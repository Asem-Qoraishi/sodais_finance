import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:sodais_finance/features/persons/data/local/dao/person_dao.dart';
import 'package:sodais_finance/features/persons/data/local/tables/person_table.dart';
import 'package:sodais_finance/features/products/data/local/dao/product_category_dao.dart';
import 'package:sodais_finance/features/products/data/local/dao/product_dao.dart';
import 'package:sodais_finance/features/products/data/local/tables/product_category_table.dart';
import 'package:sodais_finance/features/products/data/local/tables/product_table.dart';
import 'package:sodais_finance/features/invoices/data/local/tables/invoice_tables.dart';
import 'package:sodais_finance/features/invoices/data/local/dao/invoice_dao.dart';
import 'package:sodais_finance/features/finance/data/local/tables/finance_tables.dart';
import 'package:sodais_finance/features/finance/data/local/tables/loan_check_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    PersonTable,
    ProductCategoryTable,
    ProductTable,
    InvoiceTable,
    InvoiceItemTable,
    BankAccountTable,
    TransactionTable,
    CheckTable,
    LoanTable,
    InstallmentTable,
  ],
  daos: [PersonDao, ProductCategoryDao, ProductDao, InvoiceDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 3) {
        await migrator.createTable(invoiceTable);
        await migrator.createTable(invoiceItemTable);
        await migrator.createTable(bankAccountTable);
        await migrator.createTable(transactionTable);
        await migrator.createTable(checkTable);
        await migrator.createTable(loanTable);
        await migrator.createTable(installmentTable);
      }
      if (from >= 3 && from < 4) {
        await migrator.addColumn(invoiceTable, invoiceTable.amountPaid);
        await customStatement('''
          UPDATE invoice_table
          SET amount_paid = CASE
            WHEN status = 'paid' THEN final_amount
            ELSE 0
          END
        ''');
      }
      if (from < 5) {
        await migrator.addColumn(productTable, productTable.mainUnitName);
        await migrator.addColumn(productTable, productTable.secondaryUnitName);
        await migrator.addColumn(productTable, productTable.secondaryUnitRate);
        await migrator.addColumn(productTable, productTable.stockUnit);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sodais_finance.db'));

    return NativeDatabase.createInBackground(file);
  });
}

final appDatabaseProvider = Provider((ref) => AppDatabase(_openConnection()));
