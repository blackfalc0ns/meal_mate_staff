import '../../../core/constants/assets.dart';
import '../domain/register_document.dart';
import '../domain/register_personal_data.dart';
import '../domain/register_review_data.dart';
import '../domain/register_vehicle_data.dart';

class RegisterFakeData {
  const RegisterFakeData._();

  static const review = RegisterReviewData(
    personal: RegisterPersonalData(
      firstName: 'Ahmad',
      lastName: 'Al Sayed',
      phone: '+962 7 9123 4567',
      email: 'ahmad.driver@mail.com',
      birthDate: '1996/04/18',
      nationality: 'Kuwaiti',
      civilId: '287041812345',
    ),
    vehicle: RegisterVehicleData(
      type: 'Car',
      model: 'Toyota Corolla',
      manufactureYear: '2021',
      plateNumber: '54821',
      country: 'Kuwait',
      color: 'Purple',
      isOwned: true,
    ),
    documents: [
      RegisterDocument(
        id: 'civil-card',
        imageAsset: AppAssets.registrationLicenseSample,
      ),
      RegisterDocument(
        id: 'driving-license',
        imageAsset: AppAssets.registrationLicenseSample,
        isUploaded: true,
      ),
      RegisterDocument(
        id: 'car-registration',
        imageAsset: AppAssets.registrationLicenseSample,
      ),
      RegisterDocument(
        id: 'vehicle-photo',
        imageAsset: AppAssets.registrationVehicleSample,
        isUploaded: true,
      ),
      RegisterDocument(
        id: 'personal-photo',
        imageAsset: AppAssets.registrationDriverRole,
      ),
    ],
  );
}
