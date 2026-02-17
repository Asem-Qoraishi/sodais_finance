import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/widgets/text_field/custom_text_field.dart';
import 'package:sodais_finance/features/products/constants/category_constants.dart';

class CategoryDraft {
  final String name;
  final String colorHex;

  const CategoryDraft({required this.name, required this.colorHex});
}

Future<CategoryDraft?> showCreateProductCategoryBottomSheet(
  BuildContext context, {
  CategoryDraft? initialValue,
}) {
  return showModalBottomSheet<CategoryDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CreateProductCategorySheet(initialValue: initialValue),
  );
}

class _CreateProductCategorySheet extends StatefulWidget {
  const _CreateProductCategorySheet({this.initialValue});

  final CategoryDraft? initialValue;

  @override
  State<_CreateProductCategorySheet> createState() =>
      _CreateProductCategorySheetState();
}

class _CreateProductCategorySheetState
    extends State<_CreateProductCategorySheet> {
  late final TextEditingController _nameController;
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialValue?.name ?? '',
    );
    _selectedColor =
        widget.initialValue?.colorHex ?? kCategoryColorOptions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    Navigator.of(
      context,
    ).pop(CategoryDraft(name: name, colorHex: _selectedColor));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final insetBottom = mediaQuery.viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: insetBottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(sizeConstants.radiusXLarge),
          ),
          border: Border.all(color: theme.dividerColor),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              sizeConstants.spacingMedium,
              sizeConstants.spacingXSmall,
              sizeConstants.spacingMedium,
              sizeConstants.spacingMedium,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: sizeConstants.spacingXLarge,
                    height: sizeConstants.spacingXXSmall,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(
                        sizeConstants.radiusMax,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: sizeConstants.spacingSmall),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        LocaleKeys.newCategory.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: sizeConstants.spacingSmall),
                CustomTextField(
                  controller: _nameController,
                  label: LocaleKeys.categoryName.tr(),
                  hintText: LocaleKeys.categoryNameHint.tr(),
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: sizeConstants.spacingSmall),
                Text(
                  LocaleKeys.categoryColor.tr(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: sizeConstants.spacingXSmall),
                Wrap(
                  spacing: sizeConstants.spacingSmall,
                  runSpacing: sizeConstants.spacingSmall,
                  children: kCategoryColorOptions
                      .map((hex) {
                        final selected = _selectedColor == hex;
                        final color = hexToColor(hex);

                        return _SelectableCircle(
                          selected: selected,
                          color: color,
                          borderColor: selected
                              ? Colors.white
                              : Colors.transparent,
                          semanticsLabel: 'Color $hex',
                          onTap: () {
                            setState(() => _selectedColor = hex);
                          },
                          child: selected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : const SizedBox.shrink(),
                        );
                      })
                      .toList(growable: false),
                ),
                SizedBox(height: sizeConstants.spacingMedium),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text(LocaleKeys.createCategory.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectableCircle extends StatelessWidget {
  const _SelectableCircle({
    required this.selected,
    required this.color,
    required this.borderColor,
    required this.child,
    required this.onTap,
    this.semanticsLabel,
  });

  final bool selected;
  final Color color;
  final Color borderColor;
  final Widget child;
  final VoidCallback onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    Widget target = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(sizeConstants.radiusMax),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: sizeConstants.avatarXSmall,
        height: sizeConstants.avatarXSmall,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );

    if (semanticsLabel != null && semanticsLabel!.trim().isNotEmpty) {
      target = Semantics(
        button: true,
        selected: selected,
        label: semanticsLabel!.trim(),
        child: target,
      );
    }

    return target;
  }
}
