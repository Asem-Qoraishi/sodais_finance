import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/utils/formatters/date_formatter.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:sodais_finance/core/widgets/slivers/custom_sliver_card.dart';

class DateCardWidget extends StatelessWidget {
  const DateCardWidget({super.key, required this.date});
  final DateTime date;
  @override
  Widget build(BuildContext context) {
    final Jalali jDate = Jalali.fromDateTime(date);
    return CustomSliverCard(
      padding: EdgeInsets.all(sizeConstants.spacingLarge),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 70),
        child: Row(
          spacing: sizeConstants.spacingLarge,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildShamsiDate(context, jDate),
            _buildGregorianDate(context, date),
          ],
        ),
      ),
    );
  }

  Widget _buildShamsiDate(BuildContext context, Jalali date) {
    return buildDateWidget(
      context,
      date.day.toString(),
      dateFormatter.getMonthName(date.toDateTime()),
      '${date.year}/${date.month}/${date.day}',
    );
  }

  Widget _buildGregorianDate(BuildContext context, DateTime date) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: buildDateWidget(
        context,
        date.day.toString(),
        dateFormatter.getMonthName(date, true),
        '${date.year}/${date.month}/${date.day}',
      ),
    );
  }

  Widget buildDateWidget(
    BuildContext context,
    String day,
    String monthName,
    String date,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: sizeConstants.spacingMedium,
      children: [
        Text(day, style: textTheme.titleLarge),
        Column(
          mainAxisSize: MainAxisSize.min,
          spacing: sizeConstants.spacingXSmall,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(monthName, style: textTheme.titleLarge),
            Text(
              date,
              style: textTheme.titleSmall!.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
