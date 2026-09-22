import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/data/data_source/dispatcher_orders_remote_data_source.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/data/models/response/dispatcher_order_queue_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/data/repo/dispatcher_orders_repository_impl.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_filter_type.dart';

void main() {
  group('DispatcherOrdersRepositoryImpl', () {
    test('maps queue response on success', () async {
      final repository = DispatcherOrdersRepositoryImpl(_SuccessDataSource());

      final result = await repository.getQueue(DispatcherFilterType.all);

      expect(result, isA<ApiSuccessResult>());
      final data = (result as ApiSuccessResult).data;
      expect(data.counts.totalCount, 120);
      expect(data.boxes.length, 1);
      expect(data.boxes.first.boxCode, '#BX-1256');
    });

    test(
      'converts transport failures into ApiErrorResult via safeApiCall',
      () async {
        final repository = DispatcherOrdersRepositoryImpl(_FailingDataSource());

        final result = await repository.getQueue(
          DispatcherFilterType.pendingAssignment,
        );

        expect(result, isA<ApiErrorResult>());
      },
    );
  });
}

class _SuccessDataSource implements DispatcherOrdersRemoteDataSource {
  @override
  Future<DispatcherOrderQueueResponseDto> getQueue(String filter) async {
    return DispatcherOrderQueueResponseDto.fromJson(const {
      'counts': {'totalCount': 120},
      'boxes': [
        {'boxId': 'b1', 'boxCode': '#BX-1256'},
      ],
    });
  }
}

class _FailingDataSource implements DispatcherOrdersRemoteDataSource {
  @override
  Future<DispatcherOrderQueueResponseDto> getQueue(String filter) {
    return Future.error(
      DioException(
        requestOptions: RequestOptions(path: '/api/v1/dispatcher/orders/queue'),
        type: DioExceptionType.connectionError,
      ),
    );
  }
}
