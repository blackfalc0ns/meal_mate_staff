import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_services.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/models/request/update_driver_availability_request_dto.dart';

void main() {
  for (final active in [true, false]) {
    test(
      'sends PATCH shift-status with ${active ? 'Active' : 'Inactive'}',
      () async {
        final dio = Dio();
        late RequestOptions captured;
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              captured = options;
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: <String, dynamic>{},
                  statusCode: 200,
                ),
              );
            },
          ),
        );

        const driverId = '52a408f2-94d4-4c7d-bfaf-3e9017eb0d49';
        await ApiServices(dio).updateDispatcherDriverAvailability(
          driverId,
          UpdateDriverAvailabilityRequestDto(
            isAvailable: active,
            reason: 'test',
          ),
        );

        expect(captured.method, 'PATCH');
        expect(
          captured.path,
          '/api/v1/dispatcher/drivers/$driverId/shift-status',
        );
        expect(captured.contentType, 'application/json');
        expect(captured.data, {'shiftStatus': active ? 'Active' : 'Inactive'});
        dio.close();
      },
    );
  }
}
