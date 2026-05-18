import 'package:drift/drift.dart';
import 'package:sodais_finance/features/app/data/app_database.dart';
import 'package:sodais_finance/features/transactions/domain/transaction_feed_entry.dart';
import 'package:sodais_finance/features/transactions/domain/transactions_repository.dart';

class TransactionsDriftStore {
  TransactionsDriftStore(this._db);

  final AppDatabase _db;

  static const _ledgerAccountTitle = 'System Ledger';
  static const _cashAccountTitle = 'System Cash';

  static const contactBalanceExpressionSql = '''
    COALESCE(SUM(
      CASE transaction_table.type
        WHEN 'expense' THEN transaction_table.amount
        WHEN 'income' THEN -transaction_table.amount
        ELSE 0
      END
    ), 0.0)
  ''';

  Stream<List<TransactionFeedEntry>> watchUnifiedFeed() {
    return _db
        .customSelect(
          '''
          SELECT *
          FROM (
            SELECT
              'invoice' AS entry_kind,
              invoice_table.id AS entry_id,
              invoice_table.issue_date AS occurred_at,
              invoice_table.final_amount AS amount,
              invoice_table.amount_paid AS amount_paid,
              invoice_table.due_date AS due_date,
              invoice_table.type AS entry_type,
              invoice_table.status AS status,
              invoice_table.invoice_number AS invoice_number,
              COALESCE(person_table.name, '') AS contact_name,
              '' AS description,
              'invoice' AS reference_type,
              invoice_table.id AS reference_id
            FROM invoice_table
            LEFT JOIN person_table
              ON person_table.id = invoice_table.contact_id

            UNION ALL

            SELECT
              'transaction' AS entry_kind,
              transaction_table.id AS entry_id,
              transaction_table.date AS occurred_at,
              transaction_table.amount AS amount,
              NULL AS amount_paid,
              NULL AS due_date,
              transaction_table.type AS entry_type,
              NULL AS status,
              COALESCE(invoice_table.invoice_number, '') AS invoice_number,
              COALESCE(person_table.name, '') AS contact_name,
              COALESCE(transaction_table.description, '') AS description,
              transaction_table.reference_type AS reference_type,
              transaction_table.reference_id AS reference_id
            FROM transaction_table
            LEFT JOIN person_table
              ON person_table.id = transaction_table.contact_id
            LEFT JOIN invoice_table
              ON invoice_table.id = transaction_table.reference_id
              AND transaction_table.reference_type = ?
            WHERE transaction_table.reference_type != ?
          )
          ORDER BY occurred_at DESC, entry_id DESC
          ''',
          variables: [
            Variable<String>(invoicePaymentReferenceType),
            Variable<String>(invoicePrincipalReferenceType),
          ],
          readsFrom: {_db.invoiceTable, _db.personTable, _db.transactionTable},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => TransactionFeedEntry(
                  kind: row.read<String>('entry_kind') == 'invoice'
                      ? TransactionFeedEntryKind.invoice
                      : TransactionFeedEntryKind.transaction,
                  id: row.read<int>('entry_id'),
                  occurredAt: row.read<DateTime>('occurred_at'),
                  amount: row.read<double>('amount'),
                  amountPaid: row.readNullable<double>('amount_paid'),
                  dueDate: row.readNullable<DateTime>('due_date'),
                  entryType: row.read<String>('entry_type'),
                  status: row.readNullable<String>('status'),
                  invoiceNumber: row.readNullable<String>('invoice_number'),
                  contactName: row.readNullable<String>('contact_name'),
                  description: row.readNullable<String>('description'),
                  referenceType: row.read<String>('reference_type'),
                  referenceId: row.read<int>('reference_id'),
                ),
              )
              .toList(growable: false),
        );
  }

  Future<List<InvoiceLedgerPaymentRecord>> getInvoicePayments(int invoiceId) {
    return (_db.select(_db.transactionTable)
          ..where(
            (tbl) =>
                tbl.referenceId.equals(invoiceId) &
                tbl.referenceType.equals(invoicePaymentReferenceType),
          )
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.date),
            (tbl) => OrderingTerm.asc(tbl.id),
          ]))
        .get()
        .then(
          (rows) => rows
              .map(
                (row) => InvoiceLedgerPaymentRecord(
                  id: row.id,
                  amount: row.amount,
                  recordedAt: row.date,
                ),
              )
              .toList(growable: false),
        );
  }

  Future<void> syncInvoiceLedger(InvoiceLedgerSyncRequest request) async {
    await _db.transaction(() async {
      final existingEntries = await _linkedInvoiceEntries(request.invoiceId);
      final paymentEntries = existingEntries
          .where((entry) => entry.referenceType == invoicePaymentReferenceType)
          .toList(growable: false);
      final paymentAccountId =
          _firstWhereOrNull(paymentEntries, (_) => true)?.accountId ??
          await _ensureCashAccountId();
      final ledgerAccountId = await _ensureLedgerAccountId();

      await _deleteLinkedEntries(existingEntries);
      await _insertPrincipalEntry(request: request, accountId: ledgerAccountId);
      for (final payment in request.payments) {
        await _insertPaymentEntry(
          invoiceId: request.invoiceId,
          contactId: request.contactId,
          invoiceNumber: request.invoiceNumber,
          invoiceType: request.invoiceType,
          recordedAt: payment.recordedAt,
          amount: payment.amount,
          accountId: paymentAccountId,
        );
      }
    });
  }

  Future<void> deleteInvoiceLedgerEntries(int invoiceId) async {
    await _db.transaction(() async {
      final existingEntries = await _linkedInvoiceEntries(invoiceId);
      await _deleteLinkedEntries(existingEntries);
    });
  }

  Future<void> recordOpeningBalance(OpeningBalanceEntryRequest request) async {
    if (request.amount == 0) return;

    await _db.transaction(() async {
      final accountId = await _ensureLedgerAccountId();
      await _db
          .into(_db.transactionTable)
          .insert(
            TransactionTableCompanion.insert(
              accountId: accountId,
              contactId: Value(request.contactId),
              amount: request.amount.abs(),
              type: request.amount.isNegative ? 'income' : 'expense',
              date: request.recordedAt,
              description: Value(
                request.description?.trim().isEmpty ?? true
                    ? 'Opening balance'
                    : request.description!.trim(),
              ),
              referenceType: openingBalanceReferenceType,
              referenceId: request.contactId,
            ),
          );
    });
  }

  Future<void> recordManualTransaction(ManualTransactionRequest request) async {
    if (request.amount <= 0) {
      throw StateError('Amount must be greater than zero.');
    }

    await _db.transaction(() async {
      final accountId = await _ensureCashAccountId();
      await _db
          .into(_db.transactionTable)
          .insert(
            TransactionTableCompanion.insert(
              accountId: accountId,
              contactId: Value(request.contactId),
              amount: request.amount.abs(),
              type: request.type,
              date: request.recordedAt,
              description: Value(_trimToNull(request.description)),
              referenceType: manualReferenceType,
              referenceId: request.contactId,
            ),
          );

      await _applyAccountDelta(
        accountId: accountId,
        amount: request.amount.abs(),
        type: request.type,
      );
    });
  }

  Future<void> _insertPrincipalEntry({
    required InvoiceLedgerSyncRequest request,
    required int accountId,
  }) async {
    await _db
        .into(_db.transactionTable)
        .insert(
          TransactionTableCompanion.insert(
            accountId: accountId,
            contactId: Value(request.contactId),
            amount: request.finalAmount.abs(),
            type: _principalTypeFor(request.invoiceType),
            date: request.issueDate,
            description: Value('Invoice principal ${request.invoiceNumber}'),
            referenceType: invoicePrincipalReferenceType,
            referenceId: request.invoiceId,
          ),
        );
  }

  Future<void> _insertPaymentEntry({
    required int invoiceId,
    required int contactId,
    required String invoiceNumber,
    required String invoiceType,
    required DateTime recordedAt,
    required double amount,
    required int accountId,
  }) async {
    final normalizedAmount = amount.abs();
    if (normalizedAmount <= 0) return;

    await _db
        .into(_db.transactionTable)
        .insert(
          TransactionTableCompanion.insert(
            accountId: accountId,
            contactId: Value(contactId),
            amount: normalizedAmount,
            type: _paymentTypeFor(invoiceType),
            date: recordedAt,
            description: Value('Invoice payment $invoiceNumber'),
            referenceType: invoicePaymentReferenceType,
            referenceId: invoiceId,
          ),
        );

    await _applyAccountDelta(
      accountId: accountId,
      amount: normalizedAmount,
      type: _paymentTypeFor(invoiceType),
    );
  }

  Future<List<TransactionTableData>> _linkedInvoiceEntries(int invoiceId) {
    return (_db.select(_db.transactionTable)..where(
          (tbl) =>
              tbl.referenceId.equals(invoiceId) &
              tbl.referenceType.isIn(const [
                invoicePrincipalReferenceType,
                invoicePaymentReferenceType,
              ]),
        ))
        .get();
  }

  Future<void> _deleteEntries(
    List<TransactionTableData> entries, {
    bool reverseAccountBalances = false,
  }) async {
    for (final entry in entries) {
      if (reverseAccountBalances &&
          entry.referenceType == invoicePaymentReferenceType) {
        await _applyAccountDelta(
          accountId: entry.accountId,
          amount: entry.amount,
          type: _reverseType(entry.type),
        );
      }
    }

    if (entries.isEmpty) return;

    final ids = entries.map((entry) => entry.id).toList(growable: false);
    await (_db.delete(
      _db.transactionTable,
    )..where((tbl) => tbl.id.isIn(ids))).go();
  }

  Future<void> _deleteLinkedEntries(List<TransactionTableData> entries) {
    return _deleteEntries(entries, reverseAccountBalances: true);
  }

  Future<int> _ensureLedgerAccountId() async {
    return _ensureAccountId(_ledgerAccountTitle);
  }

  Future<int> _ensureCashAccountId() async {
    return _ensureAccountId(_cashAccountTitle);
  }

  Future<int> _ensureAccountId(String title) async {
    final existing = await (_db.select(
      _db.bankAccountTable,
    )..where((tbl) => tbl.title.equals(title))).getSingleOrNull();
    if (existing != null) return existing.id;

    return _db
        .into(_db.bankAccountTable)
        .insert(
          BankAccountTableCompanion.insert(
            title: title,
            initialBalance: const Value(0),
            currentBalance: const Value(0),
          ),
        );
  }

  Future<void> _applyAccountDelta({
    required int accountId,
    required double amount,
    required String type,
  }) async {
    final account = await (_db.select(
      _db.bankAccountTable,
    )..where((tbl) => tbl.id.equals(accountId))).getSingleOrNull();
    if (account == null) return;

    final delta = switch (type) {
      'income' => amount,
      'expense' => -amount,
      _ => 0.0,
    };

    await (_db.update(
      _db.bankAccountTable,
    )..where((tbl) => tbl.id.equals(accountId))).write(
      BankAccountTableCompanion(
        currentBalance: Value(account.currentBalance + delta),
      ),
    );
  }

  String _principalTypeFor(String invoiceType) {
    return switch (invoiceType) {
      'sale' => 'expense',
      'purchase' => 'income',
      'returned' => 'income',
      _ => 'expense',
    };
  }

  String _paymentTypeFor(String invoiceType) {
    return switch (invoiceType) {
      'sale' => 'income',
      'purchase' => 'expense',
      'returned' => 'expense',
      _ => 'income',
    };
  }

  String _reverseType(String type) {
    return switch (type) {
      'income' => 'expense',
      'expense' => 'income',
      _ => type,
    };
  }

  T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T item) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }

  String? _trimToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
