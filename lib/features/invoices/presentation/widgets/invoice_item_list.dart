import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/assets/assets.gen.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/utils/formatters/app_number_formatter.dart';
import 'package:sodais_finance/core/widgets/buttons/custom_button.dart';
import 'package:sodais_finance/core/widgets/cards/custom_card.dart';
import 'package:sodais_finance/core/widgets/text_field/custom_text_field.dart';
import 'package:sodais_finance/features/invoices/presentation/controllers/invoice_form_state.dart';
import 'package:sodais_finance/features/products/domain/product.dart';

class InvoiceItemList extends StatelessWidget {
  const InvoiceItemList({
    super.key,
    required this.invoiceState,
    required this.products,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onItemProductChanged,
    required this.onItemQuantityChanged,
    required this.onItemPriceChanged,
    required this.onItemUnitChanged,
  });

  final InvoiceState invoiceState;
  final List<Product> products;
  final VoidCallback onAddItem;
  final ValueChanged<String> onRemoveItem;
  final void Function(String itemId, Product product) onItemProductChanged;
  final void Function(String itemId, int quantity) onItemQuantityChanged;
  final void Function(String itemId, double price) onItemPriceChanged;
  final void Function(String itemId, ProductStockUnit unit) onItemUnitChanged;

  @override
  Widget build(BuildContext context) {
    final canAddItem = invoiceState.canAddItems(products);

    return Column(
      spacing: sizeConstants.spacingSmall,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (products.isEmpty)
          Text(
            LocaleKeys.noProductsFound.tr(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        for (var i = 0; i < invoiceState.items.length; i++)
          InvoiceItemCard(
            key: ValueKey(invoiceState.items[i].id),
            itemIndex: i,
            item: invoiceState.items[i],
            products: invoiceState.selectableProductsForItem(
              products,
              invoiceState.items[i],
            ),
            canIncrement: invoiceState.canIncrementItem(
              invoiceState.items[i],
              products,
            ),
            onRemove: () => onRemoveItem(invoiceState.items[i].id),
            onProductChanged: (product) =>
                onItemProductChanged(invoiceState.items[i].id, product),
            onQuantityChanged: (quantity) =>
                onItemQuantityChanged(invoiceState.items[i].id, quantity),
            onPriceChanged: (price) =>
                onItemPriceChanged(invoiceState.items[i].id, price),
            onUnitChanged: (unit) =>
                onItemUnitChanged(invoiceState.items[i].id, unit),
          ),
        SizedBox(
          width: double.infinity,
          child: AbsorbPointer(
            absorbing: !canAddItem,
            child: Opacity(
              opacity: canAddItem ? 1 : 0.5,
              child: CustomButton(
                onPressed: onAddItem,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: sizeConstants.spacingXSmall,
                  children: [const Icon(Icons.add), Text(LocaleKeys.add.tr())],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class InvoiceItemCard extends StatefulWidget {
  const InvoiceItemCard({
    super.key,
    required this.itemIndex,
    required this.item,
    required this.products,
    required this.canIncrement,
    required this.onRemove,
    required this.onProductChanged,
    required this.onQuantityChanged,
    required this.onPriceChanged,
    required this.onUnitChanged,
  });

  final int itemIndex;
  final InvoiceItem item;
  final List<Product> products;
  final bool canIncrement;
  final VoidCallback onRemove;
  final ValueChanged<Product> onProductChanged;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<double> onPriceChanged;
  final ValueChanged<ProductStockUnit> onUnitChanged;

  @override
  State<InvoiceItemCard> createState() => _InvoiceItemCardState();
}

class _InvoiceItemCardState extends State<InvoiceItemCard> {
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: formatInvoiceAmount(widget.item.price),
    );
  }

  @override
  void didUpdateWidget(covariant InvoiceItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextValue = formatInvoiceAmount(widget.item.price);
    if (_priceController.text != nextValue) {
      _priceController.value = TextEditingValue(
        text: nextValue,
        selection: TextSelection.collapsed(offset: nextValue.length),
      );
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Product? _selectedProduct() {
    final productId = widget.item.productId;
    if (productId == null) return null;

    for (final product in widget.products) {
      if (product.id == productId) return product;
    }

    return null;
  }

  void _onPriceChanged(String value) {
    if (value.trim().isEmpty) {
      widget.onPriceChanged(0);
      return;
    }

    widget.onPriceChanged(AppNumberFormatter.parseDouble(value));
  }

  @override
  Widget build(BuildContext context) {
    final selectedProduct = _selectedProduct();
    final selectedProductId = selectedProduct?.id;
    final availableUnits = widget.item.availableUnits(selectedProduct);
    final theme = Theme.of(context);
    final compactFieldPadding = EdgeInsets.symmetric(
      horizontal: sizeConstants.spacingSmall,
      vertical: sizeConstants.spacingSmall,
    );
    final deleteButton = IconButton(
      onPressed: widget.onRemove,
      visualDensity: VisualDensity.compact,
      constraints: BoxConstraints.tightFor(
        width: sizeConstants.buttonHeightSmall,
        height: sizeConstants.buttonHeightSmall,
      ),
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.delete_outline),
    );
    final indexBadge = Container(
      width: sizeConstants.buttonHeightSmall,
      height: sizeConstants.buttonHeightSmall,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
      ),
      child: Text(
        '${widget.itemIndex + 1}',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    final subtotalBadge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizeConstants.spacingSmall,
        vertical: sizeConstants.spacingXXSmall,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: sizeConstants.spacingXXSmall,
        children: [
          Text(
            LocaleKeys.subtotal.tr(),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
          Text(
            formatInvoiceAmount(widget.item.subtotal),
            style: theme.textTheme.titleSmall,
          ),
        ],
      ),
    );
    final productDropdown = SizedBox(
      height: sizeConstants.buttonHeightMedium,
      child: DropdownButtonFormField<String>(
        initialValue: selectedProductId,
        isExpanded: true,
        isDense: true,
        iconSize: sizeConstants.iconSmall + 2,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          isDense: true,
          hintText: LocaleKeys.select_product.tr(),
          contentPadding: compactFieldPadding,
        ),
        items: widget.products
            .map(
              (product) => DropdownMenuItem<String>(
                value: product.id,
                child: Text(product.name, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(growable: false),
        onChanged: (productId) {
          if (productId == null) return;
          for (final product in widget.products) {
            if (product.id == productId) {
              widget.onProductChanged(product);
              break;
            }
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return LocaleKeys.fieldRequired.tr();
          }
          return null;
        },
      ),
    );

    final quantityField = _QuantitySelector(
      quantity: widget.item.qty,
      minimum: 1,
      label: widget.item.unitName.isEmpty
          ? LocaleKeys.quantity.tr()
          : '${LocaleKeys.quantity.tr()} (${widget.item.unitName})',
      canIncrement: widget.canIncrement,
      onChanged: widget.onQuantityChanged,
    );

    final unitField = availableUnits.length < 2
        ? null
        : Column(
            spacing: sizeConstants.spacingXXSmall,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.units.tr(),
                style: theme.inputDecorationTheme.labelStyle,
              ),
              SizedBox(
                height: sizeConstants.buttonHeightMedium,
                child: DropdownButtonFormField<ProductStockUnit>(
                  initialValue: widget.item.unit,
                  isDense: true,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: compactFieldPadding,
                  ),
                  items: availableUnits
                      .map(
                        (unit) => DropdownMenuItem<ProductStockUnit>(
                          value: unit,
                          child: Text(
                            unit == ProductStockUnit.main
                                ? widget.item.mainUnitName
                                : widget.item.secondaryUnitName ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) widget.onUnitChanged(value);
                  },
                ),
              ),
            ],
          );

    final quantityAndUnitFields = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: sizeConstants.buttonHeightSmall * 4.4,
          child: quantityField,
        ),
        if (unitField != null) ...[
          SizedBox(width: sizeConstants.spacingSmall),
          Expanded(child: unitField),
        ],
      ],
    );

    final desktopQuantityAndUnitFields = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: sizeConstants.buttonHeightSmall * 4.4,
          child: quantityField,
        ),
        if (unitField != null) ...[
          SizedBox(width: sizeConstants.spacingSmall),
          SizedBox(width: 132, child: unitField),
        ],
      ],
    );

    final priceField = Column(
      spacing: sizeConstants.spacingXXSmall,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.item.mainUnitName.trim().isEmpty
              ? LocaleKeys.unit_price.tr()
              : '${LocaleKeys.unit_price.tr()} (${widget.item.mainUnitName.trim()})',
          style: theme.inputDecorationTheme.labelStyle,
        ),
        SizedBox(
          height: sizeConstants.buttonHeightMedium,
          child: CustomTextField(
            controller: _priceController,
            prefixIconSource: Assets.icons.money,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChange: _onPriceChanged,
            inputFormatters: [AppNumberTextInputFormatter(allowDecimal: true)],
            isDense: true,
            contentPadding: compactFieldPadding,
            validator: (value) {
              final parsed = AppNumberFormatter.parseDouble(value);
              if (parsed.isNegative) {
                return LocaleKeys.invalidNumber.tr();
              }
              return null;
            },
          ),
        ),
      ],
    );

    return CustomCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(sizeConstants.spacingSmall),
      child: Column(
        spacing: sizeConstants.spacingSmall,
        children: [
          Row(
            spacing: sizeConstants.spacingSmall,
            children: [
              indexBadge,
              Expanded(child: productDropdown),
              deleteButton,
            ],
          ),
          if ((widget.item.inventoryId ?? '').isNotEmpty)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                selectedProduct == null
                    ? widget.item.inventoryId!
                    : '${widget.item.inventoryId!} • ${selectedProduct.trackedUnitName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 520) {
                return Column(
                  spacing: sizeConstants.spacingSmall,
                  children: [
                    quantityAndUnitFields,
                    priceField,
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: subtotalBadge,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  desktopQuantityAndUnitFields,
                  SizedBox(width: sizeConstants.spacingSmall),
                  Expanded(child: priceField),
                  SizedBox(width: sizeConstants.spacingSmall),
                  subtotalBadge,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatefulWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.minimum,
    required this.label,
    required this.canIncrement,
    required this.onChanged,
  });

  final int quantity;
  final int minimum;
  final String label;
  final bool canIncrement;
  final ValueChanged<int> onChanged;

  @override
  State<_QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<_QuantitySelector> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.quantity.toString());
  }

  @override
  void didUpdateWidget(covariant _QuantitySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextValue = widget.quantity.toString();
    if (_controller.text != nextValue) {
      _controller.value = TextEditingValue(
        text: nextValue,
        selection: TextSelection.collapsed(offset: nextValue.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _emitQuantity(int quantity) {
    widget.onChanged(quantity < widget.minimum ? widget.minimum : quantity);
  }

  void _onTextChanged(String value) {
    if (value.trim().isEmpty) return;
    _emitQuantity(AppNumberFormatter.parseInt(value));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonConstraints = BoxConstraints.tightFor(
      width: sizeConstants.buttonHeightSmall,
      height: sizeConstants.buttonHeightSmall,
    );

    return Column(
      spacing: sizeConstants.spacingXXSmall,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: theme.inputDecorationTheme.labelStyle),
        Container(
          height: sizeConstants.buttonHeightMedium,
          decoration: BoxDecoration(
            color: theme.inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
            border: Border.all(color: theme.dividerColor),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: sizeConstants.spacingXSmall,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.quantity > widget.minimum
                    ? () => _emitQuantity(widget.quantity - 1)
                    : null,
                visualDensity: VisualDensity.compact,
                constraints: buttonConstraints,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    AppNumberTextInputFormatter(allowDecimal: false),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: theme.textTheme.titleSmall,
                  onChanged: _onTextChanged,
                ),
              ),
              IconButton(
                onPressed: widget.canIncrement
                    ? () => _emitQuantity(widget.quantity + 1)
                    : null,
                visualDensity: VisualDensity.compact,
                constraints: buttonConstraints,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
