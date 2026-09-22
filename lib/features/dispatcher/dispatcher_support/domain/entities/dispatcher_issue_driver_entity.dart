class DispatcherIssueDriverEntity {
  const DispatcherIssueDriverEntity({
    required this.id,
    required this.name,
    required this.code,
    this.avatarUrl,
    this.phoneNumber,
    this.isOnline = true,
    this.status = '',
    this.statusLabel = '',
    this.statusColorHex,
    this.subStatus = '',
    this.vehicleInfo,
    this.rating,
  });

  final String id;
  final String name;
  final String code;
  final String? avatarUrl;
  final String? phoneNumber;
  final bool isOnline;
  final String status;
  final String statusLabel;
  final String? statusColorHex;
  final String subStatus;
  final String? vehicleInfo;
  final double? rating;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherIssueDriverEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
