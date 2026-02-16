import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sodais_finance/features/dashboard/domain/entities/activity.dart';
import 'package:sodais_finance/features/dashboard/domain/enums/activity_type.dart';
import 'package:sodais_finance/features/dashboard/presentation/controllers/activity_filter_controller.dart';

part 'activity_controller.g.dart';

@riverpod
class ActivityController extends _$ActivityController {
  @override
  FutureOr<List<Activity>> build() async {
    final filter = ref.watch(activityFilterControllerProvider);
    await Future.delayed(const Duration(seconds: 1));
    var activities = [
      Activity(
        id: '1',
        title: 'Sold item A',
        type: ActivityType.sale,
        timestamp: DateTime.now(),
      ),
      Activity(
        id: '3',
        title: 'Payment received from client C',
        type: ActivityType.payment,
        timestamp: DateTime.now(),
      ),
      Activity(
        id: '2',
        title: 'Purchased item B',
        type: ActivityType.purchase,
        timestamp: DateTime.now(),
      ),
      Activity(
        id: '4',
        title: 'Sold item D',
        type: ActivityType.sale,
        timestamp: DateTime.now(),
      ),
      Activity(
        id: '5',
        title: 'Purchased item E',
        type: ActivityType.purchase,
        timestamp: DateTime.now(),
      ),
      Activity(
        id: '5',
        title: 'Purchased item E',
        type: ActivityType.purchase,
        timestamp: DateTime.now(),
      ),
      Activity(
        id: '5',
        title: 'Purchased item E',
        type: ActivityType.purchase,
        timestamp: DateTime.now(),
      ),
    ];

    return filter.type != null
        ? activities.where((activity) => activity.type == filter.type).toList()
        : activities;
  }
}
