import 'package:drift/drift.dart';

import '../sync/sync_service.dart';
import '../sync/device_identity.dart';
import '../sync/uuid_util.dart';
import 'daos/accounts_dao.dart';
import 'daos/courses_dao.dart';
import 'daos/custom_categories_dao.dart';
import 'daos/focus_sessions_dao.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Accounts,
    FocusSessions,
    Courses,
    CustomCategories,
    AppMeta,
    SyncPeers,
  ],
  daos: [AccountsDao, FocusSessionsDao, CoursesDao, CustomCategoriesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 6;

  /// 当前设备标识（未来多端同步时区分来源）。
  String get deviceId => NoOpSyncService.deviceId;

  /// 全表最大 updated_at（判断是否有待同步变更）。
  Future<int> maxUpdatedAt() async {
    final row = await customSelect(
      'SELECT MAX(u) AS m FROM ('
      ' SELECT MAX(updated_at) AS u FROM accounts UNION ALL'
      ' SELECT MAX(updated_at) FROM focus_sessions UNION ALL'
      ' SELECT MAX(updated_at) FROM courses UNION ALL'
      ' SELECT MAX(updated_at) FROM custom_categories UNION ALL'
      ' SELECT MAX(updated_at) FROM app_meta'
      ')',
    ).getSingleOrNull();
    final v = row?.data['m'];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  /// 清空全部业务数据（调试/重置用）。
  Future<void> clearAllData() async {
    await delete(accounts).go();
    await delete(focusSessions).go();
    await delete(courses).go();
    await delete(customCategories).go();
    await customStatement('VACUUM');
  }

  /// 清空全部课程（含软删除行；测试用，自定义作息保留）。
  Future<void> clearAllCourses() async {
    await delete(courses).go();
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
          if (from < 4) {
            await customStatement('DROP TABLE IF EXISTS courses');
            await m.createTable(courses);
          }
          if (from < 5) {
            // v5：为四张业务表加 uuid 主键列（回填随机 uuid，保留数据），
            // 并新增 app_meta / sync_peers。
            for (final t in ['accounts', 'focus_sessions', 'courses', 'custom_categories']) {
              await customStatement('ALTER TABLE $t ADD COLUMN uuid TEXT');
              await customStatement(
                  "UPDATE $t SET uuid = lower(hex(randomblob(16))) WHERE uuid IS NULL");
              await customStatement(
                  'CREATE UNIQUE INDEX IF NOT EXISTS idx_${t}_uuid ON $t(uuid)');
            }
            await m.createTable(appMeta);
            await m.createTable(syncPeers);
          }
          if (from < 6) {
            // v6：课程支持单双周（0=每周 1=单周 2=双周）
            await customStatement(
                'ALTER TABLE courses ADD COLUMN week_parity INTEGER NOT NULL DEFAULT 0');
          }
        },
      );
}
