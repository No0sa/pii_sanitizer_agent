import 'package:faker/faker.dart';
import '../core/trajectory_logger.dart';
import '../models/user_record.dart';

class GeneratorAgent {
  final Faker faker = Faker();

  String _generatePhone() {
    final areaCode = faker.randomGenerator.integer(900, min: 100);
    final prefix = faker.randomGenerator.integer(900, min: 100);
    final lineNum = faker.randomGenerator.integer(9999, min: 1000);
    return '+1$areaCode$prefix$lineNum';
  }

  Future<UserRecord> sanitizeRecord(
    UserRecord record,
    Map<String, dynamic> inspectionResult, {
    bool redactionOnly = false,
  }) async {
    final syntheticEmail = redactionOnly ? '[REDACTED_EMAIL]' : faker.internet.email();
    final syntheticPhone = redactionOnly ? '[REDACTED_PHONE]' : _generatePhone();

    String sanitizedNotes = record.internalNotes;
    final detectedPii = (inspectionResult['detected_pii'] as List?) ?? [];
    final Map<String, String> replacementMap = {};

    for (final item in detectedPii) {
      final entityType = item['entity_type'] as String?;
      final originalValue = item['original_value'] as String?;

      if (originalValue == null || originalValue.isEmpty) continue;

      String syntheticValue;
      if (redactionOnly) {
        syntheticValue = '[REDACTED_${entityType ?? 'PII'}]';
      } else {
        switch (entityType) {
          case 'NAME':
            syntheticValue = faker.person.name();
            break;
          case 'PHONE':
            syntheticValue = _generatePhone();
            break;
          case 'CREDIT_CARD':
            syntheticValue =
                '${faker.randomGenerator.integer(9999, min: 1000)}-XXXX-XXXX-XXXX';
            break;
          case 'EMAIL':
            syntheticValue = faker.internet.email();
            break;
          case 'PASSPORT':
            syntheticValue =
                'PASS-${faker.randomGenerator.integer(999999, min: 100000)}';
            break;
          case 'IP_ADDRESS':
            syntheticValue =
                '10.0.0.${faker.randomGenerator.integer(255, min: 1)}';
            break;
          default:
            syntheticValue = '[REDACTED]';
        }
      }

      replacementMap[originalValue] = syntheticValue;
      sanitizedNotes = sanitizedNotes.replaceAll(originalValue, syntheticValue);
    }

    final sanitizedRecord = record.copyWith(
      email: syntheticEmail,
      phone: syntheticPhone,
      internalNotes: sanitizedNotes,
    );

    await TrajectoryLogger.logAgentAction(
      agentName: 'GeneratorAgent',
      systemPrompt: redactionOnly
          ? 'Mask all PII with redaction tags.'
          : 'Replace PII entities with realistic synthetic data.',
      userInput: record.internalNotes,
      agentOutput: sanitizedNotes,
      metadata: {
        'user_id': record.userId,
        'mode': redactionOnly ? 'REDACTION' : 'SYNTHETIC',
        'replacements_count': replacementMap.length,
      },
    );

    return sanitizedRecord;
  }
}