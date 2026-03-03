import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/shadows.dart';

/// Clean, solid container widget for Apple-level design
///
/// Replaces GlassContainer with a minimal, professional design:
/// - Solid background colors (no opacity + blur)
/// - Consistent shadow elevation system
/// - No BackdropFilter or blur effects
/// - Simple, purposeful styling
///
/// Usage:
/// ```dart
/// CleanContainer(
///   elevation: 'medium',
///   padding: EdgeInsets.all(16),
///   child: Text('Content'),
/// )
/// ```
class CleanContainer extends StatelessWidget {
  /// Child widget to display inside the container
  final Widget? child;

  /// Internal padding
  final EdgeInsetsGeometry? padding;

  /// External margin
  final EdgeInsetsGeometry? margin;

  /// Border radius (default: 16px for clean, modern look)
  final BorderRadius? borderRadius;

  /// Background color (default: theme surface color)
  final Color? backgroundColor;

  /// Shadow elevation: 'small', 'medium', 'large', or 'none'
  /// - small: Subtle lift for buttons, chips
  /// - medium: Cards and containers (default)
  /// - large: Modals and floating elements
  /// - none: No shadow
  final String elevation;

  /// Optional border for subtle dividers
  final Border? border;

  /// Container width
  final double? width;

  /// Container height
  final double? height;

  const CleanContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.elevation = 'medium',
    this.border,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface(context),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: border,
        boxShadow: elevation == 'none'
          ? AppShadows.none()
          : AppShadows.elevation(context, elevation),
      ),
      child: child,
    );
  }
}
