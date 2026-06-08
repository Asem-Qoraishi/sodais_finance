import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:sodais_finance/core/assets/assets.gen.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/utils/formatters/app_number_formatter.dart';
import 'package:sodais_finance/core/utils/helpers/app_locale_helper.dart';
import 'package:sodais_finance/core/widgets/buttons/type_toggle_buttons.dart';
import 'package:sodais_finance/core/widgets/cards/custom_card.dart';
import 'package:sodais_finance/core/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:sodais_finance/core/widgets/text_field/custom_text_field.dart';
import 'package:sodais_finance/features/invoices/application/providers/invoice_providers.dart';
import 'package:sodais_finance/features/invoices/presentation/controllers/invoice_form_controller.dart';
import 'package:sodais_finance/features/invoices/presentation/controllers/invoice_form_state.dart';
import 'package:sodais_finance/features/invoices/presentation/widgets/date_picker.dart';
import 'package:sodais_finance/features/invoices/presentation/widgets/invoice_item_list.dart';
import 'package:sodais_finance/features/invoices/presentation/widgets/invoice_payment_sheet.dart';
import 'package:sodais_finance/features/invoices/presentation/widgets/invoice_section_label.dart';
import 'package:sodais_finance/features/invoices/presentation/widgets/invoice_submit_button.dart';
import 'package:sodais_finance/features/invoices/presentation/widgets/invoice_total_amount.dart';

class InvoiceCreateScreen extends ConsumerStatefulWidget {
  const InvoiceCreateScreen({super.key, required this.type, this.invoiceId});

  final InvoiceType type;
  final int? invoiceId;

  @override
  ConsumerState<InvoiceCreateScreen> createState() =>
      _InvoiceCreateScreenState();
}

