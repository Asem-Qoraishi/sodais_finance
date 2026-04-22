import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/widgets/buttons/type_toggle_buttons.dart';
import 'package:sodais_finance/core/widgets/cards/custom_card.dart';
import 'package:sodais_finance/core/widgets/text_field/custom_text_field.dart';
import 'package:sodais_finance/features/invoices/application/providers/invoice_providers.dart';
import 'package:sodais_finance/features/invoices/presentation/controllers/invoice_form_controller.dart';
import 'package:sodais_finance/features/invoices/presentation/controllers/invoice_form_state.dart';
import 'package:sodais_finance/features/invoices/presentation/widgets/date_picker.dart';
import 'package:sodais_finance/features/invoices/presentation/widgets/invoice_item_list.dart';
import 'package:sodais_finance/features/invoices/presentation/widgets/invoice_section_label.dart';
import 'package:sodais_finance/features/invoices/presentation/widgets/invoice_submit_button.dart';
import 'package:sodais_finance/features/invoices/presentation/widgets/invoice_total_amount.dart';

class InvoiceCreateScreen extends ConsumerStatefulWidget {
  const InvoiceCreateScreen({super.key, required this.type});

  final InvoiceType type;

  @override
  ConsumerState<InvoiceCreateScreen> createState() =>
      _InvoiceCreateScreenState();
}

