import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sodais_finance/config/app_router.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/features/products/presentation/controllers/products_controller.dart';

class InventoryAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const InventoryAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      centerTitle: true,
      title: Text(LocaleKeys.inventory.tr()),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ref.invalidate(productsControllerProvider);
          },
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            context.pushNamed(routeNames.addNewProduct);
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
