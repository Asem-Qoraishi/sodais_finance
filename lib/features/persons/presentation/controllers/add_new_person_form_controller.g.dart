// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_new_person_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddNewPersonForm)
final addNewPersonFormProvider = AddNewPersonFormProvider._();

final class AddNewPersonFormProvider
    extends $NotifierProvider<AddNewPersonForm, AddNewPersonFormState> {
  AddNewPersonFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addNewPersonFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addNewPersonFormHash();

  @$internal
  @override
  AddNewPersonForm create() => AddNewPersonForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddNewPersonFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddNewPersonFormState>(value),
    );
  }
}

String _$addNewPersonFormHash() => r'1f4fc49cad8d1948cdc888b8a9cf936147df101a';

abstract class _$AddNewPersonForm extends $Notifier<AddNewPersonFormState> {
  AddNewPersonFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AddNewPersonFormState, AddNewPersonFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddNewPersonFormState, AddNewPersonFormState>,
              AddNewPersonFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
