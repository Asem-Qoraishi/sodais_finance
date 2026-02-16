import 'package:flutter/material.dart';
import 'package:sodais_finance/core/assets/assets.gen.dart';
import 'package:sodais_finance/core/constants/colors.dart';
import 'package:sodais_finance/features/dashboard/presentation/widgets/dashboard_report_card.dart';

class DashboardReports extends StatelessWidget {
  const DashboardReports({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Row(
        children: [
          Expanded(
            child: DashboardReportCard(
              title: "کالا های موجود",
              amount: 243,
              svgAssetName: Assets.icons.products,
            ),
          ),
          Expanded(
            child: DashboardReportCard(
              title: "مانده حساب",
              amount: 243,
              svgAssetName: Assets.icons.payment,
              iconColor: textWarningColor,
              textColor: textWarningColor,
            ),
          ),
        ],
      ),
    );
  }
}
