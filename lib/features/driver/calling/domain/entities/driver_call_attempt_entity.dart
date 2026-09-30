class DriverCallAttemptEntity {
  const DriverCallAttemptEntity({
    required this.customerName,
    required this.customerPhone,
    this.attemptNumber = 1,
  });

  final String customerName;
  final String customerPhone;
  final int attemptNumber;

  bool get isPhoneUnlocked => attemptNumber >= 3;

  DriverCallAttemptEntity copyWith({
    String? customerName,
    String? customerPhone,
    int? attemptNumber,
  }) {
    return DriverCallAttemptEntity(
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      attemptNumber: attemptNumber ?? this.attemptNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverCallAttemptEntity &&
          runtimeType == other.runtimeType &&
          customerName == other.customerName &&
          customerPhone == other.customerPhone &&
          attemptNumber == other.attemptNumber;

  @override
  int get hashCode => Object.hash(customerName, customerPhone, attemptNumber);
}
