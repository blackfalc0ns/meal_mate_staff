import 'package:meal_mate_delivery/core/constants/assets_fake.dart';
import '../entities/delivery_issue_entity.dart';
import '../entities/delivery_issue_reason.dart';
import '../entities/reassignment_reason.dart';
import '../entities/reassignment_request_entity.dart';

class DeliveryIssuesFakeData {
  const DeliveryIssuesFakeData._();

  static const List<String> defaultPhotos = [
    AssetsFake.ticketPhoto1,
    AssetsFake.ticketPhoto2,
  ];

  static const DeliveryIssueEntity defaultIssue = DeliveryIssueEntity(
    boxCode: '#BX-1257',
    customerName: 'أحمد إبراهيم',
    restaurantName: 'مطعم MealMate الكويت',
    area: 'منطقة حولي',
    status: 'في الطريق للعميل',
    mealsCountText: '1 من 1 وجبة',
    selectedReason: DeliveryIssueReason.customerNoAnswer,
    attachedPhotos: defaultPhotos,
  );

  static const ReassignmentRequestEntity defaultReassignment =
      ReassignmentRequestEntity(
    reason: ReassignmentReason.vehicleFailure,
  );
}
