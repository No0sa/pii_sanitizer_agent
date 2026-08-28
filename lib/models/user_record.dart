

class UserRecord {
  final String userId;
  final String accountStatus;
  final String email;
  final String phone;
  final String internalNotes;

  UserRecord({
    required this.userId,
    required this.accountStatus,
    required this.email,
    required this.phone,
    required this.internalNotes, required String status,
  });

  factory UserRecord.fromJson(Map<String, dynamic> json) {
    return UserRecord(
      userId: json['user_id'] ?? '',
      accountStatus: json['account_status'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      internalNotes: json['internal_notes'] ?? '', status: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'account_status': accountStatus,
      'email': email,
      'phone': phone,
      'internal_notes': internalNotes,
    };
  }

  UserRecord copyWith({String? email, String? phone, String? internalNotes}) {
    return UserRecord(
      userId: userId,
      accountStatus: accountStatus,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      internalNotes: internalNotes ?? this.internalNotes, status: '',
    );
  }
}
