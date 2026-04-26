import 'package:sodais_finance/features/transactions/domain/transaction_feed_entry.dart';

const invoicePrincipalReferenceType = 'invoice_principal';
const invoicePaymentReferenceType = 'invoice_payment';
const openingBalanceReferenceType = 'opening_balance';
const manualReferenceType = 'manual';

class InvoiceLedgerSyncRequest {
  const InvoiceLedgerSyncRequest({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.contactId,
    required this.invoiceType,
    required this.issueDate,
    required this.finalAmount,
    required this.amountPaid,
    required this.status,
  });

  final int invoiceId;
  final String invoiceNumber;
  final int contactId;
  final String invoiceType;
  final DateTime issueDate;
  final double finalAmount;
  final double amountPaid;
  final String status;

  bool get hasPayment =>
      amountPaid > 0 &&
      (status == 'paid' || status == 'partial' || status == 'partialPaid');
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

abstract class TransactionsRepository {
  Stream<List<TransactionFeedEntry>> watchUnifiedFeed();

  Future<void> syncInvoiceLedger(InvoiceLedgerSyncRequest request);

  Future<void> deleteInvoiceLedgerEntries(int invoiceId);

  Future<void> recordOpeningBalance(OpeningBalanceEntryRequest request);
}
