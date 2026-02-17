import 'package:sodais_finance/features/products/domain/product.dart';
import 'package:sodais_finance/features/products/domain/products_query_options.dart';

abstract class ProductRepository {
  Stream<List<Product>> watchProducts({
    required String query,
    required ProductsOrderBy orderBy,
    int page = 0,
    int pageSize = productsPageSize,
  });

  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}
