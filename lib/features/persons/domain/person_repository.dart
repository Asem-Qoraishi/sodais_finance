// features/persons/domain/person_repository.dart
import 'package:sodais_finance/features/persons/domain/person.dart';

abstract class PersonRepository {
  Stream<List<Person>> watchPersons();

  Future<void> addPerson(Person person);
  Future<void> updatePerson(Person person);
  Future<void> deletePerson(String id);
}
