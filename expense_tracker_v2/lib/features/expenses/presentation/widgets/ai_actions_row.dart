import 'package:expense_tracker_v2/features/expenses/presentation/widgets/action_button.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/ai_expense_parser.dart';
import '../../presentation/widgets/ai_parse_dialog.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class AiActionsRow extends StatefulWidget {
  const AiActionsRow({super.key, required this.onParsed});
  final ValueChanged<Map<String, dynamic>> onParsed;
  @override
  State<AiActionsRow> createState() => _AiActionsRowState();
}

class _AiActionsRowState extends State<AiActionsRow> {
  bool _isLoading = false;

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
      if (parsed != null) widget.onParsed(parsed);
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
        widget.onParsed(parsed);
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

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
