import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/assets/assets.gen.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/utils/formatters/app_number_formatter.dart';
import 'package:sodais_finance/core/widgets/text_field/custom_text_field.dart';
import 'package:sodais_finance/features/invoices/presentation/controllers/invoice_form_state.dart';

enum InvoicePaymentSheetAction { save, delete }

class InvoicePaymentSheetResult {
  const InvoicePaymentSheetResult.save(this.amount)
    : action = InvoicePaymentSheetAction.save;

  const InvoicePaymentSheetResult.delete()
    : action = InvoicePaymentSheetAction.delete,
      amount = null;

  final InvoicePaymentSheetAction action;
  final double? amount;
}

Future<InvoicePaymentSheetResult?> showInvoicePaymentSheet({
  required BuildContext context,
  required int paymentIndex,
  required double totalAmount,
  required double remainingAmount,
  double? initialAmount,
  bool canDelete = false,
}) {
  return showModalBottomSheet<InvoicePaymentSheetResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _InvoicePaymentSheet(
      paymentIndex: paymentIndex,
      totalAmount: totalAmount,
      remainingAmount: remainingAmount,
      initialAmount: initialAmount,
      canDelete: canDelete,
    ),
  );
}

class _InvoicePaymentSheet extends StatefulWidget {
  const _InvoicePaymentSheet({
    required this.paymentIndex,
    required this.totalAmount,
    required this.remainingAmount,
    required this.initialAmount,
    required this.canDelete,
  });

  final int paymentIndex;
  final double totalAmount;
  final double remainingAmount;
  final double? initialAmount;
  final bool canDelete;

  @override
  State<_InvoicePaymentSheet> createState() => _InvoicePaymentSheetState();
}

class _InvoicePaymentSheetState extends State<_InvoicePaymentSheet> {
  late final TextEditingController _amountController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount == null
          ? ''
          : formatInvoiceAmount(widget.initialAmount!),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = AppNumberFormatter.parseDouble(_amountController.text);
    Navigator.of(context).pop(InvoicePaymentSheetResult.save(amount));
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          sizeConstants.spacingMedium,
          sizeConstants.spacingSmall,
          sizeConstants.spacingMedium,
          sizeConstants.spacingMedium + viewInsets,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${LocaleKeys.payment.tr()} #${widget.paymentIndex}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              SizedBox(height: sizeConstants.spacingXSmall),
              Wrap(
                spacing: sizeConstants.spacingXSmall,
                runSpacing: sizeConstants.spacingXSmall,
                children: [
                  _InfoPill(
                    label:
                        '${LocaleKeys.total.tr()}: ${_formatMoney(widget.totalAmount)}',
                  ),
                  _InfoPill(
                    label:
                        '${LocaleKeys.balance.tr()}: ${_formatMoney(widget.remainingAmount)}',
                  ),
                ],
              ),
              SizedBox(height: sizeConstants.spacingMedium),
              CustomTextField(
                controller: _amountController,
                label: LocaleKeys.amount.tr(),
                prefixIconSource: Assets.icons.money,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  AppNumberTextInputFormatter(allowDecimal: true),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return LocaleKeys.fieldRequired.tr();
                  }
                  final amount = AppNumberFormatter.parseDouble(value);
                  if (amount <= 0) {
                    return LocaleKeys.invalidNumber.tr();
                  }
                  if (amount > widget.remainingAmount) {
                    return LocaleKeys.amountExceedsTotal.tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: sizeConstants.spacingMedium),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(LocaleKeys.cancel.tr()),
                    ),
                  ),
                  SizedBox(width: sizeConstants.spacingSmall),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.canDelete
                          ? () => Navigator.of(
                              context,
                            ).pop(const InvoicePaymentSheetResult.delete())
                          : null,
                      child: Text(LocaleKeys.delete.tr()),
                    ),
                  ),
                  SizedBox(width: sizeConstants.spacingSmall),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submit,
                      child: Text(
                        widget.initialAmount == null
                            ? LocaleKeys.add.tr()
                            : LocaleKeys.save.tr(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizeConstants.spacingSmall,
        vertical: sizeConstants.spacingXXSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(sizeConstants.radiusMax),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

String _formatMoney(double value) {
  return AppNumberFormatter.formatAmount(value);
}
