import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_shell.dart';
import '../../core/db/database.dart';
import '../../core/db/db_provider.dart';
import '../../core/theme/app_colors.dart';
import 'course_edit_page.dart';
import 'timetable_providers.dart';

const _hourHeight = 64.0;
const _dayHeaderH = 34.0;
const _slotColW = 44.0;

/// 课表页：24 小时时间轴周视图。
class TimetablePage extends ConsumerStatefulWidget {
  const TimetablePage({super.key});

  @override
  ConsumerState<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends ConsumerState<TimetablePage> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    // 默认滚到 8:00
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(8 * _hourHeight);
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final start = ref.watch(semesterStartProvider);
    final week = ref.watch(displayedWeekProvider);
    final courses = ref.watch(coursesProvider);

    final monday = start.add(Duration(days: (week - 1) * 7));
    final today = DateTime.now();
    final todayWeekday = today.weekday;
    final isCurrentWeek =
        ref.read(semesterStartProvider.notifier).weekOf(today) == week;

    return Scaffold(
      appBar: AppBar(
        title: Text('第 $week 周'),
        actions: [
          IconButton(
            tooltip: '新建课程',
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CourseEditPage(
                  initialWeekday: isCurrentWeek ? todayWeekday : 1,
                ),
              ),
            ),
          ),
          const SettingsAction(),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                color: colors.textMuted,
                onPressed: week > 1
                    ? () =>
                        ref.read(displayedWeekProvider.notifier).state = week - 1
                    : null,
              ),
              Text(
                '${DateFormat('M月d日').format(monday)} – ${DateFormat('M月d日').format(monday.add(const Duration(days: 6)))}',
                style: TextStyle(fontSize: 14, color: colors.textMuted),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                color: colors.textMuted,
                onPressed: () =>
                    ref.read(displayedWeekProvider.notifier).state = week + 1,
              ),
            ],
          ),
          Divider(height: 1, color: colors.border),
          Expanded(
            child: courses.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败：$e')),
              data: (all) => _Grid(
                week: week,
                all: all,
                isCurrentWeek: isCurrentWeek,
                todayWeekday: todayWeekday,
                scrollCtrl: _scrollCtrl,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Grid extends ConsumerWidget {
  final int week;
  final List<CourseRow> all;
  final bool isCurrentWeek;
  final int todayWeekday;
  final ScrollController scrollCtrl;

  const _Grid({
    required this.week,
    required this.all,
    required this.isCurrentWeek,
    required this.todayWeekday,
    required this.scrollCtrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final now = DateTime.now();
    final nowOffset = (now.hour + now.minute / 60) * _hourHeight;

    return SingleChildScrollView(
      controller: scrollCtrl,
      child: SizedBox(
        height: _dayHeaderH + 24 * _hourHeight,
        child: Column(
          children: [
            SizedBox(
              height: _dayHeaderH,
              child: Row(
                children: [
                  const SizedBox(width: _slotColW),
                  for (var d = 1; d <= 7; d++)
                    Expanded(
                      child: Center(
                        child: Text(
                          '周${'一二三四五六日'[d - 1]}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isCurrentWeek && d == todayWeekday
                                ? FontWeight.w700
                                : FontWeight.normal,
                            color: isCurrentWeek && d == todayWeekday
                                ? colors.primary
                                : colors.textMuted,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  // 小时列
                  SizedBox(
                    width: _slotColW,
                    child: Column(
                      children: [
                        for (var h = 0; h < 24; h++)
                          SizedBox(
                            height: _hourHeight,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Transform.translate(
                                offset: const Offset(0, -6),
                                child: Text(
                                  '${h.toString().padLeft(2, '0')}:00',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: colors.textMuted),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // 七天列
                  for (var d = 1; d <= 7; d++)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left:
                                BorderSide(color: colors.border, width: 0.5),
                          ),
                          color: isCurrentWeek && d == todayWeekday
                              ? colors.primary.withValues(alpha: 0.04)
                              : null,
                        ),
                        child: Stack(
                          children: [
                            // 整点横线 + 空位点击
                            Column(
                              children: [
                                for (var h = 0; h < 24; h++)
                                  SizedBox(
                                    height: _hourHeight,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => CourseEditPage(
                                            initialWeekday: d,
                                            initialHour: h,
                                          ),
                                        ),
                                      ),
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                                color: colors.border,
                                                width: 0.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            // 当前时间线（本周今天）
                            if (isCurrentWeek && d == todayWeekday)
                              Positioned(
                                left: 0,
                                right: 0,
                                top: nowOffset,
                                child: Container(
                                  height: 1.5,
                                  color: colors.error.withValues(alpha: 0.7),
                                ),
                              ),
                            // 课程卡片
                            for (final c in all)
                              if (c.weekday == d &&
                                  !c.isDeleted &&
                                  week >= c.startWeek &&
                                  week <= c.endWeek)
                                Positioned(
                                  top: c.startHour * _hourHeight + 1,
                                  height:
                                      c.durationHours * _hourHeight - 2,
                                  left: 1,
                                  right: 1,
                                  child: _CourseCard(
                                    course: c,
                                    onLongPress: () =>
                                        _showQuickEdit(context, ref, c),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 长按快速编辑：调时长、上下左右移动（均即时保存）。
  void _showQuickEdit(BuildContext context, WidgetRef ref, CourseRow c) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final dao = ref.read(databaseProvider).coursesDao;

    Future<void> update(CoursesCompanion entry) async {
      await dao.updateCourse(
        c.id,
        CoursesCompanion(
          startHour: entry.startHour,
          durationHours: entry.durationHours,
          weekday: entry.weekday,
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: StatefulBuilder(
          builder: (ctx, setSheet) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${c.name} · ${c.startHour}:00 – ${c.startHour + c.durationHours}:00',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.text),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _QuickBtn(
                      icon: Icons.arrow_upward,
                      label: '上移',
                      onTap: c.startHour > 0
                          ? () => update(CoursesCompanion(
                              startHour: Value(c.startHour - 1)))
                          : null,
                    ),
                    _QuickBtn(
                      icon: Icons.arrow_downward,
                      label: '下移',
                      onTap: c.startHour + c.durationHours < 24
                          ? () => update(CoursesCompanion(
                              startHour: Value(c.startHour + 1)))
                          : null,
                    ),
                    _QuickBtn(
                      icon: Icons.arrow_back,
                      label: '前一天',
                      onTap: c.weekday > 1
                          ? () => update(
                              CoursesCompanion(weekday: Value(c.weekday - 1)))
                          : null,
                    ),
                    _QuickBtn(
                      icon: Icons.arrow_forward,
                      label: '后一天',
                      onTap: c.weekday < 7
                          ? () => update(
                              CoursesCompanion(weekday: Value(c.weekday + 1)))
                          : null,
                    ),
                    _QuickBtn(
                      icon: Icons.remove,
                      label: '短 1 小时',
                      onTap: c.durationHours > 1
                          ? () => update(CoursesCompanion(
                              durationHours: Value(c.durationHours - 1)))
                          : null,
                    ),
                    _QuickBtn(
                      icon: Icons.add,
                      label: '长 1 小时',
                      onTap: c.startHour + c.durationHours < 24
                          ? () => update(CoursesCompanion(
                              durationHours: Value(c.durationHours + 1)))
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => CourseEditPage(existing: c)),
                      );
                    },
                    child: Text('完整编辑',
                        style: TextStyle(color: colors.primary)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickBtn({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(10),
          color: colors.bg,
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: onTap == null ? colors.borderStrong : colors.primary),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color:
                        onTap == null ? colors.borderStrong : colors.text)),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseRow course;
  final VoidCallback onLongPress;

  const _CourseCard({required this.course, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final bg = Color(int.parse(course.colorHex.replaceFirst('#', ''),
            radix: 16) |
        0xFF000000);
    final onColor =
        bg.computeLuminance() > 0.5 ? colors.text : Colors.white;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CourseEditPage(existing: course)),
      ),
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          color: bg.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左：课程名（bold，自动换行）
            Expanded(
              child: Text(
                course.name,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  color: onColor,
                ),
              ),
            ),
            const SizedBox(width: 3),
            // 右：地点/老师 竖排
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (course.room?.isNotEmpty == true)
                  Text(
                    '@${course.room}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        height: 1.15,
                        color: onColor.withValues(alpha: 0.9)),
                  ),
                if (course.teacher?.isNotEmpty == true)
                  Text(
                    course.teacher!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        height: 1.15,
                        color: onColor.withValues(alpha: 0.75)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
