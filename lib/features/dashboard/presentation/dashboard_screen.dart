import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/widgets/slivers/sliver_sized_box.dart';
import 'package:sodais_finance/features/dashboard/presentation/widgets/dashboard_action_buttons.dart';
import 'package:sodais_finance/features/dashboard/presentation/widgets/dashboard_reports.dart';
import 'package:sodais_finance/features/dashboard/presentation/widgets/date_card_widget.dart';
import 'package:sodais_finance/features/dashboard/presentation/widgets/recent_activities_lable.dart';
import 'package:sodais_finance/features/dashboard/presentation/widgets/recent_activities_list.dart';
import 'package:sodais_finance/features/dashboard/presentation/widgets/recent_activity_filter_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.dashboard.tr()), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: sizeConstants.spacingMedium),
        child: CustomScrollView(
          slivers: [
            // #Date
            DateCardWidget(date: DateTime.now()),
            SliverSizedBox(height: sizeConstants.spacingSmall),
            // #Reports
            DashboardReports(),
            SliverSizedBox(height: sizeConstants.spacingSmall),
            // #Action Buttons
            DashboardActionButtons(),
            SliverSizedBox(height: sizeConstants.spacingMedium),
            // #Recent Activities
            RecentActivitiesLabel(),
            SliverSizedBox(height: sizeConstants.spacingSmall),
            RecentActivityFilterBar(),
            SliverSizedBox(height: sizeConstants.spacingSmall),
            RecentActivitiesList(),
          ],
        ),
      ),
    );
  }
}
