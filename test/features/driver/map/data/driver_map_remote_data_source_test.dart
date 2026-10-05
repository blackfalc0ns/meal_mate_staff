import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_services.dart';
import 'package:meal_mate_delivery/features/driver/map/data/data_source/driver_map_remote_data_source.dart';
import 'package:meal_mate_delivery/features/driver/map/data/data_source/driver_map_remote_data_source_impl.dart';
import 'package:meal_mate_delivery/features/driver/map/data/models/response/driver_map_route_response_dto.dart';

class _FakeApiServices implements ApiServices {
  String? lastFocusedStopId;
  DriverMapRouteResponseDto responseDto =
      const DriverMapRouteResponseDto(tripId: 'trip_default');

  @override
  Future<DriverMapRouteResponseDto> getDriverMapRoute(
    String? focusedStopId,
  ) async {
    lastFocusedStopId = focusedStopId;
    return responseDto;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeApiServices fakeApiServices;
  late DriverMapRemoteDataSource remoteDataSource;

  setUp(() {
    fakeApiServices = _FakeApiServices();
    remoteDataSource = DriverMapRemoteDataSourceImpl(fakeApiServices);
  });

  group('DriverMapRemoteDataSource', () {
    test('calls getDriverMapRoute with null focusedStopId on initial fetch', () async {
      fakeApiServices.responseDto =
          const DriverMapRouteResponseDto(tripId: 'trip_1');

      final result = await remoteDataSource.getDriverMapRoute();

      expect(result.tripId, 'trip_1');
      expect(fakeApiServices.lastFocusedStopId, isNull);
    });

    test('calls getDriverMapRoute with specified focusedStopId', () async {
      fakeApiServices.responseDto =
          const DriverMapRouteResponseDto(tripId: 'trip_2');

      final result = await remoteDataSource.getDriverMapRoute(
        focusedStopId: 'stop-guid-123',
      );

      expect(result.tripId, 'trip_2');
      expect(fakeApiServices.lastFocusedStopId, 'stop-guid-123');
    });
  });
}
