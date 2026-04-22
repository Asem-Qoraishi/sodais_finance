import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';

class TypeToggleButtons<T> extends StatelessWidget {
  const TypeToggleButtons({
    super.key,
    required this.options,
    required this.onApply,
    required this.selectedOption,
  });

  final List<T> options;
  final T selectedOption;
  final ValueChanged<T> onApply;

  String _getOptionTitle(T option) {
    if (option is Enum) {
      return option.name.tr();
    }
    return option.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
      ),
      padding: EdgeInsets.all(sizeConstants.spacingXXSmall),
      child: Row(
        children: options.map((option) {
          final isSelected = option == selectedOption;
          return Expanded(
            child: _buildTypeButton(
              context: context,
              title: _getOptionTitle(option),
              selected: isSelected,
              onTap: () => onApply(option),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypeButton({
    required BuildContext context,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(vertical: sizeConstants.spacingXSmall),
        decoration: BoxDecoration(
          color: selected ? theme.cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected ? colors.primary : theme.hintColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
