import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/features/app/data/app_database.dart';
import 'package:sodais_finance/features/persons/data/local/tables/person_table.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/persons/domain/persons_query_options.dart';
import 'package:sodais_finance/features/transactions/data/local/transactions_drift_store.dart';

part 'person_dao.g.dart';

@DriftAccessor(tables: [PersonTable])
class PersonDao extends DatabaseAccessor<AppDatabase> with _$PersonDaoMixin {
  PersonDao(super.db);

  static const _personColumns = '''
    person_table.id,
    person_table.name,
    person_table.image,
    person_table.phone,
    person_table.address,
    person_table.email,
    person_table.type,
    person_table.created_at,
    person_table.updated_at
  ''';

  Person _mapToPersonRow(QueryRow row) {
    return Person(
      id: row.read<int>('id').toString(),
      image: row.readNullable<String>('image'),
      name: row.read<String>('name'),
      phone: row.readNullable<String>('phone'),
      address: row.readNullable<String>('address'),
      email: row.readNullable<String>('email'),
      type: PersonType.fromValue(row.read<String>('type')),
      balance: row.read<double>('computed_balance'),
      createdAt: row.read<DateTime>('created_at'),
      updatedAt: row.read<DateTime>('updated_at'),
    );
  }

  Stream<List<Person>> watchPersons({
    required String query,
    required PersonTypeFilter typeFilter,
    required PersonsOrderBy orderBy,
    int page = 0,
    int pageSize = personsPageSize,
  }) {
    final normalizedQuery = query.trim();
    final resolvedPage = page < 0 ? 0 : page;
    final resolvedPageSize = pageSize <= 0 ? personsPageSize : pageSize;
    final offset = resolvedPage * resolvedPageSize;
    final variables = <Variable>[];
    final whereClauses = <String>[];

    if (normalizedQuery.isNotEmpty) {
      final pattern = '%$normalizedQuery%';
      whereClauses.add('''
        (
          person_table.name LIKE ?
          OR COALESCE(person_table.phone, '') LIKE ?
          OR COALESCE(person_table.email, '') LIKE ?
          OR COALESCE(person_table.address, '') LIKE ?
          OR person_table.type LIKE ?
        )
      ''');
      for (var i = 0; i < 5; i++) {
        variables.add(Variable<String>(pattern));
      }
    }

    final typeFilterClause = _typeFilterClause(typeFilter);
    if (typeFilterClause case final clause?) {
      whereClauses.add(clause);
    }

    final havingClause = _balanceFilterClause(typeFilter);
    variables.add(Variable<int>(resolvedPageSize));
    variables.add(Variable<int>(offset));

    return customSelect(
      '''
      SELECT
        $_personColumns,
        ${TransactionsDriftStore.contactBalanceExpressionSql} AS computed_balance
      FROM person_table
      LEFT JOIN transaction_table
        ON transaction_table.contact_id = person_table.id
      ${whereClauses.isEmpty ? '' : 'WHERE ${whereClauses.join(' AND ')}'}
      GROUP BY $_personColumns
      ${havingClause == null ? '' : 'HAVING $havingClause'}
      ORDER BY ${_orderingClause(orderBy)}
      LIMIT ? OFFSET ?
      ''',
      variables: variables,
      readsFrom: {personTable, attachedDatabase.transactionTable},
    ).watch().map((rows) => rows.map(_mapToPersonRow).toList(growable: false));
  }

  Stream<Person?> watchPersonById(String id) {
    final intId = int.tryParse(id) ?? -1;
    if (intId < 0) {
      return Stream.value(null);
    }

    return customSelect(
      '''
      SELECT
        $_personColumns,
        ${TransactionsDriftStore.contactBalanceExpressionSql} AS computed_balance
      FROM person_table
      LEFT JOIN transaction_table
        ON transaction_table.contact_id = person_table.id
      WHERE person_table.id = ?
      GROUP BY $_personColumns
      ''',
      variables: [Variable<int>(intId)],
      readsFrom: {personTable, attachedDatabase.transactionTable},
    ).watch().map((rows) => rows.isEmpty ? null : _mapToPersonRow(rows.first));
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
        balance: const Value(0),
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
        balance: const Value(0),
        createdAt: Value(person.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deletePerson(String id) {
    final intId = int.tryParse(id) ?? -1;
    return (delete(personTable)..where((t) => t.id.equals(intId))).go();
  }

  String? _typeFilterClause(PersonTypeFilter typeFilter) {
    switch (typeFilter) {
      case PersonTypeFilter.all:
      case PersonTypeFilter.owesYou:
      case PersonTypeFilter.youOwe:
        return null;
      case PersonTypeFilter.customers:
        return '''
          (
            person_table.type = '${PersonType.customer.value}'
            OR person_table.type = '${PersonType.both.value}'
          )
        ''';
      case PersonTypeFilter.suppliers:
        return '''
          (
            person_table.type = '${PersonType.supplier.value}'
            OR person_table.type = '${PersonType.both.value}'
          )
        ''';
    }
  }

  String? _balanceFilterClause(PersonTypeFilter typeFilter) {
    switch (typeFilter) {
      case PersonTypeFilter.owesYou:
        return 'computed_balance > 0';
      case PersonTypeFilter.youOwe:
        return 'computed_balance < 0';
      case PersonTypeFilter.all:
      case PersonTypeFilter.customers:
      case PersonTypeFilter.suppliers:
        return null;
    }
  }

  String _orderingClause(PersonsOrderBy orderBy) {
    switch (orderBy) {
      case PersonsOrderBy.recentlyActive:
        return '''
          COALESCE(MAX(transaction_table.date), person_table.updated_at) DESC,
          person_table.id DESC
        ''';
      case PersonsOrderBy.lastPayment:
        return '''
          COALESCE(
            MAX(
              CASE
                WHEN transaction_table.type = 'income'
                THEN transaction_table.date
              END
            ),
            person_table.updated_at
          ) DESC,
          computed_balance ASC
        ''';
      case PersonsOrderBy.lastReceipt:
        return '''
          COALESCE(
            MAX(
              CASE
                WHEN transaction_table.type = 'expense'
                THEN transaction_table.date
              END
            ),
            person_table.updated_at
          ) DESC,
          computed_balance DESC
        ''';
      case PersonsOrderBy.alphabetAsc:
        return 'person_table.name ASC';
      case PersonsOrderBy.alphabetDesc:
        return 'person_table.name DESC';
      case PersonsOrderBy.highestDebt:
        return 'computed_balance ASC, person_table.name ASC';
      case PersonsOrderBy.highestCredit:
        return 'computed_balance DESC, person_table.name ASC';
      case PersonsOrderBy.oldest:
        return 'person_table.created_at ASC';
      case PersonsOrderBy.newest:
        return 'person_table.created_at DESC';
    }
  }
}

final personDaoProvider = Provider(
  (ref) => PersonDao(ref.watch(appDatabaseProvider)),
);
