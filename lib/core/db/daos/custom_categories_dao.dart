import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

export '../database.dart' show CustomCategoryRow;

part 'custom_categories_dao.g.dart';

/// 自定义分类数据访问。
@DriftAccessor(tables: [CustomCategories])
class CustomCategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CustomCategoriesDaoMixin {
  CustomCategoriesDao(super.db);

  /// 某类型的自定义标签流。
  Stream<List<CustomCategoryRow>> watchByType(String type) {
    return (select(customCategories)
          ..where((t) => t.type.equals(type))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(u) => OrderingTerm.asc(u.id)]))
        .watch();
  }

  Future<void> insertCategory(CustomCategoriesCompanion entry) =>
      into(customCategories).insert(entry);

  Future<bool> nameExists(String name, String type) async {
    final q = selectOnly(customCategories)
      ..addColumns([customCategories.id])
      ..where(customCategories.name.equals(name))
      ..where(customCategories.type.equals(type))
      ..where(customCategories.isDeleted.equals(false));
    return await q.getSingleOrNull() != null;
  }

  Future<void> softDelete(int id) {
    return (update(customCategories)..where((t) => t.id.equals(id))).write(
      CustomCategoriesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
