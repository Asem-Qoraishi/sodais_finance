import 'package:easy_localization/easy_localization.dart';
import 'package:sodais_finance/core/enums/order_by_interface.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';

enum TransactionsOrderOption implements OrderByInterface {
  newest,
  oldest,
  highestAmount,
  lowestAmount;

  @override
  String get name {
    switch (this) {
      case TransactionsOrderOption.newest:
        return LocaleKeys.newest.tr();
      case TransactionsOrderOption.oldest:
        return LocaleKeys.oldest.tr();
      case TransactionsOrderOption.highestAmount:
        return LocaleKeys.highestAmount.tr();
      case TransactionsOrderOption.lowestAmount:
        return LocaleKeys.lowestAmount.tr();
    }
  }

  @override
  String get icon => switch (this) {
    TransactionsOrderOption.newest => 'newest',
    TransactionsOrderOption.oldest => 'oldest',
    TransactionsOrderOption.highestAmount => 'highest_amount',
    TransactionsOrderOption.lowestAmount => 'lowest_amount',
  };
}
