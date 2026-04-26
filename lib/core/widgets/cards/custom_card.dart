import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    this.margin,
    this.padding,
    required this.child,
    this.elevation = 0,
    this.onTap,
  });

  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Widget child;
  final double elevation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
        side: BorderSide(color: Theme.of(context).dividerColor, width: 1),
      ),
      margin: margin,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ?? EdgeInsets.all(sizeConstants.spacingMedium),
          child: child,
        ),
      ),
    );
  }
}
