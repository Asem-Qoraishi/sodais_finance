import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sodais_finance/features/dashboard/domain/enums/activity_filter_enum.dart';

part 'activity_filter_controller.g.dart';

@riverpod
class ActivityFilterController extends _$ActivityFilterController {
  @override
  ActivityFilterEnum build() => ActivityFilterEnum.all;

  void setFilter(ActivityFilterEnum filter) => state = filter;
}
