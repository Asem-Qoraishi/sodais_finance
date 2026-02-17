import 'package:drift/drift.dart';

class ProductCategoryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 128).unique()();
  TextColumn get icon =>
      text().withLength(max: 64).withDefault(const Constant('inventory_2'))();
  TextColumn get colorHex =>
      text().withLength(max: 16).withDefault(const Constant('#1C74E9'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime()();
}
