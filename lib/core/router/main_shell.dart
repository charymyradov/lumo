import 'package:flutter/material.dart';
import 'package:lumo/features/home/presentation/pages/home_page.dart';
import 'package:lumo/features/journal/presentation/pages/journal_page.dart';
import 'package:lumo/features/profile/presentation/pages/profile_page.dart';
import 'package:lumo/features/shop/presentation/pages/shop_page.dart';
import 'package:lumo/features/tasks/presentation/pages/tasks_page.dart';
import 'package:lumo/shared/widgets/lumo_bottom_nav.dart';

/// Root shell that hosts the 5 main tabs behind the glass bottom nav.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0; // Open on Home (Yaşam)

  void _onTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomePage(),
          TasksPage(),
          JournalPage(),
          ShopPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: LumoBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
