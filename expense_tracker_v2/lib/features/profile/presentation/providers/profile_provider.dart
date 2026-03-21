import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_notifier.dart';
import '../../domain/profile.dart';

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfile>(
      UserProfileNotifier.new,
    );
