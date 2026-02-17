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
    final theme = Theme.of(context);

    return CustomCard(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 70),
        child: Row(
          children: [
            CustomSvgIcon(iconSource: svgAssetName, iconColor: iconColor),
            SizedBox(width: sizeConstants.spacingSmall),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall!.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  Text(
                    amount.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge!.copyWith(
                      color: textColor ?? theme.textTheme.titleLarge!.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
