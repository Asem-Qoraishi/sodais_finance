import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/colors.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/features/products/domain/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      minVerticalPadding: sizeConstants.spacingSmall,
      leading: product.image == null
          ? const Icon(Icons.image)
          : Image.file(File(product.image!)),
      title: Text(product.name),
      subtitle: _stockBadge(product.stock),
      trailing: Text(
        "${product.price} افغانی",
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _stockBadge(int stock) {
    final badgeText = stock > 0 ? "$stock موجود" : "ناموجود";
    final badgeColor = stock > 0 ? kSuccessColor : darkErrorColor;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(badgeText, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
