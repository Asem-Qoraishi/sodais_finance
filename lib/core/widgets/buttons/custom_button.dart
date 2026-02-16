import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/colors.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isPrimary = false,
    this.padding,
  });

  final VoidCallback onPressed;
  final Widget child;
  final bool isPrimary;
  final EdgeInsetsGeometry? padding;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isHover = false;
  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? textPrimaryColorDark
        : textPrimaryColor;
    return OutlinedButton(
      onPressed: widget.onPressed,
      onHover: (value) => setState(() {
        isHover = value;
      }),
      style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
        textStyle: widget.isPrimary && !isHover
            ? WidgetStatePropertyAll(
                TextStyle(fontSize: 16, color: Colors.white),
              )
            : Theme.of(context).outlinedButtonTheme.style!.textStyle,
        backgroundColor: widget.isPrimary && !isHover
            ? WidgetStatePropertyAll(textColor)
            : null,
        foregroundColor: widget.isPrimary && !isHover
            ? WidgetStatePropertyAll(Colors.white)
            : null,
        padding: WidgetStatePropertyAll(
          widget.padding ??
              EdgeInsets.symmetric(
                horizontal: sizeConstants.spacingSmall,
                vertical: sizeConstants.spacingMedium + 2,
              ),
        ),
      ),

      child: widget.child,
    );
  }
}
