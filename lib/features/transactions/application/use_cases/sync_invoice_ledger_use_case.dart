import 'package:sodais_finance/features/transactions/domain/transactions_repository.dart';

class SyncInvoiceLedgerUseCase {
  const SyncInvoiceLedgerUseCase(this._repository);

  final TransactionsRepository _repository;

  Future<void> call(InvoiceLedgerSyncRequest request) {
    return _repository.syncInvoiceLedger(request);
  }
}
