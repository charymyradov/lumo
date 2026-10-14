import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lumo/core/services/audio_service.dart';
import 'package:lumo/core/services/haptic_service.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/pages/controllers/home_pet_state_mixin.dart';

/// HomePage'in zamanlayıcı sürücülü bakım davranışları:
/// vital nabzı, boşta gezinme, otomatik bakım ve dokunma etkileşimleri.
///
/// [HomePetStateMixin] üzerine uygulanır; alanları ve kalıcılığı oradan alır.
mixin HomePetCareMixin<T extends StatefulWidget> on HomePetStateMixin<T> {
  @override
  void syncHomeTimers() {
    final shouldRun = isAppResumed && isTickerEnabled;
    if (homeTimersActive == shouldRun) return;
    homeTimersActive = shouldRun;

    if (shouldRun) {
      startVitalPulse();
      scheduleIdleWander();
    } else {
      vitalPulseTimer?.cancel();
      vitalPulseTimer = null;
      idleWanderTimer?.cancel();
      idleWanderTimer = null;
    }
  }

  void startVitalPulse() {
    vitalPulseTimer?.cancel();
    vitalPulseTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;

      final isSleeping = petLifecycle == PetLifecycleState.resting &&
          petAction == PetActionState.sleep;

      setState(() {
        if (isSleeping) {
          // Uyurken enerji dolar, diğer ihtiyaçlar daha yavaş değişir.
          energy = (energy + 0.15).clamp(0.0, 1.0);
          hunger = (hunger + 0.02).clamp(0.0, 1.0);
          hydration = (hydration - 0.015).clamp(0.0, 1.0);
          happiness = (happiness - 0.01).clamp(0.0, 1.0);
        } else {
          hunger = (hunger + 0.04).clamp(0.0, 1.0);
          hydration = (hydration - 0.03).clamp(0.0, 1.0);
          energy = (energy - 0.015).clamp(0.0, 1.0);
          happiness = (happiness - 0.02).clamp(0.0, 1.0);
        }
      });
      persistVitals();

      updatePetMood();

      if (isSleeping) {
        // Enerji dolunca otomatik uyan — sonsuz uykuyu engeller.
        if (energy >= 0.75) {
          setState(() {
            petAction = PetActionState.idle;
            petLifecycle = PetLifecycleState.idle;
          });
          say("Oh, I feel rested! I'm ready to play! ✨");
        }
        return;
      }

      final priorityAction = resolvePriorityAction();
      if (priorityAction != PetActionState.idle &&
          petAction != priorityAction &&
          petLifecycle != PetLifecycleState.reacting) {
        executeAutoCare(priorityAction);
      }
    });
  }

  void applyPetActionTimer({Duration? duration}) {
    petActionTimer?.cancel();
    final actionDuration = duration ?? const Duration(milliseconds: 1800);
    petActionTimer = Timer(actionDuration, () {
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
      ].contains(petAction);

      if (!isTransientAction) return;

      final priorityAction = resolvePriorityAction();
      if (priorityAction != PetActionState.idle) {
        executeAutoCare(priorityAction);
        return;
      }

      setState(() {
        petAction = PetActionState.idle;
        petLifecycle = PetLifecycleState.idle;
      });
      say("I love spending time with you! 💜");
    });
  }

  void executeAutoCare(PetActionState action) {
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
      petAction = action;
      petLifecycle = action == PetActionState.sleep
          ? PetLifecycleState.resting
          : PetLifecycleState.seekingCare;
    });
    // Balon metnini `transitionPetAction` balonu sahiplenir (bkz. `say`).

    transitionPetAction(
      action,
      bubble: bubble,
      lifetime: action == PetActionState.sleep
          ? null
          : const Duration(milliseconds: 1800),
    );
  }

  void transitionPetAction(
    PetActionState action, {
    String? bubble,
    Duration? lifetime,
  }) {
    setState(() {
      petAction = action;
      petLifecycle = switch (action) {
        PetActionState.sleep => PetLifecycleState.resting,
        PetActionState.eat ||
        PetActionState.drink ||
        PetActionState.groom =>
          PetLifecycleState.seekingCare,
        PetActionState.walk ||
        PetActionState.run ||
        PetActionState.playBall ||
        PetActionState.dance =>
          PetLifecycleState.wandering,
        PetActionState.idle => PetLifecycleState.idle,
        _ => PetLifecycleState.reacting,
      };
    });
    if (bubble != null) {
      say(bubble);
    }

    if (lifetime != null &&
        action != PetActionState.sleep &&
        action != PetActionState.idle) {
      applyPetActionTimer(duration: lifetime);
    }
  }

  void scheduleIdleWander() {
    if (!homeTimersActive) return;
    idleWanderTimer?.cancel();
    idleWanderTimer = Timer(
      Duration(milliseconds: 2400 + Random().nextInt(2400)),
      () {
        if (!mounted || !homeTimersActive) return;
        if (petAction != PetActionState.idle) {
          scheduleIdleWander();
          return;
        }

        final careAction = pendingCareAction();
        if (careAction != null) {
          executeAutoCare(careAction);
        }
        // Walking / running / jumping around is handled by the pet stage
        // itself, so there is no need to drive a position from up here.
        scheduleIdleWander();
      },
    );
  }

  // ── Pet interactions ───────────────────────────────────────────────
  void performPetAction(PetActionState action) {
    // His: her dokunuşta tepki (rehber §8).
    HapticService.petTap();
    switch (action) {
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
      switch (action) {
        case PetActionState.eat:
          hunger = (hunger - 0.18).clamp(0.0, 1.0);
          happiness = (happiness + 0.08).clamp(0.0, 1.0);
          break;
        case PetActionState.drink:
          hydration = (hydration + 0.22).clamp(0.0, 1.0);
          energy = (energy + 0.06).clamp(0.0, 1.0);
          break;
        case PetActionState.petted:
          happiness = (happiness + 0.16).clamp(0.0, 1.0);
          break;
        case PetActionState.playBall:
          happiness = (happiness + 0.20).clamp(0.0, 1.0);
          energy = (energy - 0.10).clamp(0.0, 1.0);
          hunger = (hunger - 0.05).clamp(0.0, 1.0);
          break;
        case PetActionState.run:
          energy = (energy - 0.15).clamp(0.0, 1.0);
          break;
        case PetActionState.groom:
          happiness = (happiness + 0.10).clamp(0.0, 1.0);
          break;
        case PetActionState.sleep:
          energy = (energy + 0.30).clamp(0.0, 1.0);
          break;
        case PetActionState.jump:
          happiness = (happiness + 0.18).clamp(0.0, 1.0);
          energy = (energy - 0.06).clamp(0.0, 1.0);
          hunger = (hunger - 0.05).clamp(0.0, 1.0);
          break;
        case PetActionState.walk:
          break;
        case PetActionState.dance:
          happiness = (happiness + 0.18).clamp(0.0, 1.0);
          break;
        case PetActionState.idle:
          break;
      }
    });
    // Vital değişti → ruh hali ve acil buton nabazı hemen tazelensin.
    updatePetMood();
    persistVitals();
    // Bakım mini-ödülü: her etkileşimde küçük XP, coin değil (ekonomi Tasks/Shop'ta).
    addWalletXp(2).then((r) {
      if (!mounted) return;
      setState(() {
        level = r.level;
        xp = r.xp;
      });
    });

    final bubble = switch (action) {
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

    transitionPetAction(
      action,
      bubble: bubble,
      lifetime: action == PetActionState.sleep || action == PetActionState.idle
          ? null
          : const Duration(milliseconds: 1800),
    );
  }

  /// Sahnedeki yürüme/koşma etkileşimi için kısa bilgi balonu gösterir.
  void handleGroundTapped(PetActionState moveMode, String message) {
    assert(moveMode == PetActionState.walk || moveMode == PetActionState.run);
    say(message);
  }
}
