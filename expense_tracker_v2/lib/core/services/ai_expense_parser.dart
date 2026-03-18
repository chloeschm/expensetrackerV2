import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/config.dart';
import 'package:intl/intl.dart';

class AiExpenseParser {
  static String get _systemPrompt =>
      'Today is ${DateFormat('yyyy-MM-dd').format(DateTime.now())}. '
      'The user is inputting a travel expense. '
      'Extract the title, amount (as 0.00), currency (default USD), '
      'category (one of: food, transport, accommodation, activities, shopping, health, other), '
      'and date (as yyyy-MM-dd). '
      'Respond with raw JSON only — no markdown, no code fences, no extra text. '
      'Example: {"title":"Coffee","amount":"3.50","currency":"USD","category":"food","date":"2024-06-01"}';

  static Future<Map<String, dynamic>?> parseText(String input) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Config.openAiApiKey}',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': input},
        ],
      }),
    );
    final data = jsonDecode(response.body);
    final content = data['choices'][0]['message']['content'] as String;
    final cleaned = content.replaceAll('```json', '').replaceAll('```', '').trim();
    return jsonDecode(cleaned) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>?> scanReceipt(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return null;

    final bytes = await File(picked.path).readAsBytes();
    final base64Image = base64Encode(bytes);
    final mimeType = picked.path.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Config.openAiApiKey}',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {
            'role': 'user',
            'content': [
              {'type': 'image_url', 'image_url': {'url': 'data:$mimeType;base64,$base64Image'}},
              {'type': 'text', 'text': 'Extract expense details from this receipt.'},
            ],
          },
        ],
        'max_tokens': 300,
      }),
    );
    final data = jsonDecode(response.body);
    final content = data['choices'][0]['message']['content'] as String;
    final cleaned = content.replaceAll('```json', '').replaceAll('```', '').trim();
    return jsonDecode(cleaned) as Map<String, dynamic>;
  }
}