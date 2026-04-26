import 'package:sodais_finance/features/app/data/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/features/persons/data/local/dao/person_dao.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/persons/domain/person_repository.dart';
import 'package:sodais_finance/features/persons/domain/persons_query_options.dart';
import 'package:sodais_finance/features/transactions/application/providers/transaction_providers.dart';
import 'package:sodais_finance/features/transactions/domain/transactions_repository.dart';

final personRepositoryProvider = Provider(
  (ref) => PersonRepositoryImpl(
    ref.watch(appDatabaseProvider),
    ref.watch(personDaoProvider),
    ref.watch(transactionsRepositoryProvider),
  ),
);

class PersonRepositoryImpl implements PersonRepository {
  final AppDatabase _db;
  final PersonDao _personDao;
  final TransactionsRepository _transactionsRepository;

  PersonRepositoryImpl(this._db, this._personDao, this._transactionsRepository);

  @override
  Stream<List<Person>> watchPersons({
    required String query,
    required PersonTypeFilter typeFilter,
    required PersonsOrderBy orderBy,
    int page = 0,
    int pageSize = personsPageSize,
  }) => _personDao.watchPersons(
    query: query,
    typeFilter: typeFilter,
    orderBy: orderBy,
    page: page,
    pageSize: pageSize,
  );

  @override
  Future<void> addPerson(Person person) async {
    if (person.name.isEmpty) throw ArgumentError('Name cannot be empty');

    await _db.transaction(() async {
      final personId = await _personDao.insertPerson(person);
      if (person.balance == 0) return;

      await _transactionsRepository.recordOpeningBalance(
        OpeningBalanceEntryRequest(
          contactId: personId,
          amount: person.balance,
          recordedAt: person.createdAt,
          description: 'Opening balance for ${person.name}',
        ),
      );
    });
  }

  @override
  Future<void> updatePerson(Person person) async {
    await _personDao.updatePerson(person);
  }

  @override
  Future<void> deletePerson(String id) async {
    await _personDao.deletePerson(id);
  }
}