class _InvoiceCreateScreenState extends ConsumerState<InvoiceCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _discountController;
  late final TextEditingController _invoiceNumberController;
  bool _isSubmitting = false;
  bool _isInitializingInvoice = false;
  String? _initializationError;

  bool get _isEditing => widget.invoiceId != null;

  InvoiceControllerArgs get _controllerArgs =>
      InvoiceControllerArgs(type: widget.type, invoiceId: widget.invoiceId);

  @override
  void initState() {
    super.initState();
    _discountController = TextEditingController(text: '0');
    _invoiceNumberController = TextEditingController();

    if (_isEditing) {
      _isInitializingInvoice = true;
      Future.microtask(_loadExistingInvoice);
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    _invoiceNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingInvoice() async {
    final invoiceId = widget.invoiceId;
    if (invoiceId == null) return;

    if (mounted) {
      setState(() {
        _isInitializingInvoice = true;
        _initializationError = null;
      });
    }

    try {
      await ref
          .read(invoiceControllerProvider(_controllerArgs).notifier)
          .loadExistingInvoice(invoiceId);
      if (!mounted) return;
      setState(() {
        _isInitializingInvoice = false;
        _initializationError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isInitializingInvoice = false;
        _initializationError = error is StateError
            ? error.message.toString()
            : error.toString();
      });
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? LocaleKeys.invoiceUpdated.tr()
                : LocaleKeys.invoiceSaved.tr(),
          ),
        ),
      );
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

  Future<void> _deleteInvoice(InvoiceController controller) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: LocaleKeys.deleteInvoice.tr(),
      message: LocaleKeys.deleteInvoiceConfirmation.tr(),
    );

    if (!confirmed) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await controller.deleteInvoice();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(LocaleKeys.invoiceDeleted.tr())));
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

  Future<void> _openPaymentSheet({
    required InvoiceState invoiceState,
    required InvoiceController controller,
    InvoicePaymentDraft? payment,
  }) async {
    final paymentIndex = payment == null
        ? invoiceState.payments.length + 1
        : invoiceState.payments.indexWhere((entry) => entry.id == payment.id) +
              1;
    final availableBalance =
        invoiceState.remainingAmount + (payment?.amount ?? 0);

    final result = await showInvoicePaymentSheet(
      context: context,
      paymentIndex: paymentIndex < 1 ? 1 : paymentIndex,
      totalAmount: invoiceState.totalAmount,
      remainingAmount: availableBalance,
      initialAmount: payment?.amount,
      canDelete: payment != null,
    );

    if (!mounted || result == null) return;

    switch (result.action) {
      case InvoicePaymentSheetAction.save:
        if (payment == null) {
          controller.addPayment(amount: result.amount!);
        } else {
          controller.updatePayment(id: payment.id, amount: result.amount!);
        }
        break;
      case InvoicePaymentSheetAction.delete:
        if (payment != null) {
          controller.removePayment(payment.id);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerProvider = invoiceControllerProvider(_controllerArgs);
    final invoiceState = ref.watch(controllerProvider);
    final invoiceController = ref.read(controllerProvider.notifier);

    if (_isInitializingInvoice || _initializationError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(LocaleKeys.editInvoice.tr())),
        body: Center(
          child: _isInitializingInvoice
              ? const CircularProgressIndicator()
              : Padding(
                  padding: EdgeInsets.all(sizeConstants.spacingMedium),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: sizeConstants.iconXLarge,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      SizedBox(height: sizeConstants.spacingSmall),
                      Text(
                        _initializationError ??
                            LocaleKeys.failedToLoadInvoices.tr(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: sizeConstants.spacingSmall),
                      FilledButton.icon(
                        onPressed: _loadExistingInvoice,
                        icon: const Icon(Icons.refresh),
                        label: Text(LocaleKeys.retry.tr()),
                      ),
                    ],
                  ),
                ),
        ),
      );
    }

    final personsAsync = ref.watch(invoiceContactsProvider(invoiceState.type));
    final productsAsync = ref.watch(invoiceProductsProvider);

    final persons = personsAsync.asData?.value ?? const [];
    final products = productsAsync.asData?.value ?? const [];

    _syncController(_invoiceNumberController, invoiceState.invoiceNumber);
    _syncController(
      _discountController,
      formatInvoiceAmount(invoiceState.discount),
    );

    final pagePadding = sizeConstants.spacingMedium;

    final selectedContactId =
        persons.any((person) => person.id == invoiceState.contact?.id)
        ? invoiceState.contact?.id
        : null;
    final invoiceTypeOptions =
        _isEditing && invoiceState.type == InvoiceType.returned
        ? InvoiceType.values
        : InvoiceType.values
              .where((type) => type != InvoiceType.returned)
              .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? LocaleKeys.editInvoice.tr()
              : invoiceState.type.createTitle,
        ),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _isSubmitting
                  ? null
                  : () => _deleteInvoice(invoiceController),
              icon: const Icon(Icons.delete_outline),
              tooltip: LocaleKeys.deleteInvoice.tr(),
            ),
        ],
      ),
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
            label: _isEditing
                ? LocaleKeys.updateInvoice.tr()
                : LocaleKeys.saveInvoice.tr(),
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
                      options: invoiceTypeOptions,
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
                        onItemUnitChanged: invoiceController.updateItemUnit,
                      ),
                    ),
                    _InvoiceSection(
                      title: LocaleKeys.payment.tr(),
                      sectionNumber: 3,
                      child: Column(
                        spacing: sizeConstants.spacingMedium,
                        children: [
                          _InvoicePaymentsList(
                            payments: invoiceState.payments,
                            onPaymentTap: (payment) => _openPaymentSheet(
                              invoiceState: invoiceState,
                              controller: invoiceController,
                              payment: payment,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed:
                                      invoiceState.totalAmount <= 0 ||
                                          invoiceState.remainingAmount <= 0
                                      ? null
                                      : () => _openPaymentSheet(
                                          invoiceState: invoiceState,
                                          controller: invoiceController,
                                        ),
                                  icon: const Icon(Icons.add),
                                  label: Text(LocaleKeys.addPayment.tr()),
                                ),
                              ),
                              SizedBox(width: sizeConstants.spacingSmall),
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed:
                                      invoiceState.totalAmount <= 0 ||
                                          invoiceState.remainingAmount <= 0
                                      ? null
                                      : invoiceController.markFullyPaidNow,
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: Text(LocaleKeys.fullPaidNow.tr()),
                                ),
                              ),
                            ],
                          ),
                          if (invoiceState.amountPaid >
                              invoiceState.totalAmount)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                LocaleKeys.amountExceedsTotal.tr(),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
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
                            prefixIconSource: Assets.icons.money,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChange: (value) {
                              if (value.trim().isEmpty) {
                                invoiceController.updateDiscount(0);
                                return;
                              }

                              final discount = AppNumberFormatter.parseDouble(
                                value,
                              );
                              invoiceController.updateDiscount(discount);
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }

                              final parsed = AppNumberFormatter.parseDouble(
                                value,
                              );
                              if (parsed.isNegative) {
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

class _InvoicePaymentsList extends StatelessWidget {
  const _InvoicePaymentsList({
    required this.payments,
    required this.onPaymentTap,
  });

  final List<InvoicePaymentDraft> payments;
  final ValueChanged<InvoicePaymentDraft> onPaymentTap;

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(sizeConstants.spacingMedium),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text(
          LocaleKeys.noPaymentsYet.tr(),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
        ),
      );
    }

    return Column(
      children: [
        for (int index = 0; index < payments.length; index++) ...[
          _InvoicePaymentListTile(
            payment: payments[index],
            paymentIndex: index + 1,
            onTap: () => onPaymentTap(payments[index]),
          ),
          if (index != payments.length - 1)
            SizedBox(height: sizeConstants.spacingSmall),
        ],
      ],
    );
  }
}

class _InvoicePaymentListTile extends StatelessWidget {
  const _InvoicePaymentListTile({
    required this.payment,
    required this.paymentIndex,
    required this.onTap,
  });

  final InvoicePaymentDraft payment;
  final int paymentIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(sizeConstants.spacingMedium),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: sizeConstants.avatarXSmall,
              height: sizeConstants.avatarXSmall,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
              ),
              alignment: Alignment.center,
              child: Text(
                '$paymentIndex',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(width: sizeConstants.spacingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${LocaleKeys.payment.tr()} #$paymentIndex',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: sizeConstants.spacingXXSmall),
                  Text(
                    _formatDateTime(context, payment.recordedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: sizeConstants.spacingSmall),
            Text(
              _formatMoney(payment.amount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatMoney(double value) {
  return AppNumberFormatter.formatAmount(value);
}

String _formatDateTime(BuildContext context, DateTime date) {
  if (appLocaleHelper.isCurrentLanguageEnglish(context)) {
    return DateFormat('d MMM yyyy • hh:mm a').format(date);
  }

  final jalaliDate = Jalali.fromDateTime(date);
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${jalaliDate.day} ${jalaliDate.formatter.mN} ${jalaliDate.year} • $hour:$minute';
}
