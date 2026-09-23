import 'package:json_annotation/json_annotation.dart';

part 'assign_box_details_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class AssignBoxDetailsResponseDto {
  const AssignBoxDetailsResponseDto({
    this.box,
    this.bestSuggestion,
    this.candidates,
  });

  factory AssignBoxDetailsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AssignBoxDetailsResponseDtoFromJson(json);

  final AssignBoxOrderDto? box;
  final AssignBoxCandidateDriverDto? bestSuggestion;
  final List<AssignBoxCandidateDriverDto>? candidates;
}

@JsonSerializable(createToJson: false)
class AssignBoxOrderDto {
  const AssignBoxOrderDto({
    this.boxId,
    this.boxCode,
    this.zoneName,
    this.deliveryTimeWindow,
    this.mealCount,
    this.mealCountLabel,
    this.distanceKm,
    this.distanceText,
    this.priority,
    this.priorityBadgeText,
    this.status,
    this.statusText,
  });

  factory AssignBoxOrderDto.fromJson(Map<String, dynamic> json) =>
      _$AssignBoxOrderDtoFromJson(json);

  final String? boxId;
  final String? boxCode;
  final String? zoneName;
  final String? deliveryTimeWindow;
  final int? mealCount;
  final String? mealCountLabel;
  final double? distanceKm;
  final String? distanceText;
  final String? priority;
  final String? priorityBadgeText;
  final String? status;
  final String? statusText;
}

@JsonSerializable(createToJson: false)
class AssignBoxCandidateDriverDto {
  const AssignBoxCandidateDriverDto({
    this.driverId,
    this.fullName,
    this.avatarUrl,
    this.plateNumber,
    this.phone,
    this.distanceKm,
    this.distanceText,
    this.activeOrdersCount,
    this.currentLoadBoxes,
    this.currentLoadLabel,
    this.rating,
    this.status,
    this.driverStatusText,
    this.statusTag,
    this.estimatedFinishTimeText,
    this.rank,
    this.isRecommended,
    this.recommendationReason,
  });

  factory AssignBoxCandidateDriverDto.fromJson(Map<String, dynamic> json) =>
      _$AssignBoxCandidateDriverDtoFromJson(json);

  final String? driverId;
  final String? fullName;
  final String? avatarUrl;
  final String? plateNumber;
  final String? phone;
  final double? distanceKm;
  final String? distanceText;
  final int? activeOrdersCount;
  final int? currentLoadBoxes;
  final String? currentLoadLabel;
  final double? rating;
  final String? status;
  final String? driverStatusText;
  final String? statusTag;
  final String? estimatedFinishTimeText;
  final int? rank;
  final bool? isRecommended;
  final String? recommendationReason;
}
