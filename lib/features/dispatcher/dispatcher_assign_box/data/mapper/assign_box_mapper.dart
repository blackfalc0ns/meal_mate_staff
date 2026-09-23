import '../../domain/entities/assign_box_candidate_driver_entity.dart';
import '../../domain/entities/assign_box_details_entity.dart';
import '../../domain/entities/assign_box_driver_status_type.dart';
import '../../domain/entities/assign_box_meal_entity.dart';
import '../../domain/entities/assign_box_order_entity.dart';
import '../../domain/entities/assign_box_priority.dart';
import '../../domain/entities/assign_box_status.dart';
import '../../domain/entities/assign_box_summary_entity.dart';
import '../models/response/assign_box_details_response_dto.dart';
import '../models/response/assign_box_summary_response_dto.dart';

extension AssignBoxDetailsResponseDtoMapper on AssignBoxDetailsResponseDto {
  AssignBoxDetailsEntity toEntity() {
    return AssignBoxDetailsEntity(
      box: (box ?? const AssignBoxOrderDto()).toEntity(),
      bestSuggestion: bestSuggestion?.toEntity(),
      candidates: candidates
              ?.map((c) => c.toEntity())
              .toList(growable: false) ??
          const [],
    );
  }
}

extension AssignBoxOrderDtoMapper on AssignBoxOrderDto {
  AssignBoxOrderEntity toEntity() {
    final count = mealCount ?? 0;
    return AssignBoxOrderEntity(
      boxId: boxId ?? '',
      boxCode: boxCode ?? '',
      zoneName: zoneName ?? '',
      deliveryTimeWindow: deliveryTimeWindow ?? '',
      mealsCount: count,
      mealsCountText: mealCountLabel ?? (count > 0 ? '$count وجبات' : ''),
      distanceKm: distanceKm,
      distanceText: distanceText ?? (distanceKm != null ? '$distanceKm كم' : ''),
      priority: AssignBoxPriorityX.fromApi(priority),
      priorityText: priorityBadgeText ?? priority ?? '',
      status: AssignBoxStatusX.fromApi(status),
      statusText: statusText ?? status ?? '',
    );
  }
}

extension AssignBoxCandidateDriverDtoMapper on AssignBoxCandidateDriverDto {
  AssignBoxCandidateDriverEntity toEntity() {
    final activeOrders = activeOrdersCount ?? 0;
    final loadBoxes = currentLoadBoxes ?? 0;
    final parsedStatus = AssignBoxDriverStatusTypeX.fromApi(status);

    return AssignBoxCandidateDriverEntity(
      driverId: driverId ?? '',
      fullName: fullName ?? '',
      avatarUrl: avatarUrl,
      plateNumber: plateNumber,
      phone: phone,
      distanceKm: distanceKm,
      distanceText: distanceText ?? (distanceKm != null ? '$distanceKm كم' : ''),
      activeOrdersCount: activeOrders,
      currentLoadBoxes: loadBoxes,
      currentLoadLabel: currentLoadLabel ?? '$loadBoxes بوكسات',
      rating: rating,
      status: parsedStatus,
      driverStatusText: driverStatusText ?? status ?? '',
      statusTag: statusTag ?? '',
      estimatedFinishTimeText: estimatedFinishTimeText ?? '',
      rank: rank ?? 0,
      isRecommended: isRecommended ?? false,
      recommendationReason: recommendationReason,
    );
  }
}

extension AssignBoxSummaryResponseDtoMapper on AssignBoxSummaryResponseDto {
  AssignBoxSummaryEntity toEntity() {
    return AssignBoxSummaryEntity(
      boxId: boxId ?? '',
      boxCode: boxCode ?? '',
      customerMaskedId: customerMaskedId,
      customerNameMasked: customerNameMasked,
      customerPhoneMasked: customerPhoneMasked,
      zoneName: zoneName,
      address: address,
      deliveryTimeWindow: deliveryTimeWindow,
      boxCount: boxCount ?? 1,
      barcode: barcode,
      deliveryNotes: deliveryNotes,
      allergies: List<String>.unmodifiable(allergies ?? const []),
      meals: List<AssignBoxMealEntity>.unmodifiable(
        meals?.map((m) => m.toEntity()).toList(growable: false) ?? const [],
      ),
    );
  }
}

extension AssignBoxMealDtoMapper on AssignBoxMealDto {
  AssignBoxMealEntity toEntity() {
    return AssignBoxMealEntity(
      mealId: mealId ?? '',
      mealName: mealName ?? '',
      quantity: quantity ?? 1,
      category: category,
      notes: notes,
    );
  }
}
