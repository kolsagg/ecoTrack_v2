import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import '../../core/constants/app_constants.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/expense/expenses_list_screen.dart';
import '../../screens/receipt/qr_scanner_screen.dart';
import '../../screens/reports/reports_screen.dart';
import '../../screens/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<IconData> _iconList = [
    Icons.home_outlined,
    Icons.receipt_long_outlined,
    Icons.analytics_outlined,
    Icons.person_outline,
  ];

  final List<IconData> _activeIconList = [
    Icons.home,
    Icons.receipt_long,
    Icons.analytics,
    Icons.person,
  ];

  final List<String> _labelList = ['Home', 'Expenses', 'Reports', 'Profile'];

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExpensesListScreen(),
    const ReportsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const QrScannerScreen()),
          );
        },
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner, size: 26),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? AppConstants.primaryColor : Colors.grey[600];

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? _activeIconList[index] : _iconList[index],
                size: 18,
                color: color,
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  _labelList[index],
                  maxLines: 1,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          );
        },
        backgroundColor: Colors.white,
        activeIndex: _currentIndex,
        splashColor: AppConstants.primaryColor.withValues(alpha: 0.1),
        notchSmoothness: NotchSmoothness.softEdge,
        notchMargin: 8,
        gapLocation: GapLocation.center,
        leftCornerRadius: 20,
        rightCornerRadius: 20,
        onTap: (index) => setState(() => _currentIndex = index),
        height: 45,
        elevation: 8,
        shadow: BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ),
    );
  }
}
