import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/add_expense_screen.dart'2;
import '../screens/add_trip_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/trip_detail_screen.dart';
import '../screens/trip_summary_screen.dart';
import '../screens/login_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = AuthRouterNotifier();
  ref.listen <String?>(authProvider, (previous, next) {
    notifier.updateUser(next);
  });

  ref.onDispose(notifier.dispose);

  return GoRouter(
    redirect: (BuildContext context, GoRouterState state) {
      final bool isSignedIn = notifier.userId != null;
      final bool onSigninPage = state.matchedLocation == '/login';

      if (!isSignedIn && !onSigninPage) {
        return '/login';
      }

      if (isSignedIn && onSigninPage) {
        return '/home';
      }

      return null;
    },

    refreshListenable: notifier,
    initialLocation: "/home",
    routes: [
      GoRoute(
        path: "/add_trip",
        builder: (context, state) => const AddTripScreen(),
      ),
      GoRoute(path: "/login", builder: (context, state) => const LoginScreen()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithBottomNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/home",
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: "trips/:tripId",
                    builder: (context, state) => const TripDetailScreen(),
                    routes: [
                      GoRoute(
                        path: "summary",
                        builder: (context, state) => const TripSummaryScreen(),
                      ),
                      GoRoute(
                        path: "expenses/new",
                        builder: (context, state) => const AddExpenseScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/profile",
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class ScaffoldWithBottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ScaffoldWithBottomNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              navigationShell.goBranch(
                0,
                initialLocation: index == navigationShell.currentIndex,
              );
              break;
            case 1:
              context.push('/add_trip');
              break;
            case 2:
              navigationShell.goBranch(
                2,
                initialLocation: index == navigationShell.currentIndex,
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add Trip"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class AuthNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  void login(String userId) {
    state = userId;
  }

  void logout() {
    state = null;
  }
}
