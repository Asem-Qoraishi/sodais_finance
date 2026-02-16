import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:sodais_finance/core/utils/formatters/date_formatter.dart';
import 'package:sodais_finance/core/widgets/icons/custom_svg_widget.dart';
import 'package:sodais_finance/core/widgets/slivers/sliver_circular_progress_indicator.dart';
import 'package:sodais_finance/features/dashboard/domain/enums/activity_type.dart';
import 'package:sodais_finance/features/dashboard/presentation/controllers/activity_controller.dart';

class RecentActivitiesList extends ConsumerWidget {
  const RecentActivitiesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncActivities = ref.watch(activityControllerProvider);

    return asyncActivities.when(
      data: (activities) {
        return SliverList.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return ActivityCard(
              activityType: activity.type,
              personName: "الیاس",
              price: 235.0 * index,
              date: DateTime.now(),
              productName: 'نایلکس',
            );
          },
        );
      },
      error: (error, stack) =>
          SliverToBoxAdapter(child: Center(child: Text('Error: $error'))),
      loading: () => SliverCircularProgressIndicator(),
    );
  }
}

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activityType,
    required this.personName,
    required this.price,
    required this.date,
    this.productName,
  });

  final DateTime date;
  final String? productName;
  final String personName;
  final double price;
  final ActivityType activityType;

  @override
  Widget build(BuildContext context) {
    final jDate = Jalali.fromDateTime(date);
    return Card(
      child: ListTile(
        leading: CustomSvgPicture(
          iconSource: activityType.iconSource,
          iconColor: activityType.color,
        ),
        title: Text("${activityType.name} $productName"),
        subtitle: Text(
          "$price افغانی",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: activityType.color),
        ),
        trailing: Text(
          '${jDate.day} ${dateFormatter.getMonthName(date)} ${jDate.year}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
