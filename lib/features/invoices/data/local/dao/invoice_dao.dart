import 'package:drift/drift.dart';
import 'package:sodais_finance/features/finance/data/local/tables/finance_tables.dart';
import 'package:sodais_finance/features/invoices/data/local/tables/invoice_tables.dart';
import 'package:sodais_finance/features/persons/data/local/tables/person_table.dart';
import 'package:sodais_finance/features/products/data/local/tables/product_table.dart';
import '../../../../app/data/app_database.dart';

part 'invoice_dao.g.dart';

typedef InvoiceItemInput = ({
  int productId,
  double quantity,
  double unitPrice,
  double totalPrice,
});

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

  Future<int> insertInvoice(Insertable<InvoiceTableData> invoice) =>
      into(invoiceTable).insert(invoice);

  Future<int> insertInvoiceItem(Insertable<InvoiceItemTableData> item) =>
      into(invoiceItemTable).insert(item);

  Future<List<InvoiceTableData>> getAllInvoices() => select(invoiceTable).get();

  Future<List<InvoiceItemTableData>> getItemsForInvoice(int invoiceId) =>
      (select(
        invoiceItemTable,
      )..where((tbl) => tbl.invoiceId.equals(invoiceId))).get();

  Future<InvoiceTableData?> getInvoiceById(int id) => (select(
    invoiceTable,
  )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

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
  }) async {
    if (type != 'sale' && type != 'purchase') return;

    for (final entry in quantities.entries) {
      final product = await (select(
        productTable,
      )..where((tbl) => tbl.id.equals(entry.key))).getSingle();

      final nextStock = type == 'sale'
          ? product.stock - entry.value
          : product.stock + entry.value;

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
          status: status,
          updatedAt: DateTime.now(),
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

  Future<void> deleteInvoice(int id) async {
    await transaction(() async {
      await (delete(
        invoiceItemTable,
      )..where((tbl) => tbl.invoiceId.equals(id))).go();
      await (delete(invoiceTable)..where((tbl) => tbl.id.equals(id))).go();
    });
  }
}
