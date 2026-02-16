import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/colors.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';

class OutlinedBtnTheme {
  static final lightTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      textStyle: TextStyle(
        fontSize: sizeConstants.fontMedium,
        color: textPrimaryColor,
        fontWeight: FontWeight.w600,
      ),
      foregroundColor: textPrimaryColor,
      backgroundColor: kCardColor,
      minimumSize: Size(double.infinity, sizeConstants.buttonHeightLarge),
      padding: EdgeInsets.symmetric(
        vertical: sizeConstants.spacingSmall,
        horizontal: sizeConstants.spacingMedium,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
      ),
      side: const BorderSide(width: 1.5, color: kStrokeColor),
    ),
  );

  static final darkTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      textStyle: TextStyle(
        fontSize: sizeConstants.fontMedium,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      foregroundColor: Colors.white,
      minimumSize: Size(double.infinity, sizeConstants.buttonHeightLarge),
      padding: EdgeInsets.symmetric(
        vertical: sizeConstants.spacingSmall,
        horizontal: sizeConstants.spacingMedium,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
      ),
      side: const BorderSide(width: 1.5, color: darkStrokeColor),
    ),
  );
}
