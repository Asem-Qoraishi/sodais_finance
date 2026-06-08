import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/utils/formatters/app_number_formatter.dart';
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
const _itemEpsilon = 0.000001;

class InvoicePaymentDraft {
  const InvoicePaymentDraft({
    required this.id,
    required this.amount,
    required this.recordedAt,
  });

  final String id;
  final double amount;
  final DateTime recordedAt;

  InvoicePaymentDraft copyWith({
    String? id,
    double? amount,
    DateTime? recordedAt,
  }) {
    return InvoicePaymentDraft(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
}

class InvoiceItem {
  const InvoiceItem({
    required this.id,
    this.productId,
    required this.name,
    this.inventoryId,
    required this.qty,
    this.secondaryQty = 0,
    required this.price,
    this.unit = ProductStockUnit.main,
    this.mainUnitName = 'item',
    this.secondaryUnitName,
    this.secondaryUnitRate,
  });

  final String id;
  final String? productId;
  final String name;
  final String? inventoryId;
  final int qty;
  final int secondaryQty;
  final double price;
  final ProductStockUnit unit;
  final String mainUnitName;
  final String? secondaryUnitName;
  final double? secondaryUnitRate;

  factory InvoiceItem.empty(String id) {
    return const InvoiceItem(
      id: '',
      qty: 1,
      price: 0,
      name: '',
    ).copyWith(id: id);
  }

  bool get hasSecondaryUnit {
    final secondaryName = secondaryUnitName?.trim() ?? '';
    return secondaryName.isNotEmpty && (secondaryUnitRate ?? 0) > 0;
  }

  bool get usesSecondaryUnit =>
      unit == ProductStockUnit.secondary && hasSecondaryUnit;

  String get unitName {
    if (usesSecondaryUnit) {
      return secondaryUnitName!.trim();
    }
    return mainUnitName.trim();
  }

  double get quantityInMainUnit {
    if (usesSecondaryUnit) return qty * secondaryUnitRate!;
    return qty.toDouble();
  }

  double get subtotal => quantityInMainUnit * price;

  List<ProductStockUnit> availableUnits(Product? product) {
    final supportsSecondary = product?.hasSecondaryUnit ?? hasSecondaryUnit;
    if (!supportsSecondary) {
      return const [ProductStockUnit.main];
    }
    return const [ProductStockUnit.main, ProductStockUnit.secondary];
  }

  int trackedQuantityFor(Product product) {
    final rate = product.secondaryUnitRate ?? secondaryUnitRate ?? 0;
    final totalMainQuantity = quantityInMainUnit;

    if (product.stockUnit == ProductStockUnit.secondary &&
        product.hasSecondaryUnit &&
        rate > 0) {
      return math.max((totalMainQuantity / rate).ceil(), 1);
    }

    return math.max(totalMainQuantity.ceil(), 1);
  }

  int trackedStepFor(Product product) {
    final rate = product.secondaryUnitRate ?? secondaryUnitRate ?? 0;
    if (rate <= 0) return 1;

    if (product.stockUnit == ProductStockUnit.secondary &&
        product.hasSecondaryUnit) {
      return usesSecondaryUnit ? 1 : 1;
    }

    if (usesSecondaryUnit) {
      return math.max(rate.round(), 1);
    }

    return 1;
  }

  int quantityStepFor(Product product) {
    return 1;
  }

  InvoiceItem copyWith({
    String? id,
    Object? productId = _invoiceUnset,
    String? name,
    Object? inventoryId = _invoiceUnset,
    int? qty,
    int? secondaryQty,
    double? price,
    ProductStockUnit? unit,
    String? mainUnitName,
    Object? secondaryUnitName = _invoiceUnset,
    Object? secondaryUnitRate = _invoiceUnset,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      productId: identical(productId, _invoiceUnset)
          ? this.productId
          : productId as String?,
      name: name ?? this.name,
      inventoryId: identical(inventoryId, _invoiceUnset)
          ? this.inventoryId
          : inventoryId as String?,
      qty: qty ?? this.qty,
      secondaryQty: secondaryQty ?? this.secondaryQty,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      mainUnitName: mainUnitName ?? this.mainUnitName,
      secondaryUnitName: identical(secondaryUnitName, _invoiceUnset)
          ? this.secondaryUnitName
          : secondaryUnitName as String?,
      secondaryUnitRate: identical(secondaryUnitRate, _invoiceUnset)
          ? this.secondaryUnitRate
          : secondaryUnitRate as double?,
    );
  }
}

class InvoiceState {
  const InvoiceState({
    this.type = InvoiceType.sale,
    this.contact,
    this.invoiceNumber = '',
    required this.date,
    this.dueDate,
    this.items = const [],
    this.payments = const [],
    this.editingStockAllowanceByProduct = const {},
    this.taxRate = 0.0,
    this.discount = 0.0,
  });

  final InvoiceType type;
  final Person? contact;
  final String invoiceNumber;
  final DateTime date;
  final DateTime? dueDate;
  final List<InvoiceItem> items;
  final List<InvoicePaymentDraft> payments;
  final Map<String, int> editingStockAllowanceByProduct;
  final double taxRate;
  final double discount;

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get taxAmount => subtotal * (taxRate / 100);
  double get totalAmount => math.max(0.0, (subtotal + taxAmount) - discount);
  double get amountPaid =>
      payments.fold(0.0, (sum, payment) => sum + payment.amount);
  double get remainingAmount => math.max(0.0, totalAmount - amountPaid);

  PaymentStatus get paymentStatus {
    if (amountPaid <= 0) return PaymentStatus.unpaid;
    if (remainingAmount <= 0) return PaymentStatus.paid;
    return PaymentStatus.partialPaid;
  }

  InvoiceState copyWith({
    InvoiceType? type,
    Object? contact = _invoiceUnset,
    String? invoiceNumber,
    DateTime? date,
    Object? dueDate = _invoiceUnset,
    List<InvoiceItem>? items,
    List<InvoicePaymentDraft>? payments,
    Map<String, int>? editingStockAllowanceByProduct,
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
      payments: payments ?? this.payments,
      editingStockAllowanceByProduct:
          editingStockAllowanceByProduct ?? this.editingStockAllowanceByProduct,
      taxRate: taxRate ?? this.taxRate,
      discount: discount ?? this.discount,
    );
  }
}

String formatInvoiceAmount(num value) {
  return AppNumberFormatter.formatDecimal(value);
}

bool isWholeInvoiceQuantity(double value) {
  return (value - value.roundToDouble()).abs() < _itemEpsilon;
}

extension InvoiceStateProductX on InvoiceState {
  Product? findProductById(String productId, List<Product> products) {
    for (final product in products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  int allocatedQuantityForProduct(Product product, {String? excludingItemId}) {
    var allocatedQuantity = 0;
    for (final item in items) {
      if (item.productId != product.id || item.id == excludingItemId) {
        continue;
      }
      allocatedQuantity += item.trackedQuantityFor(product);
    }
    return allocatedQuantity;
  }

  int remainingStockForProduct(Product product, {String? excludingItemId}) {
    if (!type.tracksStock) return product.stock;

    final remainingStock =
        product.stock +
        (editingStockAllowanceByProduct[product.id] ?? 0) -
        allocatedQuantityForProduct(product, excludingItemId: excludingItemId);

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

    final nextItem = resolvedItemForQuantities(
      item,
      products,
      qty: item.qty + 1,
    );
    return nextItem.qty > item.qty;
  }

  bool canIncrementSecondaryItem(InvoiceItem item, List<Product> products) {
    return false;
  }

  int resolvedQuantityForItem(
    InvoiceItem item,
    int quantity,
    List<Product> products,
  ) {
    return resolvedItemForQuantities(item, products, qty: quantity).qty;
  }

  InvoiceItem resolvedItemForQuantities(
    InvoiceItem item,
    List<Product> products, {
    int? qty,
    int? secondaryQty,
  }) {
    final candidate = item.copyWith(
      qty: math.max(qty ?? item.qty, 1),
      secondaryQty: 0,
    );

    InvoiceItem ensurePositive(InvoiceItem nextItem) {
      if (nextItem.quantityInMainUnit > 0) return nextItem;
      return nextItem.copyWith(qty: 1, secondaryQty: 0);
    }

    InvoiceItem clampToMainQuantity(InvoiceItem nextItem, double maxQuantity) {
      final safeMax = math.max(maxQuantity, 1);
      final unitMultiplier = nextItem.usesSecondaryUnit
          ? nextItem.secondaryUnitRate ?? 1
          : 1;
      final clampedQuantity = math.max((safeMax / unitMultiplier).floor(), 1);
      return nextItem.copyWith(qty: clampedQuantity, secondaryQty: 0);
    }

    if (!type.tracksStock || item.productId == null) {
      return ensurePositive(candidate);
    }

    final product = findProductById(item.productId!, products);
    if (product == null) return ensurePositive(candidate);

    final maxTrackedQuantity = remainingStockForProduct(
      product,
      excludingItemId: item.id,
    );
    final rate = product.secondaryUnitRate ?? item.secondaryUnitRate ?? 0;
    final maxMainQuantity =
        product.stockUnit == ProductStockUnit.secondary &&
            product.hasSecondaryUnit &&
            rate > 0
        ? maxTrackedQuantity * rate
        : maxTrackedQuantity.toDouble();

    if (candidate.quantityInMainUnit <= maxMainQuantity) {
      return ensurePositive(candidate);
    }

    return clampToMainQuantity(candidate, maxMainQuantity);
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
