import 'package:drift/drift.dart';

class PersonTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 32)();
  TextColumn get image => text().nullable().withLength(max: 1024)();
  TextColumn get phone => text().nullable().withLength(max: 32)();
  TextColumn get address => text().nullable().withLength(max: 256)();
  TextColumn get email => text().nullable().withLength(max: 128)();
  TextColumn get type =>
      text().withDefault(const Constant('customer')).withLength(max: 16)();
  RealColumn get balance =>
      real().nullable().withDefault(const Constant(0.0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime()();
}
