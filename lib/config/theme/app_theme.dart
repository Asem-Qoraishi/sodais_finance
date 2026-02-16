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

  static ThemeData lightTheme(BuildContext context) {
    final colorScheme = _lightColorScheme();

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: kBackgroundColor,
      canvasColor: kBackgroundColor,
      primaryColor: colorScheme.primary,
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
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: kCardColor,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: textLabelColor,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: kCardColor,
        selectedIconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
        selectedLabelTextStyle: TextStyle(color: colorScheme.primary),
        unselectedIconTheme: const IconThemeData(color: textLabelColor),
        unselectedLabelTextStyle: const TextStyle(color: textLabelColor),
        indicatorColor: colorScheme.primaryContainer,
      ),
      cardTheme: const CardThemeData().copyWith(
        surfaceTintColor: Colors.transparent,
        color: kCardColor,
        elevation: 1,
      ),
      fontFamily: appLocaleHelper.getFontFamily(context),
      textTheme: CustomTextTheme.lightTheme,
      appBarTheme: CustomAppBarTheme.lightTheme,
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    final colorScheme = _darkColorScheme();

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: darkBackgroundColor,
      canvasColor: darkBackgroundColor,
      primaryColor: colorScheme.primary,
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
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkNavigationColor,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: textLabelColorDark,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: darkNavigationColor,
        selectedIconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
        selectedLabelTextStyle: TextStyle(color: colorScheme.primary),
        unselectedIconTheme: const IconThemeData(color: textLabelColorDark),
        unselectedLabelTextStyle: const TextStyle(color: textLabelColorDark),
        indicatorColor: colorScheme.primaryContainer,
      ),
      cardTheme: const CardThemeData().copyWith(
        surfaceTintColor: Colors.transparent,
        color: darkCardColor,
      ),
      textTheme: CustomTextTheme.darkTheme,
      fontFamily: appLocaleHelper.getFontFamily(context),
      appBarTheme: CustomAppBarTheme.darkTheme,
    );
  }

  static ColorScheme _lightColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: kPrimaryColor,
      brightness: Brightness.light,
    ).copyWith(
      primary: kPrimaryColor,
      onPrimary: Colors.white,
      primaryContainer: kPrimaryContainerColor,
      onPrimaryContainer: kOnPrimaryContainerColor,
      secondary: kSecondaryColor,
      onSecondary: Colors.white,
      surface: kCardColor,
      onSurface: textPrimaryColor,
      outline: kStrokeColor,
      error: kErrorColor,
      onError: Colors.white,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF8FAFC),
      surfaceContainer: kCardColor,
      surfaceContainerHigh: kHighlightColor,
      surfaceContainerHighest: kHighlightColor,
    );
  }

  static ColorScheme _darkColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: darkPrimaryColor,
      brightness: Brightness.dark,
    ).copyWith(
      primary: darkPrimaryColor,
      onPrimary: Colors.white,
      primaryContainer: darkPrimaryContainerColor,
      onPrimaryContainer: darkOnPrimaryContainerColor,
      secondary: darkSecondaryColor,
      onSecondary: darkOnBackground,
      surface: darkCardColor,
      onSurface: textPrimaryColorDark,
      outline: darkStrokeColor,
      error: darkErrorColor,
      onError: Colors.white,
      surfaceContainerLowest: darkBackgroundColor,
      surfaceContainerLow: darkCardLowColor,
      surfaceContainer: darkCardColor,
      surfaceContainerHigh: darkHighlightColor,
      surfaceContainerHighest: darkStrokeColor,
    );
  }
}
