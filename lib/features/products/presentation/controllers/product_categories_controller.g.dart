// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_categories_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProductCategorySearchQuery)
final productCategorySearchQueryProvider =
    ProductCategorySearchQueryProvider._();

final class ProductCategorySearchQueryProvider
    extends $NotifierProvider<ProductCategorySearchQuery, String> {
  ProductCategorySearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productCategorySearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productCategorySearchQueryHash();

  @$internal
  @override
  ProductCategorySearchQuery create() => ProductCategorySearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$productCategorySearchQueryHash() =>
    r'1020493c14436c514ccea62606c5dd1f3bdc26ba';

abstract class _$ProductCategorySearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ProductCategoriesController)
final productCategoriesControllerProvider =
    ProductCategoriesControllerProvider._();

final class ProductCategoriesControllerProvider
    extends
        $StreamNotifierProvider<
          ProductCategoriesController,
          List<ProductCategory>
        > {
  ProductCategoriesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productCategoriesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productCategoriesControllerHash();

  @$internal
  @override
  ProductCategoriesController create() => ProductCategoriesController();
}

String _$productCategoriesControllerHash() =>
    r'28998664aed636943ca82c8a9920cde749a4399e';

abstract class _$ProductCategoriesController
    extends $StreamNotifier<List<ProductCategory>> {
  Stream<List<ProductCategory>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<ProductCategory>>, List<ProductCategory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ProductCategory>>,
                List<ProductCategory>
              >,
              AsyncValue<List<ProductCategory>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
