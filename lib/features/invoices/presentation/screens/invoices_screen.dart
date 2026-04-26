import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:sodais_finance/config/app_router.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/utils/helpers/app_locale_helper.dart';
import 'package:sodais_finance/core/widgets/cards/custom_card.dart';
import 'package:sodais_finance/features/invoices/application/providers/invoice_providers.dart';
import 'package:sodais_finance/features/invoices/data/local/dao/invoice_dao.dart';
import 'package:sodais_finance/features/invoices/presentation/controllers/invoice_form_state.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  void _openInvoice(BuildContext context, InvoiceSummary summary) {
    context.pushNamed(
      routeNames.editInvoice,
      pathParameters: {'invoiceId': summary.invoice.id.toString()},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoiceSummaryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.invoices.tr()),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(invoiceSummaryListProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(sizeConstants.spacingSmall),
        child: invoicesAsync.when(
          data: (invoices) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.resultsCount.tr(
                    namedArgs: {'count': invoices.length.toString()},
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: sizeConstants.spacingSmall),
                Expanded(
                  child: invoices.isEmpty
                      ? Center(
                          child: _StateContent(
                            icon: Icons.receipt_long_outlined,
                            title: LocaleKeys.noInvoicesFound.tr(),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.only(
                            bottom: sizeConstants.spacingXXLarge,
                          ),
                          itemCount: invoices.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: sizeConstants.spacingSmall),
                          itemBuilder: (context, index) => _InvoiceSummaryCard(
                            summary: invoices[index],
                            onTap: () => _openInvoice(context, invoices[index]),
                          ),
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: _StateContent(
              icon: Icons.error_outline,
              title: LocaleKeys.failedToLoadInvoices.tr(),
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoiceSummaryCard extends StatelessWidget {
  const _InvoiceSummaryCard({required this.summary, required this.onTap});

  final InvoiceSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invoice = summary.invoice;
    final invoiceType = _invoiceTypeFromName(invoice.type);
    final paymentStatus = _paymentStatusFromName(invoice.status);
    final typeColor = _invoiceTypeColor(invoiceType);
    final statusColor = _paymentStatusColor(context, paymentStatus);
    final contactName = summary.contactName.trim().isEmpty
        ? LocaleKeys.unknownContact.tr()
        : summary.contactName.trim();

    return CustomCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(sizeConstants.spacingSmall),
      onTap: onTap,
      child: Column(
        spacing: sizeConstants.spacingSmall,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: sizeConstants.avatarXSmall,
                height: sizeConstants.avatarXSmall,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    sizeConstants.radiusSmall,
                  ),
                ),
                child: Icon(_invoiceTypeIcon(invoiceType), color: typeColor),
              ),
              SizedBox(width: sizeConstants.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.invoiceNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: sizeConstants.spacingXXSmall),
                    Text(
                      contactName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              SizedBox(width: sizeConstants.spacingSmall),
              Text(
                _formatMoney(invoice.finalAmount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: sizeConstants.spacingXSmall,
            runSpacing: sizeConstants.spacingXSmall,
            children: [
              _InvoiceBadge(
                label: invoiceType.label,
                icon: _invoiceTypeIcon(invoiceType),
                color: typeColor,
              ),
              _InvoiceBadge(
                label: paymentStatus.label,
                icon: _paymentStatusIcon(paymentStatus),
                color: statusColor,
              ),
              _InvoiceBadge(
                label: LocaleKeys.itemsCount.tr(
                  namedArgs: {'count': summary.itemCount.toString()},
                ),
                icon: Icons.inventory_2_outlined,
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.event_outlined,
                size: sizeConstants.iconSmall,
                color: theme.hintColor,
              ),
              SizedBox(width: sizeConstants.spacingXXSmall),
              Expanded(
                child: Text(
                  _formatDate(context, invoice.issueDate),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InvoiceType _invoiceTypeFromName(String value) {
    for (final type in InvoiceType.values) {
      if (type.name == value) return type;
    }
    return InvoiceType.sale;
  }

  PaymentStatus _paymentStatusFromName(String value) {
    for (final status in PaymentStatus.values) {
      if (status.name == value) return status;
    }
    return PaymentStatus.unpaid;
  }

  IconData _invoiceTypeIcon(InvoiceType type) {
    return switch (type) {
      InvoiceType.sale => Icons.shopping_bag_outlined,
      InvoiceType.purchase => Icons.inventory_2_outlined,
      InvoiceType.returned => Icons.assignment_return_outlined,
    };
  }

  IconData _paymentStatusIcon(PaymentStatus status) {
    return switch (status) {
      PaymentStatus.paid => Icons.check_circle_outline,
      PaymentStatus.unpaid => Icons.schedule_outlined,
      PaymentStatus.partialPaid => Icons.timelapse_outlined,
    };
  }

  Color _invoiceTypeColor(InvoiceType type) {
    return switch (type) {
      InvoiceType.sale => Colors.green.shade700,
      InvoiceType.purchase => Colors.blue.shade700,
      InvoiceType.returned => Colors.orange.shade800,
    };
  }

  Color _paymentStatusColor(BuildContext context, PaymentStatus status) {
    return switch (status) {
      PaymentStatus.paid => Colors.green.shade700,
      PaymentStatus.unpaid => Theme.of(context).colorScheme.error,
      PaymentStatus.partialPaid => Colors.orange.shade800,
    };
  }

  String _formatDate(BuildContext context, DateTime date) {
    if (appLocaleHelper.isCurrentLanguageEnglish(context)) {
      return DateFormat('d MMM yyyy').format(date);
    }

    final jalaliDate = Jalali.fromDateTime(date);
    final f = jalaliDate.formatter;
    return '${f.wN} ${f.d} ${f.mNAf} ${f.yyyy}';
  }

  String _formatMoney(double value) {
    final fixed = value.abs().toStringAsFixed(2);
    final parts = fixed.split('.');
    return '\$${_withThousandsSeparator(parts[0])}.${parts[1]}';
  }

  String _withThousandsSeparator(String value) {
    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      final remaining = value.length - i;
      buffer.write(value[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }
}

class _InvoiceBadge extends StatelessWidget {
  const _InvoiceBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizeConstants.spacingXSmall,
        vertical: sizeConstants.spacingXXSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: sizeConstants.iconSmall, color: color),
          SizedBox(width: sizeConstants.spacingXXSmall),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StateContent extends StatelessWidget {
  const _StateContent({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: sizeConstants.iconXLarge, color: theme.hintColor),
        SizedBox(height: sizeConstants.spacingSmall),
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
