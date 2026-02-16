import 'package:easy_localization/easy_localization.dart';
import 'package:sodais_finance/config/app_router.dart';
import 'package:sodais_finance/core/assets/assets.gen.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';

enum MainNavItemsEnum {
  dashboard,
  persons,
  inventory,
  reports;

  String routeName() => switch (this) {
    MainNavItemsEnum.dashboard => routeNames.dashboard,
    MainNavItemsEnum.inventory => routeNames.inventory,
    MainNavItemsEnum.persons => routeNames.persons,
    MainNavItemsEnum.reports => routeNames.reports,
  };

  String iconSource() => switch (this) {
    MainNavItemsEnum.dashboard => Assets.icons.dashboard,
    MainNavItemsEnum.persons => Assets.icons.persons,
    MainNavItemsEnum.inventory => Assets.icons.warehouse,
    MainNavItemsEnum.reports => Assets.icons.charts,
  };

  String activeIconSource() => switch (this) {
    MainNavItemsEnum.dashboard => Assets.icons.dashboard,
    MainNavItemsEnum.persons => Assets.icons.persons,
    MainNavItemsEnum.inventory => Assets.icons.warehouse,
    MainNavItemsEnum.reports => Assets.icons.charts,
  };

  String label() => switch (this) {
    MainNavItemsEnum.dashboard => LocaleKeys.dashboard.tr(),
    MainNavItemsEnum.persons => LocaleKeys.persons.tr(),
    MainNavItemsEnum.inventory => LocaleKeys.inventory.tr(),
    MainNavItemsEnum.reports => LocaleKeys.reports.tr(),
  };
}
