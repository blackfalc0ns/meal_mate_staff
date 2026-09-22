import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_filter_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_order_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_order_priority.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_order_queue_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_order_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/repo/dispatcher_orders_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/usecase/get_dispatcher_order_queue_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/presentation/manager/dispatcher_orders_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/presentation/manager/dispatcher_orders_view_model.dart';

void main() {
  group('DispatcherOrdersViewModel', () {
    test('loads queue on initial LoadDispatcherOrdersEvent', () async {
      final repo = _FakeRepository();
      final vm = _buildViewModel(repo);

      vm.doIntent(const LoadDispatcherOrdersEvent());
      expect(vm.state.isInitialLoading, isTrue);

      await Future<void>.delayed(Duration.zero);

      expect(vm.state.isInitialLoading, isFalse);
      expect(vm.state.hasLoadedOnce, isTrue);
      expect(vm.state.queue?.counts.totalCount, 120);
      expect(vm.state.failure, isNull);
      await vm.close();
    });

    test(
      'handles failure on initial load and clears failure on retry',
      () async {
        final repo = _FakeRepository(shouldFail: true);
        final vm = _buildViewModel(repo);

        vm.doIntent(const LoadDispatcherOrdersEvent());
        await Future<void>.delayed(Duration.zero);

        expect(vm.state.isInitialLoading, isFalse);
        expect(vm.state.queue, isNull);
        expect(vm.state.failure, isNotNull);

        // Now fix repo and retry
        repo.shouldFail = false;
        vm.doIntent(const RetryDispatcherOrdersEvent());
        expect(vm.state.isInitialLoading, isTrue);
        expect(vm.state.failure, isNull);

        await Future<void>.delayed(Duration.zero);
        expect(vm.state.isInitialLoading, isFalse);
        expect(vm.state.queue?.counts.totalCount, 120);
        await vm.close();
      },
    );

    test(
      'refresh retains existing data while loading and on failure',
      () async {
        final repo = _FakeRepository();
        final vm = _buildViewModel(repo);

        // Initial load success
        vm.doIntent(const LoadDispatcherOrdersEvent());
        await Future<void>.delayed(Duration.zero);
        expect(vm.state.queue, isNotNull);

        // Trigger refresh with failure
        repo.shouldFail = true;
        vm.doIntent(const RefreshDispatcherOrdersEvent());
        expect(vm.state.isRefreshLoading, isTrue);
        expect(
          vm.state.queue,
          isNotNull,
          reason: 'Must retain data while refreshing',
        );

        await Future<void>.delayed(Duration.zero);
        expect(vm.state.isRefreshLoading, isFalse);
        expect(
          vm.state.queue,
          isNotNull,
          reason: 'Must preserve data on refresh failure',
        );
        expect(vm.state.failure, isNotNull);
        await vm.close();
      },
    );

    test(
      'filter switch updates selectedFilter and loads data for that filter',
      () async {
        final repo = _FakeRepository();
        final vm = _buildViewModel(repo);

        vm.doIntent(
          const SelectDispatcherFilterEvent(
            DispatcherFilterType.pendingAssignment,
          ),
        );
        expect(vm.state.selectedFilter, DispatcherFilterType.pendingAssignment);
        expect(vm.state.isFilterLoading, isTrue);

        await Future<void>.delayed(Duration.zero);
        expect(vm.state.isFilterLoading, isFalse);
        expect(
          repo.lastRequestedFilter,
          DispatcherFilterType.pendingAssignment,
        );
        await vm.close();
      },
    );

    test('preserves existing data when filter request fails', () async {
      final repo = _FakeRepository();
      final vm = _buildViewModel(repo);

      vm.doIntent(const LoadDispatcherOrdersEvent());
      await Future<void>.delayed(Duration.zero);
      expect(vm.state.queue, isNotNull);

      repo.shouldFail = true;
      vm.doIntent(
        const SelectDispatcherFilterEvent(DispatcherFilterType.problems),
      );
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.selectedFilter, DispatcherFilterType.problems);
      expect(vm.state.isFilterLoading, isFalse);
      expect(
        vm.state.queue,
        isNotNull,
        reason: 'Must preserve existing data on filter failure',
      );
      expect(vm.state.failure, isNotNull);
      await vm.close();
    });

    test(
      'discards stale out-of-order responses using generation counter',
      () async {
        final slowCompleter =
            Completer<ApiResult<DispatcherOrderQueueEntity>>();
        final repo = _DelayedFakeRepository(slowCompleter);
        final vm = _buildViewModel(repo);

        // First request: Pending (slow)
        vm.doIntent(
          const SelectDispatcherFilterEvent(
            DispatcherFilterType.pendingAssignment,
          ),
        );
        expect(vm.state.selectedFilter, DispatcherFilterType.pendingAssignment);

        // Second request: Assigned (fast)
        vm.doIntent(
          const SelectDispatcherFilterEvent(DispatcherFilterType.assigned),
        );
        expect(vm.state.selectedFilter, DispatcherFilterType.assigned);
        await Future<void>.delayed(Duration.zero);

        // The fast request finishes with 37 assigned
        expect(vm.state.queue?.counts.assignedCount, 37);

        // Now the slow pending request finally finishes with 23 pending
        slowCompleter.complete(
          ApiSuccessResult(
            data: _createQueue(pendingCount: 23, assignedCount: 0),
          ),
        );
        await Future<void>.delayed(Duration.zero);

        // Active state should NOT be overwritten by the stale pending response
        expect(vm.state.selectedFilter, DispatcherFilterType.assigned);
        expect(vm.state.queue?.counts.assignedCount, 37);
        await vm.close();
      },
    );
  });
}

