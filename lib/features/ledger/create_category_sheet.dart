import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/db/db_provider.dart';
import '../../core/icons/app_icon_catalog.dart';
import '../../core/icons/app_icon_view.dart';
import '../../core/theme/app_colors.dart';
import 'icon_picker_page.dart';

/// 创建/修改自定义标签：输入名称 + 选图标（默认猫猫头）。
///
/// [existing] 非空时为编辑模式（标题变「修改标签」，多一个删除按钮）。
Future<void> showCreateCategorySheet(
  BuildContext context,
  WidgetRef ref,
  String type, {
  CustomCategoryRow? existing,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _CreateCategorySheet(type: type, existing: existing),
  );
}

class _CreateCategorySheet extends ConsumerStatefulWidget {
  final String type;
  final CustomCategoryRow? existing;
  const _CreateCategorySheet({required this.type, this.existing});

  @override
  ConsumerState<_CreateCategorySheet> createState() =>
      _CreateCategorySheetState();
}

class _CreateCategorySheetState extends ConsumerState<_CreateCategorySheet> {
  final _nameCtrl = TextEditingController();
  late int _iconCode;

  bool get _isIncome => widget.type == 'income';

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _iconCode = widget.existing?.iconCode ?? kCatCodePoint;
    _nameCtrl.text = widget.existing?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _isEdit
                    ? '修改标签'
                    : (_isIncome ? '新建收入标签' : '新建支出标签'),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.text),
              ),
              const Spacer(),
              if (_isEdit)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colors.error),
                  tooltip: '删除标签',
                  onPressed: () async {
                    await ref
                        .read(databaseProvider)
                        .customCategoriesDao
                        .softDelete(widget.existing!.uuid);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // 图标预览（点击换图标）
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickIcon,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                    color: colors.bg,
                  ),
                  child: Center(
                    child: AppIconView(
                      codePoint: _iconCode,
                      color: colors.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _nameCtrl,
                  autofocus: true,
                  maxLength: 8,
                  style: TextStyle(color: colors.text),
                  decoration: const InputDecoration(
                    hintText: '标签名（最多 8 字）',
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('点图标框可更换图标，支持关键词搜索',
              style: TextStyle(fontSize: 12, color: colors.textMuted)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: const Text('保存'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickIcon() async {
    final code = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => const IconPickerPage()),
    );
    if (code != null && mounted) setState(() => _iconCode = code);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('先给标签起个名字吧')),
      );
      return;
    }
    final dao = ref.read(databaseProvider).customCategoriesDao;
    if (name != widget.existing?.name &&
        await dao.nameExists(name, widget.type)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('「$name」已存在')),
        );
      }
      return;
    }
    if (_isEdit) {
      await dao.updateCategory(
        widget.existing!.uuid,
        CustomCategoriesCompanion(
          name: Value(name),
          iconCode: Value(_iconCode),
        ),
      );
    } else {
      await dao.insertCategory(
        CustomCategoriesCompanion.insert(
          name: name,
          iconCode: Value(_iconCode),
          type: widget.type,
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }
}
