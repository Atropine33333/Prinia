import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../../core/db/database.dart';
import '../../core/sync/uuid_util.dart';
import 'course_palette.dart';
import 'periods.dart';

/// 导入映射后的一行（= 一个每周固定安排，与 courses 表一一对应）。
class ImportedCourseRow {
  final String name;
  final String? teacher;
  final String? room;
  final int weekday;
  final int startWeek;
  final int endWeek;

  /// 0=每周 1=单周 2=双周
  final int weekParity;
  final int startMinutes;
  final int durationMinutes;
  final String colorHex;

  const ImportedCourseRow({
    required this.name,
    required this.teacher,
    required this.room,
    required this.weekday,
    required this.startWeek,
    required this.endWeek,
    required this.weekParity,
    required this.startMinutes,
    required this.durationMinutes,
    required this.colorHex,
  });
}

/// 解析结果：可导入的行 + 跳过原因（用于导入报告）。
class ScheduleImportReport {
  final List<ImportedCourseRow> rows;
  final List<String> skipped;

  const ScheduleImportReport({required this.rows, required this.skipped});

  bool get isEmpty => rows.isEmpty;
}

/// 解析统一规范（v1.0）课表 JSON。
///
/// - 一行 = 一个 session × 一个连续周次段；`weeks.list` 会按 parity 过滤后
///   按步长 1/2 拆段（如 `[3..9,12..18]` → 两行；`[3,5,7,9]` → 一行单周）
/// - 时间优先取 `session.time`；缺失时用 [periods]（当前「自定义作息」）换算
/// - 仅使用 name/teacher/location/weeks/periods/time，其余字段全部忽略
ScheduleImportReport parseScheduleJson(
  String source, {
  required List<CoursePeriod> periods,
  List<String> palette = coursePalette,
}) {
  final rows = <ImportedCourseRow>[];
  final skipped = <String>[];

  dynamic root;
  try {
    root = jsonDecode(source);
  } catch (_) {
    return const ScheduleImportReport(rows: [], skipped: ['JSON 解析失败']);
  }
  if (root is! Map || root['courses'] is! List) {
    return const ScheduleImportReport(rows: [], skipped: ['缺少 courses 数组']);
  }

  for (final course in root['courses'] as List) {
    if (course is! Map) continue;
    final name = (course['name'] as String?)?.trim() ?? '';
    if (name.isEmpty) {
      skipped.add('存在缺少 name 的课程');
      continue;
    }
    final teacher = _teacherOf(course['teacher']);
    final color = palette.isEmpty
        ? '#7A9E9F'
        : palette[_stableHash(name) % palette.length];
    final sessions = course['sessions'];
    if (sessions is! List || sessions.isEmpty) {
      skipped.add('$name：没有 sessions');
      continue;
    }

    for (final session in sessions) {
      if (session is! Map) continue;
      final label = '$name${_sessionLabel(session)}';
      final weekday = session['weekday'];
      if (weekday is! int || weekday < 1 || weekday > 7) {
        skipped.add('$label：weekday 非法');
        continue;
      }
      final segments = _weekSegments(session['weeks']);
      if (segments.isEmpty) {
        skipped.add('$label：缺少可用的周次');
        continue;
      }
      final time = _sessionTime(session, periods);
      if (time == null) {
        skipped.add('$label：缺少时间（time 与 periods 都不可用）');
        continue;
      }
      final room = _roomOf(session['location']);
      for (final seg in segments) {
        rows.add(ImportedCourseRow(
          name: name,
          teacher: teacher,
          room: room,
          weekday: weekday,
          startWeek: seg.start,
          endWeek: seg.end,
          weekParity: seg.parity,
          startMinutes: time.start,
          durationMinutes: time.end - time.start,
          colorHex: color,
        ));
      }
    }
  }
  return ScheduleImportReport(rows: rows, skipped: skipped);
}

/// 写入 courses 表（追加模式，不覆盖已有课程）；返回写入行数。
Future<int> insertImportedRows(
    AppDatabase db, List<ImportedCourseRow> rows) async {
  if (rows.isEmpty) return 0;
  await db.transaction(() async {
    for (final r in rows) {
      await db.coursesDao.insertCourse(CoursesCompanion.insert(
        uuid: Value(genUuid()),
        name: r.name,
        teacher: Value(r.teacher),
        room: Value(r.room),
        weekday: r.weekday,
        startWeek: r.startWeek,
        endWeek: r.endWeek,
        weekParity: Value(r.weekParity),
        startMinutes: Value(r.startMinutes),
        durationMinutes: Value(r.durationMinutes),
        colorHex: Value(r.colorHex),
      ));
    }
  });
  return rows.length;
}

