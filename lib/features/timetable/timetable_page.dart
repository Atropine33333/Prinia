import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_shell.dart';
import '../../core/db/database.dart';
import '../../core/db/db_provider.dart';
import '../../core/theme/app_colors.dart';
import 'course_edit_page.dart';
import 'periods.dart';
import 'timetable_providers.dart';

/// 每分钟对应的像素高度（与原 64px/小时 的疏密一致）。
const double minuteHeight = 64.0 / 60;
const double _dayHeaderH = 34.0;
const double _slotColW = 44.0;

/// 网格默认起始时刻：7:00（早于 7 点的课程会自动向上扩展）。
const int _defaultGridStart = 7 * 60;

/// 课表可视起始时刻（分钟）：默认 7:00；更早的作息或课程会自动向上扩展。
int _gridStartOf(List<CourseRow> all, List<CoursePeriod> periods) {
  var m = _defaultGridStart;
  if (periods.isNotEmpty && periods.first.startMinutes < m) {
    m = periods.first.startMinutes;
  }
  for (final c in all) {
    if (!c.isDeleted && c.startMinutes < m) m = c.startMinutes;
  }
  return m;
}

/// 课表可视结束时刻（分钟）：末节结束与最晚课程取大。
int _gridEndOf(List<CourseRow> all, List<CoursePeriod> periods) {
  var m = periods.isEmpty ? _defaultGridStart : periods.last.endMinutes;
  for (final c in all) {
    if (c.isDeleted) continue;
    final end = c.startMinutes + c.durationMinutes;
    if (end > m) m = end;
  }
  return m;
}

/// 时刻 → 相对网格顶部的像素偏移。
double _minutesToOffset(int minutes, int gridStart) =>
    (minutes - gridStart) * minuteHeight;

/// 课表页：7:00 起的节次时间轴周视图，45 分钟一节，长按课程弹出快速移动面板。
class TimetablePage extends ConsumerStatefulWidget {
  const TimetablePage({super.key});

