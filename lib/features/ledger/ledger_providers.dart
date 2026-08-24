import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/db_provider.dart';
import '../../core/db/daos/accounts_dao.dart';

/// 当前查看的月份（每月 1 日代表整月）。
final selectedMonthProvider =
    StateProvider<DateTime>((ref) {
      final n = DateTime.now();
      return DateTime(n.year, n.month);
    });

/// 当月账目流。
final accountsStreamProvider = StreamProvider<List<AccountRow>>((ref) {
  final db = ref.watch(databaseProvider);
  final month = ref.watch(selectedMonthProvider);
  return db.accountsDao.watchMonth(month.year, month.month);
});

/// 当月收支汇总流。
final summaryStreamProvider = StreamProvider<MonthlySummary>((ref) {
  final db = ref.watch(databaseProvider);
  final month = ref.watch(selectedMonthProvider);
  return db.accountsDao.watchMonthlySummary(month.year, month.month);
});

/// 当月每日支出流（柱状图）。
final dailyExpenseProvider = StreamProvider<Map<int, double>>((ref) {
  final db = ref.watch(databaseProvider);
  final month = ref.watch(selectedMonthProvider);
  return db.accountsDao.watchDailyExpense(month.year, month.month);
});

/// 饼图查看的日期：null = 整月；非空 = 柱状图选中的那天。
final selectedStatsDayProvider = StateProvider<int?>((ref) => null);

/// 分类占比流：跟随选中日（null 为整月聚合）。
final categoryTotalsProvider =
    StreamProvider<List<(String, double)>>((ref) {
  final accounts = ref.watch(accountsStreamProvider).value ?? const [];
  final month = ref.watch(selectedMonthProvider);
  final day = ref.watch(selectedStatsDayProvider);
  Iterable<AccountRow> scope = accounts.where((a) => a.type == 'expense');
  if (day != null) {
    final start =
        DateTime(month.year, month.month, day).millisecondsSinceEpoch;
    final end =
        DateTime(month.year, month.month, day + 1).millisecondsSinceEpoch;
    scope = scope.where((a) => a.occurredAt >= start && a.occurredAt < end);
  }
  final map = <String, double>{};
  for (final a in scope) {
    map[a.category] = (map[a.category] ?? 0) + a.amount;
  }
  final list = map.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return Stream.value(list.map((e) => (e.key, e.value)).toList());
});

/// 账目类别定义（顺序即展示顺序）。
const ledgerCategories = [
  '餐饮',
  '购物',
  '学习',
  '交通',
  '娱乐',
  '医疗',
  '其他',
];
