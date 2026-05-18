import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/widgets/filters/filter_chip_bar.dart';
import 'package:sodais_finance/features/products/domain/products_query_options.dart';
import 'package:sodais_finance/features/products/presentation/controllers/products_controller.dart';

class ProductsFilterBar extends ConsumerWidget {
  const ProductsFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(productsStockFilterProvider);
    final filterController = ref.read(productsStockFilterProvider.notifier);

    return FilterChipBar<ProductStockFilter>(
      selectedValue: selectedFilter,
      onSelected: filterController.setFilter,
      options: [
        for (final filter in ProductStockFilter.values)
          FilterChipOption(
            value: filter,
            label: filter.name.tr(),
            icon: switch (filter) {
              ProductStockFilter.lowStock => Icons.warning_amber_rounded,
              ProductStockFilter.outOfStock =>
                Icons.remove_shopping_cart_outlined,
              ProductStockFilter.inStock => Icons.inventory_2_outlined,
              ProductStockFilter.all => null,
            },
          ),
      ],
    );
  }
}
