import 'dart:async';

import 'package:expense_tracker_v2/features/trips/domain/trip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'trip_providers.dart';

class TripNotifier extends AsyncNotifier<List<Trip>> {
  @override
  Future<List<Trip>> build() async {
    final userId = ref.watch(authProvider);
    if (userId == null) return [];
    final repo = ref.read(tripRepositoryProvider);

    final completer = Completer<List<Trip>>();

    final sub = repo
        .getTrips(userId)
        .listen(
          (trips) {
            if (!completer.isCompleted) {
              completer.complete(trips);
            } else {
              state = AsyncData(trips);
            }
          },
          onError: (e) {
            if (!completer.isCompleted) completer.completeError(e);
          },
        );

    ref.onDispose(sub.cancel);

    return completer.future;
  }

  Future<void> addTrip(Trip trip) async {
    await ref.read(tripRepositoryProvider).addTrip(trip);
  }

  Future<void> deleteTrip(String tripId) async {
    await ref.read(tripRepositoryProvider).deleteTrip(tripId);
  }

  Future<void> joinTrip(String code) async {
    final userId = ref.read(authProvider);
    if (userId == null) throw Exception('Not logged in');
    await ref.read(tripRepositoryProvider).joinTripByCode(code, userId);
  }

  Future<void> updateTrip(Trip trip) async {
    await ref.read(tripRepositoryProvider).updateTrip(trip);
  }
}