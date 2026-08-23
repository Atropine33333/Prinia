// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_categories_dao.dart';

// ignore_for_file: type=lint
mixin _$CustomCategoriesDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomCategoriesTable get customCategories =>
      attachedDatabase.customCategories;
  CustomCategoriesDaoManager get managers => CustomCategoriesDaoManager(this);
}

class CustomCategoriesDaoManager {
  final _$CustomCategoriesDaoMixin _db;
  CustomCategoriesDaoManager(this._db);
  $$CustomCategoriesTableTableManager get customCategories =>
      $$CustomCategoriesTableTableManager(
        _db.attachedDatabase,
        _db.customCategories,
      );
}
