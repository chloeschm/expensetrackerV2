abstract class AuthRepository {
  Stream<String?> get authStateChanges;
  String? get currentUserId;
  Future<void> login(String email, String password);
  Future<void> register(String email, String password);
  Future<void> logout();
}