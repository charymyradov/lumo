import 'package:flutter/material.dart';

/// Species of the mascot pet.
///
/// Direct port of `MascotSpecies` from `lumo_kot/.../model/LumoModels.kt`.
/// The colors are used by the pet rig painter so that every species is drawn
/// with its own ear / fur palette.
enum MascotSpecies {
  fox(
    id: 'fox',
    titleTr: 'Tilki',
    titleEn: 'Fox',
    traitsTr: 'Meraklı • Enerjik • Sevecen',
    traitsEn: 'Curious • Energetic • Loving',
    primaryEarColor: Color(0xFF8B5CF6),
    secondaryFurColor: Color(0xFFFDFBFF),
  ),
  cat(
    id: 'cat',
    titleTr: 'Kedi',
    titleEn: 'Kitten',
    traitsTr: 'Oyuncu • Zarif • Neşeli',
    traitsEn: 'Playful • Graceful • Cheerful',
    primaryEarColor: Color(0xFFF472B6),
    secondaryFurColor: Color(0xFFFCE7F3),
  ),
  bunny(
    id: 'bunny',
    titleTr: 'Tavşan',
    titleEn: 'Bunny',
    traitsTr: 'Nazik • Huzurlu • Sevimli',
    traitsEn: 'Gentle • Peaceful • Cute',
    primaryEarColor: Color(0xFF93C5FD),
    secondaryFurColor: Color(0xFFDBEAFE),
  );

  const MascotSpecies({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.traitsTr,
    required this.traitsEn,
    required this.primaryEarColor,
    required this.secondaryFurColor,
  });

  final String id;
  final String titleTr;
  final String titleEn;
  final String traitsTr;
  final String traitsEn;

  /// Inner ear color (also used for the hair tuft gradient).
  final Color primaryEarColor;

  /// Main fur color for head / torso / tail base.
  final Color secondaryFurColor;

  /// Maps the persisted species id back to an enum value.
  static MascotSpecies fromId(String id) => MascotSpecies.values.firstWhere(
        (species) => species.id == id,
        orElse: () => MascotSpecies.fox,
      );
}
