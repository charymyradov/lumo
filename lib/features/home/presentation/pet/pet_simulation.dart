/// Backward-compatible barrel for the procedural pet rig.
///
/// The implementation now lives in focused files; this barrel keeps every
/// existing `pet_simulation.dart` import working:
/// * [MicroParticle] → `micro_particle.dart`
/// * `PetRigSimulationState` → `pet_rig_state.dart`
/// * `EquippedFlags` → `equipped_flags.dart`
/// * `stepPetSimulation` → `pet_rig_physics.dart`
library;

export 'equipped_flags.dart';
export 'micro_particle.dart';
export 'pet_rig_physics.dart';
export 'pet_rig_state.dart';
