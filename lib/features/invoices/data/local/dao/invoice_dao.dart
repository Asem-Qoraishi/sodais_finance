import 'package:drift/drift.dart';
import 'package:sodais_finance/features/finance/data/local/tables/finance_tables.dart';
import 'package:sodais_finance/features/invoices/data/local/tables/invoice_tables.dart';
import 'package:sodais_finance/features/persons/data/local/tables/person_table.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/products/data/local/tables/product_table.dart';
import 'package:sodais_finance/features/products/domain/product.dart';
import '../../../../app/data/app_database.dart';

part 'invoice_dao.g.dart';

typedef InvoiceItemInput = ({
  int productId,
  double quantity,
  double unitPrice,
  double totalPrice,
});

class InvoiceSummary {
  const InvoiceSummary({
    required this.invoice,
    required this.contactName,
    required this.itemCount,
  });

  final InvoiceTableData invoice;
  final String contactName;
  final int itemCount;
}

class InvoiceDetails {
  const InvoiceDetails({
    required this.invoice,
    required this.contact,
    required this.items,
  });

  final InvoiceTableData invoice;
  final Person? contact;
  final List<InvoiceDetailsItem> items;
}

class InvoiceDetailsItem {
  const InvoiceDetailsItem({required this.item, required this.product});

  final InvoiceItemTableData item;
  final Product? product;
}

@DriftAccessor(
  tables: [
    InvoiceTable,
    InvoiceItemTable,
    ProductTable,
    PersonTable,
    BankAccountTable,
  ],
)
class InvoiceDao extends DatabaseAccessor<AppDatabase> with _$InvoiceDaoMixin {
  InvoiceDao(super.db);

  String _invoiceNumberForId(int id) => 'inv-$id';

