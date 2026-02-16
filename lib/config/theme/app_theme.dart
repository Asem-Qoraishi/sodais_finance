import 'package:flutter/material.dart';
import 'package:sodais_finance/config/theme/app_bar_theme.dart';
import 'package:sodais_finance/config/theme/elevated_btn_theme.dart';
import 'package:sodais_finance/config/theme/filled_btn_theme.dart';
import 'package:sodais_finance/config/theme/outline_btn_theme.dart';
import 'package:sodais_finance/config/theme/text_field_theme.dart';
import 'package:sodais_finance/config/theme/text_theme.dart';
import 'package:sodais_finance/core/constants/colors.dart';
import 'package:sodais_finance/core/utils/helpers/app_locale_helper.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme(BuildContext context) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      surface: Colors.transparent,
      seedColor: kPrimaryColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: kBackgroundColor,
    primaryColor: kPrimaryColor,
    dividerColor: kStrokeColor,
    hintColor: textLabelColor,
    highlightColor: kHighlightColor,
    dividerTheme: DividerThemeData(color: kStrokeColor, space: 0),
    inputDecorationTheme: TextFieldTheme.lightTheme,
    outlinedButtonTheme: OutlinedBtnTheme.lightTheme,
    elevatedButtonTheme: ElevatedBtnTheme.lightTheme,
    filledButtonTheme: FilledBtnTheme.lightTheme,
    iconTheme: IconThemeData(color: textLabelColor),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: kPrimaryColor,
      foregroundColor: kBackgroundColor,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: kCardColor,
      selectedItemColor: kPrimaryColor,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: kCardColor,
      selectedIconTheme: const IconThemeData(color: kBackgroundColor),
      indicatorColor: kPrimaryColor,
    ),
    cardTheme: const CardThemeData().copyWith(
      surfaceTintColor: kCardColor,
      color: kCardColor,
      elevation: 1,
    ),
    fontFamily: appLocaleHelper.getFontFamily(context),
    textTheme: CustomTextTheme.lightTheme,
    appBarTheme: CustomAppBarTheme.lightTheme,
  );

  static ThemeData darkTheme(BuildContext context) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      surface: Colors.transparent,
      seedColor: kPrimaryColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: darkBackgroundColor,
    primaryColor: kPrimaryColor,
    dividerColor: darkStrokeColor,
    hintColor: textLabelColorDark,
    highlightColor: darkHighlightColor,
    dividerTheme: DividerThemeData(color: darkStrokeColor, space: 0),
    inputDecorationTheme: TextFieldTheme.darkTheme,
    outlinedButtonTheme: OutlinedBtnTheme.darkTheme,
    elevatedButtonTheme: ElevatedBtnTheme.darkTheme,
    filledButtonTheme: FilledBtnTheme.darkTheme,
    iconTheme: IconThemeData(color: textLabelColorDark),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkPrimaryColor,
      foregroundColor: darkBackgroundColor,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkCardColor,
      selectedItemColor: darkPrimaryColor,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: darkCardColor,
      selectedIconTheme: const IconThemeData(color: darkBackgroundColor),
      indicatorColor: darkPrimaryColor,
    ),
    cardTheme: const CardThemeData().copyWith(
      surfaceTintColor: darkCardColor,
      color: darkCardColor,
    ),
    textTheme: CustomTextTheme.darkTheme,
    fontFamily: appLocaleHelper.getFontFamily(context),
    appBarTheme: CustomAppBarTheme.darkTheme,
  );
  //generate dark theme
}
