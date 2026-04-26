import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sodais_finance/features/app/data/app_database.dart';
import 'package:sodais_finance/features/invoices/application/providers/invoice_providers.dart';
import 'package:sodais_finance/features/invoices/presentation/controllers/invoice_form_state.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/products/domain/product.dart';
import 'package:sodais_finance/features/transactions/application/providers/transaction_providers.dart';
import 'package:sodais_finance/features/transactions/domain/transactions_repository.dart';

part 'invoice_form_controller.g.dart';

class InvoiceControllerArgs {
  const InvoiceControllerArgs({required this.type, this.invoiceId});

  final InvoiceType type;
  final int? invoiceId;

  @override
  bool operator ==(Object other) {
    return other is InvoiceControllerArgs &&
        other.type == type &&
        other.invoiceId == invoiceId;
  }

  @override
  int get hashCode => Object.hash(type, invoiceId);
}

@riverpod
class InvoiceController extends _$InvoiceController {
  int? _loadedInvoiceId;

  @override
  InvoiceState build(InvoiceControllerArgs args) {
    _loadedInvoiceId = null;
    if (args.invoiceId == null) {
      Future.microtask(_loadNextInvoiceNumber);
    }
    return _normalize(
      InvoiceState(
        type: args.type,
        date: DateTime.now(),
        invoiceNumber: 'inv-1',
      ),
    );
  }

  Future<void> _loadNextInvoiceNumber() async {
    final nextInvoiceNumber = await ref
        .read(invoiceDaoProvider)
        .getNextInvoiceNumber();
    if (_loadedInvoiceId != null || state.invoiceNumber == nextInvoiceNumber) {
      return;
    }
    _updateState(state.copyWith(invoiceNumber: nextInvoiceNumber));
  }

  InvoiceType _invoiceTypeFromName(String value) {
    for (final type in InvoiceType.values) {
      if (type.name == value) return type;
    }
    return InvoiceType.sale;
  }

  PaymentStatus _paymentStatusFromName(String value) {
    for (final status in PaymentStatus.values) {
      if (status.name == value) return status;
    }
    return PaymentStatus.unpaid;
  }

  double _taxRateFromStoredValues({
    required double subtotal,
    required double taxAmount,
  }) {
    if (subtotal <= 0 || taxAmount <= 0) return 0;
    return (taxAmount / subtotal) * 100;
  }

  Map<String, int> _editingStockAllowance(List<InvoiceItem> items) {
    final allowances = <String, int>{};

    for (final item in items) {
      final productId = item.productId;
      if (productId == null) continue;
      allowances.update(
        productId,
        (value) => value + item.qty,
        ifAbsent: () {
          return item.qty;
        },
      );
    }

    return allowances;
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
        final remainingStock =
            product.stock +
            (state.editingStockAllowanceByProduct[product.id] ?? 0) -
            allocatedQuantity;
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

  Future<void> loadExistingInvoice(int invoiceId) async {
    if (_loadedInvoiceId == invoiceId) return;

    final invoiceDetails = await ref
        .read(invoiceDaoProvider)
        .getInvoiceDetails(invoiceId);
    if (invoiceDetails == null) {
      throw StateError('Invoice $invoiceId was not found.');
    }

    final invoiceType = _invoiceTypeFromName(invoiceDetails.invoice.type);
    final items = invoiceDetails.items
        .map(
          (entry) => InvoiceItem(
            id: entry.item.id.toString(),
            productId: entry.product?.id,
            name: entry.product?.name ?? '',
            inventoryId: entry.product?.sku,
            qty: entry.item.quantity.round(),
            price: entry.item.unitPrice,
          ),
        )
        .toList(growable: false);

    _loadedInvoiceId = invoiceId;
    _updateState(
      InvoiceState(
        type: invoiceType,
        contact: invoiceDetails.contact,
        invoiceNumber: invoiceDetails.invoice.invoiceNumber,
        date: invoiceDetails.invoice.issueDate,
        dueDate: invoiceDetails.invoice.dueDate,
        items: items,
        editingStockAllowanceByProduct: invoiceType.tracksStock
            ? _editingStockAllowance(items)
            : const {},
        paymentStatus: _paymentStatusFromName(invoiceDetails.invoice.status),
        amountPaid: invoiceDetails.invoice.amountPaid,
        taxRate: _taxRateFromStoredValues(
          subtotal: invoiceDetails.invoice.totalAmount,
          taxAmount: invoiceDetails.invoice.tax,
        ),
        discount: invoiceDetails.invoice.discount,
      ),
    );
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
    final database = ref.read(appDatabaseProvider);
    final syncInvoiceLedger = ref.read(syncInvoiceLedgerUseCaseProvider);

    await database.transaction(() async {
      final invoiceId =
          _loadedInvoiceId ??
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
            amountPaid: state.amountPaid,
            status: state.paymentStatus.name,
            items: items,
          );

      if (_loadedInvoiceId != null) {
        await invoiceDao.updateInvoice(
          invoiceId: invoiceId,
          invoiceNumber: state.invoiceNumber,
          contactId: contactId,
          type: state.type.name,
          issueDate: state.date,
          dueDate: state.dueDate,
          totalAmount: state.subtotal,
          discount: state.discount,
          tax: state.taxAmount,
          finalAmount: state.totalAmount,
          amountPaid: state.amountPaid,
          status: state.paymentStatus.name,
          items: items,
        );
      }

      await syncInvoiceLedger(
        InvoiceLedgerSyncRequest(
          invoiceId: invoiceId,
          invoiceNumber: state.invoiceNumber,
          contactId: contactId,
          invoiceType: state.type.name,
          issueDate: state.date,
          finalAmount: state.totalAmount,
          amountPaid: state.amountPaid,
          status: state.paymentStatus.name,
        ),
      );

      _loadedInvoiceId ??= invoiceId;
    });

    ref.invalidate(invoiceListProvider);
    ref.invalidate(invoiceSummaryListProvider);
    ref.invalidate(invoiceProductsProvider);
  }

  Future<void> deleteInvoice() async {
    final invoiceId = _loadedInvoiceId;
    if (invoiceId == null) {
      throw StateError('Invoice is not loaded.');
    }

    final database = ref.read(appDatabaseProvider);
    final deleteInvoiceLedgerEntries = ref.read(
      deleteInvoiceLedgerEntriesUseCaseProvider,
    );

    await database.transaction(() async {
      await ref.read(invoiceDaoProvider).deleteInvoice(invoiceId);
      await deleteInvoiceLedgerEntries(invoiceId);
    });

    ref.invalidate(invoiceListProvider);
    ref.invalidate(invoiceSummaryListProvider);
    ref.invalidate(invoiceProductsProvider);
  }
}
