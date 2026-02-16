import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/features/dashboard/domain/enums/activity_filter_enum.dart';
import 'package:sodais_finance/features/dashboard/presentation/controllers/activity_filter_controller.dart';

class RecentActivityFilterBar extends ConsumerWidget {
  const RecentActivityFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(activityFilterControllerProvider);
    return SliverToBoxAdapter(
      child: Row(
        spacing: sizeConstants.spacingXSmall,
        children: [
          for (final item in ActivityFilterEnum.values)
            ChoiceChip(
              shape: StadiumBorder(),
              label: Text(item.name),
              selected: item == filter,
              onSelected: (_) {
                ref
                    .read(activityFilterControllerProvider.notifier)
                    .setFilter(item);
              },
            ),
        ],
      ),
    );
  }
}
