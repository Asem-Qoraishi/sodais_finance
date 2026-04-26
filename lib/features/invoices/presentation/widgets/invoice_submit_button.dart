import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';

class InvoiceSubmitButton extends StatelessWidget {
  const InvoiceSubmitButton({
    super.key,
    required this.isSubmitting,
    required this.onPressed,
    required this.label,
  });

  final bool isSubmitting;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isSubmitting ? null : onPressed,
      icon: isSubmitting
          ? SizedBox(
              width: sizeConstants.iconSmall,
              height: sizeConstants.iconSmall,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(Icons.save_outlined, size: sizeConstants.iconMedium),
      label: Text(isSubmitting ? LocaleKeys.saving.tr() : label),
    );
  }
}
