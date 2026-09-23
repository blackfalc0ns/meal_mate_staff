import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_active_box_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_current_location_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_daily_summary_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_details_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_details_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_kpis_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_profile_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/repo/driver_details_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/usecase/get_driver_active_boxes_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/usecase/get_driver_current_location_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/usecase/get_driver_details_usecase.dart';

class FakeDriverDetailsRepository implements DriverDetailsRepository {
  int getDetailsCalls = 0;
  int getActiveBoxesCalls = 0;
  int getCurrentLocationCalls = 0;
  String? lastDriverId;

  @override
  Future<ApiResult<DriverDetailsEntity>> getDetails(String driverId) async {
    getDetailsCalls++;
    lastDriverId = driverId;
    return const ApiSuccessResult(
      data: DriverDetailsEntity(
        driver: DriverProfileEntity(
          driverId: '4a6f235e-c04d-45db-9c3f-c39775c96da9',
          driverCode: 'DR-1025',
          fullName: 'أحمد السعيد',
          status: DriverDetailsStatus.available,
          statusText: 'متاح',
          lastUpdatedText: 'الآن',
        ),
        kpis: DriverKpisEntity(
          performanceRating: 4.8,
          avgDelayMinutes: 12,
          deliveredTodayCount: 28,
          activeBoxesCount: 2,
        ),
        dailySummary: DriverDailySummaryEntity(
          approxKm: 120,
          avgDelayMinutes: 12,
          failedDeliveryCount: 1,
          deliveredCount: 28,
        ),
      ),
    );
  }

  @override
  Future<ApiResult<List<DriverActiveBoxEntity>>> getActiveBoxes(
    String driverId,
  ) async {
    getActiveBoxesCalls++;
    lastDriverId = driverId;
    return const ApiSuccessResult(data: []);
  }

  @override
  Future<ApiResult<DriverCurrentLocationEntity>> getCurrentLocation(
    String driverId,
  ) async {
    getCurrentLocationCalls++;
    lastDriverId = driverId;
    return const ApiSuccessResult(
      data: DriverCurrentLocationEntity(
        statusBadgeText: 'مباشر',
        timeAgoText: 'الآن',
        streetName: 'شارع الملك فهد',
        areaName: 'حي العليا',
      ),
    );
  }
}

void main() {
  late FakeDriverDetailsRepository repository;
  late GetDriverDetailsUseCase getDetailsUseCase;
  late GetDriverActiveBoxesUseCase getActiveBoxesUseCase;
  late GetDriverCurrentLocationUseCase getCurrentLocationUseCase;

  const validDriverId = '4a6f235e-c04d-45db-9c3f-c39775c96da9';

  setUp(() {
    repository = FakeDriverDetailsRepository();
    getDetailsUseCase = GetDriverDetailsUseCase(repository);
    getActiveBoxesUseCase = GetDriverActiveBoxesUseCase(repository);
    getCurrentLocationUseCase = GetDriverCurrentLocationUseCase(repository);
  });

  group('Driver Details UseCases validation & execution', () {
    test('rejects blank driverId locally without calling repository', () async {
      final result1 = await getDetailsUseCase('');
      final result2 = await getActiveBoxesUseCase('   ');
      final result3 = await getCurrentLocationUseCase('');

      expect(result1, isA<ApiErrorResult>());
      expect(result2, isA<ApiErrorResult>());
      expect(result3, isA<ApiErrorResult>());

      expect(repository.getDetailsCalls, 0);
      expect(repository.getActiveBoxesCalls, 0);
      expect(repository.getCurrentLocationCalls, 0);
    });

    test(
      'rejects non-GUID driverId locally without calling repository',
      () async {
        final result = await getDetailsUseCase('not-a-valid-guid');

        expect(result, isA<ApiErrorResult>());
        expect(repository.getDetailsCalls, 0);
      },
    );

    test('trims and forwards valid GUID to repository', () async {
      final resultDetails = await getDetailsUseCase('  $validDriverId  ');
      expect(resultDetails, isA<ApiSuccessResult>());
      expect(repository.getDetailsCalls, 1);
      expect(repository.lastDriverId, validDriverId);

      final resultBoxes = await getActiveBoxesUseCase('  $validDriverId  ');
      expect(resultBoxes, isA<ApiSuccessResult>());
      expect(repository.getActiveBoxesCalls, 1);
      expect(repository.lastDriverId, validDriverId);

      final resultLocation = await getCurrentLocationUseCase(
        '  $validDriverId  ',
      );
      expect(resultLocation, isA<ApiSuccessResult>());
      expect(repository.getCurrentLocationCalls, 1);
      expect(repository.lastDriverId, validDriverId);
    });
  });
}
