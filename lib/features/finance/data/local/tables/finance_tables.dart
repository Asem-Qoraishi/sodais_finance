import 'package:drift/drift.dart';

class BankAccountTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(max: 64)();
  RealColumn get initialBalance => real().withDefault(const Constant(0.0))();
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();
}

class TransactionTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer()(); // FK -> BankAccountTable
  IntColumn get contactId => integer().nullable()(); // FK -> PersonTable
  RealColumn get amount => real()();
  TextColumn get type =>
      text().withLength(max: 16)(); // income, expense, transfer
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text().nullable()();
  TextColumn get referenceType =>
      text().withLength(max: 32)(); // invoice, check, installment, manual
  IntColumn get referenceId => integer()();
}
