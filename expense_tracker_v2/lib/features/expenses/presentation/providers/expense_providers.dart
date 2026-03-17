import 'package:expense_tracker_v2/features/expenses/domain/expense.dart';
import 'package:expense_tracker_v2/features/expenses/domain/expense_repository.dart';
import 'package:expense_tracker_v2/features/expenses/data/expense_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl();
});

final expensesProvider = StreamProvider.family<List<Expense>, String>((ref, tripId) {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getExpensesForTrip(tripId);
});

class ExpenseNotifier extends AsyncNotifier<List<Expense>> {
  ExpenseNotifier(this.tripId);
  final String tripId;

  @override
  Future<List<Expense>> build() async {
    final repo = ref.read(expenseRepositoryProvider);
    return await repo.getExpensesForTrip(tripId).first;
  }

  Future<void> addExpense(Expense expense) async {
    state = const AsyncLoading();
    await ref.read(expenseRepositoryProvider).addExpense(expense, tripId);
    ref.invalidateSelf();
  }

  Future<void> deleteExpense(Expense expense) async {
    state = const AsyncLoading();
    await ref.read(expenseRepositoryProvider).deleteExpense(expense, tripId);
    ref.invalidateSelf();
  }
}

final expenseNotifierProvider = AsyncNotifierProvider.family<ExpenseNotifier, List<Expense>, String>(
  ExpenseNotifier.new,
);