import 'package:flutter/material.dart';
import 'package:sodais_finance/core/widgets/cards/custom_card.dart';

class CustomSliverCard extends StatelessWidget {
  const CustomSliverCard({
    super.key,
    this.margin,
    this.padding,
    required this.child,
    this.elevation = 0,
  });

  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Widget child;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: CustomCard(
        elevation: elevation,
        margin: margin,
        padding: padding,
        child: child,
      ),
    );
  }
}
