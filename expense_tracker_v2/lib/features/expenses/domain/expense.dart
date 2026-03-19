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

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String? ?? '',
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String,
      category: ExpenseCategory.values.byName(map['category'] as String),
      date: map['date'] as DateTime,
      notes: map['notes'] as String?,
      addedBy: map['addedBy'] as String,
    );
  }
}
