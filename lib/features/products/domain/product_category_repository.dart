import 'package:sodais_finance/features/products/domain/product_category.dart';

abstract class ProductCategoryRepository {
  Stream<List<ProductCategory>> watchCategories({String query = ''});

  Future<String> addCategory({
    required String name,
    required String icon,
    required String colorHex,
  });

  Future<void> updateCategory(ProductCategory category);
  Future<void> deleteCategory(String id);
}
