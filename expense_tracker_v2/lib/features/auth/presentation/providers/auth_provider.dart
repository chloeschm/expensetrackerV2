import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRouterNotifier extends ChangeNotifier {
  String? userId;

  void updateUser(String? id) {
    userId = id;
    notifyListeners();
  }
}

class AuthNotifier extends Notifier<String?> {
  @override
  String? build() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> login(String email, String password) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    state = credential.user?.uid;
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    state = null;
  }

  Future<void> register(String email, String password) async {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    state = credential.user?.uid;
  }
}
final authProvider = NotifierProvider<AuthNotifier, String?>(AuthNotifier.new);


