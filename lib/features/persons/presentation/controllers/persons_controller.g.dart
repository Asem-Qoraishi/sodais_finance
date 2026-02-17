// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persons_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PersonSearchQuery)
final personSearchQueryProvider = PersonSearchQueryProvider._();

final class PersonSearchQueryProvider
    extends $NotifierProvider<PersonSearchQuery, String> {
  PersonSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personSearchQueryHash();

  @$internal
  @override
  PersonSearchQuery create() => PersonSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$personSearchQueryHash() => r'7b52048ba464fca6acd0b1a550c9a22d501ff7aa';

abstract class _$PersonSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(PersonsTypeFilter)
final personsTypeFilterProvider = PersonsTypeFilterProvider._();

final class PersonsTypeFilterProvider
    extends $NotifierProvider<PersonsTypeFilter, PersonTypeFilter> {
  PersonsTypeFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personsTypeFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personsTypeFilterHash();

  @$internal
  @override
  PersonsTypeFilter create() => PersonsTypeFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PersonTypeFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PersonTypeFilter>(value),
    );
  }
}

String _$personsTypeFilterHash() => r'96d19c18e3b350275a8aaedf87a6784d8ad8ccd9';

abstract class _$PersonsTypeFilter extends $Notifier<PersonTypeFilter> {
  PersonTypeFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PersonTypeFilter, PersonTypeFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PersonTypeFilter, PersonTypeFilter>,
              PersonTypeFilter,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(PersonsController)
final personsControllerProvider = PersonsControllerProvider._();

final class PersonsControllerProvider
    extends $StreamNotifierProvider<PersonsController, List<Person>> {
  PersonsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personsControllerHash();

  @$internal
  @override
  PersonsController create() => PersonsController();
}

String _$personsControllerHash() => r'9dc93edf47adc07a1f36106c3492ca1aff4c091f';

abstract class _$PersonsController extends $StreamNotifier<List<Person>> {
  Stream<List<Person>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Person>>, List<Person>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Person>>, List<Person>>,
              AsyncValue<List<Person>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
