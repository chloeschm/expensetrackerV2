import 'package:expense_tracker_v2/features/expenses/domain/expense_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker_v2/features/expenses/domain/expense.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final FirebaseFirestore _firestore;
  ExpenseRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Expense _expenseFromMap(Map<String, dynamic> map, String documentId) {
    return Expense(
      id: documentId,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      currency: map['currency'] as String,
      addedBy: map['addedBy'] as String,
      category: ExpenseCategory.values.byName(map['category']),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> _expenseToMap(Expense expense) {
    return {
      'id': expense.id,
      'title': expense.title,
      'amount': expense.amount,
      'date': expense.date,
      'currency': expense.currency,
      'addedBy': expense.addedBy,
      'category': expense.category.name,
      'notes': expense.notes,
    };
  }

  @override
  Future<void> addExpense(Expense expense, String tripId) async {
    DocumentReference tripRef = _firestore.collection('trips').doc(tripId);
    await tripRef.update({
      'expenses': FieldValue.arrayUnion([_expenseToMap(expense)]),
    });
  }

  @override
  Future<void> deleteExpense(Expense expense, String tripId) async {
    DocumentReference tripRef = _firestore.collection('trips').doc(tripId);
    await tripRef.update({
      'expenses': FieldValue.arrayRemove([_expenseToMap(expense)]),
    });
  }

  @override
  Future<void> updateExpense(Expense expense, String tripId) async {
    final docRef = _firestore.collection('trips').doc(tripId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception("Document does not exist!");
      List<dynamic> expenses = List.from(snapshot.get('expenses'));

      final updatedExpenses = expenses.map((e) {
        final map = e as Map<String, dynamic>;
        if (map['id'] == expense.id) {
          return _expenseToMap(expense);
        }
        return map;
      }).toList();
      transaction.update(docRef, {'expenses': updatedExpenses});
    });
  }

  @override
  Stream<List<Expense>> getExpensesForTrip(String tripId) {
    return _firestore.collection('trips').doc(tripId).snapshots().map((
      snapshot,
    ) {
      List<dynamic> expensesData = snapshot.get('expenses') ?? [];
      return expensesData
          .map(
            (data) => _expenseFromMap(
              data as Map<String, dynamic>,
              data['id'] as String,
            ),
          )
          .toList();
    });
  }

  @override
  Future<Expense?> getExpense(String id, String tripId) async {
    final expensesList = await getExpensesForTrip(tripId).first;
    try {
      return expensesList.firstWhere((expense) => expense.id == id);
    } catch (e) {
      return null;
    }
  }
}
