import 'package:drift/drift.dart';

class InvoiceTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get invoiceNumber => text().withLength(max: 32)();
  IntColumn get contactId => integer()(); // FK -> PersonTable
  TextColumn get type =>
      text().withLength(max: 16)(); // sale, purchase, pre_invoice, return
  DateTimeColumn get issueDate => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  RealColumn get totalAmount => real()();
  RealColumn get discount => real().withDefault(const Constant(0.0))();
  RealColumn get tax => real().withDefault(const Constant(0.0))();
  RealColumn get finalAmount => real()();
  RealColumn get amountPaid => real().withDefault(const Constant(0.0))();
  TextColumn get status =>
      text().withLength(max: 16)(); // paid, unpaid, partial

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime()();
}

class InvoiceItemTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get invoiceId => integer()(); // FK -> InvoiceTable
  IntColumn get productId => integer()(); // FK -> ProductTable
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get totalPrice => real()();
}
