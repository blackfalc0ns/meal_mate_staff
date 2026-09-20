import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/entities/phone_lookup_result_entity.dart';
import '../../domain/entities/staff_application_status_entity.dart';
import '../../domain/entities/verify_first_time_otp_result_entity.dart';
import '../../domain/user_role.dart';
import '../models/response/phone_lookup_response_dto.dart';
import '../models/response/staff_application_status_dto.dart';
import '../models/response/staff_auth_response_dto.dart';
import '../models/response/verify_first_time_otp_response_dto.dart';
import 'staff_role_mapper.dart';

extension StaffApplicationStatusDtoMapper on StaffApplicationStatusDto? {
  StaffApplicationStatusEntity? toEntity() {
    if (this == null) return null;
    final dto = this!;
    return StaffApplicationStatusEntity(
      registrationId: dto.registrationId,
      stage: dto.stage,
      badge: dto.badge,
      title: dto.title,
      subtitle: dto.subtitle,
      notice: dto.notice,
      canResubmit: dto.canResubmit ?? false,
      isApproved: dto.isApproved ?? false,
      restaurantApprovalStatus: dto.restaurantApprovalStatus,
      adminApprovalStatus: dto.adminApprovalStatus,
      changeRequestNotes: dto.changeRequestNotes,
      rejectionReason: dto.rejectionReason,
    );
  }
}

extension PhoneLookupResponseDtoMapper on PhoneLookupResponseDto {
  PhoneLookupResultEntity toEntity({
    UserRole fallbackRole = UserRole.operations,
    String fallbackPhone = '',
  }) {
    return PhoneLookupResultEntity(
      exists: exists ?? false,
      isFirstTimeSetup: isFirstTimeSetup ?? false,
      role: role != null ? role.toUserRole() : fallbackRole,
      phone: phone ?? fallbackPhone,
      fullName: fullName,
      restaurantName: restaurantName,
      restaurantId: restaurantId,
      status: status,
      applicationStatus: applicationStatus.toEntity(),
    );
  }
}

extension VerifyFirstTimeOtpResponseDtoMapper on VerifyFirstTimeOtpResponseDto {
  VerifyFirstTimeOtpResultEntity toEntity({
    UserRole fallbackRole = UserRole.operations,
    String fallbackPhone = '',
  }) {
    return VerifyFirstTimeOtpResultEntity(
      verified: verified ?? false,
      verificationToken: verificationToken ?? '',
      phone: phone ?? fallbackPhone,
      role: role != null ? role.toUserRole() : fallbackRole,
      message: message,
    );
  }
}

extension StaffAuthResponseDtoMapper on StaffAuthResponseDto {
  AuthSessionEntity toSessionEntity({
    UserRole fallbackRole = UserRole.operations,
    String fallbackPhone = '',
  }) {
    final parsedUserRole = userType != null
        ? userType.toUserRole()
        : fallbackRole;

    DateTime? parsedExpiry;
    if (accessTokenExpiresAtUtc != null &&
        accessTokenExpiresAtUtc!.trim().isNotEmpty) {
      parsedExpiry = DateTime.tryParse(accessTokenExpiresAtUtc!);
    }

    return AuthSessionEntity(
      user: AuthUserEntity(
        userId: userId ?? '',
        phoneNumber: phoneNumber ?? fallbackPhone,
        fullName: fullName ?? '',
        role: parsedUserRole,
        restaurantId: restaurantId,
        accountStatus: accountStatus,
        roles: roles ?? const [],
      ),
      accessToken: accessToken ?? '',
      refreshToken: refreshToken ?? '',
      accessTokenExpiresAtUtc: parsedExpiry,
      isAuthenticated: isAuthenticated ?? (accessToken != null && accessToken!.isNotEmpty),
    );
  }
}
