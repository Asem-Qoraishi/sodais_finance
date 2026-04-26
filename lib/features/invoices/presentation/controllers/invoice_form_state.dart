import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/products/domain/product.dart';

enum InvoiceType {
  sale,
  purchase,
  returned;

  String get label => switch (this) {
    sale => LocaleKeys.sale.tr(),
    purchase => LocaleKeys.purchase.tr(),
    returned => LocaleKeys.returned.tr(),
  };

  String get createTitle => switch (this) {
    sale => LocaleKeys.addNewSale.tr(),
    purchase => LocaleKeys.addNewPurchase.tr(),
    returned => LocaleKeys.returned.tr(),
  };

  String get contactLabel => switch (this) {
    purchase => LocaleKeys.supplier.tr(),
    _ => LocaleKeys.customer.tr(),
  };

  bool get tracksStock => this == InvoiceType.sale;

  double unitPriceFor(Product product) {
    return this == InvoiceType.purchase
        ? product.purchasePrice
        : product.sellingPrice;
  }
}

enum PaymentStatus {
  paid,
  unpaid,
  partialPaid;

  String get label => switch (this) {
    paid => LocaleKeys.paid.tr(),
    unpaid => LocaleKeys.unpaid.tr(),
    partialPaid => LocaleKeys.partialPaid.tr(),
  };
}

const _invoiceUnset = Object();

class InvoiceItem {
  final String id;
  final String? productId;
  final String name;
  final String? inventoryId;
  final int qty;
  final double price;

  const InvoiceItem({
    required this.id,
    this.productId,
    required this.name,
    this.inventoryId,
    required this.qty,
    required this.price,
  });

  factory InvoiceItem.empty(String id) {
    return InvoiceItem(id: id, qty: 1, price: 0, name: '', inventoryId: null);
  }

  double get subtotal => qty * price;

  InvoiceItem copyWith({
    Object? productId = _invoiceUnset,
    String? name,
    Object? inventoryId = _invoiceUnset,
    int? qty,
    double? price,
  }) {
    return InvoiceItem(
      id: id,
      productId: identical(productId, _invoiceUnset)
          ? this.productId
          : productId as String?,
      name: name ?? this.name,
      inventoryId: identical(inventoryId, _invoiceUnset)
          ? this.inventoryId
          : inventoryId as String?,
      qty: qty ?? this.qty,
      price: price ?? this.price,
    );
  }
}

class InvoiceState {
  final InvoiceType type;
  final Person? contact;
  final String invoiceNumber;
  final DateTime date;
  final DateTime? dueDate;
  final List<InvoiceItem> items;
  final Map<String, int> editingStockAllowanceByProduct;
  final PaymentStatus paymentStatus;
  final double amountPaid;
  final double taxRate;
  final double discount;

  const InvoiceState({
    this.type = InvoiceType.sale,
    this.contact,
    this.invoiceNumber = '',
    required this.date,
    this.dueDate,
    this.items = const [],
    this.editingStockAllowanceByProduct = const {},
    this.paymentStatus = PaymentStatus.paid,
    this.amountPaid = 0.0,
    this.taxRate = 0.0,
    this.discount = 0.0,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get taxAmount => subtotal * (taxRate / 100);
  double get totalAmount => math.max(0.0, (subtotal + taxAmount) - discount);
  double get remainingAmount => math.max(0.0, totalAmount - amountPaid);

  InvoiceState copyWith({
    InvoiceType? type,
    Object? contact = _invoiceUnset,
    String? invoiceNumber,
    DateTime? date,
    Object? dueDate = _invoiceUnset,
    List<InvoiceItem>? items,
    Map<String, int>? editingStockAllowanceByProduct,
    PaymentStatus? paymentStatus,
    double? amountPaid,
    double? taxRate,
    double? discount,
  }) {
    return InvoiceState(
      type: type ?? this.type,
      contact: identical(contact, _invoiceUnset)
          ? this.contact
          : contact as Person?,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      date: date ?? this.date,
      dueDate: identical(dueDate, _invoiceUnset)
          ? this.dueDate
          : dueDate as DateTime?,
      items: items ?? this.items,
      editingStockAllowanceByProduct:
          editingStockAllowanceByProduct ?? this.editingStockAllowanceByProduct,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amountPaid: amountPaid ?? this.amountPaid,
      taxRate: taxRate ?? this.taxRate,
      discount: discount ?? this.discount,
    );
  }
}

String formatInvoiceAmount(num value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2);
}

extension InvoiceStateProductX on InvoiceState {
  Product? findProductById(String productId, List<Product> products) {
    for (final product in products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  int allocatedQuantityForProduct(String productId, {String? excludingItemId}) {
    var allocatedQuantity = 0;
    for (final item in items) {
      if (item.productId != productId || item.id == excludingItemId) continue;
      allocatedQuantity += item.qty;
    }
    return allocatedQuantity;
  }

  int remainingStockForProduct(Product product, {String? excludingItemId}) {
    if (!type.tracksStock) return product.stock;

    final remainingStock =
        product.stock +
        (editingStockAllowanceByProduct[product.id] ?? 0) -
        allocatedQuantityForProduct(
          product.id,
          excludingItemId: excludingItemId,
        );

    return remainingStock < 0 ? 0 : remainingStock;
  }

  bool canUseProduct(Product product, {String? excludingItemId}) {
    if (!type.tracksStock) return true;
    return remainingStockForProduct(product, excludingItemId: excludingItemId) >
        0;
  }

  List<Product> selectableProductsForItem(
    List<Product> products,
    InvoiceItem item,
  ) {
    if (!type.tracksStock) return products;

    return products
        .where((product) {
          if (product.id == item.productId) return true;
          return canUseProduct(product, excludingItemId: item.id);
        })
        .toList(growable: false);
  }

  bool canAddItems(List<Product> products) {
    if (products.isEmpty) return false;
    if (!type.tracksStock) return true;

    for (final product in products) {
      if (canUseProduct(product)) return true;
    }

    return false;
  }

  bool canIncrementItem(InvoiceItem item, List<Product> products) {
    if (!type.tracksStock || item.productId == null) return true;

    final product = findProductById(item.productId!, products);
    if (product == null) return true;

    return item.qty <
        remainingStockForProduct(product, excludingItemId: item.id);
  }

  int resolvedQuantityForItem(
    InvoiceItem item,
    int quantity,
    List<Product> products,
  ) {
    final normalizedQuantity = math.max(quantity, 1);
    if (!type.tracksStock || item.productId == null) {
      return normalizedQuantity;
    }

    final product = findProductById(item.productId!, products);
    if (product == null) return normalizedQuantity;

    final maxQuantity = remainingStockForProduct(
      product,
      excludingItemId: item.id,
    );
    if (maxQuantity < 1) return 1;

    return normalizedQuantity.clamp(1, maxQuantity).toInt();
  }

  Product? suggestedProduct(List<Product> products) {
    if (products.isEmpty) return null;

    final selectedIds = items
        .map((item) => item.productId)
        .whereType<String>()
        .toSet();

    for (final product in products) {
      if (!selectedIds.contains(product.id) && canUseProduct(product)) {
        return product;
      }
    }

    for (final product in products) {
      if (canUseProduct(product)) return product;
    }

    return null;
  }
}
