import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/profile.dart';
import '../domain/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _db;

  ProfileRepositoryImpl({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<UserProfile> fetchProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      return UserProfile(
        displayName: data['displayName'] as String? ?? 'Traveler',
        preferredCurrency: data['preferredCurrency'] as String? ?? 'USD',
      );
    }
    return UserProfile(displayName: '', preferredCurrency: 'USD');
  }

  @override
  Future<void> saveProfile(
    String userId,
    String displayName,
    String preferredCurrency,
  ) async {
    await _db.collection('users').doc(userId).set({
      'displayName': displayName,
      'preferredCurrency': preferredCurrency,
    }, SetOptions(merge: true));
  }
}