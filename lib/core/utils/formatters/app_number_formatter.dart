import 'package:flutter/services.dart';

class AppNumberFormatter {
  AppNumberFormatter._();

  static String formatAmount(
    num value, {
    String currencySymbol = 'Af',
    bool includeCurrency = true,
  }) {
    final sign = value < 0 ? '-' : '';
    final formattedNumber = formatDecimal(value.abs());
    final prefix = includeCurrency ? currencySymbol : '';
    return '$sign$prefix$formattedNumber';
  }

  static String formatDecimal(
    num value, {
    int maxFractionDigits = 2,
    bool useGrouping = true,
  }) {
    final number = value.abs();
    final fixed = number.toStringAsFixed(maxFractionDigits);
    final parts = fixed.split('.');
    final integerPart = useGrouping
        ? _withThousandsSeparator(parts.first)
        : parts.first;

    if (parts.length == 1) return integerPart;

    final fractionPart = parts.last.replaceFirst(RegExp(r'0+$'), '');
    if (fractionPart.isEmpty) return integerPart;
    return '$integerPart.$fractionPart';
  }

  static String formatInteger(int value, {bool useGrouping = true}) {
    if (!useGrouping) return value.toString();
    final sign = value < 0 ? '-' : '';
    return '$sign${_withThousandsSeparator(value.abs().toString())}';
  }

  static double parseDouble(String? value) {
    final normalized = _sanitizeForParsing(value);
    return double.tryParse(normalized) ?? 0.0;
  }

  static int parseInt(String? value) {
    final normalized = _sanitizeForParsing(value);
    return int.tryParse(normalized) ?? 0;
  }

  static String _sanitizeForParsing(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return '';

    return trimmed
        .replaceAll(',', '')
        .replaceAll('Af', '')
        .replaceAll(r'$', '')
        .replaceAll(' ', '');
  }

  static String _withThousandsSeparator(String value) {
    final buffer = StringBuffer();

    for (int index = 0; index < value.length; index++) {
      final remaining = value.length - index;
      buffer.write(value[index]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }
}

class AppNumberTextInputFormatter extends TextInputFormatter {
  AppNumberTextInputFormatter({
    this.allowDecimal = false,
    this.maxDecimalDigits = 2,
  });

  final bool allowDecimal;
  final int maxDecimalDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final sanitized = _sanitize(newValue.text);
    if (sanitized.isEmpty) {
      return const TextEditingValue();
    }

    final parts = sanitized.split('.');
    final integerPart = parts.first;
    final decimalPart = parts.length > 1 ? parts[1] : '';
    final formattedInteger = integerPart.isEmpty
        ? '0'
        : AppNumberFormatter.formatInteger(int.parse(integerPart));

    final formatted = allowDecimal && sanitized.contains('.')
        ? '$formattedInteger.${decimalPart.substring(0, decimalPart.length.clamp(0, maxDecimalDigits))}'
        : formattedInteger;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _sanitize(String input) {
    final buffer = StringBuffer();
    var hasDot = false;

    for (final char in input.split('')) {
      if (_isDigit(char)) {
        buffer.write(char);
        continue;
      }

      if (allowDecimal && char == '.' && !hasDot) {
        buffer.write(char);
        hasDot = true;
      }
    }

    return buffer.toString();
  }

  bool _isDigit(String value) =>
      value.codeUnitAt(0) >= 48 && value.codeUnitAt(0) <= 57;
}
