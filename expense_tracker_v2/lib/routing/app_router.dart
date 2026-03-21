import 'package:expense_tracker_v2/features/auth/presentation/providers/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/expenses/presentation/screens/add_expense_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/trips/presentation/screens/add_trip_screen.dart';
import '../features/trips/presentation/screens/trip_detail_screen.dart';
import '../features/trips/presentation/screens/trip_summary_screen.dart';
import '../features/trips/presentation/screens/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = AuthRouterNotifier();

  notifier.updateUser(ref.read(authProvider));

  ref.listen<String?>(authProvider, (previous, next) {
    notifier.updateUser(next);
  });

  ref.onDispose(notifier.dispose);

  return GoRouter(
    redirect: (BuildContext context, GoRouterState state) {
      final bool isSignedIn = notifier.userId != null;
      final bool onSigninPage = state.matchedLocation == '/login';

      if (!isSignedIn && !onSigninPage) return '/login';
      if (isSignedIn && onSigninPage) return '/home';

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
                    builder: (context, state) => TripDetailScreen(
                      tripId: state.pathParameters['tripId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: "summary",
                        builder: (context, state) => TripSummaryScreen(
                          tripId: state.pathParameters['tripId']!,
                        ),
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
                1,
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