// ── 内部工具 ────────────────────────────────────────────────────

class _WeekSegment {
  final int start;
  final int end;
  final int parity; // 0=all 1=odd 2=even
  const _WeekSegment(this.start, this.end, this.parity);
}

List<_WeekSegment> _weekSegments(dynamic weeks) {
  if (weeks is! Map) return const [];
  final parityValue =
      weeks['parity'] == 'odd' ? 1 : (weeks['parity'] == 'even' ? 2 : 0);

  final rawList = weeks['list'];
  final weeksList = <int>[];
  if (rawList is List) {
    for (final w in rawList) {
      if (w is! int || w < 1 || w > 60) continue;
      // 兜底：list 未按单双过滤时以 parity 为准
      if (parityValue == 1 && w.isEven) continue;
      if (parityValue == 2 && w.isOdd) continue;
      weeksList.add(w);
    }
  }
  if (weeksList.isNotEmpty) {
    final sorted = weeksList.toSet().toList()..sort();
    return _splitRuns(sorted);
  }

  final start = weeks['start'];
  final end = weeks['end'];
  if (start is int && end is int && start >= 1 && end >= start) {
    return [_WeekSegment(start, end, parityValue)];
  }
  return const [];
}

/// 升序周次 → 连续段：步长 1 视作每周，步长 2 按起始奇偶视作单/双周。
List<_WeekSegment> _splitRuns(List<int> weeks) {
  final out = <_WeekSegment>[];
  var i = 0;
  while (i < weeks.length) {
    final start = weeks[i];
    var j = i;
    var step = 0;
    while (j + 1 < weeks.length) {
      final d = weeks[j + 1] - weeks[j];
      if (d != 1 && d != 2) break;
      if (step != 0 && step != d) break;
      step = d;
      j++;
    }
    final end = weeks[j];
    final parity = step == 2 ? (start.isOdd ? 1 : 2) : 0;
    out.add(_WeekSegment(start, end, parity));
    i = j + 1;
  }
  return out;
}

({int start, int end})? _sessionTime(
    Map session, List<CoursePeriod> periods) {
  final time = session['time'];
  if (time is Map) {
    final s = _hhmm(time['start']);
    final e = _hhmm(time['end']);
    if (s != null && e != null && e > s) return (start: s, end: e);
  }
  final p = session['periods'];
  if (p is Map && periods.isNotEmpty) {
    final ps = p['start'];
    final pe = p['end'];
    if (ps is int && pe is int && ps >= 1 && pe >= ps && pe <= periods.length) {
      final start = periods[ps - 1].startMinutes;
      final end = periods[pe - 1].endMinutes;
      if (end > start) return (start: start, end: end);
    }
  }
  return null;
}

int? _hhmm(dynamic v) {
  if (v is! String) return null;
  final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(v.trim());
  if (m == null) return null;
  final h = int.parse(m.group(1)!);
  final mi = int.parse(m.group(2)!);
  if (h > 23 || mi > 59) return null;
  return h * 60 + mi;
}

String? _teacherOf(dynamic t) {
  if (t is String) {
    final v = t.trim();
    return v.isEmpty ? null : v;
  }
  if (t is List) {
    final names = [
      for (final e in t)
        if (e is String && e.trim().isNotEmpty) e.trim(),
    ];
    return names.isEmpty ? null : names.join('、');
  }
  return null;
}

String? _roomOf(dynamic location) {
  if (location is Map) {
    final raw = location['raw'];
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
  }
  return null;
}

String _sessionLabel(Map session) {
  final parts = <String>[];
  final weekday = session['weekday'];
  if (weekday is int && weekday >= 1 && weekday <= 7) {
    parts.add('周${'一二三四五六日'[weekday - 1]}');
  }
  final p = session['periods'];
  if (p is Map && p['start'] is int && p['end'] is int) {
    parts.add('第${p['start']}-${p['end']}节');
  }
  return parts.isEmpty ? '' : '（${parts.join(' ')}）';
}

/// 稳定哈希（跨设备/跨运行一致，用于按课程名取色）。
int _stableHash(String s) {
  var h = 0x811c9dc5;
  for (final c in s.codeUnits) {
    h ^= c;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h;
}
