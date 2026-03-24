import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_notifier.dart';
import '../../domain/profile.dart';
import '../../data/profile_repository_impl.dart';
import '../../domain/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfile>(
      UserProfileNotifier.new,
    );