import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/widgets/text_field/custom_text_field.dart';

class AddNewProductScreen extends StatelessWidget {
  const AddNewProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.addNewProduct.tr()),
        centerTitle: true,
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: Text(LocaleKeys.save.tr()),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: EdgeInsets.all(sizeConstants.spacingMedium),
        child: Column(
          spacing: sizeConstants.spacingMedium,
          children: [
            // sizeConstants.spacingMedium.verticalSpace,
            CustomTextField(
              // onChanged: ref.read(personsControllerProvider.notifier).search,
              hintText: LocaleKeys.productName.tr(),
              label: LocaleKeys.productName.tr(),
            ),
            Row(
              spacing: sizeConstants.spacingMedium,
              children: [
                Flexible(
                  child: CustomTextField(
                    hintText: LocaleKeys.initalStockQuantity.tr(),
                    label: LocaleKeys.initalStockQuantity.tr(),
                  ),
                ),
                Flexible(
                  child: CustomTextField(
                    hintText: LocaleKeys.price.tr(),
                    label: LocaleKeys.price.tr(),
                  ),
                ),
              ],
            ),
            FilledButton(
              onPressed: () {
                context.pop();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, size: sizeConstants.iconMedium),
                  sizeConstants.spacingMedium.horizontalSpace,
                  Text(LocaleKeys.save.tr()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
