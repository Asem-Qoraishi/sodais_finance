import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sodais_finance/config/app_router.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/features/products/domain/product.dart';
import 'package:sodais_finance/features/products/presentation/widgets/product_card.dart';

class ProductsList extends StatelessWidget {
  const ProductsList({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: sizeConstants.spacingXXLarge),
      itemCount: products.length,
      separatorBuilder: (_, index) =>
          SizedBox(height: sizeConstants.spacingXSmall),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () =>
              context.pushNamed(routeNames.editProduct, extra: product),
        );
      },
    );
  }
}
