import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/features/persons/data/local/dao/person_dao.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/persons/domain/person_repository.dart';
import 'package:sodais_finance/features/persons/domain/persons_query_options.dart';

final personRepositoryProvider = Provider(
  (ref) => PersonRepositoryImpl(ref.watch(personDaoProvider)),
);

class PersonRepositoryImpl implements PersonRepository {
  final PersonDao _personDao;
  PersonRepositoryImpl(this._personDao);

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
    await _personDao.insertPerson(person);
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
