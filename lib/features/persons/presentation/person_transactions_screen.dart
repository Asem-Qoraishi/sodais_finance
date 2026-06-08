import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/utils/formatters/app_number_formatter.dart';
import 'package:sodais_finance/core/utils/helpers/app_locale_helper.dart';
import 'package:sodais_finance/core/widgets/cards/custom_card.dart';
import 'package:sodais_finance/features/invoices/application/providers/invoice_providers.dart';
import 'package:sodais_finance/features/invoices/data/local/dao/invoice_dao.dart';
import 'package:sodais_finance/features/invoices/presentation/controllers/invoice_form_state.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/transactions/application/providers/transaction_providers.dart';
import 'package:sodais_finance/features/transactions/domain/transaction_feed_entry.dart';
import 'package:sodais_finance/features/transactions/domain/transactions_repository.dart';

enum _PersonTransactionFilter { all, sales, purchases, receipts, payments }

class PersonTransactionsScreen extends ConsumerStatefulWidget {
  const PersonTransactionsScreen({super.key, required this.person});

  final Person person;

  @override
  ConsumerState<PersonTransactionsScreen> createState() =>
      _PersonTransactionsScreenState();
}

class _PersonTransactionsScreenState
    extends ConsumerState<PersonTransactionsScreen> {
  _PersonTransactionFilter _selectedFilter = _PersonTransactionFilter.all;

  @override
  Widget build(BuildContext context) {
    final invoiceAsync = ref.watch(invoiceSummaryListProvider);
    final feedAsync = ref.watch(unifiedTransactionFeedProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.person.name)),
      body: invoiceAsync.when(
        data: (invoices) {
          return feedAsync.when(
            data: (entries) {
              final personInvoices = invoices
                  .where(
                    (entry) =>
                        entry.invoice.contactId.toString() == widget.person.id,
                  )
                  .toList(growable: false);
              final personTransactions = entries
                  .where(
                    (entry) =>
                        entry.contactId?.toString() == widget.person.id &&
                        !entry.isInvoice,
                  )
                  .toList(growable: false);
              final timeline = _buildTimeline(
                invoices: personInvoices,
                transactions: personTransactions,
              );
              final filteredTimeline = timeline
                  .where(_matchesSelectedFilter)
                  .toList(growable: false);

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  sizeConstants.spacingMedium,
                  sizeConstants.spacingMedium,
                  sizeConstants.spacingMedium,
                  sizeConstants.spacingXXLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PersonSummaryCards(
                      person: widget.person,
                      invoices: personInvoices,
                    ),
                    SizedBox(height: sizeConstants.spacingMedium),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _PersonTransactionFilter.values
                            .map(
                              (filter) => Padding(
                                padding: EdgeInsets.only(
                                  right: sizeConstants.spacingXSmall,
                                ),
                                child: ChoiceChip(
                                  label: Text(_filterLabel(filter)),
                                  selected: _selectedFilter == filter,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedFilter = filter;
                                    });
                                  },
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                    SizedBox(height: sizeConstants.spacingMedium),
                    Text(
                      LocaleKeys.recentActivities.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: sizeConstants.spacingSmall),
                    if (filteredTimeline.isEmpty)
                      const _EmptyState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTimeline.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: sizeConstants.spacingSmall),
                        itemBuilder: (context, index) {
                          final item = filteredTimeline[index];
                          return switch (item) {
                            _PersonTimelineInvoiceEntry() => _PersonInvoiceCard(
                              summary: item.summary,
                            ),
                            _PersonTimelinePaymentEntry() => _PersonPaymentCard(
                              entry: item.entry,
                            ),
                          };
                        },
                      ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => const _EmptyState(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const _EmptyState(),
      ),
    );
  }

  List<_PersonTimelineEntry> _buildTimeline({
    required List<InvoiceSummary> invoices,
    required List<TransactionFeedEntry> transactions,
  }) {
    final timeline = <_PersonTimelineEntry>[
      ...invoices.map(_PersonTimelineInvoiceEntry.new),
      ...transactions.map(_PersonTimelinePaymentEntry.new),
    ];

    timeline.sort((a, b) {
      final byDate = b.occurredAt.compareTo(a.occurredAt);
      if (byDate != 0) return byDate;
      return b.sortId.compareTo(a.sortId);
    });

    return timeline;
  }

  bool _matchesSelectedFilter(_PersonTimelineEntry item) {
    return switch (_selectedFilter) {
      _PersonTransactionFilter.all => true,
      _PersonTransactionFilter.sales =>
        item is _PersonTimelineInvoiceEntry &&
            item.summary.invoice.type == InvoiceType.sale.name,
      _PersonTransactionFilter.purchases =>
        item is _PersonTimelineInvoiceEntry &&
            item.summary.invoice.type == InvoiceType.purchase.name,
      _PersonTransactionFilter.receipts =>
        item is _PersonTimelinePaymentEntry && item.entry.entryType == 'income',
      _PersonTransactionFilter.payments =>
        item is _PersonTimelinePaymentEntry &&
            item.entry.entryType == 'expense',
    };
  }

  String _filterLabel(_PersonTransactionFilter filter) {
    return switch (filter) {
      _PersonTransactionFilter.all => LocaleKeys.all.tr(),
      _PersonTransactionFilter.sales => LocaleKeys.sale.tr(),
      _PersonTransactionFilter.purchases => LocaleKeys.purchase.tr(),
      _PersonTransactionFilter.receipts => LocaleKeys.receipt.tr(),
      _PersonTransactionFilter.payments => LocaleKeys.payment.tr(),
    };
  }
}

sealed class _PersonTimelineEntry {
  const _PersonTimelineEntry({required this.occurredAt, required this.sortId});

  final DateTime occurredAt;
  final int sortId;
}

class _PersonTimelineInvoiceEntry extends _PersonTimelineEntry {
  _PersonTimelineInvoiceEntry(this.summary)
    : super(occurredAt: summary.invoice.issueDate, sortId: summary.invoice.id);

  final InvoiceSummary summary;
}

class _PersonTimelinePaymentEntry extends _PersonTimelineEntry {
  _PersonTimelinePaymentEntry(this.entry)
    : super(occurredAt: entry.occurredAt, sortId: entry.id);

  final TransactionFeedEntry entry;
}

class _PersonSummaryCards extends StatelessWidget {
  const _PersonSummaryCards({required this.person, required this.invoices});

  final Person person;
  final List<InvoiceSummary> invoices;

  @override
  Widget build(BuildContext context) {
    final totalSales = invoices
        .where((invoice) => invoice.invoice.type == InvoiceType.sale.name)
        .fold<double>(0, (sum, invoice) => sum + invoice.invoice.finalAmount);
    final totalPurchases = invoices
        .where((invoice) => invoice.invoice.type == InvoiceType.purchase.name)
        .fold<double>(0, (sum, invoice) => sum + invoice.invoice.finalAmount);
    final balanceColor = person.balance >= 0
        ? const Color(0xFF1A9B72)
        : Theme.of(context).colorScheme.error;

    return Column(
      children: [
        CustomCard(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.all(sizeConstants.spacingMedium),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.netBalance.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                SizedBox(height: sizeConstants.spacingXSmall),
                Text(
                  AppNumberFormatter.formatAmount(person.balance.abs()),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: balanceColor,
                  ),
                ),
                SizedBox(height: sizeConstants.spacingXSmall),
                Text(
                  person.balance >= 0
                      ? LocaleKeys.toCollect.tr()
                      : LocaleKeys.toPay.tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: balanceColor),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: sizeConstants.spacingSmall),
        Row(
          children: [
            Expanded(
              child: _SummaryMiniCard(
                title: LocaleKeys.sale.tr(),
                amount: totalSales,
                color: const Color(0xFF196BDE),
                icon: Icons.arrow_downward_rounded,
              ),
            ),
            SizedBox(width: sizeConstants.spacingSmall),
            Expanded(
              child: _SummaryMiniCard(
                title: LocaleKeys.purchase.tr(),
                amount: totalPurchases,
                color: const Color(0xFFE0594F),
                icon: Icons.arrow_upward_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryMiniCard extends StatelessWidget {
  const _SummaryMiniCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(sizeConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: sizeConstants.avatarXSmall,
                height: sizeConstants.avatarXSmall,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: sizeConstants.iconSmall, color: color),
              ),
              SizedBox(width: sizeConstants.spacingXSmall),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: sizeConstants.spacingSmall),
          Text(
            AppNumberFormatter.formatAmount(amount),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _PersonInvoiceCard extends ConsumerWidget {
  const _PersonInvoiceCard({required this.summary});

  final InvoiceSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(invoiceDetailsProvider(summary.invoice.id));
    final invoiceType = _invoiceTypeFromName(summary.invoice.type);
    final amountColor = invoiceType == InvoiceType.purchase
        ? const Color(0xFFE0594F)
        : const Color(0xFF1A9B72);
    final remaining = (summary.invoice.finalAmount - summary.invoice.amountPaid)
        .clamp(0, summary.invoice.finalAmount)
        .toDouble();

    return CustomCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(sizeConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EntryIcon(
                icon: invoiceType == InvoiceType.purchase
                    ? Icons.shopping_cart_outlined
                    : Icons.receipt_long_outlined,
                color: amountColor,
              ),
              SizedBox(width: sizeConstants.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _invoiceCardTitle(invoiceType),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: sizeConstants.spacingXXSmall),
                    Text(
                      '${summary.invoice.invoiceNumber} • ${_formatDate(context, summary.invoice.issueDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: sizeConstants.spacingSmall),
              Text(
                AppNumberFormatter.formatAmount(summary.invoice.finalAmount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: amountColor,
                ),
              ),
            ],
          ),
          SizedBox(height: sizeConstants.spacingSmall),
          Text(
            '${LocaleKeys.remaining.tr()}: ${AppNumberFormatter.formatAmount(remaining)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
          SizedBox(height: sizeConstants.spacingSmall),
          detailsAsync.when(
            data: (details) {
              final items = details?.items ?? const <InvoiceDetailsItem>[];
              if (items.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(sizeConstants.spacingSmall),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(
                    sizeConstants.radiusSmall,
                  ),
                ),
                child: Column(
                  children: items
                      .map(
                        (item) => Padding(
                          padding: EdgeInsets.only(
                            bottom: item == items.last
                                ? 0
                                : sizeConstants.spacingXSmall,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product?.name ??
                                          LocaleKeys.product.tr(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    SizedBox(
                                      height: sizeConstants.spacingXXSmall,
                                    ),
                                    Text(
                                      '${_displayInvoiceItemQuantity(item)} × ${AppNumberFormatter.formatAmount(item.item.unitPrice)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context).hintColor,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: sizeConstants.spacingSmall),
                              Text(
                                AppNumberFormatter.formatAmount(
                                  item.item.totalPrice,
                                ),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _PersonPaymentCard extends StatelessWidget {
  const _PersonPaymentCard({required this.entry});

  final TransactionFeedEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = _paymentEntryColor(context, entry);

    return CustomCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(sizeConstants.spacingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EntryIcon(icon: _paymentEntryIcon(entry), color: color),
          SizedBox(width: sizeConstants.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _paymentTitle(entry),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: sizeConstants.spacingXXSmall),
                Text(
                  _paymentSubtitle(context, entry),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                SizedBox(height: sizeConstants.spacingXXSmall),
                Text(
                  _formatDate(context, entry.occurredAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: sizeConstants.spacingSmall),
          Text(
            AppNumberFormatter.formatAmount(entry.amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryIcon extends StatelessWidget {
  const _EntryIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sizeConstants.avatarSmall,
      height: sizeConstants.avatarSmall,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: sizeConstants.iconMedium),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(sizeConstants.spacingLarge),
      child: Center(
        child: Text(
          LocaleKeys.noTransactionsFound.tr(),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

InvoiceType _invoiceTypeFromName(String type) {
  return switch (type) {
    'purchase' => InvoiceType.purchase,
    'returned' => InvoiceType.returned,
    _ => InvoiceType.sale,
  };
}

String _invoiceCardTitle(InvoiceType type) {
  return switch (type) {
    InvoiceType.purchase =>
      '${LocaleKeys.purchase.tr()} ${LocaleKeys.invoices.tr()}',
    InvoiceType.returned => LocaleKeys.returned.tr(),
    InvoiceType.sale => '${LocaleKeys.sale.tr()} ${LocaleKeys.invoices.tr()}',
  };
}

String _paymentTitle(TransactionFeedEntry entry) {
  if (entry.referenceType == invoicePaymentReferenceType) {
    return LocaleKeys.invoicePayment.tr();
  }
  if (entry.referenceType == openingBalanceReferenceType) {
    return LocaleKeys.openingBalance.tr();
  }
  return entry.entryType == 'income'
      ? LocaleKeys.receipt.tr()
      : LocaleKeys.payment.tr();
}

String _paymentSubtitle(BuildContext context, TransactionFeedEntry entry) {
  final description = entry.description?.trim();
  final invoiceNumber = entry.invoiceNumber?.trim();

  if (entry.referenceType == invoicePaymentReferenceType &&
      invoiceNumber != null &&
      invoiceNumber.isNotEmpty) {
    return '${LocaleKeys.linkedInvoice.tr()}: $invoiceNumber';
  }

  if (description != null && description.isNotEmpty) {
    return description;
  }

  return LocaleKeys.details.tr();
}

IconData _paymentEntryIcon(TransactionFeedEntry entry) {
  return switch (entry.referenceType) {
    invoicePaymentReferenceType => Icons.payments_outlined,
    openingBalanceReferenceType => Icons.account_balance_wallet_outlined,
    _ =>
      entry.entryType == 'income'
          ? Icons.arrow_downward_rounded
          : Icons.arrow_upward_rounded,
  };
}

Color _paymentEntryColor(BuildContext context, TransactionFeedEntry entry) {
  return switch (entry.referenceType) {
    invoicePaymentReferenceType => const Color(0xFF196BDE),
    openingBalanceReferenceType => const Color(0xFF7C5CFA),
    _ =>
      entry.entryType == 'income'
          ? const Color(0xFF1A9B72)
          : Theme.of(context).colorScheme.error,
  };
}

String _formatDate(BuildContext context, DateTime date) {
  if (appLocaleHelper.isCurrentLanguageEnglish(context)) {
    return DateFormat('d MMM yyyy').format(date);
  }

  final jalaliDate = Jalali.fromDateTime(date);
  return '${jalaliDate.formatter.wN} ${jalaliDate.day} ${jalaliDate.formatter.mNAf} ${jalaliDate.year}';
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
