import 'package:easy_localization/easy_localization.dart';
import 'package:sodais_finance/core/enums/order_by_interface.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';

enum PersonsOrderOption implements OrderByInterface {
  recentlyActive,
  lastPyament,
  lastReceipt,
  alphabetAsc,
  alphabetDesc,
  highestDebt,
  highestCredit,
  oldest,
  newest;

  @override
  String get name {
    switch (this) {
      case PersonsOrderOption.recentlyActive:
        return LocaleKeys.recentlyActive.tr();
      case PersonsOrderOption.lastPyament:
        return LocaleKeys.lastPayment.tr();
      case PersonsOrderOption.lastReceipt:
        return LocaleKeys.lastReceipt.tr();
      case PersonsOrderOption.alphabetAsc:
        return LocaleKeys.alphabetAsc.tr();
      case PersonsOrderOption.alphabetDesc:
        return LocaleKeys.alphabetDesc.tr();
      case PersonsOrderOption.highestDebt:
        return LocaleKeys.highestDebt.tr();
      case PersonsOrderOption.highestCredit:
        return LocaleKeys.highestCredit.tr();
      case PersonsOrderOption.oldest:
        return LocaleKeys.oldest.tr();
      case PersonsOrderOption.newest:
        return LocaleKeys.newest.tr();
    }
  }

  @override
  String get icon => switch (this) {
    PersonsOrderOption.recentlyActive => 'last_active',
    PersonsOrderOption.lastPyament => 'last_payment',
    PersonsOrderOption.lastReceipt => 'last_receipt',
    PersonsOrderOption.alphabetAsc => 'alphabet_asc',
    PersonsOrderOption.alphabetDesc => 'alphabet_desc',
    PersonsOrderOption.highestDebt => 'highest_debt',
    PersonsOrderOption.highestCredit => 'highest_credit',
    PersonsOrderOption.oldest => 'oldest',
    PersonsOrderOption.newest => 'newest',
  };
}
