import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sodais_finance/config/app_router.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/widgets/text_field/custom_text_field.dart';
import 'package:sodais_finance/features/products/domain/product.dart';
import 'package:sodais_finance/features/products/domain/product_category.dart';
import 'package:sodais_finance/features/products/presentation/controllers/add_new_product_form_controller.dart';
import 'package:sodais_finance/features/products/presentation/controllers/product_categories_controller.dart';

class AddNewProductScreen extends ConsumerStatefulWidget {
  const AddNewProductScreen({super.key, this.editingProduct});

  final Product? editingProduct;

  @override
  ConsumerState<AddNewProductScreen> createState() =>
      _AddNewProductScreenState();
}

class _AddNewProductScreenState extends ConsumerState<AddNewProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _taxRateController = TextEditingController();
  final _stockController = TextEditingController();
  final _reorderLevelController = TextEditingController();
  final _locationController = TextEditingController();
  bool _didInitProviderState = false;

  String _requiredLabel(String base) => '$base *';
  bool get _isEditMode => widget.editingProduct != null;

  @override
  void initState() {
    super.initState();
    _populateControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didInitProviderState) return;
      _didInitProviderState = true;
      ref
          .read(addNewProductFormProvider.notifier)
          .initialize(
            imagePath: widget.editingProduct?.imagePath,
            categoryId: widget.editingProduct?.categoryId,
          );
    });
  }

  void _populateControllers() {
    final product = widget.editingProduct;
    if (product == null) return;

    _nameController.text = product.name;
    _skuController.text = product.sku ?? '';
    _descriptionController.text = product.description ?? '';
    _purchasePriceController.text = _decimalValue(product.purchasePrice);
    _sellingPriceController.text = _decimalValue(product.sellingPrice);
    _taxRateController.text = _decimalValue(product.taxRate);
    _stockController.text = _intValue(product.stock);
    _reorderLevelController.text = _intValue(product.reorderLevel);
    _locationController.text = product.location ?? '';
  }

  String _decimalValue(double value) {
    if (value == 0) return '';
    final fixed = value.toStringAsFixed(2);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _intValue(int value) => value == 0 ? '' : value.toString();

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _taxRateController.dispose();
    _stockController.dispose();
    _reorderLevelController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final formNotifier = ref.read(addNewProductFormProvider.notifier);
    final didSave = await formNotifier.submit(
      editingProduct: widget.editingProduct,
      name: _nameController.text,
      sku: _skuController.text,
      description: _descriptionController.text,
      purchasePriceText: _purchasePriceController.text,
      sellingPriceText: _sellingPriceController.text,
      taxRateText: _taxRateController.text,
      stockText: _stockController.text,
      reorderLevelText: _reorderLevelController.text,
      location: _locationController.text,
    );

    if (didSave && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      addNewProductFormProvider.select((state) => state.errorMessage),
      (previous, next) {
        if (next == null || next == previous || !mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next), backgroundColor: Colors.red),
        );
      },
    );

    final formState = ref.watch(addNewProductFormProvider);
    final formNotifier = ref.read(addNewProductFormProvider.notifier);
    final categoriesAsync = ref.watch(productCategoriesControllerProvider);
    final categories =
        categoriesAsync.asData?.value ?? const <ProductCategory>[];
    final selectedImagePath = formState.selectedImagePath;
    final hasImage =
        selectedImagePath != null && File(selectedImagePath).existsSync();
    final pagePadding = sizeConstants.spacingMedium;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode
              ? LocaleKeys.editProduct.tr()
              : LocaleKeys.addNewProduct.tr(),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            pagePadding,
            sizeConstants.spacingXSmall,
            pagePadding,
            pagePadding,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: FilledButton.icon(
            onPressed: formState.isSaving ? null : _handleSave,
            icon: formState.isSaving
                ? SizedBox(
                    width: sizeConstants.iconSmall,
                    height: sizeConstants.iconSmall,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(Icons.save_outlined, size: sizeConstants.iconMedium),
            label: Text(
              formState.isSaving
                  ? LocaleKeys.saving.tr()
                  : _isEditMode
                  ? LocaleKeys.updateProduct.tr()
                  : LocaleKeys.saveProduct.tr(),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            pagePadding,
            pagePadding,
            pagePadding,
            sizeConstants.spacingXXLarge * 2,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProductImagePicker(
                      hasImage: hasImage,
                      imagePath: selectedImagePath,
                      onTap: formNotifier.pickImageFromGallery,
                    ),
                    SizedBox(height: sizeConstants.spacingLarge),
                    _SectionHeader(title: LocaleKeys.generalInformation.tr()),
                    SizedBox(height: sizeConstants.spacingSmall),
                    Text(
                      '* ${LocaleKeys.fieldRequired.tr()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    SizedBox(height: sizeConstants.spacingXSmall),
                    CustomTextField(
                      controller: _nameController,
                      label: _requiredLabel(LocaleKeys.productName.tr()),
                      hintText: LocaleKeys.productNameHint.tr(),
                      prefixIconData: Icons.inventory_2_outlined,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return LocaleKeys.nameRequired.tr();
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: sizeConstants.spacingSmall),
                    _ResponsiveTwoColumns(
                      first: CustomTextField(
                        controller: _skuController,
                        label: LocaleKeys.skuOrBarcode.tr(),
                        hintText: LocaleKeys.skuOrBarcodeHint.tr(),
                        prefixIconData: Icons.qr_code_scanner_outlined,
                        textInputAction: TextInputAction.next,
                      ),
                      second: _CategorySelector(
                        categories: categories,
                        selectedCategoryId: formState.selectedCategoryId,
                        loading: categoriesAsync.isLoading,
                        onChanged: formNotifier.setCategoryId,
                        onOpenCategoriesScreen: () {
                          context.pushNamed(routeNames.manageProductCategories);
                        },
                      ),
                    ),
                    SizedBox(height: sizeConstants.spacingSmall),
                    CustomTextField(
                      controller: _descriptionController,
                      label: LocaleKeys.description.tr(),
                      hintText: LocaleKeys.descriptionHint.tr(),
                      maxLines: 3,
                      minLines: 3,
                    ),
                    SizedBox(height: sizeConstants.spacingLarge),
                    _PricingTaxSection(
                      purchasePriceController: _purchasePriceController,
                      sellingPriceController: _sellingPriceController,
                      taxRateController: _taxRateController,
                    ),
                    SizedBox(height: sizeConstants.spacingLarge),
                    _SectionHeader(
                      title:
                          '${LocaleKeys.inventorySettings.tr()} (${LocaleKeys.fieldOptional.tr()})',
                      icon: Icons.inventory_2_outlined,
                    ),
                    SizedBox(height: sizeConstants.spacingSmall),
                    _ResponsiveTwoColumns(
                      first: CustomTextField(
                        controller: _stockController,
                        label: LocaleKeys.initalStockQuantity.tr(),
                        hintText: LocaleKeys.initalStockHint.tr(),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textInputAction: TextInputAction.next,
                      ),
                      second: CustomTextField(
                        controller: _reorderLevelController,
                        label: LocaleKeys.reorderLevel.tr(),
                        hintText: LocaleKeys.lowStockThreshold.tr(),
                        prefixIconData: Icons.notification_important_outlined,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    SizedBox(height: sizeConstants.spacingSmall),
                    CustomTextField(
                      controller: _locationController,
                      label: LocaleKeys.warehouseLocation.tr(),
                      hintText: LocaleKeys.warehouseLocationHint.tr(),
                      prefixIconData: Icons.location_on_outlined,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
    required this.selectedCategoryId,
    required this.loading,
    required this.onChanged,
    required this.onOpenCategoriesScreen,
  });

  final List<ProductCategory> categories;
  final String? selectedCategoryId;
  final bool loading;
  final ValueChanged<String?> onChanged;
  final VoidCallback onOpenCategoriesScreen;

  @override
  Widget build(BuildContext context) {
    final hasCategories = categories.isNotEmpty;
    final currentValue = categories.any((c) => c.id == selectedCategoryId)
        ? selectedCategoryId
        : null;
    final dropdownTextStyle = Theme.of(context).textTheme.bodyMedium;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: hasCategories ? null : onOpenCategoriesScreen,
      child: AbsorbPointer(
        absorbing: !hasCategories,
        child: DropdownButtonFormField<String>(
          key: ValueKey(currentValue),
          initialValue: currentValue,
          style: dropdownTextStyle,
          decoration: InputDecoration(
            labelText: LocaleKeys.category.tr(),
            hintText: hasCategories
                ? LocaleKeys.selectCategory.tr()
                : LocaleKeys.noCategoriesFound.tr(),
            labelStyle: dropdownTextStyle,
            hintStyle: dropdownTextStyle,
            prefixIcon: IconButton(
              tooltip: LocaleKeys.categories.tr(),
              onPressed: onOpenCategoriesScreen,
              icon: const Icon(Icons.category_outlined),
            ),
            suffixIcon: loading
                ? Padding(
                    padding: EdgeInsets.only(right: sizeConstants.spacingSmall),
                    child: SizedBox(
                      width: sizeConstants.iconSmall,
                      height: sizeConstants.iconSmall,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          items: categories
              .map(
                (category) => DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.name, style: dropdownTextStyle),
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ProductImagePicker extends StatelessWidget {
  const _ProductImagePicker({
    required this.hasImage,
    required this.imagePath,
    required this.onTap,
  });

  final bool hasImage;
  final String? imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(sizeConstants.radiusLarge),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.35),
              width: 2,
            ),
          ),
          child: hasImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(
                    sizeConstants.radiusLarge,
                  ),
                  child: Image.file(File(imagePath!), fit: BoxFit.cover),
                )
              : _ImagePlaceholder(onTap: onTap),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(sizeConstants.spacingMedium),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: SizedBox(
                width: constraints.maxWidth * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: sizeConstants.avatarSmall,
                      height: sizeConstants.avatarSmall,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.add_a_photo_outlined,
                        color: colors.primary,
                        size: sizeConstants.iconLarge,
                      ),
                    ),
                    SizedBox(height: sizeConstants.spacingXSmall),
                    Text(
                      LocaleKeys.productImage.tr(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                    SizedBox(height: sizeConstants.spacingXXSmall),
                    Text(
                      LocaleKeys.tapToUploadOrCapturePhoto.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(height: sizeConstants.spacingSmall),
                    OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(LocaleKeys.selectFile.tr()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PricingTaxSection extends StatelessWidget {
  const _PricingTaxSection({
    required this.purchasePriceController,
    required this.sellingPriceController,
    required this.taxRateController,
  });

  final TextEditingController purchasePriceController;
  final TextEditingController sellingPriceController;
  final TextEditingController taxRateController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title:
              '${LocaleKeys.pricingAndTax.tr()} (${LocaleKeys.fieldOptional.tr()})',
          icon: Icons.payments_outlined,
          compact: true,
        ),
        SizedBox(height: sizeConstants.spacingSmall),
        _ResponsiveThreeColumns(
          first: CustomTextField(
            controller: purchasePriceController,
            label: LocaleKeys.purchasePrice.tr(),
            hintText: '0.00',
            prefixIconData: Icons.attach_money,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
          ),
          second: CustomTextField(
            controller: sellingPriceController,
            label: LocaleKeys.sellingPrice.tr(),
            hintText: '0.00',
            prefixIconData: Icons.attach_money,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
          ),
          third: CustomTextField(
            controller: taxRateController,
            label: LocaleKeys.taxRatePercent.tr(),
            hintText: LocaleKeys.taxRateHint.tr(),
            prefixIconData: Icons.percent,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.icon, this.compact = false});

  final String title;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: sizeConstants.iconSmall,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: sizeConstants.spacingXXSmall),
        ],
        Text(
          title,
          style: compact
              ? text.labelLarge?.copyWith(fontWeight: FontWeight.w700)
              : text.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
        ),
      ],
    );
  }
}

class _ResponsiveTwoColumns extends StatelessWidget {
  const _ResponsiveTwoColumns({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 620;
        if (!isWide) {
          return Column(
            children: [
              first,
              SizedBox(height: sizeConstants.spacingSmall),
              second,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: first),
            SizedBox(width: sizeConstants.spacingSmall),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _ResponsiveThreeColumns extends StatelessWidget {
  const _ResponsiveThreeColumns({
    required this.first,
    required this.second,
    required this.third,
  });

  final Widget first;
  final Widget second;
  final Widget third;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = sizeConstants.spacingSmall;
        final isWide = constraints.maxWidth >= 760;
        final isMedium = constraints.maxWidth >= 520;

        if (isWide) {
          return Row(
            children: [
              Expanded(child: first),
              SizedBox(width: spacing),
              Expanded(child: second),
              SizedBox(width: spacing),
              Expanded(child: third),
            ],
          );
        }

        if (isMedium) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: first),
                  SizedBox(width: spacing),
                  Expanded(child: second),
                ],
              ),
              SizedBox(height: spacing),
              third,
            ],
          );
        }

        return Column(
          children: [
            first,
            SizedBox(height: spacing),
            second,
            SizedBox(height: spacing),
            third,
          ],
        );
      },
    );
  }
}
