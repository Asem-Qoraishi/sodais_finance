// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_dao.dart';

// ignore_for_file: type=lint
mixin _$InvoiceDaoMixin on DatabaseAccessor<AppDatabase> {
  $InvoiceTableTable get invoiceTable => attachedDatabase.invoiceTable;
  $InvoiceItemTableTable get invoiceItemTable =>
      attachedDatabase.invoiceItemTable;
  $ProductCategoryTableTable get productCategoryTable =>
      attachedDatabase.productCategoryTable;
  $ProductTableTable get productTable => attachedDatabase.productTable;
  $PersonTableTable get personTable => attachedDatabase.personTable;
  $BankAccountTableTable get bankAccountTable =>
      attachedDatabase.bankAccountTable;
  InvoiceDaoManager get managers => InvoiceDaoManager(this);
}

class InvoiceDaoManager {
  final _$InvoiceDaoMixin _db;
  InvoiceDaoManager(this._db);
  $$InvoiceTableTableTableManager get invoiceTable =>
      $$InvoiceTableTableTableManager(_db.attachedDatabase, _db.invoiceTable);
  $$InvoiceItemTableTableTableManager get invoiceItemTable =>
      $$InvoiceItemTableTableTableManager(
        _db.attachedDatabase,
        _db.invoiceItemTable,
      );
  $$ProductCategoryTableTableTableManager get productCategoryTable =>
      $$ProductCategoryTableTableTableManager(
        _db.attachedDatabase,
        _db.productCategoryTable,
      );
  $$ProductTableTableTableManager get productTable =>
      $$ProductTableTableTableManager(_db.attachedDatabase, _db.productTable);
  $$PersonTableTableTableManager get personTable =>
      $$PersonTableTableTableManager(_db.attachedDatabase, _db.personTable);
  $$BankAccountTableTableTableManager get bankAccountTable =>
      $$BankAccountTableTableTableManager(
        _db.attachedDatabase,
        _db.bankAccountTable,
      );
}
