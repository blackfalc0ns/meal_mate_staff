class DriverActiveCallEntity {
  const DriverActiveCallEntity({
    required this.customerName,
    required this.addressLine,
    required this.area,
    this.initialDurationSeconds = 24,
  });

  final String customerName;
  final String addressLine;
  final String area;
  final int initialDurationSeconds;

  DriverActiveCallEntity copyWith({
    String? customerName,
    String? addressLine,
    String? area,
    int? initialDurationSeconds,
  }) {
    return DriverActiveCallEntity(
      customerName: customerName ?? this.customerName,
      addressLine: addressLine ?? this.addressLine,
      area: area ?? this.area,
      initialDurationSeconds:
          initialDurationSeconds ?? this.initialDurationSeconds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverActiveCallEntity &&
          runtimeType == other.runtimeType &&
          customerName == other.customerName &&
          addressLine == other.addressLine &&
          area == other.area &&
          initialDurationSeconds == other.initialDurationSeconds;

  @override
  int get hashCode => Object.hash(
        customerName,
        addressLine,
        area,
        initialDurationSeconds,
      );
}
