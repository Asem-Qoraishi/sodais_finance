import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/features/app/data/app_database.dart';
import 'package:sodais_finance/features/persons/data/local/tables/person_table.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/persons/domain/persons_query_options.dart';

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

  Stream<List<Person>> watchPersons({
    required String query,
    required PersonTypeFilter typeFilter,
    required PersonsOrderBy orderBy,
    int page = 0,
    int pageSize = personsPageSize,
  }) {
    final queryBuilder = select(personTable);
    final normalizedQuery = query.trim();
    final resolvedPage = page < 0 ? 0 : page;
    final resolvedPageSize = pageSize <= 0 ? personsPageSize : pageSize;
    final offset = resolvedPage * resolvedPageSize;

    if (normalizedQuery.isNotEmpty) {
      final pattern = '%$normalizedQuery%';
      queryBuilder.where((t) {
        final phone = coalesce<String>([t.phone, const Constant('')]);
        final email = coalesce<String>([t.email, const Constant('')]);
        final address = coalesce<String>([t.address, const Constant('')]);

        return t.name.like(pattern) |
            phone.like(pattern) |
            email.like(pattern) |
            address.like(pattern) |
            t.type.like(pattern);
      });
    }

    _applyTypeFilter(queryBuilder, typeFilter);
    queryBuilder.orderBy(_orderingTerms(orderBy));
    queryBuilder.limit(resolvedPageSize, offset: offset);

    return queryBuilder.watch().map(
      (rows) => rows.map(_mapToPerson).toList(growable: false),
    );
  }

  void _applyTypeFilter(
    SimpleSelectStatement<$PersonTableTable, PersonTableData> query,
    PersonTypeFilter typeFilter,
  ) {
    switch (typeFilter) {
      case PersonTypeFilter.all:
        return;
      case PersonTypeFilter.customers:
        query.where(
          (t) =>
              t.type.equals(PersonType.customer.value) |
              t.type.equals(PersonType.both.value),
        );
        return;
      case PersonTypeFilter.suppliers:
        query.where(
          (t) =>
              t.type.equals(PersonType.supplier.value) |
              t.type.equals(PersonType.both.value),
        );
        return;
      case PersonTypeFilter.owesYou:
        query.where((t) => t.balance.isBiggerThanValue(0));
        return;
      case PersonTypeFilter.youOwe:
        query.where((t) => t.balance.isSmallerThanValue(0));
        return;
    }
  }

  List<OrderingTerm Function($PersonTableTable)> _orderingTerms(
    PersonsOrderBy orderBy,
  ) {
    switch (orderBy) {
      case PersonsOrderBy.recentlyActive:
        return [(t) => OrderingTerm.desc(t.updatedAt)];
      case PersonsOrderBy.lastPayment:
        return [
          (t) => OrderingTerm.asc(t.balance),
          (t) => OrderingTerm.desc(t.updatedAt),
        ];
      case PersonsOrderBy.lastReceipt:
        return [
          (t) => OrderingTerm.desc(t.balance),
          (t) => OrderingTerm.desc(t.updatedAt),
        ];
      case PersonsOrderBy.alphabetAsc:
        return [(t) => OrderingTerm.asc(t.name)];
      case PersonsOrderBy.alphabetDesc:
        return [(t) => OrderingTerm.desc(t.name)];
      case PersonsOrderBy.highestDebt:
        return [(t) => OrderingTerm.asc(t.balance)];
      case PersonsOrderBy.highestCredit:
        return [(t) => OrderingTerm.desc(t.balance)];
      case PersonsOrderBy.oldest:
        return [(t) => OrderingTerm.asc(t.createdAt)];
      case PersonsOrderBy.newest:
        return [(t) => OrderingTerm.desc(t.createdAt)];
    }
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
