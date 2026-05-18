import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/features/reports/domain/report_snapshot.dart';
import 'package:sodais_finance/features/reports/presentation/report_formatters.dart';

class ReportTopItemsDetailsScreen extends StatelessWidget {
  const ReportTopItemsDetailsScreen({super.key, required this.snapshot});

  final ReportsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.topItemsBySales.tr())),
      body: ListView(
        padding: EdgeInsets.all(sizeConstants.spacingSmall),
        children: [
          _ItemsPanel(products: snapshot.topSellingProducts),
          SizedBox(height: sizeConstants.spacingSmall),
          _AlertsPanel(alerts: snapshot.inventoryHealth.alerts),
        ],
      ),
    );
  }
}

class _ItemsPanel extends StatelessWidget {
  const _ItemsPanel({required this.products});

  final List<ReportTopProduct> products;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(sizeConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(sizeConstants.radiusLarge),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.topItemsBySales.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: sizeConstants.spacingSmall),
          if (products.isEmpty)
            Text(
              LocaleKeys.noReportData.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            )
          else
            for (int index = 0; index < products.length; index++) ...[
              if (index > 0) Divider(height: sizeConstants.spacingSmall * 2),
              _ItemRow(rank: index + 1, product: products[index]),
            ],
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.rank, required this.product});

  final int rank;
  final ReportTopProduct product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: sizeConstants.avatarXSmall,
          height: sizeConstants.avatarXSmall,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
          ),
          child: Text(
            rank.toString(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(width: sizeConstants.spacingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: sizeConstants.spacingXXSmall),
              Text(
                '${LocaleKeys.quantity.tr()}: ${ReportsFormatters.formatQuantity(product.quantity)} • '
                '${LocaleKeys.currentStock.tr()}: ${product.currentStock}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: sizeConstants.spacingSmall),
        Text(
          ReportsFormatters.formatMoney(product.revenue),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _AlertsPanel extends StatelessWidget {
  const _AlertsPanel({required this.alerts});

  final List<ReportInventoryAlert> alerts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(sizeConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(sizeConstants.radiusLarge),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.inventory.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: sizeConstants.spacingSmall),
          if (alerts.isEmpty)
            Text(
              LocaleKeys.noInventoryAlerts.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            )
          else
            for (int index = 0; index < alerts.length; index++) ...[
              if (index > 0) Divider(height: sizeConstants.spacingSmall * 2),
              Row(
                children: [
                  Icon(
                    alerts[index].outOfStock
                        ? Icons.remove_shopping_cart_outlined
                        : Icons.warning_amber_rounded,
                    color: alerts[index].outOfStock
                        ? Theme.of(context).colorScheme.error
                        : Colors.orange.shade700,
                  ),
                  SizedBox(width: sizeConstants.spacingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alerts[index].name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: sizeConstants.spacingXXSmall),
                        Text(
                          alerts[index].outOfStock
                              ? LocaleKeys.outOfStock.tr()
                              : '${LocaleKeys.lowStock.tr()} • '
                                    '${alerts[index].stock}/${alerts[index].reorderLevel}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
        ],
      ),
    );
  }
}
