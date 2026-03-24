import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/profile.dart';
import '../../domain/profile_repository.dart';
import 'profile_providers.dart';

class UserProfileNotifier extends AsyncNotifier<UserProfile> {
  late final ProfileRepository _repository;
  String get _userId => ref.read(authProvider)!;

  @override
  Future<UserProfile> build() async {
    _repository = ref.read(profileRepositoryProvider);

    final fetched = await _repository.fetchProfile(_userId);

    if (fetched.displayName.isEmpty) {
      final email = FirebaseAuth.instance.currentUser?.email ?? '';
      final displayName = email.split('@').first;
      await saveProfile(displayName, 'USD');
      return UserProfile(displayName: displayName, preferredCurrency: 'USD');
    }

    return fetched;
  }

  Future<void> saveProfile(String name, String currency) async {
    await _repository.saveProfile(_userId, name, currency);
    state = AsyncData(UserProfile(displayName: name, preferredCurrency: currency));
  }
}