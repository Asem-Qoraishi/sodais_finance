import 'package:easy_localization/easy_localization.dart';
import 'package:sodais_finance/config/app_router.dart';
import 'package:sodais_finance/core/assets/assets.gen.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';

enum MainNavItemsEnum {
  transactions,
  persons,
  inventory,
  settings;

  String routeName() => switch (this) {
    MainNavItemsEnum.transactions => routeNames.transactions,
    MainNavItemsEnum.inventory => routeNames.inventory,
    MainNavItemsEnum.persons => routeNames.persons,
    MainNavItemsEnum.settings => routeNames.settings,
  };

  String iconSource() => switch (this) {
    MainNavItemsEnum.transactions => Assets.icons.transactionOutline,
    MainNavItemsEnum.persons => Assets.icons.personOutline,
    MainNavItemsEnum.inventory => Assets.icons.productOutline,
    MainNavItemsEnum.settings => Assets.icons.settingsOutline,
  };

  String activeIconSource() => switch (this) {
    MainNavItemsEnum.transactions => Assets.icons.transactionFill,
    MainNavItemsEnum.persons => Assets.icons.personFill,
    MainNavItemsEnum.inventory => Assets.icons.productFill,
    MainNavItemsEnum.settings => Assets.icons.settingsFill,
  };

  String label() => switch (this) {
    MainNavItemsEnum.transactions => LocaleKeys.transactions.tr(),
    MainNavItemsEnum.persons => LocaleKeys.persons.tr(),
    MainNavItemsEnum.inventory => LocaleKeys.inventory.tr(),
    MainNavItemsEnum.settings => LocaleKeys.settings.tr(),
  };
}
