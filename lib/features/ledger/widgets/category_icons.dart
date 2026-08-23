import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// 类别 → 图标映射（全部矢量，颜色随主题）。
const categoryMeta = <String, IconData>{
  '餐饮': Icons.restaurant,
  '购物': Icons.shopping_bag_outlined,
  '学习': Icons.school_outlined,
  '交通': Icons.commute,
  '娱乐': Icons.sports_esports_outlined,
  '医疗': Icons.medication_outlined,
  '其他': Icons.more_horiz,
};

Icon categoryIcon(String category, AppColors colors, {double size = 22}) {
  final icon = categoryMeta[category] ?? Icons.more_horiz;
  return Icon(icon, size: size, color: colors.primary);
}

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
