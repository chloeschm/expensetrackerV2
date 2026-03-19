import 'package:flutter/material.dart';
import '../../../../core/widgets/label.dart';
import '../../../../core/utils/input_decoration.dart';


class AmountCurrencyRow extends StatelessWidget {
  final double amount;
  final String currency;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onCurrencyChanged;
  final TextEditingController amountController;

  const AmountCurrencyRow({
    super.key,
    required this.amount,
    required this.currency,
    required this.onAmountChanged,
    required this.onCurrencyChanged,
    required this.amountController,
  });

  static const _currencies = ['USD', 'EUR', 'AUD', 'GBP', 'JPY', 'CNY', 'INR'];

  @override
  Widget build(BuildContext context) {
    return Row(
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
                controller: amountController,
                decoration: appInputDecoration('\$ 0.00'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onChanged: (v) => onAmountChanged(v),
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
                key: ValueKey(currency),
                initialValue: currency,
                decoration: appInputDecoration(''),
                items: _currencies
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => onCurrencyChanged(v!),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
