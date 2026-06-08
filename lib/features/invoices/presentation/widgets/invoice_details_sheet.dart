import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/utils/formatters/app_number_formatter.dart';
import 'package:sodais_finance/core/widgets/cards/custom_card.dart';
import 'package:sodais_finance/features/invoices/application/providers/invoice_providers.dart';
import 'package:sodais_finance/features/invoices/data/local/dao/invoice_dao.dart';
import 'package:sodais_finance/features/invoices/presentation/controllers/invoice_form_state.dart';

class InvoiceDetailsSheet extends ConsumerWidget {
  const InvoiceDetailsSheet({super.key, required this.invoiceId});

  final int invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(invoiceDetailsProvider(invoiceId));
    final paymentsAsync = ref.watch(invoicePaymentRecordsProvider(invoiceId));

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          sizeConstants.spacingMedium,
          sizeConstants.spacingSmall,
          sizeConstants.spacingMedium,
          sizeConstants.spacingMedium,
        ),
        child: detailsAsync.when(
          data: (details) {
            if (details == null) {
              return const Center(child: Text('Unable to load invoice.'));
            }

            final remainingAmount =
                (details.invoice.finalAmount - details.invoice.amountPaid)
                    .clamp(0, details.invoice.finalAmount)
                    .toDouble();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details.contact?.name ?? LocaleKeys.unknownContact.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: sizeConstants.spacingXXSmall),
                  Text(
                    '${_invoiceTypeLabel(details.invoice.type)} ${details.invoice.invoiceNumber}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  SizedBox(height: sizeConstants.spacingSmall),
                  Text(
                    '${LocaleKeys.total.tr()}: ${AppNumberFormatter.formatAmount(details.invoice.finalAmount)}',
                  ),
                  Text(
                    '${LocaleKeys.amountPaid.tr()}: ${AppNumberFormatter.formatAmount(details.invoice.amountPaid)}',
                  ),
                  Text(
                    '${LocaleKeys.remaining.tr()}: ${AppNumberFormatter.formatAmount(remainingAmount)}',
                  ),
                  SizedBox(height: sizeConstants.spacingLarge),
                  Text(
                    LocaleKeys.items.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: sizeConstants.spacingSmall),
                  for (final item in details.items) ...[
                    CustomCard(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.all(sizeConstants.spacingSmall),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.product?.name ?? LocaleKeys.product.tr(),
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                            '${_displayInvoiceItemQuantity(item)} x ${AppNumberFormatter.formatAmount(item.item.unitPrice)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          SizedBox(width: sizeConstants.spacingSmall),
                          Text(
                            AppNumberFormatter.formatAmount(
                              item.item.totalPrice,
                            ),
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sizeConstants.spacingSmall),
                  ],
                  Text(
                    LocaleKeys.payment.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: sizeConstants.spacingSmall),
                  paymentsAsync.when(
                    data: (payments) {
                      if (payments.isEmpty) {
                        return Text(LocaleKeys.noPaymentsYet.tr());
                      }

                      return Column(
                        children: payments
                            .map(
                              (payment) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: sizeConstants.spacingSmall,
                                ),
                                child: CustomCard(
                                  margin: EdgeInsets.zero,
                                  padding: EdgeInsets.all(
                                    sizeConstants.spacingSmall,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(payment.recordedAt),
                                        ),
                                      ),
                                      Text(
                                        AppNumberFormatter.formatAmount(
                                          payment.amount,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stackTrace) =>
                        Text(LocaleKeys.failedToLoadInvoices.tr()),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text(LocaleKeys.failedToLoadInvoices.tr())),
        ),
      ),
    );
  }
}

String _invoiceTypeLabel(String type) {
  return switch (type) {
    'purchase' => LocaleKeys.purchase.tr(),
    'returned' => LocaleKeys.returned.tr(),
    _ => LocaleKeys.sale.tr(),
  };
}

String _displayInvoiceItemQuantity(InvoiceDetailsItem item) {
  final product = item.product;
  final mainQuantity = item.item.quantity;
  if (product == null) {
    return formatInvoiceAmount(mainQuantity);
  }

  final rate = product.secondaryUnitRate ?? 0;
  if (product.hasSecondaryUnit && rate > 0) {
    final secondaryQuantity = (mainQuantity / rate).floor();
    final remainingMainQuantity = mainQuantity - (secondaryQuantity * rate);
    final parts = <String>[
      if (secondaryQuantity > 0)
        '${formatInvoiceAmount(secondaryQuantity)} ${product.secondaryUnitName}',
      if (remainingMainQuantity > 0.000001)
        '${formatInvoiceAmount(remainingMainQuantity)} ${product.mainUnitName}',
    ];
    if (parts.isNotEmpty) return parts.join(' + ');
  }

  return '${formatInvoiceAmount(mainQuantity)} ${product.mainUnitName}';
}
