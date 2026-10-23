class PhoneGrantEntity {
  const PhoneGrantEntity({
    required this.grantId,
    required this.expiresAtUtc,
    required this.customerPhone,
    required this.contactCaseId,
  });

  final String grantId;
  final DateTime expiresAtUtc;
  final String customerPhone;
  final String contactCaseId;

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAtUtc);
}
