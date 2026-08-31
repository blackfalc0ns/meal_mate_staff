import 'register_document.dart';
import 'register_personal_data.dart';
import 'register_vehicle_data.dart';

class RegisterReviewData {
  const RegisterReviewData({
    required this.personal,
    required this.vehicle,
    required this.documents,
  });

  final RegisterPersonalData personal;
  final RegisterVehicleData vehicle;
  final List<RegisterDocument> documents;
}
