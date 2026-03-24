import '../domain/profile.dart';

abstract interface class ProfileRepository {
  Future<UserProfile> fetchProfile(String userId);
  Future<void> saveProfile(String userId, String displayName, String preferredCurrency);
}