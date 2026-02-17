import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/features/products/data/local/dao/product_dao.dart';
import 'package:sodais_finance/features/products/domain/product.dart';
import 'package:sodais_finance/features/products/domain/product_repository.dart';
import 'package:sodais_finance/features/products/domain/products_query_options.dart';

final productRepositoryProvider = Provider(
  (ref) => ProductRepositoryImpl(ref.watch(productDaoProvider)),
);

class ProductRepositoryImpl implements ProductRepository {
  final ProductDao _productDao;
  ProductRepositoryImpl(this._productDao);

  @override
  Stream<List<Product>> watchProducts({
    required String query,
    required ProductsOrderBy orderBy,
    int page = 0,
    int pageSize = productsPageSize,
  }) => _productDao.watchProducts(
    query: query,
    orderBy: orderBy,
    page: page,
    pageSize: pageSize,
  );

  @override
  Future<void> addProduct(Product product) async {
    if (product.name.trim().isEmpty) {
      throw ArgumentError('Product name cannot be empty');
    }
    await _productDao.insertProduct(product);
  }

  @override
  Future<void> updateProduct(Product product) async {
    await _productDao.updateProduct(product);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _productDao.deleteProduct(id);
  }
}
