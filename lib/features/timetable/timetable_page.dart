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

/// 课表页：24 小时时间轴周视图，支持长按拖拽移动课程。
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) _scrollCtrl.jumpTo(8 * _hourHeight);
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
                        ref.read(displayedWeekProvider.notifier).state =
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
                    ref.read(displayedWeekProvider.notifier).state =
                        week + 1,
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
    final fontSize = ref.watch(timetableFontProvider);

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
                  for (var d = 1; d <= 7; d++)
                    Expanded(
                      child: DragTarget<CourseRow>(
                        onWillAcceptWithDetails: (_) => true,
                        onAcceptWithDetails: (details) {
                          final box =
                              context.findRenderObject() as RenderBox;
                          final local = box.globalToLocal(details.offset);
                          var hour =
                              (local.dy / _hourHeight).round().clamp(0, 23);
                          final c = details.data;
                          hour = hour.clamp(0, 24 - c.durationHours);
                          ref
                              .read(databaseProvider)
                              .coursesDao
                              .updateCourse(
                                c.id,
                                CoursesCompanion(
                                  weekday: Value(d),
                                  startHour: Value(hour),
                                ),
                              );
                        },
                        builder: (ctx, _, _) => Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                  color: colors.border, width: 0.5),
                            ),
                            color: isCurrentWeek && d == todayWeekday
                                ? colors.primary.withValues(alpha: 0.04)
                                : null,
                          ),
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  for (var h = 0; h < 24; h++)
                                    SizedBox(
                                      height: _hourHeight,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () =>
                                            Navigator.of(context).push(
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
                              if (isCurrentWeek && d == todayWeekday)
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  top: nowOffset,
                                  child: Container(
                                    height: 1.5,
                                    color:
                                        colors.error.withValues(alpha: 0.7),
                                  ),
                                ),
                              for (final c in all)
                                if (c.weekday == d &&
                                    !c.isDeleted &&
                                    week >= c.startWeek &&
                                    week <= c.endWeek)
                                  Positioned(
                                    top: c.startHour * _hourHeight + 1,
                                    height: c.durationHours * _hourHeight - 2,
                                    left: 1,
                                    right: 1,
                                    child: LongPressDraggable<CourseRow>(
                                      data: c,
                                      delay: const Duration(milliseconds: 160),
                                      feedback: Material(
                                        color: Colors.transparent,
                                        child: _CourseCard(
                                          course: c,
                                          fontSize: fontSize,
                                          dragging: true,
                                        ),
                                      ),
                                      childWhenDragging: Opacity(
                                          opacity: 0.3,
                                          child: _CourseCard(
                                              course: c, fontSize: fontSize)),
                                      child: _CourseCard(
                                        course: c,
                                        fontSize: fontSize,
                                      ),
                                    ),
                                  ),
                            ],
                          ),
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

class _CourseCard extends StatelessWidget {
  final CourseRow course;
  final double fontSize;
  final bool dragging;

  const _CourseCard({
    required this.course,
    required this.fontSize,
    this.dragging = false,
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
      onTap: dragging
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => CourseEditPage(existing: course)),
              ),
      child: Container(
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          color: bg.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(7),
          boxShadow: dragging
              ? [BoxShadow(color: const Color(0x33000000), blurRadius: 10)]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左：课程名（bold，自动换行）
            Expanded(
              child: Text(
                course.name,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  color: onColor,
                ),
              ),
            ),
            const SizedBox(width: 4),
            // 右：地点/老师 竖排（固定窄列）
            SizedBox(
              width: 44,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (course.room?.isNotEmpty == true)
                    Text(
                      '@${course.room}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: fontSize - 3,
                          height: 1.2,
                          color: onColor.withValues(alpha: 0.9)),
                    ),
                  if (course.teacher?.isNotEmpty == true)
                    Text(
                      course.teacher!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: fontSize - 3,
                          height: 1.2,
                          color: onColor.withValues(alpha: 0.75)),
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
