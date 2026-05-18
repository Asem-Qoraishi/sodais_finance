import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/features/transactions/application/providers/transaction_providers.dart';
import 'package:sodais_finance/features/transactions/domain/transaction_feed_entry.dart';
import 'package:sodais_finance/features/transactions/domain/transactions_repository.dart';
import 'package:sodais_finance/features/transactions/presentation/controllers/transactions_order_options.dart';
import 'package:sodais_finance/features/transactions/presentation/controllers/transactions_query_options.dart';

enum TransactionsSection { invoices, payments }

enum InvoiceSectionFilter { all, paid, unpaid, partialPaid, overdue }

enum PaymentSectionFilter { all, receipt, payment, openingBalance }

class TransactionsSectionNotifier extends Notifier<TransactionsSection> {
  @override
  TransactionsSection build() => TransactionsSection.invoices;

  void setSection(TransactionsSection section) {
    if (state == section) return;
    state = section;
  }
}

final transactionsSectionProvider =
    NotifierProvider<TransactionsSectionNotifier, TransactionsSection>(
      TransactionsSectionNotifier.new,
    );

class InvoiceSectionFilterNotifier extends Notifier<InvoiceSectionFilter> {
  @override
  InvoiceSectionFilter build() => InvoiceSectionFilter.all;

  void setFilter(InvoiceSectionFilter filter) {
    if (state == filter) return;
    state = filter;
  }
}

final invoiceSectionFilterProvider =
    NotifierProvider<InvoiceSectionFilterNotifier, InvoiceSectionFilter>(
      InvoiceSectionFilterNotifier.new,
    );

class PaymentSectionFilterNotifier extends Notifier<PaymentSectionFilter> {
  @override
  PaymentSectionFilter build() => PaymentSectionFilter.all;

  void setFilter(PaymentSectionFilter filter) {
    if (state == filter) return;
    state = filter;
  }
}

final paymentSectionFilterProvider =
    NotifierProvider<PaymentSectionFilterNotifier, PaymentSectionFilter>(
      PaymentSectionFilterNotifier.new,
    );

class TransactionsOrderOptionNotifier
    extends Notifier<TransactionsOrderOption> {
  @override
  TransactionsOrderOption build() => TransactionsOrderOption.newest;

  void setOrderOption(TransactionsOrderOption option) {
    if (state == option) return;
    state = option;
  }
}

final transactionsOrderOptionProvider =
    NotifierProvider<TransactionsOrderOptionNotifier, TransactionsOrderOption>(
      TransactionsOrderOptionNotifier.new,
    );

class TransactionSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) {
    if (state == query) return;
    state = query;
  }
}

final transactionSearchQueryProvider =
    NotifierProvider<TransactionSearchQueryNotifier, String>(
      TransactionSearchQueryNotifier.new,
    );

class TransactionsFeedFilterNotifier extends Notifier<TransactionFeedFilter> {
  @override
  TransactionFeedFilter build() => TransactionFeedFilter.all;

  void setFilter(TransactionFeedFilter filter) {
    if (state == filter) return;
    state = filter;
  }
}

final transactionsFeedFilterProvider =
    NotifierProvider<TransactionsFeedFilterNotifier, TransactionFeedFilter>(
      TransactionsFeedFilterNotifier.new,
    );

final transactionsControllerProvider =
    Provider<AsyncValue<List<TransactionFeedEntry>>>((ref) {
      final feedAsync = ref.watch(unifiedTransactionFeedProvider);
      final query = ref
          .watch(transactionSearchQueryProvider)
          .trim()
          .toLowerCase();
      final orderOption = ref.watch(transactionsOrderOptionProvider);

      return feedAsync.whenData((entries) {
        final filtered = entries
            .where((entry) => query.isEmpty || _matchesQuery(entry, query))
            .toList(growable: false);

        filtered.sort((a, b) => _compareEntries(a, b, orderOption));
        return filtered;
      });
    });

bool _matchesQuery(TransactionFeedEntry entry, String query) {
  final haystacks = <String>[
    entry.invoiceNumber ?? '',
    entry.contactName ?? '',
    entry.description ?? '',
    entry.referenceType,
    entry.entryType,
    entry.status ?? '',
  ];

  for (final haystack in haystacks) {
    if (haystack.toLowerCase().contains(query)) return true;
  }
  return false;
}

int _compareEntries(
  TransactionFeedEntry a,
  TransactionFeedEntry b,
  TransactionsOrderOption orderOption,
) {
  switch (orderOption) {
    case TransactionsOrderOption.newest:
      final dateCompare = b.occurredAt.compareTo(a.occurredAt);
      return dateCompare != 0 ? dateCompare : b.id.compareTo(a.id);
    case TransactionsOrderOption.oldest:
      final dateCompare = a.occurredAt.compareTo(b.occurredAt);
      return dateCompare != 0 ? dateCompare : a.id.compareTo(b.id);
    case TransactionsOrderOption.highestAmount:
      final amountCompare = b.amount.compareTo(a.amount);
      return amountCompare != 0
          ? amountCompare
          : b.occurredAt.compareTo(a.occurredAt);
    case TransactionsOrderOption.lowestAmount:
      final amountCompare = a.amount.compareTo(b.amount);
      return amountCompare != 0
          ? amountCompare
          : b.occurredAt.compareTo(a.occurredAt);
  }
}

bool isPaymentEntry(TransactionFeedEntry entry) {
  return !entry.isInvoice &&
      entry.referenceType != invoicePrincipalReferenceType &&
      entry.referenceType != invoicePaymentReferenceType;
}
