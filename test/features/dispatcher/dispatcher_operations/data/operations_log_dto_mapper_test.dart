import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/data/mapper/operations_log_mapper.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/data/models/response/operations_log_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operation_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_indicator_color.dart';

void main() {
  group('OperationsLogResponseDto & Mapper', () {
    test('maps complete payload with all 4 operation types and counters', () {
      final payload = {
        'counters': {
          'allCount': 128,
          'completedCount': 98,
          'cancelledCount': 3,
          'failedCount': 7,
          'reassignedCount': 17,
        },
        'operations': [
          {
            'id': 'op-1',
            'boxId': '3fa85f64-5717-4562-b3fc-2c963f66afa2',
            'boxCode': '#BX-10256',
            'type': 'Completed',
            'statusText': 'مكتمل',
            'customer': {
              'id': 'cust-1',
              'name': 'شهد المطيري',
              'area': 'حي الملقا',
              'addressText': 'حي الملقا، الرياض',
            },
            'timeText': '10:45 ص',
            'occurredAtUtc': '2026-09-23T07:45:00Z',
            'driver': {
              'id': 'drv-1',
              'name': 'يوسف خالد',
              'avatarUrl': 'https://example.com/avatar.jpg',
              'indicatorColor': 'green',
            },
          },
          {
            'id': 'op-2',
            'boxId': 'box-failed-id',
            'boxCode': '#BX-10255',
            'type': 'Failed',
            'customer': {
              'id': 'cust-2',
              'name': 'سعد الدوسري',
              'area': '',
              'addressText': 'حي النرجس، الرياض',
            },
            'timeText': '11:15 ص',
            'occurredAtUtc': '2026-09-23T08:15:00Z',
            'driver': {
              'id': 'drv-2',
              'name': 'علي القحطاني',
              'avatarUrl': null,
              'indicatorColor': 'red',
            },
          },
          {
            'id': 'op-3',
            'boxId': 'box-reassigned-id',
            'boxCode': '#BX-10254',
            'type': 'Reassigned',
            'customer': {
              'id': 'cust-3',
              'name': 'نورة السبيعي',
              'area': 'حي الصحافة',
              'addressText': 'حي الصحافة، الرياض',
            },
            'timeText': '11:30 ص',
            'originalDriver': {
              'id': 'drv-orig',
              'name': 'فهد المطيري',
              'indicatorColor': 'orange',
            },
            'replacementDriver': {
              'id': 'drv-repl',
              'name': 'يوسف خالد',
              'avatarUrl': 'https://example.com/yousef.jpg',
              'indicatorColor': 'green',
            },
          },
          {
            'id': 'op-4',
            'boxId': 'box-cancelled-id',
            'boxCode': '#BX-10253',
            'type': 'CancelledByRestaurant',
            'customer': {
              'id': 'cust-4',
              'name': 'أحمد العتيبي',
              'area': 'حي الياسمين',
              'addressText': 'حي الياسمين، الرياض',
            },
            'timeText': '12:00 م',
            'cancelledBy': 'Restaurant',
            'cancelledByText': 'تم الإلغاء من قبل المطعم',
          },
        ],
        'pagination': {
          'pageNumber': 1,
          'pageSize': 10,
          'totalItems': 128,
          'totalPages': 13,
          'hasPreviousPage': false,
          'hasNextPage': true,
        },
      };

      final dto = OperationsLogResponseDto.fromJson(payload);
      final entity = dto.toEntity();

      expect(entity.counters.allCount, 128);
      expect(entity.counters.completedCount, 98);
      expect(entity.counters.cancelledCount, 3);
      expect(entity.counters.failedCount, 7);
      expect(entity.counters.reassignedCount, 17);

      expect(entity.pagination.pageNumber, 1);
      expect(entity.pagination.totalItems, 128);
      expect(entity.pagination.hasNextPage, isTrue);
      expect(entity.pagination.hasPreviousPage, isFalse);

      expect(entity.operations.length, 4);

      // Completed card
      final completedOp = entity.operations[0];
      expect(completedOp.id, 'op-1');
      expect(completedOp.boxId, '3fa85f64-5717-4562-b3fc-2c963f66afa2');
      expect(completedOp.boxCode, '#BX-10256');
      expect(completedOp.status, OperationStatus.completed);
      expect(completedOp.customer.name, 'شهد المطيري');
      expect(completedOp.customer.area, 'حي الملقا');
      expect(completedOp.driver?.name, 'يوسف خالد');
      expect(
        completedOp.driver?.indicatorColor,
        OperationsIndicatorColor.green,
      );
      expect(completedOp.occurredAtUtc, DateTime.utc(2026, 9, 23, 7, 45));

      // Failed card - fallback to addressText when area is empty
      final failedOp = entity.operations[1];
      expect(failedOp.status, OperationStatus.failed);
      expect(failedOp.customer.area, 'حي النرجس، الرياض');
      expect(failedOp.driver?.indicatorColor, OperationsIndicatorColor.red);
      expect(failedOp.driver?.avatarUrl, isNull);

      // Reassigned card
      final reassignedOp = entity.operations[2];
      expect(reassignedOp.status, OperationStatus.reassigned);
      expect(reassignedOp.originalDriver?.name, 'فهد المطيري');
      expect(reassignedOp.replacementDriver?.name, 'يوسف خالد');

      // Cancelled card
      final cancelledOp = entity.operations[3];
      expect(cancelledOp.status, OperationStatus.cancelled);
      expect(cancelledOp.cancelledByText, 'تم الإلغاء من قبل المطعم');
    });

    test('handles empty response gracefully with defensive defaults', () {
      final payload = {
        'operations': <Object?>[],
        'pagination': {'totalItems': 0, 'totalPages': 0},
      };

      final dto = OperationsLogResponseDto.fromJson(payload);
      final entity = dto.toEntity();

      expect(entity.operations, isEmpty);
      expect(entity.counters.allCount, 0);
      expect(entity.pagination.totalItems, 0);
      expect(entity.pagination.totalPages, 0);
      expect(entity.pagination.pageNumber, 1);
      expect(entity.pagination.hasNextPage, isFalse);
    });

    test(
      'handles nulls, missing objects, invalid dates, and unknown enums safely',
      () {
        final payload = {
          'counters': null,
          'operations': [
            {
              'id': null,
              'boxId': null,
              'boxCode': null,
              'type': 'future_unknown_type',
              'customer': null,
              'timeText': null,
              'occurredAtUtc': 'invalid-date-format',
              'driver': {
                'id': null,
                'name': null,
                'avatarUrl': null,
                'indicatorColor': 'violet',
              },
            },
          ],
          'pagination': null,
        };

        final dto = OperationsLogResponseDto.fromJson(payload);
        final entity = dto.toEntity();

        expect(entity.counters.allCount, 0);
        expect(entity.pagination.pageNumber, 1);
        expect(entity.operations.length, 1);

        final op = entity.operations.first;
        expect(op.id, '');
        expect(op.boxId, '');
        expect(op.boxCode, '');
        expect(op.status, OperationStatus.unknown);
        expect(op.customer.name, '');
        expect(op.customer.area, '');
        expect(op.occurredAtUtc, isNull);
        expect(op.driver?.name, '');
        expect(op.driver?.indicatorColor, OperationsIndicatorColor.unknown);
      },
    );
  });
}
