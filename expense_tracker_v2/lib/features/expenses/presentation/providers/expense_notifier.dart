import 'dart:async';

import 'package:expense_tracker_v2/features/expenses/domain/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_providers.dart';

class ExpenseNotifier extends AsyncNotifier<List<Expense>> {
  ExpenseNotifier(this.tripId);
  final String tripId;

  @override
  Future<List<Expense>> build() async {
    final repo = ref.read(expenseRepositoryProvider);

    final completer = Completer<List<Expense>>();

    final sub = repo
        .getExpensesForTrip(tripId)
        .listen(
          (expenses) {
            if (!completer.isCompleted) {
              completer.complete(expenses);
            } else {
              state = AsyncData(expenses);
            }
          },
          onError: (e) {
            if (!completer.isCompleted) completer.completeError(e);
          },
        );

    ref.onDispose(sub.cancel);
    return completer.future;
  }

  Future<void> addExpense(Expense expense) async {
    await ref.read(expenseRepositoryProvider).addExpense(expense, tripId);
  }

  Future<void> deleteExpense(Expense expense) async {
    state = const AsyncLoading();
    await ref.read(expenseRepositoryProvider).deleteExpense(expense, tripId);
  }

  Future<void> updateExpense(Expense expense) async {
    state = const AsyncLoading();
    await ref.read(expenseRepositoryProvider).updateExpense(expense, tripId);
  }
}
