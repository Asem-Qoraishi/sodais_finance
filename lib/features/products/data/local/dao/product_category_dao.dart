import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/features/app/data/app_database.dart';
import 'package:sodais_finance/features/products/data/local/tables/product_category_table.dart';
import 'package:sodais_finance/features/products/data/local/tables/product_table.dart';
import 'package:sodais_finance/features/products/domain/product_category.dart';

part 'product_category_dao.g.dart';

@DriftAccessor(tables: [ProductCategoryTable, ProductTable])
class ProductCategoryDao extends DatabaseAccessor<AppDatabase>
    with _$ProductCategoryDaoMixin {
  ProductCategoryDao(super.db);

  ProductCategory _mapCategoryRow(ProductCategoryTableData row) {
    return ProductCategory(
      id: row.id.toString(),
      name: row.name,
      icon: row.icon,
      colorHex: row.colorHex,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Stream<List<ProductCategory>> watchCategories({String query = ''}) {
    final normalizedQuery = query.trim();
    final itemCount = productTable.id.count();

    final queryBuilder = selectOnly(productCategoryTable)
      ..addColumns([
        productCategoryTable.id,
        productCategoryTable.name,
        productCategoryTable.icon,
        productCategoryTable.colorHex,
        productCategoryTable.createdAt,
        productCategoryTable.updatedAt,
        itemCount,
      ])
      ..join([
        leftOuterJoin(
          productTable,
          productTable.categoryId.equalsExp(productCategoryTable.id),
        ),
      ]);

    if (normalizedQuery.isNotEmpty) {
      final pattern = '%$normalizedQuery%';
      queryBuilder.where(productCategoryTable.name.like(pattern));
    }

    queryBuilder.groupBy([
      productCategoryTable.id,
      productCategoryTable.name,
      productCategoryTable.icon,
      productCategoryTable.colorHex,
      productCategoryTable.createdAt,
      productCategoryTable.updatedAt,
    ]);
    queryBuilder.orderBy([OrderingTerm(expression: productCategoryTable.name)]);

    return queryBuilder.watch().map((rows) {
      return rows
          .map((row) {
            return ProductCategory(
              id: row.read(productCategoryTable.id)!.toString(),
              name: row.read(productCategoryTable.name)!,
              icon: row.read(productCategoryTable.icon)!,
              colorHex: row.read(productCategoryTable.colorHex)!,
              itemCount: row.read(itemCount) ?? 0,
              createdAt: row.read(productCategoryTable.createdAt)!,
              updatedAt: row.read(productCategoryTable.updatedAt)!,
            );
          })
          .toList(growable: false);
    });
  }

  Future<List<ProductCategory>> getAllCategories() {
    return (select(productCategoryTable)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get()
        .then((rows) => rows.map(_mapCategoryRow).toList(growable: false));
  }

  Future<int> insertCategory({
    required String name,
    required String icon,
    required String colorHex,
  }) {
    return into(productCategoryTable).insert(
      ProductCategoryTableCompanion.insert(
        name: name,
        icon: Value(icon),
        colorHex: Value(colorHex),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<bool> updateCategory(ProductCategory category) {
    final intId = int.tryParse(category.id) ?? -1;

    return update(productCategoryTable).replace(
      ProductCategoryTableCompanion(
        id: Value(intId),
        name: Value(category.name),
        icon: Value(category.icon),
        colorHex: Value(category.colorHex),
        createdAt: Value(category.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteCategory(String id) {
    final intId = int.tryParse(id) ?? -1;
    return (delete(
      productCategoryTable,
    )..where((t) => t.id.equals(intId))).go();
  }
}

final productCategoryDaoProvider = Provider(
  (ref) => ProductCategoryDao(ref.watch(appDatabaseProvider)),
);
