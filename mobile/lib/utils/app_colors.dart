import 'package:flutter/material.dart';

// Simple helper to get theme-aware colors
class AppColors {
  static Color accent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF14B8A6) : const Color(0xFF0F766E);
  }

  static Color accentSoft(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1E3A38) : const Color(0xFFE6F4F1);
  }

  static Color background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFAFAFA);
  }

  static Color surface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1A1A) : Colors.white;
  }

  static Color textPrimary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : Colors.black;
  }

  static Color textSecondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white70 : Colors.black54;
  }

  // New solid surface colors for clean design

  /// Elevated surface color (slightly lighter/darker than base surface)
  static Color surfaceElevated(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF222222) : Colors.white;
  }

  /// Secondary surface color (subtle background variation)
  static Color surfaceSecondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF161616) : const Color(0xFFF5F5F5);
  }

  /// Border color (subtle dividers)
  static Color border(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
  }

  // Sub-bin solid colors (consistent across themes)

  /// Map of waste type to color
  static const Map<String, Color> subBinColors = {
    'plastic': Color(0xFFE8703A), // Orange
    'paper': Color(0xFF4E80EE),   // Blue
    'organic': Color(0xFFD4A017), // Yellow
    'cans': Color(0xFF6B7280),    // Gray
    'mixed': Color(0xFF8B5CF6),   // Purple
  };

  /// Get sub-bin color by type (fallback to accent)
  static Color subBinColor(String type, BuildContext context) {
    return subBinColors[type.toLowerCase()] ?? accent(context);
  }

  /// Get sub-bin background color (12% opacity)
  static Color subBinBackground(String type, BuildContext context) {
    final color = subBinColors[type.toLowerCase()] ?? accent(context);
    return color.withValues(alpha: 0.12);
  }

  // Legacy glass colors (deprecated, will be removed)
  @Deprecated('Use surfaceElevated() instead')
  static Color glassLight = Colors.white;

  @Deprecated('Use surfaceElevated() instead')
  static Color glassDark = Colors.black;
}
