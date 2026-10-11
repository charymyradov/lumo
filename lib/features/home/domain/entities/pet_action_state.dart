/// Every locomotion / interaction mode the pet rig understands.
///
/// Direct port of `PetActionState` from `lumo_kot/.../model/LumoModels.kt`.
/// The internal pet simulation (see `PetRigSimulationState`) switches between
/// these states and every state maps to a distinct body animation.
enum PetActionState {
  idle,
  walk,
  run,
  jump,
  eat,
  drink,
  petted,
  playBall,
  groom,
  sleep,
  dance;

  /// Maps the legacy snake/upper-case action codes (`"EAT"`, `"PLAY_BALL"`, …)
  /// used by older call sites back onto the enum.
  static PetActionState fromCode(String code) {
    switch (code.trim().toUpperCase()) {
      case 'EAT':
        return PetActionState.eat;
      case 'DRINK':
        return PetActionState.drink;
      case 'PETTED':
        return PetActionState.petted;
      case 'PLAY_BALL':
        return PetActionState.playBall;
      case 'RUN':
        return PetActionState.run;
      case 'GROOM':
        return PetActionState.groom;
      case 'SLEEP':
        return PetActionState.sleep;
      case 'JUMP':
        return PetActionState.jump;
      case 'WALK':
        return PetActionState.walk;
      case 'DANCE':
        return PetActionState.dance;
      default:
        return PetActionState.idle;
    }
  }
}
