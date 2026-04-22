import 'package:drift/drift.dart';

class CheckTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get contactId => integer()(); // FK -> PersonTable
  TextColumn get bankName => text().withLength(max: 64)();
  TextColumn get chequeNumber => text().withLength(max: 32)();
  RealColumn get amount => real()();
  DateTimeColumn get issueDate => dateTime()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get type => text().withLength(max: 16)(); // payable, receivable
  TextColumn get status =>
      text().withLength(max: 16)(); // pending, cashed, bounced, returned
}

class LoanTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(max: 64)();
  RealColumn get totalAmount => real()();
  IntColumn get accountId => integer()(); // FK -> BankAccountTable
  DateTimeColumn get startDate => dateTime()();
}

class InstallmentTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get loanId => integer()(); // FK -> LoanTable
  DateTimeColumn get dueDate => dateTime()();
  RealColumn get amount => real()();
  TextColumn get status => text().withLength(max: 16)(); // paid, unpaid
  RealColumn get penaltyFee => real().withDefault(const Constant(0.0))();
}
