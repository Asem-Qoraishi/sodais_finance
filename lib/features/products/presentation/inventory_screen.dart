import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/widgets/texts/result_count.dart';
import 'package:sodais_finance/features/products/presentation/widgets/inventory_app_bar.dart';
import 'package:sodais_finance/features/products/presentation/widgets/products_list.dart';
import 'package:sodais_finance/features/products/presentation/widgets/products_order_by.dart';
import 'package:sodais_finance/features/products/presentation/widgets/products_search_field.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InventoryAppBar(),
      body: Padding(
        padding: EdgeInsets.all(sizeConstants.spacingSmall),
        child: Column(
          spacing: sizeConstants.spacingSmall,
          children: [
            InventorySearchField(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [ResultCount(resultCount: 7), ProductsOrderBy()],
            ),
            Expanded(child: ProductsList()),
          ],
        ),
      ),
    );
  }
}
