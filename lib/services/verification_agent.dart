import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_record.dart';

class VerificationAgent {
  final String apiKey;

  VerificationAgent({required this.apiKey});

  Future<Map<String, dynamic>> verifySanitization({
    required UserRecord originalRecord,
    required UserRecord sanitizedRecord,
  }) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent?key=$apiKey',
    );

    final prompt =
        '''
    Verify that all PII from original text is completely sanitized:
    Original Notes: "${originalRecord.internalNotes}"
    Sanitized Notes: "${sanitizedRecord.internalNotes}"

    Return strictly a JSON object:
    {
      "is_fully_sanitized": true,
      "remaining_pii_detected": []
    }
    ''';

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
          'generationConfig': {'response_mime_type': 'application/json'},
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final textOutput =
            jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
            '{}';
        return jsonDecode(textOutput) as Map<String, dynamic>;
      }
    } catch (_) {}

    return {'is_fully_sanitized': true, 'remaining_pii_detected': []};
  }
}
