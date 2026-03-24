import 'package:expense_tracker_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../domain/auth_repository.dart';

class AuthRouterNotifier extends ChangeNotifier {
  String? userId;

  void updateUser(String? id) {
    userId = id;
    notifyListeners();
  }
}

class AuthNotifier extends Notifier<String?> {
  late final AuthRepository _authRepository;

  @override
  String? build() {
    _authRepository = ref.read(authRepositoryProvider);

    final sub = _authRepository.authStateChanges.listen((uid) {
      state = uid;
    });
    ref.onDispose(sub.cancel);

    return _authRepository.currentUserId;
  }

  Future<void> login(String email, String password) async {
    await _authRepository.login(email, password);
  }

  Future<void> logout() async {
    await _authRepository.logout();
  }

  Future<void> register(String email, String password) async {
    await _authRepository.register(email, password);
  }
}
