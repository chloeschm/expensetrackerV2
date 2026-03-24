import 'package:expense_tracker_v2/features/auth/data/firebase_auth_repository.dart';
import 'package:expense_tracker_v2/features/auth/domain/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_notifier.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final authProvider = NotifierProvider<AuthNotifier, String?>(AuthNotifier.new);
