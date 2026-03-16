import 'expense.dart';

abstract class ExpenseRepository {
  Future<Expense?> getExpense(String id, String tripId);
  Stream<List<Expense>> getExpensesForTrip(String tripId);
  Future<void> addExpense(Expense expense, String tripId);
  Future<void> updateExpense(Expense expense, String tripId);
  Future<void> deleteExpense(String tripId, Expense expense);
}