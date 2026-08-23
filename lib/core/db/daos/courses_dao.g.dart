// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'courses_dao.dart';

// ignore_for_file: type=lint
mixin _$CoursesDaoMixin on DatabaseAccessor<AppDatabase> {
  $CoursesTable get courses => attachedDatabase.courses;
  CoursesDaoManager get managers => CoursesDaoManager(this);
}

class CoursesDaoManager {
  final _$CoursesDaoMixin _db;
  CoursesDaoManager(this._db);
  $$CoursesTableTableManager get courses =>
      $$CoursesTableTableManager(_db.attachedDatabase, _db.courses);
}
