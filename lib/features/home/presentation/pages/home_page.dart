import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/core/di/injection.dart';
import 'package:lumo/core/repositories/progress_repositories.dart';
import 'package:lumo/core/repositories/user_profile_repository.dart';
import 'package:lumo/core/repositories/wallet_repository.dart';
import 'package:lumo/core/repositories/wallet_repository_impl.dart';
import 'package:lumo/core/services/audio_service.dart';
import 'package:lumo/core/services/haptic_service.dart';
import 'package:lumo/core/services/progress_store.dart';
import 'package:lumo/core/services/user_profile_store.dart';
import 'package:lumo/core/services/wallet_store.dart';
import 'package:lumo/features/breathing/presentation/pages/breathing_page.dart';
import 'package:lumo/features/home/domain/entities/cosmetic_item.dart';
import 'package:lumo/features/home/domain/entities/mascot_species.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/bloc/home_state.dart'
    show resolvePetMood, PetMood;
import 'package:lumo/features/home/presentation/pet/lumo_interactive_pet_stage.dart';
import 'package:lumo/features/home/presentation/pet/rive_pet_stage.dart';
import 'package:lumo/features/home/presentation/widgets/daily_tasks_panel.dart';
import 'package:lumo/features/home/presentation/widgets/falling_leaves.dart';
import 'package:lumo/features/notifications/presentation/pages/notifications_page.dart';
import 'package:lumo/shared/widgets/coin_badge.dart';
import 'package:lumo/shared/widgets/glass_card.dart';
import 'package:lumo/shared/widgets/animated_background.dart';

enum _PetLifecycleState {
  idle,
  wandering,
  reacting,
  resting,
  seekingCare,
}

enum _PetMood {
  joyful,
  playful,
  sleepy,
  hungry,
  thirsty,
  tired,
  calm,
  needy,
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  /// Onboarding'de seçilen maskot (local storage'dan yüklenir).
  MascotSpecies _species = MascotSpecies.fox;

  /// Onboarding'de girilen isim — selamlamada kullanılır.
  String _userName = '';

  /// Rive sahnesi önceliklidir; `lumo.riv` henüz pakette yoksa
  /// [RivePetStage] otomatik olarak vektör sahneye düşer.
  static const bool _useRive = true;

  /// Wardrobe / furniture rendered on the stage (cloud bed, lantern, crown…).
  final List<CosmeticItem> _equippedItems = defaultCosmeticItems;

  // ── Pet state ──────────────────────────────────────────────────────
  Timer? _idleWanderTimer;
  Timer? _petActionTimer;
  Timer? _vitalPulseTimer;
  PetActionState _petAction = PetActionState.idle;
  _PetLifecycleState _petLifecycle = _PetLifecycleState.idle;
  _PetMood _petMood = _PetMood.calm;

  // ── Pet Vitals ─────────────────────────────────────────────────────
  double _hunger = 0.84;
  double _hydration = 0.78;
  double _happiness = 0.92;
  double _energy = 0.88;

  bool _isPetCarePanelExpanded = false;
  String _statusBubbleText = "I love spending time with you! 💜";

  /// Kafa üstü balon yalnızca [_statusBubbleText] değiştiğinde belirir ve
  /// birkaç saniye sonra kendiliğinden gizlenir (bkz. [_say]).
  bool _bubbleVisible = false;
  Timer? _bubbleTimer;

  bool _isNightMode = false;

  // ── Cüzdan (coin/XP/level) — repository üzerinden, static Store yok ──
  int _coins = WalletRepositoryImpl.defaultCoins;
  int _level = WalletRepositoryImpl.defaultLevel;
  int _xp = WalletRepositoryImpl.defaultXp;
  static const int _xpMax = WalletRepositoryImpl.xpPerLevel;
  bool _isAppResumed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfile();
    _updateEnvironmentMode();
    _startVitalPulse();
    _scheduleIdleWander();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isResumed = state == AppLifecycleState.resumed;
    if (_isAppResumed == isResumed) return;

