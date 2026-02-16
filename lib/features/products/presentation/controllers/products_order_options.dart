import 'package:easy_localization/easy_localization.dart';
import 'package:sodais_finance/core/enums/order_by_interface.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';

enum ProductsOrderOption implements OrderByInterface {
  alphabetAsc,
  alphabetDesc,
  highestStock,
  oldest,
  newest;

  @override
  String get name {
    switch (this) {
      case ProductsOrderOption.highestStock:
        return LocaleKeys.highestStock.tr();
      case ProductsOrderOption.alphabetAsc:
        return LocaleKeys.alphabetAsc.tr();
      case ProductsOrderOption.alphabetDesc:
        return LocaleKeys.alphabetDesc.tr();
      case ProductsOrderOption.oldest:
        return LocaleKeys.oldest.tr();
      case ProductsOrderOption.newest:
        return LocaleKeys.newest.tr();
    }
  }

  @override
  String get icon => switch (this) {
    ProductsOrderOption.highestStock => 'stock',
    ProductsOrderOption.alphabetAsc => 'alphabet_asc',
    ProductsOrderOption.alphabetDesc => 'alphabet_desc',
    ProductsOrderOption.oldest => 'oldest',
    ProductsOrderOption.newest => 'newest',
  };
}
