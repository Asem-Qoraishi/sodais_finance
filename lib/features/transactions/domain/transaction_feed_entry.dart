enum TransactionFeedEntryKind { invoice, transaction }

class TransactionFeedEntry {
  const TransactionFeedEntry({
    required this.kind,
    required this.id,
    required this.occurredAt,
    required this.amount,
    required this.entryType,
    required this.referenceType,
    required this.referenceId,
    this.contactId,
    this.amountPaid,
    this.dueDate,
    this.status,
    this.invoiceNumber,
    this.contactName,
    this.description,
  });

  final TransactionFeedEntryKind kind;
  final int id;
  final DateTime occurredAt;
  final double amount;
  final int? contactId;
  final double? amountPaid;
  final DateTime? dueDate;
  final String entryType;
  final String referenceType;
  final int referenceId;
  final String? status;
  final String? invoiceNumber;
  final String? contactName;
  final String? description;

  bool get isInvoice => kind == TransactionFeedEntryKind.invoice;
}
