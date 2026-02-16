// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_filter_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActivityFilterController)
final activityFilterControllerProvider = ActivityFilterControllerProvider._();

final class ActivityFilterControllerProvider
    extends $NotifierProvider<ActivityFilterController, ActivityFilterEnum> {
  ActivityFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activityFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activityFilterControllerHash();

  @$internal
  @override
  ActivityFilterController create() => ActivityFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActivityFilterEnum value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActivityFilterEnum>(value),
    );
  }
}

String _$activityFilterControllerHash() =>
    r'f04a5d81704a50efd448ec9646e8b6d47a2d4ed9';

abstract class _$ActivityFilterController
    extends $Notifier<ActivityFilterEnum> {
  ActivityFilterEnum build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ActivityFilterEnum, ActivityFilterEnum>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ActivityFilterEnum, ActivityFilterEnum>,
              ActivityFilterEnum,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
