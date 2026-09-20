import '../../domain/entities/forgot_password_request_entity.dart';
import '../../domain/entities/phone_lookup_request_entity.dart';
import '../../domain/entities/resend_otp_request_entity.dart';
import '../../domain/entities/reset_password_request_entity.dart';
import '../../domain/entities/set_password_request_entity.dart';
import '../../domain/entities/staff_login_request_entity.dart';
import '../../domain/entities/verify_first_time_otp_request_entity.dart';
import '../models/request/forgot_password_request_dto.dart';
import '../models/request/phone_lookup_request_dto.dart';
import '../models/request/resend_otp_request_dto.dart';
import '../models/request/reset_password_request_dto.dart';
import '../models/request/set_password_request_dto.dart';
import '../models/request/staff_login_request_dto.dart';
import '../models/request/verify_first_time_otp_request_dto.dart';
import 'staff_role_mapper.dart';

extension PhoneLookupRequestEntityMapper on PhoneLookupRequestEntity {
  PhoneLookupRequestDto toDto() {
    return PhoneLookupRequestDto(
      phone: phone,
      role: role.toApiValue(),
    );
  }
}

extension VerifyFirstTimeOtpRequestEntityMapper
    on VerifyFirstTimeOtpRequestEntity {
  VerifyFirstTimeOtpRequestDto toDto() {
    return VerifyFirstTimeOtpRequestDto(
      phone: phone,
      role: role.toApiValue(),
      otpCode: otpCode,
    );
  }
}

extension SetPasswordRequestEntityMapper on SetPasswordRequestEntity {
  SetPasswordRequestDto toDto() {
    return SetPasswordRequestDto(
      phone: phone,
      role: role.toApiValue(),
      verificationToken: verificationToken,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}

extension StaffLoginRequestEntityMapper on StaffLoginRequestEntity {
  StaffLoginRequestDto toDto() {
    return StaffLoginRequestDto(
      phone: phone,
      role: role.toApiValue(),
      password: password,
    );
  }
}

extension ForgotPasswordRequestEntityMapper on ForgotPasswordRequestEntity {
  ForgotPasswordRequestDto toDto() {
    return ForgotPasswordRequestDto(
      phone: phone,
      role: role.toApiValue(),
    );
  }
}

extension ResetPasswordRequestEntityMapper on ResetPasswordRequestEntity {
  ResetPasswordRequestDto toDto() {
    return ResetPasswordRequestDto(
      phone: phone,
      role: role.toApiValue(),
      otpCode: otpCode,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}

extension ResendOtpRequestEntityMapper on ResendOtpRequestEntity {
  ResendOtpRequestDto toDto() {
    return ResendOtpRequestDto(
      phone: phone,
      role: role.toApiValue(),
    );
  }
}
