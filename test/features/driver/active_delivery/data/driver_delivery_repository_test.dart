import 'dart:io';
import 'package:meal_mate_delivery/features/driver/active_delivery/data/models/response/driver_start_delivery_response_dto.dart';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/data/data_source/driver_delivery_remote_data_source.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/data/models/request/driver_arrival_request_dto.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/data/models/request/driver_deliver_request_dto.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/data/models/response/driver_arrival_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/data/models/response/driver_deliver_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/data/models/response/driver_delivery_proof_upload_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/data/repo/driver_delivery_repository_impl.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/driver_arrival_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/driver_deliver_request_entity.dart';

class FakeDriverDeliveryRemoteDataSource
    implements DriverDeliveryRemoteDataSource {
  DriverArrivalResponseDto? arrivalResponse;
  DriverDeliverResponseDto? deliverResponse;
  DriverDeliveryProofUploadResponseDto? uploadResponse;
  Exception? throwError;

  @override
  Future<DriverStartDeliveryResponseDto> startDelivery({
    required String boxId,
  }) async => DriverStartDeliveryResponseDto(boxId: boxId, status: 'InTransit');

  @override
  Future<DriverArrivalResponseDto> arriveAtCustomer({
    required String boxId,
    required DriverArrivalRequestDto request,
  }) async {
    if (throwError != null) throw throwError!;
    return arrivalResponse!;
  }

  @override
  Future<DriverDeliverResponseDto> deliverOrder({
    required String boxId,
    required DriverDeliverRequestDto request,
  }) async {
    if (throwError != null) throw throwError!;
    return deliverResponse!;
  }

  @override
  Future<DriverDeliveryProofUploadResponseDto> uploadProof({
    required File file,
  }) async {
    if (throwError != null) throw throwError!;
    return uploadResponse!;
  }
}

void main() {
  group('DriverDeliveryRepositoryImpl Tests', () {
    late FakeDriverDeliveryRemoteDataSource fakeDataSource;
    late DriverDeliveryRepositoryImpl repository;

    setUp(() {
      fakeDataSource = FakeDriverDeliveryRemoteDataSource();
      repository = DriverDeliveryRepositoryImpl(fakeDataSource);
    });

    test(
      'arriveAtCustomer returns ApiSuccessResult on remote success',
      () async {
        fakeDataSource.arrivalResponse = const DriverArrivalResponseDto(
          boxId: 'box-1',
          arrivedAtUtc: '2026-10-06T08:35:00Z',
          isFirstArrival: true,
        );

        final result = await repository.arriveAtCustomer(
          boxId: 'box-1',
          request: const DriverArrivalRequestEntity(),
        );

        expect(result, isA<ApiSuccessResult>());
        final success = result as ApiSuccessResult;
        expect(success.data.boxId, 'box-1');
        expect(success.data.isFirstArrival, isTrue);
      },
    );

    test('arriveAtCustomer returns ApiErrorResult on DioException', () async {
      fakeDataSource.throwError = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/arrive'),
        response: Response(
          requestOptions: RequestOptions(path: '/arrive'),
          statusCode: 404,
          data: {'code': 'DriverMap.StopNotFound', 'message': 'Stop not found'},
        ),
      );

      final result = await repository.arriveAtCustomer(
        boxId: 'box-1',
        request: const DriverArrivalRequestEntity(),
      );

      expect(result, isA<ApiErrorResult>());
      final error = result as ApiErrorResult;
      expect(error.failure, isA<ServerFailure>());
      expect(error.failure.code, 'DriverMap.StopNotFound');
    });

    test('deliverOrder returns ApiSuccessResult on success', () async {
      fakeDataSource.deliverResponse = const DriverDeliverResponseDto(
        boxId: 'box-1',
        deliveredAtUtc: '2026-10-06T08:45:00Z',
        isFirstDelivery: true,
        isTripCompleted: false,
        remainingStopsCount: 1,
      );

      final result = await repository.deliverOrder(
        boxId: 'box-1',
        request: const DriverDeliverRequestEntity(
          proofPhotoStorageKey: 'key-123',
        ),
      );

      expect(result, isA<ApiSuccessResult>());
      final success = result as ApiSuccessResult;
      expect(success.data.boxId, 'box-1');
      expect(success.data.isFirstDelivery, isTrue);
      expect(success.data.remainingStopsCount, 1);
    });

    test('uploadProof returns ApiErrorResult if storageKey is empty', () async {
      fakeDataSource.uploadResponse =
          const DriverDeliveryProofUploadResponseDto(storageKey: '');

      final result = await repository.uploadProof(localPath: 'test_photo.jpg');

      expect(result, isA<ApiErrorResult>());
    });

    test('uploadProof returns ApiSuccessResult when key is present', () async {
      fakeDataSource.uploadResponse =
          const DriverDeliveryProofUploadResponseDto(
            storageKey: 'uploads/drivers/delivery/proof.jpg',
            uploadedAtUtc: '2026-10-06T08:40:00Z',
          );

      final result = await repository.uploadProof(localPath: 'test_photo.jpg');

      expect(result, isA<ApiSuccessResult>());
      final success = result as ApiSuccessResult;
      expect(success.data.storageKey, 'uploads/drivers/delivery/proof.jpg');
    });
  });
}
