import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';

import '../../core/db/db_provider.dart';
import '../../core/db/daos/custom_categories_dao.dart';

/// 按类型提供自定义标签流（'expense' / 'income'）。
final customCategoriesProvider = StreamProvider.family
    .autoDispose<List<CustomCategoryRow>, String>((ref, type) {
  final db = ref.watch(databaseProvider);
  return db.customCategoriesDao.watchByType(type);
});

/// 收入默认标签（与支出分开）。
const incomeDefaultCategories = ['生活费', '工资', '杂项收入'];

/// 收入默认标签图标。
const incomeDefaultIcons = <String, IconData>{
  '生活费': Icons.savings,
  '工资': Icons.work,
  '杂项收入': Icons.paid,
};
