import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:code_g/app/core/values/app_colors.dart';

class CustomCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BoxBorder border;
  final BorderRadius borderRadius;
  final bool isDashedBorder;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;
  const CustomCard({
    Key? key,
    this.width,
    this.height,
    required this.children,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(8.0),
    this.color = Colors.white,
    this.border = const Border.fromBorderSide(BorderSide(
      color: Colors.grey, // Default border color
      width: 1.0, // Default border width
      style: BorderStyle.solid,
    )),
    this.borderRadius =
        const BorderRadius.all(Radius.circular(12)), // Default border radius
    this.isDashedBorder = false,
    this.boxShadow = const [
      BoxShadow(
        color: AppColors.shadowBlack20, // Shadow color with opacity (#00000033)
        blurRadius: 8.0, // Spread of the shadow
        offset: Offset(0, 0), // Offset in x and y directions
      ),
    ],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Padding(
      padding: padding!,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );

    return Container(
      height: height,
      width: width,
      margin: margin,
      child: isDashedBorder
          ? DottedBorder(
              color: border.top.color,
              borderType: BorderType.RRect,
              radius: Radius.circular(borderRadius.topLeft.x),
              dashPattern: [6, 3],
              child: ClipRRect(
                borderRadius: borderRadius,
                child: Container(
                  color: color,
                  child: cardContent,
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: color,
                border: border,
                borderRadius: borderRadius,
                boxShadow: boxShadow, // Apply the box shadow
              ),
              child: cardContent,
            ),
    );
  }
}