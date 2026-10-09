class ReassignmentResultEntity {
  const ReassignmentResultEntity({
    required this.requestId,
    required this.boxId,
    required this.status,
    this.boxCode,
    this.message,
    this.requestedAtUtc,
  });

  final String requestId;
  final String boxId;
  final String status;
  final String? boxCode;
  final String? message;
  final DateTime? requestedAtUtc;

  ReassignmentResultEntity copyWith({
    String? requestId,
    String? boxId,
    String? status,
    String? boxCode,
    String? message,
    DateTime? requestedAtUtc,
  }) {
    return ReassignmentResultEntity(
      requestId: requestId ?? this.requestId,
      boxId: boxId ?? this.boxId,
      status: status ?? this.status,
      boxCode: boxCode ?? this.boxCode,
      message: message ?? this.message,
      requestedAtUtc: requestedAtUtc ?? this.requestedAtUtc,
    );
  }
}
