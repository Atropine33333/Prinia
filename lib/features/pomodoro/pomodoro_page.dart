
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_shell.dart';
import '../../core/db/daos/focus_sessions_dao.dart';
import '../../core/theme/app_colors.dart';
import 'pomodoro_controller.dart';
import 'pomodoro_providers.dart';
import 'widgets/focus_line_chart.dart';
import 'widgets/ring_progress.dart';

/// 番茄钟页：计时 / 统计 双视图。
class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  bool _showStats = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showStats ? '专注统计' : '番茄钟'),
        actions: [
          IconButton(
            tooltip: _showStats ? '开始专注' : '查看统计',
            onPressed: () => setState(() => _showStats = !_showStats),
            icon: Icon(
                _showStats ? Icons.timer_outlined : Icons.insights_outlined),
          ),
          const SettingsAction(),
        ],
      ),
      body: _showStats ? const _StatsView() : const _TimerView(),
    );
  }
}

// ── 计时视图 ────────────────────────────────────────────────────

class _TimerView extends ConsumerWidget {
  const _TimerView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final state = ref.watch(pomodoroProvider);
    final controller = ref.read(pomodoroProvider.notifier);
    final today = ref.watch(todayFocusProvider);

    final isRest = state.phase == PomodoroPhase.resting ||
        state.phase == PomodoroPhase.restPaused;
    final phaseColor = isRest ? colors.highlight : colors.primary;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            // 时长设置（仅空闲可调）
            if (state.phase == PomodoroPhase.idle)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DurationStepper(
                    label: '专注',
                    minutes: state.workMinutes,
                    colors: colors,
                    onDown: () => controller
                        .setWorkMinutes(PomodoroController.stepDown(state.workMinutes)),
                    onUp: () => controller
                        .setWorkMinutes(PomodoroController.stepUp(state.workMinutes)),
                  ),
                  const SizedBox(width: 16),
                  _DurationStepper(
                    label: '休息',
                    minutes: state.restMinutes,
                    colors: colors,
                    onDown: () => controller
                        .setRestMinutes(PomodoroController.stepDown(state.restMinutes)),
                    onUp: () => controller
                        .setRestMinutes(PomodoroController.stepUp(state.restMinutes)),
                  ),
                ],
              )
            else
              Text(
                '专注 ${state.workMinutes} 分钟 · 休息 ${state.restMinutes} 分钟',
                style: TextStyle(fontSize: 13, color: colors.textMuted),
              ),
            const SizedBox(height: 24),
            // 环形进度 + 中央时间（无动画）
            SizedBox(
              width: 280,
              height: 280,
              child: RingProgress(
                fraction: state.elapsedFraction,
                breathing: false,
                progressColorOverride: phaseColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.mmss,
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2,
                        color: colors.text,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      switch (state.phase) {
                        PomodoroPhase.idle => '准备开始',
                        PomodoroPhase.focusing => '专注中…',
                        PomodoroPhase.focusPaused => '专注已暂停',
                        PomodoroPhase.resting => '休息一下',
                        PomodoroPhase.restPaused => '休息已暂停',
                      },
                      style: TextStyle(fontSize: 13, color: colors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 溜号提示
            if (state.comebackNotice)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '专注才对嘛,不许溜号╰(￣ω￣ｏ)',
                  style: TextStyle(fontSize: 14, color: colors.error),
                ),
              ),
            // 控制按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: state.phase == PomodoroPhase.idle
                      ? null
                      : () => controller.reset(),
                  icon:
                      Icon(Icons.refresh, size: 30, color: colors.textMuted),
                  tooltip: '重置',
                ),
                const SizedBox(width: 24),
                FloatingActionButton.large(
                  onPressed: controller.startOrPause,
                  backgroundColor: colors.primary,
                  foregroundColor: colors.bg,
                  child: Icon(
                    state.isRunning ? Icons.pause : Icons.play_arrow,
                    size: 44,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              switch (today.value) {
                null => '',
                int sec when sec >= 60 => '今日已专注 ${sec ~/ 60} 分钟',
                _ => '今日尚未专注',
              },
              style: TextStyle(color: colors.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationStepper extends StatelessWidget {
  final String label;
  final int minutes;
  final AppColors colors;
  final VoidCallback onDown;
  final VoidCallback onUp;

  const _DurationStepper({
    required this.label,
    required this.minutes,
    required this.colors,
    required this.onDown,
    required this.onUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12),
        color: colors.bg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label ',
              style: TextStyle(fontSize: 13, color: colors.textMuted)),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: minutes > 1 ? onDown : null,
            icon: const Icon(Icons.remove, size: 18),
            color: colors.text,
          ),
          Text('$minutes',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: colors.text)),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: minutes < 120 ? onUp : null,
            icon: const Icon(Icons.add, size: 18),
            color: colors.text,
          ),
          Text('分',
              style: TextStyle(fontSize: 13, color: colors.textMuted)),
        ],
      ),
    );
  }
}

// ── 统计视图 ────────────────────────────────────────────────────

class _StatsView extends ConsumerWidget {
  const _StatsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final week = ref.watch(last7DaysProvider);
    final sessions = ref.watch(recentSessionsProvider);
    final today = ref.watch(todayFocusProvider);

    final grouped = <DateTime, List<FocusSessionRow>>{};
    for (final s in sessions.value ?? const <FocusSessionRow>[]) {
      if (s.status != 'completed') continue;
      final d = DateTime.fromMillisecondsSinceEpoch(s.startTime);
      grouped.putIfAbsent(DateTime(d.year, d.month, d.day), () => []).add(s);
    }
    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('最近 7 天',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.text)),
                    const Spacer(),
                    Icon(Icons.timer_outlined,
                        size: 16, color: colors.primary),
                    const SizedBox(width: 4),
                    Text(
                      today.value == null
                          ? ''
                          : '今日 ${today.value! ~/ 60} 分钟',
                      style:
                          TextStyle(fontSize: 12, color: colors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FocusLineChart(data: week),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final day in days.take(14))
          _DayGroup(day: day, rows: grouped[day]!),
        if (days.isEmpty)
          SizedBox(
            height: 120,
            child: Center(
              child: Text('还没有完成的专注记录',
                  style: TextStyle(color: colors.textMuted)),
            ),
          ),
      ],
    );
  }
}

class _DayGroup extends StatelessWidget {
  final DateTime day;
  final List<FocusSessionRow> rows;
  const _DayGroup({required this.day, required this.rows});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final now = DateTime.now();
    final isToday = day.year == now.year &&
        day.month == now.month &&
        day.day == now.day;
    Intl.defaultLocale = 'zh_CN';
    final header = isToday ? '今天' : DateFormat('M月d日 EEE').format(day);
    final totalMin = rows.fold<int>(0, (s, r) => s + r.durationSeconds ~/ 60);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(header,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: colors.text)),
                const Spacer(),
                Text('$totalMin 分钟',
                    style: TextStyle(color: colors.primary, fontSize: 13)),
              ],
            ),
            const Divider(height: 16),
            for (final r in rows)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(
                  r.status == 'completed'
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  size: 18,
                  color: r.status == 'completed'
                      ? colors.primary
                      : colors.textMuted,
                ),
                title: Text(
                  '${DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(r.startTime))}'
                  ' – ${DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(r.endTime))}',
                  style: TextStyle(fontSize: 13, color: colors.text),
                ),
                trailing: Text(
                  '${r.durationSeconds ~/ 60} 分钟',
                  style: TextStyle(fontSize: 13, color: colors.textMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
