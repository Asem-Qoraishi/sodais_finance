import 'package:sodais_finance/features/transactions/domain/transactions_repository.dart';

class DeleteInvoiceLedgerEntriesUseCase {
  const DeleteInvoiceLedgerEntriesUseCase(this._repository);

  final TransactionsRepository _repository;

  Future<void> call(int invoiceId) {
    return _repository.deleteInvoiceLedgerEntries(invoiceId);
  }
}
