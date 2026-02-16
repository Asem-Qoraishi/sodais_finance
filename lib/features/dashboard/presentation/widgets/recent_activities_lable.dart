import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';

class RecentActivitiesLabel extends StatelessWidget {
  const RecentActivitiesLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Text(
        LocaleKeys.recentActivities.tr(),
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
