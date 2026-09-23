import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/arguments/assign_box_route_arguments.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_candidate_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_details_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_driver_status_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_meal_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_order_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_priority.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_summary_entity.dart';

void main() {
  group('AssignBoxRouteArgs', () {
    test('validates non-empty GUID correctly', () {
      expect(const AssignBoxRouteArgs(boxId: '').isValid, isFalse);
      expect(const AssignBoxRouteArgs(boxId: 'invalid-id').isValid, isFalse);
      expect(
        const AssignBoxRouteArgs(
          boxId: 'a1111111-1111-1111-1111-111111111111',
        ).isValid,
        isTrue,
      );
    });
  });

  group('AssignBoxDriverStatusTypeX', () {
    test('parses all four driver statuses from API strings and unknown fallback', () {
      expect(
        AssignBoxDriverStatusTypeX.fromApi('Available'),
        AssignBoxDriverStatusType.available,
      );
      expect(
        AssignBoxDriverStatusTypeX.fromApi('Busy'),
        AssignBoxDriverStatusType.busy,
      );
      expect(
        AssignBoxDriverStatusTypeX.fromApi('InDelivery'),
        AssignBoxDriverStatusType.inDelivery,
      );
      expect(
        AssignBoxDriverStatusTypeX.fromApi('Returning'),
        AssignBoxDriverStatusType.returning,
      );
      expect(
        AssignBoxDriverStatusTypeX.fromApi('SomethingElse'),
        AssignBoxDriverStatusType.unknown,
      );
      expect(
        AssignBoxDriverStatusTypeX.fromApi(null),
        AssignBoxDriverStatusType.unknown,
      );
    });
  });

  group('AssignBoxPriorityX', () {
    test('parses priorities correctly including high priority and fallback', () {
      expect(
        AssignBoxPriorityX.fromApi('HighPriority'),
        AssignBoxPriority.high,
      );
      expect(
        AssignBoxPriorityX.fromApi('High'),
        AssignBoxPriority.high,
      );
      expect(
        AssignBoxPriorityX.fromApi('Normal'),
        AssignBoxPriority.normal,
      );
      expect(
        AssignBoxPriorityX.fromApi('Urgent'),
        AssignBoxPriority.urgent,
      );
      expect(
        AssignBoxPriorityX.fromApi('Low'),
        AssignBoxPriority.low,
      );
      expect(
        AssignBoxPriorityX.fromApi(null),
        AssignBoxPriority.unknown,
      );
    });
  });

  group('AssignBoxStatusX', () {
    test('parses box statuses correctly and fallback', () {
      expect(AssignBoxStatusX.fromApi('Pending'), AssignBoxStatus.pending);
      expect(AssignBoxStatusX.fromApi('Assigned'), AssignBoxStatus.assigned);
      expect(AssignBoxStatusX.fromApi('InDelivery'), AssignBoxStatus.inDelivery);
      expect(AssignBoxStatusX.fromApi('Issue'), AssignBoxStatus.issue);
      expect(AssignBoxStatusX.fromApi(null), AssignBoxStatus.unknown);
    });
  });

  group('AssignBoxCandidateDriverEntity', () {
    test('holds separate ID, display, and metric fields with compatibility getters', () {
      const driver = AssignBoxCandidateDriverEntity(
        driverId: 'd-1',
        fullName: 'سالم الحربي',
        avatarUrl: 'https://example.com/avatar.jpg',
        plateNumber: '40-12849',
        phone: '0501234567',
        distanceKm: 2.4,
        distanceText: '2.4 كم',
        activeOrdersCount: 1,
        currentLoadBoxes: 4,
        currentLoadLabel: '4 بوكسات',
        rating: 4.8,
        status: AssignBoxDriverStatusType.available,
        driverStatusText: 'متاح',
        statusTag: 'الأسرع وصولاً',
        estimatedFinishTimeText: '10:20 ص',
        rank: 1,
        isRecommended: true,
        recommendationReason: 'الأقرب لموقع الاستلام',
      );

      expect(driver.driverId, 'd-1');
      expect(driver.id, 'd-1');
      expect(driver.fullName, 'سالم الحربي');
      expect(driver.name, 'سالم الحربي');
      expect(driver.plateNumber, '40-12849');
      expect(driver.badgeNumber, '40-12849');
      expect(driver.status, AssignBoxDriverStatusType.available);
      expect(driver.statusType, AssignBoxDriverStatusType.available);
      expect(driver.currentLoadBoxes, 4);
      expect(driver.currentLoadText, '4 بوكسات');
      expect(driver.isRecommended, isTrue);
    });
  });

  group('AssignBoxDetailsEntity', () {
    test('calculates defaultSelectedDriverId based on precedence rules', () {
      const box = AssignBoxOrderEntity(
        boxId: 'b-1',
        boxCode: '#BX-1256',
        zoneName: 'المنطقة الشرقية',
        deliveryTimeWindow: '10:00 - 11:30 ص',
        mealsCount: 4,
        mealsCountText: '4 وجبات',
        distanceKm: 3.5,
        distanceText: '3.5 كم',
        priority: AssignBoxPriority.high,
        priorityText: 'أولوية عالية',
        status: AssignBoxStatus.pending,
        statusText: 'قيد الانتظار',
      );

      const driver1 = AssignBoxCandidateDriverEntity(
        driverId: 'd-1',
        fullName: 'Driver 1',
        distanceText: '2 كم',
        activeOrdersCount: 0,
        currentLoadBoxes: 0,
        currentLoadLabel: '0 بوكسات',
        status: AssignBoxDriverStatusType.available,
        driverStatusText: 'متاح',
        statusTag: 'الأسرع',
        estimatedFinishTimeText: '10:00 ص',
        rank: 1,
        isRecommended: true,
      );

      const driver2 = AssignBoxCandidateDriverEntity(
        driverId: 'd-2',
        fullName: 'Driver 2',
        distanceText: '4 كم',
        activeOrdersCount: 1,
        currentLoadBoxes: 2,
        currentLoadLabel: '2 بوكسات',
        status: AssignBoxDriverStatusType.busy,
        driverStatusText: 'مشغول',
        statusTag: 'متاح قريباً',
        estimatedFinishTimeText: '10:30 ص',
        rank: 2,
      );

      // 1. bestSuggestion present -> picks bestSuggestion
      const detailsWithBest = AssignBoxDetailsEntity(
        box: box,
        bestSuggestion: driver1,
        candidates: [driver2],
      );
      expect(detailsWithBest.defaultSelectedDriverId, 'd-1');

      // 2. bestSuggestion null, candidates available -> picks first candidate
      const detailsNoBest = AssignBoxDetailsEntity(
        box: box,
        bestSuggestion: null,
        candidates: [driver2],
      );
      expect(detailsNoBest.defaultSelectedDriverId, 'd-2');

      // 3. no best, no candidates -> null
      const detailsEmpty = AssignBoxDetailsEntity(
        box: box,
        bestSuggestion: null,
        candidates: [],
      );
      expect(detailsEmpty.defaultSelectedDriverId, isNull);
    });
  });

  group('AssignBoxSummaryEntity', () {
    test('handles nullable summary strings and immutable lists', () {
      const summary = AssignBoxSummaryEntity(
        boxId: 'b-1',
        boxCode: '#BX-1256',
        customerMaskedId: 'CUST-***42',
        customerNameMasked: 'أحمد ***',
        customerPhoneMasked: '+965 **** 1234',
        zoneName: 'السالمية',
        address: 'شارع سالم المبارك، برج السنابل، شقة 14',
        deliveryTimeWindow: '11:00 ص - 12:30 م',
        boxCount: 1,
        barcode: 'MM-BX-1256-KWT',
        deliveryNotes: 'يرجى وضع البوكس عند الباب والاتصال',
        allergies: ['مكسرات', 'لاكتوز'],
        meals: [
          AssignBoxMealEntity(
            mealId: 'm-1',
            mealName: 'سالمون مشوي مع الكينوا والخضار السوتيه',
            quantity: 2,
            category: 'غداء كيتو',
            notes: 'بدون بصل',
          ),
        ],
      );

      expect(summary.boxId, 'b-1');
      expect(summary.allergies, contains('مكسرات'));
      expect(summary.meals.first.quantity, 2);
      expect(summary.meals.first.notes, 'بدون بصل');
    });
  });
}
