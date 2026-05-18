import 'package:sodais_finance/features/transactions/domain/transactions_repository.dart';

class RecordManualTransactionUseCase {
  const RecordManualTransactionUseCase(this._repository);

  final TransactionsRepository _repository;

  Future<void> call(ManualTransactionRequest request) {
    return _repository.recordManualTransaction(request);
  }
}
