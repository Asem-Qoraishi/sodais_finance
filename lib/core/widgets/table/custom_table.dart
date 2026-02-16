import 'package:flutter/material.dart';
import 'package:sodais_finance/core/widgets/cards/custom_card.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';

class CustomTable extends StatelessWidget {
  const CustomTable({
    super.key,
    required this.title,
    required this.itemBuilder,
    required this.itemCount,
  });

  final String title;
  final Widget? Function(BuildContext context, int index) itemBuilder;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    // return SizedBox();
    return Expanded(
      child: CustomCard(
        padding: EdgeInsets.all(0),
        child: Column(
          children: [
            TableHeader(title: title),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: itemCount,
                itemBuilder: itemBuilder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TableHeader extends StatelessWidget {
  const TableHeader({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sizeConstants.spacingMedium),
      color: Theme.of(context).highlightColor,
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
