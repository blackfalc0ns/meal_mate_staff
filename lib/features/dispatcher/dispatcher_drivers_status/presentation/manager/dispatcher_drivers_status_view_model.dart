import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/dispatcher_driver_status_type.dart';
import '../../domain/entities/dispatcher_drivers_status_summary_entity.dart';
import '../../domain/usecase/get_drivers_status_usecase.dart';
import '../../domain/usecase/toggle_driver_availability_usecase.dart';
import 'dispatcher_drivers_status_event.dart';
import 'dispatcher_drivers_status_state.dart';

@injectable
class DispatcherDriversStatusViewModel extends Cubit<DispatcherDriversStatusState> {
  DispatcherDriversStatusViewModel({
    required this.getDriversStatusUseCase,
    required this.toggleDriverAvailabilityUseCase,
  }) : super(const DispatcherDriversStatusState());

  final GetDriversStatusUseCase getDriversStatusUseCase;
  final ToggleDriverAvailabilityUseCase toggleDriverAvailabilityUseCase;

  Future<void> doIntent(DispatcherDriversStatusEvent event) async {
    switch (event) {
      case LoadDispatcherDriversStatusEvent():
        await _load();
      case RefreshDispatcherDriversStatusEvent():
        await _refresh();
      case SearchDriversStatusEvent(:final query):
        emit(state.copyWith(searchQuery: query));
      case FilterDriversStatusEvent(:final statusFilter):
        if (statusFilter == null) {
          emit(state.copyWith(clearFilter: true));
        } else {
          emit(state.copyWith(selectedFilter: statusFilter));
        }
      case ToggleDriverStatusEvent(:final driverId, :final isAvailable):
        await _toggleDriver(driverId, isAvailable);
    }
  }

  Future<void> _load() async {
    emit(state.copyWith(isInitialLoading: true, failure: null));
    final result = await getDriversStatusUseCase();
    switch (result) {
      case ApiSuccessResult(:final data):
        emit(state.copyWith(
          isInitialLoading: false,
          summary: data,
          failure: null,
        ));
      case ApiErrorResult(:final failure):
        emit(state.copyWith(
          isInitialLoading: false,
          failure: failure,
        ));
    }
  }

  Future<void> _refresh() async {
    emit(state.copyWith(isRefreshing: true));
    final result = await getDriversStatusUseCase();
    switch (result) {
      case ApiSuccessResult(:final data):
        emit(state.copyWith(
          isRefreshing: false,
          summary: data,
          failure: null,
        ));
      case ApiErrorResult(:final failure):
        emit(state.copyWith(
          isRefreshing: false,
          failure: failure,
        ));
    }
  }

  Future<void> _toggleDriver(String driverId, bool isAvailable) async {
    final currentSummary = state.summary;
    if (currentSummary == null) return;

    final updatedDrivers = currentSummary.drivers.map((driver) {
      if (driver.id == driverId) {
        return driver.copyWith(
          isAvailable: isAvailable,
          status: isAvailable
              ? DispatcherDriverStatusType.available
              : DispatcherDriverStatusType.offline,
        );
      }
      return driver;
    }).toList();

    emit(state.copyWith(
      summary: DispatcherDriversStatusSummaryEntity(
        restaurantName: currentSummary.restaurantName,
        role: currentSummary.role,
        kpis: currentSummary.kpis,
        drivers: updatedDrivers,
      ),
      togglingDriverIds: {...state.togglingDriverIds, driverId},
    ));

    final result = await toggleDriverAvailabilityUseCase(
      driverId: driverId,
      isAvailable: isAvailable,
    );

    final updatedToggling = Set<String>.from(state.togglingDriverIds)..remove(driverId);

    if (result is ApiErrorResult) {
      // Revert if error
      final revertedDrivers = state.summary?.drivers.map((driver) {
        if (driver.id == driverId) {
          return driver.copyWith(
            isAvailable: !isAvailable,
            status: !isAvailable
                ? DispatcherDriverStatusType.available
                : DispatcherDriverStatusType.offline,
          );
        }
        return driver;
      }).toList();

      if (revertedDrivers != null && state.summary != null) {
        emit(state.copyWith(
          summary: DispatcherDriversStatusSummaryEntity(
            restaurantName: state.summary!.restaurantName,
            role: state.summary!.role,
            kpis: state.summary!.kpis,
            drivers: revertedDrivers,
          ),
          togglingDriverIds: updatedToggling,
        ));
      }
    } else {
      emit(state.copyWith(togglingDriverIds: updatedToggling));
    }
  }
}
