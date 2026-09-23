import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_services.dart';
import 'package:meal_mate_delivery/core/network/network_constants.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/forgot_password_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/phone_lookup_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/refresh_token_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/resend_otp_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/reset_password_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/set_password_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/staff_login_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/verify_first_time_otp_request_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/request/driver_registration_request_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/request/driver_resubmit_request_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/models/request/reassign_driver_request_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/models/request/resolve_issue_request_dto.dart';

void main() {
  late Dio dio;
  late ApiServices apiServices;
  late RequestOptions capturedOptions;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: NetworkConstants.baseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedOptions = options;
          dynamic responseData = <String, dynamic>{};
          if (options.path == EndPoints.driverRestaurants ||
              options.path == EndPoints.driverNationalities) {
            responseData = <dynamic>[];
          }
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: responseData,
            ),
          );
        },
      ),
    );
    apiServices = ApiServices(dio);
  });

  group('ApiServices endpoint contract tests', () {
    test('lookupPhone hits POST EndPoints.lookupPhone', () async {
      await apiServices.lookupPhone(
        const PhoneLookupRequestDto(phone: '+966501234567', role: 'Driver'),
      );
      expect(capturedOptions.method, 'POST');
      expect(capturedOptions.path, EndPoints.lookupPhone);
      expect(capturedOptions.data, {
        'phone': '+966501234567',
        'role': 'Driver',
      });
    });

    test('verifyFirstTimeOtp hits POST EndPoints.verifyFirstTimeOtp', () async {
      await apiServices.verifyFirstTimeOtp(
        const VerifyFirstTimeOtpRequestDto(
          phone: '+966501234567',
          role: 'Driver',
          otpCode: '123456',
        ),
      );
      expect(capturedOptions.method, 'POST');
      expect(capturedOptions.path, EndPoints.verifyFirstTimeOtp);
      expect(capturedOptions.data['otpCode'], '123456');
    });

    test('setPassword hits POST EndPoints.setPassword', () async {
      await apiServices.setPassword(
        const SetPasswordRequestDto(
          phone: '+966501234567',
          role: 'Driver',
          verificationToken: 'token-xyz',
          newPassword: 'Password@123',
          confirmPassword: 'Password@123',
        ),
      );
      expect(capturedOptions.method, 'POST');
      expect(capturedOptions.path, EndPoints.setPassword);
      expect(capturedOptions.data['verificationToken'], 'token-xyz');
    });

    test('login hits POST EndPoints.login', () async {
      await apiServices.login(
        const StaffLoginRequestDto(
          phone: '+966501234567',
          role: 'Driver',
          password: 'Password@123',
        ),
      );
      expect(capturedOptions.method, 'POST');
      expect(capturedOptions.path, EndPoints.login);
      expect(capturedOptions.data['password'], 'Password@123');
    });

    test('forgotPassword hits POST EndPoints.forgotPassword', () async {
      await apiServices.forgotPassword(
        const ForgotPasswordRequestDto(phone: '+966501234567', role: 'Driver'),
      );
      expect(capturedOptions.method, 'POST');
      expect(capturedOptions.path, EndPoints.forgotPassword);
    });

    test('resetPassword hits POST EndPoints.resetPassword', () async {
      await apiServices.resetPassword(
        const ResetPasswordRequestDto(
          phone: '+966501234567',
          role: 'Driver',
          otpCode: '123456',
          newPassword: 'NewPassword@123',
          confirmPassword: 'NewPassword@123',
        ),
      );
      expect(capturedOptions.method, 'POST');
      expect(capturedOptions.path, EndPoints.resetPassword);
    });

    test('resendOtp hits POST EndPoints.resendOtp', () async {
      await apiServices.resendOtp(
        const ResendOtpRequestDto(phone: '+966501234567', role: 'Driver'),
      );
      expect(capturedOptions.method, 'POST');
      expect(capturedOptions.path, EndPoints.resendOtp);
    });

    test('refreshToken hits POST EndPoints.refresh', () async {
      await apiServices.refreshToken(
        const RefreshTokenRequestDto(refreshToken: 'refresh-xyz'),
      );
      expect(capturedOptions.method, 'POST');
      expect(capturedOptions.path, EndPoints.refresh);
    });

    test('getDriverRestaurants hits GET EndPoints.driverRestaurants', () async {
      await apiServices.getDriverRestaurants();
      expect(capturedOptions.method, 'GET');
      expect(capturedOptions.path, EndPoints.driverRestaurants);
    });

    test(
      'getDriverNationalities hits GET EndPoints.driverNationalities',
      () async {
        await apiServices.getDriverNationalities();
        expect(capturedOptions.method, 'GET');
        expect(capturedOptions.path, EndPoints.driverNationalities);
      },
    );

    test(
      'submitDriverRegistration hits POST EndPoints.driverRegistration',
      () async {
        await apiServices.submitDriverRegistration(
          const DriverRegistrationRequestDto(
            restaurantId: 'rest-1',
            fullNameAr: 'أحمد',
            fullNameEn: 'Ahmed',
            phone: '+966501234567',
            nationalId: '1234567890',
            nationalIdExpiry: '2029-01-01T00:00:00Z',
            nationality: 'Saudi',
            vehicleType: 'Car',
            vehicleModel: 'Camry',
            vehiclePlate: '1234',
            vehicleYear: 2023,
            isVehicleOwned: true,
            licenseNumber: 'LIC-1',
            licenseExpiry: '2029-01-01T00:00:00Z',
            vehicleLicenseExpiry: '2029-01-01T00:00:00Z',
            nationalIdFrontStorageKey: 'key1',
            nationalIdBackStorageKey: 'key2',
            drivingLicenseFrontStorageKey: 'key3',
            drivingLicenseBackStorageKey: 'key4',
            vehicleRegistrationStorageKey: 'key5',
          ),
        );
        expect(capturedOptions.method, 'POST');
        expect(capturedOptions.path, EndPoints.driverRegistration);
      },
    );

    test(
      'getDriverRegistrationStatus hits GET EndPoints.driverRegistrationStatus with query parameters',
      () async {
        await apiServices.getDriverRegistrationStatus(
          phone: '+966501234567',
          registrationId: 'reg-123',
        );
        expect(capturedOptions.method, 'GET');
        expect(capturedOptions.path, EndPoints.driverRegistrationStatus);
        expect(capturedOptions.queryParameters['phone'], '+966501234567');
        expect(capturedOptions.queryParameters['registrationId'], 'reg-123');
      },
    );

    test(
      'resubmitDriverRegistration hits POST EndPoints.driverRegistrationResubmit',
      () async {
        await apiServices.resubmitDriverRegistration(
          'reg-123',
          const DriverResubmitRequestDto(
            vehicleLicenseExpiry: '2029-01-01T00:00:00Z',
          ),
        );
        expect(capturedOptions.method, 'POST');
        expect(
          capturedOptions.path,
          EndPoints.driverRegistrationResubmit.replaceAll(
            '{registrationId}',
            'reg-123',
          ),
        );
      },
    );

    test(
      'getDispatcherSupportIssues hits GET EndPoints.dispatcherSupportIssues with query parameters',
      () async {
        await apiServices.getDispatcherSupportIssues(
          area: 'Al Malqa',
          status: 'Open',
          search: 'box-1',
          datePreset: 'Last7Days',
          fromDateUtc: '2026-09-01T00:00:00.000Z',
          toDateUtc: '2026-09-22T00:00:00.000Z',
          pageNumber: 1,
          pageSize: 20,
        );
        expect(capturedOptions.method, 'GET');
        expect(capturedOptions.path, EndPoints.dispatcherSupportIssues);
        expect(capturedOptions.queryParameters, {
          'area': 'Al Malqa',
          'status': 'Open',
          'search': 'box-1',
          'datePreset': 'Last7Days',
          'fromDateUtc': '2026-09-01T00:00:00.000Z',
          'toDateUtc': '2026-09-22T00:00:00.000Z',
          'pageNumber': 1,
          'pageSize': 20,
        });
      },
    );

    test(
      'getDispatcherIssueDetails hits GET EndPoints.dispatcherSupportIssues/{issueId}',
      () async {
        await apiServices.getDispatcherIssueDetails('issue-123');
        expect(capturedOptions.method, 'GET');
        expect(
          capturedOptions.path,
          '${EndPoints.dispatcherSupportIssues}/issue-123',
        );
      },
    );

    test(
      'resolveDispatcherIssue hits POST EndPoints.dispatcherSupportIssues/{issueId}/resolve',
      () async {
        await apiServices.resolveDispatcherIssue(
          'issue-123',
          const ResolveIssueRequestDto(resolutionNotes: 'Notes'),
        );
        expect(capturedOptions.method, 'POST');
        expect(
          capturedOptions.path,
          '${EndPoints.dispatcherSupportIssues}/issue-123/resolve',
        );
        expect(capturedOptions.data, {'resolutionNotes': 'Notes'});
      },
    );

    test(
      'getReplacementDriverCandidates hits GET EndPoints.dispatcherSupportIssues/{issueId}/candidates',
      () async {
        await apiServices.getReplacementDriverCandidates('issue-123', 1, 20);
        expect(capturedOptions.method, 'GET');
        expect(
          capturedOptions.path,
          '${EndPoints.dispatcherSupportIssues}/issue-123/candidates',
        );
        expect(capturedOptions.queryParameters, {
          'pageNumber': 1,
          'pageSize': 20,
        });
      },
    );

    test(
      'reassignDispatcherIssue hits POST EndPoints.dispatcherSupportIssues/{issueId}/reassign',
      () async {
        await apiServices.reassignDispatcherIssue(
          'issue-123',
          const ReassignDriverRequestDto(
            replacementDriverId: 'drv-2',
            notes: null,
          ),
        );
        expect(capturedOptions.method, 'POST');
        expect(
          capturedOptions.path,
          '${EndPoints.dispatcherSupportIssues}/issue-123/reassign',
        );
        expect(capturedOptions.data, {'replacementDriverId': 'drv-2'});
      },
    );

    test(
      'getDriverPerformanceOverview hits GET EndPoints.dispatcherPerformanceOverview',
      () async {
        await apiServices.getDriverPerformanceOverview(
          period: 'Last7Days',
          fromDate: null,
          toDate: null,
        );
        expect(capturedOptions.method, 'GET');
        expect(capturedOptions.path, EndPoints.dispatcherPerformanceOverview);
        expect(capturedOptions.queryParameters, {'period': 'Last7Days'});
      },
    );

    test(
      'getDriverPerformanceComparison hits GET EndPoints.dispatcherPerformanceComparison',
      () async {
        await apiServices.getDriverPerformanceComparison(
          period: 'Custom',
          driverIds: ['dr_1', 'dr_2'],
          fromDate: '2025-05-01',
          toDate: '2025-05-07',
        );
        expect(capturedOptions.method, 'GET');
        expect(capturedOptions.path, EndPoints.dispatcherPerformanceComparison);
        expect(capturedOptions.queryParameters, {
          'period': 'Custom',
          'driverIds': ['dr_1', 'dr_2'],
          'fromDate': '2025-05-01',
          'toDate': '2025-05-07',
        });
      },
    );

    test(
      'getDispatcherOperationsLog hits GET EndPoints.dispatcherOperationsLog with query parameters',
      () async {
        await apiServices.getDispatcherOperationsLog(
          status: 'Reassigned',
          datePreset: 'Last7Days',
          pageNumber: 2,
          pageSize: 10,
        );
        expect(capturedOptions.method, 'GET');
        expect(capturedOptions.path, '/api/v1/dispatcher/operations/log');
        expect(
          capturedOptions.queryParameters,
          containsPair('status', 'Reassigned'),
        );
        expect(
          capturedOptions.queryParameters,
          containsPair('datePreset', 'Last7Days'),
        );
        expect(capturedOptions.queryParameters, containsPair('pageNumber', 2));
        expect(capturedOptions.queryParameters, containsPair('pageSize', 10));
        expect(
          capturedOptions.queryParameters.containsKey('restaurantId'),
          isFalse,
        );
      },
    );
  });
}
