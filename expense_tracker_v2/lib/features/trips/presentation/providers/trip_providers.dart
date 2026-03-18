import 'package:expense_tracker_v2/features/trips/domain/trip.dart';
import 'package:expense_tracker_v2/features/trips/domain/trip_repository.dart';
import 'package:expense_tracker_v2/features/trips/data/trip_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepositoryImpl();
});

final tripProvider = FutureProvider.family<Trip?, String>((ref, tripId) async {
  final repo = ref.watch(tripRepositoryProvider);
  return await repo.getTrip(tripId);
});

final tripsProvider = StreamProvider.family<List<Trip>, String>((ref, userId) {
  final repo = ref.watch(tripRepositoryProvider);
  return repo.getTrips(userId);
});

class TripNotifier extends AsyncNotifier<List<Trip>> {
  @override
  Future<List<Trip>> build() async {
    final userId = ref.watch(authProvider);
    if (userId == null) {
      return [];
    }
    final repo = ref.read(tripRepositoryProvider);
    return await repo.getTrips(userId).first;
  }

  Future<void> addTrip(Trip trip) async {
    state = const AsyncLoading();
    await ref.read(tripRepositoryProvider).addTrip(trip);
    ref.invalidateSelf();
  }

  Future<void> deleteTrip(String tripId) async {
    state = const AsyncLoading();
    await ref.read(tripRepositoryProvider).deleteTrip(tripId);
    ref.invalidateSelf();
  }

  Future<void> joinTrip(String code) async {
    state = const AsyncLoading();
    final userId = ref.read(authProvider);
    if (userId == null) throw Exception('Not logged in');
    await ref.read(tripRepositoryProvider).joinTripByCode(code, userId);
    ref.invalidateSelf();
  }

  Future<void> updateTrip(Trip trip) async {
  state = const AsyncLoading();
  await ref.read(tripRepositoryProvider).updateTrip(trip);
  ref.invalidateSelf();
}
}

final tripNotifierProvider = AsyncNotifierProvider<TripNotifier, List<Trip>>(
  TripNotifier.new,
);
