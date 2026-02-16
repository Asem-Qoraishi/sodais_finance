import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sodais_finance/core/constants/colors.dart';

class CustomTextTheme {
  CustomTextTheme._();

  //light Text Styles
  static final lightTheme = TextTheme(
    //Display Text style
    displayLarge: const TextStyle().copyWith(
      fontSize: 48.sp,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: const TextStyle().copyWith(
      fontSize: 36.sp,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: const TextStyle().copyWith(
      fontSize: 32.sp,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),

    //Title Text style
    titleLarge: const TextStyle().copyWith(
      fontSize: 24.sp,
      color: textPrimaryColor,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: const TextStyle().copyWith(
      fontSize: 20.sp,
      color: textPrimaryColor,
      fontWeight: FontWeight.bold,
    ),
    titleSmall: const TextStyle().copyWith(
      fontSize: 16.sp,
      color: textPrimaryColor,
      fontWeight: FontWeight.bold,
    ),

    // Body text style
    bodyLarge: const TextStyle().copyWith(
      fontSize: 16.sp,
      color: textPrimaryColor,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: const TextStyle().copyWith(
      fontSize: 14.sp,
      color: textPrimaryColor,
      fontWeight: FontWeight.w500,
    ),
    bodySmall: const TextStyle().copyWith(
      fontSize: 12.sp,
      color: textPrimaryColor,
    ),

    // Lable text style
    labelLarge: const TextStyle().copyWith(
      fontSize: 14.sp,
      color: textLabelColor,
    ),
    labelMedium: const TextStyle().copyWith(
      fontSize: 12.sp,
      color: textLabelColor,
    ),
    labelSmall: const TextStyle().copyWith(
      fontSize: 10.sp,
      color: textLabelColor,
    ),
  );

  // dark text theme
  static final darkTheme = TextTheme(
    //Display Text style
    displayLarge: const TextStyle().copyWith(
      fontSize: 48.sp,
      color: textPrimaryColorDark,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: const TextStyle().copyWith(
      fontSize: 36.sp,
      color: textPrimaryColorDark,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: const TextStyle().copyWith(
      fontSize: 32.sp,
      color: textPrimaryColorDark,
      fontWeight: FontWeight.bold,
    ),

    //Title Text style
    titleLarge: const TextStyle().copyWith(
      fontSize: 24.sp,
      color: textPrimaryColorDark,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: const TextStyle().copyWith(
      fontSize: 20.sp,
      color: textPrimaryColorDark,
      fontWeight: FontWeight.bold,
    ),
    titleSmall: const TextStyle().copyWith(
      fontSize: 18.sp,
      color: textPrimaryColorDark,
      fontWeight: FontWeight.bold,
    ),

    // Body text style
    bodyLarge: const TextStyle().copyWith(
      fontSize: 16.sp,
      color: textPrimaryColorDark,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: const TextStyle().copyWith(
      fontSize: 14.sp,
      color: textPrimaryColorDark,
      fontWeight: FontWeight.w500,
    ),
    bodySmall: const TextStyle().copyWith(
      fontSize: 12.sp,
      color: textPrimaryColorDark,
    ),

    // Lable text style
    labelLarge: const TextStyle().copyWith(
      fontSize: 14.sp,
      color: textLabelColorDark,
    ),
    labelMedium: const TextStyle().copyWith(
      fontSize: 12.sp,
      color: textLabelColorDark,
    ),
    labelSmall: const TextStyle().copyWith(
      fontSize: 10.sp,
      color: textLabelColorDark,
    ),
  );
}
