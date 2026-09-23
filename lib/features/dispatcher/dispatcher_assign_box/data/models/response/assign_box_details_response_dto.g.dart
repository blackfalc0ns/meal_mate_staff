// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assign_box_details_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignBoxDetailsResponseDto _$AssignBoxDetailsResponseDtoFromJson(
  Map<String, dynamic> json,
) => AssignBoxDetailsResponseDto(
  box: json['box'] == null
      ? null
      : AssignBoxOrderDto.fromJson(json['box'] as Map<String, dynamic>),
  bestSuggestion: json['bestSuggestion'] == null
      ? null
      : AssignBoxCandidateDriverDto.fromJson(
          json['bestSuggestion'] as Map<String, dynamic>,
        ),
  candidates: (json['candidates'] as List<dynamic>?)
      ?.map(
        (e) => AssignBoxCandidateDriverDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

AssignBoxOrderDto _$AssignBoxOrderDtoFromJson(Map<String, dynamic> json) =>
    AssignBoxOrderDto(
      boxId: json['boxId'] as String?,
      boxCode: json['boxCode'] as String?,
      zoneName: json['zoneName'] as String?,
      deliveryTimeWindow: json['deliveryTimeWindow'] as String?,
      mealCount: (json['mealCount'] as num?)?.toInt(),
      mealCountLabel: json['mealCountLabel'] as String?,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      distanceText: json['distanceText'] as String?,
      priority: json['priority'] as String?,
      priorityBadgeText: json['priorityBadgeText'] as String?,
      status: json['status'] as String?,
      statusText: json['statusText'] as String?,
    );

AssignBoxCandidateDriverDto _$AssignBoxCandidateDriverDtoFromJson(
  Map<String, dynamic> json,
) => AssignBoxCandidateDriverDto(
  driverId: json['driverId'] as String?,
  fullName: json['fullName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  plateNumber: json['plateNumber'] as String?,
  phone: json['phone'] as String?,
  distanceKm: (json['distanceKm'] as num?)?.toDouble(),
  distanceText: json['distanceText'] as String?,
  activeOrdersCount: (json['activeOrdersCount'] as num?)?.toInt(),
  currentLoadBoxes: (json['currentLoadBoxes'] as num?)?.toInt(),
  currentLoadLabel: json['currentLoadLabel'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  status: json['status'] as String?,
  driverStatusText: json['driverStatusText'] as String?,
  statusTag: json['statusTag'] as String?,
  estimatedFinishTimeText: json['estimatedFinishTimeText'] as String?,
  rank: (json['rank'] as num?)?.toInt(),
  isRecommended: json['isRecommended'] as bool?,
  recommendationReason: json['recommendationReason'] as String?,
);
