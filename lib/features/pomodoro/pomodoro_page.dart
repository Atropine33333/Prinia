import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/db/daos/focus_sessions_dao.dart';
import '../../app/app_shell.dart';
import '../../core/theme/app_colors.dart';
import 'pomodoro_controller.dart';
import 'pomodoro_providers.dart';
import 'widgets/focus_line_chart.dart';
import 'widgets/ring_progress.dart';

const _presets = [15, 25, 45];

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
            icon: Icon(_showStats
                ? Icons.timer_outlined
                : Icons.insights_outlined),
          ),
          const SettingsAction(),
        ],
      ),
      body: _showStats ? const _StatsView() : const _TimerView(),
    );
  }
}

// ── 计时视图 ────────────────────────────────────────────────────

class _TimerView extends ConsumerStatefulWidget {
  const _TimerView();

  @override
  ConsumerState<_TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends ConsumerState<_TimerView>
    with SingleTickerProviderStateMixin {
  // 呼吸动画：周期 2s，仅运行时播放
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
    lowerBound: 0.97,
    upperBound: 1.03,
  );

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PomodoroState>(pomodoroProvider, (_, s) {
      if (s.isRunning) {
        if (!_breath.isAnimating) _breath.repeat(reverse: true);
      } else if (_breath.isAnimating) {
        _breath.stop();
      }
    });

    final colors = Theme.of(context).extension<AppColors>()!;
    final state = ref.watch(pomodoroProvider);
    final controller = ref.read(pomodoroProvider.notifier);
    final today = ref.watch(todayFocusProvider);

    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 预设时长 chips（仅空闲可选）
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final m in _presets)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ChoiceChip(
                      label: Text('$m 分钟'),
                      selected: state.presetMinutes == m,
                      onSelected: state.phase == PomodoroPhase.idle &&
                              m != state.presetMinutes
                          ? (_) => controller.setPreset(m)
                          : null,
                      selectedColor: colors.activeBg,
                      labelStyle: TextStyle(
                        color: state.presetMinutes == m
                            ? colors.primary
                            : colors.textMuted,
                      ),
                      side: BorderSide(
                        color: state.presetMinutes == m
                            ? colors.primary
                            : colors.border,
                      ),
                      showCheckmark: false,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            // 环形进度 + 中央时间
            ScaleTransition(
              scale: state.isRunning
                  ? _breath
                  : const AlwaysStoppedAnimation(1.0),
              child: SizedBox(
                width: 280,
                height: 280,
                child: RingProgress(
                  fraction: state.elapsedFraction,
                  breathing: state.isRunning,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: anim,
                          child: child,
                        ),
                        child: Text(
                          key: ValueKey(state.mmss.substring(0, 2)),
                          state.mmss,
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2,
                            color: colors.text,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        switch (state.phase) {
                          PomodoroPhase.idle => '准备开始',
                          PomodoroPhase.running => '专注中…',
                          PomodoroPhase.paused => '已暂停',
                        },
                        style: TextStyle(
                            fontSize: 13, color: colors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // 控制按钮：重置 + 开始/暂停
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: state.phase == PomodoroPhase.idle
                      ? null
                      : () => controller.reset(),
                  icon: Icon(Icons.refresh, size: 30, color: colors.textMuted),
                  tooltip: '重置',
                ),
                const SizedBox(width: 24),
                // 开始->暂停 图标旋转过渡
                AnimatedRotation(
                  turns: state.phase == PomodoroPhase.running ? 0.5 : 0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutBack,
                  child: FloatingActionButton.large(
                    onPressed: controller.startOrPause,
                    backgroundColor: colors.primary,
                    foregroundColor: colors.bg,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        key: ValueKey(state.phase),
                        state.phase == PomodoroPhase.running
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 44,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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

// ── 统计视图 ────────────────────────────────────────────────────

class _StatsView extends ConsumerWidget {
  const _StatsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final week = ref.watch(last7DaysProvider);
    final sessions = ref.watch(recentSessionsProvider);
    final today = ref.watch(todayFocusProvider);

    // 按日期分组（仅 completed）
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
                      style: TextStyle(fontSize: 12, color: colors.textMuted),
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
        for (final day in days.take(14)) _DayGroup(day: day, rows: grouped[day]!),
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
    final header =
        isToday ? '今天' : DateFormat('M月d日 EEE').format(day);
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
