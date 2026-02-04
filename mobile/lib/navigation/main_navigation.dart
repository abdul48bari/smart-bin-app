import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/bins_page.dart';
import '../pages/analytics_page.dart';
import '../pages/account_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // NO KEYS! Build fresh each time
  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const HomePage();  // ← No key!
      case 1:
        return const BinsPage();  // ← No key!
      case 2:
        return const AnalyticsPage();  // ← No key!
      case 3:
        return const AccountPage();  // ← No key!
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentPage(),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (index) {
            final icons = [
              Icons.dashboard_rounded,
              Icons.delete_outline_rounded,
              Icons.bar_chart_rounded,
              Icons.person_outline_rounded,
            ];

            final isActive = _currentIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() => _currentIndex = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFE6F4F1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icons[index],
                  size: 24,
                  color: isActive
                      ? const Color(0xFF0F766E)
                      : Colors.black54,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}