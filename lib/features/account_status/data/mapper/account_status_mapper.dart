import '../../domain/account_status_kind.dart';
import '../../domain/entities/driver_registration_status_entity.dart';
import '../models/response/driver_registration_status_response_dto.dart';

extension DriverRegistrationStatusResponseDtoMapper
    on DriverRegistrationStatusResponseDto {
  DriverRegistrationStatusEntity toEntity() {
    final statusVal = (status ?? '').trim();
    final normalized = statusVal.toLowerCase();

    final kind = switch (normalized) {
      'submitted' || 'underreview' => AccountStatusKind.underReview,
      'needschanges' || 'moreinformationrequired' =>
        AccountStatusKind.moreInformationRequired,
      'rejected' => AccountStatusKind.rejected,
      'approved' || 'accepted' => AccountStatusKind.accepted,
      _ => AccountStatusKind.underReview,
    };

    return DriverRegistrationStatusEntity(
      registrationId: registrationId ?? '',
      kind: kind,
      phone: phone,
      fullName: fullName,
      restaurantName: restaurantName,
      restaurantId: restaurantId,
      statusString: statusVal.isNotEmpty ? statusVal : 'Submitted',
      stage: stage ?? 1,
      badge: badge,
      title: title,
      subtitle: subtitle,
      notice: notice,
      restaurantApprovalStatus: restaurantApprovalStatus,
      adminApprovalStatus: adminApprovalStatus,
      canResubmit: canResubmit ?? false,
      isApproved: isApproved ?? (normalized == 'approved' || normalized == 'accepted'),
      changeRequestNotes: changeRequestNotes,
      rejectionReason: rejectionReason,
    );
  }
}
