import '../user_role.dart';
import 'staff_application_status_entity.dart';

class PhoneLookupResultEntity {
  const PhoneLookupResultEntity({
    required this.exists,
    required this.isFirstTimeSetup,
    required this.role,
    required this.phone,
    this.fullName,
    this.restaurantName,
    this.restaurantId,
    this.status,
    this.applicationStatus,
  });

  final bool exists;
  final bool isFirstTimeSetup;
  final UserRole role;
  final String phone;
  final String? fullName;
  final String? restaurantName;
  final String? restaurantId;
  final String? status;
  final StaffApplicationStatusEntity? applicationStatus;
}
