import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/data/mapper/driver_notification_mapper.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/data/models/driver_notification_dto.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/domain/entities/driver_notification_filter_type.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/domain/entities/driver_notification_type.dart';

void main() {
  group('DriverNotificationDto & Mapper', () {
    test('deserializes complete json object correctly', () {
      final json = {
        'id': 'notif-123',
        'type': 'new_order',
        'title': 'New Delivery Assigned',
        'message': 'You have been assigned box #B100',
        'data': {'boxId': 'B100', 'route': '/driver/orders'},
        'isRead': false,
        'createdAt': '2026-09-30T10:00:00.000Z',
      };

      final dto = DriverNotificationDto.fromJson(json);

      expect(dto.id, 'notif-123');
      expect(dto.type, 'new_order');
      expect(dto.title, 'New Delivery Assigned');
      expect(dto.message, 'You have been assigned box #B100');
      expect(dto.data, {'boxId': 'B100', 'route': '/driver/orders'});
      expect(dto.isRead, isFalse);
      expect(dto.createdAt, '2026-09-30T10:00:00.000Z');
    });

    test('deserializes defensively when fields are null or missing', () {
      final json = <String, dynamic>{};

      final dto = DriverNotificationDto.fromJson(json);

      expect(dto.id, isNull);
      expect(dto.type, isNull);
      expect(dto.title, isNull);
      expect(dto.message, isNull);
      expect(dto.data, isNull);
      expect(dto.isRead, isNull);
      expect(dto.createdAt, isNull);

      final entity = dto.toEntity();
      expect(entity.id, isEmpty);
      expect(entity.title, isEmpty);
      expect(entity.body, isEmpty);
      expect(entity.isRead, isFalse);
      expect(entity.type, DriverNotificationType.system);
    });

    test('deserializes direct array of notifications', () {
      const rawJson = '''
      [
        {"id": "n1", "type": "offer", "title": "Bonus", "isRead": true},
        {"id": "n2", "type": "system", "title": "Maintenance", "isRead": false}
      ]
      ''';

      final list = (jsonDecode(rawJson) as List<dynamic>)
          .map((e) => DriverNotificationDto.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(list.length, 2);
      expect(list.first.id, 'n1');
      expect(list.last.id, 'n2');

      final entities = list.toEntityList();
      expect(entities.length, 2);
      expect(entities[0].type, DriverNotificationType.offer);
      expect(entities[0].filterCategory, DriverNotificationFilterType.offers);
      expect(entities[1].type, DriverNotificationType.system);
      expect(entities[1].filterCategory, DriverNotificationFilterType.system);
    });

    test('maps notification types to correct entity types and filter categories', () {
      final types = {
        'new_order': DriverNotificationType.newOrder,
        'neworder': DriverNotificationType.newOrder,
        'order': DriverNotificationType.system,
        'delivered': DriverNotificationType.delivered,
        'earning': DriverNotificationType.earnings,
        'rating': DriverNotificationType.rating,
        'offer': DriverNotificationType.offer,
        'system': DriverNotificationType.system,
        'unknown_custom_type': DriverNotificationType.system,
      };

      for (final entry in types.entries) {
        final dto = DriverNotificationDto(id: '1', type: entry.key);
        final entity = dto.toEntity();
        expect(
          entity.type,
          entry.value,
          reason: 'Expected ${entry.key} to map to ${entry.value}',
        );
      }
    });

    test('isToday calculation relative to current date', () {
      final now = DateTime.now();
      final todayIso = now.toIso8601String();
      final pastIso = now.subtract(const Duration(days: 2)).toIso8601String();

      final dtoToday = DriverNotificationDto(
        id: 't1',
        title: 'Today',
        createdAt: todayIso,
      );
      final dtoPast = DriverNotificationDto(
        id: 'p1',
        title: 'Past',
        createdAt: pastIso,
      );

      final entityToday = dtoToday.toEntity();
      final entityPast = dtoPast.toEntity();

      expect(entityToday.isToday, isTrue);
      expect(entityPast.isToday, isFalse);
    });
  });
}
