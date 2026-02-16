import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/colors.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';

void showOrderByBottomSheet<T extends Enum>({
  required BuildContext context,
  required T selected,
  required List<T> options,
  required ValueChanged<T> onApply,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => OrderByBottomSheet(
      selected: selected,
      options: options,
      onApply: onApply,
    ),
  );
}

class OrderByBottomSheet<T extends Enum> extends StatelessWidget {
  const OrderByBottomSheet({
    super.key,
    required this.selected,
    required this.onApply,
    required this.options,
  });

  final T selected;
  final ValueChanged<T> onApply;
  final List<T> options;
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(sizeConstants.spacingSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(sizeConstants.radiusMedium),
              topRight: Radius.circular(sizeConstants.radiusMedium),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: AlignmentGeometry.centerRight,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close),
                      ),
                    ),
                    Align(
                      alignment: AlignmentGeometry.center,
                      child: Text(
                        LocaleKeys.orderBy.tr(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                for (final option in options)
                  ListTile(
                    leading: Icon(Icons.sort),
                    title: Text(option.name).tr(),
                    trailing: option == selected
                        ? Icon(
                            Icons.radio_button_checked,
                            color:
                                Theme.brightnessOf(context) == Brightness.dark
                                ? darkSuccessColor
                                : kSuccessColor,
                          )
                        : const Icon(
                            Icons.radio_button_unchecked,
                            color: Colors.grey,
                          ),
                    onTap: () => onApply(option),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
