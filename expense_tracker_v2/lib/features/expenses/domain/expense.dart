enum ExpenseCategory {
  food,
  transport,
  accommodation,
  activities,
  shopping,
  health,
  other,
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final String currency;
  final ExpenseCategory category;
  final DateTime date;
  final String? notes;
  final String addedBy;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
    this.notes,
    required this.addedBy,
  });
}
