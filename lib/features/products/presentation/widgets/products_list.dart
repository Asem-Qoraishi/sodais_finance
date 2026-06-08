import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sodais_finance/config/app_router.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:sodais_finance/features/products/domain/product.dart';
import 'package:sodais_finance/features/products/presentation/controllers/products_controller.dart';
import 'package:sodais_finance/features/products/presentation/widgets/product_card.dart';

class ProductsList extends ConsumerWidget {
  const ProductsList({super.key, required this.products});

  final List<Product> products;

  Future<void> _openActions(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final selected = await showModalBottomSheet<_ProductAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(LocaleKeys.editProduct.tr()),
              onTap: () => Navigator.of(context).pop(_ProductAction.edit),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(LocaleKeys.delete.tr()),
              onTap: () => Navigator.of(context).pop(_ProductAction.delete),
            ),
          ],
        ),
      ),
    );

    if (!context.mounted || selected == null) return;

    switch (selected) {
      case _ProductAction.edit:
        context.pushNamed(routeNames.editProduct, extra: product);
        return;
      case _ProductAction.delete:
        final shouldDelete = await showDeleteConfirmationDialog(
          context: context,
          title: LocaleKeys.delete.tr(),
          message: LocaleKeys.deleteProductConfirmation.tr(
            namedArgs: {'name': product.name},
          ),
        );

        if (!shouldDelete) return;

        await ref
            .read(productsControllerProvider.notifier)
            .deleteProduct(product.id);
        return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: sizeConstants.spacingXXLarge),
      itemCount: products.length,
      separatorBuilder: (_, index) =>
          SizedBox(height: sizeConstants.spacingXSmall),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => _openActions(context, ref, product),
        );
      },
    );
  }
}

enum _ProductAction { edit, delete }
