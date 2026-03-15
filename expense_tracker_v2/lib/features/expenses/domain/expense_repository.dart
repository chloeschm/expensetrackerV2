import 'expense.dart';

abstract class ExpenseRepository {
  Future<Expense?> getExpense(String id);
  Stream<List<Expense>> getExpensesForTrip(String tripId);
  Future<void> addExpense(Expense expense, String tripId);
  Future<void> updateExpense(Expense expense, String tripId);
  Future<void> deleteExpense(String id, String tripId);
}