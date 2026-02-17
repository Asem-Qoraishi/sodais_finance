import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sodais_finance/features/products/data/repositories/product_category_repository_impl.dart';
import 'package:sodais_finance/features/products/domain/product_category.dart';

part 'product_categories_controller.g.dart';

@riverpod
class ProductCategorySearchQuery extends _$ProductCategorySearchQuery {
  @override
  String build() => '';

  void update(String query) {
    state = query;
  }
}

@riverpod
class ProductCategoriesController extends _$ProductCategoriesController {
  @override
  Stream<List<ProductCategory>> build() {
    final repository = ref.watch(productCategoryRepositoryProvider);
    final query = ref.watch(productCategorySearchQueryProvider).trim();

    return repository.watchCategories(query: query);
  }

  Future<String> addCategory({
    required String name,
    required String icon,
    required String colorHex,
  }) async {
    return ref
        .read(productCategoryRepositoryProvider)
        .addCategory(name: name, icon: icon, colorHex: colorHex);
  }

  Future<void> updateCategory(ProductCategory category) async {
    await ref.read(productCategoryRepositoryProvider).updateCategory(category);
  }

  Future<void> deleteCategory(String id) async {
    await ref.read(productCategoryRepositoryProvider).deleteCategory(id);
  }
}
