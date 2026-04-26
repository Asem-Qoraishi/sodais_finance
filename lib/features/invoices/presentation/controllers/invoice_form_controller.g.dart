// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InvoiceController)
final invoiceControllerProvider = InvoiceControllerFamily._();

final class InvoiceControllerProvider
    extends $NotifierProvider<InvoiceController, InvoiceState> {
  InvoiceControllerProvider._({
    required InvoiceControllerFamily super.from,
    required InvoiceControllerArgs super.argument,
  }) : super(
         retry: null,
         name: r'invoiceControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$invoiceControllerHash();

  @override
  String toString() {
    return r'invoiceControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  InvoiceController create() => InvoiceController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InvoiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InvoiceState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InvoiceControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$invoiceControllerHash() => r'd12fdc68132177636267201763a9f3c31fb7616d';

final class InvoiceControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          InvoiceController,
          InvoiceState,
          InvoiceState,
          InvoiceState,
          InvoiceControllerArgs
        > {
  InvoiceControllerFamily._()
    : super(
        retry: null,
        name: r'invoiceControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InvoiceControllerProvider call(InvoiceControllerArgs args) =>
      InvoiceControllerProvider._(argument: args, from: this);

  @override
  String toString() => r'invoiceControllerProvider';
}

abstract class _$InvoiceController extends $Notifier<InvoiceState> {
  late final _$args = ref.$arg as InvoiceControllerArgs;
  InvoiceControllerArgs get args => _$args;

  InvoiceState build(InvoiceControllerArgs args);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<InvoiceState, InvoiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InvoiceState, InvoiceState>,
              InvoiceState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
