import '../../../../../core/constants/assets.dart';
import '../entities/driver_vehicle_entity.dart';

class DriverVehicleFakeData {
  const DriverVehicleFakeData._();

  static const DriverVehicleEntity defaultVehicle = DriverVehicleEntity(
    brandAndModel: 'تويوتا كورولا',
    model: 'كورولا',
    colorName: 'أبيض',
    manufactureYear: '2022',
    bodyType: 'سيدان',
    plateNumber: '12345',
    plateLetter: 'أ',
    plateLetterEn: 'A',
    licenseNumber: 'KWT-9876543',
    licenseExpiryDate: '15 مارس 2026',
    imageAsset: AppAssets.driverToyotaCorolla,
    notes: '',
  );
}
