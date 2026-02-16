import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/features/persons/domain/persons_query_options.dart';
import 'package:sodais_finance/features/persons/presentation/controllers/persons_controller.dart';

class PersonsFilterBar extends ConsumerWidget {
  const PersonsFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedFilter = ref.watch(personsTypeFilterProvider);
    final filterController = ref.read(personsTypeFilterProvider.notifier);

    return SizedBox(
      height: sizeConstants.spacingXLarge + sizeConstants.spacingSmall,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final filter in PersonTypeFilter.values)
            _chip(
              context: context,
              label: filter.name.tr(),
              icon: switch (filter) {
                PersonTypeFilter.owesYou => Icons.arrow_downward_rounded,
                PersonTypeFilter.youOwe => Icons.arrow_upward_rounded,
                _ => null,
              },
              borderColor: _borderColor(
                theme,
                filter,
                selectedFilter == filter,
              ),
              backgroundColor: _backgroundColor(
                theme,
                filter,
                selectedFilter == filter,
              ),
              foregroundColor: _foregroundColor(
                theme,
                filter,
                selectedFilter == filter,
              ),
              onTap: () => filterController.setFilter(filter),
            ),
        ],
      ),
    );
  }

  Color _backgroundColor(
    ThemeData theme,
    PersonTypeFilter filter,
    bool selected,
  ) {
    if (!selected) return theme.cardColor;

    return switch (filter) {
      PersonTypeFilter.owesYou => Colors.green.withValues(alpha: 0.14),
      PersonTypeFilter.youOwe => Colors.red.withValues(alpha: 0.14),
      _ => theme.colorScheme.primary,
    };
  }

  Color _foregroundColor(
    ThemeData theme,
    PersonTypeFilter filter,
    bool selected,
  ) {
    if (!selected) return theme.textTheme.bodyMedium?.color ?? Colors.black;

    return switch (filter) {
      PersonTypeFilter.owesYou => Colors.green.shade700,
      PersonTypeFilter.youOwe => Colors.red.shade700,
      _ => theme.colorScheme.onPrimary,
    };
  }

  Color _borderColor(ThemeData theme, PersonTypeFilter filter, bool selected) {
    if (!selected) return theme.dividerColor;

    return switch (filter) {
      PersonTypeFilter.owesYou => Colors.green.withValues(alpha: 0.34),
      PersonTypeFilter.youOwe => Colors.red.withValues(alpha: 0.34),
      _ => theme.colorScheme.primary,
    };
  }

  Widget _chip({
    required BuildContext context,
    required String label,
    required IconData? icon,
    required Color borderColor,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: sizeConstants.spacingXSmall),
      child: InkWell(
        borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: sizeConstants.spacingSmall,
            vertical: sizeConstants.spacingXSmall - 1,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Padding(
                  padding: EdgeInsets.only(right: sizeConstants.spacingXXSmall),
                  child: Icon(
                    icon,
                    size: sizeConstants.iconSmall,
                    color: foregroundColor,
                  ),
                ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
