/// Species of the mascot pet.
///
/// Pure-Dart domain enum — no Flutter imports. Colors are stored as ARGB
/// ints; presentation layer maps them to [Color] via extension.
enum MascotSpecies {
  fox(
    id: 'fox',
    titleTr: 'Tilki',
    titleEn: 'Fox',
    traitsTr: 'Meraklı • Enerjik • Sevecen',
    traitsEn: 'Curious • Energetic • Loving',
    primaryEarColorValue: 0xFF8B5CF6,
    secondaryFurColorValue: 0xFFFDFBFF,
  ),
  cat(
    id: 'cat',
    titleTr: 'Kedi',
    titleEn: 'Kitten',
    traitsTr: 'Oyuncu • Zarif • Neşeli',
    traitsEn: 'Playful • Graceful • Cheerful',
    primaryEarColorValue: 0xFFF472B6,
    secondaryFurColorValue: 0xFFFCE7F3,
  ),
  bunny(
    id: 'bunny',
    titleTr: 'Tavşan',
    titleEn: 'Bunny',
    traitsTr: 'Nazik • Huzurlu • Sevimli',
    traitsEn: 'Gentle • Peaceful • Cute',
    primaryEarColorValue: 0xFF93C5FD,
    secondaryFurColorValue: 0xFFDBEAFE,
  );

  const MascotSpecies({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.traitsTr,
    required this.traitsEn,
    required this.primaryEarColorValue,
    required this.secondaryFurColorValue,
  });

  final String id;
  final String titleTr;
  final String titleEn;
  final String traitsTr;
  final String traitsEn;

  /// Inner ear color (also used for the hair tuft gradient).
  final int primaryEarColorValue;

  /// Main fur color for head / torso / tail base.
  final int secondaryFurColorValue;

  /// Maps the persisted species id back to an enum value.
  static MascotSpecies fromId(String id) => MascotSpecies.values.firstWhere(
        (species) => species.id == id,
        orElse: () => MascotSpecies.fox,
      );
}
