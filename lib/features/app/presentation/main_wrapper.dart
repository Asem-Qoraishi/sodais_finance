import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sodais_finance/features/app/presentation/widgets/scaffold_with_bottom_nav.dart';
import 'package:sodais_finance/features/app/presentation/widgets/scaffold_with_navigation_rail.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 450) {
          return ScaffoldWithBottomNav(navigationShell: navigationShell);
        } else {
          return ScaffoldWithNavigationRail(navigationShell: navigationShell);
        }
      },
    );
  }
}
