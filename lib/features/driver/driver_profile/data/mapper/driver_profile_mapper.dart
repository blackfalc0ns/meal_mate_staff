import 'package:meal_mate_delivery/core/network/network_constants.dart';

import '../../domain/entities/driver_profile_assignment_entity.dart';
import '../../domain/entities/driver_profile_document_entity.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/entities/driver_profile_ticket_entity.dart';
import '../../domain/entities/driver_profile_vehicle_entity.dart';
import '../models/response/driver_profile_response_dto.dart';

extension DriverProfileResponseDtoMapper on DriverProfileResponseDto {
  DriverProfileEntity toEntity() => DriverProfileEntity(
    driverProfileId: driverProfileId ?? '',
    fullName: (fullNameAr != null && fullNameAr!.trim().isNotEmpty)
        ? fullNameAr!
        : (fullName ?? ''),
    driverDescription: driverDescription ?? '',
    driverRank: driverRank,
    driverCode: driverCode ?? '',
    phoneNumber: phoneNumber,
    profileImageUrl: _resolveAvatarUrl(profileImageUrl, profileImageStorageKey),
    isOnline: isOnline ?? false,
    status: status ?? '',
    statusText: statusText ?? '',
    averageRating: averageRating?.toDouble(),
    reviewsCount: reviewsCount ?? 0,
    totalOrders: totalOrders ?? 0,
    acceptanceRatePercent: acceptanceRatePercent?.toDouble(),
    joinedAtUtc: DateTime.tryParse(joinedAtUtc ?? '')?.toUtc(),
    vehicle: vehicle?.toEntity(),
    documents: List.unmodifiable(
      (documents ?? const []).map((item) => item.toEntity()),
    ),
    assignment: assignment?.toEntity(),
    latestSupportTicket: latestSupportTicket?.toEntity(),
  );

  static String? _resolveAvatarUrl(String? rawUrl, String? storageKey) {
    if (rawUrl != null &&
        (rawUrl.startsWith('http://') || rawUrl.startsWith('https://'))) {
      return rawUrl;
    }
    if (storageKey != null && storageKey.trim().isNotEmpty) {
      final cleanKey = storageKey.startsWith('/')
          ? storageKey.substring(1)
          : storageKey;
      return '${NetworkConstants.baseUrl}/$cleanKey';
    }
    if (rawUrl != null && rawUrl.startsWith('/')) {
      return '${NetworkConstants.baseUrl}$rawUrl';
    }
    return null;
  }
}

extension DriverProfileVehicleResponseDtoMapper
    on DriverProfileVehicleResponseDto {
  DriverProfileVehicleEntity toEntity() => DriverProfileVehicleEntity(
    vehicleType: vehicleType,
    vehicleTypeLocalized: effectiveTypeLocalized,
    vehicleModel: vehicleModel,
    vehicleYear: vehicleYear,
    color: effectiveColor,
    vehicleColorLocalized: effectiveColorLocalized,
    plateNumber: effectivePlate,
    plateGovernorate: plateGovernorate,
    verificationStatus: verificationStatus,
    verificationStatusText: verificationStatusText,
    isVehicleActive:
        isVehicleActive ?? (verificationStatus?.toLowerCase() == 'approved'),
  );
}

extension DriverProfileDocumentResponseDtoMapper
    on DriverProfileDocumentResponseDto {
  DriverProfileDocumentEntity toEntity() => DriverProfileDocumentEntity(
    documentId: documentId ?? '',
    documentType: documentType ?? '',
    documentTitle: documentTitle ?? '',
    status: status ?? '',
    statusText: statusText ?? '',
    expiryDate: expiryDate,
    daysUntilExpiry: daysUntilExpiry,
    uploadedAtUtc: DateTime.tryParse(uploadedAtUtc ?? '')?.toUtc(),
  );
}

extension DriverProfileAssignmentResponseDtoMapper
    on DriverProfileAssignmentResponseDto {
  DriverProfileAssignmentEntity toEntity() => DriverProfileAssignmentEntity(
    restaurantId: restaurantId,
    restaurantName: restaurantName,
    branchId: branchId,
    branchName: branchName,
    assignedAtUtc: DateTime.tryParse(assignedAtUtc ?? '')?.toUtc(),
  );
}

extension DriverProfileTicketResponseDtoMapper
    on DriverProfileTicketResponseDto {
  DriverProfileTicketEntity toEntity() => DriverProfileTicketEntity(
    ticketId: ticketId ?? '',
    ticketNumber: ticketNumber ?? '',
    subject: subject ?? '',
    body: body ?? '',
    status: status ?? '',
    statusText: statusText ?? '',
    priority: priority,
    priorityText: priorityText,
    createdAtUtc: DateTime.tryParse(createdAtUtc ?? '')?.toUtc(),
  );
}
