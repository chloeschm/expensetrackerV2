import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/trip_providers.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../expenses/presentation/widgets/expense_list_item.dart';
import '../utils/expense_category_utils.dart';
import '../utils/group_expense_utils.dart';
import '../widgets/trip_detail_header.dart';
import '../widgets/budget_progress_card.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  const TripDetailScreen({super.key});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  final _currencyService = CurrencyService();
  bool _ratesLoaded = false;

  @override
  void initState() {
    super.initState();    
  }

  @override
  Widget build(BuildContext context) {
    final tripId = GoRouterState.of(context).pathParameters['tripId']!;
    final tripsAsync = ref.watch(tripNotifierProvider);
    final currentTrip = tripsAsync
        .whenData((trips) => trips.firstWhere((t) => t.id == tripId))
        .value;
    if (currentTrip == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_ratesLoaded) {
      _currencyService.fetchRates(currentTrip.currency).then((_) {
        if (mounted) setState(() => _ratesLoaded = true);
      });
    }

    final grouped = groupExpenses(currentTrip.expenses);

    double totalSpent = 0;
    if (_ratesLoaded) {
      totalSpent = currentTrip.expenses
          .map(
            (e) => _currencyService.convert(
              e.amount,
              e.currency,
              currentTrip.currency,
            ),
          )
          .fold(0.0, (s, a) => s + a);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Trip Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => context.push('/home/trips/$tripId/summary'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          const SizedBox(height: 20),

          TripDetailHeader(trip: currentTrip),
          const SizedBox(height: 20),
          BudgetProgressCard(
            trip: currentTrip,
            totalSpent: totalSpent,
            ratesLoaded: _ratesLoaded,
          ),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/home/trips/$tripId/expenses/new'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text(
                'Add New Expense',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (currentTrip.expenses.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 30,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No expenses yet',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tap the button above to add one',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ...grouped.entries.map((entry) {
              final cat = entry.key;
              final expenses = entry.value;
              final categoryTotal = _ratesLoaded
                  ? expenses
                        .map(
                          (e) => _currencyService.convert(
                            e.amount,
                            e.currency,
                            currentTrip.currency,
                          ),
                        )
                        .fold(0.0, (s, a) => s + a)
                  : 0.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          categoryIcon(cat),
                          size: 18,
                          color: categoryColor(cat),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          categoryLabel(cat),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (_ratesLoaded)
                          Text(
                            '${currentTrip.currency} ${categoryTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),

                  ...expenses.map(
                    (expense) => ExpenseListItem(
                      expense: expense,
                      tripId: currentTrip.id,
                      currency: currentTrip.currency,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }),
        ],
      ),
    );
  }
}
