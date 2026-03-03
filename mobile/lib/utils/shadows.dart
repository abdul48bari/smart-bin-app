import 'package:flutter/material.dart';

/// Apple-inspired shadow elevation system for clean, minimal design
///
/// Provides three elevation levels (small, medium, large) with theme-aware shadows.
/// Key principles:
/// - Single layer shadows only (no double shadows)
/// - NO spreadRadius (no glow effects)
/// - Dark mode uses deeper blacks, not glows
/// - Subtle and purposeful
class AppShadows {
  // Light mode shadows - subtle and purposeful

  /// Small elevation - Used for subtle lift (buttons, chips)
  /// BlurRadius: 4px, Offset: (0,1), Opacity: 0.04
  static List<BoxShadow> small(BuildContext context) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// Medium elevation - Used for cards and containers
  /// BlurRadius: 8px, Offset: (0,2), Opacity: 0.06
  static List<BoxShadow> medium(BuildContext context) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Large elevation - Used for modals and floating elements
  /// BlurRadius: 12px, Offset: (0,4), Opacity: 0.08
  static List<BoxShadow> large(BuildContext context) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // Dark mode shadows - deeper blacks, no glow

  /// Small elevation for dark mode
  /// BlurRadius: 3px, Offset: (0,1), Opacity: 0.2
  static List<BoxShadow> smallDark(BuildContext context) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 3,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// Medium elevation for dark mode
  /// BlurRadius: 6px, Offset: (0,2), Opacity: 0.3
  static List<BoxShadow> mediumDark(BuildContext context) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Large elevation for dark mode
  /// BlurRadius: 10px, Offset: (0,3), Opacity: 0.4
  static List<BoxShadow> largeDark(BuildContext context) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.4),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ];
  }

  /// Helper method to get theme-aware shadows
  ///
  /// Usage:
  /// ```dart
  /// boxShadow: AppShadows.elevation(context, 'medium')
  /// ```
  ///
  /// Parameters:
  /// - context: BuildContext to determine theme
  /// - size: 'small', 'medium', or 'large'
  ///
  /// Returns appropriate shadow for current theme
  static List<BoxShadow> elevation(BuildContext context, String size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (size) {
      case 'small':
        return isDark ? smallDark(context) : small(context);
      case 'medium':
        return isDark ? mediumDark(context) : medium(context);
      case 'large':
        return isDark ? largeDark(context) : large(context);
      default:
        return [];
    }
  }

  /// Returns empty list for elements that don't need shadows
  static List<BoxShadow> none() {
    return [];
  }
}