class _InvoiceCreateScreenState extends ConsumerState<InvoiceCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountPaidController;
  late final TextEditingController _discountController;
  late final TextEditingController _invoiceNumberController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountPaidController = TextEditingController(text: '0');
    _discountController = TextEditingController(text: '0');
    _invoiceNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _amountPaidController.dispose();
    _discountController.dispose();
    _invoiceNumberController.dispose();
    super.dispose();
  }

  void _syncController(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  Future<void> _submitInvoice(
    InvoiceController controller,
    InvoiceState invoiceState,
  ) async {
    FocusScope.of(context).unfocus();

    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    if (invoiceState.contact == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(LocaleKeys.selectContact.tr())));
      return;
    }

    if (invoiceState.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.addAtLeastOneItem.tr())),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await controller.saveInvoice();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(LocaleKeys.invoiceSaved.tr())));
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      final message = error is StateError
          ? error.message.toString()
          : error.toString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceState = ref.watch(invoiceControllerProvider(widget.type));
    final invoiceController = ref.read(
      invoiceControllerProvider(widget.type).notifier,
    );
    final personsAsync = ref.watch(invoiceContactsProvider(invoiceState.type));
    final productsAsync = ref.watch(invoiceProductsProvider);

    final persons = personsAsync.asData?.value ?? const [];
    final products = productsAsync.asData?.value ?? const [];

    _syncController(_invoiceNumberController, invoiceState.invoiceNumber);
    _syncController(
      _amountPaidController,
      formatInvoiceAmount(invoiceState.amountPaid),
    );
    _syncController(
      _discountController,
      formatInvoiceAmount(invoiceState.discount),
    );

    final pagePadding = sizeConstants.spacingMedium;

    final selectedContactId =
        persons.any((person) => person.id == invoiceState.contact?.id)
        ? invoiceState.contact?.id
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(invoiceState.type.createTitle)),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            pagePadding,
            sizeConstants.spacingXSmall,
            pagePadding,
            pagePadding,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: InvoiceSubmitButton(
            isSubmitting: _isSubmitting,
            onPressed: () => _submitInvoice(invoiceController, invoiceState),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              pagePadding,
              pagePadding,
              pagePadding,
              sizeConstants.spacingXXLarge * 2,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  spacing: sizeConstants.spacingLarge,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TypeToggleButtons(
                      options: InvoiceType.values,
                      selectedOption: invoiceState.type,
                      onApply: invoiceController.updateType,
                    ),
                    _InvoiceSection(
                      title: LocaleKeys.details.tr(),
                      sectionNumber: 1,
                      child: Column(
                        spacing: sizeConstants.spacingMedium,
                        children: [
                          DropdownButtonFormField<String>(
                            key: ValueKey(
                              '${invoiceState.type.name}-$selectedContactId',
                            ),
                            initialValue: selectedContactId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: invoiceState.type.contactLabel,
                            ),
                            items: persons
                                .map(
                                  (person) => DropdownMenuItem<String>(
                                    value: person.id,
                                    child: Text(person.name),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: (contactId) {
                              for (final person in persons) {
                                if (person.id == contactId) {
                                  invoiceController.updateContact(person);
                                  break;
                                }
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return LocaleKeys.fieldRequired.tr();
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            controller: _invoiceNumberController,
                            label: LocaleKeys.invoice_number.tr(),
                            readOnly: true,
                          ),
                          CustomDatePicker(
                            label: LocaleKeys.issue_date.tr(),
                            date: invoiceState.date,
                            onPickedDate: (date) {
                              if (date != null) {
                                invoiceController.updateDate(date);
                              }
                            },
                          ),
                          CustomDatePicker(
                            label:
                                '${LocaleKeys.due_date.tr()} (${LocaleKeys.optional.tr()})',
                            date: invoiceState.dueDate,
                            isOptional: true,
                            onPickedDate: invoiceController.updateDueDate,
                          ),
                        ],
                      ),
                    ),
                    _InvoiceSection(
                      title: LocaleKeys.items.tr(),
                      sectionNumber: 2,
                      child: InvoiceItemList(
                        invoiceState: invoiceState,
                        products: products,
                        onAddItem: () {
                          final suggestedProduct = invoiceState
                              .suggestedProduct(products);
                          if (suggestedProduct == null) return;
                          invoiceController.addProductItem(suggestedProduct);
                        },
                        onRemoveItem: invoiceController.removeItem,
                        onItemProductChanged:
                            invoiceController.updateItemProduct,
                        onItemQuantityChanged:
                            invoiceController.updateItemQuantity,
                        onItemPriceChanged: invoiceController.updateItemPrice,
                      ),
                    ),
                    _InvoiceSection(
                      title: LocaleKeys.payment.tr(),
                      sectionNumber: 3,
                      child: Column(
                        spacing: sizeConstants.spacingMedium,
                        children: [
                          TypeToggleButtons(
                            options: PaymentStatus.values,
                            selectedOption: invoiceState.paymentStatus,
                            onApply: invoiceController.updatePaymentStatus,
                          ),
                          if (invoiceState.paymentStatus !=
                              PaymentStatus.unpaid)
                            CustomTextField(
                              controller: _amountPaidController,
                              label: LocaleKeys.amountPaid.tr(),
                              readOnly:
                                  invoiceState.paymentStatus ==
                                  PaymentStatus.paid,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onChange: (value) {
                                if (value.trim().isEmpty) {
                                  invoiceController.updateAmountPaid(0);
                                  return;
                                }

                                final amount = double.tryParse(value);
                                if (amount == null) return;
                                invoiceController.updateAmountPaid(amount);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) return null;
                                final amount = double.tryParse(value);
                                if (amount == null || amount.isNegative) {
                                  return LocaleKeys.invalidNumber.tr();
                                }
                                if (amount > invoiceState.totalAmount) {
                                  return LocaleKeys.amountExceedsTotal.tr();
                                }
                                return null;
                              },
                            ),
                        ],
                      ),
                    ),
                    _InvoiceSection(
                      title: LocaleKeys.summary.tr(),
                      sectionNumber: 4,
                      child: Column(
                        spacing: sizeConstants.spacingMedium,
                        children: [
                          CustomTextField(
                            controller: _discountController,
                            label: LocaleKeys.discount.tr(),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChange: (value) {
                              if (value.trim().isEmpty) {
                                invoiceController.updateDiscount(0);
                                return;
                              }

                              final discount = double.tryParse(value);
                              if (discount == null) return;
                              invoiceController.updateDiscount(discount);
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }

                              final parsed = double.tryParse(value);
                              if (parsed == null || parsed.isNegative) {
                                return LocaleKeys.invalidNumber.tr();
                              }
                              return null;
                            },
                          ),
                          InvoiceTotalAmount(invoiceState: invoiceState),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoiceSection extends StatelessWidget {
  const _InvoiceSection({
    required this.title,
    required this.sectionNumber,
    required this.child,
  });

  final String title;
  final int sectionNumber;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: sizeConstants.spacingSmall,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InvoiceSectionLabel(text: title, sectionNumber: sectionNumber),
        CustomCard(child: child),
      ],
    );
  }
}
