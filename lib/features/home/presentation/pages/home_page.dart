import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/features/breathing/presentation/pages/breathing_page.dart';
import 'package:lumo/features/home/domain/entities/cosmetic_item.dart';
import 'package:lumo/features/home/domain/entities/mascot_species.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/pet/lumo_interactive_pet_stage.dart';
import 'package:lumo/features/notifications/presentation/pages/notifications_page.dart';
import 'package:lumo/shared/widgets/coin_badge.dart';
import 'package:lumo/shared/widgets/glass_card.dart';

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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  /// Mascot species drawn by the interactive pet stage.
  static const MascotSpecies _species = MascotSpecies.fox;

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
  
  bool _isPetCarePanelExpanded = true;
  bool _isHomeTasksExpanded = false;
  String _statusBubbleText = "Seninle vakit geçirmek çok güzel! 💜";
  bool _isNightMode = false;

  // ── Float animation (subtle up-down when idle) ─────────────────────
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    _updateEnvironmentMode();
    _startVitalPulse();
    _scheduleIdleWander();
  }

  @override
  void dispose() {
    _idleWanderTimer?.cancel();
    _petActionTimer?.cancel();
    _vitalPulseTimer?.cancel();
    _floatController.dispose();
    super.dispose();
  }

  void _updatePetMood() {
    if (_energy < 0.2) {
      _petMood = _PetMood.sleepy;
      return;
    }
    if (_hunger > 0.82) {
      _petMood = _PetMood.hungry;
      return;
    }
    if (_hydration < 0.25) {
      _petMood = _PetMood.thirsty;
      return;
    }
    if (_happiness < 0.28) {
      _petMood = _PetMood.needy;
      return;
    }
    if (_energy < 0.45) {
      _petMood = _PetMood.tired;
      return;
    }
    if (_happiness > 0.82 && _energy > 0.5) {
      _petMood = _PetMood.playful;
      return;
    }
    if (_happiness > 0.6) {
      _petMood = _PetMood.joyful;
      return;
    }
    _petMood = _PetMood.calm;
  }

  void _startVitalPulse() {
    _vitalPulseTimer?.cancel();
    _vitalPulseTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;

      setState(() {
        _hunger = (_hunger + 0.04).clamp(0.0, 1.0);
        _hydration = (_hydration - 0.03).clamp(0.0, 1.0);
        _energy = (_energy - 0.03).clamp(0.0, 1.0);
        _happiness = (_happiness - 0.02).clamp(0.0, 1.0);
      });

      _updatePetMood();

      if (_petLifecycle == _PetLifecycleState.resting && _petAction == PetActionState.sleep) {
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
        _statusBubbleText = "Seninle vakit geçirmek çok güzel! 💜";
      });
    });
  }

  PetActionState _resolvePriorityAction() {
    if (_energy < 0.18 || _petMood == _PetMood.sleepy) {
      return PetActionState.sleep;
    }
    if (_hunger > 0.82 || _petMood == _PetMood.hungry) {
      return PetActionState.eat;
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
    if ((_happiness > 0.85 || _petMood == _PetMood.playful) && Random().nextBool()) {
      return PetActionState.playBall;
    }
    return PetActionState.idle;
  }

  void _executeAutoCare(PetActionState action) {
    final bubble = switch (action) {
      PetActionState.sleep => "Kendime biraz dinlenmem lazım... uyku vakti! 😴",
      PetActionState.eat => "Açlığım arttı, bir şeyler yemem lazım! 🍎",
      PetActionState.drink => "Susadım, su içmem gerekli! 💧",
      PetActionState.groom => "Biraz kendime bakmam lazım. Tüylerim dağınık! ✨",
      PetActionState.playBall => "Enerjim yerine geldi, biraz koşup oyun oynayayım! ⚽",
      PetActionState.walk => "Kısa bir yürüyüş iyi gelir! 🌿",
      _ => "Seninle vakit geçirmek çok güzel! 💜",
    };

    setState(() {
      _petAction = action;
      _petLifecycle = action == PetActionState.sleep
          ? _PetLifecycleState.resting
          : _PetLifecycleState.seekingCare;
      _statusBubbleText = bubble;
    });

    _transitionPetAction(
      action,
      bubble: bubble,
      lifetime: action == PetActionState.sleep ? null : const Duration(milliseconds: 1800),
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
    if (_energy < 0.25) return PetActionState.sleep;
    if (_hunger > 0.75) return PetActionState.eat;
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
        PetActionState.eat || PetActionState.drink || PetActionState.groom => _PetLifecycleState.seekingCare,
        PetActionState.walk || PetActionState.run || PetActionState.playBall || PetActionState.dance => _PetLifecycleState.wandering,
        PetActionState.idle => _PetLifecycleState.idle,
        _ => _PetLifecycleState.reacting,
      };
      if (bubble != null) {
        _statusBubbleText = bubble;
      }
    });

    if (lifetime != null && action != PetActionState.sleep && action != PetActionState.idle) {
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

    setState(() {
      switch (petAction) {
        case PetActionState.eat:
          _hunger = (_hunger + 0.18).clamp(0.0, 1.0);
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

    final bubble = switch (petAction) {
      PetActionState.eat => "Nefis! Karnım doydu, çok teşekkürler! 🍎✨",
      PetActionState.drink => "Berrak kaynak suyu çok ferahlatıcı! 💧",
      PetActionState.petted => "Mırrr... Başımın okşanmasına bayılıyorum! 💖",
      PetActionState.playBall => "Yakaladım! Hadi tekrar at, koşmak çok eğlenceli! ⚽🐾",
      PetActionState.run => "Rüzgar gibi koşuyorum! Bak ayaklarıma! 🏃‍♂️💨",
      PetActionState.groom => "Tüylerim yumuşacık ve tertemiz oldu! 🫧✨",
      PetActionState.sleep => "Zzz... Tatlı rüyalar görüyorum... 🌙",
      PetActionState.jump => "Yaşasın! Gökyüzüne kadar zıpladım! ⭐",
      PetActionState.walk => "Çayırda yürüyüş yapmak harika! 🌸",
      PetActionState.dance => "Mutluluk dansı zamanı! 🎉",
      PetActionState.idle => "Seninle vakit geçirmek çok güzel! 💜",
    };

    _transitionPetAction(
      petAction,
      bubble: bubble,
      lifetime: petAction == PetActionState.sleep || petAction == PetActionState.idle
          ? null
          : const Duration(milliseconds: 1800),
    );
  }

  // ── Sağ üst buton rotaları ───────────────────────────────────────
  void _openBreathing() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BreathingPage()),
    );
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;

    final environmentBackground = _isNightMode
        ? AssetPaths.nightMeadow
        : AssetPaths.dayMeadow;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Full-screen Background ─────────────────────────────
          Image.asset(
            environmentBackground,
            fit: BoxFit.cover,
            alignment: Alignment.center,
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
            if (!_isNightMode)
              ...List.generate(6, (index) {
                final leafX = 40.0 + index * 70.0;
                final leafY = 180.0 + ((index % 2) * 70.0);
                final drift = sin((_floatController.value * 2 * pi) + index) * 12;
                return Positioned(
                  left: leafX + drift,
                  top: leafY,
                  child: Transform.rotate(
                    angle: (index % 2 == 0 ? 1 : -1) * 0.8,
                    child: Container(
                      width: 10,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7FD86A).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                );
              }),
          ],

          // ── 3. Subtle bottom gradient for readability ─────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * 0.50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.06),
                    Colors.black.withValues(alpha: 0.12),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // ── 3. Interactive pet stage (full screen) ────────────────
          // The stage owns locomotion, gestures, particles and every body
          // animation, exactly like `LumoInteractivePetStage` in the Kotlin app.
          Positioned.fill(
            child: LumoInteractivePetStage(
              species: _species,
              actionState: _petAction,
              equippedItems: _equippedItems,
              reduceMotion: false,
              onPetTappedOrStroked: () => _performPetAction(PetActionState.petted),
              onGroundTapped: (moveMode, message) {
                setState(() {
                  _petAction = moveMode;
                  _petLifecycle = moveMode == PetActionState.run ||
                          moveMode == PetActionState.walk
                      ? _PetLifecycleState.wandering
                      : _PetLifecycleState.idle;
                  _statusBubbleText = message;
                });
                _applyPetActionTimer();
              },
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

                  // Name + level
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Merhaba, Elif!',
                          style: GoogleFonts.nunito(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                color: Colors.black38,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '(Level 5, 230 xp)',
                          style: GoogleFonts.nunito(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                            shadows: const [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Coins
                  const CoinReward(amount: 246),
                  const SizedBox(width: 10),

                  // Profile icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.25),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 5. Right side action buttons ──────────────────────────
          Positioned(
            right: 14,
            top: topPadding + 80,
            child: Column(
              children: [
                _SideActionButton(
                  icon: Icons.inventory_2_outlined,
                  color: const Color(0xFFFF8A65),
                  onTap: _openNotifications,
                ),
                const SizedBox(height: 12),
                _SideActionButton(
                  icon: Icons.star_rounded,
                  color: const Color(0xFFFFD54F),
                  onTap: _openNotifications,
                ),
                const SizedBox(height: 12),
                _SideActionButton(
                  icon: Icons.water_drop_outlined,
                  color: const Color(0xFF64B5F6),
                  onTap: _openBreathing,
                ),
                const SizedBox(height: 12),
                _SideActionButton(
                  icon: Icons.refresh_rounded,
                  color: const Color(0xFF81C784),
                  onTap: () {},
                ),
              ],
            ),
          ),

          // ── Speech Bubble ───────────────────────────────────────────
          Positioned(
            top: topPadding + 80,
            left: 16,
            right: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text("🦊", style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _statusBubbleText,
                      style: GoogleFonts.nunito(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E2E3D),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 6. Bottom Panels (Pet Care & Tasks) ───────────────────
          Positioned(
            left: 12,
            right: 12,
            bottom: 90,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pet Care Panel
                GlassCard(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  radius: 24,
                  opacity: 0.82,
                  blur: 22,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isPetCarePanelExpanded = !_isPetCarePanelExpanded),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.pets, color: Color(0xFF5A449C), size: 18),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Lumi Bakım',
                                      style: GoogleFonts.nunito(
                                        fontSize: 14.5,
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _VitalMiniPill(emoji: "🍎", value: _hunger, color: const Color(0xFFFB923C)),
                                _VitalMiniPill(emoji: "💧", value: _hydration, color: const Color(0xFF38BDF8)),
                                _VitalMiniPill(emoji: "💖", value: _happiness, color: const Color(0xFFF472B6)),
                                _VitalMiniPill(emoji: "⚡", value: _energy, color: const Color(0xFFFBBF24)),
                                Icon(
                                  _isPetCarePanelExpanded ? Icons.expand_less : Icons.expand_more,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (_isPetCarePanelExpanded) ...[
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _PetCareButton(emoji: "🍎", label: "Besle", color: const Color(0xFFFB923C), onTap: () => _performPetAction(PetActionState.eat)),
                              const SizedBox(width: 8),
                              _PetCareButton(emoji: "💧", label: "Su Ver", color: const Color(0xFF38BDF8), onTap: () => _performPetAction(PetActionState.drink)),
                              const SizedBox(width: 8),
                              _PetCareButton(emoji: "💖", label: "Sev", color: const Color(0xFFF472B6), onTap: () => _performPetAction(PetActionState.petted)),
                              const SizedBox(width: 8),
                              _PetCareButton(emoji: "⚽", label: "Top Oyna", color: const Color(0xFFFBBF24), onTap: () => _performPetAction(PetActionState.playBall)),
                              const SizedBox(width: 8),
                              _PetCareButton(emoji: "🏃", label: "Koştur", color: const Color(0xFF34D399), onTap: () => _performPetAction(PetActionState.run)),
                              const SizedBox(width: 8),
                              _PetCareButton(emoji: "🫧", label: "Fırçala", color: const Color(0xFFA78BFA), onTap: () => _performPetAction(PetActionState.groom)),
                              const SizedBox(width: 8),
                              _PetCareButton(
                                emoji: _petAction == PetActionState.sleep ? "☀️" : "🌙",
                                label: _petAction == PetActionState.sleep ? "Uyandır" : "Uyut",
                                color: const Color(0xFF818CF8),
                                onTap: () => _performPetAction(
                                  _petAction == PetActionState.sleep
                                      ? PetActionState.idle
                                      : PetActionState.sleep,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),

                // Tasks Panel
                GlassCard(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  radius: 28,
                  opacity: 0.85,
                  blur: 22,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isHomeTasksExpanded = !_isHomeTasksExpanded),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Günlük Görevler',
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E2E3D),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "Tümünü Gör",
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF5A449C),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _isHomeTasksExpanded ? Icons.expand_less : Icons.expand_more,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (_isHomeTasksExpanded) ...[
                        const SizedBox(height: 14),
                        const _TaskRow(
                          icon: Icons.water_drop_outlined,
                          iconColor: Color(0xFF4FB3F0),
                          title: 'Su iç',
                          progressText: '1/1',
                          progress: 1.0,
                          barColor: Color(0xFF75D973),
                        ),
                        const SizedBox(height: 12),
                        const _TaskRow(
                          icon: Icons.directions_run_rounded,
                          iconColor: Color(0xFF58C77A),
                          title: '10.000 adım at',
                          progressText: '3.2k / 10k',
                          progress: 0.32,
                          barColor: Color(0xFF4FB3F0),
                        ),
                        const SizedBox(height: 12),
                        const _TaskRow(
                          icon: Icons.air_rounded,
                          iconColor: Color(0xFF9B6FE0),
                          title: 'Nefes egzersizi yap',
                          progressText: '0/1',
                          progress: 0.0,
                          barColor: Color(0xFF9B6FE0),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Side Action Button
// ─────────────────────────────────────────────────────────────────────────────
class _SideActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SideActionButton({
    required this.icon,
    required this.color,
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
    return GestureDetector(
      onTapDown: (_) => _scaleController.reverse(),
      onTapUp: (_) {
        _scaleController.forward();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.forward(),
      child: ScaleTransition(
        scale: _scaleController,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.45),
                Colors.white.withValues(alpha: 0.2),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(widget.icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task Row
// ─────────────────────────────────────────────────────────────────────────────
class _TaskRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String progressText;
  final double progress;
  final Color barColor;

  const _TaskRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.progressText,
    required this.progress,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E2E3D),
                ),
              ),
            ),
            Text(
              progressText,
              style: GoogleFonts.nunito(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5D6470),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            height: 7,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          barColor,
                          barColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vital Mini Pill
// ─────────────────────────────────────────────────────────────────────────────
class _VitalMiniPill extends StatelessWidget {
  final String emoji;
  final double value;
  final Color color;

  const _VitalMiniPill({
    required this.emoji,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 2),
          Container(
            width: 20,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pet Care Button
// ─────────────────────────────────────────────────────────────────────────────
class _PetCareButton extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PetCareButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E2E3D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
