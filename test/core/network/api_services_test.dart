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
import 'package:meal_mate_delivery/features/device_token/data/models/request/driver_device_token_request_dto.dart';
import 'package:meal_mate_delivery/features/device_token/data/models/request/restaurant_device_token_request_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/request/driver_registration_request_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/request/driver_resubmit_request_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/models/request/reassign_driver_request_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/models/request/resolve_issue_request_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/data/models/request/assign_driver_request_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/data/models/request/report_box_issue_request_dto.dart';

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
      'submitDriverRegistration hits POST EndPoints.driverRegistration with required contract and password',
      () async {
        await apiServices.submitDriverRegistration(
          const DriverRegistrationRequestDto(
            restaurantId: '898259c1-4064-434e-ad20-be885987d8cb',
            fullNameAr: 'أحمد',
            fullNameEn: 'Ahmed',
            phone: '+96551234001',
            password: 'Password123!',
            nationalId: '1234567890',
            nationalIdExpiry: '2029-01-01T00:00:00Z',
            nationality: 'Kuwaiti',
            vehicleType: 'Car',
            vehicleModel: 'Camry',
            vehiclePlate: '1234',
            vehicleYear: 2023,
            isVehicleOwned: true,
            licenseNumber: 'LIC-1',
            licenseExpiry: '2029-01-01T00:00:00Z',
            vehicleLicenseExpiry: '2029-01-01T00:00:00Z',
            nationalIdFrontStorageKey: 'drivers/temp/civil_id_front.jpg',
            nationalIdBackStorageKey: 'drivers/temp/civil_id_back.jpg',
            drivingLicenseFrontStorageKey:
                'drivers/temp/driving_license_front.jpg',
            drivingLicenseBackStorageKey:
                'drivers/temp/driving_license_back.jpg',
            vehicleRegistrationStorageKey:
                'drivers/temp/vehicle_registration.jpg',
          ),
        );
        expect(capturedOptions.method, 'POST');
        expect(capturedOptions.path, EndPoints.driverRegistration);

        final body = capturedOptions.data as Map<String, dynamic>;
        expect(
          body,
          containsPair('restaurantId', '898259c1-4064-434e-ad20-be885987d8cb'),
        );
        expect(body, containsPair('phone', '+96551234001'));
        expect(body, containsPair('password', 'Password123!'));
        expect(body, containsPair('vehicleType', 'Car'));
        expect(body['email'], isNull);
        expect(body['contractExpiry'], isNull);
        expect(
          body['nationalIdFrontStorageKey'],
          'drivers/temp/civil_id_front.jpg',
        );
        expect(
          body['drivingLicenseFrontStorageKey'],
          'drivers/temp/driving_license_front.jpg',
        );
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
      'upsertDriverDeviceToken hits POST EndPoints.driverDeviceToken with registrationId',
      () async {
        await apiServices.upsertDriverDeviceToken(
          const DriverDeviceTokenRequestDto(
            token: 'fcm-driver-token',
            platform: 'Android',
            deviceId: 'device-123',
            registrationId: 'reg-456',
          ),
        );
        expect(capturedOptions.method, 'POST');
        expect(capturedOptions.path, EndPoints.driverDeviceToken);
        expect(capturedOptions.data, {
          'token': 'fcm-driver-token',
          'platform': 'Android',
          'deviceId': 'device-123',
          'registrationId': 'reg-456',
        });
      },
    );

    test(
      'deactivateDriverDeviceToken hits DELETE EndPoints.driverDeviceToken with query token',
      () async {
        await apiServices.deactivateDriverDeviceToken('fcm-driver-token');
        expect(capturedOptions.method, 'DELETE');
        expect(capturedOptions.path, EndPoints.driverDeviceToken);
        expect(capturedOptions.queryParameters['token'], 'fcm-driver-token');
      },
    );

    test(
      'upsertRestaurantDeviceTokens hits PUT EndPoints.restaurantDeviceTokens',
      () async {
        await apiServices.upsertRestaurantDeviceTokens(
          const RestaurantDeviceTokenRequestDto(
            token: 'fcm-manager-token',
            platform: 'iOS',
            deviceId: 'device-789',
          ),
        );
        expect(capturedOptions.method, 'PUT');
        expect(capturedOptions.path, EndPoints.restaurantDeviceTokens);
        expect(capturedOptions.data, {
          'token': 'fcm-manager-token',
          'platform': 'iOS',
          'deviceId': 'device-789',
        });
      },
    );

    test(
      'deactivateRestaurantDeviceTokens hits DELETE EndPoints.restaurantDeviceTokens with query token',
      () async {
        await apiServices.deactivateRestaurantDeviceTokens('fcm-manager-token');
        expect(capturedOptions.method, 'DELETE');
        expect(capturedOptions.path, EndPoints.restaurantDeviceTokens);
        expect(capturedOptions.queryParameters['token'], 'fcm-manager-token');
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

    test('getDispatcherDriversRoster hits GET EndPoints.dispatcherDriversRoster', () async {
      await apiServices.getDispatcherDriversRoster(
        view: 'ByArea',
        area: 'salmiya',
        boxId: 'a1111111-1111-1111-1111-111111111111',
      );
      expect(capturedOptions.method, 'GET');
      expect(capturedOptions.path, EndPoints.dispatcherDriversRoster);
      expect(capturedOptions.queryParameters['view'], 'ByArea');
      expect(capturedOptions.queryParameters['area'], 'salmiya');
      expect(capturedOptions.queryParameters['boxId'], 'a1111111-1111-1111-1111-111111111111');
    });

    test('assignDriverToBox hits POST EndPoints.dispatcherAssignOrder with path substitution', () async {
      const boxId = 'a1111111-1111-1111-1111-111111111111';
      const driverId = '11111111-1111-1111-1111-111111111111';
      await apiServices.assignDriverToBox(
        boxId,
        const AssignDriverRequestDto(
          driverId: driverId,
          notes: 'إسناد مباشر من قائمة السائقين',
        ),
      );
      expect(capturedOptions.method, 'POST');
      expect(capturedOptions.path, '/api/v1/dispatcher/orders/$boxId/assign');
      expect(capturedOptions.data, {
        'driverId': driverId,
        'notes': 'إسناد مباشر من قائمة السائقين',
      });
    });

    test('getAssignBoxDetails hits GET EndPoints.dispatcherAssignmentDetails with path substitution', () async {
      const boxId = 'a1111111-1111-1111-1111-111111111111';
      await apiServices.getAssignBoxDetails(boxId);
      expect(capturedOptions.method, 'GET');
      expect(capturedOptions.path, '/api/v1/dispatcher/orders/$boxId/assignment-details');
    });

    test('getAssignBoxSummary hits GET EndPoints.dispatcherOrderSummary with path substitution', () async {
      const boxId = 'a1111111-1111-1111-1111-111111111111';
      await apiServices.getAssignBoxSummary(boxId);
      expect(capturedOptions.method, 'GET');
      expect(capturedOptions.path, '/api/v1/dispatcher/orders/$boxId/summary');
    });

    test('getBoxTracking hits GET EndPoints.dispatcherOrderTracking with path substitution', () async {
      const boxId = '4f8a3c21-9b12-42e7-90c1-872f2316e110';
      await apiServices.getBoxTracking(boxId);
      expect(capturedOptions.method, 'GET');
      expect(capturedOptions.path, '/api/v1/dispatcher/orders/$boxId/tracking');
    });

    test('reportBoxIssue hits POST EndPoints.dispatcherOrderIssues with path substitution and request body', () async {
      const boxId = '4f8a3c21-9b12-42e7-90c1-872f2316e110';
      await apiServices.reportBoxIssue(
        boxId,
        const ReportBoxIssueRequestDto(
          issueType: 'DelayedDelivery',
          description: 'Traffic delay',
          severity: 'Medium',
        ),
      );
      expect(capturedOptions.method, 'POST');
      expect(capturedOptions.path, '/api/v1/dispatcher/orders/$boxId/issues');
      expect(capturedOptions.data, {
        'issueType': 'DelayedDelivery',
        'description': 'Traffic delay',
        'severity': 'Medium',
      });
    });

    test('getDispatcherDriverDetails hits GET EndPoints.dispatcherDriverDetails with path substitution', () async {
      const driverId = '4a6f235e-c04d-45db-9c3f-c39775c96da9';
      await apiServices.getDispatcherDriverDetails(driverId);
      expect(capturedOptions.method, 'GET');
      expect(capturedOptions.path, '/api/v1/dispatcher/drivers/$driverId/details');
    });

    test('getDispatcherDriverActiveBoxes hits GET EndPoints.dispatcherDriverActiveBoxes with path substitution', () async {
      const driverId = '4a6f235e-c04d-45db-9c3f-c39775c96da9';
      await apiServices.getDispatcherDriverActiveBoxes(driverId);
      expect(capturedOptions.method, 'GET');
      expect(capturedOptions.path, '/api/v1/dispatcher/drivers/$driverId/active-boxes');
    });

    test('getDispatcherDriverCurrentLocation hits GET EndPoints.dispatcherDriverCurrentLocation with path substitution', () async {
      const driverId = '4a6f235e-c04d-45db-9c3f-c39775c96da9';
      await apiServices.getDispatcherDriverCurrentLocation(driverId);
      expect(capturedOptions.method, 'GET');
      expect(capturedOptions.path, '/api/v1/dispatcher/drivers/$driverId/current-location');
    });
  });
}

