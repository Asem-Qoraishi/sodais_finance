import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/colors.dart';

class CustomAppBarTheme {
  // AppBar light theme
  static const lightTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: kBackgroundColor,
    surfaceTintColor: kBackgroundColor,
    iconTheme: IconThemeData(color: textPrimaryColor, size: 24),
    actionsIconTheme: IconThemeData(color: textPrimaryColor, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 24,
      color: textPrimaryColor,
      fontWeight: FontWeight.w600,
    ),
  );

  // AppBar dark theme
  static const darkTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: darkBackgroundColor,
    surfaceTintColor: darkBackgroundColor,
    iconTheme: IconThemeData(color: textPrimaryColorDark, size: 24),
    actionsIconTheme: IconThemeData(color: textPrimaryColorDark, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 20,
      color: textPrimaryColorDark,
      fontWeight: FontWeight.w600,
    ),
  );
}
