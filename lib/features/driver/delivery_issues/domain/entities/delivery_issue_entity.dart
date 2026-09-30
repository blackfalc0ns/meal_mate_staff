import 'delivery_issue_reason.dart';

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
    );
  }
}
