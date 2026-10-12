import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding'de toplanan kullanıcı profili (isim, hedefler, maskot).
/// [SharedPreferences] içinde saklanır; uygulama yeniden açılsa da yaşar.
class UserProfile {
  final String name;
  final List<String> goals;
  final int mascotIndex;
  final String speciesId;

  const UserProfile({
    this.name = '',
    this.goals = const [],
    this.mascotIndex = 0,
    this.speciesId = 'fox',
  });

  /// Gemini'ye gönderilecek kişiselleştirme metni. Boşsa '' döner.
  String questContext() {
    final parts = <String>[];
    if (name.isNotEmpty) parts.add("Kullanıcının adı: $name.");
    if (goals.isNotEmpty) {
      parts.add(
          'Hedefleri: ${goals.map(UserProfileStore.goalLabel).join(', ')}.');
    }
    parts.add(
        'Evcil hayvanı: ${UserProfileStore.speciesLabel(speciesId)}.');
    return parts.join(' ');
  }

  /// Önbellek geçerliliği için profil parmak izi.
  String get profileKey {
    final sorted = List<String>.from(goals)..sort();
    return '$name|${sorted.join(',')}|$speciesId';
  }
}

class UserProfileStore {
  UserProfileStore._();

  static const _kName = 'user_profile_name_v1';
  static const _kGoals = 'user_profile_goals_v1';
  static const _kMascot = 'user_profile_mascot_v1';
  static const _kSpecies = 'user_profile_species_v1';

  /// Karusel sırası (fox, cat, dog, panda, fossa) → vektör sahnedeki
  /// en yakın tür (sahnede fox/cat/bunny çizilebiliyor).
  static const carouselSpecies = ['fox', 'cat', 'fox', 'bunny', 'fox'];

  /// Hedef kimliği → quest bağlamında kullanılacak Türkçe ad.
  static String goalLabel(String id) => switch (id) {
        'stress' => 'stres azaltma',
        'sleep' => 'daha iyi uyku',
        'focus' => 'odaklanma',
        'motivation' => 'motivasyon',
        'meditation' => 'meditasyon',
        _ => id,
      };

  static String speciesLabel(String id) => switch (id) {
        'fox' => 'tilki',
        'cat' => 'kedi',
        'bunny' => 'tavşan',
        _ => 'tilki',
      };

  static String speciesForMascot(int index) {
    if (index < 0 || index >= carouselSpecies.length) return 'fox';
    return carouselSpecies[index];
  }

  static Future<void> save({
    required String name,
    required List<String> goals,
    required int mascotIndex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, name.trim());
    await prefs.setStringList(_kGoals, goals);
    await prefs.setInt(_kMascot, mascotIndex);
    await prefs.setString(_kSpecies, speciesForMascot(mascotIndex));
  }

  static Future<UserProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProfile(
      name: prefs.getString(_kName) ?? '',
      goals: prefs.getStringList(_kGoals) ?? const [],
      mascotIndex: prefs.getInt(_kMascot) ?? 0,
      speciesId: prefs.getString(_kSpecies) ?? 'fox',
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kName);
    await prefs.remove(_kGoals);
    await prefs.remove(_kMascot);
    await prefs.remove(_kSpecies);
  }
}
