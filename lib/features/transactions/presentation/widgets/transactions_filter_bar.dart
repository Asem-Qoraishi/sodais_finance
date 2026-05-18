import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/widgets/filters/filter_chip_bar.dart';
import 'package:sodais_finance/features/transactions/presentation/controllers/transactions_controller.dart';
import 'package:sodais_finance/features/transactions/presentation/controllers/transactions_query_options.dart';

class TransactionsFilterBar extends ConsumerWidget {
  const TransactionsFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(transactionsFeedFilterProvider);
    final filterController = ref.read(transactionsFeedFilterProvider.notifier);

    return FilterChipBar<TransactionFeedFilter>(
      selectedValue: selectedFilter,
      onSelected: filterController.setFilter,
      options: [
        for (final filter in TransactionFeedFilter.values)
          FilterChipOption(
            value: filter,
            label: filter.name.tr(),
            icon: switch (filter) {
              TransactionFeedFilter.payment => Icons.arrow_upward_rounded,
              TransactionFeedFilter.receipt => Icons.arrow_downward_rounded,
              TransactionFeedFilter.invoices => Icons.receipt_long_outlined,
              TransactionFeedFilter.openingBalance =>
                Icons.account_balance_wallet_outlined,
              TransactionFeedFilter.all => null,
            },
          ),
      ],
    );
  }
}
