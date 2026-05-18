import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';

class FilterChipOption<T> {
  const FilterChipOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

class FilterChipBar<T> extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.onSelected,
  });

  final T selectedValue;
  final List<FilterChipOption<T>> options;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: sizeConstants.spacingXLarge + sizeConstants.spacingSmall,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (context, index) =>
            SizedBox(width: sizeConstants.spacingXSmall),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option.value == selectedValue;
          final foregroundColor = isSelected
              ? colorScheme.onPrimaryContainer
              : theme.textTheme.bodyMedium?.color;

          return ChoiceChip(
            showCheckmark: false,
            selected: isSelected,
            onSelected: (_) => onSelected(option.value),
            backgroundColor: theme.cardColor,
            selectedColor: colorScheme.primaryContainer,
            side: BorderSide(
              color: isSelected ? colorScheme.primary : theme.dividerColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: sizeConstants.spacingSmall,
              vertical: sizeConstants.spacingXXSmall,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            avatar: option.icon == null
                ? null
                : Icon(
                    option.icon,
                    size: sizeConstants.iconSmall,
                    color: foregroundColor,
                  ),
            label: Text(
              option.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }
}
