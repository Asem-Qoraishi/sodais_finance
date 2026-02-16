// features/persons/domain/person_repository.dart
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/persons/domain/persons_query_options.dart';

abstract class PersonRepository {
  Stream<List<Person>> watchPersons({
    required String query,
    required PersonTypeFilter typeFilter,
    required PersonsOrderBy orderBy,
    int page = 0,
    int pageSize = personsPageSize,
  });

  Future<void> addPerson(Person person);
  Future<void> updatePerson(Person person);
  Future<void> deletePerson(String id);
}
