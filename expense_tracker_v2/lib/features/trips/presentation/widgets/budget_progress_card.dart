import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../../domain/trip.dart';

class BudgetProgressCard extends StatelessWidget {
  const BudgetProgressCard({
    super.key,
    required this.trip,
    required this.totalSpent,
    required this.ratesLoaded,
  });
  final Trip trip;
  final double totalSpent;
  final bool ratesLoaded;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'TOTAL BUDGET',
                value: '${trip.currency} ${trip.budget.toStringAsFixed(2)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'TOTAL SPENT',
                value: ratesLoaded
                    ? '${trip.currency} ${totalSpent.toStringAsFixed(2)}'
                    : '...',
                valueColor: ratesLoaded && totalSpent > trip.budget
                    ? AppTheme.error
                    : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (ratesLoaded && trip.budget > 0) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (totalSpent / trip.budget).clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(
                totalSpent >= trip.budget ? AppTheme.error : AppTheme.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            totalSpent <= trip.budget
                ? '${trip.currency} ${(trip.budget - totalSpent).toStringAsFixed(2)} remaining'
                : '${trip.currency} ${(totalSpent - trip.budget).toStringAsFixed(2)} over budget',
            style: TextStyle(
              fontSize: 12,
              color: totalSpent > trip.budget
                  ? AppTheme.error
                  : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}
