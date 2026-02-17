import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sodais_finance/features/persons/data/repositories/person_repository_impl.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/persons/domain/persons_query_options.dart';
import 'package:sodais_finance/features/persons/presentation/controllers/persons_order_options.dart';

part 'persons_controller.g.dart';

class PersonsPageNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setPage(int page) {
    state = page < 0 ? 0 : page;
  }

  void nextPage() {
    state += 1;
  }

  void reset() {
    state = 0;
  }
}

final personsPageProvider = NotifierProvider<PersonsPageNotifier, int>(
  PersonsPageNotifier.new,
);

class PersonsOrderOptionNotifier extends Notifier<PersonsOrderOption> {
  @override
  PersonsOrderOption build() => PersonsOrderOption.recentlyActive;

  void setOrderOption(PersonsOrderOption option) {
    if (state == option) return;
    state = option;
    ref.read(personsPageProvider.notifier).reset();
  }
}

final personsOrderOptionProvider =
    NotifierProvider<PersonsOrderOptionNotifier, PersonsOrderOption>(
      PersonsOrderOptionNotifier.new,
    );

@riverpod
class PersonSearchQuery extends _$PersonSearchQuery {
  @override
  String build() => '';

  void update(String query) {
    if (state == query) return;
    state = query;
    ref.read(personsPageProvider.notifier).reset();
  }
}

@riverpod
class PersonsTypeFilter extends _$PersonsTypeFilter {
  @override
  PersonTypeFilter build() => PersonTypeFilter.all;

  void setFilter(PersonTypeFilter filter) {
    if (state == filter) return;
    state = filter;
    ref.read(personsPageProvider.notifier).reset();
  }
}

@riverpod
class PersonsController extends _$PersonsController {
  @override
  Stream<List<Person>> build() {
    final repository = ref.watch(personRepositoryProvider);
    final query = ref.watch(personSearchQueryProvider).trim();
    final typeFilter = ref.watch(personsTypeFilterProvider);
    final orderBy = ref.watch(personsOrderOptionProvider).toQueryOrderBy();
    final page = ref.watch(personsPageProvider);

    return repository.watchPersons(
      query: query,
      typeFilter: typeFilter,
      orderBy: orderBy,
      page: page,
      pageSize: personsPageSize,
    );
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

extension on PersonsOrderOption {
  PersonsOrderBy toQueryOrderBy() {
    switch (this) {
      case PersonsOrderOption.recentlyActive:
        return PersonsOrderBy.recentlyActive;
      case PersonsOrderOption.lastPayment:
        return PersonsOrderBy.lastPayment;
      case PersonsOrderOption.lastReceipt:
        return PersonsOrderBy.lastReceipt;
      case PersonsOrderOption.alphabetAsc:
        return PersonsOrderBy.alphabetAsc;
      case PersonsOrderOption.alphabetDesc:
        return PersonsOrderBy.alphabetDesc;
      case PersonsOrderOption.highestDebt:
        return PersonsOrderBy.highestDebt;
      case PersonsOrderOption.highestCredit:
        return PersonsOrderBy.highestCredit;
      case PersonsOrderOption.oldest:
        return PersonsOrderBy.oldest;
      case PersonsOrderOption.newest:
        return PersonsOrderBy.newest;
    }
  }
}
