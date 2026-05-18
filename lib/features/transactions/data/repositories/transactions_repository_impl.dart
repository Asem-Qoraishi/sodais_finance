import 'package:sodais_finance/features/transactions/data/local/transactions_drift_store.dart';
import 'package:sodais_finance/features/transactions/domain/transaction_feed_entry.dart';
import 'package:sodais_finance/features/transactions/domain/transactions_repository.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  TransactionsRepositoryImpl(this._store);

  final TransactionsDriftStore _store;

  @override
  Stream<List<TransactionFeedEntry>> watchUnifiedFeed() {
    return _store.watchUnifiedFeed();
  }

  @override
  Future<List<InvoiceLedgerPaymentRecord>> getInvoicePayments(int invoiceId) {
    return _store.getInvoicePayments(invoiceId);
  }

  @override
  Future<void> syncInvoiceLedger(InvoiceLedgerSyncRequest request) {
    return _store.syncInvoiceLedger(request);
  }

  @override
  Future<void> deleteInvoiceLedgerEntries(int invoiceId) {
    return _store.deleteInvoiceLedgerEntries(invoiceId);
  }

  @override
  Future<void> recordOpeningBalance(OpeningBalanceEntryRequest request) {
    return _store.recordOpeningBalance(request);
  }

  @override
  Future<void> recordManualTransaction(ManualTransactionRequest request) {
    return _store.recordManualTransaction(request);
  }
}
