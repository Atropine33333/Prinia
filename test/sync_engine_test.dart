import 'dart:async';
import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_note/core/db/database.dart';
import 'package:octo_note/core/sync/device_identity.dart';
import 'package:octo_note/core/sync/sync_engine.dart';

/// 内存双工管道：A.send → B.incoming，B.send → A.incoming。
class PipeChannel implements SyncChannel {
  final void Function(Uint8List) _onSend;
  final _incoming = StreamController<Uint8List>(); // 非广播：先缓冲后投递，贴近 socket 语义

  PipeChannel(this._onSend);

  @override
  Future<void> send(Uint8List frame) async => _onSend(frame);

  @override
  Stream<Uint8List> get incoming => _incoming.stream;

  void deliver(Uint8List frame) => _incoming.add(frame);

  @override
  Future<void> close() async => _incoming.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase a;
  late AppDatabase b;

  setUp(() {
    DeviceIdentity.overrideForTest('dev-a');
    a = AppDatabase(NativeDatabase.memory());
    DeviceIdentity.overrideForTest('dev-b');
    b = AppDatabase(NativeDatabase.memory());
  });

  /// 每次会话新建互联管道，同时跑 A、B 两端，等双方都完成。
  Future<(SyncResult, SyncResult)> runBoth() async {
    late PipeChannel aSide;
    late PipeChannel bSide;
    aSide = PipeChannel((f) => bSide.deliver(f));
    bSide = PipeChannel((f) => aSide.deliver(f));

    final engineA = SyncEngine(db: a, myDeviceId: 'dev-a', myDeviceName: '手机');
    final engineB = SyncEngine(db: b, myDeviceId: 'dev-b', myDeviceName: '平板');

    final rA = engineA.run(aSide);
    final rB = engineB.run(bSide);

    return (await rA, await rB);
  }

  test('全量首同步：A 的账目流向 B，B 的账目流向 A', () async {
    DeviceIdentity.overrideForTest('dev-a');
    await a.into(a.accounts).insert(AccountsCompanion.insert(
          uuid: const Value('a-1'),
          amount: 10,
          type: 'expense',
          category: '餐饮',
          updatedAt: const Value(1000),
        ));
    DeviceIdentity.overrideForTest('dev-b');
    await b.into(b.accounts).insert(AccountsCompanion.insert(
          uuid: const Value('b-1'),
          amount: 20,
          type: 'income',
          category: '其他',
          updatedAt: const Value(2000),
        ));

    final (ra, rb) = await runBoth();

    expect(ra.applied, 1, reason: 'A 收到 B 的 b-1');
    expect(rb.applied, 1, reason: 'B 收到 A 的 a-1');
    expect(ra.peerName, '平板');
    expect(rb.peerName, '手机');

    // 双端收敛：各有两条
    expect(await (a.select(a.accounts)).get(), hasLength(2));
    expect(await (b.select(b.accounts)).get(), hasLength(2));
  });

  test('增量二轮同步：只传新变更，双向修改收敛', () async {
    // 首轮：各自一条
    DeviceIdentity.overrideForTest('dev-a');
    await a.into(a.accounts).insert(AccountsCompanion.insert(
          uuid: const Value('a-1'),
          amount: 10,
          type: 'expense',
          category: '餐饮',
          updatedAt: const Value(1000),
        ));
    DeviceIdentity.overrideForTest('dev-b');
    await b.into(b.accounts).insert(AccountsCompanion.insert(
          uuid: const Value('b-1'),
          amount: 20,
          type: 'income',
          category: '其他',
          updatedAt: const Value(2000),
        ));
    await runBoth();

    // 二轮前：A 改 b-1，B 改 a-1（交叉修改）
    DeviceIdentity.overrideForTest('dev-a');
    await (a.update(a.accounts)..where((t) => t.uuid.equals('b-1')))
        .write(AccountsCompanion(amount: const Value(25), updatedAt: const Value(3000)));
    DeviceIdentity.overrideForTest('dev-b');
    await (b.update(b.accounts)..where((t) => t.uuid.equals('a-1')))
        .write(AccountsCompanion(amount: const Value(15), updatedAt: const Value(3500)));

    final (ra, rb) = await runBoth();

    expect(ra.applied, 1);
    expect(rb.applied, 1);

    // 双端收敛一致
    final rowsA = await (a.select(a.accounts)
          ..where((t) => t.uuid.isIn(['a-1', 'b-1'])))
        .get();
    final rowsB = await (b.select(b.accounts)
          ..where((t) => t.uuid.isIn(['a-1', 'b-1'])))
        .get();
    final mapA = {for (final r in rowsA) r.uuid: r.amount};
    final mapB = {for (final r in rowsB) r.uuid: r.amount};
    expect(mapA, mapB);
    expect(mapA['a-1'], 15);
    expect(mapA['b-1'], 25);
  });

  test('删除同步为墓碑', () async {
    DeviceIdentity.overrideForTest('dev-a');
    await a.into(a.accounts).insert(AccountsCompanion.insert(
          uuid: const Value('a-1'),
          amount: 10,
          type: 'expense',
          category: '餐饮',
          updatedAt: const Value(1000),
        ));
    await runBoth();

    // A 删除
    DeviceIdentity.overrideForTest('dev-a');
    await (a.update(a.accounts)..where((t) => t.uuid.equals('a-1')))
        .write(AccountsCompanion(
      isDeleted: const Value(true),
      updatedAt: const Value(5000),
    ));

    await runBoth();

    final row = await (b.select(b.accounts)
          ..where((t) => t.uuid.equals('a-1')))
        .getSingle();
    expect(row.isDeleted, true);
  });

  test('对端游标更新：二轮不重传旧数据', () async {
    DeviceIdentity.overrideForTest('dev-a');
    await a.into(a.accounts).insert(AccountsCompanion.insert(
          uuid: const Value('a-1'),
          amount: 10,
          type: 'expense',
          category: '餐饮',
          updatedAt: const Value(1000),
        ));
    final (ra, _) = await runBoth();
    expect(ra.sent, 1);

    // 无任何新改动再跑一轮
    final (ra2, _) = await runBoth();
    expect(ra2.sent, 0, reason: '游标已推进，无增量可发');
    expect(ra2.applied, 0);
  });

  test('课程表随会话同步', () async {
    DeviceIdentity.overrideForTest('dev-a');
    await a.into(a.courses).insert(CoursesCompanion.insert(
          uuid: const Value('c-1'),
          name: '数据结构',
          weekday: 3,
          startWeek: 1,
          endWeek: 16,
          startMinutes: const Value(14 * 60),
          durationMinutes: const Value(90),
          updatedAt: const Value(1000),
        ));

    final (_, rb) = await runBoth();
    expect(rb.applied, 1);

    final row = await (b.select(b.courses)).getSingle();
    expect(row.name, '数据结构');
    expect(row.startMinutes, 840);
  });
}
