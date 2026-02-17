import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/features/products/domain/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onTap});

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(sizeConstants.radiusLarge),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(
          horizontal: sizeConstants.spacingSmall,
          vertical: sizeConstants.spacingXXSmall,
        ),
        leading: _buildAvatar(),
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: sizeConstants.spacingXXSmall),
          child: Wrap(
            spacing: sizeConstants.spacingXXSmall,
            runSpacing: sizeConstants.spacingXXSmall,
            children: [
              _StockBadge(product: product),
              if ((product.categoryName ?? '').trim().isNotEmpty)
                _InfoBadge(text: product.categoryName!.trim()),
              if ((product.sku ?? '').trim().isNotEmpty)
                _InfoBadge(text: product.sku!.trim()),
            ],
          ),
        ),
        trailing: Text(
          '\$${product.sellingPrice.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final path = product.imagePath;
    final hasImage = path != null && path.isNotEmpty && File(path).existsSync();

    return CircleAvatar(
      radius: sizeConstants.imageSmall / 2,
      child: hasImage
          ? ClipOval(child: Image.file(File(path), fit: BoxFit.cover))
          : Text(_buildInitials(product.name)),
    );
  }

  String _buildInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final status = switch (true) {
      _ when !product.isInStock => _StockBadgeStatus.outOfStock,
      _ when product.isLowStock => _StockBadgeStatus.lowStock,
      _ => _StockBadgeStatus.inStock,
    };

    final text = switch (status) {
      _StockBadgeStatus.outOfStock => LocaleKeys.outOfStock.tr(),
      _StockBadgeStatus.lowStock => LocaleKeys.lowStock.tr(),
      _StockBadgeStatus.inStock => '${LocaleKeys.stock.tr()}: ${product.stock}',
    };

    final foreground = switch (status) {
      _StockBadgeStatus.outOfStock => colors.error,
      _StockBadgeStatus.lowStock => const Color(0xFFCA8A04),
      _StockBadgeStatus.inStock => const Color(0xFF16A34A),
    };

    final background = foreground.withValues(alpha: 0.12);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizeConstants.spacingXSmall,
        vertical: sizeConstants.spacingXXSmall,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

enum _StockBadgeStatus { inStock, lowStock, outOfStock }

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizeConstants.spacingXSmall,
        vertical: sizeConstants.spacingXXSmall,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
      ),
      child: Text(text, style: theme.textTheme.labelSmall),
    );
  }
}
