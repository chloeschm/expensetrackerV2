import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  final String text;
  const Label({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F2B2E),
      ),
    );
  }
}