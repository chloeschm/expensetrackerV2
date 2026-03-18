import 'package:expense_tracker_v2/features/expenses/domain/expense.dart';
import 'package:expense_tracker_v2/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '..//../providers/expense_providers.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'add_expense_args.dart';
import '../widgets/action_button.dart';
import '../../../../core/widgets/label.dart';
import '../../../../core/services/ai_expense_parser.dart';
import '../widgets/ai_parse_dialog.dart';

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
  final _aiController = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.food;
  DateTime _date = DateTime.now();
  String? _notes;
  bool _isLoading = false;
  AddExpenseArgs? _args;

  bool get _isEditing => _args?.existingExpense != null;

  static const _currencies = ['USD', 'EUR', 'AUD', 'GBP', 'JPY', 'CNY', 'INR'];

  static const _categoryMeta = {
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
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _aiController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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

 Future<void> _showAiDialog() async {
  await showAiParseDialog(
    context,
    onParse: (input) => _parseNaturalLanguage(input),
  );
}

  Future<void> _parseNaturalLanguage(String input) async {
    setState(() => _isLoading = true);
    try {
      final parsed = await AiExpenseParser.parseText(input);
      if (parsed != null) _fillFormFromParsed(parsed);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not parse: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _scanReceipt() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;
    setState(() => _isLoading = true);
    try {
      final parsed = await AiExpenseParser.scanReceipt(source);
      if (parsed != null) {
        _fillFormFromParsed(parsed);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receipt scanned — please review')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not scan receipt: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<ImageSource?> _showImageSourceDialog() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: AppTheme.primary,
              ),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: AppTheme.primary,
              ),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ActionButton(
                          icon: Icons.auto_awesome_rounded,
                          label: 'AI Parse Text',
                          onTap: _isLoading ? null : _showAiDialog,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ActionButton(
                          icon: Icons.receipt_long_rounded,
                          label: 'Scan Receipt',
                          onTap: _isLoading ? null : _scanReceipt,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Label(text: 'Title'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: _inputDecoration('What did you buy?'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Please enter a title' : null,
                    onChanged: (v) => setState(() => _title = v),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Label(text: 'Amount'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _amountController,
                              decoration: _inputDecoration('\$ 0.00'),
                              keyboardType: TextInputType.number,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                              onChanged: (v) => setState(
                                () => _amount = double.tryParse(v) ?? 0.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Label(text: 'Currency'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              key: ValueKey(_currency),
                              initialValue: _currency,
                              decoration: _inputDecoration(''),
                              items: _currencies
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => _currency = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Label(text: 'Date'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('MMM d, y').format(_date),
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Label(text: 'Category'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ExpenseCategory.values.map((cat) {
                      final meta = _categoryMeta[cat]!;
                      final selected = _category == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _category = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primary
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                meta.icon,
                                size: 16,
                                color: selected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                meta.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  Label(text: 'Notes (Optional)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    decoration: _inputDecoration(
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
                      onPressed: _isLoading ? null : _submit,
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
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
    filled: true,
    fillColor: const Color(0xFFF3F4F6),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
}
