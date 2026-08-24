import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/db/db_provider.dart';
import '../../core/db/daos/courses_dao.dart';

export '../../core/db/daos/courses_dao.dart'
    show CourseRow, CourseReminder, encodeReminders, parseReminders;

/// 学期开始日期（周一），用于计算当前周数。
final semesterStartProvider =
    NotifierProvider<SemesterStartController, DateTime>(
        SemesterStartController.new);

class SemesterStartController extends Notifier<DateTime> {
  static const _key = 'semester_start';

  @override
  DateTime build() {
    Future.microtask(_load);
    // 默认：本周一
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day)
        .subtract(Duration(days: n.weekday - 1));
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_key);
    if (s != null) {
      state = DateTime.parse(s);
    }
  }

  Future<void> set(DateTime d) async {
    state = DateTime(d.year, d.month, d.day);
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, state.toIso8601String().substring(0, 10));
  }

  /// 第几周（1 起）。
  int weekOf(DateTime day) {
    final diff = DateTime(day.year, day.month, day.day).difference(state);
    return (diff.inDays / 7).floor() + 1;
  }
}

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

/// 指定周在指定 weekday 上课的课程。
List<CourseRow> coursesForDay(List<CourseRow> all, int week, int weekday) {
  return all
      .where((c) =>
          c.weekday == weekday &&
          !c.isDeleted &&
          week >= c.startWeek &&
          week <= c.endWeek)
      .toList()
    ..sort((a, b) => a.startHour.compareTo(b.startHour));
}
