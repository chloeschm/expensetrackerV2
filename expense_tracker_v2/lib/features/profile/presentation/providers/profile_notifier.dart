import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/profile.dart';

class UserProfileNotifier extends AsyncNotifier<UserProfile> {
  final _db = FirebaseFirestore.instance;
  String get _userId => ref.read(authProvider)!;
  @override
  Future<UserProfile> build() async {
    final doc = await _db.collection('users').doc(_userId).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      return UserProfile(
        displayName: data['displayName'] as String? ?? 'Traveler',
        preferredCurrency: data['preferredCurrency'] as String? ?? 'USD',
      );
    } else {
      final email = FirebaseAuth.instance.currentUser?.email ?? '';
      final displayName = email.split('@').first;
      await saveProfile(displayName, 'USD');
      return UserProfile(displayName: displayName, preferredCurrency: 'USD');
    }
  }

  Future<void> saveProfile(String name, String currency) async {
    await _db.collection('users').doc(_userId).set({
      'displayName': name,
      'preferredCurrency': currency,
    }, SetOptions(merge: true));
    state = AsyncData(
      UserProfile(displayName: name, preferredCurrency: currency),
    );
  }
}
