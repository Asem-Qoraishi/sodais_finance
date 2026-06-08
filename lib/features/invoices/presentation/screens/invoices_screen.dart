import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:sodais_finance/config/app_router.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/utils/formatters/app_number_formatter.dart';
import 'package:sodais_finance/core/utils/helpers/app_locale_helper.dart';
import 'package:sodais_finance/core/widgets/cards/custom_card.dart';
import 'package:sodais_finance/core/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:sodais_finance/features/app/data/app_database.dart';
import 'package:sodais_finance/features/invoices/application/providers/invoice_providers.dart';
import 'package:sodais_finance/features/invoices/data/local/dao/invoice_dao.dart';
import 'package:sodais_finance/features/invoices/presentation/controllers/invoice_form_state.dart';
import 'package:sodais_finance/features/invoices/presentation/widgets/invoice_payment_sheet.dart';
import 'package:sodais_finance/features/transactions/application/providers/transaction_providers.dart';
import 'package:sodais_finance/features/transactions/domain/transactions_repository.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  Future<void> _openInvoiceActions(
    BuildContext context,
    WidgetRef ref,
    InvoiceSummary summary,
  ) async {
    final invoice = summary.invoice;
    final status = _paymentStatusFromName(invoice.status);
    final selected = await showModalBottomSheet<_InvoiceAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(LocaleKeys.editInvoice.tr()),
              onTap: () => Navigator.of(context).pop(_InvoiceAction.edit),
            ),
            if (status != PaymentStatus.paid)
              ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: Text(LocaleKeys.addPayment.tr()),
                onTap: () => Navigator.of(context).pop(_InvoiceAction.payment),
              ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text(LocaleKeys.showDetails.tr()),
              onTap: () => Navigator.of(context).pop(_InvoiceAction.details),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(LocaleKeys.deleteInvoice.tr()),
              onTap: () => Navigator.of(context).pop(_InvoiceAction.delete),
            ),
          ],
        ),
      ),
    );

    if (!context.mounted || selected == null) return;

    switch (selected) {
      case _InvoiceAction.edit:
        context.pushNamed(
          routeNames.editInvoice,
          pathParameters: {'invoiceId': invoice.id.toString()},
        );
        return;
      case _InvoiceAction.details:
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => _InvoiceDetailsSheet(invoiceId: invoice.id),
        );
        return;
      case _InvoiceAction.delete:
        final confirmed = await showDeleteConfirmationDialog(
          context: context,
          title: LocaleKeys.deleteInvoice.tr(),
          message: LocaleKeys.deleteInvoiceConfirmation.tr(),
        );
        if (!confirmed) return;

        await ref.read(appDatabaseProvider).transaction(() async {
          await ref.read(invoiceDaoProvider).deleteInvoice(invoice.id);
          await ref
              .read(deleteInvoiceLedgerEntriesUseCaseProvider)
              .call(invoice.id);
        });
        ref.invalidate(invoiceSummaryListProvider);
        ref.invalidate(unifiedTransactionFeedProvider);
        return;
      case _InvoiceAction.payment:
        await _showAddPaymentSheet(context, ref, summary);
        return;
    }
  }

  Future<void> _showAddPaymentSheet(
    BuildContext context,
    WidgetRef ref,
    InvoiceSummary summary,
  ) async {
    final details = await ref.read(
      invoiceDetailsProvider(summary.invoice.id).future,
    );
    if (details == null) return;

    final payments = await ref.read(
      invoicePaymentRecordsProvider(summary.invoice.id).future,
    );
    final alreadyPaid = payments.fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );
    final remaining = (details.invoice.finalAmount - alreadyPaid)
        .clamp(0, details.invoice.finalAmount)
        .toDouble();
    if (remaining <= 0 || !context.mounted) return;

    final result = await showInvoicePaymentSheet(
      context: context,
      paymentIndex: payments.length + 1,
      totalAmount: details.invoice.finalAmount,
      remainingAmount: remaining,
    );

    if (result == null || result.action != InvoicePaymentSheetAction.save) {
      return;
    }

    final amount = result.amount ?? 0;
    if (amount <= 0) return;

    final nextPayments = [
      ...payments,
      InvoiceLedgerPaymentRecord(
        id: 0,
        amount: amount,
        recordedAt: DateTime.now(),
      ),
    ];
    final nextAmountPaid = nextPayments.fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );
    final nextStatus = _statusNameForAmounts(
      totalAmount: details.invoice.finalAmount,
      amountPaid: nextAmountPaid,
    );

    await ref.read(appDatabaseProvider).transaction(() async {
      await ref
          .read(invoiceDaoProvider)
          .updateInvoicePaymentSummary(
            invoiceId: details.invoice.id,
            amountPaid: nextAmountPaid,
            status: nextStatus,
          );
      await ref
          .read(syncInvoiceLedgerUseCaseProvider)
          .call(
            InvoiceLedgerSyncRequest(
              invoiceId: details.invoice.id,
              invoiceNumber: details.invoice.invoiceNumber,
              contactId: details.invoice.contactId,
              invoiceType: details.invoice.type,
              issueDate: details.invoice.issueDate,
              finalAmount: details.invoice.finalAmount,
              status: nextStatus,
              payments: nextPayments
                  .map(
                    (payment) => InvoiceLedgerPaymentRequest(
                      amount: payment.amount,
                      recordedAt: payment.recordedAt,
                    ),
                  )
                  .toList(growable: false),
            ),
          );
    });

    ref.invalidate(invoiceSummaryListProvider);
    ref.invalidate(invoiceDetailsProvider(summary.invoice.id));
    ref.invalidate(invoicePaymentRecordsProvider(summary.invoice.id));
    ref.invalidate(unifiedTransactionFeedProvider);
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
                            onTap: () => _openInvoiceActions(
                              context,
                              ref,
                              invoices[index],
                            ),
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
    final invoice = summary.invoice;
    final contactName = summary.contactName.trim().isEmpty
        ? LocaleKeys.unknownContact.tr()
        : summary.contactName.trim();
    final invoiceType = _invoiceTypeFromName(invoice.type);
    final remainingAmount = (invoice.finalAmount - invoice.amountPaid)
        .clamp(0, invoice.finalAmount)
        .toDouble();

    return CustomCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(sizeConstants.spacingSmall),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InvoiceDateLeading(date: invoice.issueDate),
              SizedBox(width: sizeConstants.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contactName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: sizeConstants.spacingXXSmall),
                    Text(
                      '${invoiceType.label} ${invoice.invoiceNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: sizeConstants.spacingSmall),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppNumberFormatter.formatAmount(invoice.finalAmount),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: sizeConstants.spacingXXSmall),
                  Text(
                    '${LocaleKeys.remaining.tr()}: ${AppNumberFormatter.formatAmount(remainingAmount)}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvoiceDateLeading extends StatelessWidget {
  const _InvoiceDateLeading({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final jalaliDate = Jalali.fromDateTime(date);

    return Container(
      width: sizeConstants.avatarSmall,
      padding: EdgeInsets.symmetric(vertical: sizeConstants.spacingXSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
      ),
      child: Column(
        children: [
          Text(
            jalaliDate.year.toString(),
            style: textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: sizeConstants.spacingXXSmall),
          Text(
            jalaliDate.day.toString().padLeft(2, '0'),
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            jalaliDate.formatter.mNAf,
            style: textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceDetailsSheet extends ConsumerWidget {
  const _InvoiceDetailsSheet({required this.invoiceId});

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
              return _StateContent(
                icon: Icons.error_outline,
                title: LocaleKeys.failedToLoadInvoices.tr(),
              );
            }

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
                    '${_invoiceTypeFromName(details.invoice.type).label} ${details.invoice.invoiceNumber}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  SizedBox(height: sizeConstants.spacingSmall),
                  Text(
                    '${LocaleKeys.total.tr()}: ${AppNumberFormatter.formatAmount(details.invoice.finalAmount)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${LocaleKeys.amountPaid.tr()}: ${AppNumberFormatter.formatAmount(details.invoice.amountPaid)}',
                  ),
                  Text(
                    '${LocaleKeys.remaining.tr()}: ${AppNumberFormatter.formatAmount((details.invoice.finalAmount - details.invoice.amountPaid).clamp(0, details.invoice.finalAmount).toDouble())}',
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product?.name ?? LocaleKeys.product.tr(),
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                SizedBox(height: sizeConstants.spacingXXSmall),
                                Text(
                                  '${_displayInvoiceItemQuantity(item)} x ${AppNumberFormatter.formatAmount(item.item.unitPrice)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
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
                                          _formatDate(
                                            context,
                                            payment.recordedAt,
                                          ),
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
          error: (error, stackTrace) => _StateContent(
            icon: Icons.error_outline,
            title: LocaleKeys.failedToLoadInvoices.tr(),
          ),
        ),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: sizeConstants.iconXLarge,
          color: Theme.of(context).hintColor,
        ),
        SizedBox(height: sizeConstants.spacingSmall),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

enum _InvoiceAction { edit, payment, details, delete }

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
  if (value == 'partial') return PaymentStatus.partialPaid;
  return PaymentStatus.unpaid;
}

String _statusNameForAmounts({
  required double totalAmount,
  required double amountPaid,
}) {
  if (amountPaid <= 0) return PaymentStatus.unpaid.name;
  if (amountPaid >= totalAmount) return PaymentStatus.paid.name;
  return PaymentStatus.partialPaid.name;
}

String _formatDate(BuildContext context, DateTime date) {
  if (appLocaleHelper.isCurrentLanguageEnglish(context)) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  final jalaliDate = Jalali.fromDateTime(date);
  final month = jalaliDate.month.toString().padLeft(2, '0');
  final day = jalaliDate.day.toString().padLeft(2, '0');
  return '$day/$month/${jalaliDate.year}';
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
