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
  AppLifecycleListener? _lifecycle;
  bool _restNotifyScheduled = false;

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
        _startedAt = DateTime.now();
        _startTicker();
        state = state.copyWith(
          phase: PomodoroPhase.focusing,
          remainingSeconds: state.workMinutes * 60,
        );
      case PomodoroPhase.focusing:
        _cancelTicker();
        state = state.copyWith(phase: PomodoroPhase.focusPaused);
      case PomodoroPhase.focusPaused:
      case PomodoroPhase.restPaused:
        _startTicker();
        state = state.copyWith(
          phase: state.phase == PomodoroPhase.focusPaused
              ? PomodoroPhase.focusing
              : PomodoroPhase.resting,
        );
      case PomodoroPhase.resting:
        _cancelTicker();
        state = state.copyWith(phase: PomodoroPhase.restPaused);
    }
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
    final next = state.remainingSeconds - 1;

    // 休息剩 1 分钟提醒（前台也提醒，保持一致性）
    if (state.phase == PomodoroPhase.resting && next == 60) {
      NotificationService.showPomodoro(
        '还有一分钟休息就结束了哦——',
      );
    }

    if (next > 0) {
      state = state.copyWith(remainingSeconds: next);
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
      _startedAt = DateTime.now();
      _restNotifyScheduled = false;
      state = state.copyWith(
        phase: PomodoroPhase.resting,
        remainingSeconds: state.restMinutes * 60,
      );
      _startTicker();
    } else {
      // 休息完成 → 自动开始下一轮专注（循环计时）
      _celebrate();
      _startedAt = DateTime.now();
      state = state.copyWith(
        phase: PomodoroPhase.focusing,
        remainingSeconds: state.workMinutes * 60,
        comebackNotice: false,
      );
      _startTicker();
    }
  }

  // ── 生命周期：溜号检测 ──────────────────────────────────────

  void _onAppHide() {
    if (state.phase == PomodoroPhase.focusing) {
      // 专注时溜号：停表 + 立即通知
      _cancelTicker();
      state = state.copyWith(phase: PomodoroPhase.focusPaused);
      NotificationService.showPomodoro('快回来——(╬▔皿▔)╯', payload: 'pomodoro_back');
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
    if (_restNotifyScheduled) {
      _restNotifyScheduled = false;
      NotificationService.cancelScheduledPomodoro();
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
