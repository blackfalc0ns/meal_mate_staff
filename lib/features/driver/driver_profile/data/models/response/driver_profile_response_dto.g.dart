// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_profile_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverProfileResponseDto _$DriverProfileResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverProfileResponseDto(
  driverProfileId: json['driverProfileId'] as String?,
  fullName: json['fullName'] as String?,
  fullNameAr: json['fullNameAr'] as String?,
  driverDescription: json['driverDescription'] as String?,
  driverRank: json['driverRank'] as String?,
  driverCode: json['driverCode'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  profileImageStorageKey: json['profileImageStorageKey'] as String?,
  profileImageUrl: json['profileImageUrl'] as String?,
  isOnline: json['isOnline'] as bool?,
  status: json['status'] as String?,
  statusText: json['statusText'] as String?,
  averageRating: json['averageRating'] as num?,
  reviewsCount: (json['reviewsCount'] as num?)?.toInt(),
  totalOrders: (json['totalOrders'] as num?)?.toInt(),
  acceptanceRatePercent: json['acceptanceRatePercent'] as num?,
  joinedAtUtc: json['joinedAtUtc'] as String?,
  vehicle: json['vehicle'] == null
      ? null
      : DriverProfileVehicleResponseDto.fromJson(
          json['vehicle'] as Map<String, dynamic>,
        ),
  documents: (json['documents'] as List<dynamic>?)
      ?.map(
        (e) => DriverProfileDocumentResponseDto.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  assignment: json['assignment'] == null
      ? null
      : DriverProfileAssignmentResponseDto.fromJson(
          json['assignment'] as Map<String, dynamic>,
        ),
  latestSupportTicket: json['latestSupportTicket'] == null
      ? null
      : DriverProfileTicketResponseDto.fromJson(
          json['latestSupportTicket'] as Map<String, dynamic>,
        ),
);

DriverProfileVehicleResponseDto _$DriverProfileVehicleResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverProfileVehicleResponseDto(
  vehicleType: json['vehicleType'] as String?,
  vehicleTypeLocalized: json['vehicleTypeLocalized'] as String?,
  vehicleModel: json['vehicleModel'] as String?,
  vehiclePlate: json['vehiclePlate'] as String?,
  vehicleYear: (json['vehicleYear'] as num?)?.toInt(),
  vehicleColor: json['vehicleColor'] as String?,
  vehicleColorLocalized: json['vehicleColorLocalized'] as String?,
  color: json['color'] as String?,
  plateNumber: json['plateNumber'] as String?,
  plateGovernorate: json['plateGovernorate'] as String?,
  verificationStatus: json['verificationStatus'] as String?,
  verificationStatusText: json['verificationStatusText'] as String?,
  isVehicleActive: json['isVehicleActive'] as bool?,
);

DriverProfileDocumentResponseDto _$DriverProfileDocumentResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverProfileDocumentResponseDto(
  documentId: json['documentId'] as String?,
  documentType: json['documentType'] as String?,
  documentTitle: json['documentTitle'] as String?,
  status: json['status'] as String?,
  statusText: json['statusText'] as String?,
  verificationStatus: json['verificationStatus'] as String?,
  expiryDate: json['expiryDate'] as String?,
  daysUntilExpiry: (json['daysUntilExpiry'] as num?)?.toInt(),
  requiresRenewal: json['requiresRenewal'] as bool?,
  uploadedAtUtc: json['uploadedAtUtc'] as String?,
);

DriverProfileAssignmentResponseDto _$DriverProfileAssignmentResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverProfileAssignmentResponseDto(
  restaurantId: json['restaurantId'] as String?,
  restaurantName: json['restaurantName'] as String?,
  branchId: json['branchId'] as String?,
  branchName: json['branchName'] as String?,
  assignedAtUtc: json['assignedAtUtc'] as String?,
);

DriverProfileTicketResponseDto _$DriverProfileTicketResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverProfileTicketResponseDto(
  ticketId: json['ticketId'] as String?,
  ticketNumber: json['ticketNumber'] as String?,
  subject: json['subject'] as String?,
  body: json['body'] as String?,
  status: json['status'] as String?,
  statusText: json['statusText'] as String?,
  priority: json['priority'] as String?,
  priorityText: json['priorityText'] as String?,
  createdAtUtc: json['createdAtUtc'] as String?,
);
