import 'package:flutter/material.dart';
import 'package:sodais_finance/features/app/data/app_database.dart';
import 'package:sodais_finance/features/reports/domain/report_snapshot.dart';
import 'package:sodais_finance/features/transactions/domain/transaction_feed_entry.dart';
import 'package:sodais_finance/features/transactions/domain/transactions_repository.dart';

class ReportsQueryService {
  ReportsQueryService(this._db);

  final AppDatabase _db;

  Stream<ReportsSnapshot> watchSnapshot(ReportsFilter filter) {
    return _db
        .customSelect(
          '''
          SELECT
            (SELECT COUNT(*) FROM invoice_table) AS invoice_count,
            COALESCE((SELECT MAX(updated_at) FROM invoice_table), '') AS invoice_marker,
            (SELECT COUNT(*) FROM invoice_item_table) AS invoice_item_count,
            COALESCE((SELECT SUM(total_price) FROM invoice_item_table), 0) AS invoice_item_total,
            (SELECT COUNT(*) FROM person_table) AS person_count,
            COALESCE((SELECT MAX(updated_at) FROM person_table), '') AS person_marker,
            (SELECT COUNT(*) FROM product_table) AS product_count,
            COALESCE((SELECT MAX(updated_at) FROM product_table), '') AS product_marker,
            (SELECT COUNT(*) FROM transaction_table) AS transaction_count,
            COALESCE((SELECT SUM(amount) FROM transaction_table), 0) AS transaction_amount,
            COALESCE((SELECT MAX(date) FROM transaction_table), '') AS transaction_marker,
            (SELECT COUNT(*) FROM bank_account_table) AS bank_account_count,
            COALESCE((SELECT SUM(current_balance) FROM bank_account_table), 0) AS bank_balance_marker
          ''',
          readsFrom: {
            _db.invoiceTable,
            _db.invoiceItemTable,
            _db.personTable,
            _db.productTable,
            _db.transactionTable,
            _db.bankAccountTable,
          },
        )
        .watch()
        .asyncMap((_) => loadSnapshot(filter));
  }

  Future<ReportsSnapshot> loadSnapshot(ReportsFilter filter) async {
    final now = DateTime.now();
    final range = filter.resolveRange(now);

    final invoices = await _db.select(_db.invoiceTable).get();
    final invoiceItems = await _db.select(_db.invoiceItemTable).get();
    final persons = await _db.select(_db.personTable).get();
    final products = await _db.select(_db.productTable).get();
    final transactions = await _db.select(_db.transactionTable).get();
    final bankAccounts = await _db.select(_db.bankAccountTable).get();

    final personsById = {for (final person in persons) person.id: person};
    final productsById = {for (final product in products) product.id: product};
    final invoicesById = {for (final invoice in invoices) invoice.id: invoice};

    final periodInvoices = invoices
        .where((invoice) => _isInRange(invoice.issueDate, range))
        .toList(growable: false);
    final periodInvoiceIds = periodInvoices
        .map((invoice) => invoice.id)
        .toSet();
    final periodInvoiceItems = invoiceItems
        .where((item) => periodInvoiceIds.contains(item.invoiceId))
        .toList(growable: false);
    final periodTransactions = transactions
        .where(
          (transaction) =>
              transaction.referenceType != invoicePrincipalReferenceType &&
              _isInRange(transaction.date, range),
        )
        .toList(growable: false);

    final salesInvoices = periodInvoices
        .where((invoice) => invoice.type == 'sale')
        .toList(growable: false);
    final purchaseInvoices = periodInvoices
        .where((invoice) => invoice.type == 'purchase')
        .toList(growable: false);

    final invoiceStatuses = _buildInvoiceStatuses(periodInvoices);
    final inventoryHealth = _buildInventoryHealth(products);
    final recentActivity = _buildRecentActivity(
      invoices: periodInvoices,
      transactions: periodTransactions,
      personsById: personsById,
      invoicesById: invoicesById,
    );

    return ReportsSnapshot(
      filter: filter,
      range: range,
      summary: ReportsSummary(
        totalSales: _sumDoubles(
          salesInvoices.map((invoice) => invoice.finalAmount),
        ),
        totalPurchases: _sumDoubles(
          purchaseInvoices.map((invoice) => invoice.finalAmount),
        ),
        cashIn: _sumDoubles(
          periodTransactions
              .where((transaction) => transaction.type == 'income')
              .map((transaction) => transaction.amount),
        ),
        cashOut: _sumDoubles(
          periodTransactions
              .where((transaction) => transaction.type == 'expense')
              .map((transaction) => transaction.amount),
        ),
        invoiceCount: periodInvoices.length,
        salesCount: salesInvoices.length,
        purchaseCount: purchaseInvoices.length,
      ),
      currentPosition: ReportsCurrentPosition(
        cashOnHand: _sumDoubles(
          bankAccounts.map((account) => account.currentBalance),
        ),
        toCollect: _sumDoubles(
          persons
              .where((person) => (person.balance ?? 0) > 0)
              .map((person) => person.balance ?? 0),
        ),
        toPay: _sumDoubles(
          persons
              .where((person) => (person.balance ?? 0) < 0)
              .map((person) => (person.balance ?? 0).abs()),
        ),
        inventoryValue: _sumDoubles(
          products.map((product) => product.stock * product.purchasePrice),
        ),
        potentialRevenue: _sumDoubles(
          products.map((product) => product.stock * product.sellingPrice),
        ),
      ),
      invoiceStatuses: invoiceStatuses,
      inventoryHealth: inventoryHealth,
      topSellingProducts: _buildTopProducts(
        saleInvoices: salesInvoices,
        invoiceItems: periodInvoiceItems,
        productsById: productsById,
      ),
      topCustomers: _buildTopContacts(
        invoices: salesInvoices,
        personsById: personsById,
      ),
      topSuppliers: _buildTopContacts(
        invoices: purchaseInvoices,
        personsById: personsById,
      ),
      recentActivity: recentActivity,
    );
  }

