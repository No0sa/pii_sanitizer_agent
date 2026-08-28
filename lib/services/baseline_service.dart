import '../models/user_record.dart';

class BaselineService {
  static List<UserRecord> sanitizeBatch(List<UserRecord> records) {
    return records.map((record) => sanitizeSingle(record)).toList();
  }

  static UserRecord sanitizeSingle(UserRecord record) {
    String sanitizedEmail = 'anonymized_user@domain.com';

    final phoneRegex = RegExp(r'\+?\d{10,14}');
    String sanitizedPhone = record.phone.replaceAll(
      phoneRegex,
      '+000000000000',
    );

    String sanitizedNotes = record.internalNotes.replaceAll(
      phoneRegex,
      '[PHONE_REMOVED]',
    );

    return record.copyWith(
      email: sanitizedEmail,
      phone: sanitizedPhone,
      internalNotes: sanitizedNotes,
    );
  }
}
