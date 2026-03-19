import 'package:expense_tracker_v2/features/trips/presentation/providers/trip_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/profile_provider.dart';
import '../widgets/stat_item.dart';
import '../widgets/edit_form_card.dart';
import '../widgets/profile_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final tripsAsync = ref.watch(tripNotifierProvider);
    final trips = tripsAsync.value ?? [];

    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value;
    final displayName = profile?.displayName ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(displayName: displayName, email: email),

            const SizedBox(height: 32),

            const EditFormCard(),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: StatItem(label: 'Trips', value: '${trips.length}'),
                  ),
                  Container(width: 1, height: 40, color: AppTheme.border),
                  Expanded(
                    child: StatItem(
                      label: 'Expenses',
                      value:
                          '${trips.fold(0, (sum, t) => sum + t.expenses.length)}',
                    ),
                  ),
                  Container(width: 1, height: 40, color: AppTheme.border),
                  Expanded(
                    child: StatItem(
                      label: 'Currency',
                      value: profile?.preferredCurrency ?? 'USD',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => FirebaseAuth.instance.signOut(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: BorderSide(color: AppTheme.error.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
