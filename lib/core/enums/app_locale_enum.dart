import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum AppLocaleEnum {
  en, // English
  fa, // Persian
  ps; // Pashto

  String get languageCode => switch (this) {
    AppLocaleEnum.en => 'en',
    AppLocaleEnum.fa => 'fa',
    AppLocaleEnum.ps => 'ps',
  };
  String get fontFamily => switch (this) {
    AppLocaleEnum.en => 'P22Mackinac',
    AppLocaleEnum.fa => 'Yekan',
    AppLocaleEnum.ps => 'Vazir',
  };

  AppLocaleEnum currentLanguageCode(BuildContext context) => switch (context
      .locale
      .languageCode) {
    "fa" => AppLocaleEnum.fa,
    "ps" => AppLocaleEnum.ps,
    _ => AppLocaleEnum.en,
  };

  String getFontFamily(BuildContext context) {
    return currentLanguageCode(context).fontFamily;
  }
}
