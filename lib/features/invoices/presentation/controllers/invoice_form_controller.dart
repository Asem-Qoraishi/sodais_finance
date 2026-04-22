import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sodais_finance/features/invoices/application/providers/invoice_providers.dart';
import 'package:sodais_finance/features/invoices/presentation/controllers/invoice_form_state.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/products/domain/product.dart';

part 'invoice_form_controller.g.dart';

@riverpod
class InvoiceController extends _$InvoiceController {
  @override
  InvoiceState build(InvoiceType? type) {
    final resolvedType = type ?? InvoiceType.sale;
    return _normalize(
      InvoiceState(
        type: resolvedType,
        date: DateTime.now(),
        invoiceNumber: _buildInvoiceNumber(resolvedType),
      ),
    );
  }

  String _buildInvoiceNumber(InvoiceType type) {
    final now = DateTime.now();
    final prefix = switch (type) {
      InvoiceType.sale => 'SAL',
      InvoiceType.purchase => 'PUR',
      InvoiceType.returned => 'RET',
    };

    String pad(int value) => value.toString().padLeft(2, '0');

    return '$prefix-${now.year}${pad(now.month)}${pad(now.day)}-'
        '${pad(now.hour)}${pad(now.minute)}${pad(now.second)}';
  }

  InvoiceState _normalize(InvoiceState nextState) {
    final normalizedState = nextState.copyWith(
      discount: nextState.discount.isNegative ? 0 : nextState.discount,
      taxRate: nextState.taxRate.isNegative ? 0 : nextState.taxRate,
    );
    final total = normalizedState.totalAmount;
    final normalizedAmountPaid = switch (normalizedState.paymentStatus) {
      PaymentStatus.paid => total,
      PaymentStatus.unpaid => 0.0,
      PaymentStatus.partialPaid =>
        normalizedState.amountPaid.clamp(0.0, total).toDouble(),
    };

    return normalizedState.copyWith(amountPaid: normalizedAmountPaid);
  }

  void _updateState(InvoiceState nextState) {
    state = _normalize(nextState);
  }

  String _newItemId() => DateTime.now().microsecondsSinceEpoch.toString();

  List<Product> _products() {
    return ref.read(invoiceProductsProvider).asData?.value ?? const [];
  }

  List<InvoiceItem> _itemsForType(InvoiceType type, List<InvoiceItem> items) {
    final products = _products();
    if (items.isEmpty || products.isEmpty) return items;

    final productsById = {for (final product in products) product.id: product};
    final nextItems = <InvoiceItem>[];
    final allocatedByProduct = <String, int>{};

    for (final item in items) {
      final productId = item.productId;
      if (productId == null) {
        nextItems.add(item.copyWith(price: 0));
        continue;
      }

      final product = productsById[productId];
      if (product == null) {
        nextItems.add(
          item.copyWith(productId: null, name: '', inventoryId: null, price: 0),
        );
        continue;
      }

      var nextQuantity = item.qty < 1 ? 1 : item.qty;
      if (type.tracksStock) {
        final allocatedQuantity = allocatedByProduct[product.id] ?? 0;
        final remainingStock = product.stock - allocatedQuantity;
        if (remainingStock < 1) continue;
        if (nextQuantity > remainingStock) {
          nextQuantity = remainingStock;
        }
        allocatedByProduct[product.id] = allocatedQuantity + nextQuantity;
      }

      nextItems.add(
        item.copyWith(
          productId: product.id,
          name: product.name,
          inventoryId: product.sku,
          qty: nextQuantity,
          price: type.unitPriceFor(product),
        ),
      );
    }

    return nextItems;
  }

  void updateInvoiceNumber(String number) {
    final trimmedNumber = number.trim();
    if (trimmedNumber.isEmpty) return;
    _updateState(state.copyWith(invoiceNumber: trimmedNumber));
  }

  void updateType(InvoiceType type) {
    if (type == state.type) return;
    _updateState(
      state.copyWith(
        type: type,
        contact: null,
        items: _itemsForType(type, state.items),
        invoiceNumber: _buildInvoiceNumber(type),
      ),
    );
  }

  void updateContact(Person? contact) =>
      _updateState(state.copyWith(contact: contact));

  void updateDate(DateTime date) => _updateState(state.copyWith(date: date));
  void updateDueDate(DateTime? date) =>
      _updateState(state.copyWith(dueDate: date));

