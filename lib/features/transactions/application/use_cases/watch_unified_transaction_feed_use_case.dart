import 'package:sodais_finance/features/transactions/domain/transaction_feed_entry.dart';
import 'package:sodais_finance/features/transactions/domain/transactions_repository.dart';

class WatchUnifiedTransactionFeedUseCase {
  const WatchUnifiedTransactionFeedUseCase(this._repository);

  final TransactionsRepository _repository;

  Stream<List<TransactionFeedEntry>> call() => _repository.watchUnifiedFeed();
}
