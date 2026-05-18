import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/features/invoices/presentation/controllers/invoice_form_state.dart';
import 'package:sodais_finance/features/persons/data/repositories/person_repository_impl.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/persons/domain/persons_query_options.dart';
import 'package:sodais_finance/features/products/data/repositories/product_repository_impl.dart';
import 'package:sodais_finance/features/products/domain/product.dart';
import 'package:sodais_finance/features/products/domain/products_query_options.dart';
import '../../data/local/dao/invoice_dao.dart';
import '../../../app/data/app_database.dart';

final invoiceDaoProvider = Provider<InvoiceDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.invoiceDao;
});

final invoiceListProvider = FutureProvider((ref) async {
  final dao = ref.watch(invoiceDaoProvider);
  return dao.getAllInvoices();
});

final invoiceSummaryListProvider = FutureProvider<List<InvoiceSummary>>((
  ref,
) async {
  final dao = ref.watch(invoiceDaoProvider);
  return dao.getInvoiceSummaries();
});

final invoiceItemsProvider = FutureProvider.family((ref, int invoiceId) async {
  final dao = ref.watch(invoiceDaoProvider);
  return dao.getItemsForInvoice(invoiceId);
});

final invoiceContactsProvider =
    StreamProvider.family<List<Person>, InvoiceType>((ref, type) {
      final repository = ref.watch(personRepositoryProvider);
      final filter = type == InvoiceType.purchase
          ? PersonTypeFilter.suppliers
          : PersonTypeFilter.customers;

      return repository.watchPersons(
        query: '',
        typeFilter: filter,
        orderBy: PersonsOrderBy.alphabetAsc,
        pageSize: 1000,
      );
    });

final invoiceProductsProvider = StreamProvider<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryProvider);

  return repository.watchProducts(
    query: '',
    stockFilter: ProductStockFilter.all,
    orderBy: ProductsOrderBy.alphabetAsc,
    pageSize: 1000,
  );
});
