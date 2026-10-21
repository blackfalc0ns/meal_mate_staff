import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/api_services.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/data/mapper/driver_issue_mapper.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/data/models/request/driver_report_issue_request_dto.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/data/models/request/driver_report_delay_request_dto.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/data/data_source/driver_issue_remote_data_source.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/data/data_source/driver_issue_remote_data_source_impl.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/data/repo/driver_issue_repository_impl.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/delivery_issue_reason.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/data/models/response/driver_delivery_proof_upload_response_dto.dart';

class MockApiServices implements ApiServices {
  String? lastReportedBoxId;
  DriverReportIssueRequestDto? lastReportIssueRequest;
  String? lastDelayBoxId;
  DriverReportDelayRequestDto? lastDelayRequest;
  File? lastUploadedFile;

  @override
  Future<String> reportDriverIssue(
    String boxId,
    DriverReportIssueRequestDto request,
  ) async {
    lastReportedBoxId = boxId;
    lastReportIssueRequest = request;
    return 'd1c5c144-2d47-4773-8430-ce38b7b220af';
  }

  @override
  Future<bool> reportDriverDelay(
    String boxId,
    DriverReportDelayRequestDto request,
  ) async {
    lastDelayBoxId = boxId;
    lastDelayRequest = request;
    return true;
  }

