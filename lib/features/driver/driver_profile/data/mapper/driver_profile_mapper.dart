import '../../domain/entities/driver_profile_assignment_entity.dart';
import '../../domain/entities/driver_profile_document_entity.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/entities/driver_profile_ticket_entity.dart';
import '../../domain/entities/driver_profile_vehicle_entity.dart';
import '../models/response/driver_profile_response_dto.dart';

extension DriverProfileResponseDtoMapper on DriverProfileResponseDto {
  DriverProfileEntity toEntity() => DriverProfileEntity(
        driverProfileId: driverProfileId ?? '',
        fullName: fullName ?? '',
        driverDescription: driverDescription ?? '',
        driverRank: driverRank,
        driverCode: driverCode ?? '',
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
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
}

extension DriverProfileVehicleResponseDtoMapper
    on DriverProfileVehicleResponseDto {
  DriverProfileVehicleEntity toEntity() => DriverProfileVehicleEntity(
        vehicleType: vehicleType,
        vehicleModel: vehicleModel,
        vehicleYear: vehicleYear,
        color: effectiveColor,
        plateNumber: plateNumber,
        plateGovernorate: plateGovernorate,
        verificationStatus: verificationStatus,
        verificationStatusText: verificationStatusText,
        isVehicleActive: isVehicleActive ?? false,
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