  Person _mapPerson(PersonTableData row) {
    return Person(
      id: row.id.toString(),
      image: row.image,
      name: row.name,
      phone: row.phone,
      address: row.address,
      email: row.email,
      type: PersonType.fromValue(row.type),
      balance: row.balance ?? 0.0,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Product _mapProduct(ProductTableData row) {
    return Product(
      id: row.id.toString(),
      name: row.name,
      description: row.description,
      imagePath: row.imagePath,
      sku: row.sku,
      categoryId: row.categoryId?.toString(),
      categoryName: null,
      purchasePrice: row.purchasePrice,
      sellingPrice: row.sellingPrice,
      taxRate: row.taxRate,
      stock: row.stock,
      reorderLevel: row.reorderLevel,
      location: row.location,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Future<int> insertInvoice(Insertable<InvoiceTableData> invoice) =>
      into(invoiceTable).insert(invoice);

  Future<int> insertInvoiceItem(Insertable<InvoiceItemTableData> item) =>
      into(invoiceItemTable).insert(item);

  Future<List<InvoiceTableData>> getAllInvoices() => select(invoiceTable).get();

  Future<String> getNextInvoiceNumber() async {
    try {
      final sequenceRow = await customSelect(
        'SELECT seq FROM sqlite_sequence WHERE name = ? LIMIT 1',
        variables: [Variable<String>('invoice_table')],
      ).getSingleOrNull();
      final lastInsertedId = sequenceRow?.read<int>('seq');
      if (lastInsertedId != null) {
        return _invoiceNumberForId(lastInsertedId + 1);
      }
    } catch (_) {
      // Fall back to the current max id if sqlite_sequence is unavailable.
    }

    final latestInvoice =
        await (select(invoiceTable)
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.id)])
              ..limit(1))
            .getSingleOrNull();

    return _invoiceNumberForId((latestInvoice?.id ?? 0) + 1);
  }

  Future<List<InvoiceSummary>> getInvoiceSummaries() async {
    final invoices =
        await (select(invoiceTable)..orderBy([
              (tbl) => OrderingTerm.desc(tbl.createdAt),
              (tbl) => OrderingTerm.desc(tbl.id),
            ]))
            .get();

    if (invoices.isEmpty) return const [];

    final contactIds = invoices
        .map((invoice) => invoice.contactId)
        .toSet()
        .toList(growable: false);
    final contacts = await (select(
      personTable,
    )..where((tbl) => tbl.id.isIn(contactIds))).get();
    final contactNamesById = {
      for (final contact in contacts) contact.id: contact.name,
    };

    final invoiceIds = invoices
        .map((invoice) => invoice.id)
        .toList(growable: false);
    final invoiceItems = await (select(
      invoiceItemTable,
    )..where((tbl) => tbl.invoiceId.isIn(invoiceIds))).get();
    final itemCountByInvoiceId = <int, int>{};

    for (final item in invoiceItems) {
      itemCountByInvoiceId.update(
        item.invoiceId,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    return invoices
        .map(
          (invoice) => InvoiceSummary(
            invoice: invoice,
            contactName: contactNamesById[invoice.contactId] ?? '',
            itemCount: itemCountByInvoiceId[invoice.id] ?? 0,
          ),
        )
        .toList(growable: false);
  }

  Future<List<InvoiceItemTableData>> getItemsForInvoice(int invoiceId) =>
      (select(
        invoiceItemTable,
      )..where((tbl) => tbl.invoiceId.equals(invoiceId))).get();

  Future<InvoiceTableData?> getInvoiceById(int id) => (select(
    invoiceTable,
  )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<InvoiceDetails?> getInvoiceDetails(int invoiceId) async {
    final invoice = await getInvoiceById(invoiceId);
    if (invoice == null) return null;

    final contactRow = await (select(
      personTable,
    )..where((tbl) => tbl.id.equals(invoice.contactId))).getSingleOrNull();
    final items = await getItemsForInvoice(invoiceId);
    final productIds = items
        .map((item) => item.productId)
        .toSet()
        .toList(growable: false);
    final productRows = productIds.isEmpty
        ? const <ProductTableData>[]
        : await (select(
            productTable,
          )..where((tbl) => tbl.id.isIn(productIds))).get();
    final productsById = {
      for (final product in productRows) product.id: _mapProduct(product),
    };

    return InvoiceDetails(
      invoice: invoice,
      contact: contactRow == null ? null : _mapPerson(contactRow),
      items: items
          .map(
            (item) => InvoiceDetailsItem(
              item: item,
              product: productsById[item.productId],
            ),
          )
          .toList(growable: false),
    );
  }

  Map<int, int> _stockTrackedQuantities(List<InvoiceItemInput> items) {
    final quantities = <int, int>{};

    for (final item in items) {
      final quantity = item.quantity;
      if (quantity <= 0) {
        throw StateError('Quantity must be greater than zero.');
      }
      if (quantity != quantity.roundToDouble()) {
        throw StateError(
          'Stock-tracked invoices require whole-number quantities.',
        );
      }

      quantities.update(
        item.productId,
        (value) => value + quantity.toInt(),
        ifAbsent: () => quantity.toInt(),
      );
    }

    return quantities;
  }

  Map<int, int> _stockTrackedQuantitiesFromSavedItems(
    List<InvoiceItemTableData> items,
  ) {
    return _stockTrackedQuantities(
      items
          .map(
            (item) => (
              productId: item.productId,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              totalPrice: item.totalPrice,
            ),
          )
          .toList(growable: false),
    );
  }

  Future<void> _validateSaleStock(Map<int, int> quantities) async {
    for (final entry in quantities.entries) {
      final product = await (select(
        productTable,
      )..where((tbl) => tbl.id.equals(entry.key))).getSingleOrNull();

      if (product == null) {
        throw StateError('Product ${entry.key} was not found.');
      }
      if (entry.value > product.stock) {
        throw StateError(
          'Insufficient stock for ${product.name}. '
          'Available: ${product.stock}, requested: ${entry.value}.',
        );
      }
    }
  }

  Future<void> _applyStockAdjustments({
    required String type,
    required Map<int, int> quantities,
    bool revert = false,
  }) async {
    if (type != 'sale' && type != 'purchase') return;

    for (final entry in quantities.entries) {
      final product = await (select(
        productTable,
      )..where((tbl) => tbl.id.equals(entry.key))).getSingle();

      final quantityDelta = switch (type) {
        'sale' => revert ? entry.value : -entry.value,
        'purchase' => revert ? -entry.value : entry.value,
        _ => 0,
      };
      final nextStock = product.stock + quantityDelta;
      if (nextStock < 0) {
        throw StateError(
          'Cannot update ${product.name}. '
          'Current stock: ${product.stock}, required: ${entry.value}.',
        );
      }

      await (update(
        productTable,
      )..where((tbl) => tbl.id.equals(entry.key))).write(
        ProductTableCompanion(
          stock: Value(nextStock),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<int> saveInvoice({
    required String invoiceNumber,
    required int contactId,
    required String type,
    required DateTime issueDate,
    DateTime? dueDate,
    required double totalAmount,
    double discount = 0,
    double tax = 0,
    required double finalAmount,
    required double amountPaid,
    required String status,
    required List<InvoiceItemInput> items,
  }) async {
    final stockTrackedQuantities = _stockTrackedQuantities(items);

    return transaction(() async {
      if (type == 'sale') {
        await _validateSaleStock(stockTrackedQuantities);
      }

      final invoiceId = await insertInvoice(
        InvoiceTableCompanion.insert(
          invoiceNumber: invoiceNumber,
          contactId: contactId,
          type: type,
          issueDate: issueDate,
          dueDate: Value(dueDate),
          totalAmount: totalAmount,
          discount: Value(discount),
          tax: Value(tax),
          finalAmount: finalAmount,
          amountPaid: Value(amountPaid),
          status: status,
          updatedAt: DateTime.now(),
        ),
      );

      await (update(
        invoiceTable,
      )..where((tbl) => tbl.id.equals(invoiceId))).write(
        InvoiceTableCompanion(
          invoiceNumber: Value(_invoiceNumberForId(invoiceId)),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await batch((batch) {
        batch.insertAll(
          invoiceItemTable,
          items
              .map(
                (item) => InvoiceItemTableCompanion.insert(
                  invoiceId: invoiceId,
                  productId: item.productId,
                  quantity: item.quantity,
                  unitPrice: item.unitPrice,
                  totalPrice: item.totalPrice,
                ),
              )
              .toList(growable: false),
        );
      });

      await _applyStockAdjustments(
        type: type,
        quantities: stockTrackedQuantities,
      );

      return invoiceId;
    });
  }

  Future<void> updateInvoice({
    required int invoiceId,
    required String invoiceNumber,
    required int contactId,
    required String type,
    required DateTime issueDate,
    DateTime? dueDate,
    required double totalAmount,
    double discount = 0,
    double tax = 0,
    required double finalAmount,
    required double amountPaid,
    required String status,
    required List<InvoiceItemInput> items,
  }) async {
    final existingInvoice = await getInvoiceById(invoiceId);
    if (existingInvoice == null) {
      throw StateError('Invoice $invoiceId was not found.');
    }
    final existingItems = await getItemsForInvoice(invoiceId);
    final existingQuantities = _stockTrackedQuantitiesFromSavedItems(
      existingItems,
    );
    final nextQuantities = _stockTrackedQuantities(items);

    await transaction(() async {
      await _applyStockAdjustments(
        type: existingInvoice.type,
        quantities: existingQuantities,
        revert: true,
      );

      if (type == 'sale') {
        await _validateSaleStock(nextQuantities);
      }

      await (update(
        invoiceTable,
      )..where((tbl) => tbl.id.equals(invoiceId))).write(
        InvoiceTableCompanion(
          invoiceNumber: Value(invoiceNumber),
          contactId: Value(contactId),
          type: Value(type),
          issueDate: Value(issueDate),
          dueDate: Value(dueDate),
          totalAmount: Value(totalAmount),
          discount: Value(discount),
          tax: Value(tax),
          finalAmount: Value(finalAmount),
          amountPaid: Value(amountPaid),
          status: Value(status),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await (delete(
        invoiceItemTable,
      )..where((tbl) => tbl.invoiceId.equals(invoiceId))).go();

      await batch((batch) {
        batch.insertAll(
          invoiceItemTable,
          items
              .map(
                (item) => InvoiceItemTableCompanion.insert(
                  invoiceId: invoiceId,
                  productId: item.productId,
                  quantity: item.quantity,
                  unitPrice: item.unitPrice,
                  totalPrice: item.totalPrice,
                ),
              )
              .toList(growable: false),
        );
      });

      await _applyStockAdjustments(type: type, quantities: nextQuantities);
    });
  }

  Future<void> deleteInvoice(int id) async {
    final existingInvoice = await getInvoiceById(id);
    if (existingInvoice == null) return;
    final existingItems = await getItemsForInvoice(id);
    final existingQuantities = _stockTrackedQuantitiesFromSavedItems(
      existingItems,
    );

    await transaction(() async {
      await _applyStockAdjustments(
        type: existingInvoice.type,
        quantities: existingQuantities,
        revert: true,
      );
      await (delete(
        invoiceItemTable,
      )..where((tbl) => tbl.invoiceId.equals(id))).go();
      await (delete(invoiceTable)..where((tbl) => tbl.id.equals(id))).go();
    });
  }
}
