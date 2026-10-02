import '../../../../../core/constants/assets_fake.dart';
import '../entities/driver_document_item_entity.dart';

class DriverDocumentsFakeData {
  const DriverDocumentsFakeData._();

  static const List<DriverDocumentItemEntity> defaultDocuments = [
    DriverDocumentItemEntity(
      id: 'civil-card',
      documentType: 'civil-card',
      imageAsset: AssetsFake.documentCivilCard,
      status: DriverDocumentItemStatus.approved,
      expiryDate: '2028-12-31',
    ),
    DriverDocumentItemEntity(
      id: 'driving-license',
      documentType: 'driving-license',
      imageAsset: AssetsFake.documentDrivingLicense,
      status: DriverDocumentItemStatus.expiringSoon,
      expiryDate: '2026-11-15',
    ),
    DriverDocumentItemEntity(
      id: 'car-registration',
      documentType: 'car-registration',
      imageAsset: AssetsFake.documentCarRegistration,
      status: DriverDocumentItemStatus.approved,
      expiryDate: '2027-08-20',
    ),
    DriverDocumentItemEntity(
      id: 'vehicle-photo',
      documentType: 'vehicle-photo',
      imageAsset: AssetsFake.documentVehiclePhoto,
      status: DriverDocumentItemStatus.approved,
    ),
    DriverDocumentItemEntity(
      id: 'personal-photo',
      documentType: 'personal-photo',
      imageAsset: AssetsFake.documentPersonalPhoto,
      status: DriverDocumentItemStatus.approved,
    ),
  ];
}
