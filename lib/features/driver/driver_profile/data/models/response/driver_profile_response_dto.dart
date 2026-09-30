import 'package:json_annotation/json_annotation.dart';

part 'driver_profile_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DriverProfileResponseDto {
  const DriverProfileResponseDto({
    this.driverProfileId,
    this.fullName,
    this.driverDescription,
    this.driverRank,
    this.driverCode,
    this.phoneNumber,
    this.profileImageStorageKey,
    this.profileImageUrl,
    this.isOnline,
    this.status,
    this.statusText,
    this.averageRating,
    this.reviewsCount,
    this.totalOrders,
    this.acceptanceRatePercent,
    this.joinedAtUtc,
    this.vehicle,
    this.documents,
    this.assignment,
    this.latestSupportTicket,
  });

  factory DriverProfileResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverProfileResponseDtoFromJson(json);

  final String? driverProfileId;
  final String? fullName;
  final String? driverDescription;
  final String? driverRank;
  final String? driverCode;
  final String? phoneNumber;
  final String? profileImageStorageKey;
  final String? profileImageUrl;
  final bool? isOnline;
  final String? status;
  final String? statusText;
  final num? averageRating;
  final int? reviewsCount;
  final int? totalOrders;
  final num? acceptanceRatePercent;
  final String? joinedAtUtc;
  final DriverProfileVehicleResponseDto? vehicle;
  final List<DriverProfileDocumentResponseDto>? documents;
  final DriverProfileAssignmentResponseDto? assignment;
  final DriverProfileTicketResponseDto? latestSupportTicket;
}

@JsonSerializable(createToJson: false)
class DriverProfileVehicleResponseDto {
  const DriverProfileVehicleResponseDto({
    this.vehicleType,
    this.vehicleModel,
    this.vehicleYear,
    this.vehicleColor,
    this.color,
    this.plateNumber,
    this.plateGovernorate,
    this.verificationStatus,
    this.verificationStatusText,
    this.isVehicleActive,
  });

  factory DriverProfileVehicleResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverProfileVehicleResponseDtoFromJson(json);

  final String? vehicleType;
  final String? vehicleModel;
  final int? vehicleYear;
  final String? vehicleColor;
  final String? color;
  final String? plateNumber;
  final String? plateGovernorate;
  final String? verificationStatus;
  final String? verificationStatusText;
  final bool? isVehicleActive;

  String? get effectiveColor => color ?? vehicleColor;
}

@JsonSerializable(createToJson: false)
class DriverProfileDocumentResponseDto {
  const DriverProfileDocumentResponseDto({
    this.documentId,
    this.documentType,
    this.documentTitle,
    this.status,
    this.statusText,
    this.expiryDate,
    this.daysUntilExpiry,
    this.uploadedAtUtc,
  });

  factory DriverProfileDocumentResponseDto.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$DriverProfileDocumentResponseDtoFromJson(json);

  final String? documentId;
  final String? documentType;
  final String? documentTitle;
  final String? status;
  final String? statusText;
  final String? expiryDate;
  final int? daysUntilExpiry;
  final String? uploadedAtUtc;
}

@JsonSerializable(createToJson: false)
class DriverProfileAssignmentResponseDto {
  const DriverProfileAssignmentResponseDto({
    this.restaurantId,
    this.restaurantName,
    this.branchId,
    this.branchName,
    this.assignedAtUtc,
  });

  factory DriverProfileAssignmentResponseDto.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$DriverProfileAssignmentResponseDtoFromJson(json);

  final String? restaurantId;
  final String? restaurantName;
  final String? branchId;
  final String? branchName;
  final String? assignedAtUtc;
}

@JsonSerializable(createToJson: false)
class DriverProfileTicketResponseDto {
  const DriverProfileTicketResponseDto({
    this.ticketId,
    this.ticketNumber,
    this.subject,
    this.body,
    this.status,
    this.statusText,
    this.priority,
    this.priorityText,
    this.createdAtUtc,
  });

  factory DriverProfileTicketResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverProfileTicketResponseDtoFromJson(json);

  final String? ticketId;
  final String? ticketNumber;
  final String? subject;
  final String? body;
  final String? status;
  final String? statusText;
  final String? priority;
  final String? priorityText;
  final String? createdAtUtc;
}
