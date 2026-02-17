import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/widgets/text_field/custom_text_field.dart';
import 'package:sodais_finance/features/products/constants/category_constants.dart';
import 'package:sodais_finance/features/products/domain/product_category.dart';
import 'package:sodais_finance/features/products/presentation/controllers/product_categories_controller.dart';
import 'package:sodais_finance/features/products/presentation/widgets/create_product_category_bottom_sheet.dart';

class ProductCategoriesScreen extends ConsumerWidget {
  const ProductCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(productCategoriesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.categories.tr()),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createCategory(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: EdgeInsets.all(sizeConstants.spacingSmall),
        child: Column(
          children: [
            CustomTextField(
              hintText: LocaleKeys.searchCategories.tr(),
              prefixIconData: Icons.search,
              onChange: (value) => ref
                  .read(productCategorySearchQueryProvider.notifier)
                  .update(value),
            ),
            SizedBox(height: sizeConstants.spacingSmall),
            Expanded(
              child: categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return Center(
                      child: Text(
                        LocaleKeys.noCategoriesFound.tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: categories.length,
                    separatorBuilder: (_, index) =>
                        SizedBox(height: sizeConstants.spacingXSmall),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _CategoryCard(
                        category: category,
                        onEdit: () => _editCategory(context, ref, category),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text(
                    LocaleKeys.failedToLoadCategories.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createCategory(BuildContext context, WidgetRef ref) async {
    final draft = await showCreateProductCategoryBottomSheet(context);
    if (draft == null || !context.mounted) return;

    try {
      await ref
          .read(productCategoriesControllerProvider.notifier)
          .addCategory(
            name: draft.name,
            icon: kDefaultPersistedCategoryIcon,
            colorHex: draft.colorHex,
          );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _editCategory(
    BuildContext context,
    WidgetRef ref,
    ProductCategory category,
  ) async {
    final draft = await showCreateProductCategoryBottomSheet(
      context,
      initialValue: CategoryDraft(
        name: category.name,
        colorHex: category.colorHex,
      ),
    );

    if (draft == null || !context.mounted) return;

    try {
      await ref
          .read(productCategoriesControllerProvider.notifier)
          .updateCategory(
            ProductCategory(
              id: category.id,
              name: draft.name,
              icon: category.icon,
              colorHex: draft.colorHex,
              itemCount: category.itemCount,
              createdAt: category.createdAt,
              updatedAt: DateTime.now(),
            ),
          );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
      );
    }
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onEdit});

  final ProductCategory category;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = hexToColor(category.colorHex);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: sizeConstants.spacingSmall,
          vertical: sizeConstants.spacingXXSmall,
        ),
        leading: Container(
          width: sizeConstants.iconLarge,
          height: sizeConstants.iconLarge,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.32)),
          ),
        ),
        title: Text(
          category.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          LocaleKeys.itemsCount.tr(
            namedArgs: {'count': '${category.itemCount}'},
          ),
          style: theme.textTheme.bodySmall,
        ),
        trailing: IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
        ),
      ),
    );
  }
}
