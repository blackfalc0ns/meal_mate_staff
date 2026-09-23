import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/data/mapper/assign_box_mapper.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/data/models/response/assign_box_details_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/data/models/response/assign_box_summary_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_driver_status_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_priority.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_status.dart';

void main() {
  group('AssignBoxDetailsResponseDto Mapping', () {
    final validDetailsJson = {
      'box': {
        'boxId': 'a1111111-1111-1111-1111-111111111111',
        'boxCode': '#BX-1256',
        'zoneName': 'المنطقة الشرقية',
        'deliveryTimeWindow': '10:00 - 11:30 ص',
        'mealCount': 4,
        'mealCountLabel': '4 وجبات',
        'distanceKm': 3.5,
        'distanceText': '3.5 كم',
        'priority': 'HighPriority',
        'priorityBadgeText': 'أولوية عالية',
        'status': 'Pending',
        'statusText': 'قيد الانتظار',
      },
      'bestSuggestion': {
        'driverId': '33333333-3333-3333-3333-333333333333',
        'fullName': 'سالم الحربي',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'plateNumber': '40-12849',
        'phone': '0501234567',
        'distanceKm': 2.4,
        'distanceText': '2.4 كم',
        'activeOrdersCount': 1,
        'currentLoadBoxes': 4,
        'currentLoadLabel': '4 بوكسات',
        'rating': 4.8,
        'status': 'Available',
        'driverStatusText': 'متاح',
        'statusTag': 'الأسرع وصولاً',
        'estimatedFinishTimeText': '10:20 ص',
        'rank': 1,
        'isRecommended': true,
        'recommendationReason': 'الأقرب لموقع الاستلام',
      },
      'candidates': [
        {
          'driverId': '11111111-1111-1111-1111-111111111111',
          'fullName': 'فهد العتيبي',
          'distanceKm': 3.1,
          'distanceText': '3.1 كم',
          'activeOrdersCount': 2,
          'currentLoadBoxes': 3,
          'currentLoadLabel': '3 بوكسات',
          'status': 'Busy',
          'driverStatusText': 'مشغول',
          'statusTag': 'متاح قريباً',
          'estimatedFinishTimeText': '10:35 ص',
          'rank': 2,
        },
        {
          'driverId': '22222222-2222-2222-2222-222222222222',
          'fullName': 'خالد المطيري',
          'distanceKm': 4.5,
          'distanceText': '4.5 كم',
          'activeOrdersCount': 0,
          'currentLoadBoxes': 0,
          'currentLoadLabel': '0 بوكسات',
          'status': 'Available',
          'driverStatusText': 'متاح',
          'statusTag': 'الأقل حمولة',
          'estimatedFinishTimeText': '10:15 ص',
          'rank': 3,
        },
        {
          'driverId': '44444444-4444-4444-4444-444444444444',
          'fullName': 'عمر الدوسري',
          'distanceKm': 5.2,
          'distanceText': '5.2 كم',
          'activeOrdersCount': 3,
          'currentLoadBoxes': 5,
          'currentLoadLabel': '5 بوكسات',
          'status': 'InDelivery',
          'driverStatusText': 'في الطريق',
          'statusTag': 'في المنطقة',
          'estimatedFinishTimeText': '10:45 ص',
          'rank': 4,
        },
        {
          'driverId': '55555555-5555-5555-5555-555555555555',
          'fullName': 'يوسف الشمري',
          'distanceKm': 6.0,
          'distanceText': '6.0 كم',
          'activeOrdersCount': 1,
          'currentLoadBoxes': 2,
          'currentLoadLabel': '2 بوكسات',
          'status': 'Returning',
          'driverStatusText': 'عائد للمطعم',
          'statusTag': 'جاهز للاستلام',
          'estimatedFinishTimeText': '10:50 ص',
          'rank': 5,
        },
      ],
    };

    test('maps valid details payload accurately to entity', () {
      final entity =
          AssignBoxDetailsResponseDto.fromJson(validDetailsJson).toEntity();

      expect(entity.box.boxId, 'a1111111-1111-1111-1111-111111111111');
      expect(entity.box.boxCode, '#BX-1256');
      expect(entity.box.priority, AssignBoxPriority.high);
      expect(entity.box.status, AssignBoxStatus.pending);

      expect(
        entity.bestSuggestion?.driverId,
        '33333333-3333-3333-3333-333333333333',
      );
      expect(entity.bestSuggestion?.fullName, 'سالم الحربي');
      expect(entity.bestSuggestion?.status, AssignBoxDriverStatusType.available);
      expect(entity.bestSuggestion?.isRecommended, isTrue);

      expect(entity.candidates.length, 4);
      expect(entity.candidates[0].status, AssignBoxDriverStatusType.busy);
      expect(entity.candidates[1].status, AssignBoxDriverStatusType.available);
      expect(entity.candidates[2].status, AssignBoxDriverStatusType.inDelivery);
      expect(entity.candidates[3].status, AssignBoxDriverStatusType.returning);
    });

    test('defensively handles null bestSuggestion, empty candidates, and missing box', () {
      const emptyDto = AssignBoxDetailsResponseDto();
      final entity = emptyDto.toEntity();

      expect(entity.box.boxId, '');
      expect(entity.box.priority, AssignBoxPriority.unknown);
      expect(entity.box.status, AssignBoxStatus.unknown);
      expect(entity.bestSuggestion, isNull);
      expect(entity.candidates, isEmpty);
    });

    test('handles unknown enums and null optional driver fields safely', () {
      final jsonWithUnknowns = {
        'box': {
          'boxId': 'box-1',
          'priority': 'SuperSpecial',
          'status': 'UnseenStatus',
        },
        'candidates': [
          {
            'driverId': 'driver-1',
            'fullName': null,
            'status': 'UnknownStatus',
            'rating': null,
            'avatarUrl': null,
            'phone': null,
            'distanceKm': null,
            'isRecommended': null,
          }
        ],
      };

      final entity =
          AssignBoxDetailsResponseDto.fromJson(jsonWithUnknowns).toEntity();
      expect(entity.box.priority, AssignBoxPriority.unknown);
      expect(entity.box.status, AssignBoxStatus.unknown);
      expect(entity.candidates.length, 1);
      final driver = entity.candidates.first;
      expect(driver.driverId, 'driver-1');
      expect(driver.fullName, '');
      expect(driver.status, AssignBoxDriverStatusType.unknown);
      expect(driver.avatarUrl, isNull);
      expect(driver.isRecommended, isFalse);
    });
  });

  group('AssignBoxSummaryResponseDto Mapping', () {
    final validSummaryJson = {
      'boxId': 'a1111111-1111-1111-1111-111111111111',
      'boxCode': '#BX-1256',
      'customerMaskedId': 'CUST-***42',
      'customerNameMasked': 'أحمد ***',
      'customerPhoneMasked': '+965 **** 1234',
      'zoneName': 'السالمية',
      'address': 'شارع سالم المبارك، برج السنابل، شقة 14',
      'deliveryTimeWindow': '11:00 ص - 12:30 م',
      'boxCount': 1,
      'barcode': 'MM-BX-1256-KWT',
      'deliveryNotes': 'يرجى وضع البوكس عند الباب والاتصال',
      'allergies': ['مكسرات', 'لاكتوز'],
      'meals': [
        {
          'mealId': 'm-1',
          'mealName': 'سالمون مشوي مع الكينوا والخضار السوتيه',
          'quantity': 2,
          'category': 'غداء كيتو',
          'notes': 'بدون بصل',
        },
        {
          'mealId': 'm-2',
          'mealName': 'سلطة سيزر الدجاج المشوي',
          'quantity': 1,
          'category': 'سلطات',
          'notes': null,
        }
      ],
    };

    test('maps valid summary payload accurately to entity', () {
      final summary =
          AssignBoxSummaryResponseDto.fromJson(validSummaryJson).toEntity();

      expect(summary.boxId, 'a1111111-1111-1111-1111-111111111111');
      expect(summary.boxCode, '#BX-1256');
      expect(summary.customerMaskedId, 'CUST-***42');
      expect(summary.customerNameMasked, 'أحمد ***');
      expect(summary.customerPhoneMasked, '+965 **** 1234');
      expect(summary.zoneName, 'السالمية');
      expect(summary.address, 'شارع سالم المبارك، برج السنابل، شقة 14');
      expect(summary.deliveryTimeWindow, '11:00 ص - 12:30 م');
      expect(summary.boxCount, 1);
      expect(summary.barcode, 'MM-BX-1256-KWT');
      expect(summary.deliveryNotes, 'يرجى وضع البوكس عند الباب والاتصال');
      expect(summary.allergies, contains('مكسرات'));
      expect(summary.allergies.length, 2);
      expect(summary.meals.length, 2);
      expect(summary.meals.first.mealId, 'm-1');
      expect(summary.meals.first.quantity, 2);
      expect(summary.meals.first.notes, 'بدون بصل');
      expect(summary.meals[1].notes, isNull);
    });

    test('defensively maps null allergies and null meals to empty lists', () {
      const emptySummaryDto = AssignBoxSummaryResponseDto();
      final summary = emptySummaryDto.toEntity();

      expect(summary.boxId, '');
      expect(summary.boxCode, '');
      expect(summary.allergies, isEmpty);
      expect(summary.meals, isEmpty);
    });
  });
}
