import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/db/database.dart';
import '../../core/db/db_provider.dart';
import '../../core/theme/app_colors.dart';
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
    _amountCtrl =
        TextEditingController(text: e == null ? '' : _fmt(e.amount));
    _noteCtrl = TextEditingController(text: e?.note);
    _occurredAt = e == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(e.occurredAt);
  }

  static String _fmt(double v) =>
      v.toStringAsFixed(v % 1 == 0 ? 0 : 2);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 收/支切换
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'expense', label: Text('支出'), icon: Icon(Icons.north_east)),
              ButtonSegment(value: 'income', label: Text('收入'), icon: Icon(Icons.south_west)),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 24),
          // 金额
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
          Divider(color: colors.border),
          const SizedBox(height: 16),
          // 类别
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in ledgerCategories)
                  _CategoryChip(
                    label: c,
                    selected: _category == c && _type == 'expense' ||
                        _category == c && _type == 'income',
                    onTap: () => setState(() => _category = c),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 备注
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
          // 时间
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
          // 保存
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(_isEdit ? '保存修改' : '保存', style: const TextStyle(fontSize: 16)),
          ),
        ],
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入正确的金额')),
      );
      return;
    }
    final db = ref.read(databaseProvider);
    final companion = AccountsCompanion.insert(
      amount: amount,
      type: _type,
      category: _type == 'income' ? '其他' : _category,
      occurredAt: Value(_occurredAt.millisecondsSinceEpoch),
      note: Value(_noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim()),
    );

    if (_isEdit) {
      await db.accountsDao.updateEntry(widget.existing!.id, companion);
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
            child: Text('取消',
                style: TextStyle(color: colors.textMuted)),
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
        .softDelete(widget.existing!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
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
          categoryIcon(label, colors, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selectedColor: colors.activeBg,
      checkmarkColor: colors.primary,
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
