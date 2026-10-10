import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/api_services.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/data/data_source/driver_delivery_remote_data_source_impl.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/data/repo/driver_delivery_repository_impl.dart';

const targetBox = 'a64a746f-9872-492a-b373-172310ae89cf';
const tripId = 'ea812470-bd73-491b-a46e-45d088299f39';
const responseFixture = <String, Object?>{
  'boxId': targetBox,
  'tripId': tripId,
  'status': 'InTransit',
  'startedAtUtc': '2026-10-07T09:00:00Z',
  'customer': {
    'name': 'عبدالله العتيبي',
    'address': 'السالمية، قطعة 5',
    'latitude': 29.3337,
    'longitude': 48.0761,
    'notes': 'يرجى الاتصال قبل الوصول',
  },
  'order': {
    'code': 'MM-987654',
    'boxCount': 3,
    'deliveryTimeSlot': '09:00–12:00',
  },
  'navigation': {
    'url':
        'https://www.google.com/maps/dir/?api=1&destination=29.3337,48.0761&travelmode=driving',
  },
};

class StartDeliveryAdapter implements HttpClientAdapter {
  Map<String, Object?> response = responseFixture;
  int statusCode = 200;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(response),
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late StartDeliveryAdapter adapter;
  late DriverDeliveryRepositoryImpl repository;

  setUp(() {
    adapter = StartDeliveryAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    repository = DriverDeliveryRepositoryImpl(
      DriverDeliveryRemoteDataSourceImpl(ApiServices(dio)),
    );
  });
  tearDown(() => dio.close());

  test('starts a trip using its ID rather than a box ID', () async {
    await ApiServices(dio).startDriverDelivery(tripId);
    expect(adapter.requests.single.method, 'POST');
    expect(adapter.requests.single.path, '/api/v1/driver/trips/$tripId/start');
    expect(adapter.requests.single.data, anyOf(isNull, isEmpty));
  });

  test(
    'starts the selected box with a bodyless POST and maps nested response',
    () async {
      final result = await repository.startDelivery(
        boxId: targetBox,
        tripId: tripId,
        latitude: 30,
        longitude: 31,
        idempotencyKey: 'test-key',
      );
      expect(adapter.requests.single.method, 'POST');
      expect(
        adapter.requests.single.path,
        '/api/v1/driver/trips/$tripId/start',
      );
      expect(adapter.requests.single.data, {
        'latitude': 30.0,
        'longitude': 31.0,
      });
      expect(result, isA<ApiSuccessResult>());
      final data = (result as ApiSuccessResult).data;
      expect(data.boxId, targetBox);
      expect(data.tripId, tripId);
      expect(data.status, 'InTransit');
      expect(data.startedAtUtc, DateTime.utc(2026, 10, 7, 9));
      expect(data.customerName, isNull);
    },
  );

  test('preserves ProblemDetails code on failure', () async {
    adapter.statusCode = 409;
    adapter.response = {
      'code': 'Orders.StopStateNotAllowed',
      'detail': 'Cannot start this box',
    };
    final result = await repository.startDelivery(
      boxId: targetBox,
      tripId: tripId,
      latitude: 30,
      longitude: 31,
      idempotencyKey: 'test-key',
    );
    expect(result, isA<ApiErrorResult>());
    expect(
      (result as ApiErrorResult).failure.code,
      'Orders.StopStateNotAllowed',
    );
  });

  test(
    'rejects wrong target or missing transit state instead of confirming start',
    () async {
      for (final response in [
        {...responseFixture, 'tripId': targetBox},
        {...responseFixture, 'status': null},
        <String, Object?>{},
      ]) {
        adapter.response = response;
        expect(
          await repository.startDelivery(
            boxId: targetBox,
            tripId: tripId,
            latitude: 30,
            longitude: 31,
            idempotencyKey: 'test-key',
          ),
          isA<ApiErrorResult>(),
        );
      }
    },
  );

  test(
    'optional nested fields remain absent and markdown is not a navigation URL',
    () async {
      adapter.response = {
        'tripId': tripId,
        'status': 'InTransit',
        'navigation': {'url': '[maps](https://www.google.com/maps/dir/)'},
      };
      final result = await repository.startDelivery(
        boxId: targetBox,
        tripId: tripId,
        latitude: 30,
        longitude: 31,
        idempotencyKey: 'test-key',
      );
      final data = (result as ApiSuccessResult).data;
      expect(data.customerLatitude, isNull);
      expect(data.startedAtUtc, isNull);
      expect(data.boxCount, isNull);
      expect(data.navigationUrl, isNull);
    },
  );
}
