import 'package:flutter/material.dart';
import '../../../expenses/domain/expense.dart';
 
 Color categoryColor(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.food:
        return const Color(0xFFF97316);
      case ExpenseCategory.transport:
        return const Color(0xFF3B82F6);
      case ExpenseCategory.accommodation:
        return const Color(0xFF8B5CF6);
      case ExpenseCategory.activities:
        return const Color(0xFF10B981);
      case ExpenseCategory.shopping:
        return const Color(0xFFEC4899);
      case ExpenseCategory.health:
        return const Color(0xFFEF4444);
      case ExpenseCategory.other:
        return const Color(0xFF9CA3AF);
    }
  }

  IconData categoryIcon(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.transport:
        return Icons.directions_car_rounded;
      case ExpenseCategory.accommodation:
        return Icons.hotel_rounded;
      case ExpenseCategory.activities:
        return Icons.local_activity_rounded;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_rounded;
      case ExpenseCategory.health:
        return Icons.medical_services_rounded;
      case ExpenseCategory.other:
        return Icons.category_rounded;
    }
  }

  String categoryLabel(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.food:
        return 'Food & Dining';
      case ExpenseCategory.transport:
        return 'Transportation';
      case ExpenseCategory.accommodation:
        return 'Accommodation';
      case ExpenseCategory.activities:
        return 'Activities';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.health:
        return 'Health';
      case ExpenseCategory.other:
        return 'Other';
    }
  }