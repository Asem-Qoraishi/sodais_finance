import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/colors.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';

class TextFieldTheme {
  TextFieldTheme._();

  static final lightTheme = InputDecorationTheme(
    errorMaxLines: 2,
    prefixIconColor: textLabelColor,
    suffixIconColor: textLabelColor,
    labelStyle: TextStyle(
      fontSize: sizeConstants.fontSmall,
      color: textLabelColor,
    ),
    hintStyle: TextStyle(
      fontSize: sizeConstants.fontSmall,
      color: textLabelColor,
    ),
    errorStyle: const TextStyle(),
    fillColor: kCardColor,
    filled: true,
    contentPadding: EdgeInsets.symmetric(
      horizontal: sizeConstants.spacingMedium,
      vertical: sizeConstants.spacingSmall,
    ),
    floatingLabelStyle: TextStyle(
      fontSize: sizeConstants.fontSmall,
      color: kPrimaryColor,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
      borderSide: const BorderSide(color: kStrokeColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
      borderSide: const BorderSide(color: kStrokeColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
      borderSide: const BorderSide(color: kPrimaryColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
      borderSide: const BorderSide(width: 2, color: kErrorColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
      borderSide: const BorderSide(color: kErrorColor),
    ),
  );

  static final darkTheme = InputDecorationTheme(
    errorMaxLines: 2,
    prefixIconColor: textLabelColorDark,
    suffixIconColor: textLabelColorDark,
    fillColor: darkCardColor,
    filled: true,
    labelStyle: TextStyle(
      fontSize: sizeConstants.fontSmall,
      color: textLabelColorDark,
    ),
    hintStyle: TextStyle(
      fontSize: sizeConstants.fontSmall,
      color: textLabelColorDark,
    ),
    errorStyle: const TextStyle(),
    contentPadding: EdgeInsets.symmetric(
      horizontal: sizeConstants.spacingMedium,
      vertical: sizeConstants.spacingSmall,
    ),
    floatingLabelStyle: TextStyle(
      fontSize: sizeConstants.fontSmall,
      color: darkPrimaryColor,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
      borderSide: BorderSide(color: darkStrokeColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
      borderSide: const BorderSide(color: darkStrokeColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
      borderSide: const BorderSide(color: darkPrimaryColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
      borderSide: const BorderSide(width: 2, color: kErrorColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
      borderSide: const BorderSide(color: kErrorColor),
    ),
  );
}
