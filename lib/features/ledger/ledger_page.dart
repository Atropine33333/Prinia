import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/db/daos/accounts_dao.dart';
import '../../core/icons/app_icon_view.dart';
import '../../core/theme/app_colors.dart';
import 'ledger_categories_provider.dart';
import 'ledger_edit_page.dart';
import 'ledger_providers.dart';
import 'widgets/category_icons.dart';
import 'widgets/charts.dart';

/// 记账本页：列表 / 统计 双视图 + 月份切换。
class LedgerPage extends ConsumerStatefulWidget {
  const LedgerPage({super.key});

  @override
  ConsumerState<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends ConsumerState<LedgerPage> {
  bool _showStats = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final month = ref.watch(selectedMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('记账本'),
        actions: [
          IconButton(
            tooltip: _showStats ? '查看列表' : '查看统计',
            onPressed: () => setState(() => _showStats = !_showStats),
            icon: Icon(_showStats
                ? Icons.receipt_long_outlined
                : Icons.insights_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openEditor,
        backgroundColor: colors.primary,
        foregroundColor: colors.bg,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _MonthSelector(month: month),
          Divider(height: 1, color: colors.border),
          Expanded(
            child: _showStats ? const _StatsView() : const _ListView(),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditor([AccountRow? existing]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LedgerEditPage(existing: existing),
      ),
    );
  }
}

// ── 月份选择器 ──────────────────────────────────────────────────

class _MonthSelector extends ConsumerWidget {
  final DateTime month;
  const _MonthSelector({required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final label = DateFormat('yyyy年M月').format(month);
    final isCurrent = month.year == DateTime.now().year &&
        month.month == DateTime.now().month;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: colors.textMuted,
            onPressed: () => ref.read(selectedMonthProvider.notifier).state =
                DateTime(month.year, month.month - 1),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: colors.textMuted,
            onPressed: isCurrent
                ? null
                : () => ref.read(selectedMonthProvider.notifier).state =
                    DateTime(month.year, month.month + 1),
          ),
          if (!isCurrent)
            TextButton(
              onPressed: () {
                final n = DateTime.now();
                ref.read(selectedMonthProvider.notifier).state =
                    DateTime(n.year, n.month);
              },
              child: const Text('回到本月'),
            ),
        ],
      ),
    );
  }
}

// ── 列表视图 ────────────────────────────────────────────────────

class _ListView extends ConsumerWidget {
  const _ListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsStreamProvider);

    return accounts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败：$e')),
      data: (list) {
        if (list.isEmpty) return const _EmptyHint();
        return LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 600;
            final tiles = [
              for (final a in list) _AccountTile(row: a),
            ];
            if (!wide) {
              return ListView(children: tiles);
            }
            // 平板双列网格
            return GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 3.4,
              shrinkWrap: false,
              children: tiles,
            );
          },
        );
      },
    );
  }
}

class _AccountTile extends ConsumerWidget {
  final AccountRow row;
  const _AccountTile({required this.row});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isIncome = row.type == 'income';
    final amountColor = isIncome ? colors.primary : colors.text;
    final sign = isIncome ? '+' : '-';
    // 自定义标签优先按码点渲染
    final customs = ref.watch(customCategoriesProvider(row.type)).value;
    final custom = customs?.where((c) => c.name == row.category).firstOrNull;
    final leading = custom != null
        ? AppIconView(
            codePoint: custom.iconCode, color: colors.primary, size: 22)
        : categoryIcon(row.category, colors);

    return ListTile(
      leading: leading,
      title: Text(
        row.note?.isNotEmpty == true ? row.note! : row.category,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: colors.text, fontSize: 15),
      ),
      subtitle: Text(
        DateFormat('MM-dd HH:mm').format(
          DateTime.fromMillisecondsSinceEpoch(row.occurredAt),
        ),
        style: TextStyle(color: colors.textMuted, fontSize: 12),
      ),
      trailing: Text(
        '$sign¥${row.amount.toStringAsFixed(row.amount % 1 == 0 ? 0 : 2)}',
        style: TextStyle(
          color: amountColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => LedgerEditPage(existing: row)),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 56, color: colors.borderStrong),
          const SizedBox(height: 12),
          Text('本月还没有记录', style: TextStyle(color: colors.textMuted)),
          const SizedBox(height: 4),
          Text('点右下角 + 记一笔吧', style: TextStyle(color: colors.textMuted)),
        ],
      ),
    );
  }
}

// ── 统计视图 ────────────────────────────────────────────────────

class _StatsView extends ConsumerWidget {
  const _StatsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final summary = ref.watch(summaryStreamProvider);
    final daily = ref.watch(dailyExpenseProvider);
    final categories = ref.watch(categoryTotalsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 收支结余卡片
        summary.when(
          loading: () => const SizedBox(),
          error: (e, _) => Text('汇总失败：$e'),
          data: (s) => Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Expanded(child: _StatCol('支出', s.expense)),
                  VerticalDivider(color: colors.border),
                  Expanded(child: _StatCol('收入', s.income)),
                  VerticalDivider(color: colors.border),
                  Expanded(
                    child: _StatCol('结余', s.balance,
                        color: s.balance >= 0 ? colors.primary : colors.error),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 每日支出柱状图
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('每日支出',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.text)),
                const SizedBox(height: 8),
                daily.when(
                  loading: () => const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator())),
                  error: (e, _) => Text('$e'),
                  data: (m) => ExpenseBarChart(data: m),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 分类占比饼图
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('分类占比',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.text)),
                const SizedBox(height: 8),
                categories.maybeWhen(
                  loading: () => const SizedBox(height: 160),
                  orElse: () => categories.value == null ||
                          categories.value!.isEmpty
                      ? SizedBox(
                          height: 80,
                          child: Center(
                            child: Text('暂无支出数据',
                                style: TextStyle(color: colors.textMuted)),
                          ),
                        )
                      : _PieWithLegend(totals: categories.value!),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final double value;
  final Color? color;
  const _StatCol(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: colors.textMuted)),
        const SizedBox(height: 4),
        Text(
          '¥${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)}',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: color ?? colors.text,
          ),
        ),
      ],
    );
  }
}

class _PieWithLegend extends StatelessWidget {
  final List<(String, double)> totals;
  const _PieWithLegend({required this.totals});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final palette = piePalette(colors);
    final total = totals.fold<double>(0, (s, e) => s + e.$2);

    return Row(
      children: [
        CategoryPieChart(totals: totals),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              for (var i = 0; i < totals.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: palette[i % palette.length],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(totals[i].$1,
                          style: TextStyle(
                              fontSize: 13, color: colors.text)),
                      const Spacer(),
                      Text(
                        '${(totals[i].$2 / total * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontSize: 13, color: colors.textMuted),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
