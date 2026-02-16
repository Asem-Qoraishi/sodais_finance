import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/widgets/cards/custom_card.dart';
import 'package:sodais_finance/core/widgets/icons/custom_svg_icon.dart';

class DashboardReportCard extends StatelessWidget {
  const DashboardReportCard({
    super.key,
    required this.title,
    required this.amount,
    required this.svgAssetName,
    this.iconColor,
    this.textColor,
  });

  final String svgAssetName;
  final String title;
  final int amount;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 70),
        child: Row(
          spacing: sizeConstants.spacingMedium,
          children: [
            CustomSvgIcon(iconSource: svgAssetName, iconColor: iconColor),
            Column(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                Text(
                  amount.toString(),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color:
                        textColor ??
                        Theme.of(context).textTheme.titleLarge!.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
