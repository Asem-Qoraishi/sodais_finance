import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/features/persons/presentation/controllers/persons_controller.dart';

class PersonsFilterBar extends ConsumerWidget {
  const PersonsFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(personsTypeFilterProvider);
    final filterController = ref.read(personsTypeFilterProvider.notifier);

    return SizedBox(
      height: sizeConstants.spacingXLarge + sizeConstants.spacingSmall,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final filter in PersonTypeFilter.values)
            _chip(
              label: filter.name.tr(),
              selected: selectedFilter == filter,
              onTap: () => filterController.setFilter(filter),
            ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: sizeConstants.spacingXSmall),
      child: ChoiceChip(
        shape: const StadiumBorder(),
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
