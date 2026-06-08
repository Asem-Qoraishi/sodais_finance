import 'dart:math' as math;

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
import 'package:sodais_finance/core/widgets/actions/quick_action_buttons.dart';
import 'package:sodais_finance/core/widgets/cards/custom_card.dart';
import 'package:sodais_finance/core/widgets/filters/filter_chip_bar.dart';
import 'package:sodais_finance/core/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:sodais_finance/features/app/data/app_database.dart';
import 'package:sodais_finance/features/invoices/application/providers/invoice_providers.dart';
import 'package:sodais_finance/features/invoices/presentation/controllers/invoice_form_state.dart';
import 'package:sodais_finance/features/invoices/presentation/widgets/invoice_details_sheet.dart';
import 'package:sodais_finance/features/transactions/application/providers/transaction_providers.dart';
import 'package:sodais_finance/features/transactions/domain/transaction_feed_entry.dart';
import 'package:sodais_finance/features/transactions/domain/transactions_repository.dart';
import 'package:sodais_finance/features/transactions/presentation/controllers/transactions_controller.dart';
import 'package:sodais_finance/features/transactions/presentation/widgets/transactions_order_by.dart';
import 'package:sodais_finance/features/transactions/presentation/widgets/transactions_search_field.dart';

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

  void _onActionSelected(BuildContext context, QuickActionType action) {
    switch (action) {
      case QuickActionType.newSale:
        context.push('/${routeNames.addNewSale}');
        break;
      case QuickActionType.newPurchase:
        context.push('/${routeNames.addNewPurchase}');
        break;
      case QuickActionType.receive:
        context.push('/${routeNames.addNewReceipt}');
        break;
      case QuickActionType.payment:
        context.push('/${routeNames.addNewPayment}');
        break;
      case QuickActionType.newExpense:
        context.push('/${routeNames.addNewPayment}');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(transactionsControllerProvider);
    final selectedSection = ref.watch(transactionsSectionProvider);
    final invoiceFilter = ref.watch(invoiceSectionFilterProvider);
    final paymentFilter = ref.watch(paymentSectionFilterProvider);

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
      floatingActionButton: QuickActionButtons(
        actions: const [
          QuickActionType.newSale,
          QuickActionType.newPurchase,
          QuickActionType.receive,
          QuickActionType.payment,
        ],
        onActionSelected: (action) => _onActionSelected(context, action),
      ),
      body: Padding(
        padding: EdgeInsets.all(sizeConstants.spacingSmall),
        child: feedAsync.when(
          data: (entries) {
            final invoices = entries.where((entry) => entry.isInvoice).toList();
            final payments = entries.where(isPaymentEntry).toList();
            final filteredInvoices = _applyInvoiceSectionFilter(
              invoices,
              invoiceFilter,
            );
            final filteredPayments = _applyPaymentSectionFilter(
              payments,
              paymentFilter,
            );
            final visibleEntries =
                selectedSection == TransactionsSection.invoices
                ? filteredInvoices
                : filteredPayments;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: sizeConstants.spacingSmall,
                  children: [
                    _TransactionsSectionSwitcher(
                      selectedSection: selectedSection,
                      invoiceCount: invoices.length,
                      paymentCount: payments.length,
                      onSelected: (section) => ref
                          .read(transactionsSectionProvider.notifier)
                          .setSection(section),
                    ),
                    const TransactionsSearchField(),
                    if (selectedSection == TransactionsSection.invoices)
                      _InvoiceSectionFilterBar(
                        selectedFilter: invoiceFilter,
                        onSelected: ref
                            .read(invoiceSectionFilterProvider.notifier)
                            .setFilter,
                      )
                    else
                      _PaymentSectionFilterBar(
                        selectedFilter: paymentFilter,
                        onSelected: ref
                            .read(paymentSectionFilterProvider.notifier)
                            .setFilter,
                      ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        LocaleKeys.resultsCount.tr(
                          namedArgs: {
                            'count': visibleEntries.length.toString(),
                          },
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).hintColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const TransactionsOrderBy(),
                  ],
                ),
                Expanded(
                  child: visibleEntries.isEmpty
                      ? _EmptyTransactionsState(section: selectedSection)
                      : ListView.separated(
                          padding: EdgeInsets.only(
                            bottom: sizeConstants.spacingXXLarge,
                          ),
                          itemCount: visibleEntries.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: sizeConstants.spacingSmall),
                          itemBuilder: (context, index) {
                            final entry = visibleEntries[index];

                            if (selectedSection ==
                                TransactionsSection.invoices) {
                              return _InvoiceCard(
                                entry: entry,
                                onTap: () => _openInvoiceActions(
                                  context,
                                  ref,
                                  entry: entry,
                                ),
                              );
                            }

                            return _PaymentCard(entry: entry, onTap: null);
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

  // ignore: unused_element
  Future<void> _showInvoicePaymentsSheet(
    BuildContext context, {
    required TransactionFeedEntry entry,
    required List<TransactionFeedEntry> allEntries,
  }) {
    final linkedPayments =
        allEntries
            .where(
              (item) =>
                  item.referenceType == invoicePaymentReferenceType &&
                  item.referenceId == entry.referenceId,
            )
            .toList(growable: false)
          ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _InvoicePaymentsSheet(
        entry: entry,
        linkedPayments: linkedPayments,
        onOpenInvoice: () => _openLinkedInvoice(context, entry),
      ),
    );
  }

  Future<void> _openInvoiceActions(
    BuildContext context,
    WidgetRef ref, {
    required TransactionFeedEntry entry,
  }) async {
    final paymentStatus = _paymentStatusFromName(entry.status);
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
            if (paymentStatus != PaymentStatus.paid)
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
        _openLinkedInvoice(context, entry);
        return;
      case _InvoiceAction.payment:
        _openLinkedInvoice(context, entry);
        return;
      case _InvoiceAction.details:
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => InvoiceDetailsSheet(invoiceId: entry.referenceId),
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
          await ref.read(invoiceDaoProvider).deleteInvoice(entry.referenceId);
          await ref
              .read(deleteInvoiceLedgerEntriesUseCaseProvider)
              .call(entry.referenceId);
        });
        ref.invalidate(unifiedTransactionFeedProvider);
        ref.invalidate(invoiceSummaryListProvider);
        return;
    }
  }
}

enum _InvoiceAction { edit, payment, details, delete }

class _TransactionsSectionSwitcher extends StatelessWidget {
  const _TransactionsSectionSwitcher({
    required this.selectedSection,
    required this.invoiceCount,
    required this.paymentCount,
    required this.onSelected,
  });

  final TransactionsSection selectedSection;
  final int invoiceCount;
  final int paymentCount;
  final ValueChanged<TransactionsSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(sizeConstants.spacingXXSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(sizeConstants.radiusLarge),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SectionChip(
              label: LocaleKeys.invoices.tr(),
              count: invoiceCount,
              selected: selectedSection == TransactionsSection.invoices,
              onTap: () => onSelected(TransactionsSection.invoices),
            ),
          ),
          SizedBox(width: sizeConstants.spacingXSmall),
          Expanded(
            child: _SectionChip(
              label: LocaleKeys.payment.tr(),
              count: paymentCount,
              selected: selectedSection == TransactionsSection.payments,
              onTap: () => onSelected(TransactionsSection.payments),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: sizeConstants.spacingSmall,
          vertical: sizeConstants.spacingSmall,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
          color: selected ? colorScheme.primary : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: selected ? colorScheme.onPrimary : null,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(width: sizeConstants.spacingXSmall),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: sizeConstants.spacingXSmall,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? colorScheme.onPrimary.withValues(alpha: 0.14)
                    : colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(sizeConstants.radiusMax),
              ),
              child: Text(
                '$count',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? colorScheme.onPrimary : colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceSectionFilterBar extends StatelessWidget {
  const _InvoiceSectionFilterBar({
    required this.selectedFilter,
    required this.onSelected,
  });

  final InvoiceSectionFilter selectedFilter;
  final ValueChanged<InvoiceSectionFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChipBar<InvoiceSectionFilter>(
      selectedValue: selectedFilter,
      onSelected: onSelected,
      options: InvoiceSectionFilter.values
          .map(
            (filter) =>
                FilterChipOption(value: filter, label: filter.name.tr()),
          )
          .toList(growable: false),
    );
  }
}

class _PaymentSectionFilterBar extends StatelessWidget {
  const _PaymentSectionFilterBar({
    required this.selectedFilter,
    required this.onSelected,
  });

  final PaymentSectionFilter selectedFilter;
  final ValueChanged<PaymentSectionFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChipBar<PaymentSectionFilter>(
      selectedValue: selectedFilter,
      onSelected: onSelected,
      options: PaymentSectionFilter.values
          .map(
            (filter) =>
                FilterChipOption(value: filter, label: filter.name.tr()),
          )
          .toList(growable: false),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.entry, this.onTap});

  final TransactionFeedEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final amountPaid = entry.amountPaid ?? 0;
    final remaining = math.max(0.0, entry.amount - amountPaid).toDouble();
    final invoiceType = _invoiceTypeFromName(entry.entryType);

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
              _InvoiceDateBadge(date: entry.occurredAt),
              SizedBox(width: sizeConstants.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _invoiceContactName(context, entry),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: sizeConstants.spacingXXSmall),
                    Text(
                      _invoiceCardSubtitle(entry, invoiceType),
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
                    _MoneyText.format(entry.amount),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: sizeConstants.spacingXXSmall),
                  Text(
                    '${LocaleKeys.remaining.tr()}: ${_MoneyText.format(remaining)}',
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

class _InvoiceDateBadge extends StatelessWidget {
  const _InvoiceDateBadge({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
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
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: sizeConstants.spacingXXSmall),
          Text(
            jalaliDate.day.toString().padLeft(2, '0'),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            jalaliDate.formatter.mNAf,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _InvoicePaymentsSheet extends StatelessWidget {
  const _InvoicePaymentsSheet({
    required this.entry,
    required this.linkedPayments,
    required this.onOpenInvoice,
  });

  final TransactionFeedEntry entry;
  final List<TransactionFeedEntry> linkedPayments;
  final VoidCallback onOpenInvoice;

  @override
  Widget build(BuildContext context) {
    final amountPaid = linkedPayments.fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );
    final remaining = math.max(0.0, entry.amount - amountPaid).toDouble();

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            sizeConstants.spacingMedium,
            sizeConstants.spacingSmall,
            sizeConstants.spacingMedium,
            sizeConstants.spacingMedium,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _invoiceNumber(entry),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              SizedBox(height: sizeConstants.spacingXXSmall),
              Text(
                _invoiceContactName(context, entry),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
              SizedBox(height: sizeConstants.spacingSmall),
              Wrap(
                spacing: sizeConstants.spacingXSmall,
                runSpacing: sizeConstants.spacingXSmall,
                children: [
                  _SoftTag(
                    icon: Icons.receipt_long_outlined,
                    label:
                        '${LocaleKeys.total.tr()}: ${_MoneyText.format(entry.amount)}',
                    color: const Color(0xFF196BDE),
                  ),
                  _SoftTag(
                    icon: Icons.payments_outlined,
                    label:
                        '${LocaleKeys.amountPaid.tr()}: ${_MoneyText.format(amountPaid)}',
                    color: const Color(0xFF1A9B72),
                  ),
                  _SoftTag(
                    icon: Icons.account_balance_wallet_outlined,
                    label:
                        '${LocaleKeys.remaining.tr()}: ${_MoneyText.format(remaining)}',
                    color: _paymentStatusColor(
                      context,
                      _paymentStatusFromName(entry.status),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sizeConstants.spacingMedium),
              Text(
                LocaleKeys.details.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: sizeConstants.spacingSmall),
              if (linkedPayments.isEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: sizeConstants.spacingMedium),
                  child: Text(
                    LocaleKeys.noTransactionsFound.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: linkedPayments.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: sizeConstants.spacingSmall),
                    itemBuilder: (context, index) {
                      final payment = linkedPayments[index];
                      return CustomCard(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.all(sizeConstants.spacingMedium),
                        child: Row(
                          children: [
                            Container(
                              width: sizeConstants.avatarXSmall,
                              height: sizeConstants.avatarXSmall,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1A9B72,
                                ).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                  sizeConstants.radiusMedium,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.payments_outlined,
                                color: Color(0xFF1A9B72),
                              ),
                            ),
                            SizedBox(width: sizeConstants.spacingSmall),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _MoneyText.format(payment.amount),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  SizedBox(
                                    height: sizeConstants.spacingXXSmall,
                                  ),
                                  Text(
                                    _DateText.formatWithTime(
                                      context,
                                      payment.occurredAt,
                                    ),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context).hintColor,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: sizeConstants.spacingMedium),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onOpenInvoice();
                  },
                  child: Text(LocaleKeys.editInvoice.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.entry, this.onTap});

  final TransactionFeedEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = _paymentEntryColor(context, entry);
    final invoiceNumber = entry.invoiceNumber?.trim();

    return CustomCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(sizeConstants.spacingMedium),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: sizeConstants.avatarXSmall,
                height: sizeConstants.avatarXSmall,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    sizeConstants.radiusMedium,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _paymentEntryIcon(entry),
                  color: accentColor,
                  size: sizeConstants.iconMedium,
                ),
              ),
              SizedBox(width: sizeConstants.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _paymentTitle(context, entry),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: sizeConstants.spacingXXSmall),
                    Text(
                      _paymentSubtitle(context, entry),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).hintColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: sizeConstants.spacingSmall),
              Text(
                _MoneyText.format(entry.amount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: sizeConstants.spacingSmall),
          Row(
            children: [
              _MetaLabel(
                icon: Icons.event_outlined,
                text: _DateText.formatLong(context, entry.occurredAt),
              ),
              if (invoiceNumber != null && invoiceNumber.isNotEmpty) ...[
                SizedBox(width: sizeConstants.spacingSmall),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _SoftTag(
                      icon: Icons.receipt_long_outlined,
                      label: invoiceNumber,
                      color: const Color(0xFF196BDE),
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
}

class _EmptyTransactionsState extends StatelessWidget {
  const _EmptyTransactionsState({required this.section});

  final TransactionsSection section;

  @override
  Widget build(BuildContext context) {
    final isInvoices = section == TransactionsSection.invoices;
    final icon = isInvoices
        ? Icons.receipt_long_outlined
        : Icons.payments_outlined;
    final title = isInvoices
        ? LocaleKeys.invoices.tr()
        : LocaleKeys.payment.tr();

    return Center(
      child: Padding(
        padding: EdgeInsets.all(sizeConstants.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: sizeConstants.imageSmall,
              height: sizeConstants.imageSmall,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: sizeConstants.iconLarge,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: sizeConstants.spacingSmall),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: sizeConstants.spacingXXSmall),
            Text(
              LocaleKeys.noTransactionsFound.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _StatusDotPill extends StatelessWidget {
  const _StatusDotPill({required this.label, required this.color});

  final String label;
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
        borderRadius: BorderRadius.circular(sizeConstants.radiusMax),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: sizeConstants.spacingXXSmall),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftTag extends StatelessWidget {
  const _SoftTag({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizeConstants.spacingXSmall,
        vertical: sizeConstants.spacingXXSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(sizeConstants.radiusMax),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: sizeConstants.iconSmall, color: color),
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

class _MetaLabel extends StatelessWidget {
  const _MetaLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: sizeConstants.iconSmall,
          color: Theme.of(context).hintColor,
        ),
        SizedBox(width: sizeConstants.spacingXXSmall),
        Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MoneyText {
  static String format(double value) {
    return AppNumberFormatter.formatAmount(value);
  }
}

class _DateText {
  // ignore: unused_element
  static String formatShort(BuildContext context, DateTime date) {
    if (appLocaleHelper.isCurrentLanguageEnglish(context)) {
      return DateFormat('dd/MM/yyyy').format(date);
    }

    final jalaliDate = Jalali.fromDateTime(date);
    final month = jalaliDate.month.toString().padLeft(2, '0');
    final day = jalaliDate.day.toString().padLeft(2, '0');
    return '$day/$month/${jalaliDate.year}';
  }

  static String formatLong(BuildContext context, DateTime date) {
    if (appLocaleHelper.isCurrentLanguageEnglish(context)) {
      return DateFormat('d MMM yyyy').format(date);
    }

    final jalaliDate = Jalali.fromDateTime(date);
    return '${jalaliDate.day} ${jalaliDate.formatter.mN} ${jalaliDate.year}';
  }

  static String formatWithTime(BuildContext context, DateTime date) {
    if (appLocaleHelper.isCurrentLanguageEnglish(context)) {
      return DateFormat('d MMM yyyy • hh:mm a').format(date);
    }

    final jalaliDate = Jalali.fromDateTime(date);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${jalaliDate.day} ${jalaliDate.formatter.mN} ${jalaliDate.year} • $hour:$minute';
  }
}

String _invoiceContactName(BuildContext context, TransactionFeedEntry entry) {
  final contactName = entry.contactName?.trim();
  if (contactName != null && contactName.isNotEmpty) {
    return contactName;
  }
  return LocaleKeys.unknownContact.tr();
}

String _invoiceNumber(TransactionFeedEntry entry) {
  final invoiceNumber = entry.invoiceNumber?.trim();
  if (invoiceNumber == null || invoiceNumber.isEmpty) {
    return '#${entry.referenceId}';
  }
  return '#$invoiceNumber';
}

String _invoiceCardSubtitle(
  TransactionFeedEntry entry,
  InvoiceType invoiceType,
) {
  final invoiceNumber = entry.invoiceNumber?.trim();
  if (invoiceNumber != null && invoiceNumber.isNotEmpty) {
    return '${invoiceType.label} $invoiceNumber';
  }

  return '${invoiceType.label} ${entry.referenceId}';
}

String _paymentTitle(BuildContext context, TransactionFeedEntry entry) {
  return switch (entry.referenceType) {
    invoicePaymentReferenceType => LocaleKeys.invoicePayment.tr(),
    openingBalanceReferenceType => LocaleKeys.openingBalance.tr(),
    manualReferenceType => switch (entry.entryType) {
      'income' => LocaleKeys.receipt.tr(),
      'expense' => LocaleKeys.payment.tr(),
      _ => LocaleKeys.manualEntry.tr(),
    },
    _ => LocaleKeys.transactions.tr(),
  };
}

String _paymentSubtitle(BuildContext context, TransactionFeedEntry entry) {
  final contactName = entry.contactName?.trim();
  final invoiceNumber = entry.invoiceNumber?.trim();
  final description = entry.description?.trim();

  if (entry.referenceType == invoicePaymentReferenceType &&
      invoiceNumber != null &&
      invoiceNumber.isNotEmpty) {
    final contact = contactName?.isNotEmpty == true ? ' • $contactName' : '';
    return '${LocaleKeys.linkedInvoice.tr()}: $invoiceNumber$contact';
  }

  if (contactName?.isNotEmpty == true && description?.isNotEmpty == true) {
    return '$contactName • $description';
  }

  if (contactName?.isNotEmpty == true) {
    return contactName!;
  }

  if (description?.isNotEmpty == true) {
    return description!;
  }

  return LocaleKeys.details.tr();
}

IconData _paymentEntryIcon(TransactionFeedEntry entry) {
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

Color _paymentEntryColor(BuildContext context, TransactionFeedEntry entry) {
  return switch (entry.referenceType) {
    invoicePaymentReferenceType => const Color(0xFF196BDE),
    openingBalanceReferenceType => const Color(0xFF7C5CFA),
    _ => switch (entry.entryType) {
      'income' => const Color(0xFF1A9B72),
      'expense' => const Color(0xFFE0594F),
      'transfer' => const Color(0xFF5A6B85),
      _ => Theme.of(context).colorScheme.primary,
    },
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
  if (value == 'partial') return PaymentStatus.partialPaid;
  return PaymentStatus.unpaid;
}

Color _paymentStatusColor(BuildContext context, PaymentStatus status) {
  return switch (status) {
    PaymentStatus.paid => const Color(0xFF1A9B72),
    PaymentStatus.unpaid => Theme.of(context).colorScheme.error,
    PaymentStatus.partialPaid => const Color(0xFFC2822E),
  };
}

List<TransactionFeedEntry> _applyInvoiceSectionFilter(
  List<TransactionFeedEntry> entries,
  InvoiceSectionFilter filter,
) {
  final now = DateTime.now();
  return entries
      .where((entry) {
        final status = _paymentStatusFromName(entry.status);
        return switch (filter) {
          InvoiceSectionFilter.all => true,
          InvoiceSectionFilter.paid => status == PaymentStatus.paid,
          InvoiceSectionFilter.unpaid =>
            status == PaymentStatus.unpaid ||
                status == PaymentStatus.partialPaid,
          InvoiceSectionFilter.overdue => _isOverdueInvoice(entry, now),
        };
      })
      .toList(growable: false);
}

List<TransactionFeedEntry> _applyPaymentSectionFilter(
  List<TransactionFeedEntry> entries,
  PaymentSectionFilter filter,
) {
  return entries
      .where((entry) {
        return switch (filter) {
          PaymentSectionFilter.all => true,
          PaymentSectionFilter.receipt => entry.entryType == 'income',
          PaymentSectionFilter.payment => entry.entryType == 'expense',
          PaymentSectionFilter.openingBalance =>
            entry.referenceType == openingBalanceReferenceType,
        };
      })
      .toList(growable: false);
}

bool _isOverdueInvoice(TransactionFeedEntry entry, DateTime now) {
  final dueDate = entry.dueDate;
  if (dueDate == null) return false;
  if (_paymentStatusFromName(entry.status) == PaymentStatus.paid) return false;

  final today = DateTime(now.year, now.month, now.day);
  final invoiceDueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
  return invoiceDueDate.isBefore(today);
}
