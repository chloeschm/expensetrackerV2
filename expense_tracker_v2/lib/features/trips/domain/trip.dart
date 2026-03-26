import '../../expenses/domain/expense.dart';

class Trip {
  final String id;
  final String name;
  final String destination;
  final DateTime startDate;
  final DateTime? endDate;
  final double budget;
  final String currency;
  final List<Expense> expenses;
  final String joinCode;
  final List<String> members;
  final String createdBy;

  Trip({
    List<String>? members,
    this.id = '',
    required this.name,
    required this.destination,
    required this.startDate,
    this.endDate,
    required this.budget,
    this.currency = 'USD',
    List<Expense>? expenses,
    this.joinCode = '',
    required this.createdBy,
  }) : members = members ?? [],
       expenses = expenses ?? [];
       
  Trip copyWith({
    String? id,
    String? name,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    String? currency,
    List<Expense>? expenses,
    String? joinCode,
    List<String>? members,
    String? createdBy,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      currency: currency ?? this.currency,
      expenses: expenses ?? this.expenses,
      joinCode: joinCode ?? this.joinCode,
      members: members ?? this.members,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  double get totalSpent => expenses.fold(0, (sum, e) => sum + e.amount);
  double get remaining => budget - totalSpent;
}
