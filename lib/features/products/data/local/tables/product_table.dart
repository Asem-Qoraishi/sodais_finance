import 'package:drift/drift.dart';
import 'package:sodais_finance/features/products/data/local/tables/product_category_table.dart';

class ProductTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 128)();
  TextColumn get description => text().nullable().withLength(max: 2048)();
  TextColumn get imagePath => text().nullable().withLength(max: 1024)();
  TextColumn get sku => text().nullable().withLength(max: 128)();
  IntColumn get categoryId => integer().nullable().references(
    ProductCategoryTable,
    #id,
    onDelete: KeyAction.setNull,
  )();
  RealColumn get purchasePrice => real().withDefault(const Constant(0.0))();
  RealColumn get sellingPrice => real().withDefault(const Constant(0.0))();
  RealColumn get taxRate => real().withDefault(const Constant(0.0))();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  IntColumn get reorderLevel => integer().withDefault(const Constant(0))();
  TextColumn get location => text().nullable().withLength(max: 256)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime()();
}
