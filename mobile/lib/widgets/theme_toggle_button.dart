import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeToggleButton extends StatefulWidget {
  const ThemeToggleButton({super.key});

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    if (isDark) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return GestureDetector(
      onTap: () {
        themeProvider.toggleTheme();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        width: 70,
        height: 35,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF334155)  // Solid slate for dark mode
              : const Color(0xFFFBBF24),  // Solid amber for light mode
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Stars (visible in dark mode)
            if (isDark) ...[
              Positioned(
                top: 8,
                left: 12,
                child: Icon(
                  Icons.star,
                  size: 6,
                  color: Colors.white.withValues(alpha:0.8),
                ),
              ),
              Positioned(
                top: 15,
                left: 20,
                child: Icon(
                  Icons.star,
                  size: 4,
                  color: Colors.white.withValues(alpha:0.6),
                ),
              ),
            ],
            
            // Sliding circle (sun/moon)
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isDark ? Icons.nights_stay : Icons.wb_sunny,
                    key: ValueKey(isDark),
                    color: isDark
                        ? const Color(0xFF60A5FA)
                        : const Color(0xFFFBBF24),
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}