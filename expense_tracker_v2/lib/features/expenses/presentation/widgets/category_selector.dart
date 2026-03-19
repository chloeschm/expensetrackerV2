import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/expense.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ExpenseCategory selected;
  final ValueChanged<ExpenseCategory> onChanged;

  static const categoryMeta = {
    ExpenseCategory.food: (icon: Icons.restaurant_rounded, label: 'Food'),
    ExpenseCategory.transport: (
      icon: Icons.directions_car_rounded,
      label: 'Transport',
    ),
    ExpenseCategory.accommodation: (icon: Icons.hotel_rounded, label: 'Hotel'),
    ExpenseCategory.activities: (
      icon: Icons.local_activity_rounded,
      label: 'Activities',
    ),
    ExpenseCategory.shopping: (
      icon: Icons.shopping_bag_rounded,
      label: 'Shopping',
    ),
    ExpenseCategory.health: (
      icon: Icons.medical_services_rounded,
      label: 'Health',
    ),
    ExpenseCategory.other: (icon: Icons.category_rounded, label: 'Other'),
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ExpenseCategory.values.map((cat) {
        final meta = categoryMeta[cat]!;
        final isSelected = selected == cat;
        return GestureDetector(
          onTap: () => onChanged(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  meta.icon,
                  size: 16,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  meta.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
