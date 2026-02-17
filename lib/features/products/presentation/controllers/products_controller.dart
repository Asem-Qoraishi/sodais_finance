import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sodais_finance/features/products/data/repositories/product_repository_impl.dart';
import 'package:sodais_finance/features/products/domain/product.dart';
import 'package:sodais_finance/features/products/domain/products_query_options.dart';
import 'package:sodais_finance/features/products/presentation/controllers/products_order_options.dart';

part 'products_controller.g.dart';

class ProductsPageNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setPage(int page) {
    state = page < 0 ? 0 : page;
  }

  void nextPage() {
    state += 1;
  }

  void reset() {
    state = 0;
  }
}

final productsPageProvider = NotifierProvider<ProductsPageNotifier, int>(
  ProductsPageNotifier.new,
);

class ProductsOrderOptionNotifier extends Notifier<ProductsOrderOption> {
  @override
  ProductsOrderOption build() => ProductsOrderOption.newest;

  void setOrderOption(ProductsOrderOption option) {
    if (state == option) return;
    state = option;
    ref.read(productsPageProvider.notifier).reset();
  }
}

final productsOrderOptionProvider =
    NotifierProvider<ProductsOrderOptionNotifier, ProductsOrderOption>(
      ProductsOrderOptionNotifier.new,
    );

@riverpod
class ProductSearchQuery extends _$ProductSearchQuery {
  @override
  String build() => '';

  void update(String query) {
    if (state == query) return;
    state = query;
    ref.read(productsPageProvider.notifier).reset();
  }
}

@riverpod
class ProductsController extends _$ProductsController {
  @override
  Stream<List<Product>> build() {
    final repository = ref.watch(productRepositoryProvider);
    final query = ref.watch(productSearchQueryProvider).trim();
    final orderBy = ref.watch(productsOrderOptionProvider).toQueryOrderBy();
    final page = ref.watch(productsPageProvider);

    return repository.watchProducts(
      query: query,
      orderBy: orderBy,
      page: page,
      pageSize: productsPageSize,
    );
  }

  Future<void> addProduct({
    required String name,
    String? description,
    String? imagePath,
    String? sku,
    String? categoryId,
    required double purchasePrice,
    required double sellingPrice,
    required double taxRate,
    required int stock,
    required int reorderLevel,
    String? location,
  }) async {
    final now = DateTime.now();
    final product = Product(
      id: '0',
      name: name,
      description: description,
      imagePath: imagePath,
      sku: sku,
      categoryId: categoryId,
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      taxRate: taxRate,
      stock: stock,
      reorderLevel: reorderLevel,
      location: location,
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(productRepositoryProvider).addProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    await ref.read(productRepositoryProvider).updateProduct(product);
  }

  Future<void> deleteProduct(String id) async {
    await ref.read(productRepositoryProvider).deleteProduct(id);
  }
}

extension on ProductsOrderOption {
  ProductsOrderBy toQueryOrderBy() {
    switch (this) {
      case ProductsOrderOption.alphabetAsc:
        return ProductsOrderBy.alphabetAsc;
      case ProductsOrderOption.alphabetDesc:
        return ProductsOrderBy.alphabetDesc;
      case ProductsOrderOption.highestStock:
        return ProductsOrderBy.highestStock;
      case ProductsOrderOption.oldest:
        return ProductsOrderBy.oldest;
      case ProductsOrderOption.newest:
        return ProductsOrderBy.newest;
    }
  }
}
