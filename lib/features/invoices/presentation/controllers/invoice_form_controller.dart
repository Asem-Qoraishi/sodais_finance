import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sodais_finance/features/app/data/app_database.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/features/invoices/application/providers/invoice_providers.dart';
import 'package:sodais_finance/features/invoices/data/local/dao/invoice_dao.dart';
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
      InvoiceState(type: args.type, date: DateTime.now(), invoiceNumber: '1'),
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

  double _taxRateFromStoredValues({
    required double subtotal,
    required double taxAmount,
  }) {
    if (subtotal <= 0 || taxAmount <= 0) return 0;
    return (taxAmount / subtotal) * 100;
  }

  Map<String, int> _editingStockAllowance(List<InvoiceItem> items) {
    final allowances = <String, int>{};
    final productsById = {
      for (final product in _products()) product.id: product,
    };

    for (final item in items) {
      final productId = item.productId;
      if (productId == null) continue;
      final product = productsById[productId];
      if (product == null) continue;
      allowances.update(
        productId,
        (value) => value + item.trackedQuantityFor(product),
        ifAbsent: () {
          return item.trackedQuantityFor(product);
        },
      );
    }

    return allowances;
  }

  InvoiceState _normalize(InvoiceState nextState) {
    final normalizedPayments = nextState.payments
        .map(
          (payment) => payment.copyWith(
            amount: payment.amount.isNegative ? 0 : payment.amount,
          ),
        )
        .where((payment) => payment.amount > 0)
        .toList(growable: false);

    return nextState.copyWith(
      payments: normalizedPayments,
      discount: nextState.discount.isNegative ? 0 : nextState.discount,
      taxRate: nextState.taxRate.isNegative ? 0 : nextState.taxRate,
    );
  }

  void _updateState(InvoiceState nextState) {
    state = _normalize(nextState);
  }

  String _newItemId() => DateTime.now().microsecondsSinceEpoch.toString();

  String _newPaymentId() =>
      'payment-${DateTime.now().microsecondsSinceEpoch.toString()}';

  List<Product> _products() {
    return ref.read(invoiceProductsProvider).asData?.value ?? const [];
  }

  ProductStockUnit _defaultInvoiceUnit(
    Product product, {
    ProductStockUnit? currentUnit,
  }) {
    if (!product.hasSecondaryUnit) {
      return ProductStockUnit.main;
    }
    if (currentUnit == ProductStockUnit.secondary) {
      return ProductStockUnit.secondary;
    }
    if (product.stockUnit == ProductStockUnit.secondary) {
      return ProductStockUnit.secondary;
    }
    return ProductStockUnit.main;
  }

  InvoiceItem _invoiceItemFromDetailsEntry(InvoiceDetailsItem entry) {
    final product = entry.product;
    final mainQuantity = entry.item.quantity;
    final rate = product?.secondaryUnitRate ?? 0;
    final usesSecondary =
        product?.hasSecondaryUnit == true &&
        rate > 0 &&
        isWholeInvoiceQuantity(mainQuantity / rate);

    return InvoiceItem(
      id: entry.item.id.toString(),
      productId: product?.id,
      name: product?.name ?? '',
      inventoryId: product?.sku,
      qty: usesSecondary
          ? math.max(1, (mainQuantity / rate).round())
          : math.max(1, mainQuantity.round()),
      secondaryQty: 0,
      price: entry.item.unitPrice,
      unit: usesSecondary ? ProductStockUnit.secondary : ProductStockUnit.main,
      mainUnitName: product?.mainUnitName ?? 'item',
      secondaryUnitName: product?.secondaryUnitName,
      secondaryUnitRate: product?.secondaryUnitRate,
    );
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

      var nextItem = item.copyWith(
        productId: product.id,
        name: product.name,
        inventoryId: product.sku,
        price: type.unitPriceFor(product),
        mainUnitName: product.mainUnitName,
        secondaryUnitName: product.secondaryUnitName,
        secondaryUnitRate: product.secondaryUnitRate,
        unit: _defaultInvoiceUnit(product, currentUnit: item.unit),
      );
      nextItem = nextItem.copyWith(
        qty: math.max(nextItem.qty, 1),
        secondaryQty: 0,
      );
      if (type.tracksStock) {
        final allocatedQuantity = allocatedByProduct[product.id] ?? 0;
        final remainingStock =
            product.stock +
            (state.editingStockAllowanceByProduct[product.id] ?? 0) -
            allocatedQuantity;
        if (remainingStock < 1) continue;
        final rate =
            product.secondaryUnitRate ?? nextItem.secondaryUnitRate ?? 0;
        final maxMainQuantity =
            product.stockUnit == ProductStockUnit.secondary &&
                product.hasSecondaryUnit &&
                rate > 0
            ? remainingStock * rate
            : remainingStock.toDouble();
        final unitMultiplier = nextItem.usesSecondaryUnit && rate > 0
            ? rate
            : 1.0;
        final maxQuantity = math.max(
          (maxMainQuantity / unitMultiplier).floor(),
          1,
        );
        nextItem = nextItem.copyWith(qty: nextItem.qty.clamp(1, maxQuantity));
        if (nextItem.quantityInMainUnit <= 0) {
          nextItem = nextItem.copyWith(qty: 1, secondaryQty: 0);
        }
        allocatedByProduct[product.id] =
            allocatedQuantity + nextItem.trackedQuantityFor(product);
      } else {
        if (nextItem.quantityInMainUnit <= 0) {
          nextItem = nextItem.copyWith(qty: 1, secondaryQty: 0);
        }
      }

      nextItems.add(nextItem);
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
        .map((entry) => _invoiceItemFromDetailsEntry(entry))
        .toList(growable: false);
    final payments = await ref
        .read(transactionsRepositoryProvider)
        .getInvoicePayments(invoiceId);

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
        payments: payments
            .map(
              (payment) => InvoicePaymentDraft(
                id: payment.id.toString(),
                amount: payment.amount,
                recordedAt: payment.recordedAt,
              ),
            )
            .toList(growable: false),
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
        unit: _defaultInvoiceUnit(product),
        mainUnitName: product.mainUnitName,
        secondaryUnitName: product.secondaryUnitName,
        secondaryUnitRate: product.secondaryUnitRate,
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
                      unit: _defaultInvoiceUnit(
                        product,
                        currentUnit: item.unit,
                      ),
                      mainUnitName: product.mainUnitName,
                      secondaryUnitName: product.secondaryUnitName,
                      secondaryUnitRate: product.secondaryUnitRate,
                      secondaryQty: 0,
                    )
                  : item,
            )
            .toList(growable: false),
      ),
    );
  }

  void updateItemUnit(String id, ProductStockUnit unit) {
    final products = _products();

    _updateState(
      state.copyWith(
        items: state.items
            .map((item) {
              if (item.id != id) return item;

              final productId = item.productId;
              if (productId == null) return item;
              final product = state.findProductById(productId, products);
              if (product == null) return item;

              final resolvedUnit = item.availableUnits(product).contains(unit)
                  ? unit
                  : ProductStockUnit.main;
              final rate =
                  product.secondaryUnitRate ?? item.secondaryUnitRate ?? 0;
              final totalMainQuantity = item.quantityInMainUnit;
              final nextMainQuantity =
                  resolvedUnit == ProductStockUnit.secondary && rate > 0
                  ? math.max(1, (totalMainQuantity / rate).round())
                  : math.max(1, totalMainQuantity.round());
              final candidate = item.copyWith(
                unit: resolvedUnit,
                qty: nextMainQuantity,
                secondaryQty: 0,
              );

              return state.resolvedItemForQuantities(candidate, products);
            })
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

    final resolvedItem = state.resolvedItemForQuantities(
      targetItem,
      _products(),
      qty: quantity,
    );
    _updateState(
      state.copyWith(
        items: state.items
            .map((item) => item.id == id ? resolvedItem : item)
            .toList(growable: false),
      ),
    );
  }

  void updateItemSecondaryQuantity(String id, int quantity) {
    InvoiceItem? targetItem;
    for (final item in state.items) {
      if (item.id == id) {
        targetItem = item;
        break;
      }
    }
    if (targetItem == null) return;

    final resolvedItem = state.resolvedItemForQuantities(
      targetItem,
      _products(),
      secondaryQty: quantity,
    );
    _updateState(
      state.copyWith(
        items: state.items
            .map((item) => item.id == id ? resolvedItem : item)
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

  void addPayment({required double amount, DateTime? recordedAt}) {
    _updateState(
      state.copyWith(
        payments: [
          ...state.payments,
          InvoicePaymentDraft(
            id: _newPaymentId(),
            amount: amount.abs(),
            recordedAt: recordedAt ?? DateTime.now(),
          ),
        ],
      ),
    );
  }

  void updatePayment({required String id, required double amount}) {
    _updateState(
      state.copyWith(
        payments: state.payments
            .map(
              (payment) => payment.id == id
                  ? payment.copyWith(amount: amount.abs())
                  : payment,
            )
            .toList(growable: false),
      ),
    );
  }

  void removePayment(String id) {
    _updateState(
      state.copyWith(
        payments: state.payments
            .where((payment) => payment.id != id)
            .toList(growable: false),
      ),
    );
  }

  void markFullyPaidNow() {
    final remaining = state.remainingAmount;
    if (remaining <= 0) return;
    addPayment(amount: remaining, recordedAt: DateTime.now());
  }

  Future<void> saveInvoice() async {
    final contactId = int.tryParse(state.contact?.id ?? '');
    if (contactId == null) {
      throw StateError('Select a contact first.');
    }
    if (state.items.isEmpty) {
      throw StateError('Add at least one item.');
    }
    if (state.amountPaid > state.totalAmount) {
      throw StateError(LocaleKeys.amountExceedsTotal.tr());
    }

    final items = state.items
        .map((item) {
          final productId = int.tryParse(item.productId ?? '');
          if (productId == null) {
            throw StateError('Each item must have a product.');
          }

          return (
            productId: productId,
            quantity: item.quantityInMainUnit,
            unitPrice: item.price,
            totalPrice: item.subtotal,
          );
        })
        .toList(growable: false);

    final invoiceDao = ref.read(invoiceDaoProvider);
    final database = ref.read(appDatabaseProvider);
    final syncInvoiceLedger = ref.read(syncInvoiceLedgerUseCaseProvider);
    int savedInvoiceId = _loadedInvoiceId ?? 0;

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
      savedInvoiceId = invoiceId;

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
          status: state.paymentStatus.name,
          payments: state.payments
              .map(
                (payment) => InvoiceLedgerPaymentRequest(
                  amount: payment.amount,
                  recordedAt: payment.recordedAt,
                ),
              )
              .toList(growable: false),
        ),
      );

      _loadedInvoiceId ??= invoiceId;
    });

    ref.invalidate(invoiceListProvider);
    ref.invalidate(invoiceSummaryListProvider);
    ref.invalidate(invoiceItemsProvider(savedInvoiceId));
    ref.invalidate(invoiceDetailsProvider(savedInvoiceId));
    ref.invalidate(invoicePaymentRecordsProvider(savedInvoiceId));
    ref.invalidate(invoiceProductsProvider);
    ref.invalidate(unifiedTransactionFeedProvider);
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
    ref.invalidate(invoiceItemsProvider(invoiceId));
    ref.invalidate(invoiceDetailsProvider(invoiceId));
    ref.invalidate(invoicePaymentRecordsProvider(invoiceId));
    ref.invalidate(invoiceProductsProvider);
    ref.invalidate(unifiedTransactionFeedProvider);
  }
}
