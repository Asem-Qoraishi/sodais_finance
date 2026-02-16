import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/assets/assets.gen.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';

enum ActivityType {
  sale,
  purchase,
  payment,
  reciept;

  String get name {
    switch (this) {
      case ActivityType.sale:
        return LocaleKeys.sale.tr();
      case ActivityType.purchase:
        return LocaleKeys.purchase.tr();
      case ActivityType.payment:
        return LocaleKeys.payment.tr();
      case ActivityType.reciept:
        return LocaleKeys.receipt.tr();
    }
  }

  String get iconSource {
    switch (this) {
      case ActivityType.sale:
        return Assets.icons.sellProducts;
      case ActivityType.purchase:
        return Assets.icons.buyProducts;
      case ActivityType.payment:
        return Assets.icons.payment;
      case ActivityType.reciept:
        return Assets.icons.payment;
    }
  }

  Color get color {
    switch (this) {
      case ActivityType.sale:
        return Colors.green;
      case ActivityType.purchase:
        return Colors.blue;
      case ActivityType.payment:
        return Colors.orange;
      case ActivityType.reciept:
        return Colors.purple;
    }
  }
}
