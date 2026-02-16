import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/colors.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';

class FilledBtnTheme {
  FilledBtnTheme._();

  static final lightTheme = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      minimumSize: Size(double.infinity, sizeConstants.buttonHeightLarge),
      padding: EdgeInsets.symmetric(
        vertical: sizeConstants.spacingSmall,
        horizontal: sizeConstants.spacingMedium,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
      ),
      textStyle: TextStyle(
        fontSize: sizeConstants.fontMedium,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static final darkTheme = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: darkPrimaryColor,
      foregroundColor: Colors.white,
      minimumSize: Size(double.infinity, sizeConstants.buttonHeightLarge),
      padding: EdgeInsets.symmetric(
        vertical: sizeConstants.spacingSmall,
        horizontal: sizeConstants.spacingMedium,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
      ),
      textStyle: TextStyle(
        fontSize: sizeConstants.fontMedium,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
