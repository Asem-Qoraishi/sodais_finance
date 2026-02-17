import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/widgets/bottom_sheets/order_by_bottom_sheet.dart';
import 'package:sodais_finance/features/products/presentation/controllers/products_controller.dart';
import 'package:sodais_finance/features/products/presentation/controllers/products_order_options.dart';

class ProductsOrderBy extends ConsumerWidget {
  const ProductsOrderBy({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedOrder = ref.watch(productsOrderOptionProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          selectedOrder.name,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(width: sizeConstants.spacingXSmall),
        InkWell(
          borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
          onTap: () {
            showOrderByBottomSheet(
              context: context,
              selected: selectedOrder,
              options: ProductsOrderOption.values,
              onApply: (value) {
                ref
                    .read(productsOrderOptionProvider.notifier)
                    .setOrderOption(value);
                Navigator.of(context).pop();
              },
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sizeConstants.spacingXSmall,
              vertical: sizeConstants.spacingXXSmall,
            ),
            child: Text(
              LocaleKeys.orderBy.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
