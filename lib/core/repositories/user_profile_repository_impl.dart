import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumo/core/repositories/user_profile_repository.dart';
import 'package:lumo/core/services/user_profile_store.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final SharedPreferences _prefs;
  UserProfileRepositoryImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  static const _kName = 'user_profile_name_v1';
  static const _kGoals = 'user_profile_goals_v1';
  static const _kMascot = 'user_profile_mascot_v1';
  static const _kSpecies = 'user_profile_species_v1';

  @override
  Future<UserProfile> load() async {
    return UserProfile(
      name: _prefs.getString(_kName) ?? '',
      goals: _prefs.getStringList(_kGoals) ?? const [],
      mascotIndex: _prefs.getInt(_kMascot) ?? 0,
      speciesId: _prefs.getString(_kSpecies) ?? 'fox',
    );
  }

  @override
  Future<void> save({
    required String name,
    required List<String> goals,
    required int mascotIndex,
  }) async {
    await _prefs.setString(_kName, name.trim());
    await _prefs.setStringList(_kGoals, goals);
    await _prefs.setInt(_kMascot, mascotIndex);
    await _prefs.setString(
        _kSpecies, UserProfileStore.speciesForMascot(mascotIndex));
  }
}
