class DriverCallProxyEntity {
  const DriverCallProxyEntity({
    required this.boxId,
    required this.callableUri,
    this.phoneNumber,
    this.expiresAtUtc,
  });

  final String boxId;
  final String callableUri;
  final String? phoneNumber;
  final DateTime? expiresAtUtc;

  bool get isExpired =>
      expiresAtUtc != null && DateTime.now().toUtc().isAfter(expiresAtUtc!);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverCallProxyEntity &&
          runtimeType == other.runtimeType &&
          boxId == other.boxId &&
          callableUri == other.callableUri &&
          phoneNumber == other.phoneNumber &&
          expiresAtUtc == other.expiresAtUtc;

  @override
  int get hashCode =>
      Object.hash(boxId, callableUri, phoneNumber, expiresAtUtc);
}
