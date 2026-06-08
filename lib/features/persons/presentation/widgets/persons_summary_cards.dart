import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/utils/formatters/app_number_formatter.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';

class PersonsSummaryCards extends StatelessWidget {
  const PersonsSummaryCards({super.key, required this.persons});

  final List<Person> persons;

  @override
  Widget build(BuildContext context) {
    final (toCollect, toPay) = _summaryTotals();

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: LocaleKeys.toCollect.tr(),
            amount: AppNumberFormatter.formatAmount(toCollect),
            icon: Icons.call_received_rounded,
            iconColor: Colors.green.shade700,
            iconBackgroundColor: Colors.green.withValues(alpha: 0.14),
          ),
        ),
        SizedBox(width: sizeConstants.spacingSmall),
        Expanded(
          child: _SummaryCard(
            title: LocaleKeys.toPay.tr(),
            amount: AppNumberFormatter.formatAmount(toPay),
            icon: Icons.call_made_rounded,
            iconColor: Colors.red.shade700,
            iconBackgroundColor: Colors.red.withValues(alpha: 0.14),
          ),
        ),
      ],
    );
  }

  (double toCollect, double toPay) _summaryTotals() {
    double toCollect = 0;
    double toPay = 0;

    for (final person in persons) {
      if (person.balance > 0) {
        toCollect += person.balance;
      } else if (person.balance < 0) {
        toPay += person.balance.abs();
      }
    }

    return (toCollect, toPay);
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
  });

  final String title;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(sizeConstants.spacingSmall),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(sizeConstants.radiusLarge),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: sizeConstants.avatarXSmall,
                height: sizeConstants.avatarXSmall,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: sizeConstants.iconSmall,
                  color: iconColor,
                ),
              ),
              SizedBox(width: sizeConstants.spacingXSmall),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: sizeConstants.spacingXSmall),
          Text(
            amount,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: sizeConstants.fontLarge,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
