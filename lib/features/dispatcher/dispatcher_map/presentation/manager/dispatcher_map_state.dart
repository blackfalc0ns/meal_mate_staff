import '../../../../../core/network/failures.dart';
import '../../domain/entities/dispatcher_live_monitoring_entity.dart';
import '../../domain/entities/dispatcher_map_connection_status.dart';
import '../../domain/entities/dispatcher_map_driver_entity.dart';
import '../../domain/entities/dispatcher_map_kpi_entity.dart';

const _unchanged = Object();

class DispatcherMapState {
  const DispatcherMapState({
    this.snapshot,
    this.selectedDriverId,
    this.isInitialLoading = false,
    this.isRefreshLoading = false,
    this.isReconciling = false,
    this.failure,
    this.connectionStatus = DispatcherMapConnectionStatus.disconnected,
    this.hasLoadedOnce = false,
    this.lastSyncTime,
    this.isSynchronized = false,
  });

  final DispatcherLiveMonitoringEntity? snapshot;
  final String? selectedDriverId;
  final bool isInitialLoading;
  final bool isRefreshLoading;
  final bool isReconciling;
  final Failure? failure;
  final DispatcherMapConnectionStatus connectionStatus;
  final bool hasLoadedOnce;
  final DateTime? lastSyncTime;
  final bool isSynchronized;

  bool get isLoading => isInitialLoading || isRefreshLoading || isReconciling;

  bool get hasData => snapshot != null;

  List<DispatcherMapDriverEntity> get drivers => snapshot?.drivers ?? const [];

  DispatcherMapKpiEntity? get kpi => snapshot?.kpi;

  DispatcherMapDriverEntity? get selectedDriver {
    if (selectedDriverId == null || snapshot == null) return null;
    for (final driver in snapshot!.drivers) {
      if (driver.id == selectedDriverId) return driver;
    }
    return null;
  }

  DispatcherMapState copyWith({
    Object? snapshot = _unchanged,
    Object? selectedDriverId = _unchanged,
    bool? isInitialLoading,
    bool? isRefreshLoading,
    bool? isReconciling,
    Object? failure = _unchanged,
    DispatcherMapConnectionStatus? connectionStatus,
    bool? hasLoadedOnce,
    Object? lastSyncTime = _unchanged,
    bool? isSynchronized,
  }) {
    return DispatcherMapState(
      snapshot: identical(snapshot, _unchanged)
          ? this.snapshot
          : snapshot as DispatcherLiveMonitoringEntity?,
      selectedDriverId: identical(selectedDriverId, _unchanged)
          ? this.selectedDriverId
          : selectedDriverId as String?,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshLoading: isRefreshLoading ?? this.isRefreshLoading,
      isReconciling: isReconciling ?? this.isReconciling,
      failure: identical(failure, _unchanged)
          ? this.failure
          : failure as Failure?,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
      lastSyncTime: identical(lastSyncTime, _unchanged)
          ? this.lastSyncTime
          : lastSyncTime as DateTime?,
      isSynchronized: isSynchronized ?? this.isSynchronized,
    );
  }
}
