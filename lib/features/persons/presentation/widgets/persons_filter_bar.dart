import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/widgets/filters/filter_chip_bar.dart';
import 'package:sodais_finance/features/persons/domain/persons_query_options.dart';
import 'package:sodais_finance/features/persons/presentation/controllers/persons_controller.dart';

class PersonsFilterBar extends ConsumerWidget {
  const PersonsFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(personsTypeFilterProvider);
    final filterController = ref.read(personsTypeFilterProvider.notifier);

    return FilterChipBar<PersonTypeFilter>(
      selectedValue: selectedFilter,
      onSelected: filterController.setFilter,
      options: [
        for (final filter in PersonTypeFilter.values)
          FilterChipOption(
            value: filter,
            label: filter.name.tr(),
            icon: switch (filter) {
              PersonTypeFilter.owesYou => Icons.arrow_downward_rounded,
              PersonTypeFilter.youOwe => Icons.arrow_upward_rounded,
              _ => null,
            },
          ),
      ],
    );
  }
}