  List<ReportInvoiceStatusItem> _buildInvoiceStatuses(
    List<InvoiceTableData> invoices,
  ) {
    final counts = <ReportInvoiceStatus, int>{
      ReportInvoiceStatus.paid: 0,
      ReportInvoiceStatus.partialPaid: 0,
      ReportInvoiceStatus.unpaid: 0,
    };
    final amounts = <ReportInvoiceStatus, double>{
      ReportInvoiceStatus.paid: 0,
      ReportInvoiceStatus.partialPaid: 0,
      ReportInvoiceStatus.unpaid: 0,
    };

    for (final invoice in invoices) {
      final status = switch (invoice.status) {
        'paid' => ReportInvoiceStatus.paid,
        'partial' || 'partialPaid' => ReportInvoiceStatus.partialPaid,
        _ => ReportInvoiceStatus.unpaid,
      };

      counts.update(status, (value) => value + 1);
      amounts.update(status, (value) => value + invoice.finalAmount);
    }

    return ReportInvoiceStatus.values
        .map(
          (status) => ReportInvoiceStatusItem(
            status: status,
            count: counts[status] ?? 0,
            amount: amounts[status] ?? 0,
          ),
        )
        .toList(growable: false);
  }

  ReportsInventoryHealth _buildInventoryHealth(
    List<ProductTableData> products,
  ) {
    final alerts =
        products
            .where(
              (product) =>
                  product.stock <= 0 ||
                  (product.reorderLevel > 0 &&
                      product.stock <= product.reorderLevel),
            )
            .map(
              (product) => ReportInventoryAlert(
                id: product.id.toString(),
                name: product.name,
                stock: product.stock,
                reorderLevel: product.reorderLevel,
                outOfStock: product.stock <= 0,
              ),
            )
            .toList(growable: false)
          ..sort((a, b) {
            if (a.outOfStock != b.outOfStock) {
              return a.outOfStock ? -1 : 1;
            }
            return a.stock.compareTo(b.stock);
          });

    return ReportsInventoryHealth(
      totalProducts: products.length,
      totalUnits: products.fold(0, (sum, product) => sum + product.stock),
      inStockCount: products.where((product) => product.stock > 0).length,
      lowStockCount: products
          .where(
            (product) =>
                product.stock > 0 &&
                product.reorderLevel > 0 &&
                product.stock <= product.reorderLevel,
          )
          .length,
      outOfStockCount: products.where((product) => product.stock <= 0).length,
      alerts: alerts.take(6).toList(growable: false),
    );
  }

