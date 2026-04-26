import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/features/app/data/app_database.dart';
import 'package:sodais_finance/features/transactions/application/use_cases/delete_invoice_ledger_entries_use_case.dart';
import 'package:sodais_finance/features/transactions/application/use_cases/record_opening_balance_use_case.dart';
import 'package:sodais_finance/features/transactions/application/use_cases/sync_invoice_ledger_use_case.dart';
import 'package:sodais_finance/features/transactions/application/use_cases/watch_unified_transaction_feed_use_case.dart';
import 'package:sodais_finance/features/transactions/data/local/transactions_drift_store.dart';
import 'package:sodais_finance/features/transactions/data/repositories/transactions_repository_impl.dart';
import 'package:sodais_finance/features/transactions/domain/transactions_repository.dart';

final transactionsDriftStoreProvider = Provider<TransactionsDriftStore>((ref) {
  return TransactionsDriftStore(ref.watch(appDatabaseProvider));
});

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepositoryImpl(ref.watch(transactionsDriftStoreProvider));
});

final watchUnifiedTransactionFeedUseCaseProvider =
    Provider<WatchUnifiedTransactionFeedUseCase>((ref) {
      return WatchUnifiedTransactionFeedUseCase(
        ref.watch(transactionsRepositoryProvider),
      );
    });

final syncInvoiceLedgerUseCaseProvider = Provider<SyncInvoiceLedgerUseCase>((
  ref,
) {
  return SyncInvoiceLedgerUseCase(ref.watch(transactionsRepositoryProvider));
});

final deleteInvoiceLedgerEntriesUseCaseProvider =
    Provider<DeleteInvoiceLedgerEntriesUseCase>((ref) {
      return DeleteInvoiceLedgerEntriesUseCase(
        ref.watch(transactionsRepositoryProvider),
      );
    });

final recordOpeningBalanceUseCaseProvider =
    Provider<RecordOpeningBalanceUseCase>((ref) {
      return RecordOpeningBalanceUseCase(
        ref.watch(transactionsRepositoryProvider),
      );
    });

final unifiedTransactionFeedProvider = StreamProvider((ref) {
  return ref.watch(watchUnifiedTransactionFeedUseCaseProvider).call();
});
