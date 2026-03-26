import 'package:expense_tracker_v2/core/services/currency_service.dart';
import 'package:expense_tracker_v2/features/expenses/domain/expense.dart';
import 'package:expense_tracker_v2/features/trips/domain/trip.dart';

Map<ExpenseCategory, double> getCategoryTotals(
  Trip trip,
  CurrencyService currencyService,
) {
  final totals = <ExpenseCategory, double>{};
  for (final expense in trip.expenses) {
    final converted = currencyService.convert(
      expense.amount,
      expense.currency,
      trip.currency,
    );
    totals[expense.category] = (totals[expense.category] ?? 0) + converted;
  }
  return totals;
}
