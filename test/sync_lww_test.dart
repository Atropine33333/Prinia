import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_note/core/db/database.dart';
import 'package:octo_note/core/sync/device_identity.dart';
import 'package:octo_note/core/sync/sync_tables.dart';
import 'package:octo_note/core/db/daos/courses_dao.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase a; // 设备 A
  late AppDatabase b; // 设备 B
  late List<SyncTableAdapter> adaptersA;
  late List<SyncTableAdapter> adaptersB;

  SyncTableAdapter ad(List<SyncTableAdapter> l, String n) =>
      l.firstWhere((e) => e.name == n);

  setUp(() {
    DeviceIdentity.overrideForTest('dev-a');
    a = AppDatabase(NativeDatabase.memory());
    DeviceIdentity.overrideForTest('dev-b');
    b = AppDatabase(NativeDatabase.memory());
    DeviceIdentity.overrideForTest('dev-a');
    adaptersA = buildSyncAdapters(a);
    adaptersB = buildSyncAdapters(b);
  });

  tearDown(() async {
    await a.close();
    await b.close();
  });

  /// A 的变更应用到 B。
  Future<void> pushAToB(
      int since, List<SyncTableAdapter> from, List<SyncTableAdapter> to) async {
    for (final adapter in from) {
      final changes = await adapter.changesSince(since);
      for (final row in changes) {
        await ad(to, adapter.name).applyLww(row);
      }
    }
  }

  group('LWW 同步', () {
    test('新行从 A 流向 B', () async {
      await a.into(a.accounts).insert(AccountsCompanion.insert(
            uuid: const Value('row-1'),
            amount: 12.5,
            type: 'expense',
            category: '餐饮',
            updatedAt: const Value(1000),
          ));

      await pushAToB(0, adaptersA, adaptersB);

      final rows = await b.select(b.accounts).get();
      expect(rows, hasLength(1));
      expect(rows.first.uuid, 'row-1');
      expect(rows.first.deviceId, 'dev-a');
      expect(rows.first.amount, 12.5);
    });

    test('旧时间戳不覆盖新数据（LWW）', () async {
      // B 上已有较新的修改
      await b.into(b.accounts).insert(AccountsCompanion.insert(
            uuid: const Value('row-1'),
            amount: 99,
            type: 'expense',
            category: '购物',
            updatedAt: const Value(2000),
            deviceId: const Value('dev-b'),
          ));
      // A 上是旧版本
      await a.into(a.accounts).insert(AccountsCompanion.insert(
            uuid: const Value('row-1'),
            amount: 1,
            type: 'expense',
            category: '餐饮',
            updatedAt: const Value(1000),
          ));

      await pushAToB(0, adaptersA, adaptersB);

      final row = await (b.select(b.accounts)..where(
              (t) => t.uuid.equals('row-1')))
          .getSingle();
      expect(row.amount, 99, reason: '旧数据不应覆盖新数据');
    });

    test('新时间戳覆盖旧数据（双向收敛）', () async {
      // 两端都有 row-1，A 更新（时间更新）
      await b.into(b.accounts).insert(AccountsCompanion.insert(
            uuid: const Value('row-1'),
            amount: 1,
            type: 'expense',
            category: '餐饮',
            updatedAt: const Value(1000),
            deviceId: const Value('dev-b'),
          ));
      await a.into(a.accounts).insert(AccountsCompanion.insert(
            uuid: const Value('row-1'),
            amount: 50,
            type: 'expense',
            category: '餐饮',
            updatedAt: const Value(3000),
          ));

      await pushAToB(0, adaptersA, adaptersB);

      // B 的状态回流 A：LWW 判定 A 的行不比 B 旧，A 不回滚（收敛）
      final changesFromB =
          await ad(adaptersB, 'accounts').changesSince(0);
      for (final row in changesFromB) {
        await ad(adaptersA, 'accounts').applyLww(row);
      }
      final back = await (a.select(a.accounts)
            ..where((t) => t.uuid.equals('row-1')))
          .getSingle();
      expect(back.amount, 50, reason: '双向同步后两端收敛，不回滚');
    });

    test('时间平局按 device_id 字典序裁决', () async {
      await b.into(b.accounts).insert(AccountsCompanion.insert(
            uuid: const Value('row-1'),
            amount: 1,
            type: 'expense',
            category: '餐饮',
            updatedAt: const Value(1000),
            deviceId: const Value('dev-b'),
          ));
      await a.into(a.accounts).insert(AccountsCompanion.insert(
            uuid: const Value('row-1'),
            amount: 2,
            type: 'expense',
            category: '餐饮',
            updatedAt: const Value(1000),
            deviceId: const Value('dev-a'),
          ));

      await pushAToB(0, adaptersA, adaptersB);

      final row = await (b.select(b.accounts)..where(
              (t) => t.uuid.equals('row-1')))
          .getSingle();
      expect(row.amount, 1, reason: 'dev-b 字典序大于 dev-a，应胜出');
    });

    test('时间平局：字典序大的设备胜出（反向）', () async {
      await b.into(b.accounts).insert(AccountsCompanion.insert(
            uuid: const Value('row-1'),
            amount: 1,
            type: 'expense',
            category: '餐饮',
            updatedAt: const Value(1000),
            deviceId: const Value('dev-b'),
          ));
      await a.into(a.accounts).insert(AccountsCompanion.insert(
            uuid: const Value('row-1'),
            amount: 2,
            type: 'expense',
            category: '餐饮',
            updatedAt: const Value(1000),
            deviceId: const Value('dev-c'),
          ));

      await pushAToB(0, adaptersA, adaptersB);

      final row = await (b.select(b.accounts)..where(
              (t) => t.uuid.equals('row-1')))
          .getSingle();
      expect(row.amount, 2, reason: 'dev-c 字典序大于 dev-b，应胜出');
    });

    test('墓碑同步：A 删除后 B 也删除', () async {
      await a.into(a.accounts).insert(AccountsCompanion.insert(
            uuid: const Value('row-1'),
            amount: 10,
            type: 'expense',
            category: '餐饮',
            updatedAt: const Value(1000),
          ));
      await pushAToB(0, adaptersA, adaptersB);

      // A 软删除
      await (a.update(a.accounts)..where((t) => t.uuid.equals('row-1')))
          .write(AccountsCompanion(
        isDeleted: const Value(true),
        updatedAt: const Value(2000),
      ));

      await pushAToB(1000, adaptersA, adaptersB); // 增量

      final row = await (b.select(b.accounts)..where(
              (t) => t.uuid.equals('row-1')))
          .getSingle();
      expect(row.isDeleted, true);
    });

    test('增量游标：只取上次之后的变更', () async {
      await a.into(a.accounts).insert(AccountsCompanion.insert(
            uuid: const Value('old'),
            amount: 1,
            type: 'expense',
            category: '餐饮',
            updatedAt: const Value(1000),
          ));
      await a.into(a.accounts).insert(AccountsCompanion.insert(
            uuid: const Value('new'),
            amount: 2,
            type: 'expense',
            category: '餐饮',
            updatedAt: const Value(5000),
          ));

      final changes = await ad(adaptersA, 'accounts').changesSince(1000);
      expect(changes.map((e) => e['uuid']), ['new']);
    });

    test('自定义标签行往返（含猫猫码点）', () async {
      await a.into(a.customCategories).insert(CustomCategoriesCompanion.insert(
            uuid: const Value('tag-1'),
            name: '猫粮',
            iconCode: const Value(-1), // 猫猫头
            type: 'expense',
            updatedAt: const Value(1000),
          ));

      await pushAToB(0, adaptersA, adaptersB);

      final row = await (b.select(b.customCategories)).getSingle();
      expect(row.name, '猫粮');
      expect(row.iconCode, -1);
      expect(row.type, 'expense');
    });

    test('课程行全字段往返', () async {
      await a.into(a.courses).insert(CoursesCompanion.insert(
            uuid: const Value('course-1'),
            name: '高等数学',
            teacher: const Value('张三'),
            room: const Value('教一 101'),
            weekday: 2,
            startWeek: 1,
            endWeek: 16,
            weekParity: const Value(2),
            startMinutes: const Value(8 * 60 + 30),
            durationMinutes: const Value(90),
            colorHex: const Value('#8896AB'),
            remindersJson:
                const Value('[{"date":"2026-12-01","text":"交作业"}]'),
            updatedAt: const Value(1000),
          ));

      await pushAToB(0, adaptersA, adaptersB);

      final row = await (b.select(b.courses)).getSingle();
      expect(row.name, '高等数学');
      expect(row.teacher, '张三');
      expect(row.weekParity, 2);
      expect(row.startMinutes, 510);
      expect(row.durationMinutes, 90);
      expect(parseReminders(row.remindersJson), hasLength(1));
    });
  });
}
