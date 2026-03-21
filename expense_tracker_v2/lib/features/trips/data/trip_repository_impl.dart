import 'package:expense_tracker_v2/features/trips/domain/trip.dart';
import 'package:expense_tracker_v2/features/trips/domain/trip_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../expenses/domain/expense.dart';

class TripRepositoryImpl implements TripRepository {
  final FirebaseFirestore _firestore;
  TripRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return 'TR-${List.generate(4, (_) => chars[rand.nextInt(chars.length)]).join()}';
  }

  Expense _expenseFromMap(Map<String, dynamic> map, String id) {
    return Expense(
      id: id,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      currency: map['currency'] as String,
      addedBy: map['addedBy'] as String,
      category: ExpenseCategory.values.byName(map['category']),
      notes: map['notes'] as String?,
    );
  }

  Trip _tripFromDoc(DocumentSnapshot doc) {
    return Trip(
      id: doc.id,
      name: doc['name'],
      destination: doc['destination'],
      startDate: (doc['startDate'] as Timestamp).toDate(),
      endDate: doc['endDate'] != null
          ? (doc['endDate'] as Timestamp).toDate()
          : null,
      budget: doc['budget'].toDouble(),
      currency: doc['currency'] ?? 'USD',
      joinCode: doc['joinCode'],
      createdBy: doc['createdBy'],
      members: List<String>.from(doc['members'] ?? []),
      expenses: (doc['expenses'] as List<dynamic>? ?? [])
          .map(
            (e) => _expenseFromMap(
              e as Map<String, dynamic>,
              e['id'] as String? ?? '',
            ),
          )
          .toList(),
    );
  }

  @override
  Future<Trip?> getTrip(String tripId) async {
    final doc = await _firestore.collection('trips').doc(tripId).get();
    if (doc.exists) {
      return _tripFromDoc(doc);
    } else {
      return null;
    }
  }

  @override
  Future<void> addTrip(Trip trip) async {
    final docRef = _firestore.collection('trips').doc();

    await docRef.set({
      'name': trip.name,
      'destination': trip.destination,
      'startDate': Timestamp.fromDate(trip.startDate),
      'endDate': trip.endDate != null
          ? Timestamp.fromDate(trip.endDate!)
          : null,
      'budget': trip.budget,
      'currency': trip.currency,
      'joinCode': _generateJoinCode(),
      'createdBy': trip.createdBy,
      'members': trip.members,
      'expenses': trip.expenses,
    });
  }

  @override
  Future<void> deleteTrip(String id) async {
    await _firestore.collection('trips').doc(id).delete();
  }

  @override
  Future<void> joinTripByCode(String code, String userId) async {
    final query = await _firestore
        .collection('trips')
        .where('joinCode', isEqualTo: code)
        .get();
    if (query.docs.isNotEmpty) {
      final tripDoc = query.docs.first;
      final tripId = tripDoc.id;
      await _firestore.collection('trips').doc(tripId).update({
        'members': FieldValue.arrayUnion([userId]),
      });
    } else {
      throw Exception('Invalid join code');
    }
  }

  @override
  Future<void> updateTrip(Trip trip) async {
    await _firestore.collection('trips').doc(trip.id).update({
      'name': trip.name,
      'destination': trip.destination,
      'startDate': Timestamp.fromDate(trip.startDate),
      'endDate': trip.endDate != null
          ? Timestamp.fromDate(trip.endDate!)
          : null,
      'budget': trip.budget,
      'currency': trip.currency,
      'members': trip.members,
      'expenses': trip.expenses,
    });
  }

  @override
  Stream<List<Trip>> getTrips(String userId) {
    return _firestore
        .collection('trips')
        .where('members', arrayContains: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return _tripFromDoc(doc);
          }).toList(),
        );
  }

  @override
  Stream<Trip?> getTripStream(String tripId) {
    return _firestore.collection('trips').doc(tripId).snapshots().map((doc) {
      if (doc.exists) {
        return _tripFromDoc(doc);
      } else {
        return null;
      }
    });
  }
}
