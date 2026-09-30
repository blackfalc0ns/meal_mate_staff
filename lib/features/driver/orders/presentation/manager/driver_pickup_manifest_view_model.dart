import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/driver_assigned_box_entity.dart';
import '../../domain/entities/driver_box_delivery_status.dart';
import '../../domain/entities/driver_boxes_filter_type.dart';
import '../../domain/entities/driver_pickup_manifest_entity.dart';
import '../../domain/usecase/get_driver_pickup_manifest_usecase.dart';
import 'driver_pickup_manifest_event.dart';
import 'driver_pickup_manifest_state.dart';

@injectable
class DriverPickupManifestViewModel extends Cubit<DriverPickupManifestState> {
  DriverPickupManifestViewModel({required this.getManifestUseCase})
    : super(const DriverPickupManifestState());

  final GetDriverPickupManifestUseCase getManifestUseCase;

  int _requestGeneration = 0;

  // ===========================================================================
  // [TEMPORARY FAKE DATA] - احذف هذا البلوك بالكامل عند إصلاح الباك إند
  // أو اجعل _useFakeData = false للرجوع للـ API الحقيقي مباشرة
  // ===========================================================================
  static const bool _useFakeData = true;

  // 1. قائمة الصناديق قيد الاستلام / الفحص (Pending Scan)
  static const List<DriverAssignedBoxEntity> fakePendingBoxes = [
    DriverAssignedBoxEntity(
      boxId: 'BOX-101',
      boxCode: 'ORD-9801',
      customerName: 'أحمد محمود',
      deliveryZone: 'المعادي - شارع 9',
      mealsCount: 3,
      mealsSummary: '3 وجبات كيتو بلس',
      deliveryTimeSlot: '12:00 م - 02:00 م',
      status: DriverBoxDeliveryStatus.pendingScan,
      statusText: 'قيد الاستلام',
      isPickedUp: false,
    ),
    DriverAssignedBoxEntity(
      boxId: 'BOX-102',
      boxCode: 'ORD-9802',
      customerName: 'سارة خالد',
      deliveryZone: 'التجمع الخامس - النرجس',
      mealsCount: 2,
      mealsSummary: '2 وجبة صحية متوازنة',
      deliveryTimeSlot: '01:00 م - 03:00 م',
      status: DriverBoxDeliveryStatus.pendingScan,
      statusText: 'قيد الاستلام',
      isPickedUp: false,
    ),
    DriverAssignedBoxEntity(
      boxId: 'BOX-103',
      boxCode: 'ORD-9803',
      customerName: 'محمد علي',
      deliveryZone: 'مدينة نصر - عباس العقاد',
      mealsCount: 4,
      mealsSummary: '4 وجبات بروتين عالي',
      deliveryTimeSlot: '02:00 م - 04:00 م',
      status: DriverBoxDeliveryStatus.pendingScan,
      statusText: 'قيد الاستلام',
      isPickedUp: false,
    ),
  ];

  // 2. قائمة الصناديق التي تم استلامها / تحميلها (Picked Up)
  static const List<DriverAssignedBoxEntity> fakePickedUpBoxes = [
    DriverAssignedBoxEntity(
      boxId: 'BOX-104',
      boxCode: 'ORD-9804',
      customerName: 'عمر إبراهيم',
      deliveryZone: 'الزمالك - ش 26 يوليو',
      mealsCount: 2,
      mealsSummary: '2 وجبة نباتية فيجان',
      deliveryTimeSlot: '11:00 ص - 01:00 م',
      status: DriverBoxDeliveryStatus.pickedUp,
      statusText: 'تم التحميل',
      isPickedUp: true,
    ),
    DriverAssignedBoxEntity(
      boxId: 'BOX-105',
      boxCode: 'ORD-9805',
      customerName: 'نورا حسن',
      deliveryZone: 'الدقي - ش مصدق',
      mealsCount: 1,
      mealsSummary: '1 وجبة سلطة سوبر فود',
      deliveryTimeSlot: '11:30 ص - 01:30 م',
      status: DriverBoxDeliveryStatus.pickedUp,
      statusText: 'تم التحميل',
      isPickedUp: true,
    ),
  ];

