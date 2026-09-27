import 'package:injectable/injectable.dart';
import '../../../../../core/constants/assets_fake.dart';
import '../models/response/dispatcher_drivers_status_response_dto.dart';
import 'dispatcher_drivers_status_remote_data_source.dart';

@LazySingleton(as: DispatcherDriversStatusRemoteDataSource)
class DispatcherDriversStatusRemoteDataSourceImpl
    implements DispatcherDriversStatusRemoteDataSource {
  const DispatcherDriversStatusRemoteDataSourceImpl();

  @override
  Future<DispatcherDriversStatusResponseDto> getDriversStatus() async {
    // Simulated remote network delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return const DispatcherDriversStatusResponseDto(
      restaurantName: 'مطعم MealMate الكويت',
      role: 'Dispatcher',
      kpis: DispatcherDriversStatusKpisDto(
        connectedCount: 12,
        inDeliveryCount: 8,
        offlineCount: 6,
        totalCount: 26,
      ),
      drivers: [
        DispatcherDriverStatusItemDto(
          id: '4a6f235e-c04d-45db-9c3f-c39775c96da1',
          name: 'أحمد محمد',
          code: '#37262828',
          avatarUrl: AssetsFake.driverAvatar,
          rating: 4.8,
          vehicleType: 'سيارة',
          plateNumber: '#KU-3719',
          status: 'available',
          isAvailable: true,
        ),
        DispatcherDriverStatusItemDto(
          id: '4a6f235e-c04d-45db-9c3f-c39775c96da2',
          name: 'محمد سالم',
          code: '#37262828',
          avatarUrl: AssetsFake.driverAvatar,
          rating: 4.6,
          vehicleType: 'سيارة',
          plateNumber: '#KU-3719',
          status: 'available',
          isAvailable: true,
        ),
        DispatcherDriverStatusItemDto(
          id: '4a6f235e-c04d-45db-9c3f-c39775c96da3',
          name: 'عبدالله علي',
          code: '#37262828',
          avatarUrl: AssetsFake.driverAvatar,
          rating: 4.5,
          vehicleType: 'سيارة',
          plateNumber: '#KU-3719',
          status: 'offline',
          isAvailable: false,
        ),
        DispatcherDriverStatusItemDto(
          id: '4a6f235e-c04d-45db-9c3f-c39775c96da4',
          name: 'سالم ناصر',
          code: '#37262828',
          avatarUrl: AssetsFake.driverAvatar,
          rating: 4.7,
          vehicleType: 'سيارة',
          plateNumber: '#KU-3719',
          status: 'available',
          isAvailable: true,
        ),
        DispatcherDriverStatusItemDto(
          id: '4a6f235e-c04d-45db-9c3f-c39775c96da5',
          name: 'فهد العتيبي',
          code: '#37262828',
          avatarUrl: AssetsFake.driverAvatar,
          rating: 4.4,
          vehicleType: 'سيارة',
          plateNumber: '#KU-3719',
          status: 'offline',
          isAvailable: false,
        ),
        DispatcherDriverStatusItemDto(
          id: '4a6f235e-c04d-45db-9c3f-c39775c96da6',
          name: 'محمود خالد',
          code: '#37262828',
          avatarUrl: AssetsFake.driverAvatar,
          rating: 4.9,
          vehicleType: 'سيارة',
          plateNumber: '#KU-3719',
          status: 'available',
          isAvailable: true,
        ),
        DispatcherDriverStatusItemDto(
          id: '4a6f235e-c04d-45db-9c3f-c39775c96da7',
          name: 'عمر إبراهيم',
          code: '#37262828',
          avatarUrl: AssetsFake.driverAvatar,
          rating: 4.3,
          vehicleType: 'سيارة',
          plateNumber: '#KU-3719',
          status: 'offline',
          isAvailable: false,
        ),
        DispatcherDriverStatusItemDto(
          id: '4a6f235e-c04d-45db-9c3f-c39775c96da8',
          name: 'خالد فيصل',
          code: '#37262828',
          avatarUrl: AssetsFake.driverAvatar,
          rating: 4.9,
          vehicleType: 'سيارة',
          plateNumber: '#KU-3719',
          status: 'connected',
          isAvailable: true,
        ),
      ],
    );
  }

  @override
  Future<bool> toggleDriverAvailability(String driverId, bool isAvailable) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return isAvailable;
  }
}
