import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/data/mapper/dispatcher_orders_mapper.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/data/models/response/dispatcher_order_queue_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_driver_suggestion_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_order_priority.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_order_status.dart';

void main() {
  group('DispatcherOrdersMapper', () {
    test('maps documented backend response correctly', () {
      final dto = DispatcherOrderQueueResponseDto.fromJson(
        _documentedResponseJson,
      );
      final entity = dto.toEntity();

      expect(entity.restaurant.id, '0a40e4ff-72c7-4754-94e3-50b5f505b730');
      expect(entity.restaurant.nameAr, 'مطعم MealMate الكويت');
      expect(entity.restaurant.nameEn, 'MealMate Restaurant Kuwait');
      expect(entity.restaurant.role, 'Dispatcher');

      expect(entity.counts.totalCount, 120);
      expect(entity.counts.pendingCount, 23);
      expect(entity.counts.assignedCount, 37);
      expect(entity.counts.inDeliveryCount, 58);
      expect(entity.counts.issuesCount, 2);

      expect(entity.boxes.length, 1);
      final box = entity.boxes.first;
      expect(box.id, 'a1111111-1111-1111-1111-111111111111');
      expect(box.boxCode, '#BX-1256');
      expect(box.area, 'منطقة السالمية');
      expect(box.mealsCount, 8);
      expect(box.mealCountLabel, '8 وجبات');
      expect(box.deliveryTimeWindow, '09:30-10:30 ص');
      expect(box.distanceKm, 6.2);
      expect(box.distanceText, '6.2 كم');
      expect(box.status, DispatcherOrderStatus.pending);
      expect(box.priority, DispatcherOrderPriority.newOrder);
      expect(box.priorityBadgeText, 'جديد');

      expect(box.suggestion, isNotNull);
      expect(box.suggestion!.driverId, '11111111-1111-1111-1111-111111111111');
      expect(box.suggestion!.driverName, 'أحمد');
      expect(
        box.suggestion!.avatarUrl,
        'https://cdn.mealmate.app/avatars/ahmed.jpg',
      );
      expect(
        box.suggestion!.suggestionType,
        DispatcherDriverSuggestionType.nearest,
      );
      expect(box.suggestion!.label, 'الأقرب: أحمد القلاف');

      // Backward compatibility helpers
      expect(box.suggestedDriverName, 'أحمد');
      expect(box.isLeastLoaded, isFalse);
    });

    test('maps all documented status enums and unknown fallback', () {
      const mapping = <String, DispatcherOrderStatus>{
        'Pending': DispatcherOrderStatus.pending,
        'Assigned': DispatcherOrderStatus.assigned,
        'InDelivery': DispatcherOrderStatus.inDelivery,
        'Issue': DispatcherOrderStatus.issue,
        'UnknownFutureStatus': DispatcherOrderStatus.unknown,
      };

      for (final entry in mapping.entries) {
        final boxDto = DispatcherOrderBoxDto.fromJson({
          'boxId': 'b1',
          'boxCode': '#BX-1',
          'status': entry.key,
        });
        final box = boxDto.toEntity();
        expect(box.status, entry.value);
      }
    });

    test('maps all documented priority enums and unknown fallback', () {
      const mapping = <String, DispatcherOrderPriority>{
        'New': DispatcherOrderPriority.newOrder,
        'Urgent': DispatcherOrderPriority.urgent,
        'HighPriority': DispatcherOrderPriority.highPriority,
        'Normal': DispatcherOrderPriority.normal,
        'NonExistent': DispatcherOrderPriority.unknown,
      };

      for (final entry in mapping.entries) {
        final boxDto = DispatcherOrderBoxDto.fromJson({
          'boxId': 'b1',
          'boxCode': '#BX-1',
          'priority': entry.key,
        });
        final box = boxDto.toEntity();
        expect(box.priority, entry.value);
      }
    });

    test(
      'maps all documented suggestion types and handles null suggestion',
      () {
        final nearestBox = DispatcherOrderBoxDto.fromJson({
          'boxId': 'b1',
          'suggestion': {
            'driverId': 'd1',
            'driverName': 'Ali',
            'suggestionType': 'Nearest',
          },
        }).toEntity();
        expect(
          nearestBox.suggestion?.suggestionType,
          DispatcherDriverSuggestionType.nearest,
        );
        expect(nearestBox.isLeastLoaded, isFalse);

        final leastLoadedBox = DispatcherOrderBoxDto.fromJson({
          'boxId': 'b2',
          'suggestion': {
            'driverId': 'd2',
            'driverName': 'Omar',
            'suggestionType': 'LeastLoaded',
          },
        }).toEntity();
        expect(
          leastLoadedBox.suggestion?.suggestionType,
          DispatcherDriverSuggestionType.leastLoaded,
        );
        expect(leastLoadedBox.isLeastLoaded, isTrue);

        final unknownSuggestionBox = DispatcherOrderBoxDto.fromJson({
          'boxId': 'b3',
          'suggestion': {
            'driverId': 'd3',
            'driverName': 'Zaid',
            'suggestionType': 'Fastest',
          },
        }).toEntity();
        expect(
          unknownSuggestionBox.suggestion?.suggestionType,
          DispatcherDriverSuggestionType.unknown,
        );

        final nullSuggestionBox = DispatcherOrderBoxDto.fromJson({
          'boxId': 'b4',
          'suggestion': null,
        }).toEntity();
        expect(nullSuggestionBox.suggestion, isNull);
        expect(nullSuggestionBox.suggestedDriverName, isEmpty);
        expect(nullSuggestionBox.isLeastLoaded, isFalse);
      },
    );

    test('defensively maps empty / missing JSON', () {
      final dto = DispatcherOrderQueueResponseDto.fromJson(const {});
      final entity = dto.toEntity();

      expect(entity.restaurant.id, isEmpty);
      expect(entity.restaurant.nameAr, isEmpty);
      expect(entity.restaurant.nameEn, isEmpty);
      expect(entity.restaurant.role, isEmpty);

      expect(entity.counts.totalCount, 0);
      expect(entity.counts.pendingCount, 0);
      expect(entity.counts.assignedCount, 0);
      expect(entity.counts.inDeliveryCount, 0);
      expect(entity.counts.issuesCount, 0);

      expect(entity.boxes, isEmpty);
    });
  });
}

const _documentedResponseJson = <String, dynamic>{
  'restaurant': {
    'id': '0a40e4ff-72c7-4754-94e3-50b5f505b730',
    'nameAr': 'مطعم MealMate الكويت',
    'nameEn': 'MealMate Restaurant Kuwait',
    'role': 'Dispatcher',
  },
  'counts': {
    'totalCount': 120,
    'pendingCount': 23,
    'assignedCount': 37,
    'inDeliveryCount': 58,
    'issuesCount': 2,
  },
  'boxes': [
    {
      'boxId': 'a1111111-1111-1111-1111-111111111111',
      'boxCode': '#BX-1256',
      'zoneName': 'منطقة السالمية',
      'mealCount': 8,
      'mealCountLabel': '8 وجبات',
      'deliveryTimeWindow': '09:30-10:30 ص',
      'distanceKm': 6.2,
      'distanceText': '6.2 كم',
      'status': 'Pending',
      'priority': 'New',
      'priorityBadgeText': 'جديد',
      'suggestion': {
        'driverId': '11111111-1111-1111-1111-111111111111',
        'driverName': 'أحمد',
        'avatarUrl': 'https://cdn.mealmate.app/avatars/ahmed.jpg',
        'suggestionType': 'Nearest',
        'label': 'الأقرب: أحمد القلاف',
      },
    },
  ],
};
