import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sodais_finance/features/persons/data/local/dao/person_dao.dart';
import 'package:sodais_finance/features/persons/data/local/tables/person_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [PersonTable], daos: [PersonDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sodais_finance.db'));

    return NativeDatabase.createInBackground(file);
  });
}

final appDatabaseProvider = Provider((ref) => AppDatabase(_openConnection()));
