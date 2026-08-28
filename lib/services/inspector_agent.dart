import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_record.dart';

class InspectorAgent {
  final String apiKey;

  InspectorAgent({required this.apiKey});

  /// Analyzes unstructured text in a UserRecord to detect all PII entities
  Future<Map<String, dynamic>> inspectRecord(UserRecord record) async {
    final candidateModels = [
      'gemini-3.6-flash',
      'gemini-2.5-flash',
      'gemini-2.0-flash',
      'gemini-1.5-flash',
    ];

    final prompt =
        '''
You are a Security Inspector Agent specializing in Privacy and PII (Personally Identifiable Information) detection.
Your task is to analyze raw, unstructured user notes and detect ANY sensitive data entities including:
- Full Names
- Phone Numbers
- Credit Card Numbers
- Email Addresses
- Passport or Identification Numbers
- IP Addresses

User Email: ${record.email}
User Phone: ${record.phone}
Internal Notes: "${record.internalNotes}"

Return ONLY a valid JSON object matching this schema:
{
  "detected_pii": [
    {
      "entity_type": "STRING (NAME | PHONE | CREDIT_CARD | EMAIL | PASSPORT | IP_ADDRESS)",
      "original_value": "STRING",
      "confidence": 1.0
    }
  ],
  "contains_unstructured_pii": true
}
''';

    String lastError = '';

    for (final model in candidateModels) {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
      );

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt},
                ],
              },
            ],
            'generationConfig': {
              'response_mime_type': 'application/json',
              'temperature': 0.1,
            },
          }),
        );

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final textOutput =
              jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
              '{}';
          return jsonDecode(textOutput) as Map<String, dynamic>;
        } else {
          final errorJson = jsonDecode(response.body);
          lastError =
              errorJson['error']?['message'] ?? 'HTTP ${response.statusCode}';
        }
      } catch (e) {
        lastError = e.toString();
      }
    }

    throw Exception(lastError);
  }
}
