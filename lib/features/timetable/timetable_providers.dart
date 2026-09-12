import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/db/database.dart';
import '../../core/db/db_provider.dart';
import '../../core/sync/device_identity.dart';
import 'periods.dart';

export '../../core/db/daos/courses_dao.dart'
    show CourseRow, CourseReminder, encodeReminders, parseReminders;

/// 学期开始日期（周一），存储于 app_meta（随设备同步）。
final semesterStartProvider =
    NotifierProvider<SemesterStartController, DateTime>(
        SemesterStartController.new);

class SemesterStartController extends Notifier<DateTime> {
  static const _key = 'semester_start';
  static const _uuid = 'meta-semester-start';

  @override
  DateTime build() {
    // 数据库行变化时自动刷新（同步写入也会触达）
    ref.listen(semesterStartRowProvider, (_, next) {
      final row = next.value;
      if (row != null) {
        final d = DateTime.tryParse(row.metaValue);
        if (d != null && d != state) state = d;
      }
    });
    Future.microtask(_load);
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day)
        .subtract(Duration(days: n.weekday - 1));
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final row = await (db.select(db.appMeta)
          ..where((t) => t.metaKey.equals(_key)))
        .getSingleOrNull();
    if (row != null) {
      final d = DateTime.tryParse(row.metaValue);
      if (d != null) {
        state = d;
        return;
      }
    }
    // 旧版本遗留：prefs 迁移进 app_meta
    final sp = await SharedPreferences.getInstance();
    final legacy = sp.getString(_key);
    if (legacy != null) {
      final d = DateTime.tryParse(legacy);
      if (d != null) {
        await set(d);
        return;
      }
    }
  }

  Future<void> set(DateTime d) async {
    state = DateTime(d.year, d.month, d.day);
    final db = ref.read(databaseProvider);
    await db.into(db.appMeta).insertOnConflictUpdate(AppMetaCompanion(
          uuid: const Value(_uuid),
          metaKey: const Value(_key),
          metaValue: Value(state.toIso8601String().substring(0, 10)),
          updatedAt:
              Value(DateTime.now().millisecondsSinceEpoch),
          deviceId: Value(DeviceIdentity.current),
        ));
  }

  /// 第几周（1 起）。
  int weekOf(DateTime day) {
    final diff = DateTime(day.year, day.month, day.day).difference(state);
    return (diff.inDays / 7).floor() + 1;
  }
}

/// 学期开始日期所在行流。
final semesterStartRowProvider = StreamProvider<AppMetaRow?>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.appMeta)
        ..where((t) => t.metaKey.equals('semester_start')))
      .watchSingleOrNull();
});

/// 自定义作息（存 app_meta，随同步下发；无自定义时用默认华科 12 节）。
final periodsProvider =
    NotifierProvider<PeriodsController, List<CoursePeriod>>(
        PeriodsController.new);

class PeriodsController extends Notifier<List<CoursePeriod>> {
  static const _key = 'custom_periods';
  static const _uuid = 'meta-custom-periods';

  @override
  List<CoursePeriod> build() {
    // 同步写入也会触达，自动刷新
    ref.listen(periodsRowProvider, (_, next) {
      final row = next.value;
      if (row == null) return;
      final parsed = parsePeriods(row.metaValue);
      if (parsed != null && !samePeriods(parsed, state)) state = parsed;
    });
    Future.microtask(_load);
    return defaultPeriods;
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final row = await (db.select(db.appMeta)
          ..where((t) => t.metaKey.equals(_key)))
        .getSingleOrNull();
    if (row != null) {
      final parsed = parsePeriods(row.metaValue);
      if (parsed != null) state = parsed;
    }
  }

  /// 保存自定义作息（节次按顺序重排）；非法时抛 [ArgumentError]。
  Future<void> set(List<CoursePeriod> periods) async {
    final error = validatePeriods(periods);
    if (error != null) throw ArgumentError(error);
    final normalized = [
      for (var i = 0; i < periods.length; i++)
        CoursePeriod(i + 1, periods[i].startMinutes, periods[i].endMinutes),
    ];
    state = normalized;
    final db = ref.read(databaseProvider);
    await db.into(db.appMeta).insertOnConflictUpdate(AppMetaCompanion(
          uuid: const Value(_uuid),
          metaKey: const Value(_key),
          metaValue: Value(encodePeriods(normalized)),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
          deviceId: Value(DeviceIdentity.current),
        ));
  }

  /// 恢复默认（华科 12 节）。
  Future<void> reset() => set(defaultPeriods);
}

/// 自定义作息所在行流。
final periodsRowProvider = StreamProvider<AppMetaRow?>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.appMeta)
        ..where((t) => t.metaKey.equals('custom_periods')))
      .watchSingleOrNull();
});

/// 当前查看的周数（相对学期开始，1 起）。
final displayedWeekProvider = StateProvider<int>((ref) {
  final start = ref.watch(semesterStartProvider);
  final n = DateTime.now();
  final diff =
      DateTime(n.year, n.month, n.day).difference(start);
  final w = (diff.inDays / 7).floor() + 1;
  return w < 1 ? 1 : w;
});

/// 全部课程流。
final coursesProvider = StreamProvider<List<CourseRow>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.coursesDao.watchAll();
});

/// 指定周在指定 weekday 上课的课程（含单双周过滤）。
List<CourseRow> coursesForDay(List<CourseRow> all, int week, int weekday) {
  return all
      .where((c) =>
          c.weekday == weekday && !c.isDeleted && courseRunsInWeek(c, week))
      .toList()
    ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
}

/// 课程在第 [week] 周是否上课（周次范围 + 单双周）。
///
/// [CourseRow.weekParity]：0=每周，1=单周（奇数周），2=双周（偶数周）。
bool courseRunsInWeek(CourseRow course, int week) {
  if (week < course.startWeek || week > course.endWeek) return false;
  return switch (course.weekParity) {
    1 => week.isOdd,
    2 => week.isEven,
    _ => true,
  };
}

/// 时间列显示模式：false=时刻，true=节次（点击时间列切换）。
final periodDisplayProvider = StateProvider<bool>((ref) => false);

/// 课表课程名字号（设置页可调）。
final timetableFontProvider =
    NotifierProvider<TimetableFontController, double>(
        TimetableFontController.new);

class TimetableFontController extends Notifier<double> {
  static const _key = 'timetable_font_size';

  @override
  double build() {
    Future.microtask(_load);
    return 14;
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getDouble(_key);
    if (v != null && v >= 10 && v <= 22) {
      state = v;
    }
  }

  Future<void> set(double v) async {
    state = v.clamp(10, 22);
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble(_key, state);
  }
}
