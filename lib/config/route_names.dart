part of 'app_router.dart';

class RouteNames {
  RouteNames._();

  static final RouteNames _instance = RouteNames._();

  factory RouteNames() => _instance;

  // Main app routes
  final String dashboard = 'dashboard';
  final String persons = 'persons';
  final String inventory = 'inventory';
  final String finance = 'finance';
  final String reports = 'reports';
  final String addNewPerson = 'addNewPerson';
  final String addNewProduct = 'addNewProduct';
  final String addNewSale = 'addNewSale';
  final String addNewPurchase = 'addNewPurchase';
  final String addNewPayment = 'addNewPayment';
  final String addNewReceipt = 'addNewReceipt';
}

RouteNames routeNames = RouteNames();
