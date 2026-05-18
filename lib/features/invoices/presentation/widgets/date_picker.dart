import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/utils/helpers/app_locale_helper.dart';
import 'package:sodais_finance/core/widgets/text_field/custom_text_field.dart';

class CustomDatePicker extends StatefulWidget {
  const CustomDatePicker({
    super.key,
    required this.onPickedDate,
    required this.date,
    this.initialDate,
    this.isOptional = false,
    this.label,
    this.useJalaliCalendar = false,
  });

  final ValueChanged<DateTime?> onPickedDate;
  final DateTime? initialDate;
  final DateTime? date;
  final bool isOptional;
  final String? label;
  final bool useJalaliCalendar;

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncText();
  }

  @override
  void didUpdateWidget(covariant CustomDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date ||
        oldWidget.useJalaliCalendar != widget.useJalaliCalendar) {
      _syncText();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDariDate(Jalali date) {
    final f = date.formatter;
    return '${f.wN} ${f.d} ${f.mNAf} ${f.yyyy}';
  }

  void _syncText() {
    final useJalali =
        widget.useJalaliCalendar ||
        !appLocaleHelper.isCurrentLanguageEnglish(context);

    final displayText = widget.date == null
        ? ''
        : !useJalali
        ? DateFormat('d MMM yyyy').format(widget.date!)
        : _formatDariDate(Jalali.fromDateTime(widget.date!));

    if (_controller.text == displayText) return;
    _controller.value = TextEditingValue(
      text: displayText,
      selection: TextSelection.collapsed(offset: displayText.length),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final useJalali =
        widget.useJalaliCalendar ||
        !appLocaleHelper.isCurrentLanguageEnglish(context);

    if (!useJalali) {
      final selectedDate = widget.date ?? widget.initialDate ?? DateTime.now();
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now().subtract(const Duration(days: 360 * 90)),
        lastDate: DateTime(2050, 12, 31),
      );

      if (pickedDate != null) {
        widget.onPickedDate(pickedDate);
      }
      return;
    }

    final selectedDate = widget.date ?? widget.initialDate ?? DateTime.now();
    final initialJalali = Jalali.fromDateTime(selectedDate);

    final pickedJalali = await showPersianDatePicker(
      context: context,
      initialDate: initialJalali,
      firstDate: Jalali.fromDateTime(
        DateTime.now().subtract(const Duration(days: 360 * 90)),
      ),
      lastDate: Jalali(1450, 12, 29),
      initialEntryMode: PersianDatePickerEntryMode.calendar,
      initialDatePickerMode: PersianDatePickerMode.day,
    );

    if (pickedJalali != null) {
      widget.onPickedDate(pickedJalali.toDateTime());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: _controller,
      readOnly: true,
      onTap: () => _openPicker(context),
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.date != null && widget.isOptional)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => widget.onPickedDate(null),
            ),
          const Icon(Icons.calendar_today),
        ],
      ),
      label: widget.label ?? LocaleKeys.select_date.tr(),
    );
  }
}
