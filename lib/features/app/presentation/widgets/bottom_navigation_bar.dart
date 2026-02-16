import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/constants/colors.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/widgets/icons/custom_svg_icon.dart';
import 'package:sodais_finance/features/app/domain/main_nav_items_enum.dart';

class CustomBottomNavBar extends ConsumerWidget {
  const CustomBottomNavBar({
    super.key,
    required this.onTap,
    required this.currentIndex,
  });

  final ValueChanged onTap;
  final int currentIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
        child: BottomNavigationBar(
          selectedLabelStyle: textTheme.labelMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
          unselectedLabelStyle: textTheme.labelMedium,
          currentIndex: currentIndex,
          onTap: onTap,
          items: _buildNavigationItems(context),
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavigationItems(BuildContext context) {
    final bottomNavTheme = Theme.of(context).bottomNavigationBarTheme;
    return List.generate(MainNavItemsEnum.values.length, (index) {
      final mainNavItemsEnum = MainNavItemsEnum.values[index];
      return BottomNavigationBarItem(
        icon: CustomSvgIcon(
          iconSource: mainNavItemsEnum.iconSource(),
          iconColor: bottomNavTheme.unselectedItemColor,
          padding: sizeConstants.radiusSmall,
        ),
        activeIcon: CustomSvgIcon(
          iconSource: mainNavItemsEnum.activeIconSource(),
          iconColor: bottomNavTheme.selectedItemColor,
          padding: sizeConstants.radiusSmall,
        ),
        label: mainNavItemsEnum.label(),
      );
    });
  }
}
