import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/usecase/get_dispatcher_home_overview_usecase.dart';
import '../../domain/usecase/get_dispatcher_live_drivers_usecase.dart';
import 'dispatcher_home_event.dart';
import 'dispatcher_home_state.dart';

@injectable
class DispatcherHomeViewModel extends Cubit<DispatcherHomeState> {
  DispatcherHomeViewModel({
    required this.getOverviewUseCase,
    required this.getLiveDriversUseCase,
  }) : super(const DispatcherHomeState());

  final GetDispatcherHomeOverviewUseCase getOverviewUseCase;
  final GetDispatcherLiveDriversUseCase getLiveDriversUseCase;

  void doIntent(DispatcherHomeEvent event) {
    switch (event) {
      case DispatcherHomeLoadEvent():
      case DispatcherHomeRefreshEvent():
        _loadAll();
      case DispatcherHomeRetryOverviewEvent():
        _loadOverview();
      case DispatcherHomeRetryLiveDriversEvent():
        _loadLiveDrivers();
    }
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadOverview(), _loadLiveDrivers()]);
  }

  Future<void> _loadOverview() async {
    emit(state.copyWith(isOverviewLoading: true, overviewFailure: null));
    final result = await getOverviewUseCase();
    if (isClosed) return;
    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            overview: data,
            isOverviewLoading: false,
            overviewFailure: null,
            hasLoadedOnce: true,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            isOverviewLoading: false,
            overviewFailure: failure,
            hasLoadedOnce: true,
          ),
        );
    }
  }

  Future<void> _loadLiveDrivers() async {
    emit(state.copyWith(isLiveDriversLoading: true, liveDriversFailure: null));
    final result = await getLiveDriversUseCase();
    if (isClosed) return;
    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            liveDrivers: data,
            isLiveDriversLoading: false,
            liveDriversFailure: null,
            hasLoadedOnce: true,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            isLiveDriversLoading: false,
            liveDriversFailure: failure,
            hasLoadedOnce: true,
          ),
        );
    }
  }
}
