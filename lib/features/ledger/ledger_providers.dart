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

/// 统计页饼图当前查看的日期（默认今天，限当月）。
final selectedStatsDayProvider = StateProvider<int>((ref) {
  final n = ref.watch(selectedMonthProvider);
  final now = DateTime.now();
  return (n.year == now.year && n.month == now.month) ? now.day : 1;
});

/// 指定日期的分类占比流（饼图），在 Dart 侧聚合。
final categoryTotalsProvider =
    StreamProvider<List<(String, double)>>((ref) {
  final accounts = ref.watch(accountsStreamProvider).value ?? const [];
  final month = ref.watch(selectedMonthProvider);
  final day = ref.watch(selectedStatsDayProvider);
  final start =
      DateTime(month.year, month.month, day).millisecondsSinceEpoch;
  final end = DateTime(month.year, month.month, day + 1).millisecondsSinceEpoch;
  final map = <String, double>{};
  for (final a in accounts.where((a) =>
      a.type == 'expense' &&
      a.occurredAt >= start &&
      a.occurredAt < end)) {
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
