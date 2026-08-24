import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_shell.dart';
import '../../core/theme/app_colors.dart';
import 'course_edit_page.dart';
import 'timetable_providers.dart';

const _slotCount = 12;

/// 课表页：周视图网格（横向周一~周日，纵向 1~12 节）。
class TimetablePage extends ConsumerWidget {
  const TimetablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final start = ref.watch(semesterStartProvider);
    final week = ref.watch(displayedWeekProvider);
    final courses = ref.watch(coursesProvider);

    // 本周七天的日期
    final monday = start.add(Duration(days: (week - 1) * 7));
    final today = DateTime.now();
    final todayWeekday = today.weekday;
    final isCurrentWeek = ref.read(semesterStartProvider.notifier).weekOf(today) == week;

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
          // 周切换
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                color: colors.textMuted,
                onPressed: week > 1
                    ? () => ref.read(displayedWeekProvider.notifier).state = week - 1
                    : null,
              ),
              Text(
                '${DateFormat('M月d日').format(monday)} – ${DateFormat('M月d日').format(monday.add(const Duration(days: 6)))}',
                style: TextStyle(fontSize: 13, color: colors.textMuted),
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
          // 网格
          Expanded(
            child: courses.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败：$e')),
              data: (all) => _Grid(
                week: week,
                all: all,
                isCurrentWeek: isCurrentWeek,
                todayWeekday: todayWeekday,
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

  const _Grid({
    required this.week,
    required this.all,
    required this.isCurrentWeek,
    required this.todayWeekday,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    const dayHeaderH = 32.0;
    const slotColW = 34.0;

    return SingleChildScrollView(
      child: SizedBox(
        height: dayHeaderH + _slotCount * 56.0,
        child: Column(
          children: [
            // 星期表头
            SizedBox(
              height: dayHeaderH,
              child: Row(
                children: [
                  const SizedBox(width: slotColW),
                  for (var d = 1; d <= 7; d++)
                    Expanded(
                      child: Center(
                        child: Text(
                          '周${'一二三四五六日'[d - 1]}',
                          style: TextStyle(
                            fontSize: 12,
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
            // 课程网格
            Expanded(
              child: Row(
                children: [
                  // 节次列
                  SizedBox(
                    width: slotColW,
                    child: Column(
                      children: [
                        for (var s = 1; s <= _slotCount; s++)
                          SizedBox(
                            height: 56,
                            child: Center(
                              child: Text('$s',
                                  style: TextStyle(
                                      fontSize: 11, color: colors.textMuted)),
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
                            left: BorderSide(color: colors.border, width: 0.5),
                            top: BorderSide(color: colors.border, width: 0.5),
                          ),
                          color: isCurrentWeek && d == todayWeekday
                              ? colors.primary.withValues(alpha: 0.04)
                              : null,
                        ),
                        child: Stack(
                          children: [
                            // 空槽点击热区
                            Column(
                              children: [
                                for (var s = 1; s <= _slotCount; s++)
                                  SizedBox(
                                    height: 56,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => CourseEditPage(
                                            initialWeekday: d,
                                            initialSlot: s,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            // 课程卡片
                            for (final c in coursesForDay(all, week, d))
                              Positioned(
                                top: (c.startSlot - 1) * 56.0 + 1,
                                height: (c.endSlot - c.startSlot + 1) * 56.0 - 2,
                                left: 1,
                                right: 1,
                                child: _CourseCard(course: c),
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

class _CourseCard extends StatelessWidget {
  final CourseRow course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final bg = Color(int.parse(
            course.colorHex.replaceFirst('#', ''), radix: 16) |
        0xFF000000);
    // 根据背景亮度选择文字颜色
    final onColor =
        bg.computeLuminance() > 0.5 ? colors.text : Colors.white;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CourseEditPage(existing: course)),
      ),
      child: Container(
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: bg.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: onColor),
            ),
            if (course.room?.isNotEmpty == true)
              Text(
                '@${course.room}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, color: onColor.withValues(alpha: 0.85)),
              ),
          ],
        ),
      ),
    );
  }
}
