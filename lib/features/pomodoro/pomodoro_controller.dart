import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/db/database.dart';
import '../../core/db/db_provider.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/platform/screen_state.dart';

/// 番茄钟阶段：专注 <-> 休息 循环。
enum PomodoroPhase { idle, focusing, focusPaused, resting, restPaused }

class PomodoroState {
  final PomodoroPhase phase;
  final int workMinutes;
  final int restMinutes;
  final int remainingSeconds;

  /// 从后台溜号回来后显示的提示（专注才对嘛…）。
  final bool comebackNotice;

  const PomodoroState({
    this.phase = PomodoroPhase.idle,
    this.workMinutes = 25,
    this.restMinutes = 5,
    this.remainingSeconds = 25 * 60,
    this.comebackNotice = false,
  });

  bool get isActive =>
      phase == PomodoroPhase.focusing ||
      phase == PomodoroPhase.resting;

  bool get isFocusLike =>
      phase == PomodoroPhase.focusing || phase == PomodoroPhase.focusPaused;

  bool get isRunning => phase == PomodoroPhase.focusing || phase == PomodoroPhase.resting;

  String get mmss {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// 已流逝比例 0~1。
  double get elapsedFraction =>
      1 -
      remainingSeconds /
          max((isFocusLike ? workMinutes : restMinutes) * 60, 1);

  PomodoroState copyWith({
    PomodoroPhase? phase,
    int? workMinutes,
    int? restMinutes,
    int? remainingSeconds,
    bool? comebackNotice,
  }) {
    return PomodoroState(
      phase: phase ?? this.phase,
      workMinutes: workMinutes ?? this.workMinutes,
      restMinutes: restMinutes ?? this.restMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      comebackNotice: comebackNotice ?? this.comebackNotice,
    );
  }
}

class PomodoroController extends Notifier<PomodoroState>
    with WidgetsBindingObserver {
  Timer? _ticker;
  DateTime? _startedAt;

  /// 当前阶段的墙钟结束点；暂停/空闲时为 null。
  ///
  /// 倒计时一律按 `结束点 - 现在` 计算，进程被系统冻结后回前台也能自动校正。
  DateTime? _phaseEndAt;
  AppLifecycleListener? _lifecycle;
  bool _restNotifyScheduled = false;

  /// 当前是否在前台；用于避免「快速切出又切回」时异步息屏判定误暂停。
  bool _inForeground = true;

  @override
  PomodoroState build() {
    ref.onDispose(_teardown);
    _lifecycle ??= _makeLifecycleListener();
    Future.microtask(_loadDurations);
    return const PomodoroState();
  }

  Future<void> _loadDurations() async {
    final sp = await SharedPreferences.getInstance();
    final w = sp.getInt('pomodoro_work');
    final r = sp.getInt('pomodoro_rest');
    if (w == null && r == null) return;
    state = state.copyWith(
      workMinutes: (w != null && w >= 1) ? w : state.workMinutes,
      restMinutes: (r != null && r >= 1) ? r : state.restMinutes,
      remainingSeconds: ((w != null && w >= 1) ? w : state.workMinutes) * 60,
    );
  }

  Future<void> _saveDurations() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('pomodoro_work', state.workMinutes);
    await sp.setInt('pomodoro_rest', state.restMinutes);
  }

  /// 步进：5 的倍数之间步进 5；1 与 5 互通（5→1→5→10…）。
  static int stepDown(int m) => m <= 5 ? 1 : m - 5;
  static int stepUp(int m) => m < 5 ? 5 : m + 5;

  AppLifecycleListener _makeLifecycleListener() {
    return AppLifecycleListener(
      onHide: _onAppHide,
      onResume: _onAppResume,
    );
  }

