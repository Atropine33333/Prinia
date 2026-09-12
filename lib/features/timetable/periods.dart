/// 一节课的时间段（当日 0 点起的分钟数）。
class CoursePeriod {
  /// 节次（1 起）。
  final int index;
  final int startMinutes;
  final int endMinutes;

  const CoursePeriod(this.index, this.startMinutes, this.endMinutes);

  int get durationMinutes => endMinutes - startMinutes;
}

/// 默认作息（华中科技大学）：上午 4 节、下午 4 节、晚上 4 节，自 8:00 起共 12 节。
///
/// 全天时段：8:00–11:50 / 14:30–18:00 / 19:00–22:20。
const defaultPeriods = <CoursePeriod>[
  CoursePeriod(1, 8 * 60, 8 * 60 + 45), // 08:00–08:45
  CoursePeriod(2, 8 * 60 + 55, 9 * 60 + 40), // 08:55–09:40
  CoursePeriod(3, 10 * 60 + 10, 10 * 60 + 55), // 10:10–10:55
  CoursePeriod(4, 11 * 60 + 5, 11 * 60 + 50), // 11:05–11:50
  CoursePeriod(5, 14 * 60 + 30, 15 * 60 + 15), // 14:30–15:15
  CoursePeriod(6, 15 * 60 + 25, 16 * 60 + 10), // 15:25–16:10
  CoursePeriod(7, 16 * 60 + 20, 17 * 60 + 5), // 16:20–17:05
  CoursePeriod(8, 17 * 60 + 15, 18 * 60), // 17:15–18:00
  CoursePeriod(9, 19 * 60, 19 * 60 + 45), // 19:00–19:45
  CoursePeriod(10, 19 * 60 + 50, 20 * 60 + 35), // 19:50–20:35
  CoursePeriod(11, 20 * 60 + 45, 21 * 60 + 30), // 20:45–21:30
  CoursePeriod(12, 21 * 60 + 35, 22 * 60 + 20), // 21:35–22:20
];

/// [minute] 时刻所处的节次；课间不属于任何节，返回 null。
CoursePeriod? periodAtMinute(int minute) {
  for (final p in defaultPeriods) {
    if (minute >= p.startMinutes && minute < p.endMinutes) return p;
  }
  return null;
}

/// 课程时间恰好覆盖的连续节次（起止与作息完全吻合）；否则返回 null。
///
/// 例：10:10–11:50 → 第 3、4 节；8:00–9:00 有 10 分钟课间，返回 null。
List<CoursePeriod>? coveredPeriods(int startMinutes, int endMinutes) {
  final covered = [
    for (final p in defaultPeriods)
      if (p.startMinutes >= startMinutes && p.endMinutes <= endMinutes) p,
  ];
  if (covered.isEmpty) return null;
  if (covered.first.startMinutes != startMinutes ||
      covered.last.endMinutes != endMinutes) {
    return null;
  }
  for (var i = 1; i < covered.length; i++) {
    if (covered[i].index != covered[i - 1].index + 1) return null;
  }
  return covered;
}

/// 节次区间的紧凑文案：`第3-4节` / `第5节`。
String formatPeriodSpan(List<CoursePeriod> periods) {
  if (periods.isEmpty) return '';
  final first = periods.first.index;
  final last = periods.last.index;
  return first == last ? '第$first节' : '第$first-$last节';
}
