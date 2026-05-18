import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/widgets/text_field/custom_text_field.dart';
import 'package:sodais_finance/features/invoices/presentation/widgets/date_picker.dart';
import 'package:sodais_finance/features/persons/data/repositories/person_repository_impl.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/persons/domain/persons_query_options.dart';
import 'package:sodais_finance/features/transactions/application/providers/transaction_providers.dart';
import 'package:sodais_finance/features/transactions/domain/transactions_repository.dart';

enum CashEntryType { payment, receipt }

extension CashEntryTypeX on CashEntryType {
  String get transactionType =>
      this == CashEntryType.payment ? 'expense' : 'income';

  String title(BuildContext context) {
    return switch (this) {
      CashEntryType.payment => LocaleKeys.addNewPayment.tr(),
      CashEntryType.receipt => LocaleKeys.addNewReceipt.tr(),
    };
  }

  String saveLabel(BuildContext context) {
    return switch (this) {
      CashEntryType.payment => LocaleKeys.savePayment.tr(),
      CashEntryType.receipt => LocaleKeys.saveReceipt.tr(),
    };
  }

  String successMessage(BuildContext context) {
    return switch (this) {
      CashEntryType.payment => LocaleKeys.paymentSaved.tr(),
      CashEntryType.receipt => LocaleKeys.receiptSaved.tr(),
    };
  }

  String contactLabel(BuildContext context) {
    return LocaleKeys.person.tr();
  }

  IconData get icon {
    return switch (this) {
      CashEntryType.payment => Icons.arrow_upward_rounded,
      CashEntryType.receipt => Icons.arrow_downward_rounded,
    };
  }
}

final paymentContactsProvider = StreamProvider<List<Person>>((ref) {
  final repository = ref.watch(personRepositoryProvider);
  return repository.watchPersons(
    query: '',
    typeFilter: PersonTypeFilter.all,
    orderBy: PersonsOrderBy.alphabetAsc,
    pageSize: 1000,
  );
});

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key, required this.entryType});

  final CashEntryType entryType;

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedContactId;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    final contactId = int.tryParse(_selectedContactId ?? '');
    if (contactId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(LocaleKeys.selectContact.tr())));
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(LocaleKeys.invalidNumber.tr())));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref
          .read(recordManualTransactionUseCaseProvider)
          .call(
            ManualTransactionRequest(
              contactId: contactId,
              amount: amount,
              type: widget.entryType.transactionType,
              recordedAt: _selectedDate,
              description: _descriptionController.text,
            ),
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.entryType.successMessage(context))),
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

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(paymentContactsProvider);
    final contacts = contactsAsync.asData?.value ?? const <Person>[];
    final selectedContactId =
        contacts.any((person) => person.id == _selectedContactId)
        ? _selectedContactId
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(widget.entryType.title(context))),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            sizeConstants.spacingMedium,
            sizeConstants.spacingXSmall,
            sizeConstants.spacingMedium,
            sizeConstants.spacingMedium,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: FilledButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: _isSubmitting
                ? SizedBox(
                    width: sizeConstants.iconSmall,
                    height: sizeConstants.iconSmall,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(widget.entryType.icon, size: sizeConstants.iconMedium),
            label: Text(
              _isSubmitting
                  ? LocaleKeys.saving.tr()
                  : widget.entryType.saveLabel(context),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: contactsAsync.when(
          data: (contacts) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  sizeConstants.spacingMedium,
                  sizeConstants.spacingMedium,
                  sizeConstants.spacingMedium,
                  sizeConstants.spacingXXLarge * 2,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: selectedContactId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: widget.entryType.contactLabel(context),
                          ),
                          items: contacts
                              .map(
                                (person) => DropdownMenuItem<String>(
                                  value: person.id,
                                  child: Text(person.name),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            setState(() {
                              _selectedContactId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return LocaleKeys.fieldRequired.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: sizeConstants.spacingMedium),
                        CustomTextField(
                          controller: _amountController,
                          label: LocaleKeys.amount.tr(),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return LocaleKeys.fieldRequired.tr();
                            }
                            final amount = double.tryParse(value.trim());
                            if (amount == null || amount <= 0) {
                              return LocaleKeys.invalidNumber.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: sizeConstants.spacingMedium),
                        CustomDatePicker(
                          label: LocaleKeys.select_date.tr(),
                          date: _selectedDate,
                          onPickedDate: (date) {
                            if (date == null) return;
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                        ),
                        SizedBox(height: sizeConstants.spacingMedium),
                        CustomTextField(
                          controller: _descriptionController,
                          label:
                              '${LocaleKeys.description.tr()} (${LocaleKeys.optional.tr()})',
                          hintText: LocaleKeys.descriptionHint.tr(),
                          prefixIconData: Icons.notes_rounded,
                          maxLines: 3,
                          minLines: 3,
                          textInputAction: TextInputAction.newline,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: EdgeInsets.all(sizeConstants.spacingMedium),
              child: Text(
                LocaleKeys.failedToLoadPersons.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
