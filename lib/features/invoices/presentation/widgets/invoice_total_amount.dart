import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/widgets/cards/custom_card.dart';
import 'package:sodais_finance/features/invoices/presentation/controllers/invoice_form_state.dart';

class InvoiceTotalAmount extends StatelessWidget {
  const InvoiceTotalAmount({super.key, required this.invoiceState});

  final InvoiceState invoiceState;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: EdgeInsets.zero,
      child: Column(
        spacing: sizeConstants.spacingSmall,
        children: [
          _SummaryRow(
            label: LocaleKeys.subtotal.tr(),
            value: formatInvoiceAmount(invoiceState.subtotal),
          ),
          _SummaryRow(
            label: LocaleKeys.discount.tr(),
            value: formatInvoiceAmount(invoiceState.discount),
          ),
          if (invoiceState.taxAmount > 0)
            _SummaryRow(
              label: LocaleKeys.tax.tr(),
              value: formatInvoiceAmount(invoiceState.taxAmount),
            ),
          Divider(height: sizeConstants.spacingLarge),
          _SummaryRow(
            label: LocaleKeys.total.tr(),
            value: formatInvoiceAmount(invoiceState.totalAmount),
            isEmphasized: true,
          ),
          _SummaryRow(
            label: LocaleKeys.amountPaid.tr(),
            value: formatInvoiceAmount(invoiceState.amountPaid),
          ),
          _SummaryRow(
            label: LocaleKeys.remaining.tr(),
            value: formatInvoiceAmount(invoiceState.remainingAmount),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });

  final String label;
  final String value;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final textStyle = isEmphasized
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        Text(value, style: textStyle),
      ],
    );
  }
}