    setState(() {
      _isAppResumed = isResumed;
    });
  }

  /// Kayıtlı profil (isim + maskot) — yoksa varsayılanlarla devam edilir.
  ///
  /// GetIt kayıtlıysa repository'ler, değilse (test/önizleme) static
  /// Store'lar kullanılır — iki yol da aynı anahtarlara yazar.
  Future<UserProfile> _loadUserProfile() =>
      sl.isRegistered<UserProfileRepository>()
          ? sl<UserProfileRepository>().load()
          : UserProfileStore.load();

  Future<({double hunger, double water, double happy, double energy})>
      _loadVitals() async {
    if (sl.isRegistered<PetVitalsRepository>()) {
      return sl<PetVitalsRepository>().load();
    }
    final v = await PetVitalsStore.load();
    return (hunger: v.$1, water: v.$2, happy: v.$3, energy: v.$4);
  }

  Future<({int coins, int xp, int level, int streak})> _loadWallet() async {
    if (sl.isRegistered<WalletRepository>()) {
      return sl<WalletRepository>().load();
    }
    final w = await WalletStore.load();
    return (coins: w.$1, xp: w.$2, level: w.$3, streak: w.$4);
  }

  Future<void> _saveVitals() {
    if (sl.isRegistered<PetVitalsRepository>()) {
      return sl<PetVitalsRepository>()
          .save(_hunger, _hydration, _happiness, _energy);
    }
    return PetVitalsStore.save(_hunger, _hydration, _happiness, _energy);
  }

  Future<({int level, int xp})> _addWalletXp(int amount) async {
    if (sl.isRegistered<WalletRepository>()) {
      return sl<WalletRepository>().addXp(amount);
    }
    final r = await WalletStore.addXp(amount);
    return (level: r.$1, xp: r.$2);
  }

  Future<void> _loadProfile() async {
    final results = await Future.wait([
      _loadUserProfile(),
      _loadVitals(),
      _loadWallet(),
    ]);
    if (!mounted) return;
    final profile = results[0] as UserProfile;
    final vitals = results[1] as ({
      double hunger,
      double water,
      double happy,
      double energy
    });
    final wallet = results[2] as ({int coins, int xp, int level, int streak});
    setState(() {
      _userName = profile.name;
      _species = MascotSpecies.fromId(profile.speciesId);
      _hunger = vitals.hunger;
      _hydration = vitals.water;
      _happiness = vitals.happy;
      _energy = vitals.energy;
      _coins = wallet.coins;
      _xp = wallet.xp;
      _level = wallet.level;
    });
    _updatePetMood();
  }

  Future<void> _persistVitals() => _saveVitals();

  Future<void> _refreshWallet() async {
    final wallet = await _loadWallet();
    if (!mounted) return;
    setState(() {
      _coins = wallet.coins;
      _xp = wallet.xp;
      _level = wallet.level;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _idleWanderTimer?.cancel();
    _petActionTimer?.cancel();
    _vitalPulseTimer?.cancel();
    _bubbleTimer?.cancel();
    super.dispose();
  }

  /// Yeni durum metnini balona yazar ve balonu ~3.5 sn boyunca görünür tutar.
  /// Balonun ömrü sahnedeki simülasyonda değil, burada sahiplenilir.
  void _say(String text) {
    _bubbleTimer?.cancel();
    setState(() {
      _statusBubbleText = text;
      _bubbleVisible = true;
    });
    _bubbleTimer = Timer(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      setState(() => _bubbleVisible = false);
    });
  }

  void _updatePetMood() {
    // Saf fonksiyon HomeBloc'ta — test edilebilir, Widget sadece map'ler.
    final mood = resolvePetMood(
      hunger: _hunger,
      hydration: _hydration,
      happiness: _happiness,
      energy: _energy,
    );
    _petMood = switch (mood) {
      PetMood.joyful => _PetMood.joyful,
      PetMood.playful => _PetMood.playful,
      PetMood.sleepy => _PetMood.sleepy,
      PetMood.hungry => _PetMood.hungry,
      PetMood.thirsty => _PetMood.thirsty,
      PetMood.tired => _PetMood.tired,
      PetMood.calm => _PetMood.calm,
      PetMood.needy => _PetMood.needy,
    };
  }

  void _startVitalPulse() {
    _vitalPulseTimer?.cancel();
    _vitalPulseTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;

      final isSleeping = _petLifecycle == _PetLifecycleState.resting &&
          _petAction == PetActionState.sleep;

      setState(() {
        if (isSleeping) {
          // Uyurken enerji dolar, diğer ihtiyaçlar daha yavaş değişir.
          _energy = (_energy + 0.15).clamp(0.0, 1.0);
          _hunger = (_hunger + 0.02).clamp(0.0, 1.0);
          _hydration = (_hydration - 0.015).clamp(0.0, 1.0);
          _happiness = (_happiness - 0.01).clamp(0.0, 1.0);
        } else {
          _hunger = (_hunger + 0.04).clamp(0.0, 1.0);
          _hydration = (_hydration - 0.03).clamp(0.0, 1.0);
          _energy = (_energy - 0.015).clamp(0.0, 1.0);
          _happiness = (_happiness - 0.02).clamp(0.0, 1.0);
        }
      });
      _persistVitals();

      _updatePetMood();

      if (isSleeping) {
        // Enerji dolunca otomatik uyan — sonsuz uykuyu engeller.
        if (_energy >= 0.75) {
          setState(() {
            _petAction = PetActionState.idle;
            _petLifecycle = _PetLifecycleState.idle;
          });
          _say("Oh, I feel rested! I'm ready to play! ✨");
        }
        return;
      }

      final priorityAction = _resolvePriorityAction();
      if (priorityAction != PetActionState.idle &&
          _petAction != priorityAction &&
          _petLifecycle != _PetLifecycleState.reacting) {
        _executeAutoCare(priorityAction);
      }
    });
  }

  void _applyPetActionTimer({Duration? duration}) {
    _petActionTimer?.cancel();
    final actionDuration = duration ?? const Duration(milliseconds: 1800);
    _petActionTimer = Timer(actionDuration, () {
      if (!mounted) return;
      final isTransientAction = [
        PetActionState.eat,
        PetActionState.drink,
        PetActionState.petted,
        PetActionState.playBall,
        PetActionState.run,
        PetActionState.groom,
        PetActionState.jump,
        PetActionState.walk,
        PetActionState.dance,
      ].contains(_petAction);

      if (!isTransientAction) return;

      final priorityAction = _resolvePriorityAction();
      if (priorityAction != PetActionState.idle) {
        _executeAutoCare(priorityAction);
        return;
      }

      setState(() {
        _petAction = PetActionState.idle;
        _petLifecycle = _PetLifecycleState.idle;
      });
      _say("I love spending time with you! 💜");
    });
  }

  /// Acil ve **deterministik** ihtiyaç — build sırasında güvenle çağrılır.
  /// [_resolvePriorityAction] bu sonucu rastgele "oyna" önerisiyle tamamlar;
  /// buton nabzı yalnızca bu metodu kullanır ki ekran her yeniden
  /// çizildiğinde kırmızı nokta zıplamasın.
  PetActionState? _urgentCareAction() {
    if (_energy < 0.10 || _petMood == _PetMood.sleepy) {
      return PetActionState.sleep;
    }
    if (_hydration < 0.28 || _petMood == _PetMood.thirsty) {
      return PetActionState.drink;
    }
    if (_happiness < 0.22 || _petMood == _PetMood.needy) {
      return PetActionState.groom;
    }
    if (_energy < 0.38 || _petMood == _PetMood.tired) {
      return PetActionState.walk;
    }
    return null;
  }

  PetActionState _resolvePriorityAction() {
    return _urgentCareAction() ?? PetActionState.idle;
  }

  void _executeAutoCare(PetActionState action) {
    final bubble = switch (action) {
      PetActionState.sleep => "I need some rest... it's bedtime! 😴",
      PetActionState.eat => "I'm getting hungry, I need something to eat! 🍎",
      PetActionState.drink => "I'm thirsty, I need a drink! 💧",
      PetActionState.groom => "I need to groom myself. My fur is messy! ✨",
      PetActionState.playBall => "My energy is back, let's run and play! ⚽",
      PetActionState.walk => "A short walk would feel great! 🌿",
      _ => "I love spending time with you! 💜",
    };

    setState(() {
      _petAction = action;
      _petLifecycle = action == PetActionState.sleep
          ? _PetLifecycleState.resting
          : _PetLifecycleState.seekingCare;
    });
    // Balon metnini `_transitionPetAction` balonu sahiplenir (bkz. `_say`).

    _transitionPetAction(
      action,
      bubble: bubble,
      lifetime: action == PetActionState.sleep
          ? null
          : const Duration(milliseconds: 1800),
    );
  }

  void _updateEnvironmentMode() {
    final currentHour = DateTime.now().hour;
    _isNightMode = currentHour >= 19 || currentHour < 7;
  }

  /// Returns a "the pet needs care" action, or null when it is perfectly
  /// happy. Locomotion itself (walk/run/jump) is owned by the pet stage, so
  /// this only surfaces real needs.
  PetActionState? _pendingCareAction() {
    final priority = _resolvePriorityAction();
    if (priority != PetActionState.idle) return priority;
    if (_energy < 0.15) return PetActionState.sleep;
    if (_hydration < 0.35) return PetActionState.drink;
    if (_happiness < 0.35) return PetActionState.groom;
    return null;
  }

  void _transitionPetAction(
    PetActionState action, {
    String? bubble,
    Duration? lifetime,
  }) {
    setState(() {
      _petAction = action;
      _petLifecycle = switch (action) {
        PetActionState.sleep => _PetLifecycleState.resting,
        PetActionState.eat ||
        PetActionState.drink ||
        PetActionState.groom =>
          _PetLifecycleState.seekingCare,
        PetActionState.walk ||
        PetActionState.run ||
        PetActionState.playBall ||
        PetActionState.dance =>
          _PetLifecycleState.wandering,
        PetActionState.idle => _PetLifecycleState.idle,
        _ => _PetLifecycleState.reacting,
      };
    });
    if (bubble != null) {
      _say(bubble);
    }

    if (lifetime != null &&
        action != PetActionState.sleep &&
        action != PetActionState.idle) {
      _applyPetActionTimer(duration: lifetime);
    }
  }

  void _scheduleIdleWander() {
    _idleWanderTimer?.cancel();
    _idleWanderTimer = Timer(
      Duration(milliseconds: 2400 + Random().nextInt(2400)),
      () {
        if (!mounted || _petAction != PetActionState.idle) {
          _scheduleIdleWander();
          return;
        }

        final careAction = _pendingCareAction();
        if (careAction != null) {
          _executeAutoCare(careAction);
        }
        // Walking / running / jumping around is handled by the pet stage
        // itself, so there is no need to drive a position from up here.
        _scheduleIdleWander();
      },
    );
  }

  // ── Pet interactions ───────────────────────────────────────────────
  void _performPetAction(PetActionState petAction) {
    // His: her dokunuşta tepki (rehber §8).
    HapticService.petTap();
    switch (petAction) {
      case PetActionState.petted || PetActionState.groom:
        PetSoundService.playPurr();
      case PetActionState.playBall ||
            PetActionState.dance ||
            PetActionState.jump:
        PetSoundService.playGiggle();
      case PetActionState.sleep:
        PetSoundService.playSleep();
      case PetActionState.eat ||
            PetActionState.drink ||
            PetActionState.run ||
            PetActionState.walk ||
            PetActionState.idle:
        PetSoundService.playPop();
    }

    setState(() {
      switch (petAction) {
        case PetActionState.eat:
          _hunger = (_hunger - 0.18).clamp(0.0, 1.0);
          _happiness = (_happiness + 0.08).clamp(0.0, 1.0);
          break;
        case PetActionState.drink:
          _hydration = (_hydration + 0.22).clamp(0.0, 1.0);
          _energy = (_energy + 0.06).clamp(0.0, 1.0);
          break;
        case PetActionState.petted:
          _happiness = (_happiness + 0.16).clamp(0.0, 1.0);
          break;
        case PetActionState.playBall:
          _happiness = (_happiness + 0.20).clamp(0.0, 1.0);
          _energy = (_energy - 0.10).clamp(0.0, 1.0);
          _hunger = (_hunger - 0.05).clamp(0.0, 1.0);
          break;
        case PetActionState.run:
          _energy = (_energy - 0.15).clamp(0.0, 1.0);
          break;
        case PetActionState.groom:
          _happiness = (_happiness + 0.10).clamp(0.0, 1.0);
          break;
        case PetActionState.sleep:
          _energy = (_energy + 0.30).clamp(0.0, 1.0);
          break;
        case PetActionState.jump:
          _happiness = (_happiness + 0.18).clamp(0.0, 1.0);
          _energy = (_energy - 0.06).clamp(0.0, 1.0);
          _hunger = (_hunger - 0.05).clamp(0.0, 1.0);
          break;
        case PetActionState.walk:
          break;
        case PetActionState.dance:
          _happiness = (_happiness + 0.18).clamp(0.0, 1.0);
          break;
        case PetActionState.idle:
          break;
      }
    });
    // Vital değişti → ruh hali ve acil buton nabazı hemen tazelensin.
    _updatePetMood();
    _persistVitals();
    // Bakım mini-ödülü: her etkileşimde küçük XP, coin değil (ekonomi Tasks/Shop'ta).
    _addWalletXp(2).then((r) {
      if (!mounted) return;
      setState(() {
        _level = r.level;
        _xp = r.xp;
      });
    });

    final bubble = switch (petAction) {
      PetActionState.eat => "Delicious! I'm full, thank you! 🍎✨",
      PetActionState.drink => "Fresh spring water is so refreshing! 💧",
      PetActionState.petted => "Purrr... I love having my head petted! 💖",
      PetActionState.playBall =>
        "Caught it! Throw it again, running is so fun! ⚽🐾",
      PetActionState.run =>
        "I'm running like the wind! Look at my feet! 🏃‍♂️💨",
      PetActionState.groom => "My fur is soft and clean again! 🫧✨",
      PetActionState.sleep => "Zzz... sweet dreams... 🌙",
      PetActionState.jump => "Yay! I jumped up to the sky! ⭐",
      PetActionState.walk => "Walking in the meadow is wonderful! 🌸",
      PetActionState.dance => "Time for a happy dance! 🎉",
      PetActionState.idle => "I love spending time with you! 💜",
    };

    _transitionPetAction(
      petAction,
      bubble: bubble,
      lifetime:
          petAction == PetActionState.sleep || petAction == PetActionState.idle
              ? null
              : const Duration(milliseconds: 1800),
    );
  }

  // ── Sağ üst buton rotaları ───────────────────────────────────────
  void _openBreathing() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BreathingPage()),
    );
    _refreshWallet();
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

  /// Sahnedeki yürüme/koşma etkileşimi için kısa bilgi balonu gösterir.
  void _handleGroundTapped(PetActionState moveMode, String message) {
    assert(moveMode == PetActionState.walk || moveMode == PetActionState.run);
    _say(message);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    // Alt nav (66px + güvenli alan + nav alt payı) üstünde 15px boşluk:
    // bakım butonları + Lumi Care şeridi navbara binmesin.
    final navBottomPad = (bottomInset > 0 ? bottomInset : 10.0) + 6.0;
    final bottomReserve = navBottomPad + 15.0;

    final environmentBackground =
        _isNightMode ? AssetPaths.nightMeadow : AssetPaths.dayMeadow;

    return TickerMode(
      enabled: _isAppResumed,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Full-screen Background (net: blur kapalı) ──
          // Rehber §5 + §9: arka plan ayrıntılı boyama, karakter düz vektör.
          BlurredMeadowBackground(
            imagePath: environmentBackground,
            blurSigma: 0,
            paleOpacity: 0,
          ),

          // ── 1b. Vignette: kenarları koyulaştıran yumuşak gradyan ──
          // Parlak gökyüzünde kalan bütün yazılar (üst bar, yan kısayollar,
          // alt bakım şeridi) tek hamlede okunur hale gelir.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.18),
                  radius: 0.98,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.10),
                    Colors.black.withValues(alpha: 0.38),
                  ],
                  stops: const [0.0, 0.42, 0.72, 1.0],
                ),
              ),
            ),
          ),

          // ── 2. Sky ambience and environment props ────────────────
          ...[
            Positioned(
              left: 30,
              top: 110,
              child: Opacity(
                opacity: _isNightMode ? 0.18 : 0.30,
                child: Container(
                  width: 140,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 210,
              top: 140,
              child: Opacity(
                opacity: _isNightMode ? 0.12 : 0.24,
                child: Container(
                  width: 180,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
            // ── Süzülen yapraklar + ışık zerrecikleri ────────────────
            // Kendi CustomPaint katmanında akar; sayfayı rebuild etmez.
            Positioned.fill(
              child: IgnorePointer(
                child: FallingLeaves(isNight: _isNightMode),
              ),
            ),
          ],

          // ── 3. Subtle bottom gradient for readability ─────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * 0.52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.10),
                    Colors.black.withValues(alpha: 0.26),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: _useRive
                ? RivePetStage(
                    species: _species,
                    actionState: _petAction,
                    equippedItems: _equippedItems,
                    reduceMotion: false,
                    isNight: _isNightMode,
                    speechText: _statusBubbleText,
                    speechVisible: _bubbleVisible,
                    onPetTappedOrStroked: () =>
                        _performPetAction(PetActionState.petted),
                    onGroundTapped: _handleGroundTapped,
                  )
                : LumoInteractivePetStage(
                    species: _species,
                    actionState: _petAction,
                    equippedItems: _equippedItems,
                    reduceMotion: false,
                    isNight: _isNightMode,
                    speechText: _statusBubbleText,
                    speechVisible: _bubbleVisible,
                    onPetTappedOrStroked: () =>
                        _performPetAction(PetActionState.petted),
                    onGroundTapped: _handleGroundTapped,
                  ),
          ),

          // ── 4. Top Bar (greeting + coins + profile) ───────────────
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: topPadding + 8,
                left: 16,
                right: 16,
                bottom: 10,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.20),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar circle
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 10,
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage(AssetPaths.splashBg),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Selamlama + XP bar — parlak gökyüzünde okunurluk için
                  // yarı saydam koyu hap (gölge tek başına yetmiyor).
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 7, 13, 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.34),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName.isEmpty
                                ? 'Hello! · Lv. $_level'
                                : 'Hello, $_userName! · Lv. $_level',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.nunito(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: SizedBox(
                                    height: 7,
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.24),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor:
                                              (_xp / _xpMax).clamp(0.0, 1.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFFA78BE0),
                                                  Color(0xFFFEF08A),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  '$_xp/$_xpMax',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.nunito(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  CoinReward(amount: _coins),
                ],
              ),
            ),
          ),

          Positioned(
            right: 14,
            top: topPadding + 84,
            child: Column(
              children: [
                _SideActionButton(
                  icon: Icons.notifications_rounded,
                  color: const Color(0xFFFF8A65),
                  label: 'Notifications',
                  onTap: _openNotifications,
                ),
                const SizedBox(height: 14),
                _SideActionButton(
                  icon: Icons.spa_rounded,
                  color: const Color(0xFF4FB3F0),
                  label: 'Calm',
                  onTap: _openBreathing,
                ),
                const SizedBox(height: 14),
                _SideActionButton(
                  icon: Icons.checklist_rounded,
                  color: const Color(0xFF58C77A),
                  label: 'Quests',
                  onTap: _openDailyQuests,
                ),
              ],
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
                // (a) Lumi'nin altına sabit, etiketli 4 net bakım butonu.
                // Dördü de aynı stildedir (acil nabız/kırmızı nokta yok).
                Row(
                  children: [
                    Expanded(
                      child: _CareActionButton(
                        id: 'feed',
                        label: 'Feed',
                        icon: Icons.restaurant_rounded,
                        color: const Color(0xFFFB923C),
                        value: _hunger,
                        onTap: () => _performPetAction(PetActionState.eat),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _CareActionButton(
                        id: 'water',
                        label: 'Water',
                        icon: Icons.water_drop_rounded,
                        color: const Color(0xFF38BDF8),
                        value: _hydration,
                        onTap: () => _performPetAction(PetActionState.drink),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _CareActionButton(
                        id: 'play',
                        label: 'Play',
                        icon: Icons.sports_soccer_rounded,
                        color: const Color(0xFFFBBF24),
                        value: _happiness,
                        onTap: () => _performPetAction(PetActionState.playBall),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _CareActionButton(
                        id: 'sleep',
                        label: _petAction == PetActionState.sleep
                            ? 'Wake Up'
                            : 'Sleep',
                        icon: _petAction == PetActionState.sleep
                            ? Icons.wb_sunny_rounded
                            : Icons.nightlight_round,
                        color: const Color(0xFF818CF8),
                        value: _energy,
                        onTap: () => _performPetAction(
                          _petAction == PetActionState.sleep
                              ? PetActionState.idle
                              : PetActionState.sleep,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // (b) Pet Care Panel — ince şerit, varsayılan kapalı.
                GlassCard(
                  padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
                  radius: 16,
                  opacity: 0.86,
                  blur: 18,
                  child: Column(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() =>
                            _isPetCarePanelExpanded = !_isPetCarePanelExpanded),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.pets,
                                      color: Color(0xFF5A449C), size: 16),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'Lumi Care',
                                      style: AppText.nunito(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1E2E3D),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            _VitalBar(
                              icon: Icons.restaurant_rounded,
                              value: _hunger,
                              color: const Color(0xFFFB923C),
                              onTap: () => setState(() =>
                                  _isPetCarePanelExpanded =
                                      !_isPetCarePanelExpanded),
                            ),
                            const SizedBox(width: 6),
                            _VitalBar(
                              icon: Icons.water_drop_rounded,
                              value: _hydration,
                              color: const Color(0xFF38BDF8),
                              onTap: () => setState(() =>
                                  _isPetCarePanelExpanded =
                                      !_isPetCarePanelExpanded),
                            ),
                            const SizedBox(width: 6),
                            _VitalBar(
                              icon: Icons.favorite_rounded,
                              value: _happiness,
                              color: const Color(0xFFF472B6),
                              onTap: () => setState(() =>
                                  _isPetCarePanelExpanded =
                                      !_isPetCarePanelExpanded),
                            ),
                            const SizedBox(width: 6),
                            _VitalBar(
                              icon: Icons.bolt_rounded,
                              value: _energy,
                              color: const Color(0xFFFBBF24),
                              onTap: () => setState(() =>
                                  _isPetCarePanelExpanded =
                                      !_isPetCarePanelExpanded),
                            ),
                            Icon(
                              _isPetCarePanelExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 20,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      // Detayı buton grubunda: sayısal vital dökümü.
                      if (_isPetCarePanelExpanded) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _VitalStat(
                                  label: 'Hunger',
                                  value: _hunger,
                                  color: const Color(0xFFFB923C)),
                            ),
                            Expanded(
                              child: _VitalStat(
                                  label: 'Water',
                                  value: _hydration,
                                  color: const Color(0xFF38BDF8)),
                            ),
                            Expanded(
                              child: _VitalStat(
                                  label: 'Happiness',
                                  value: _happiness,
                                  color: const Color(0xFFF472B6)),
                            ),
                            Expanded(
                              child: _VitalStat(
                                  label: 'Energy',
                                  value: _energy,
                                  color: const Color(0xFFFBBF24)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Side Action Button
// ─────────────────────────────────────────────────────────────────────────────
class _SideActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;

  /// İkonun altındaki küçük etiket (10.5px).
  final String? label;
  final VoidCallback onTap;

  const _SideActionButton({
    required this.icon,
    required this.color,
    this.label,
    required this.onTap,
  });

  @override
  State<_SideActionButton> createState() => _SideActionButtonState();
}

class _SideActionButtonState extends State<_SideActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTapDown: (_) => _scaleController.reverse(),
      onTapUp: (_) {
        _scaleController.forward();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.forward(),
      child: ScaleTransition(
        scale: _scaleController,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.55),
                Colors.white.withValues(alpha: 0.28),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.65),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(widget.icon, color: Colors.white, size: 20),
        ),
      ),
    );

    if (widget.label == null) return button;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button,
        const SizedBox(height: 2),
        Text(
          widget.label!,
          style: AppText.nunito(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            shadows: const [
              Shadow(
                  color: Colors.black54, blurRadius: 5, offset: Offset(0, 1)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Care Action Button — Lumi'nin altındaki 4 net butondan biri
// ─────────────────────────────────────────────────────────────────────────────
class _CareActionButton extends StatelessWidget {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  /// Butonun bağlı olduğu vital değer (0.0–1.0). Lumi Care şeridindeki
  /// değerle aynı kaynaktan gelir, etiketin yanında % olarak gösterilir.
  final double value;

  final VoidCallback onTap;

  const _CareActionButton({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Opak zemin (cam değil): gökyüzünde net okunur. Dört buton da
    // birebir aynı stildedir — büyüme/küçülme ve renk farkı yok.
    // Tek satır etiket ("Feed %84") taşmayı önler.
    final pct = (value.clamp(0.0, 1.0) * 100).round();
    return Semantics(
      button: true,
      identifier: id,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      style: AppText.nunito(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E2E3D),
                      ),
                    ),
                    Text(
                      ' %$pct',
                      maxLines: 1,
                      style: AppText.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5D6470),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vital Bar — emoji hap yerine ikon + kalın bar; eşik altında kırmızı.
// ─────────────────────────────────────────────────────────────────────────────
class _VitalBar extends StatelessWidget {
  final IconData icon;
  final double value;
  final Color color;
  final VoidCallback? onTap;

  const _VitalBar({
    required this.icon,
    required this.value,
    required this.color,
    this.onTap,
  });

  /// Bu değerin altında vital "kritik" sayılır ve kırmızıya döner.
  static const double dangerBelow = 0.25;

  @override
  Widget build(BuildContext context) {
    final critical = value <= dangerBelow;
    final barColor = critical ? const Color(0xFFEF4444) : color;

    final bar = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: barColor),
        const SizedBox(width: 3),
        Container(
          width: 26,
          height: 7,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );

    if (onTap == null) return bar;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: bar,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vital Stat — şerit detayındaki sayısal döküm (Açlık %84 …)
// ─────────────────────────────────────────────────────────────────────────────
class _VitalStat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _VitalStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final critical = value <= 0.25;
    final pct = (value * 100).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: critical ? const Color(0xFFEF4444) : color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '$label %$pct',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.nunito(
              fontSize: 10.5,
              fontWeight: critical ? FontWeight.w800 : FontWeight.w700,
              color:
                  critical ? const Color(0xFFDC2626) : const Color(0xFF5D6470),
            ),
          ),
        ),
      ],
    );
  }
}
