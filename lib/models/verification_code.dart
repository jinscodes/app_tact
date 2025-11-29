class VerificationCode {
  final String email;
  final String code;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isUsed;

  VerificationCode({
    required this.email,
    required this.code,
    required this.createdAt,
    required this.expiresAt,
    this.isUsed = false,
  });

  factory VerificationCode.create(String email, String code) {
    final now = DateTime.now();
    return VerificationCode(
      email: email,
      code: code,
      createdAt: now,
      expiresAt: now.add(const Duration(minutes: 5)),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isValid => !isUsed && !isExpired;

  int get remainingTimeInSeconds {
    if (isExpired) return 0;
    return expiresAt.difference(DateTime.now()).inSeconds;
  }

  VerificationCode markAsUsed() {
    return VerificationCode(
      email: email,
      code: code,
      createdAt: createdAt,
      expiresAt: expiresAt,
      isUsed: true,
    );
  }

  VerificationCode copyWith({
    String? email,
    String? code,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isUsed,
  }) {
    return VerificationCode(
      email: email ?? this.email,
      code: code ?? this.code,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isUsed: isUsed ?? this.isUsed,
    );
  }

  @override
  String toString() {
    return 'VerificationCode(email: $email, code: $code, createdAt: $createdAt, expiresAt: $expiresAt, isUsed: $isUsed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerificationCode &&
        other.email == email &&
        other.code == code &&
        other.createdAt == createdAt &&
        other.expiresAt == expiresAt &&
        other.isUsed == isUsed;
  }

  @override
  int get hashCode {
    return email.hashCode ^
        code.hashCode ^
        createdAt.hashCode ^
        expiresAt.hashCode ^
        isUsed.hashCode;
  }
}