  @override
  ConsumerState<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends ConsumerState<TimetablePage> {
  final _scrollCtrl = ScrollController();
  bool _scrolledToInit = false;

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _ensureInitialScroll(List<CourseRow> all, List<CoursePeriod> periods) {
    if (_scrolledToInit) return;
    _scrolledToInit = true;
    final active = all.where((c) => !c.isDeleted).toList();
    var startMin = 8 * 60;
    for (final c in active) {
      if (c.startMinutes < startMin) startMin = c.startMinutes;
    }
    final offset = _minutesToOffset(startMin, _gridStartOf(all, periods));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(offset.clamp(
          _scrollCtrl.position.minScrollExtent,
          _scrollCtrl.position.maxScrollExtent,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final start = ref.watch(semesterStartProvider);
    final week = ref.watch(displayedWeekProvider);
    final courses = ref.watch(coursesProvider);
    final periods = ref.watch(periodsProvider);
    _ensureInitialScroll(courses.value ?? const [], periods);

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
                    ? () => ref.read(displayedWeekProvider.notifier).state =
                        week - 1
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
    final nowMinutes = now.hour * 60 + now.minute;
    final fontSize = ref.watch(timetableFontProvider);
    final showPeriods = ref.watch(periodDisplayProvider);
    final periods = ref.watch(periodsProvider);
    final gridStart = _gridStartOf(all, periods);
    final gridEnd = _gridEndOf(all, periods);
    final gridHeight = (gridEnd - gridStart) * minuteHeight;
    final nowOffset = _minutesToOffset(nowMinutes, gridStart);
    final showNow =
        isCurrentWeek && nowMinutes >= gridStart && nowMinutes <= gridEnd;

    return SingleChildScrollView(
      controller: scrollCtrl,
      child: SizedBox(
        height: _dayHeaderH + gridHeight,
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
                  _TimeColumn(
                    periods: periods,
                    showPeriods: showPeriods,
                    onToggle: () => ref
                        .read(periodDisplayProvider.notifier)
                        .state = !showPeriods,
                    gridStart: gridStart,
                    height: gridHeight,
                  ),
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
                            // 节次分块：按作息排列，课间留白；点空白格建课
                            for (final p in periods)
                              Positioned(
                                top: _minutesToOffset(
                                    p.startMinutes, gridStart),
                                height: p.durationMinutes * minuteHeight,
                                left: 0,
                                right: 0,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () =>
                                      Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CourseEditPage(
                                        initialWeekday: d,
                                        initialStartMinutes: p.startMinutes,
                                        initialDurationMinutes:
                                            p.durationMinutes,
                                      ),
                                    ),
                                  ),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                            color: colors.border,
                                            width: 0.5),
                                        bottom: BorderSide(
                                            color: colors.border,
                                            width: 0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (showNow)
                              Positioned(
                                left: 0,
                                right: 0,
                                top: nowOffset,
                                child: Container(
                                  height: 1.5,
                                  color: colors.error.withValues(alpha: 0.7),
                                ),
                              ),
                            for (final c in all)
                              if (c.weekday == d &&
                                  !c.isDeleted &&
                                  courseRunsInWeek(c, week))
                                Positioned(
                                  top: _minutesToOffset(
                                          c.startMinutes, gridStart) +
                                      1,
                                  height: c.durationMinutes * minuteHeight - 2,
                                  left: 1,
                                  right: 1,
                                  child: CourseCard(
                                    course: c,
                                    fontSize: fontSize,
                                    onLongPress: () =>
                                        showQuickEdit(context, ref, c, all),
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
}

/// 左侧时间列：默认显示每节的起止时刻（如 08:00 / 08:45）；
/// 点击切换为节次编号。
class _TimeColumn extends StatelessWidget {
  final List<CoursePeriod> periods;
  final bool showPeriods;
  final VoidCallback onToggle;
  final int gridStart;
  final double height;

  const _TimeColumn({
    required this.periods,
    required this.showPeriods,
    required this.onToggle,
    required this.gridStart,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: SizedBox(
        width: _slotColW,
        height: height,
        child: Stack(
          children: [
            for (final p in periods)
              Positioned(
                top: _minutesToOffset(p.startMinutes, gridStart),
                height: p.durationMinutes * minuteHeight,
                left: 0,
                right: 0,
                child: Center(
                  child: showPeriods
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${p.index}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatMinutes(p.startMinutes),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: colors.text,
                              ),
                            ),
                            Text(
                              formatMinutes(p.endMinutes),
                              style: TextStyle(
                                fontSize: 9.5,
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 长按快速编辑：上下左右移动，冲突方向置灰，时长去详情改。
void showQuickEdit(
  BuildContext context,
  WidgetRef ref,
  CourseRow initial,
  List<CourseRow> all,
) {
  final colors = Theme.of(context).extension<AppColors>()!;
  final dao = ref.read(databaseProvider).coursesDao;
  var cur = initial;

  bool conflict(int weekday, int startMinutes) {
    for (final o in all) {
      if (o.uuid == cur.uuid || o.isDeleted || o.weekday != weekday) continue;
      if (!_parityOverlap(cur.weekParity, o.weekParity)) continue; // 单双周错开不算冲突
      if (startMinutes < o.startMinutes + o.durationMinutes &&
          o.startMinutes < startMinutes + cur.durationMinutes) {
        return true;
      }
    }
    return false;
  }

  bool can(int weekday, int startMinutes) =>
      weekday >= 1 &&
      weekday <= 7 &&
      startMinutes >= 0 &&
      startMinutes + cur.durationMinutes <= 24 * 60 &&
      !conflict(weekday, startMinutes);

  showModalBottomSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: StatefulBuilder(
        builder: (ctx, setSheet) {
          Future<void> move(int weekday, int startMinutes) async {
            await dao.updateCourse(
              cur.uuid,
              CoursesCompanion(
                weekday: Value(weekday),
                startMinutes: Value(startMinutes),
              ),
            );
            setSheet(
                () => cur = _copyWithTime(cur, weekday, startMinutes));
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cur.name} · ${formatMinutes(cur.startMinutes)} – ${formatMinutes(cur.startMinutes + cur.durationMinutes)} · ${_durText(cur.durationMinutes)}',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.text),
                ),
                const SizedBox(height: 6),
                Text('调时长请进「完整编辑」',
                    style: TextStyle(fontSize: 12, color: colors.textMuted)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _QuickBtn(
                      icon: Icons.arrow_upward,
                      label: '上移 15 分',
                      onTap: can(cur.weekday, cur.startMinutes - 15)
                          ? () => move(cur.weekday, cur.startMinutes - 15)
                          : null,
                    ),
                    _QuickBtn(
                      icon: Icons.arrow_downward,
                      label: '下移 15 分',
                      onTap: can(cur.weekday, cur.startMinutes + 15)
                          ? () => move(cur.weekday, cur.startMinutes + 15)
                          : null,
                    ),
                    _QuickBtn(
                      icon: Icons.arrow_back,
                      label: '前一天',
                      onTap: cur.weekday > 1 && can(cur.weekday - 1, cur.startMinutes)
                          ? () => move(cur.weekday - 1, cur.startMinutes)
                          : null,
                    ),
                    _QuickBtn(
                      icon: Icons.arrow_forward,
                      label: '后一天',
                      onTap: cur.weekday < 7 && can(cur.weekday + 1, cur.startMinutes)
                          ? () => move(cur.weekday + 1, cur.startMinutes)
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
                            builder: (_) => CourseEditPage(existing: cur)),
                      );
                    },
                    child:
                        Text('完整编辑', style: TextStyle(color: colors.primary)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

CourseRow _copyWithTime(CourseRow c, int weekday, int startMinutes) {
  return CourseRow(
    uuid: c.uuid,
    updatedAt: c.updatedAt,
    deviceId: c.deviceId,
    isDeleted: c.isDeleted,
    name: c.name,
    teacher: c.teacher,
    room: c.room,
    weekday: weekday,
    startWeek: c.startWeek,
    endWeek: c.endWeek,
    weekParity: c.weekParity,
    startMinutes: startMinutes,
    durationMinutes: c.durationMinutes,
    colorHex: c.colorHex,
    remindersJson: c.remindersJson,
  );
}

/// 两种单双周设置是否有交叠（0=每周与任意设置都重叠）。
bool _parityOverlap(int a, int b) => a == 0 || b == 0 || a == b;

String _durText(int minutes) => '$minutes 分钟';

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
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
              color: enabled
                  ? colors.border
                  : colors.border.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(10),
          color: colors.bg,
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 20,
                color: enabled ? colors.primary : colors.borderStrong),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: enabled ? colors.text : colors.borderStrong)),
          ],
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final CourseRow course;
  final double fontSize;
  final VoidCallback? onLongPress;

  const CourseCard({
    super.key,
    required this.course,
    required this.fontSize,
    this.onLongPress,
  });

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
          color: bg.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: course.name,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: onColor,
                ),
              ),
              if (course.weekParity != 0)
                TextSpan(
                  text: course.weekParity == 1 ? ' 单' : ' 双',
                  style: TextStyle(
                    fontSize: fontSize - 2,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: onColor.withValues(alpha: 0.8),
                  ),
                ),
              if (course.room?.isNotEmpty == true)
                TextSpan(
                  text: ' @${course.room}',
                  style: TextStyle(
                    fontSize: fontSize - 3,
                    height: 1.2,
                    color: onColor.withValues(alpha: 0.85),
                  ),
                ),
              if (course.teacher?.isNotEmpty == true)
                TextSpan(
                  text: ' ${course.teacher}',
                  style: TextStyle(
                    fontSize: fontSize - 3,
                    height: 1.2,
                    color: onColor.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
