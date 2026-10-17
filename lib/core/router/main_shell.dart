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
  late final ValueNotifier<int> _index = ValueNotifier<int>(0);

  // Open on Home (Yaşam). Const sayfalar lazy tutulur.
  late final List<Widget> _pages = const [
    HomePage(),
    TasksPage(),
    JournalPage(),
    ShopPage(),
    ProfilePage(),
  ];

  @override
  void dispose() {
    _index.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (index == _index.value) return;
    _index.value = index;
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold bir kez kurulur; sekme değişiminde yalnızca
    // aşağıdaki iki ValueListenableBuilder rebuild olur.
    return Scaffold(
      extendBody: true,
      body: ValueListenableBuilder<int>(
        valueListenable: _index,
        builder: (context, index, _) {
          final appTickerEnabled = TickerMode.valuesOf(context).enabled;
          return IndexedStack(
            index: index,
            children: [
              for (var i = 0; i < _pages.length; i++)
                RepaintBoundary(
                  child: Offstage(
                    offstage: i != index,
                    child: TickerMode(
                      enabled: appTickerEnabled && i == index,
                      child: _pages[i],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _index,
        builder: (context, index, _) => LumoBottomNav(
          currentIndex: index,
          onTap: _onTap,
        ),
      ),
    );
  }
}
