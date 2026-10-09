import 'delivery_issue_reason.dart';
import 'reassignment_delivery_context_entity.dart';

class DeliveryIssueEntity {
  const DeliveryIssueEntity({
    required this.boxCode,
    required this.customerName,
    required this.restaurantName,
    required this.area,
    required this.status,
    required this.mealsCountText,
    required this.selectedReason,
    this.notes = '',
    this.attachedPhotos = const [],
    this.deliveryContext,
  });

  final String boxCode;
  final String customerName;
  final String restaurantName;
  final String area;
  final String status;
  final String mealsCountText;
  final DeliveryIssueReason selectedReason;
  final String notes;
  final List<String> attachedPhotos;
  final ReassignmentDeliveryContextEntity? deliveryContext;

  DeliveryIssueEntity copyWith({
    String? boxCode,
    String? customerName,
    String? restaurantName,
    String? area,
    String? status,
    String? mealsCountText,
    DeliveryIssueReason? selectedReason,
    String? notes,
    List<String>? attachedPhotos,
    ReassignmentDeliveryContextEntity? deliveryContext,
    bool clearDeliveryContext = false,
  }) {
    return DeliveryIssueEntity(
      boxCode: boxCode ?? this.boxCode,
      customerName: customerName ?? this.customerName,
      restaurantName: restaurantName ?? this.restaurantName,
      area: area ?? this.area,
      status: status ?? this.status,
      mealsCountText: mealsCountText ?? this.mealsCountText,
      selectedReason: selectedReason ?? this.selectedReason,
      notes: notes ?? this.notes,
      attachedPhotos: attachedPhotos ?? this.attachedPhotos,
      deliveryContext: clearDeliveryContext
          ? null
          : (deliveryContext ?? this.deliveryContext),
    );
  }
}