  DriverPickupManifestEntity _buildFakeManifest(DriverBoxesFilterType filter) {
    final List<DriverAssignedBoxEntity> boxes;
    switch (filter) {
      case DriverBoxesFilterType.all:
        boxes = [...fakePendingBoxes, ...fakePickedUpBoxes];
      case DriverBoxesFilterType.pendingScan:
        boxes = fakePendingBoxes;
      case DriverBoxesFilterType.pickedUp:
        boxes = fakePickedUpBoxes;
    }

    final totalBoxes = fakePendingBoxes.length + fakePickedUpBoxes.length;
    final totalMeals = [...fakePendingBoxes, ...fakePickedUpBoxes].fold<int>(
      0,
      (sum, b) => sum + b.mealsCount,
    );

    return DriverPickupManifestEntity(
      tripId: 'TRIP-DEMO-2026',
      tripCode: 'TRIP-101',
      driverId: 'DRV-901',
      driverName: 'الكابتن',
      totalBoxesCount: totalBoxes,
      totalMealsCount: totalMeals,
      pendingScanBoxesCount: fakePendingBoxes.length,
      pickedUpBoxesCount: fakePickedUpBoxes.length,
      allBoxesPickedUp: fakePendingBoxes.isEmpty,
      canStartTrip: false,
      boxes: boxes,
    );
  }
  // ===========================================================================

  Future<void> doIntent(DriverPickupManifestEvent event) async {
    switch (event) {
      case LoadDriverPickupManifestEvent():
        await _loadInitial();
      case RefreshDriverPickupManifestEvent():
        await _refresh();
      case SelectDriverBoxesFilterEvent(:final filter):
        await _changeFilter(filter);
      case RetryDriverPickupManifestEvent():
        await _retry();
      case SeedDriverPickupManifestEvent(:final manifest):
        emit(
          DriverPickupManifestState(
            manifest: manifest,
            isInitialLoading: false,
            hasLoadedOnce: true,
          ),
        );
    }
  }

  Future<void> _loadInitial() async {
    final generation = ++_requestGeneration;
    emit(
      state.copyWith(
        isInitialLoading: state.manifest == null,
        isRefreshLoading: state.manifest != null,
        clearFailure: true,
      ),
    );

    await _fetchManifest(generation, state.selectedFilter);
  }

  Future<void> _refresh() async {
    final generation = ++_requestGeneration;
    emit(state.copyWith(isRefreshLoading: true, clearFailure: true));
    await _fetchManifest(generation, state.selectedFilter);
  }

  Future<void> _changeFilter(DriverBoxesFilterType filter) async {
    final generation = ++_requestGeneration;
    emit(
      state.copyWith(
        selectedFilter: filter,
        isFilterLoading: true,
        clearFailure: true,
      ),
    );
    await _fetchManifest(generation, filter);
  }

  Future<void> _retry() async {
    final generation = ++_requestGeneration;
    emit(
      state.copyWith(
        isInitialLoading: state.manifest == null,
        isFilterLoading: state.manifest != null,
        clearFailure: true,
      ),
    );
    await _fetchManifest(generation, state.selectedFilter);
  }

  Future<void> _fetchManifest(
    int generation,
    DriverBoxesFilterType filter,
  ) async {
    // =========================================================================
    // [TEMPORARY FAKE DATA LOGIC] - احذف هذا الشرط عند إصلاح الباك إند
    // =========================================================================
    if (_useFakeData) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (isClosed || generation != _requestGeneration) return;

      emit(
        state.copyWith(
          manifest: _buildFakeManifest(filter),
          isInitialLoading: false,
          isRefreshLoading: false,
          isFilterLoading: false,
          clearFailure: true,
          hasLoadedOnce: true,
        ),
      );
      return;
    }
    // =========================================================================

    final result = await getManifestUseCase(filter);

    if (isClosed || generation != _requestGeneration) {
      return;
    }

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            manifest: data,
            isInitialLoading: false,
            isRefreshLoading: false,
            isFilterLoading: false,
            clearFailure: true,
            hasLoadedOnce: true,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            isInitialLoading: false,
            isRefreshLoading: false,
            isFilterLoading: false,
            failure: failure,
            hasLoadedOnce: true,
          ),
        );
    }
  }
}
