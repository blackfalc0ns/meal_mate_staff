import 'dispatcher_driver_status_type.dart';

class DispatcherDriverStatusItemEntity {
  const DispatcherDriverStatusItemEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.avatarUrl,
    required this.rating,
    required this.vehicleType,
    required this.plateNumber,
    required this.status,
    required this.isAvailable,
  });

  final String id;
  final String name;
  final String code;
  final String avatarUrl;
  final double rating;
  final String vehicleType;
  final String plateNumber;
  final DispatcherDriverStatusType status;
  final bool isAvailable;

  DispatcherDriverStatusItemEntity copyWith({
    String? id,
    String? name,
    String? code,
    String? avatarUrl,
    double? rating,
    String? vehicleType,
    String? plateNumber,
    DispatcherDriverStatusType? status,
    bool? isAvailable,
  }) {
    return DispatcherDriverStatusItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
      vehicleType: vehicleType ?? this.vehicleType,
      plateNumber: plateNumber ?? this.plateNumber,
      status: status ?? this.status,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriverStatusItemEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          code == other.code &&
          avatarUrl == other.avatarUrl &&
          rating == other.rating &&
          vehicleType == other.vehicleType &&
          plateNumber == other.plateNumber &&
          status == other.status &&
          isAvailable == other.isAvailable;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    code,
    avatarUrl,
    rating,
    vehicleType,
    plateNumber,
    status,
    isAvailable,
  );
}
