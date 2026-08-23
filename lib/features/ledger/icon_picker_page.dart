import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/icons/app_icon_catalog.dart';
import '../../core/theme/app_colors.dart';

/// 图标选择页：搜索 + 网格，首位固定猫猫头。
///
/// 返回选中的码点（[kCatCodePoint] 表示猫猫）。
class IconPickerPage extends StatefulWidget {
  const IconPickerPage({super.key});

  @override
  State<IconPickerPage> createState() => _IconPickerPageState();
}

class _IconPickerPageState extends State<IconPickerPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final results = _query.isEmpty
        ? appIconCatalog
        : [
            // 命中的条目
            for (final e in appIconCatalog)
              if (e.keywords.toLowerCase().contains(_query.toLowerCase()))
                e,
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('选择图标'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: '输入关键词搜图标，如：咖啡 / 车 / 猫',
                prefixIcon: Icon(Icons.search, color: colors.textMuted),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 88,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: results.length + 1,
              itemBuilder: (context, i) {
                // 首位固定猫猫头
                if (i == 0) {
                  return _IconCell(
                    label: '猫猫',
                    selected: false,
                    onTap: () => Navigator.of(context).pop(kCatCodePoint),
                    child: _CatTile(colors: colors),
                  );
                }
                final e = results[i - 1];
                return _IconCell(
                  label: e.keywords.split(' ').first,
                  selected: false,
                  onTap: () => Navigator.of(context).pop(e.data.codePoint),
                  child: Icon(e.data, size: 30, color: colors.text),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CatTile extends StatelessWidget {
  final AppColors colors;
  const _CatTile({required this.colors});

  @override
  Widget build(BuildContext context) {
    // 延迟导入避免循环依赖：直接内联 SVG 渲染
    return SvgPicture.asset(
      'assets/icons/cat.svg',
      width: 30,
      height: 30,
      colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
    );
  }
}

class _IconCell extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  const _IconCell({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colors.primary : colors.border,
          ),
          color: selected ? colors.activeBg : colors.surface,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            child,
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
