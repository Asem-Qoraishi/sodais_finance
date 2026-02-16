import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sodais_finance/features/persons/data/repositories/person_repository_impl.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';

part 'persons_controller.g.dart';

enum PersonTypeFilter {
  all,
  customer,
  supplier,
  both;

  bool matches(PersonType type) {
    switch (this) {
      case PersonTypeFilter.all:
        return true;
      case PersonTypeFilter.customer:
        return type == PersonType.customer;
      case PersonTypeFilter.supplier:
        return type == PersonType.supplier;
      case PersonTypeFilter.both:
        return type == PersonType.both;
    }
  }
}

@riverpod
class PersonSearchQuery extends _$PersonSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
class PersonsTypeFilter extends _$PersonsTypeFilter {
  @override
  PersonTypeFilter build() => PersonTypeFilter.all;

  void setFilter(PersonTypeFilter filter) => state = filter;
}

@riverpod
class PersonsController extends _$PersonsController {
  @override
  Stream<List<Person>> build() {
    final repository = ref.watch(personRepositoryProvider);
    final query = ref.watch(personSearchQueryProvider).toLowerCase().trim();
    final typeFilter = ref.watch(personsTypeFilterProvider);

    return repository.watchPersons().map((persons) {
      return persons
          .where((person) {
            final nameMatch = person.name.toLowerCase().contains(query);
            final phoneMatch =
                person.phone?.toLowerCase().contains(query) ?? false;
            final emailMatch =
                person.email?.toLowerCase().contains(query) ?? false;
            final addressMatch =
                person.address?.toLowerCase().contains(query) ?? false;
            final typeMatch = person.type.value.contains(query);
            final queryMatch =
                query.isEmpty ||
                nameMatch ||
                phoneMatch ||
                emailMatch ||
                addressMatch ||
                typeMatch;

            return queryMatch && typeFilter.matches(person.type);
          })
          .toList(growable: false);
    });
  }

  Future<void> addPerson({
    required String name,
    String? image,
    String? phone,
    String? address,
    String? email,
    required PersonType type,
    required double balance,
  }) async {
    final person = Person(
      id: '0',
      image: image,
      name: name,
      phone: phone,
      address: address,
      email: email,
      type: type,
      balance: balance,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(personRepositoryProvider).addPerson(person);
  }

  Future<void> updatePerson(Person person) async {
    await ref.read(personRepositoryProvider).updatePerson(person);
  }

  Future<void> deletePerson(String id) async {
    await ref.read(personRepositoryProvider).deletePerson(id);
  }
}
