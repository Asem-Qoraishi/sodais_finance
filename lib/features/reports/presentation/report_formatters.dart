import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/utils/formatters/app_number_formatter.dart';

class ReportsFormatters {
  ReportsFormatters._();

  static String formatRange(BuildContext context, DateTimeRange? range) {
    if (range == null) return LocaleKeys.all.tr();
    final start = formatDate(context, range.start);
    final end = formatDate(context, range.end);
    if (start == end) return start;
    return '$start - $end';
  }

  static String formatDate(BuildContext context, DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    return '${jalali.formatter.yyyy}/${jalali.formatter.mm}/${jalali.formatter.dd}';
  }

  static String formatMoney(double value) {
    return AppNumberFormatter.formatAmount(value);
  }

  static String formatQuantity(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  static String compactMoney(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}
