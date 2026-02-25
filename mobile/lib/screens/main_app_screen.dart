import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../pages/home_page.dart';
import '../pages/bins_page.dart';
import '../pages/analytics_page.dart';
import '../pages/account_page.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/voice_assistant_modal.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;

  // KEEP fresh build method (important for fade animations)
  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return const HomePage();
      case 1:
        return const BinsPage();
      case 2:
        return const AnalyticsPage();
      case 3:
        return const AccountPage();
      default:
        return const HomePage();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // Allows body to go behind the bottom bar
      body: _getCurrentPage(),
      floatingActionButton: _buildVoiceAssistantButton(accent, isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: GlassContainer(
          height: 70,
          blur: 20,
          opacity: isDark ? 0.6 : 0.8,
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home', accent, isDark),
              _buildNavItem(1, Icons.delete_rounded, 'Bins', accent, isDark),
              _buildNavItem(
                2,
                Icons.bar_chart_rounded,
                'Analytics',
                accent,
                isDark,
              ),
              _buildNavItem(3, Icons.person_rounded, 'Account', accent, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    Color accent,
    bool isDark,
  ) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? accent
                  : (isDark ? Colors.white54 : Colors.black45),
              size: 24,
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? accent
                    : (isDark ? Colors.white54 : Colors.black45),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceAssistantButton(Color accent, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80), // Position above nav bar
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [accent, accent.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(isDark ? 0.5 : 0.3),
              blurRadius: isDark ? 24 : 20,
              spreadRadius: isDark ? 2 : 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(32),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const VoiceAssistantModal(),
              );
            },
            child: const Icon(
              Icons.mic_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
