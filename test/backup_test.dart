import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_note/core/backup/backup_service.dart';
import 'package:octo_note/core/db/database.dart';
import 'package:octo_note/core/sync/device_identity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('导出→导入：业务数据完整还原（保留 uuid/时间戳/单双周）', () async {
    DeviceIdentity.overrideForTest('dev-a');
    final src = AppDatabase(NativeDatabase.memory());
    await src.into(src.accounts).insert(AccountsCompanion.insert(
          uuid: const Value('a-1'),
          amount: 12.5,
          type: 'expense',
          category: '餐饮',
          updatedAt: const Value(1000),
        ));
    await src.into(src.courses).insert(CoursesCompanion.insert(
          uuid: const Value('c-1'),
          name: '高等数学',
          weekday: 1,
          startWeek: 3,
          endWeek: 9,
          weekParity: const Value(1),
          startMinutes: const Value(480),
          durationMinutes: const Value(100),
          updatedAt: const Value(2000),
        ));

    final json = await exportBackup(src);

    DeviceIdentity.overrideForTest('dev-b');
    final dst = AppDatabase(NativeDatabase.memory());
    final result = await importBackup(json, dst);

    expect(result.applied, 2);
    expect(result.skipped, 0);

    final accounts = await dst.select(dst.accounts).get();
    expect(accounts.single.uuid, 'a-1');
    expect(accounts.single.updatedAt, 1000);
    expect(accounts.single.deviceId, 'dev-a');
    expect(accounts.single.amount, 12.5);

    final courses = await dst.select(dst.courses).get();
    expect(courses.single.name, '高等数学');
    expect(courses.single.weekParity, 1);
    expect(courses.single.durationMinutes, 100);

    await src.close();
    await dst.close();
  });

  test('LWW：本机更新的同 uuid 行不被旧备份覆盖', () async {
    DeviceIdentity.overrideForTest('dev-a');
    final src = AppDatabase(NativeDatabase.memory());
    await src.into(src.accounts).insert(AccountsCompanion.insert(
          uuid: const Value('a-1'),
          amount: 1,
          type: 'expense',
          category: '餐饮',
          updatedAt: const Value(1000),
        ));
    final json = await exportBackup(src);

    DeviceIdentity.overrideForTest('dev-b');
    final dst = AppDatabase(NativeDatabase.memory());
    await dst.into(dst.accounts).insert(AccountsCompanion.insert(
          uuid: const Value('a-1'),
          amount: 99,
          type: 'expense',
          category: '购物',
          updatedAt: const Value(5000),
          deviceId: const Value('dev-b'),
        ));

    final result = await importBackup(json, dst);
    expect(result.applied, 0);
    expect(result.skipped, 1);
    final row = await (dst.select(dst.accounts)
          ..where((t) => t.uuid.equals('a-1')))
        .getSingle();
    expect(row.amount, 99);

    await src.close();
    await dst.close();
  });

  test('非法文件抛 FormatException', () async {
    final db = AppDatabase(NativeDatabase.memory());
    expect(() => importBackup('{}', db), throwsFormatException);
    expect(() => importBackup('not json', db), throwsFormatException);
    await db.close();
  });

  test('偏好设置只迁移白名单键', () async {
    SharedPreferences.setMockInitialValues({
      'pomodoro_work': 30,
      'active_theme_id': 'dark',
      'install_device_id': 'should-not-migrate',
    });
    final src = AppDatabase(NativeDatabase.memory());
    final json = await exportBackup(src);
    expect(json.contains('install_device_id'), isFalse);

    SharedPreferences.setMockInitialValues({});
    final dst = AppDatabase(NativeDatabase.memory());
    final result = await importBackup(json, dst);
    expect(result.prefs, 2);

    final sp = await SharedPreferences.getInstance();
    expect(sp.getInt('pomodoro_work'), 30);
    expect(sp.getString('active_theme_id'), 'dark');
    expect(sp.containsKey('install_device_id'), isFalse);

    await src.close();
    await dst.close();
  });
}
