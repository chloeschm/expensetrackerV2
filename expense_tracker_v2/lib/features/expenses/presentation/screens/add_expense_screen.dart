import 'package:expense_tracker_v2/features/expenses/domain/expense.dart';
import 'package:expense_tracker_v2/features/expenses/presentation/widgets/ai_actions_row.dart';
import 'package:expense_tracker_v2/features/expenses/presentation/widgets/category_selector.dart';
import 'package:expense_tracker_v2/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '..//../providers/expense_providers.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'add_expense_args.dart';
import '../../../../core/widgets/label.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/amount_currency_row.dart';
import '../../../../core/utils/input_decoration.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  double _amount = 0.0;
  String _currency = 'USD';
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.food;
  DateTime _date = DateTime.now();
  String? _notes;
  AddExpenseArgs? _args;

  bool get _isEditing => _args?.existingExpense != null;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    _args = GoRouterState.of(context).extra as AddExpenseArgs;

    if (_args?.existingExpense != null) {
      final e = _args!.existingExpense!;
      _titleController.text = e.title;
      _title = e.title;
      _amountController.text = e.amount.toStringAsFixed(2);
      _amount = e.amount;
      _currency = e.currency;
      _category = e.category;
      _date = e.date;
      _notesController.text = e.notes ?? '';
      _notes = e.notes;
    }

    if (!_isEditing) {
      setState(() {
        _currency =
            ref.read(userProfileProvider).value?.preferredCurrency ?? 'USD';
      });
    }
  }

  void _fillFormFromParsed(Map<String, dynamic> parsed) {
    final title = parsed['title'] as String? ?? '';
    final amount = double.tryParse(parsed['amount']?.toString() ?? '') ?? 0.0;
    final currency = parsed['currency'] as String? ?? 'USD';
    final category = ExpenseCategory.values.firstWhere(
      (c) => c.toString().split('.').last == parsed['category'],
      orElse: () => ExpenseCategory.other,
    );
    final date = parsed['date'] != null
        ? DateTime.tryParse(parsed['date']) ?? DateTime.now()
        : DateTime.now();
    setState(() {
      _title = title;
      _amount = amount;
      _currency = currency;
      _category = category;
      _date = date;
      _titleController.text = title;
      _amountController.text = amount.toStringAsFixed(2);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_isEditing) {
      ref
          .read(expenseNotifierProvider(_args!.tripId).notifier)
          .updateExpense(
            Expense(
              id: _args!.existingExpense!.id,
              title: _title,
              amount: _amount,
              currency: _currency,
              category: _category,
              date: _date,
              notes: _notes,
              addedBy: _args!.existingExpense!.addedBy,
            ),
          );
    } else {
      ref
          .read(expenseNotifierProvider(_args!.tripId).notifier)
          .addExpense(
            Expense(
              title: _title,
              amount: _amount,
              currency: _currency,
              category: _category,
              date: _date,
              notes: _notes,
              addedBy:
                  ref.read(userProfileProvider).value?.displayName ?? 'Unknown',
            ),
          );
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Expense' : 'Add Expense',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AiActionsRow(onParsed: (parsed) => _fillFormFromParsed(parsed)),

              const SizedBox(height: 24),

              Label(text: 'Title'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: appInputDecoration('What did you buy?'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter a title' : null,
                onChanged: (v) => setState(() => _title = v),
              ),
              const SizedBox(height: 20),

              AmountCurrencyRow(
                amount: _amount,
                currency: _currency,
                onAmountChanged: (v) =>
                    setState(() => _amount = double.tryParse(v) ?? 0.0),
                onCurrencyChanged: (v) => setState(() => _currency = v),
                amountController: _amountController,
              ),

              const SizedBox(height: 20),

              Label(text: 'Date'),
              const SizedBox(height: 8),

              DatePickerField(
                date: _date,
                onChanged: (picked) => setState(() => _date = picked),
              ),

              const SizedBox(height: 20),

              Label(text: 'Category'),
              const SizedBox(height: 12),
              CategorySelector(
                selected: _category,
                onChanged: (cat) => setState(() => _category = cat),
              ),

              const SizedBox(height: 20),

              Label(text: 'Notes (Optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: appInputDecoration(
                  'Add details about this expense...',
                ),
                maxLines: 3,
                onChanged: (v) => setState(() => _notes = v),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: Text(
                    _isEditing ? 'Save Changes' : 'Save Expense',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
