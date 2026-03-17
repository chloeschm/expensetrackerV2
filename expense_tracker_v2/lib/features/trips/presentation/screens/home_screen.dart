import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/trip_providers.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/trip_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void _showJoinDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Join a Trip',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter code e.g. TR-4X9K',
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(tripNotifierProvider.notifier)
                    .joinTrip(controller.text);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(
                    ctx,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(tripNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_outlined),
            tooltip: 'Join a trip',
            onPressed: () => _showJoinDialog(context),
          ),
        ],
      ),
      body: tripsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (trips) => trips.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 100),
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  return TripCard(
                    trip: trip,
                    onTap: () => context.push('/home/trips/${trip.id}'),
                    onEdit: () => context.push('/add_trip', extra: trip),
                    onDelete: () => ref
                        .read(tripNotifierProvider.notifier)
                        .deleteTrip(trip.id),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.flight_takeoff_rounded,
              size: 36,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No trips yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Plan your first adventure',
            style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
