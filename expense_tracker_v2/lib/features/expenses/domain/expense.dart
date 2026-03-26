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
    this.id = '',
    required this.title,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
    this.notes,
    required this.addedBy,
  });
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? currency,
    ExpenseCategory? category,
    DateTime? date,
    String? notes,
    String? addedBy,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      addedBy: addedBy ?? this.addedBy,
    );
  }
}
