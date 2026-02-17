// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_new_product_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddNewProductForm)
final addNewProductFormProvider = AddNewProductFormProvider._();

final class AddNewProductFormProvider
    extends $NotifierProvider<AddNewProductForm, AddNewProductFormState> {
  AddNewProductFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addNewProductFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addNewProductFormHash();

  @$internal
  @override
  AddNewProductForm create() => AddNewProductForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddNewProductFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddNewProductFormState>(value),
    );
  }
}

String _$addNewProductFormHash() => r'099757ed39efa1b15f88fa3c8d9b7a6ce146b5e6';

abstract class _$AddNewProductForm extends $Notifier<AddNewProductFormState> {
  AddNewProductFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AddNewProductFormState, AddNewProductFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddNewProductFormState, AddNewProductFormState>,
              AddNewProductFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
