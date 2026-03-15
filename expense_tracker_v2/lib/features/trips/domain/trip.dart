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
    required this.id,
    required this.name,
    required this.destination,
    required this.startDate,
    this.endDate,
    required this.budget,
    this.currency = 'USD',
    List<Expense>? expenses,
    required this.joinCode,
    required this.createdBy,
  }) : members = members ?? [],
       expenses = expenses ?? [];

  double get totalSpent => expenses.fold(0, (sum, e) => sum + e.amount);
  double get remaining => budget - totalSpent;
}