DispatcherOrdersViewModel _buildViewModel(DispatcherOrdersRepository repo) {
  return DispatcherOrdersViewModel(
    getQueueUseCase: GetDispatcherOrderQueueUseCase(repo),
  );
}

DispatcherOrderQueueEntity _createQueue({
  int totalCount = 120,
  int pendingCount = 23,
  int assignedCount = 37,
}) {
  return DispatcherOrderQueueEntity(
    restaurant: const DispatcherOrderQueueRestaurantEntity(
      id: 'r1',
      nameAr: 'مطعم',
      nameEn: 'Restaurant',
      role: 'Dispatcher',
    ),
    counts: DispatcherOrderQueueCountsEntity(
      totalCount: totalCount,
      pendingCount: pendingCount,
      assignedCount: assignedCount,
      inDeliveryCount: 58,
      issuesCount: 2,
    ),
    boxes: [
      const DispatcherOrderEntity(
        id: 'b1',
        boxCode: '#BX-1',
        priority: DispatcherOrderPriority.newOrder,
        status: DispatcherOrderStatus.pending,
        area: 'منطقة',
        deliveryTimeWindow: '10:00-11:00',
        mealsCount: 4,
        distanceKm: 2.5,
      ),
    ],
  );
}

class _FakeRepository implements DispatcherOrdersRepository {
  _FakeRepository({this.shouldFail = false});

  bool shouldFail;
  DispatcherFilterType? lastRequestedFilter;

  @override
  Future<ApiResult<DispatcherOrderQueueEntity>> getQueue(
    DispatcherFilterType filter,
  ) async {
    lastRequestedFilter = filter;
    if (shouldFail) {
      return ApiErrorResult(
        failure: Failure.fromException(
          const ApiException(
            errorType: ApiErrorType.serverError,
            message: 'Queue load failed',
          ),
        ),
      );
    }
    return ApiSuccessResult(data: _createQueue());
  }
}

class _DelayedFakeRepository implements DispatcherOrdersRepository {
  _DelayedFakeRepository(this._pendingCompleter);

  final Completer<ApiResult<DispatcherOrderQueueEntity>> _pendingCompleter;

  @override
  Future<ApiResult<DispatcherOrderQueueEntity>> getQueue(
    DispatcherFilterType filter,
  ) {
    if (filter == DispatcherFilterType.pendingAssignment) {
      return _pendingCompleter.future;
    }
    return Future.value(
      ApiSuccessResult(data: _createQueue(pendingCount: 0, assignedCount: 37)),
    );
  }
}
