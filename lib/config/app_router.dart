import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sodais_finance/features/app/presentation/main_wrapper.dart';
import 'package:sodais_finance/features/dashboard/presentation/dashboard_screen.dart';
import 'package:sodais_finance/features/persons/presentation/add_new_person_screen.dart';
import 'package:sodais_finance/features/persons/presentation/persons_screen.dart';
import 'package:sodais_finance/features/products/presentation/add_new_product_screen.dart';
import 'package:sodais_finance/features/products/presentation/inventory_screen.dart';
import 'package:sodais_finance/features/reports/presentation/reports_screen.dart';

part 'route_names.dart';

class AppRouter {
  // Singleton instance
  static final AppRouter _instance = AppRouter._internal();

  factory AppRouter() => _instance;

  AppRouter._internal();

  // Unique GlobalKey instances for each navigator
  static final _rootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'rootNavigator',
  );
  static final _shellNavigatorDashboardKey = GlobalKey<NavigatorState>(
    debugLabel: 'shellDashboard',
  );
  static final _shellNavigatorPersonsKey = GlobalKey<NavigatorState>(
    debugLabel: 'shellPersons',
  );
  static final _shellNavigatorInventoryKey = GlobalKey<NavigatorState>(
    debugLabel: 'shellInventory',
  );
  static final _shellNavigatorReportsKey = GlobalKey<NavigatorState>(
    debugLabel: 'shellReports',
  );

  final goRouter = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/${routeNames.dashboard}',
    routes: [
      // Build Shell routes
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainWrapper(navigationShell: navigationShell),
        branches: _buildShellBranches(),
      ),

      // Build nested routes
    ],
  );

  static List<StatefulShellBranch> _buildShellBranches() {
    return [
      StatefulShellBranch(
        navigatorKey: _shellNavigatorDashboardKey,
        routes: [
          GoRoute(
            path: "/${routeNames.dashboard}",
            name: routeNames.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: _shellNavigatorPersonsKey,
        routes: [
          GoRoute(
            path: "/${routeNames.persons}",
            name: routeNames.persons,
            builder: (context, state) => const PersonsScreen(),
            routes: [
              GoRoute(
                path: "/${routeNames.addNewPerson}",
                name: routeNames.addNewPerson,
                builder: (context, state) => const AddNewPersonScreen(),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: _shellNavigatorInventoryKey,
        routes: [
          GoRoute(
            path: "/${routeNames.inventory}",
            name: routeNames.inventory,
            builder: (context, state) => const InventoryScreen(),
            routes: [
              GoRoute(
                path: "/${routeNames.addNewProduct}",
                name: routeNames.addNewProduct,
                builder: (context, state) => const AddNewProductScreen(),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: _shellNavigatorReportsKey,
        routes: [
          GoRoute(
            path: "/${routeNames.reports}",
            name: routeNames.reports,
            builder: (context, state) => const ReportsScreen(),
          ),
        ],
      ),
    ];
  }
}
