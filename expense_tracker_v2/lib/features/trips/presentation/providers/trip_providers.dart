import 'package:expense_tracker_v2/features/trips/domain/trip.dart';
import 'package:expense_tracker_v2/features/trips/domain/trip_repository.dart';
import 'package:expense_tracker_v2/features/trips/data/trip_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'trip_notifier.dart';

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

final tripNotifierProvider = AsyncNotifierProvider<TripNotifier, List<Trip>>(
  TripNotifier.new,
);
