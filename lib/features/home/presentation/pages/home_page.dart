import 'package:flutter/material.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/features/breathing/presentation/pages/breathing_page.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/pages/controllers/home_pet_care_mixin.dart';
import 'package:lumo/features/home/presentation/pages/controllers/home_pet_state_mixin.dart';
import 'package:lumo/features/home/presentation/pages/widgets/home_background.dart';
import 'package:lumo/features/home/presentation/pages/widgets/home_care_buttons.dart';
import 'package:lumo/features/home/presentation/pages/widgets/home_care_panel.dart';
import 'package:lumo/features/home/presentation/pages/widgets/home_pet_stage_view.dart';
import 'package:lumo/features/home/presentation/pages/widgets/home_side_actions.dart';
import 'package:lumo/features/home/presentation/pages/widgets/home_top_bar.dart';
import 'package:lumo/features/home/presentation/widgets/daily_tasks_panel.dart';
import 'package:lumo/features/notifications/presentation/pages/notifications_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with
        WidgetsBindingObserver,
        HomePetStateMixin<HomePage>,
        HomePetCareMixin<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPetState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    onPetDependenciesChanged();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    handlePetAppLifecycle(state);
  }

  @override
  void dispose() {
    disposePetState();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ── Sağ üst buton rotaları ───────────────────────────────────────
  void _openBreathing() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BreathingPage()),
    );
    refreshWallet();
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
  }

  /// Günlük görev önizlemesi — [DailyTasksPanel] alt sayfa olarak açılır.
  /// Home ağacında gömülü değildir; istenince bu kısayoldan ulaşılır.
  void _openDailyQuests() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: DailyTasksPanel(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    // Alt nav (66px + güvenli alan + nav alt payı) üstünde 15px boşluk:
    // bakım butonları + Lumi Care şeridi navbara binmesin.
    final navBottomPad = (bottomInset > 0 ? bottomInset : 10.0) + 6.0;
    final bottomReserve = navBottomPad + 15.0;

    final environmentBackground =
        isNightMode ? AssetPaths.nightMeadow : AssetPaths.dayMeadow;

    return TickerMode(
      enabled: isAppResumed,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            HomeBackground(
              imagePath: environmentBackground,
              isNight: isNightMode,
            ),
            Positioned.fill(
              child: HomePetStageView(
                useRive: HomePetStateMixin.useRive,
                species: species,
                actionState: petAction,
                equippedItems: equippedItems,
                isNight: isNightMode,
                speechText: statusBubbleText,
                speechVisible: bubbleVisible,
                onPetTapped: () => performPetAction(PetActionState.petted),
                onGroundTapped: handleGroundTapped,
              ),
            ),

            // ── 4. Top Bar (greeting + coins + profile) ───────────────
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: HomeTopBar(
                topPadding: topPadding,
                userName: userName,
                level: level,
                xp: xp,
                xpMax: HomePetStateMixin.xpMax,
                coins: coins,
              ),
            ),

            // ── 5. Yan kısayollar ─────────────────────────────────────
            Positioned(
              right: 14,
              top: topPadding + 84,
              child: HomeSideActions(
                onNotifications: _openNotifications,
                onCalm: _openBreathing,
                onQuests: _openDailyQuests,
              ),
            ),

            // ── 6. Alt alan: sabit 4 bakım butonu + ince bakım şeridi ──
            Positioned(
              left: 12,
              right: 12,
              bottom: bottomReserve,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HomeCareButtons(
                    hunger: hunger,
                    hydration: hydration,
                    happiness: happiness,
                    energy: energy,
                    isSleeping: petAction == PetActionState.sleep,
                    onFeed: () => performPetAction(PetActionState.eat),
                    onDrink: () => performPetAction(PetActionState.drink),
                    onPlay: () => performPetAction(PetActionState.playBall),
                    onSleepToggle: () => performPetAction(
                      petAction == PetActionState.sleep
                          ? PetActionState.idle
                          : PetActionState.sleep,
                    ),
                  ),
                  const SizedBox(height: 6),
                  HomeCarePanel(
                    hunger: hunger,
                    hydration: hydration,
                    happiness: happiness,
                    energy: energy,
                    expanded: isPetCarePanelExpanded,
                    onToggle: () => setState(() =>
                        isPetCarePanelExpanded = !isPetCarePanelExpanded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
