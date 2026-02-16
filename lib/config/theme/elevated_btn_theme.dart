import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/colors.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';

class ElevatedBtnTheme {
  static final lightTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      textStyle: TextStyle(
        fontSize: sizeConstants.fontMedium,
        fontWeight: FontWeight.w600,
      ),
      minimumSize: Size(double.infinity, sizeConstants.buttonHeightLarge),
      padding: EdgeInsets.symmetric(
        vertical: sizeConstants.spacingSmall,
        horizontal: sizeConstants.spacingMedium,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
      ),
    ),
  );

  static final darkTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: darkPrimaryColor,
      foregroundColor: Colors.white,
      textStyle: TextStyle(
        fontSize: sizeConstants.fontMedium,
        fontWeight: FontWeight.w600,
      ),
      minimumSize: Size(double.infinity, sizeConstants.buttonHeightLarge),
      padding: EdgeInsets.symmetric(
        vertical: sizeConstants.spacingSmall,
        horizontal: sizeConstants.spacingMedium,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
      ),
    ),
  );
}
