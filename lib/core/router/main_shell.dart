import 'package:flutter/material.dart';
import 'package:lumo/features/home/presentation/pages/home_page.dart';
import 'package:lumo/features/journal/presentation/pages/journal_page.dart';
import 'package:lumo/features/profile/presentation/pages/profile_page.dart';
import 'package:lumo/features/shop/presentation/pages/shop_page.dart';
import 'package:lumo/features/tasks/presentation/pages/tasks_page.dart';
import 'package:lumo/shared/widgets/lumo_bottom_nav.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0; // Open on Home (Yaşam)

  static const _pages = [
    HomePage(),
    TasksPage(),
    JournalPage(),
    ShopPage(),
    ProfilePage(),
  ];

  void _onTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final appTickerEnabled = TickerMode.valuesOf(context).enabled;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          for (var i = 0; i < _pages.length; i++)
            RepaintBoundary(
              child: TickerMode(
                enabled: appTickerEnabled && i == _currentIndex,
                child: _pages[i],
              ),
            ),
        ],
      ),
      bottomNavigationBar: LumoBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
