import 'package:sodais_finance/features/transactions/domain/transaction_feed_entry.dart';

const invoicePrincipalReferenceType = 'invoice_principal';
const invoicePaymentReferenceType = 'invoice_payment';
const openingBalanceReferenceType = 'opening_balance';
const manualReferenceType = 'manual';

class InvoiceLedgerPaymentRequest {
  const InvoiceLedgerPaymentRequest({
    required this.amount,
    required this.recordedAt,
  });

  final double amount;
  final DateTime recordedAt;
}

class InvoiceLedgerPaymentRecord {
  const InvoiceLedgerPaymentRecord({
    required this.id,
    required this.amount,
    required this.recordedAt,
  });

  final int id;
  final double amount;
  final DateTime recordedAt;
}

class InvoiceLedgerSyncRequest {
  const InvoiceLedgerSyncRequest({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.contactId,
    required this.invoiceType,
    required this.issueDate,
    required this.finalAmount,
    required this.status,
    this.payments = const [],
  });

  final int invoiceId;
  final String invoiceNumber;
  final int contactId;
  final String invoiceType;
  final DateTime issueDate;
  final double finalAmount;
  final String status;
  final List<InvoiceLedgerPaymentRequest> payments;

  double get amountPaid =>
      payments.fold(0.0, (sum, payment) => sum + payment.amount);

  bool get hasPayment => amountPaid > 0;
}

class OpeningBalanceEntryRequest {
  const OpeningBalanceEntryRequest({
    required this.contactId,
    required this.amount,
    required this.recordedAt,
    this.description,
  });

  final int contactId;
  final double amount;
  final DateTime recordedAt;
  final String? description;
}

class ManualTransactionRequest {
  const ManualTransactionRequest({
    required this.contactId,
    required this.amount,
    required this.type,
    required this.recordedAt,
    this.description,
  });

  final int contactId;
  final double amount;
  final String type;
  final DateTime recordedAt;
  final String? description;
}

abstract class TransactionsRepository {
  Stream<List<TransactionFeedEntry>> watchUnifiedFeed();

  Future<List<InvoiceLedgerPaymentRecord>> getInvoicePayments(int invoiceId);

  Future<void> syncInvoiceLedger(InvoiceLedgerSyncRequest request);

  Future<void> deleteInvoiceLedgerEntries(int invoiceId);

  Future<void> recordOpeningBalance(OpeningBalanceEntryRequest request);

  Future<void> recordManualTransaction(ManualTransactionRequest request);
}
