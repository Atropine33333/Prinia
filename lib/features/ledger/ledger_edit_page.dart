import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/db/database.dart';
import '../../core/db/db_provider.dart';
import '../../core/icons/app_icon_view.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/responsive.dart';
import 'create_category_sheet.dart';
import 'ledger_categories_provider.dart';
import 'ledger_providers.dart';
import 'widgets/category_icons.dart';

/// 添加/编辑一笔账。[existing] 为空表示新增。
class LedgerEditPage extends ConsumerStatefulWidget {
  final AccountRow? existing;
  const LedgerEditPage({super.key, this.existing});

  @override
  ConsumerState<LedgerEditPage> createState() => _LedgerEditPageState();
}

class _LedgerEditPageState extends ConsumerState<LedgerEditPage> {
  late String _type;
  late String _category;
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  late DateTime _occurredAt;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? 'expense';
    _category = e?.category ?? ledgerCategories.first;
    _amountCtrl = TextEditingController(text: e == null ? '' : _fmt(e.amount));
    _noteCtrl = TextEditingController(text: e?.note);
    _occurredAt = e == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(e.occurredAt);
  }

  static String _fmt(double v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 2);

  /// 当前类型下的可选标签：默认 + 自定义。
  List<_CategoryOption> _options(List<CustomCategoryRow> customs) {
    final defaults = _type == 'income'
        ? [
            for (final name in incomeDefaultCategories)
              _CategoryOption(
                name: name,
                codePoint: incomeDefaultIcons[name]!.codePoint,
                builtin: incomeDefaultIcons[name],
              ),
          ]
        : [
            for (final name in ledgerCategories)
              _CategoryOption(
                name: name,
                codePoint: expenseCategoryMeta[name]!.codePoint,
                builtin: expenseCategoryMeta[name],
              ),
          ];
    return [
      ...defaults,
      for (final c in customs)
        _CategoryOption(name: c.name, codePoint: c.iconCode, isCustom: true),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final customs = ref
        .watch(customCategoriesProvider(_type))
        .value;
    final options = _options(customs ?? const []);
    // 确保当前选中项在选项里（切类型时自动纠正）
    if (!options.any((o) => o.name == _category)) {
      _category = options.first.name;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? '编辑记录' : '记一笔'),
        actions: [
          if (_isEdit)
            IconButton(
              icon: Icon(Icons.delete_outline, color: colors.error),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: ResponsiveFormBox(
        child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                  value: 'expense', label: Text('支出'), icon: Icon(Icons.north_east)),
              ButtonSegment(
                  value: 'income', label: Text('收入'), icon: Icon(Icons.south_west)),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 24),
          // 金额（无下划线）
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('¥',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: colors.textMuted)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  autofocus: !_isEdit,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: colors.text),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle:
                        TextStyle(color: colors.borderStrong, fontSize: 30),
                    border: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 标签（默认 + 自定义 + 新建）
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final o in options)
                  GestureDetector(
                    onLongPress: o.isCustom
                        ? () => showCreateCategorySheet(
                              context,
                              ref,
                              _type,
                              existing: customs
                                  ?.where((c) => c.name == o.name)
                                  .firstOrNull,
                            )
                        : null,
                    child: _CategoryChip(
                      option: o,
                      selected: _category == o.name,
                      onTap: () => setState(() => _category = o.name),
                    ),
                  ),
                _AddCategoryChip(
                  onTap: () => showCreateCategorySheet(context, ref, _type),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _noteCtrl,
            maxLength: 50,
            style: TextStyle(color: colors.text),
            decoration: InputDecoration(
              hintText: '备注（可选）',
              prefixIcon: Icon(Icons.edit_note, color: colors.textMuted),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.schedule, color: colors.textMuted),
            title: Text(
              DateFormat('yyyy-MM-dd HH:mm').format(_occurredAt),
              style: TextStyle(color: colors.text),
            ),
            trailing: Icon(Icons.chevron_right, color: colors.textMuted),
            onTap: _pickDateTime,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(_isEdit ? '保存修改' : '保存',
                style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (!mounted) return;
    setState(() {
      _occurredAt = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _occurredAt.hour,
        time?.minute ?? _occurredAt.minute,
      );
    });
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入正确的金额')),
      );
      return;
    }
    final db = ref.read(databaseProvider);
    final companion = AccountsCompanion.insert(
      amount: amount,
      type: _type,
      category: _category,
      occurredAt: Value(_occurredAt.millisecondsSinceEpoch),
      note: Value(_noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim()),
    );

    if (_isEdit) {
      await db.accountsDao.updateEntry(widget.existing!.uuid, companion);
    } else {
      await db.accountsDao.insertEntry(companion);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除这条记录？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('取消', style: TextStyle(color: colors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('删除', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await ref
        .read(databaseProvider)
        .accountsDao
        .softDelete(widget.existing!.uuid);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }
}

class _CategoryOption {
  final String name;
  final int codePoint;

  /// 内置标签的图标（直接渲染，避免码点反查失败）。
  final IconData? builtin;
  final bool isCustom;
  const _CategoryOption({
    required this.name,
    required this.codePoint,
    this.builtin,
    this.isCustom = false,
  });
}

class _CategoryChip extends StatelessWidget {
  final _CategoryOption option;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return FilterChip(
      selected: selected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (option.builtin != null)
            Icon(option.builtin,
                size: 16,
                color: selected ? colors.primary : colors.textMuted)
          else
            AppIconView(
              codePoint: option.codePoint,
              color: selected ? colors.primary : colors.textMuted,
              size: 16,
            ),
          const SizedBox(width: 6),
          Text(option.name),
        ],
      ),
      selectedColor: colors.activeBg,
      side: BorderSide(color: selected ? colors.primary : colors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      labelStyle: TextStyle(
        color: selected ? colors.primary : colors.text,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      showCheckmark: false,
      onSelected: (_) => onTap(),
    );
  }
}

/// 「+ 新建标签」入口。
class _AddCategoryChip extends StatelessWidget {
  final VoidCallback onTap;
  const _AddCategoryChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(Icons.add, size: 16, color: colors.primary),
      label: Text('新建',
          style: TextStyle(color: colors.primary)),
      side: BorderSide(
          color: colors.primary.withValues(alpha: 0.4),
          strokeAlign: BorderSide.strokeAlignInside),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: colors.bg,
    );
  }
}
