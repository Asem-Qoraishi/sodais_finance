// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_category_dao.dart';

// ignore_for_file: type=lint
mixin _$ProductCategoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProductCategoryTableTable get productCategoryTable =>
      attachedDatabase.productCategoryTable;
  $ProductTableTable get productTable => attachedDatabase.productTable;
  ProductCategoryDaoManager get managers => ProductCategoryDaoManager(this);
}

class ProductCategoryDaoManager {
  final _$ProductCategoryDaoMixin _db;
  ProductCategoryDaoManager(this._db);
  $$ProductCategoryTableTableTableManager get productCategoryTable =>
      $$ProductCategoryTableTableTableManager(
        _db.attachedDatabase,
        _db.productCategoryTable,
      );
  $$ProductTableTableTableManager get productTable =>
      $$ProductTableTableTableManager(_db.attachedDatabase, _db.productTable);
}
