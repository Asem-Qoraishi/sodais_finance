import 'package:drift/drift.dart';

class ActivityTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get type => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}
