import 'package:lumo/core/services/user_profile_store.dart';

/// Onboarding profili için soyut kontrat.
abstract class UserProfileRepository {
  Future<UserProfile> load();
  Future<void> save({
    required String name,
    required List<String> goals,
    required int mascotIndex,
  });
}
