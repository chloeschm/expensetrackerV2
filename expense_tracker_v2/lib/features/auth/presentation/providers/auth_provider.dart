import 'package:expense_tracker_v2/routing/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRouterNotifier extends ChangeNotifier {
  String? userId;

  void updateUser(String? id) {
    userId = id;
    notifyListeners();
  }
}

final authProvider = NotifierProvider<AuthNotifier, String?>(AuthNotifier.new);
