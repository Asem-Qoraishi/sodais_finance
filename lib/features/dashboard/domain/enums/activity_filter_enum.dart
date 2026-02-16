import 'package:easy_localization/easy_localization.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/features/dashboard/domain/entities/activity.dart';
import 'package:sodais_finance/features/dashboard/domain/enums/activity_type.dart';

enum ActivityFilterEnum {
  all,
  sales,
  purchases,
  payments;

  String get name {
    switch (this) {
      case ActivityFilterEnum.all:
        return LocaleKeys.all.tr();
      case ActivityFilterEnum.sales:
        return LocaleKeys.sale.tr();
      case ActivityFilterEnum.purchases:
        return LocaleKeys.purchase.tr();
      case ActivityFilterEnum.payments:
        return LocaleKeys.payment.tr();
    }
  }

  ActivityType? get type {
    switch (this) {
      case ActivityFilterEnum.all:
        return null;
      case ActivityFilterEnum.sales:
        return ActivityType.sale;
      case ActivityFilterEnum.purchases:
        return ActivityType.purchase;
      case ActivityFilterEnum.payments:
        return ActivityType.payment;
    }
  }
}
