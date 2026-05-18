import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';

enum AppLocaleEnum {
  en, // English

  fa, // Persian

  ps; // Pashto

  Locale get locale => switch (this) {
    AppLocaleEnum.en => Locale('en', 'US'),
    AppLocaleEnum.fa => Locale('fa', 'AF'),
    AppLocaleEnum.ps => Locale('ps', 'AF'),
  };

  String get fontFamily => switch (this) {
    AppLocaleEnum.en => 'P22Mackinac',
    AppLocaleEnum.fa => 'Estedad',
    AppLocaleEnum.ps => 'Vazir',
  };

  AppLocaleEnum currentLanguageCode(BuildContext context) =>
      switch (context.locale.languageCode) {
        "fa" => AppLocaleEnum.fa,
        "ps" => AppLocaleEnum.ps,
        _ => AppLocaleEnum.en,
      };

  String getFontFamily(BuildContext context) {
    return currentLanguageCode(context).fontFamily;
  }
}
