import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';

class CustomSvgPicture extends StatelessWidget {
  const CustomSvgPicture({
    super.key,
    this.backgroundColor,
    required this.iconSource,
    this.iconColor,
    this.isColorful = false,
    this.iconSize,
    this.padding,
  });

  final Color? backgroundColor;
  final Color? iconColor;
  final double? iconSize;
  final String iconSource;
  final bool isColorful;
  final double? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(sizeConstants.radiusMax),
        color: backgroundColor,
      ),
      padding: padding != null ? EdgeInsets.all(padding!) : null,
      child: !isColorful
          ? ColorFiltered(
              colorFilter: ColorFilter.mode(
                iconColor ?? Theme.of(context).iconTheme.color!,
                BlendMode.srcATop,
              ),
              child: _buildSvgPicture(),
            )
          : _buildSvgPicture(),
    );
  }

  SvgPicture _buildSvgPicture() {
    return SvgPicture.asset(
      iconSource,
      height: iconSize ?? sizeConstants.iconMedium,
      width: iconSize ?? sizeConstants.iconMedium,
    );
  }
}
