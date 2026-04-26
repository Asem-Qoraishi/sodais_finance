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
import 'package:sodais_finance/features/invoices/presentation/controllers/invoice_form_state.dart';
import 'package:sodais_finance/features/transactions/application/providers/transaction_providers.dart';
import 'package:sodais_finance/features/transactions/domain/transaction_feed_entry.dart';
import 'package:sodais_finance/features/transactions/domain/transactions_repository.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  void _openLinkedInvoice(BuildContext context, TransactionFeedEntry entry) {
    if (entry.isInvoice || entry.referenceType == invoicePaymentReferenceType) {
      context.pushNamed(
        routeNames.editInvoice,
        pathParameters: {'invoiceId': entry.referenceId.toString()},
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(unifiedTransactionFeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.transactions.tr()),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(unifiedTransactionFeedProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(sizeConstants.spacingSmall),
        child: feedAsync.when(
          data: (entries) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.resultsCount.tr(
                    namedArgs: {'count': entries.length.toString()},
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: sizeConstants.spacingSmall),
                Expanded(
                  child: entries.isEmpty
                      ? Center(
                          child: Text(
                            LocaleKeys.noTransactionsFound.tr(),
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.only(
                            bottom: sizeConstants.spacingXXLarge,
                          ),
                          itemCount: entries.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: sizeConstants.spacingSmall),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            final canOpenInvoice =
                                entry.isInvoice ||
                                entry.referenceType ==
                                    invoicePaymentReferenceType;

                            return _TransactionFeedCard(
                              entry: entry,
                              onTap: canOpenInvoice
                                  ? () => _openLinkedInvoice(context, entry)
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(
              LocaleKeys.failedToLoadTransactions.tr(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionFeedCard extends StatelessWidget {
  const _TransactionFeedCard({required this.entry, this.onTap});

  final TransactionFeedEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = _accentColor(context);

    return CustomCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(sizeConstants.spacingSmall),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: sizeConstants.avatarXSmall,
                height: sizeConstants.avatarXSmall,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    sizeConstants.radiusSmall,
                  ),
                ),
                child: Icon(_icon(), color: iconColor),
              ),
              SizedBox(width: sizeConstants.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: sizeConstants.spacingXXSmall),
                    Text(
                      _subtitle(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              SizedBox(width: sizeConstants.spacingSmall),
              Text(
                _formatMoney(entry.amount),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: sizeConstants.spacingSmall),
          Wrap(
            spacing: sizeConstants.spacingXSmall,
            runSpacing: sizeConstants.spacingXSmall,
            children: _badges(context),
          ),
          SizedBox(height: sizeConstants.spacingSmall),
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
                  _formatDate(context, entry.occurredAt),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
              if ((entry.description ?? '').trim().isNotEmpty) ...[
                SizedBox(width: sizeConstants.spacingXSmall),
                Flexible(
                  child: Text(
                    entry.description!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _title(BuildContext context) {
    if (entry.isInvoice) {
      return entry.invoiceNumber?.trim().isNotEmpty == true
          ? entry.invoiceNumber!.trim()
          : LocaleKeys.invoices.tr();
    }

    return switch (entry.referenceType) {
      invoicePaymentReferenceType => LocaleKeys.invoicePayment.tr(),
      openingBalanceReferenceType => LocaleKeys.openingBalance.tr(),
      manualReferenceType => LocaleKeys.manualEntry.tr(),
      _ => LocaleKeys.transactions.tr(),
    };
  }

  String _subtitle(BuildContext context) {
    final contactName = entry.contactName?.trim();
    final invoiceNumber = entry.invoiceNumber?.trim();

    if (entry.isInvoice) {
      return contactName?.isNotEmpty == true
          ? contactName!
          : LocaleKeys.unknownContact.tr();
    }

    if (entry.referenceType == invoicePaymentReferenceType &&
        invoiceNumber != null &&
        invoiceNumber.isNotEmpty) {
      final contact = contactName?.isNotEmpty == true ? ' • $contactName' : '';
      return '${LocaleKeys.linkedInvoice.tr()}: $invoiceNumber$contact';
    }

    if (contactName?.isNotEmpty == true) {
      return contactName!;
    }

    final description = entry.description?.trim();
    if (description?.isNotEmpty == true) {
      return description!;
    }

    return LocaleKeys.details.tr();
  }

  List<Widget> _badges(BuildContext context) {
    if (entry.isInvoice) {
      final invoiceType = _invoiceTypeFromName(entry.entryType);
      final paymentStatus = _paymentStatusFromName(entry.status);
      final theme = Theme.of(context);

      return [
        _Badge(
          label: invoiceType.label,
          icon: _invoiceTypeIcon(invoiceType),
          color: _invoiceTypeColor(invoiceType),
        ),
        _Badge(
          label: paymentStatus.label,
          icon: _paymentStatusIcon(paymentStatus),
          color: _paymentStatusColor(context, paymentStatus),
        ),
        _Badge(
          label:
              '${LocaleKeys.amountPaid.tr()}: ${_formatMoney(entry.amountPaid ?? 0)}',
          icon: Icons.payments_outlined,
          color: theme.colorScheme.secondary,
        ),
      ];
    }

    return [
      _Badge(
        label: _transactionTypeLabel(context),
        icon: _icon(),
        color: _accentColor(context),
      ),
      if (entry.referenceType == invoicePaymentReferenceType &&
          entry.invoiceNumber?.trim().isNotEmpty == true)
        _Badge(
          label: entry.invoiceNumber!.trim(),
          icon: Icons.receipt_long_outlined,
          color: Theme.of(context).colorScheme.secondary,
        ),
    ];
  }

  String _transactionTypeLabel(BuildContext context) {
    return switch (entry.referenceType) {
      invoicePaymentReferenceType => LocaleKeys.payment.tr(),
      openingBalanceReferenceType => LocaleKeys.openingBalance.tr(),
      manualReferenceType => LocaleKeys.manualEntry.tr(),
      _ => switch (entry.entryType) {
        'income' => LocaleKeys.receipt.tr(),
        'expense' => LocaleKeys.payment.tr(),
        _ => LocaleKeys.transactions.tr(),
      },
    };
  }

  IconData _icon() {
    if (entry.isInvoice) {
      return _invoiceTypeIcon(_invoiceTypeFromName(entry.entryType));
    }

    return switch (entry.referenceType) {
      invoicePaymentReferenceType => Icons.payments_outlined,
      openingBalanceReferenceType => Icons.account_balance_wallet_outlined,
      _ => switch (entry.entryType) {
        'income' => Icons.call_received_rounded,
        'expense' => Icons.call_made_rounded,
        'transfer' => Icons.swap_horiz_rounded,
        _ => Icons.receipt_long_outlined,
      },
    };
  }

  Color _accentColor(BuildContext context) {
    if (entry.isInvoice) {
      return _invoiceTypeColor(_invoiceTypeFromName(entry.entryType));
    }

    return switch (entry.entryType) {
      'income' => Colors.green.shade700,
      'expense' => Colors.red.shade700,
      'transfer' => Colors.blueGrey.shade700,
      _ => Theme.of(context).colorScheme.primary,
    };
  }

  InvoiceType _invoiceTypeFromName(String value) {
    for (final type in InvoiceType.values) {
      if (type.name == value) return type;
    }
    return InvoiceType.sale;
  }

  PaymentStatus _paymentStatusFromName(String? value) {
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
    return '${jalaliDate.day} ${jalaliDate.formatter.mN} ${jalaliDate.year}';
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.icon, required this.color});

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
          Icon(icon, color: color, size: sizeConstants.iconSmall),
          SizedBox(width: sizeConstants.spacingXXSmall),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
