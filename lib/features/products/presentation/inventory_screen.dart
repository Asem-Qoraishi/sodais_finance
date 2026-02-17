import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/features/products/domain/product.dart';
import 'package:sodais_finance/features/products/presentation/controllers/products_controller.dart';
import 'package:sodais_finance/features/products/presentation/widgets/inventory_app_bar.dart';
import 'package:sodais_finance/features/products/presentation/widgets/products_list.dart';
import 'package:sodais_finance/features/products/presentation/widgets/products_order_by.dart';
import 'package:sodais_finance/features/products/presentation/widgets/products_search_field.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsControllerProvider);
    final products = productsAsync.asData?.value ?? const <Product>[];

    return Scaffold(
      appBar: const InventoryAppBar(),
      body: Padding(
        padding: EdgeInsets.all(sizeConstants.spacingSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InventorySearchField(),
            SizedBox(height: sizeConstants.spacingSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.resultsCount.tr(
                    namedArgs: {'count': products.length.toString()},
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const ProductsOrderBy(),
              ],
            ),
            SizedBox(height: sizeConstants.spacingXSmall),
            Expanded(
              child: productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return Center(
                      child: Text(
                        LocaleKeys.noProductsFound.tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ProductsList(products: products);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text(
                    LocaleKeys.failedToLoadProducts.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
