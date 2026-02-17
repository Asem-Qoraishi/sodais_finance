import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/features/app/data/app_database.dart';
import 'package:sodais_finance/features/products/data/local/tables/product_category_table.dart';
import 'package:sodais_finance/features/products/data/local/tables/product_table.dart';
import 'package:sodais_finance/features/products/domain/product.dart';
import 'package:sodais_finance/features/products/domain/products_query_options.dart';

part 'product_dao.g.dart';

@DriftAccessor(tables: [ProductTable, ProductCategoryTable])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(super.db);

  Product _mapJoinedProduct(TypedResult row) {
    final productRow = row.readTable(productTable);
    final categoryRow = row.readTableOrNull(productCategoryTable);

    return Product(
      id: productRow.id.toString(),
      name: productRow.name,
      description: productRow.description,
      imagePath: productRow.imagePath,
      sku: productRow.sku,
      categoryId: productRow.categoryId?.toString(),
      categoryName: categoryRow?.name,
      purchasePrice: productRow.purchasePrice,
      sellingPrice: productRow.sellingPrice,
      taxRate: productRow.taxRate,
      stock: productRow.stock,
      reorderLevel: productRow.reorderLevel,
      location: productRow.location,
      createdAt: productRow.createdAt,
      updatedAt: productRow.updatedAt,
    );
  }

  Stream<List<Product>> watchProducts({
    required String query,
    required ProductsOrderBy orderBy,
    int page = 0,
    int pageSize = productsPageSize,
  }) {
    final normalizedQuery = query.trim();
    final resolvedPage = page < 0 ? 0 : page;
    final resolvedPageSize = pageSize <= 0 ? productsPageSize : pageSize;
    final offset = resolvedPage * resolvedPageSize;

    final queryBuilder = select(productTable).join([
      leftOuterJoin(
        productCategoryTable,
        productCategoryTable.id.equalsExp(productTable.categoryId),
      ),
    ]);

    if (normalizedQuery.isNotEmpty) {
      final pattern = '%$normalizedQuery%';
      final description = coalesce<String>([
        productTable.description,
        const Constant(''),
      ]);
      final sku = coalesce<String>([productTable.sku, const Constant('')]);
      final location = coalesce<String>([
        productTable.location,
        const Constant(''),
      ]);
      final categoryName = coalesce<String>([
        productCategoryTable.name,
        const Constant(''),
      ]);

      queryBuilder.where(
        productTable.name.like(pattern) |
            description.like(pattern) |
            sku.like(pattern) |
            location.like(pattern) |
            categoryName.like(pattern),
      );
    }

    queryBuilder.orderBy(_orderingTerms(orderBy));
    queryBuilder.limit(resolvedPageSize, offset: offset);

    return queryBuilder.watch().map(
      (rows) => rows.map(_mapJoinedProduct).toList(growable: false),
    );
  }

  List<OrderingTerm> _orderingTerms(ProductsOrderBy orderBy) {
    switch (orderBy) {
      case ProductsOrderBy.alphabetAsc:
        return [OrderingTerm(expression: productTable.name)];
      case ProductsOrderBy.alphabetDesc:
        return [OrderingTerm.desc(productTable.name)];
      case ProductsOrderBy.highestStock:
        return [
          OrderingTerm.desc(productTable.stock),
          OrderingTerm.desc(productTable.updatedAt),
        ];
      case ProductsOrderBy.oldest:
        return [OrderingTerm(expression: productTable.createdAt)];
      case ProductsOrderBy.newest:
        return [OrderingTerm.desc(productTable.createdAt)];
    }
  }

  Stream<Product?> watchProductById(String id) {
    final intId = int.tryParse(id) ?? -1;
    final query = select(productTable).join([
      leftOuterJoin(
        productCategoryTable,
        productCategoryTable.id.equalsExp(productTable.categoryId),
      ),
    ])..where(productTable.id.equals(intId));

    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapJoinedProduct(row),
    );
  }

  Future<int> insertProduct(Product product) {
    final categoryId = int.tryParse(product.categoryId ?? '');

    return into(productTable).insert(
      ProductTableCompanion.insert(
        name: product.name,
        description: Value(product.description),
        imagePath: Value(product.imagePath),
        sku: Value(product.sku),
        categoryId: Value(categoryId),
        purchasePrice: Value(product.purchasePrice),
        sellingPrice: Value(product.sellingPrice),
        taxRate: Value(product.taxRate),
        stock: Value(product.stock),
        reorderLevel: Value(product.reorderLevel),
        location: Value(product.location),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<bool> updateProduct(Product product) {
    final intId = int.tryParse(product.id) ?? -1;
    final categoryId = int.tryParse(product.categoryId ?? '');

    return update(productTable).replace(
      ProductTableCompanion(
        id: Value(intId),
        name: Value(product.name),
        description: Value(product.description),
        imagePath: Value(product.imagePath),
        sku: Value(product.sku),
        categoryId: Value(categoryId),
        purchasePrice: Value(product.purchasePrice),
        sellingPrice: Value(product.sellingPrice),
        taxRate: Value(product.taxRate),
        stock: Value(product.stock),
        reorderLevel: Value(product.reorderLevel),
        location: Value(product.location),
        createdAt: Value(product.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteProduct(String id) {
    final intId = int.tryParse(id) ?? -1;
    return (delete(productTable)..where((t) => t.id.equals(intId))).go();
  }
}

final productDaoProvider = Provider(
  (ref) => ProductDao(ref.watch(appDatabaseProvider)),
);
