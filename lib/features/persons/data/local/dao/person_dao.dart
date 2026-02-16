import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/features/app/data/app_database.dart';
import 'package:sodais_finance/features/persons/data/local/tables/person_table.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';

part 'person_dao.g.dart';

@DriftAccessor(tables: [PersonTable])
class PersonDao extends DatabaseAccessor<AppDatabase> with _$PersonDaoMixin {
  PersonDao(super.db);

  Person _mapToPerson(PersonTableData row) {
    return Person(
      id: row.id.toString(),
      image: row.image,
      name: row.name,
      phone: row.phone,
      address: row.address,
      email: row.email,
      type: PersonType.fromValue(row.type),
      balance: row.balance ?? 0.0,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Stream<List<Person>> watchAllPersons() {
    final query = select(personTable)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

    return query.watch().map(
      (rows) => rows.map(_mapToPerson).toList(growable: false),
    );
  }

  Stream<Person?> watchPersonById(String id) {
    final intId = int.tryParse(id) ?? -1;
    final query = select(personTable)..where((t) => t.id.equals(intId));

    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapToPerson(row),
    );
  }

  Future<int> insertPerson(Person person) {
    return into(personTable).insert(
      PersonTableCompanion.insert(
        name: person.name,
        image: Value(person.image),
        phone: Value(person.phone),
        address: Value(person.address),
        email: Value(person.email),
        type: Value(person.type.value),
        balance: Value(person.balance),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<bool> updatePerson(Person person) {
    final intId = int.tryParse(person.id) ?? -1;
    return update(personTable).replace(
      PersonTableCompanion(
        id: Value(intId),
        name: Value(person.name),
        image: Value(person.image),
        phone: Value(person.phone),
        address: Value(person.address),
        email: Value(person.email),
        type: Value(person.type.value),
        balance: Value(person.balance),
        createdAt: Value(person.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deletePerson(String id) {
    final intId = int.tryParse(id) ?? -1;
    return (delete(personTable)..where((t) => t.id.equals(intId))).go();
  }
}

final personDaoProvider = Provider(
  (ref) => PersonDao(ref.watch(appDatabaseProvider)),
);
