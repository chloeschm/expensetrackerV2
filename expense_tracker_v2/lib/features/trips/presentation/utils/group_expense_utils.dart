import '../../../expenses/domain/expense.dart';

  Map<ExpenseCategory, List<Expense>> groupExpenses(List<Expense> expenses) {
    final grouped = <ExpenseCategory, List<Expense>>{};
    for (final e in expenses) {
      grouped.putIfAbsent(e.category, () => []).add(e);
    }
    return grouped;
  }