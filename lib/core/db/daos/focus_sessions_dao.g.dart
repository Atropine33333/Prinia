// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_sessions_dao.dart';

// ignore_for_file: type=lint
mixin _$FocusSessionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $FocusSessionsTable get focusSessions => attachedDatabase.focusSessions;
  FocusSessionsDaoManager get managers => FocusSessionsDaoManager(this);
}

class FocusSessionsDaoManager {
  final _$FocusSessionsDaoMixin _db;
  FocusSessionsDaoManager(this._db);
  $$FocusSessionsTableTableManager get focusSessions =>
      $$FocusSessionsTableTableManager(_db.attachedDatabase, _db.focusSessions);
}
