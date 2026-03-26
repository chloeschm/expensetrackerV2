import 'package:expense_tracker_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:expense_tracker_v2/features/trips/presentation/providers/trip_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/trip.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../widgets/date_button.dart';
import '../../../../core/widgets/label.dart';
import '../../../../core/utils/input_decoration.dart';

class AddTripScreen extends ConsumerStatefulWidget {
  const AddTripScreen({super.key});
  @override
  ConsumerState<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends ConsumerState<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _currency = 'USD';
  double _budget = 0.0;

  bool get _isEditing => GoRouterState.of(context).extra != null;

  static const _currencies = [
    ('USD', 'USD (\$)'),
    ('EUR', 'EUR (€)'),
    ('AUD', 'AUD (A\$)'),
    ('GBP', 'GBP (£)'),
    ('JPY', 'JPY (¥)'),
    ('CNY', 'CNY (¥)'),
    ('INR', 'INR (₹)'),
  ];

  bool _initialized = false;

  Trip? _existingTrip;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _existingTrip = GoRouterState.of(context).extra as Trip?;
    if (_isEditing) {
      _nameController.text = _existingTrip!.name;
      _destinationController.text = _existingTrip!.destination;
      _startDate = _existingTrip!.startDate;
      _endDate = _existingTrip!.endDate;
      _currency = _existingTrip!.currency;
      _budgetController.text = _existingTrip!.budget.toStringAsFixed(2);
      _budget = _existingTrip!.budget;
    } else {
      final profile = ref.read(userProfileProvider).value;
      _currency = profile?.preferredCurrency ?? 'USD';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date')),
      );
      return;
    }

    final uid = ref.read(authProvider)!;

    if (_isEditing) {
      ref
          .read(tripNotifierProvider.notifier)
          .updateTrip(
_existingTrip!.copyWith(
              name: _nameController.text.trim(),
              destination: _destinationController.text.trim(),
              startDate: _startDate!,
              endDate: _endDate,
              budget: _budget,
              currency: _currency,
              createdBy: uid,
            ),
          );
    } else {
      ref
          .read(tripNotifierProvider.notifier)
          .addTrip(
            Trip(
              name: _nameController.text.trim(),
              destination: _destinationController.text.trim(),
              startDate: _startDate!,
              endDate: _endDate,
              budget: _budget,
              currency: _currency,
              createdBy: uid,
              members: [uid],
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
          _isEditing ? 'Edit Trip' : 'Add Trip',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isEditing) ...[
                const Text(
                  'Plan your next\nadventure',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F2B2E),
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fill in the details to start your journey.',
                  style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 32),
              ] else
                const SizedBox(height: 16),

              const Label(text: 'Trip Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: appInputDecoration('e.g. Roadtrip to California'),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter a trip name' : null,
              ),
              const SizedBox(height: 20),

              const Label(text: 'Destination'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _destinationController,
                decoration: appInputDecoration(
                  'Where are you going?',
                  prefixIcon: const Icon(
                    Icons.map_outlined,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.isEmpty
                    ? 'Please enter a destination'
                    : null,
              ),
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: DateButton(
                      label: 'YYYY-MM-DD',
                      date: _startDate,
                      onTap: () => _pickDate(isStart: true),
                      labelText: 'Start Date', key: null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DateButton(
                      label: 'YYYY-MM-DD',
                      date: _endDate,
                      onTap: () => _pickDate(isStart: false),
                      labelText: 'End Date', key: null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Label(text: 'Budget'),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 56,
                          child: TextFormField(
                            controller: _budgetController,
                            decoration: appInputDecoration(
                              '0.00',
                              prefixIcon: const Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 18,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => setState(
                              () => _budget = double.tryParse(v) ?? 0.0,
                            ),
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
                        const Label(text: 'Currency'),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 56,
                          child: DropdownButtonFormField<String>(
                            initialValue: _currency,
                            isDense: true,
                            decoration: appInputDecoration(''),
                            items: _currencies
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.$1,
                                    child: Text(c.$2),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _currency = v!),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

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
                  icon: const Icon(Icons.flight_takeoff_rounded, size: 20),
                  label: Text(
                    _isEditing ? 'Save Changes' : 'Create Trip',
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

