import 'package:expense_tracker_v2/features/expenses/domain/expense.dart';
import 'package:expense_tracker_v2/features/expenses/domain/expense_repository.dart';
import 'package:expense_tracker_v2/features/expenses/data/expense_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_notifier.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl();
});

final expensesProvider = StreamProvider.family<List<Expense>, String>((
  ref,
  tripId,
) {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getExpensesForTrip(tripId);
});

final expenseNotifierProvider =
    AsyncNotifierProvider.family<ExpenseNotifier, List<Expense>, String>(
      ExpenseNotifier.new,
    );