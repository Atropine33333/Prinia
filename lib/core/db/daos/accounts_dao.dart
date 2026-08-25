import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

export '../database.dart' show AccountRow;

part 'accounts_dao.g.dart';



/// 记账数据访问。
@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<AppDatabase> with _$AccountsDaoMixin {
  AccountsDao(super.db);

  /// 某月账目流（按时间倒序），软删除记录不出现。
  Stream<List<AccountRow>> watchMonth(int year, int month) {
    final start = DateTime(year, month).millisecondsSinceEpoch;
    final end = DateTime(year, month + 1).millisecondsSinceEpoch;
    return (select(accounts)
          ..where((t) =>
              t.occurredAt.isBiggerOrEqualValue(start) & t.occurredAt.isSmallerThanValue(end))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(u) => OrderingTerm.desc(u.occurredAt)]))
        .watch();
  }

  Future<void> insertEntry(AccountsCompanion entry) =>
      into(accounts).insert(entry);

  /// 更新并刷新 updated_at（LWW 冲突解决依赖）。
  Future<void> updateEntry(String uuid, AccountsCompanion entry) {
    return (update(accounts)..where((t) => t.uuid.equals(uuid))).write(
      entry.copyWith(updatedAt: Value(DateTime.now().millisecondsSinceEpoch)),
    );
  }

  Future<void> softDelete(String uuid) {
    return (update(accounts)..where((t) => t.uuid.equals(uuid))).write(
      AccountsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// 月度汇总：总收入、总支出。
  Stream<MonthlySummary> watchMonthlySummary(int year, int month) {
    final start = DateTime(year, month).millisecondsSinceEpoch;
    final end = DateTime(year, month + 1).millisecondsSinceEpoch;
    final query = selectOnly(accounts)
      ..addColumns([accounts.type, accounts.amount.sum()])
      ..where(accounts.occurredAt.isBiggerOrEqualValue(start) & accounts.occurredAt.isSmallerThanValue(end))
      ..where(accounts.isDeleted.equals(false))
      ..groupBy([accounts.type]);
    return query.watch().map((rows) {
      double income = 0, expense = 0;
      for (final row in rows) {
        final v = row.read(accounts.amount.sum()) ?? 0;
        if (row.read(accounts.type) == 'income') {
          income += v;
        } else {
          expense += v;
        }
      }
      return MonthlySummary(income: income, expense: expense);
    });
  }

  /// 每日支出（柱状图用）。按本地时区的「几号」分桶，在 Dart 侧聚合。
  Stream<Map<int, double>> watchDailyExpense(int year, int month) {
    final start = DateTime(year, month).millisecondsSinceEpoch;
    final end = DateTime(year, month + 1).millisecondsSinceEpoch;
    final daysInMonth =
        DateTime(year, month + 1).difference(DateTime(year, month)).inDays;
    final query = select(accounts)
      ..where((t) =>
          t.occurredAt.isBiggerOrEqualValue(start) & t.occurredAt.isSmallerThanValue(end))
      ..where((t) => t.isDeleted.equals(false))
      ..where((t) => t.type.equals('expense'));
    return query.watch().map((rows) {
      final map = <int, double>{};
      for (final r in rows) {
        final day = DateTime.fromMillisecondsSinceEpoch(r.occurredAt).day;
        map[day] = (map[day] ?? 0) + r.amount;
      }
      for (var d = 1; d <= daysInMonth; d++) {
        map.putIfAbsent(d, () => 0);
      }
      return map;
    });
  }
}

class MonthlySummary {
  final double income;
  final double expense;
  const MonthlySummary({required this.income, required this.expense});

  double get balance => income - expense;
}
