import 'package:flutter/material.dart';

import '../../../core/icons/app_icon_view.dart';
import '../../../core/theme/app_colors.dart';

/// 支出默认类别 → Material 图标。
const expenseCategoryMeta = <String, IconData>{
  '餐饮': Icons.restaurant,
  '购物': Icons.shopping_bag_outlined,
  '学习': Icons.school_outlined,
  '交通': Icons.commute,
  '娱乐': Icons.sports_esports_outlined,
  '医疗': Icons.medication_outlined,
  '其他': Icons.more_horiz,
};

/// 类别图标渲染：内置表 → 猫猫头兜底。
///
/// 自定义标签请使用 [categoryIconByCode]（存了码点）。
Widget categoryIcon(String category, AppColors colors, {double size = 22}) {
  final icon = expenseCategoryMeta[category];
  if (icon != null) return Icon(icon, size: size, color: colors.primary);
  // 未知名称（含自定义）→ 猫猫头
  return CatIconView(size: size, color: colors.primary);
}

/// 按码点渲染（自定义标签）。
Widget categoryIconByCode(int codePoint, AppColors colors,
        {double size = 22}) =>
    AppIconView(codePoint: codePoint, color: colors.primary, size: size);

/// 类别在饼图中的固定色序（低饱和，取自主题派生）。
List<Color> piePalette(AppColors c) => [
      c.primary,
      c.highlight,
      c.primaryHover,
      c.activeBg,
      c.borderStrong,
      c.error.withValues(alpha: 0.75),
      c.textMuted.withValues(alpha: 0.6),
    ];
