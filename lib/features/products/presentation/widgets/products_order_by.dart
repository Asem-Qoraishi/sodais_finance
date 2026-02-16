import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/widgets/bottom_sheets/order_by_bottom_sheet.dart';
import 'package:sodais_finance/features/products/presentation/controllers/products_order_options.dart';

class ProductsOrderBy extends ConsumerWidget {
  const ProductsOrderBy({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const orderBy = ProductsOrderOption.newest;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${LocaleKeys.orderBy.tr()}: ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        IconButton(
          icon: Row(
            children: [
              Text(orderBy.name, style: Theme.of(context).textTheme.bodyLarge),
              Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ],
          ),
          color: Theme.of(context).textTheme.bodyLarge!.color,
          onPressed: () {
            showOrderByBottomSheet(
              context: context,
              selected: orderBy,
              options: ProductsOrderOption.values,
              onApply: (value) {},
            );
          },
        ),
      ],
    );
  }
}