  List<ReportTopProduct> _buildTopProducts({
    required List<InvoiceTableData> saleInvoices,
    required List<InvoiceItemTableData> invoiceItems,
    required Map<int, ProductTableData> productsById,
  }) {
    final saleInvoiceIds = saleInvoices.map((invoice) => invoice.id).toSet();
    final aggregates = <int, ({double quantity, double revenue})>{};

    for (final item in invoiceItems) {
      if (!saleInvoiceIds.contains(item.invoiceId)) continue;

      final current =
          aggregates[item.productId] ?? (quantity: 0.0, revenue: 0.0);
      aggregates[item.productId] = (
        quantity: current.quantity + item.quantity,
        revenue: current.revenue + item.totalPrice,
      );
    }

    final topProducts =
        aggregates.entries
            .map((entry) {
              final product = productsById[entry.key];
              return ReportTopProduct(
                id: entry.key.toString(),
                name: product?.name ?? 'Product #${entry.key}',
                quantity: entry.value.quantity,
                revenue: entry.value.revenue,
                currentStock: product?.stock ?? 0,
              );
            })
            .toList(growable: false)
          ..sort((a, b) {
            final revenueCompare = b.revenue.compareTo(a.revenue);
            if (revenueCompare != 0) return revenueCompare;
            return b.quantity.compareTo(a.quantity);
          });

    return topProducts.take(5).toList(growable: false);
  }

  List<ReportTopContact> _buildTopContacts({
    required List<InvoiceTableData> invoices,
    required Map<int, PersonTableData> personsById,
  }) {
    final aggregates = <int, ({double amount, int count})>{};

    for (final invoice in invoices) {
      final current = aggregates[invoice.contactId] ?? (amount: 0.0, count: 0);
      aggregates[invoice.contactId] = (
        amount: current.amount + invoice.finalAmount,
        count: current.count + 1,
      );
    }

    final contacts =
        aggregates.entries
            .map((entry) {
              final person = personsById[entry.key];
              return ReportTopContact(
                id: entry.key.toString(),
                name: person?.name ?? 'Contact #${entry.key}',
                amount: entry.value.amount,
                invoiceCount: entry.value.count,
              );
            })
            .toList(growable: false)
          ..sort((a, b) => b.amount.compareTo(a.amount));

    return contacts.take(5).toList(growable: false);
  }

  List<TransactionFeedEntry> _buildRecentActivity({
    required List<InvoiceTableData> invoices,
    required List<TransactionTableData> transactions,
    required Map<int, PersonTableData> personsById,
    required Map<int, InvoiceTableData> invoicesById,
  }) {
    final invoiceEntries = invoices
        .map(
          (invoice) => TransactionFeedEntry(
            kind: TransactionFeedEntryKind.invoice,
            id: invoice.id,
            occurredAt: invoice.issueDate,
            amount: invoice.finalAmount,
            amountPaid: invoice.amountPaid,
            entryType: invoice.type,
            referenceType: 'invoice',
            referenceId: invoice.id,
            status: invoice.status,
            invoiceNumber: invoice.invoiceNumber,
            contactName: personsById[invoice.contactId]?.name,
            description: null,
          ),
        )
        .toList(growable: false);

    final transactionEntries = transactions
        .map(
          (transaction) => TransactionFeedEntry(
            kind: TransactionFeedEntryKind.transaction,
            id: transaction.id,
            occurredAt: transaction.date,
            amount: transaction.amount,
            entryType: transaction.type,
            referenceType: transaction.referenceType,
            referenceId: transaction.referenceId,
            invoiceNumber:
                transaction.referenceType == invoicePaymentReferenceType
                ? invoicesById[transaction.referenceId]?.invoiceNumber
                : null,
            contactName: transaction.contactId == null
                ? null
                : personsById[transaction.contactId!]?.name,
            description: transaction.description,
          ),
        )
        .toList(growable: false);

    final combined = [...invoiceEntries, ...transactionEntries]
      ..sort((a, b) {
        final dateCompare = b.occurredAt.compareTo(a.occurredAt);
        if (dateCompare != 0) return dateCompare;
        return b.id.compareTo(a.id);
      });

    return combined.take(8).toList(growable: false);
  }

  bool _isInRange(DateTime date, DateTimeRange? range) {
    if (range == null) return true;
    return !date.isBefore(range.start) && !date.isAfter(range.end);
  }

  double _sumDoubles(Iterable<double> values) {
    return values.fold(0.0, (sum, value) => sum + value);
  }
}
