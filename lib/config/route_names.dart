part of 'app_router.dart';

class RouteNames {
  RouteNames._();

  static final RouteNames _instance = RouteNames._();

  factory RouteNames() => _instance;

  // Main app routes
  final String persons = 'persons';
  final String inventory = 'inventory';
  final String transactions = 'transactions';
  final String finance = 'finance';
  final String settings = 'settings';
  final String reports = 'reports';
  final String addNewPerson = 'addNewPerson';
  final String editPerson = 'editPerson';
  final String personTransactions = 'personTransactions';
  final String addNewProduct = 'addNewProduct';
  final String editProduct = 'editProduct';
  final String editInvoice = 'editInvoice';
  final String productCategories = 'productCategories';
  final String manageProductCategories = 'manageProductCategories';
  final String addNewSale = 'addNewSale';
  final String addNewPurchase = 'addNewPurchase';
  final String addNewPayment = 'addNewPayment';
  final String addNewReceipt = 'addNewReceipt';
}

RouteNames routeNames = RouteNames();
