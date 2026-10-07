class DriverArrivalResultEntity {
  const DriverArrivalResultEntity({
    required this.boxId,
    required this.arrivedAtUtc,
    this.isFirstArrival,
    this.status,
    this.message,
  });

  final String boxId;
  final DateTime arrivedAtUtc;
  final bool? isFirstArrival;
  final String? status;
  final String? message;
}