  void updatePaymentStatus(PaymentStatus status) {
    if (status == state.paymentStatus) return;
    _updateState(state.copyWith(paymentStatus: status));
  }

  void updateAmountPaid(double amount) =>
      _updateState(state.copyWith(amountPaid: amount.abs()));

  void updateTaxRate(double rate) =>
      _updateState(state.copyWith(taxRate: rate.abs()));

  void updateDiscount(double discount) =>
      _updateState(state.copyWith(discount: discount.abs()));

  void addEmptyItem() {
    _updateState(
      state.copyWith(items: [...state.items, InvoiceItem.empty(_newItemId())]),
    );
  }

  void addProductItem(Product product) {
    if (!state.canUseProduct(product)) return;

    addItem(
      InvoiceItem(
        id: _newItemId(),
        productId: product.id,
        name: product.name,
        inventoryId: product.sku,
        qty: 1,
        price: state.type.unitPriceFor(product),
      ),
    );
  }

  void addItem(InvoiceItem newItem) {
    _updateState(state.copyWith(items: [...state.items, newItem]));
  }

  void updateItemProduct(String id, Product product) {
    if (!state.canUseProduct(product, excludingItemId: id)) return;

    _updateState(
      state.copyWith(
        items: state.items
            .map(
              (item) => item.id == id
                  ? item.copyWith(
                      productId: product.id,
                      name: product.name,
                      inventoryId: product.sku,
                      price: state.type.unitPriceFor(product),
                    )
                  : item,
            )
            .toList(growable: false),
      ),
    );
  }

  void updateItemQuantity(String id, int quantity) {
    InvoiceItem? targetItem;
    for (final item in state.items) {
      if (item.id == id) {
        targetItem = item;
        break;
      }
    }
    if (targetItem == null) return;

    final resolvedQuantity = state.resolvedQuantityForItem(
      targetItem,
      quantity,
      _products(),
    );
    _updateState(
      state.copyWith(
        items: state.items
            .map(
              (item) =>
                  item.id == id ? item.copyWith(qty: resolvedQuantity) : item,
            )
            .toList(growable: false),
      ),
    );
  }

  void incrementItemQuantity(String id) {
    InvoiceItem? item;
    for (final entry in state.items) {
      if (entry.id == id) {
        item = entry;
        break;
      }
    }
    if (item == null) return;
    updateItemQuantity(id, item.qty + 1);
  }

  void decrementItemQuantity(String id) {
    InvoiceItem? item;
    for (final entry in state.items) {
      if (entry.id == id) {
        item = entry;
        break;
      }
    }
    if (item == null) return;
    updateItemQuantity(id, item.qty - 1);
  }

  void updateItemPrice(String id, double price) {
    _updateState(
      state.copyWith(
        items: state.items
            .map(
              (item) => item.id == id
                  ? item.copyWith(price: price.isNegative ? 0 : price)
                  : item,
            )
            .toList(growable: false),
      ),
    );
  }

  void removeItem(String id) {
    _updateState(
      state.copyWith(
        items: state.items
            .where((item) => item.id != id)
            .toList(growable: false),
      ),
    );
  }

  Future<void> saveInvoice() async {
    final contactId = int.tryParse(state.contact?.id ?? '');
    if (contactId == null) {
      throw StateError('Select a contact first.');
    }
    if (state.items.isEmpty) {
      throw StateError('Add at least one item.');
    }

    final items = state.items
        .map((item) {
          final productId = int.tryParse(item.productId ?? '');
          if (productId == null) {
            throw StateError('Each item must have a product.');
          }

          return (
            productId: productId,
            quantity: item.qty.toDouble(),
            unitPrice: item.price,
            totalPrice: item.subtotal,
          );
        })
        .toList(growable: false);

    final invoiceDao = ref.read(invoiceDaoProvider);

    await invoiceDao.saveInvoice(
      invoiceNumber: state.invoiceNumber,
      contactId: contactId,
      type: state.type.name,
      issueDate: state.date,
      dueDate: state.dueDate,
      totalAmount: state.subtotal,
      discount: state.discount,
      tax: state.taxAmount,
      finalAmount: state.totalAmount,
      status: state.paymentStatus.name,
      items: items,
    );

    ref.invalidate(invoiceListProvider);
    ref.invalidate(invoiceProductsProvider);
  }
}
