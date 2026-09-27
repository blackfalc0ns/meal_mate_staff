import '../../../../../core/constants/assets_fake.dart';
import '../../domain/entities/dispatcher_driver_details_entity.dart';
import '../../domain/entities/dispatcher_driver_document_entity.dart';
import '../../domain/entities/dispatcher_driver_location_entity.dart';
import '../../domain/entities/dispatcher_driver_performance_entity.dart';
import '../../domain/entities/dispatcher_driver_vehicle_entity.dart';

class DispatcherDriverDetailsFakeData {
  const DispatcherDriverDetailsFakeData._();

  static DispatcherDriverDetailsEntity getSampleDriverDetails({
    String driverId = '4a6f235e-c04d-45db-9c3f-c39775c96da1',
    String? driverName,
  }) {
    return DispatcherDriverDetailsEntity(
      id: driverId,
      name: driverName ?? 'أحمد محمد',
      code: '#KD-4582',
      avatarUrl: AssetsFake.driverAvatar,
      rating: 4.8,
      reviewCount: 128,
      isAvailable: true,
      isOnline: true,
      phoneNumber: '+965 5012 3456',
      totalOrdersToday: 38,
      workTimeMinutesToday: 20,
      distanceKmToday: 42.6,
      activeOrdersToday: 5,
      vehicle: const DispatcherDriverVehicleEntity(
        model: 'تويوتا كورولا',
        colorName: 'أبيض',
        plateNumber: '#KU-7319',
        imageAsset: AssetsFake.vehicleToyotaCorolla,
      ),
      location: const DispatcherDriverLocationEntity(
        areaName: 'المنطقة السالمية',
        updatedMinutesAgo: 2,
        mapPreviewAsset: AssetsFake.mapPreview,
        latitude: 29.3375,
        longitude: 48.0261,
      ),
      performance: const DispatcherDriverPerformanceEntity(
        totalOrders: 38,
        averageRating: 4.8,
        commitmentRatePercent: 98,
        violationsCount: 2,
      ),
      documents: const [
        DispatcherDriverDocumentEntity(
          type: DispatcherDriverDocumentType.drivingLicense,
          isValid: true,
          validUntil: '12/2026',
        ),
        DispatcherDriverDocumentEntity(
          type: DispatcherDriverDocumentType.vehicleRegistration,
          isValid: true,
          validUntil: '08/2026',
        ),
        DispatcherDriverDocumentEntity(
          type: DispatcherDriverDocumentType.insurance,
          isValid: true,
          validUntil: null,
        ),
      ],
    );
  }
}
