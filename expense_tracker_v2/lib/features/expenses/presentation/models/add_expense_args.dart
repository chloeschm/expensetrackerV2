import '../../domain/expense.dart';

class AddExpenseArgs {
  final String tripId;
  final Expense? existingExpense;

  const AddExpenseArgs({required this.tripId, this.existingExpense});
}