import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/enums/app_locale_enum.dart';

class AppLocaleHelper {
  AppLocaleEnum currentLocale(BuildContext context) =>
      switch (context.locale.languageCode) {
        "fa" => AppLocaleEnum.fa,
        "ps" => AppLocaleEnum.ps,
        _ => AppLocaleEnum.en,
      };

  String getFontFamily(BuildContext context) {
    return currentLocale(context).fontFamily;
  }

  bool isCurrentLanguageEnglish(BuildContext context) =>
      currentLocale(context) == AppLocaleEnum.en;
}

AppLocaleHelper appLocaleHelper = AppLocaleHelper();
