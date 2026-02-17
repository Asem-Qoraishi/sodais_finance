import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/features/products/data/local/dao/product_category_dao.dart';
import 'package:sodais_finance/features/products/domain/product_category.dart';
import 'package:sodais_finance/features/products/domain/product_category_repository.dart';

final productCategoryRepositoryProvider = Provider(
  (ref) => ProductCategoryRepositoryImpl(ref.watch(productCategoryDaoProvider)),
);

class ProductCategoryRepositoryImpl implements ProductCategoryRepository {
  final ProductCategoryDao _productCategoryDao;

  ProductCategoryRepositoryImpl(this._productCategoryDao);

  @override
  Stream<List<ProductCategory>> watchCategories({String query = ''}) {
    return _productCategoryDao.watchCategories(query: query);
  }

  @override
  Future<String> addCategory({
    required String name,
    required String icon,
    required String colorHex,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Category name cannot be empty');
    }

    final id = await _productCategoryDao.insertCategory(
      name: name.trim(),
      icon: icon,
      colorHex: colorHex,
    );

    return id.toString();
  }

  @override
  Future<void> updateCategory(ProductCategory category) async {
    await _productCategoryDao.updateCategory(category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _productCategoryDao.deleteCategory(id);
  }
}