  @override
  Future<DriverDeliveryProofUploadResponseDto> uploadDriverIssueEvidence(
    File file,
  ) async {
    lastUploadedFile = file;
    return const DriverDeliveryProofUploadResponseDto(
      storageKey: 'evidence-key-123',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('DriverIssueMapper Tests', () {
    test('all 10 issue types map to the exact backend wire values', () {
      final map = {
        DeliveryIssueReason.addressUnclear: 'AddressIssue',
        DeliveryIssueReason.addressIssue: 'AddressIssue',
        DeliveryIssueReason.severeDelay: 'SevereDelay',
        DeliveryIssueReason.roadIssue: 'RoadIssue',
        DeliveryIssueReason.vehicleBreakdown: 'VehicleBreakdown',
        DeliveryIssueReason.trafficAccident: 'TrafficAccident',
        DeliveryIssueReason.severeWeather: 'SevereWeather',
        DeliveryIssueReason.customerNoAnswer: 'CustomerUnavailable',
        DeliveryIssueReason.customerUnavailable: 'CustomerUnavailable',
        DeliveryIssueReason.refusedDelivery: 'CustomerRefusal',
        DeliveryIssueReason.customerRefusal: 'CustomerRefusal',
        DeliveryIssueReason.boxDamaged: 'DamagedBox',
        DeliveryIssueReason.damagedBox: 'DamagedBox',
        DeliveryIssueReason.other: 'Other',
      };

      for (final entry in map.entries) {
        expect(entry.key.wireValue, equals(entry.value));
        expect(DriverIssueReasonMapper.fromWire(entry.value).wireValue, equals(entry.value));
      }
    });

    test('toDto trims description, caps at 250 chars, defaults severity to Medium, and deduplicates photo keys up to 3', () {
      final longDesc = 'a' * 300;
      final dto = DriverIssueMapper.toReportDto(
        reason: DeliveryIssueReason.vehicleBreakdown,
        description: '  $longDesc  ',
        severity: null,
        photoStorageKeys: ['key-1', 'key-2', 'key-1', 'key-3', 'key-4'],
      );

      expect(dto.issueType, equals('VehicleBreakdown'));
      expect(dto.description?.length, equals(250));
      expect(dto.severity, equals('Medium'));
      expect(dto.evidencePhotoStorageKeys, equals(['key-1', 'key-2', 'key-3']));
      expect(dto.evidencePhotoStorageKey, equals('key-1'));
    });

    test('toReportDto with blank description produces null description', () {
      final dto = DriverIssueMapper.toReportDto(
        reason: DeliveryIssueReason.other,
        description: '    ',
        severity: 'High',
        photoStorageKeys: const [],
      );

      expect(dto.description, isNull);
      expect(dto.severity, equals('High'));
      expect(dto.evidencePhotoStorageKeys, isNull);
      expect(dto.evidencePhotoStorageKey, isNull);
    });

    test('toReportDto filters out local paths, URLs, and asset paths', () {
      final dto = DriverIssueMapper.toReportDto(
        reason: DeliveryIssueReason.boxDamaged,
        description: 'Broken box',
        photoStorageKeys: [
          '/data/user/0/com.mealmate/cache/photo1.jpg',
          r'C:\Users\Photo\img.jpg',
          'https://example.com/photo.png',
          'assets/images/photo.png',
          'valid_storage_key_123',
        ],
      );

      expect(dto.evidencePhotoStorageKeys, equals(['valid_storage_key_123']));
      expect(dto.evidencePhotoStorageKey, equals('valid_storage_key_123'));
    });

    test('DriverReportIssueRequestDto toJson omits null photo keys and includes valid ones', () {
      final dtoWithoutPhotos = DriverIssueMapper.toReportDto(
        reason: DeliveryIssueReason.customerNoAnswer,
        description: 'Customer not answering',
        photoStorageKeys: null,
      );
      final jsonWithoutPhotos = dtoWithoutPhotos.toJson();
      expect(jsonWithoutPhotos.containsKey('evidencePhotoStorageKey'), isFalse);
      expect(jsonWithoutPhotos.containsKey('evidencePhotoStorageKeys'), isFalse);
      expect(jsonWithoutPhotos['issueType'], equals('CustomerUnavailable'));
      expect(jsonWithoutPhotos['description'], equals('Customer not answering'));

      final dtoWithPhotos = DriverIssueMapper.toReportDto(
        reason: DeliveryIssueReason.damagedBox,
        description: 'Damaged item',
        photoStorageKeys: ['key_abc', 'key_def'],
      );
      final jsonWithPhotos = dtoWithPhotos.toJson();
      expect(jsonWithPhotos['evidencePhotoStorageKey'], equals('key_abc'));
      expect(jsonWithPhotos['evidencePhotoStorageKeys'], equals(['key_abc', 'key_def']));
    });

    test('toDelayDto validates delay minutes between 1 and 1440 and trims reason', () {
      final dto = DriverIssueMapper.toDelayDto(
        delayMinutes: 30,
        reason: ' Heavy rain ',
      );

      expect(dto.delayMinutes, equals(30));
      expect(dto.reason, equals('Heavy rain'));

      expect(() => DriverIssueMapper.toDelayDto(delayMinutes: 0), throwsA(isA<ArgumentError>()));
      expect(() => DriverIssueMapper.toDelayDto(delayMinutes: 1441), throwsA(isA<ArgumentError>()));
    });
  });

  group('DriverIssueRepositoryImpl Tests', () {
    late MockApiServices mockApi;
    late DriverIssueRemoteDataSource dataSource;
    late DriverIssueRepositoryImpl repository;

    setUp(() {
      mockApi = MockApiServices();
      dataSource = DriverIssueRemoteDataSourceImpl(mockApi);
      repository = DriverIssueRepositoryImpl(dataSource);
    });

    test('reportIssue calls dataSource and returns bare UUID on success', () async {
      const boxId = 'box-uuid-123';
      final result = await repository.reportIssue(
        boxId: boxId,
        reason: DeliveryIssueReason.trafficAccident,
        description: 'Minor collision',
        severity: 'High',
        photoStorageKeys: ['key-1', 'key-2'],
      );

      expect(result, isA<ApiSuccessResult<String>>());
      final success = result as ApiSuccessResult<String>;
      expect(success.data, equals('d1c5c144-2d47-4773-8430-ce38b7b220af'));
      expect(mockApi.lastReportedBoxId, equals(boxId));
      expect(mockApi.lastReportIssueRequest?.issueType, equals('TrafficAccident'));
      expect(mockApi.lastReportIssueRequest?.severity, equals('High'));
    });

    test('reportDelay calls dataSource and returns boolean true on success', () async {
      const boxId = 'box-uuid-123';
      final result = await repository.reportDelay(
        boxId: boxId,
        delayMinutes: 20,
        reason: 'Traffic congestion',
      );

      expect(result, isA<ApiSuccessResult<bool>>());
      final success = result as ApiSuccessResult<bool>;
      expect(success.data, isTrue);
      expect(mockApi.lastDelayBoxId, equals(boxId));
      expect(mockApi.lastDelayRequest?.delayMinutes, equals(20));
      expect(mockApi.lastDelayRequest?.reason, equals('Traffic congestion'));
    });

    test('uploadEvidence returns storage key from uploads endpoint', () async {
      final tempFile = File('${Directory.systemTemp.path}/test_evidence.png');
      await tempFile.writeAsBytes([1, 2, 3]);

      final result = await repository.uploadEvidence(tempFile);

      expect(result, isA<ApiSuccessResult<String>>());
      final success = result as ApiSuccessResult<String>;
      expect(success.data, equals('evidence-key-123'));
      expect(mockApi.lastUploadedFile?.path, equals(tempFile.path));

      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    });
  });
}
