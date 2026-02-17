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

part 'app_database.g.dart';

@DriftDatabase(
  tables: [PersonTable, ProductCategoryTable, ProductTable],
  daos: [PersonDao, ProductCategoryDao, ProductDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sodais_finance.db'));

    return NativeDatabase.createInBackground(file);
  });
}

final appDatabaseProvider = Provider((ref) => AppDatabase(_openConnection()));
