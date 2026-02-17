// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_dao.dart';

// ignore_for_file: type=lint
mixin _$ProductDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProductCategoryTableTable get productCategoryTable =>
      attachedDatabase.productCategoryTable;
  $ProductTableTable get productTable => attachedDatabase.productTable;
  ProductDaoManager get managers => ProductDaoManager(this);
}

class ProductDaoManager {
  final _$ProductDaoMixin _db;
  ProductDaoManager(this._db);
  $$ProductCategoryTableTableTableManager get productCategoryTable =>
      $$ProductCategoryTableTableTableManager(
        _db.attachedDatabase,
        _db.productCategoryTable,
      );
  $$ProductTableTableTableManager get productTable =>
      $$ProductTableTableTableManager(_db.attachedDatabase, _db.productTable);
}
