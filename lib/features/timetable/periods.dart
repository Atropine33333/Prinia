import 'dart:convert';

/// 一节课的时间段（当日 0 点起的分钟数）。
class CoursePeriod {
  /// 节次（1 起，保存时按顺序重排）。
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

/// 分钟数 → `HH:mm`。
String formatMinutes(int m) =>
    '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

// ── 序列化（app_meta 存储、随同步下发）─────────────────────────

/// 作息 → JSON 数组：`[{"s":480,"e":525}, ...]`。
String encodePeriods(List<CoursePeriod> periods) => jsonEncode([
      for (final p in periods) {'s': p.startMinutes, 'e': p.endMinutes},
    ]);

/// JSON → 作息；格式非法或校验不过返回 null。
List<CoursePeriod>? parsePeriods(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List || decoded.isEmpty) return null;
    final periods = <CoursePeriod>[];
    for (var i = 0; i < decoded.length; i++) {
      final item = decoded[i];
      if (item is! Map) return null;
      final s = item['s'];
      final e = item['e'];
      if (s is! int || e is! int) return null;
      periods.add(CoursePeriod(i + 1, s, e));
    }
    return validatePeriods(periods) == null ? periods : null;
  } catch (_) {
    return null;
  }
}

/// 校验作息：合法返回 null，否则返回错误文案。
String? validatePeriods(List<CoursePeriod> periods) {
  if (periods.isEmpty) return '至少保留一节';
  if (periods.length > 24) return '最多 24 节';
  var prevEnd = -1;
  for (final p in periods) {
    if (p.startMinutes < 0 || p.endMinutes > 24 * 60) {
      return '第 ${p.index} 节时间需在 00:00–24:00 内';
    }
    final duration = p.endMinutes - p.startMinutes;
    if (duration < 5) return '第 ${p.index} 节时长至少 5 分钟';
    if (duration > 240) return '第 ${p.index} 节时长过长';
    if (p.startMinutes < prevEnd) return '第 ${p.index} 节与上一节时间重叠';
    prevEnd = p.endMinutes;
  }
  return null;
}

/// 两份作息是否等价（按顺序比较起止）。
bool samePeriods(List<CoursePeriod> a, List<CoursePeriod> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i].startMinutes != b[i].startMinutes ||
        a[i].endMinutes != b[i].endMinutes) {
      return false;
    }
  }
  return true;
}

// ── 查询 ────────────────────────────────────────────────────────

/// [minute] 时刻在 [periods] 中所处的节次；课间不属于任何节，返回 null。
CoursePeriod? periodAtMinute(List<CoursePeriod> periods, int minute) {
  for (final p in periods) {
    if (minute >= p.startMinutes && minute < p.endMinutes) return p;
  }
  return null;
}

/// 课程时间恰好覆盖的连续节次（起止与 [periods] 完全吻合）；否则返回 null。
///
/// 例：10:10–11:50 → 第 3、4 节；8:00–9:00 含课间，返回 null。
List<CoursePeriod>? coveredPeriods(
    List<CoursePeriod> periods, int startMinutes, int endMinutes) {
  final covered = [
    for (final p in periods)
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
