import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';

class DashboardActionButtons extends StatelessWidget {
  const DashboardActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Row(
        spacing: sizeConstants.spacingXSmall,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: sizeConstants.spacingSmall,
                  horizontal: sizeConstants.spacingMedium,
                ),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(LocaleKeys.addNewSale.tr()),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: sizeConstants.spacingSmall,
                  horizontal: sizeConstants.spacingMedium,
                ),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(LocaleKeys.addNewPurchase.tr()),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: sizeConstants.spacingSmall,
                  horizontal: sizeConstants.spacingMedium,
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(LocaleKeys.addNewPayment.tr()),
            ),
          ),
        ],
      ),
    );
  }
}
