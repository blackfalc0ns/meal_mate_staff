import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/device_token/data/models/request/driver_device_token_request_dto.dart';
import 'package:meal_mate_delivery/features/device_token/data/models/request/restaurant_device_token_request_dto.dart';

void main() {
  group('DriverDeviceTokenRequestDto', () {
    test('serializes with registrationId when provided', () {
      const dto = DriverDeviceTokenRequestDto(
        token: 'fcm-driver-token-123',
        platform: 'Android',
        deviceId: 'device-abc',
        registrationId: 'reg-789',
      );

      final json = dto.toJson();

      expect(json['token'], 'fcm-driver-token-123');
      expect(json['platform'], 'Android');
      expect(json['deviceId'], 'device-abc');
      expect(json['registrationId'], 'reg-789');
    });

    test('omits registrationId key completely when null', () {
      const dto = DriverDeviceTokenRequestDto(
        token: 'fcm-driver-token-123',
        platform: 'iOS',
        deviceId: 'device-abc',
      );

      final json = dto.toJson();

      expect(json['token'], 'fcm-driver-token-123');
      expect(json['platform'], 'iOS');
      expect(json['deviceId'], 'device-abc');
      expect(json.containsKey('registrationId'), isFalse);
    });

    test('deserializes from json correctly', () {
      final json = {
        'token': 'fcm-driver-token-123',
        'platform': 'Android',
        'deviceId': 'device-abc',
        'registrationId': 'reg-789',
      };

      final dto = DriverDeviceTokenRequestDto.fromJson(json);

      expect(dto.token, 'fcm-driver-token-123');
      expect(dto.platform, 'Android');
      expect(dto.deviceId, 'device-abc');
      expect(dto.registrationId, 'reg-789');
    });
  });

  group('RestaurantDeviceTokenRequestDto', () {
    test('serializes required fields correctly', () {
      const dto = RestaurantDeviceTokenRequestDto(
        token: 'fcm-manager-token-456',
        platform: 'iOS',
        deviceId: 'device-xyz',
      );

      final json = dto.toJson();

      expect(json['token'], 'fcm-manager-token-456');
      expect(json['platform'], 'iOS');
      expect(json['deviceId'], 'device-xyz');
    });

    test('deserializes from json correctly', () {
      final json = {
        'token': 'fcm-manager-token-456',
        'platform': 'iOS',
        'deviceId': 'device-xyz',
      };

      final dto = RestaurantDeviceTokenRequestDto.fromJson(json);

      expect(dto.token, 'fcm-manager-token-456');
      expect(dto.platform, 'iOS');
      expect(dto.deviceId, 'device-xyz');
    });
  });
}
