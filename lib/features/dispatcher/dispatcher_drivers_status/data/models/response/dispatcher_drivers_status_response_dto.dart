class DispatcherDriversStatusResponseDto {
  const DispatcherDriversStatusResponseDto({
    this.restaurantName,
    this.role,
    this.kpis,
    this.drivers,
  });

  factory DispatcherDriversStatusResponseDto.fromJson(Map<String, dynamic> json) {
    return DispatcherDriversStatusResponseDto(
      restaurantName: json['restaurant_name'] as String?,
      role: json['role'] as String?,
      kpis: json['kpis'] != null
          ? DispatcherDriversStatusKpisDto.fromJson(json['kpis'] as Map<String, dynamic>)
          : null,
      drivers: (json['drivers'] as List<dynamic>?)
          ?.map((e) => DispatcherDriverStatusItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String? restaurantName;
  final String? role;
  final DispatcherDriversStatusKpisDto? kpis;
  final List<DispatcherDriverStatusItemDto>? drivers;
}

class DispatcherDriversStatusKpisDto {
  const DispatcherDriversStatusKpisDto({
    this.connectedCount,
    this.inDeliveryCount,
    this.offlineCount,
    this.totalCount,
  });

  factory DispatcherDriversStatusKpisDto.fromJson(Map<String, dynamic> json) {
    return DispatcherDriversStatusKpisDto(
      connectedCount: json['connected_count'] as int?,
      inDeliveryCount: json['in_delivery_count'] as int?,
      offlineCount: json['offline_count'] as int?,
      totalCount: json['total_count'] as int?,
    );
  }

  final int? connectedCount;
  final int? inDeliveryCount;
  final int? offlineCount;
  final int? totalCount;
}

class DispatcherDriverStatusItemDto {
  const DispatcherDriverStatusItemDto({
    this.id,
    this.name,
    this.code,
    this.avatarUrl,
    this.rating,
    this.vehicleType,
    this.plateNumber,
    this.status,
    this.isAvailable,
  });

  factory DispatcherDriverStatusItemDto.fromJson(Map<String, dynamic> json) {
    return DispatcherDriverStatusItemDto(
      id: json['id'] as String?,
      name: json['name'] as String?,
      code: json['code'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      vehicleType: json['vehicle_type'] as String?,
      plateNumber: json['plate_number'] as String?,
      status: json['status'] as String?,
      isAvailable: json['is_available'] as bool?,
    );
  }

  final String? id;
  final String? name;
  final String? code;
  final String? avatarUrl;
  final double? rating;
  final String? vehicleType;
  final String? plateNumber;
  final String? status;
  final bool? isAvailable;
}
