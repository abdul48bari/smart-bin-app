import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget? child;
  final double blur;
  final double opacity;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final double width;
  final double height;
  final BoxShape shape;

  const GlassContainer({
    super.key,
    this.child,
    this.blur = 10,
    this.opacity = 0.1,
    this.color,
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.width = double.infinity,
    this.height = double.infinity,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        boxShadow: boxShadow,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : (borderRadius ?? BorderRadius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: shape == BoxShape.circle
            ? BorderRadius.circular(1000)
            : (borderRadius ?? BorderRadius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            width: width == double.infinity ? null : width,
            height: height == double.infinity ? null : height,
            padding: padding,
            decoration: BoxDecoration(
              color: (color ?? (isDark ? Colors.black : Colors.white))
                  .withOpacity(opacity),
              shape: shape,
              borderRadius: shape == BoxShape.circle
                  ? null
                  : (borderRadius ?? BorderRadius.circular(20)),
              border:
                  border ??
                  Border.all(
                    color: (isDark ? Colors.white : Colors.white).withOpacity(
                      isDark ? 0.05 : 0.2,
                    ),
                    width: 1.5,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
