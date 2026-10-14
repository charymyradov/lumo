import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lumo/core/di/injection.dart';
import 'package:lumo/core/repositories/progress_repositories.dart';
import 'package:lumo/core/repositories/user_profile_repository.dart';
import 'package:lumo/core/repositories/wallet_repository.dart';
import 'package:lumo/core/repositories/wallet_repository_impl.dart';
import 'package:lumo/core/services/progress_store.dart';
import 'package:lumo/core/services/user_profile_store.dart';
import 'package:lumo/core/services/wallet_store.dart';
import 'package:lumo/features/home/domain/entities/cosmetic_item.dart';
import 'package:lumo/features/home/domain/entities/mascot_species.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/bloc/home_state.dart'
    show PetMood, resolvePetMood;

/// Evcil hayvan sahnesinin yaşam döngüsü evresi.
enum PetLifecycleState {
  idle,
  wandering,
  reacting,
  resting,
  seekingCare,
}

/// Bakım nabzı ve otomatik davranışlar için kullanılan ruh hali.
/// Bloc'taki [PetMood] ile birebir eşleşir; sayfa-içi tüketime açıktır.
enum HomePetMood {
  joyful,
  playful,
  sleepy,
  hungry,
  thirsty,
  tired,
  calm,
  needy,
}

/// HomePage'in durum, yaşam döngüsü ve kalıcılık mantığı.
///
/// Zamanlayıcı sürücülü davranışlar ([syncHomeTimers]) [HomePetCareMixin]
/// tarafından sağlanır; bu mixin yalnızca alanları ve saf karar
/// fonksiyonlarını sahiplenir.
mixin HomePetStateMixin<T extends StatefulWidget> on State<T> {
  /// Onboarding'de seçilen maskot (local storage'dan yüklenir).
  MascotSpecies species = MascotSpecies.fox;

  /// Onboarding'de girilen isim — selamlamada kullanılır.
  String userName = '';

  /// Rive sahnesi önceliklidir; `lumo.riv` henüz pakette yoksa
  /// sahne otomatik olarak vektör sahneye düşer.
  static const bool useRive = true;

  /// Wardrobe / furniture rendered on the stage (cloud bed, lantern, crown…).
  final List<CosmeticItem> equippedItems = defaultCosmeticItems;

  // ── Pet state ──────────────────────────────────────────────────────
  PetActionState petAction = PetActionState.idle;
  PetLifecycleState petLifecycle = PetLifecycleState.idle;
  HomePetMood petMood = HomePetMood.calm;

  // ── Pet Vitals ─────────────────────────────────────────────────────
  double hunger = 0.84;
  double hydration = 0.78;
  double happiness = 0.92;
  double energy = 0.88;

  bool isPetCarePanelExpanded = false;
  String statusBubbleText = "I love spending time with you! 💜";

  /// Kafa üstü balon yalnızca [statusBubbleText] değiştiğinde belirir ve
  /// birkaç saniye sonra kendiliğinden gizlenir (bkz. [say]).
  bool bubbleVisible = false;
  Timer? bubbleTimer;

  bool isNightMode = false;

  // ── Cüzdan (coin/XP/level) — repository üzerinden, static Store yok ──
  int coins = WalletRepositoryImpl.defaultCoins;
  int level = WalletRepositoryImpl.defaultLevel;
  int xp = WalletRepositoryImpl.defaultXp;
  static const int xpMax = WalletRepositoryImpl.xpPerLevel;
  bool isAppResumed = true;
  bool isTickerEnabled = true;
  bool homeTimersActive = false;

  Timer? idleWanderTimer;
  Timer? petActionTimer;
  Timer? vitalPulseTimer;

  /// Zamanlayıcıları uygulama/Ticker durumuna göre başlatır ya da durdurur.
  /// [HomePetCareMixin] tarafından uygulanır.
  void syncHomeTimers();

  /// Sayfanın `initState` içinden çağrılır (observer kaydı sayfada kalır).
  void initPetState() {
    loadProfile();
    updateEnvironmentMode();
  }

  void onPetDependenciesChanged() {
    isTickerEnabled = TickerMode.valuesOf(context).enabled;
    syncHomeTimers();
  }

  void handlePetAppLifecycle(AppLifecycleState state) {
    final isResumed = state == AppLifecycleState.resumed;
    if (isAppResumed == isResumed) return;

    setState(() {
      isAppResumed = isResumed;
    });
    syncHomeTimers();
  }

  /// Sayfanın `dispose` içinden çağrılır (observer kaydı sayfada kaldırılır).
  void disposePetState() {
    idleWanderTimer?.cancel();
    petActionTimer?.cancel();
    vitalPulseTimer?.cancel();
    bubbleTimer?.cancel();
  }

  /// Kayıtlı profil (isim + maskot) — yoksa varsayılanlarla devam edilir.
  ///
  /// GetIt kayıtlıysa repository'ler, değilse (test/önizleme) static
  /// Store'lar kullanılır — iki yol da aynı anahtarlara yazar.
  Future<UserProfile> loadUserProfile() =>
      sl.isRegistered<UserProfileRepository>()
          ? sl<UserProfileRepository>().load()
          : UserProfileStore.load();

  Future<({double hunger, double water, double happy, double energy})>
      loadVitals() async {
    if (sl.isRegistered<PetVitalsRepository>()) {
      return sl<PetVitalsRepository>().load();
    }
    final v = await PetVitalsStore.load();
    return (hunger: v.$1, water: v.$2, happy: v.$3, energy: v.$4);
  }

  Future<({int coins, int xp, int level, int streak})> loadWallet() async {
    if (sl.isRegistered<WalletRepository>()) {
      return sl<WalletRepository>().load();
    }
    final w = await WalletStore.load();
    return (coins: w.$1, xp: w.$2, level: w.$3, streak: w.$4);
  }

  Future<void> saveVitals() {
    if (sl.isRegistered<PetVitalsRepository>()) {
      return sl<PetVitalsRepository>()
          .save(hunger, hydration, happiness, energy);
    }
    return PetVitalsStore.save(hunger, hydration, happiness, energy);
  }

  Future<({int level, int xp})> addWalletXp(int amount) async {
    if (sl.isRegistered<WalletRepository>()) {
      return sl<WalletRepository>().addXp(amount);
    }
    final r = await WalletStore.addXp(amount);
    return (level: r.$1, xp: r.$2);
  }

  Future<void> loadProfile() async {
    final results = await Future.wait([
      loadUserProfile(),
      loadVitals(),
      loadWallet(),
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
      userName = profile.name;
      species = MascotSpecies.fromId(profile.speciesId);
      hunger = vitals.hunger;
      hydration = vitals.water;
      happiness = vitals.happy;
      energy = vitals.energy;
      coins = wallet.coins;
      xp = wallet.xp;
      level = wallet.level;
    });
    updatePetMood();
  }

  Future<void> persistVitals() => saveVitals();

  Future<void> refreshWallet() async {
    final wallet = await loadWallet();
    if (!mounted) return;
    setState(() {
      coins = wallet.coins;
      xp = wallet.xp;
      level = wallet.level;
    });
  }

  /// Yeni durum metnini balona yazar ve balonu ~3.5 sn boyunca görünür tutar.
  /// Balonun ömrü sahnedeki simülasyonda değil, burada sahiplenilir.
  void say(String text) {
    bubbleTimer?.cancel();
    setState(() {
      statusBubbleText = text;
      bubbleVisible = true;
    });
    bubbleTimer = Timer(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      setState(() => bubbleVisible = false);
    });
  }

  void updatePetMood() {
    // Saf fonksiyon HomeBloc'ta — test edilebilir, Widget sadece map'ler.
    final mood = resolvePetMood(
      hunger: hunger,
      hydration: hydration,
      happiness: happiness,
      energy: energy,
    );
    petMood = switch (mood) {
      PetMood.joyful => HomePetMood.joyful,
      PetMood.playful => HomePetMood.playful,
      PetMood.sleepy => HomePetMood.sleepy,
      PetMood.hungry => HomePetMood.hungry,
      PetMood.thirsty => HomePetMood.thirsty,
      PetMood.tired => HomePetMood.tired,
      PetMood.calm => HomePetMood.calm,
      PetMood.needy => HomePetMood.needy,
    };
  }

  /// Acil ve **deterministik** ihtiyaç — build sırasında güvenle çağrılır.
  PetActionState? urgentCareAction() {
    if (energy < 0.10 || petMood == HomePetMood.sleepy) {
      return PetActionState.sleep;
    }
    if (hydration < 0.28 || petMood == HomePetMood.thirsty) {
      return PetActionState.drink;
    }
    if (happiness < 0.22 || petMood == HomePetMood.needy) {
      return PetActionState.groom;
    }
    if (energy < 0.38 || petMood == HomePetMood.tired) {
      return PetActionState.walk;
    }
    return null;
  }

  PetActionState resolvePriorityAction() {
    return urgentCareAction() ?? PetActionState.idle;
  }

  /// Returns a "the pet needs care" action, or null when it is perfectly
  /// happy. Locomotion itself (walk/run/jump) is owned by the pet stage, so
  /// this only surfaces real needs.
  PetActionState? pendingCareAction() {
    final priority = resolvePriorityAction();
    if (priority != PetActionState.idle) return priority;
    if (energy < 0.15) return PetActionState.sleep;
    if (hydration < 0.35) return PetActionState.drink;
    if (happiness < 0.35) return PetActionState.groom;
    return null;
  }

  void updateEnvironmentMode() {
    final currentHour = DateTime.now().hour;
    isNightMode = currentHour >= 19 || currentHour < 7;
  }
}
