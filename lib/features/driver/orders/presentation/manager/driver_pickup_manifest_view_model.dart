import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/driver_boxes_filter_type.dart';
import '../../domain/usecase/get_driver_pickup_manifest_usecase.dart';
import 'driver_pickup_manifest_event.dart';
import 'driver_pickup_manifest_state.dart';

@injectable
class DriverPickupManifestViewModel extends Cubit<DriverPickupManifestState> {
  DriverPickupManifestViewModel({required this.getManifestUseCase})
      : super(const DriverPickupManifestState());

  final GetDriverPickupManifestUseCase getManifestUseCase;

  int _requestGeneration = 0;

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
