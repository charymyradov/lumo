import 'package:flutter/material.dart';
import 'package:lumo/features/home/domain/entities/cosmetic_item.dart';
import 'package:lumo/features/home/domain/entities/mascot_species.dart';

/// Domain entity'ler saf Dart tutulur (int ARGB); bu extension'lar
/// presentation/painter katmanında [Color]'a çevirir.
/// Böylece domain `flutter/material.dart`'a bağımlı kalmaz (Clean Architecture).
extension MascotSpeciesUi on MascotSpecies {
  Color get primaryEarColor => Color(primaryEarColorValue);
  Color get secondaryFurColor => Color(secondaryFurColorValue);
}

extension CosmeticItemUi on CosmeticItem {
  Color get accentColor => Color(accentColorValue);
}
