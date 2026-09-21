import 'register_document.dart';
import 'register_personal_data.dart';
import 'register_vehicle_data.dart';

class RegisterReviewData {
  const RegisterReviewData({
    required this.personal,
    required this.vehicle,
    required this.documents,
  });

  const RegisterReviewData.empty()
    : personal = RegisterPersonalData.empty,
      vehicle = RegisterVehicleData.empty,
      documents = const [];

  final RegisterPersonalData personal;
  final RegisterVehicleData vehicle;
  final List<RegisterDocument> documents;
}
