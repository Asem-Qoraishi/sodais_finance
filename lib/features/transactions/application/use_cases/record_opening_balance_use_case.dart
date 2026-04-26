import 'package:sodais_finance/features/transactions/domain/transactions_repository.dart';

class RecordOpeningBalanceUseCase {
  const RecordOpeningBalanceUseCase(this._repository);

  final TransactionsRepository _repository;

  Future<void> call(OpeningBalanceEntryRequest request) {
    return _repository.recordOpeningBalance(request);
  }
}
