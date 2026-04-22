import 'package:flutter_test/flutter_test.dart';

import 'package:sodais_finance/features/invoices/presentation/controllers/invoice_form_state.dart';

void main() {
  test('InvoiceState computes totals and formatting', () {
    final invoiceState = InvoiceState(
      date: DateTime(2026, 4, 22),
      items: const [InvoiceItem(id: '1', name: 'Product A', qty: 2, price: 50)],
      paymentStatus: PaymentStatus.partialPaid,
      amountPaid: 30,
      discount: 10,
    );

    expect(invoiceState.subtotal, 100);
    expect(invoiceState.totalAmount, 90);
    expect(invoiceState.remainingAmount, 60);
    expect(formatInvoiceAmount(invoiceState.totalAmount), '90');
    expect(formatInvoiceAmount(90.5), '90.50');
  });
}
