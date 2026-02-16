import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sodais_finance/core/widgets/icons/custom_svg_icon.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.prefixIconSource,
    this.prefixIconData,
    this.prefixIcon,
    this.suffixIcon,
    this.label,
    this.hintText,
    this.onSubmitted,
    this.onChange,
    this.onTap,
    this.controller,
    this.validator,
    this.focusNode,
    this.inputFormatters,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.readOnly = false,
  });

  final String? prefixIconSource;
  final IconData? prefixIconData;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? label;
  final String? hintText;
  final Function(String)? onSubmitted;
  final Function(String)? onChange;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final bool readOnly;

  Widget? _buildPrefixIcon() {
    if (prefixIcon != null) return prefixIcon;
    if (prefixIconData != null) return Icon(prefixIconData);
    if (prefixIconSource != null) {
      return CustomSvgIcon(
        iconSource: prefixIconSource!,
        padding: sizeConstants.spacingSmall,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      enabled: enabled,
      readOnly: readOnly,
      onFieldSubmitted: onSubmitted,
      onChanged: onChange,
      onTap: onTap,
      decoration: InputDecoration(
        prefixIcon: _buildPrefixIcon(),
        suffixIcon: suffixIcon,
        labelText: label,
        hintText: hintText,
      ),
    );
  }
}
