import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sodais_finance/features/app/presentation/main_wrapper.dart';
import 'package:sodais_finance/features/invoices/presentation/controllers/invoice_form_state.dart';
import 'package:sodais_finance/features/invoices/presentation/screens/invoice_create_screen.dart';
import 'package:sodais_finance/features/invoices/presentation/screens/invoices_screen.dart';
import 'package:sodais_finance/features/payments/presentation/payments_screen.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/persons/presentation/add_new_person_screen.dart';
import 'package:sodais_finance/features/persons/presentation/persons_screen.dart';
import 'package:sodais_finance/features/persons/presentation/person_transactions_screen.dart';
import 'package:sodais_finance/features/products/domain/product.dart';
import 'package:sodais_finance/features/products/presentation/add_new_product_screen.dart';
import 'package:sodais_finance/features/products/presentation/inventory_screen.dart';
import 'package:sodais_finance/features/products/presentation/product_categories_screen.dart';
import 'package:sodais_finance/features/reports/presentation/reports_screen.dart';
import 'package:sodais_finance/features/settings/presentation/settings_screen.dart';
import 'package:sodais_finance/features/transactions/presentation/transactions_screen.dart';

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
  static final _shellNavigatorTransactionsKey = GlobalKey<NavigatorState>(
    debugLabel: 'shellTransactions',
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
    initialLocation: '/${routeNames.transactions}',
    routes: [
      // Build Shell routes
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainWrapper(navigationShell: navigationShell),
        branches: _buildShellBranches(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/${routeNames.persons}/${routeNames.addNewPerson}',
        name: routeNames.addNewPerson,
        builder: (context, state) => const AddNewPersonScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/${routeNames.persons}/${routeNames.editPerson}',
        name: routeNames.editPerson,
        builder: (context, state) {
          final person = state.extra is Person ? state.extra as Person : null;
          return AddNewPersonScreen(editingPerson: person);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/${routeNames.persons}/${routeNames.personTransactions}',
        name: routeNames.personTransactions,
        builder: (context, state) {
          final person = state.extra is Person ? state.extra as Person : null;
          if (person == null) {
            return const PersonsScreen();
          }
          return PersonTransactionsScreen(person: person);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/${routeNames.inventory}/${routeNames.addNewProduct}',
        name: routeNames.addNewProduct,
        builder: (context, state) => const AddNewProductScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/${routeNames.inventory}/${routeNames.editProduct}',
        name: routeNames.editProduct,
        builder: (context, state) {
          final product = state.extra is Product
              ? state.extra as Product
              : null;
          return AddNewProductScreen(editingProduct: product);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path:
            '/${routeNames.transactions}/${routeNames.editInvoice}/:invoiceId',
        name: routeNames.editInvoice,
        builder: (context, state) {
          final invoiceId = int.tryParse(
            state.pathParameters['invoiceId'] ?? '',
          );

          if (invoiceId == null) {
            return const InvoicesScreen();
          }

          return InvoiceCreateScreen(
            type: InvoiceType.sale,
            invoiceId: invoiceId,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path:
            '/${routeNames.inventory}/${routeNames.addNewProduct}/${routeNames.manageProductCategories}',
        name: routeNames.manageProductCategories,
        builder: (context, state) => const ProductCategoriesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/${routeNames.addNewSale}',
        name: routeNames.addNewSale,
        builder: (context, state) =>
            const InvoiceCreateScreen(type: InvoiceType.sale),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/${routeNames.addNewPurchase}',
        name: routeNames.addNewPurchase,
        builder: (context, state) =>
            const InvoiceCreateScreen(type: InvoiceType.purchase),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/${routeNames.addNewPayment}',
        name: routeNames.addNewPayment,
        builder: (context, state) =>
            const PaymentsScreen(entryType: CashEntryType.payment),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/${routeNames.addNewReceipt}',
        name: routeNames.addNewReceipt,
        builder: (context, state) =>
            const PaymentsScreen(entryType: CashEntryType.receipt),
      ),
    ],
  );

  static List<StatefulShellBranch> _buildShellBranches() {
    return [
      StatefulShellBranch(
        navigatorKey: _shellNavigatorTransactionsKey,
        routes: [
          GoRoute(
            path: "/${routeNames.transactions}",
            name: routeNames.transactions,
            builder: (context, state) => const TransactionsScreen(),
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
                path: routeNames.productCategories,
                name: routeNames.productCategories,
                builder: (context, state) => const ProductCategoriesScreen(),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: _shellNavigatorReportsKey,
        routes: [
          GoRoute(
            path: "/${routeNames.settings}",
            name: routeNames.settings,
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: routeNames.reports,
                name: routeNames.reports,
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
