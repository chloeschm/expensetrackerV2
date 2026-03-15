import 'trip.dart';

abstract class TripRepository {
  Future<Trip?> getTrip(String tripId);
  Stream<List<Trip>> getTrips(String userId);
  Future<void> addTrip(Trip trip);
  Future<void> updateTrip(Trip trip);
  Future<void> deleteTrip(String id);
  Future<void> joinTripByCode(String code, String userId);
  Stream<Trip?> getTripStream(String tripId);
}