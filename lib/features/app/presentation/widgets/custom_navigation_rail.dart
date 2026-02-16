import 'package:flutter/material.dart';
import 'package:sodais_finance/core/widgets/icons/custom_svg_icon.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/features/app/domain/main_nav_items_enum.dart';

class CustomNavigationRail extends StatelessWidget {
  const CustomNavigationRail({
    super.key,
    required this.onDestinationSelected,
    required this.selectedIndex,
  });

  final ValueChanged<int> onDestinationSelected;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final selectedIconColor = Theme.of(
      context,
    ).navigationRailTheme.selectedIconTheme!.color;
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      minWidth: 100,
      indicatorShape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(sizeConstants.radiusXSmall),
      ),
      destinations: MainNavItemsEnum.values.map((item) {
        return NavigationRailDestination(
          padding: EdgeInsets.all(sizeConstants.radiusXSmall),
          icon: CustomSvgIcon(iconSource: item.iconSource(), iconSize: 24),
          selectedIcon: CustomSvgIcon(
            iconSource: item.activeIconSource(),
            iconSize: 24,
            iconColor: selectedIconColor,
          ),
          label: Text(item.label()),
        );
      }).toList(),
    );
  }
}
