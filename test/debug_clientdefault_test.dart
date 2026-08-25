import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_note/core/db/database.dart';
import 'package:octo_note/core/sync/device_identity.dart';

void main() {
  test('clientDefault 动态求值', () async {
    DeviceIdentity.overrideForTest('dev-a');
    final db = AppDatabase(NativeDatabase.memory());
    await db.into(db.accounts).insert(AccountsCompanion.insert(
          uuid: const Value('x'),
          amount: 1,
          type: 'expense',
          category: '餐饮',
        ));
    final row = await db.select(db.accounts).getSingle();
    print('deviceId = ${row.deviceId}');
    expect(row.deviceId, 'dev-a');
    await db.close();
  });
}
