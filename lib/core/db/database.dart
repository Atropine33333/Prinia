import 'package:drift/drift.dart';

import '../sync/sync_service.dart';
import 'daos/accounts_dao.dart';
import 'daos/courses_dao.dart';
import 'daos/custom_categories_dao.dart';
import 'daos/focus_sessions_dao.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Accounts, FocusSessions, Courses, CustomCategories],
  daos: [AccountsDao, FocusSessionsDao, CoursesDao, CustomCategoriesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;

  /// 当前设备标识（未来多端同步时区分来源）。
  String get deviceId => NoOpSyncService.deviceId;

  /// 清空全部业务数据（调试/重置用）。
  Future<void> clearAllData() async {
    await delete(accounts).go();
    await delete(focusSessions).go();
    await delete(courses).go();
    await delete(customCategories).go();
    await customStatement('VACUUM');
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(customCategories);
          if (from < 3) {
            // 调试阶段：课程表结构变更直接重建，不迁移旧数据
            await customStatement('DROP TABLE IF EXISTS courses');
            await m.createTable(courses);
          }
        },
      );
}
