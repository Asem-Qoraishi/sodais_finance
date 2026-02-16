import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:sodais_finance/core/utils/helpers/app_locale_helper.dart';

class DateFormatter {
  String formatDateToWeekDayAndMonthDayDate({
    required BuildContext context,
    required String date,
  }) {
    Jalali jalali = Jalali.fromDateTime(DateTime.parse(date));
    return appLocaleHelper.isCurrentLanguageEnglish(context)
        ? DateFormat('EEEE d MMMM').format(DateTime.parse(date))
        : '${jalali.formatter.wN} ${jalali.formatter.dd} ${jalali.formatter.mNAf}';
  }

  String getMonthName(DateTime date, [bool isEnglish = false]) {
    Jalali jalali = Jalali.fromDateTime(date);
    return isEnglish ? DateFormat('MMMM').format(date) : jalali.formatter.mNAf;
  }

  String getDayOfWeek(DateTime date, [bool isEnglish = false]) {
    Jalali jalali = Jalali.fromDateTime(date);
    return isEnglish ? DateFormat('EEEE').format(date) : jalali.formatter.wN;
  }
}

DateFormatter dateFormatter = DateFormatter();
