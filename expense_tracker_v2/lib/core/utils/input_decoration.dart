import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

InputDecoration appInputDecoration(String hint, {Widget? prefixIcon}) => InputDecoration(
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