  void _teardown() {
    _cancelTicker();
    _lifecycle?.dispose();
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  // ── 设置 ───────────────────────────────────────────────────

  void setWorkMinutes(int m) {
    if (state.phase != PomodoroPhase.idle || m < 1) return;
    state = state.copyWith(workMinutes: m, remainingSeconds: m * 60);
    unawaited(_saveDurations());
  }

  void setRestMinutes(int m) {
    if (state.phase != PomodoroPhase.idle || m < 1) return;
    state = state.copyWith(restMinutes: m);
    unawaited(_saveDurations());
  }

  // ── 控制 ───────────────────────────────────────────────────

  void startOrPause() {
    state = state.copyWith(comebackNotice: false);
    switch (state.phase) {
      case PomodoroPhase.idle:
        _beginPhase(PomodoroPhase.focusing, state.workMinutes);
      case PomodoroPhase.focusing:
      case PomodoroPhase.resting:
        _pausePhase();
      case PomodoroPhase.focusPaused:
      case PomodoroPhase.restPaused:
        _resumePhase();
    }
  }

  /// 开始一段新阶段（专注/休息）：记录开始时刻与墙钟结束点。
  void _beginPhase(PomodoroPhase phase, int minutes) {
    final now = DateTime.now();
    _startedAt = now;
    _phaseEndAt = now.add(Duration(seconds: minutes * 60));
    state = state.copyWith(
      phase: phase,
      remainingSeconds: minutes * 60,
    );
    _startTicker();
  }

  /// 暂停当前阶段：剩余时间固定在 state，清空墙钟结束点。
  void _pausePhase() {
    final fromClock = _remainingFromClock();
    _phaseEndAt = null;
    _cancelTicker();
    state = state.copyWith(
      phase: state.phase == PomodoroPhase.focusing
          ? PomodoroPhase.focusPaused
          : PomodoroPhase.restPaused,
      remainingSeconds: fromClock == null || fromClock <= 0
          ? state.remainingSeconds
          : fromClock,
    );
  }

  /// 从暂停恢复：以当前剩余时间重新计算墙钟结束点。
  void _resumePhase() {
    _phaseEndAt =
        DateTime.now().add(Duration(seconds: max(state.remainingSeconds, 1)));
    state = state.copyWith(
      phase: state.phase == PomodoroPhase.focusPaused
          ? PomodoroPhase.focusing
          : PomodoroPhase.resting,
    );
    _startTicker();
  }

  /// 按墙钟计算的剩余秒数；未在计时中（空闲/暂停）返回 null。
  int? _remainingFromClock() {
    final endAt = _phaseEndAt;
    if (endAt == null) return null;
    return endAt.difference(DateTime.now()).inSeconds;
  }

  /// 重置回空闲（保留时长设置）。
  Future<void> reset() async {
    _cancelTicker();
    final started = _startedAt;
    final totalSec =
        (state.isFocusLike ? state.workMinutes : state.restMinutes) * 60;
    final elapsed = totalSec - state.remainingSeconds;
    final wasFocus = state.phase == PomodoroPhase.focusing;
    final wasActive = state.isActive && elapsed >= 60 && started != null;
    state = PomodoroState(
      workMinutes: state.workMinutes,
      restMinutes: state.restMinutes,
      remainingSeconds: state.workMinutes * 60,
    );
    _startedAt = null;
    _phaseEndAt = null;
    if (wasActive && wasFocus) {
      await _record(
        durationSeconds: elapsed,
        startTime: started,
        status: 'interrupted',
      );
    }
  }

  /// 【调试】快进到距结束 3 秒。
  void debugSkipToEnd() {
    if (state.isActive) {
      _phaseEndAt = DateTime.now().add(const Duration(seconds: 3));
      _startTicker();
      state = state.copyWith(remainingSeconds: 3);
    }
  }

  // ── 计时 ───────────────────────────────────────────────────

  void _startTicker() {
    _cancelTicker();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> _tick() async {
    final fromClock = _remainingFromClock();
    if (fromClock == null) return; // 已暂停/未在计时
    final prev = state.remainingSeconds;

    // 休息剩 1 分钟提醒（后台被冻结可能跨过 60s，用区间判断）
    if (state.phase == PomodoroPhase.resting && prev > 60 && fromClock <= 60) {
      NotificationService.showPomodoro(
        '还有一分钟休息就结束了哦——',
      );
    }

    if (fromClock > 0) {
      if (fromClock != prev) {
        state = state.copyWith(remainingSeconds: fromClock);
      }
      return;
    }
    _cancelTicker();
    await _onPhaseComplete();
  }

  Future<void> _onPhaseComplete() async {
    final started = _startedAt ?? DateTime.now();
    if (state.phase == PomodoroPhase.focusing ||
        state.phase == PomodoroPhase.focusPaused) {
      // 专注完成 → 记录 + 进入休息
      await _record(
        durationSeconds: state.workMinutes * 60,
        startTime: started,
        status: 'completed',
      );
      _celebrate();
      _restNotifyScheduled = false;
      _beginPhase(PomodoroPhase.resting, state.restMinutes);
    } else {
      // 休息完成 → 自动开始下一轮专注（循环计时）
      _celebrate();
      state = state.copyWith(comebackNotice: false);
      _beginPhase(PomodoroPhase.focusing, state.workMinutes);
    }
  }

  // ── 生命周期：溜号检测 ──────────────────────────────────────

  void _onAppHide() {
    _inForeground = false;
    if (state.phase == PomodoroPhase.focusing) {
      // 息屏不算溜号：屏幕点亮才判定为切换应用
      unawaited(() async {
        final screenOn = await ScreenState.isInteractive();
        if (!screenOn) return; // 息屏：继续计时（墙钟校正）
        if (_inForeground) return; // 已回到前台，无需暂停
        if (state.phase != PomodoroPhase.focusing) return;
        _pausePhase();
        NotificationService.showPomodoro('快回来——(╬▔皿▔)╯',
            payload: 'pomodoro_back');
      }());
    } else if (state.phase == PomodoroPhase.resting) {
      // 休息时溜号：继续计时，预约剩 1 分钟的通知
      final remainAtNotify = state.remainingSeconds - 60;
      if (remainAtNotify > 0) {
        _restNotifyScheduled = true;
        NotificationService.schedulePomodoroIn(
          Duration(seconds: state.remainingSeconds - 60),
          '还有一分钟休息就结束了哦——',
        );
      }
    }
  }

  void _onAppResume() {
    _inForeground = true;
    if (_restNotifyScheduled) {
      _restNotifyScheduled = false;
      NotificationService.cancelScheduledPomodoro();
    }
    // 后台/息屏期间进程可能被系统冻结：回前台按墙钟校正剩余，必要时补结算
    if (state.isActive) {
      final fromClock = _remainingFromClock() ?? state.remainingSeconds;
      if (fromClock <= 0) {
        _cancelTicker();
        unawaited(_onPhaseComplete());
      } else {
        if (state.phase == PomodoroPhase.resting &&
            state.remainingSeconds > 60 &&
            fromClock <= 60) {
          NotificationService.showPomodoro('还有一分钟休息就结束了哦——');
        }
        state = state.copyWith(remainingSeconds: fromClock);
        _startTicker(); // 定时器可能被挂起，回前台重新起表
      }
    }
    if (state.phase == PomodoroPhase.focusPaused && _startedAt != null) {
      // 从专注溜号回来：提示（计时已停，等用户手动继续）
      state = state.copyWith(comebackNotice: true);
    }
  }

  // ── 辅助 ───────────────────────────────────────────────────

  Future<void> _record({
    required int durationSeconds,
    required DateTime startTime,
    required String status,
  }) async {
    final db = ref.read(databaseProvider);
    await db.focusSessionsDao.insertSession(
      FocusSessionsCompanion.insert(
        durationSeconds: Value(durationSeconds),
        startTime: Value(startTime.millisecondsSinceEpoch),
        endTime: DateTime.now().millisecondsSinceEpoch,
        status: status,
      ),
    );
  }

  void _celebrate() {
    unawaited(() async {
      for (var i = 0; i < 3; i++) {
        await HapticFeedback.vibrate();
        await Future<void>.delayed(const Duration(milliseconds: 180));
      }
    }());
    SystemSound.play(SystemSoundType.alert);
  }
}


final pomodoroProvider =
    NotifierProvider<PomodoroController, PomodoroState>(
  PomodoroController.new,
);
