import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/utils/helpers/app_locale_helper.dart';

class RelativeTimeFormatter {
  String formatPersonLastActive({
    required BuildContext context,
    required DateTime date,
  }) {
    final difference = DateTime.now().difference(date);

    if (difference.isNegative || difference.inMinutes < 1) {
      return LocaleKeys.justNow.tr();
    }

    if (difference.inHours < 1) {
      return LocaleKeys.minutesAgo.tr(
        namedArgs: {'count': difference.inMinutes.toString()},
      );
    }

    if (difference.inDays < 1) {
      return LocaleKeys.hoursAgo.tr(
        namedArgs: {'count': difference.inHours.toString()},
      );
    }

    if (difference.inDays == 1) {
      return LocaleKeys.yesterday.tr();
    }

    if (difference.inDays <= 7) {
      return LocaleKeys.daysAgo.tr(
        namedArgs: {'count': difference.inDays.toString()},
      );
    }

    return _formatActualDate(context: context, date: date);
  }

  String _formatActualDate({
    required BuildContext context,
    required DateTime date,
  }) {
    if (appLocaleHelper.isCurrentLanguageEnglish(context)) {
      return DateFormat('d MMM yyyy').format(date);
    }

    final jalali = Jalali.fromDateTime(date);
    return '${jalali.formatter.yyyy}/${jalali.formatter.mm}/${jalali.formatter.dd}';
  }
}

RelativeTimeFormatter relativeTimeFormatter = RelativeTimeFormatter();
