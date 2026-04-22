import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';

class InvoiceSectionLabel extends StatelessWidget {
  const InvoiceSectionLabel({
    super.key,
    required this.text,
    required this.sectionNumber,
  });

  final int sectionNumber;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: sizeConstants.spacingSmall,
      children: [
        Badge.count(
          count: sectionNumber,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        Text(text, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
