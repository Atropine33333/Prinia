import 'package:drift/drift.dart';

import '../sync/sync_service.dart';
import 'daos/accounts_dao.dart';
import 'daos/courses_dao.dart';
import 'daos/focus_sessions_dao.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Accounts, FocusSessions, Courses],
  daos: [AccountsDao, FocusSessionsDao, CoursesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  /// 当前设备标识（未来多端同步时区分来源）。
  String get deviceId => NoOpSyncService.deviceId;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );
}
