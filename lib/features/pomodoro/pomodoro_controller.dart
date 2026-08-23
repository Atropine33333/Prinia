import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/db/db_provider.dart';

/// 番茄钟状态机：idle -> running <-> paused -> (完成) idle。
enum PomodoroPhase { idle, running, paused }

class PomodoroState {
  final PomodoroPhase phase;
  final int presetMinutes;
  final int remainingSeconds;

  const PomodoroState({
    this.phase = PomodoroPhase.idle,
    this.presetMinutes = 25,
    this.remainingSeconds = 25 * 60,
  });

  bool get isRunning => phase == PomodoroPhase.running;

  String get mmss {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// 已流逝比例 0~1。
  double get elapsedFraction =>
      1 - remainingSeconds / max(presetMinutes * 60, 1);

  PomodoroState copyWith({
    PomodoroPhase? phase,
    int? presetMinutes,
    int? remainingSeconds,
  }) {
    return PomodoroState(
      phase: phase ?? this.phase,
      presetMinutes: presetMinutes ?? this.presetMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }
}

class PomodoroController extends Notifier<PomodoroState> {
  Timer? _ticker;
  DateTime? _startedAt;

  @override
  PomodoroState build() {
    ref.onDispose(_cancelTicker);
    return const PomodoroState();
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  /// 选择预设时长（仅空闲时可调）。
  void setPreset(int minutes) {
    if (state.phase != PomodoroPhase.idle) return;
    state = PomodoroState(
      presetMinutes: minutes,
      remainingSeconds: minutes * 60,
    );
  }

  void startOrPause() {
    switch (state.phase) {
      case PomodoroPhase.idle:
        _startedAt = DateTime.now();
        _startTicker();
        state = state.copyWith(phase: PomodoroPhase.running);
      case PomodoroPhase.running:
        _cancelTicker();
        state = state.copyWith(phase: PomodoroPhase.paused);
      case PomodoroPhase.paused:
        _startTicker();
        state = state.copyWith(phase: PomodoroPhase.running);
    }
  }

  /// 重置；放弃超过 60 秒的会话记为 interrupted。
  Future<void> reset() async {
    _cancelTicker();
    final started = _startedAt;
    final elapsed = state.presetMinutes * 60 - state.remainingSeconds;
    final wasActive =
        state.phase != PomodoroPhase.idle && elapsed >= 60 && started != null;
    state = PomodoroState(presetMinutes: state.presetMinutes);
    _startedAt = null;
    if (wasActive) {
      await _record(
        durationSeconds: elapsed,
        startTime: started,
        status: 'interrupted',
      );
    }
  }

  void _startTicker() {
    _cancelTicker();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> _tick() async {
    final next = state.remainingSeconds - 1;
    if (next > 0) {
      state = state.copyWith(remainingSeconds: next);
      return;
    }
    // 倒计时结束
    _cancelTicker();
    final started = _startedAt ?? DateTime.now();
    state = state.copyWith(remainingSeconds: 0);
    await _record(
      durationSeconds: state.presetMinutes * 60,
      startTime: started,
      status: 'completed',
    );
    _celebrate();
    _startedAt = null;
    state = PomodoroState(presetMinutes: state.presetMinutes);
  }

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
