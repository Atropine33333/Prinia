import 'dart:convert';

import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

export '../database.dart' show CourseRow;

part 'courses_dao.g.dart';



/// 单条课程提醒（存储于 reminders_json）。
class CourseReminder {
  final DateTime date;
  final String text;

  const CourseReminder({required this.date, required this.text});

  Map<String, dynamic> toJson() => {
        'date':
            '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'text': text,
      };

  factory CourseReminder.fromJson(Map<String, dynamic> json) =>
      CourseReminder(
        date: DateTime.parse(json['date'] as String),
        text: json['text'] as String,
      );
}

List<CourseReminder> parseReminders(String json) => (jsonDecode(json) as List)
    .map((e) => CourseReminder.fromJson(e as Map<String, dynamic>))
    .toList();

String encodeReminders(List<CourseReminder> list) =>
    jsonEncode(list.map((e) => e.toJson()).toList());

/// 课程数据访问。
@DriftAccessor(tables: [Courses])
class CoursesDao extends DatabaseAccessor<AppDatabase> with _$CoursesDaoMixin {
  CoursesDao(super.db);

  /// 全部有效课程（周视图过滤周次在 Dart 侧做，数据量小）。
  Stream<List<CourseRow>> watchAll() {
    return (select(courses)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (u) => OrderingTerm.asc(u.weekday),
            (u) => OrderingTerm.asc(u.startMinutes),
          ]))
        .watch();
  }

  Future<int> insertCourse(CoursesCompanion entry) =>
      into(courses).insert(entry);

  Future<void> updateCourse(int id, CoursesCompanion entry) {
    return (update(courses)..where((t) => t.id.equals(id))).write(
      entry.copyWith(updatedAt: Value(DateTime.now().millisecondsSinceEpoch)),
    );
  }

  Future<void> softDelete(int id) {
    return (update(courses)..where((t) => t.id.equals(id))).write(
      CoursesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
