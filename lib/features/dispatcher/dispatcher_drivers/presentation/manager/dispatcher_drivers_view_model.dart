import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/routing/arguments/dispatcher_drivers_route_arguments.dart';
import '../../../../../core/errors/api_error_type.dart';
import '../../../../../core/network/api_results.dart';
import '../../domain/entities/assign_driver_request_entity.dart';
import '../../domain/entities/dispatcher_driver_view_mode.dart';
import '../../domain/entities/dispatcher_drivers_mode.dart';
import '../../domain/entities/dispatcher_drivers_query_entity.dart';
import '../../domain/usecase/assign_driver_to_box_usecase.dart';
import '../../domain/usecase/get_dispatcher_drivers_roster_usecase.dart';
import 'dispatcher_drivers_event.dart';
import 'dispatcher_drivers_state.dart';

@injectable
class DispatcherDriversViewModel extends Cubit<DispatcherDriversState> {
  DispatcherDriversViewModel({
    required DispatcherDriversRouteArgs args,
    required this.getRosterUseCase,
    required this.assignDriverUseCase,
  }) : super(
         DispatcherDriversState(
           args: args,
           query: DispatcherDriversQueryEntity(
             view: args.initialView,
             areaKey: args.initialAreaKey,
             areaName: args.initialAreaName,
             boxId: args.mode == DispatcherDriversMode.assignment
                 ? args.boxId
                 : null,
           ),
           lastSelectedAreaKey: args.initialAreaKey,
           lastSelectedAreaName: args.initialAreaName,
         ),
       );

  final GetDispatcherDriversRosterUseCase getRosterUseCase;
  final AssignDriverToBoxUseCase assignDriverUseCase;

  int _requestGeneration = 0;
  DispatcherDriversQueryEntity? _lastAttemptedQuery;

  Future<void> doIntent(DispatcherDriversEvent event) async {
    switch (event) {
      case LoadDispatcherDriversEvent():
        await _loadInitial();
      case RetryDispatcherDriversEvent():
        await _retry();
      case RefreshDispatcherDriversEvent():
        await _refresh();
      case ChangeDispatcherDriversViewEvent():
        await _changeView(event.view);
      case ChangeDispatcherDriversAreaEvent():
        await _changeArea(event.areaKey, event.areaName);
      case ChangeDispatcherDriversSortEvent():
        emit(state.copyWith(selectedSort: event.sort));
      case SelectRosterDriverEvent():
        emit(
          state.copyWith(
            selectedDriverForBrowse: event.driver,
            noticeId: state.noticeId + 1,
          ),
        );
      case AssignRosterDriverEvent():
        await _assignDriver(event);
      case ClearDispatcherDriversNoticeEvent():
        emit(
          state.copyWith(
            clearAssignmentFailure: true,
            clearAssignmentResult: true,
            clearNonFatalFailure: true,
            clearSelectedDriverForBrowse: true,
          ),
        );
    }
  }

  Future<void> _loadInitial() async {
    final query = DispatcherDriversQueryEntity(
      view: state.args.initialView,
      areaKey: state.args.initialAreaKey,
      areaName: state.args.initialAreaName,
      boxId: state.args.mode == DispatcherDriversMode.assignment
          ? state.args.boxId
          : null,
    );
    await _fetchRoster(query, isInitial: true);
  }

  Future<void> _retry() async {
    if (!state.hasLoadedOnce || state.roster == null) {
      await _loadInitial();
    } else {
      await _fetchRoster(_lastAttemptedQuery ?? state.query, isInitial: false);
    }
  }

  Future<void> _refresh() async {
    await _fetchRoster(state.query, isInitial: false);
  }

  Future<void> _changeView(DispatcherDriverViewMode view) async {
    if (view == state.query.view) return;

    if (view == DispatcherDriverViewMode.allDrivers) {
      final savedAreaKey = state.query.areaKey ?? state.lastSelectedAreaKey;
      final savedAreaName = state.query.areaName ?? state.lastSelectedAreaName;

      final targetQuery = state.query.copyWith(
        view: DispatcherDriverViewMode.allDrivers,
        clearArea: true,
      );

      emit(
        state.copyWith(
          query: targetQuery,
          isReplacementLoading: true,
          lastSelectedAreaKey: savedAreaKey,
          lastSelectedAreaName: savedAreaName,
          clearNonFatalFailure: true,
        ),
      );

      await _fetchRoster(targetQuery, isInitial: false);
    } else {
      final targetQuery = state.query.copyWith(
        view: DispatcherDriverViewMode.byArea,
        areaKey: state.lastSelectedAreaKey,
        areaName: state.lastSelectedAreaName,
      );

      emit(
        state.copyWith(
          query: targetQuery,
          isReplacementLoading: true,
          clearNonFatalFailure: true,
        ),
      );

      await _fetchRoster(targetQuery, isInitial: false);
    }
  }

  Future<void> _changeArea(String areaKey, String? areaName) async {
    if (state.query.view == DispatcherDriverViewMode.byArea &&
        state.query.areaKey == areaKey) {
      return;
    }

    final targetQuery = state.query.copyWith(
      view: DispatcherDriverViewMode.byArea,
      areaKey: areaKey,
      areaName: areaName,
    );

    emit(
      state.copyWith(
        query: targetQuery,
        isReplacementLoading: true,
        lastSelectedAreaKey: areaKey,
        lastSelectedAreaName: areaName,
        clearNonFatalFailure: true,
      ),
    );

    await _fetchRoster(targetQuery, isInitial: false);
  }

  Future<void> _assignDriver(AssignRosterDriverEvent event) async {
    if (state.args.mode != DispatcherDriversMode.assignment) return;
    if (!event.driver.isAvailableForSelection) return;
    if (state.isAssigning) return; // Guard against duplicate submissions

    final boxId = state.args.boxId;
    if (boxId == null || boxId.trim().isEmpty) return;

    emit(
      state.copyWith(
        assigningDriverId: event.driver.driverId,
        clearAssignmentFailure: true,
        clearAssignmentResult: true,
      ),
    );

    final request = AssignDriverRequestEntity(
      boxId: boxId,
      driverId: event.driver.driverId,
      notes: 'إسناد مباشر من قائمة السائقين',
    );

    final result = await assignDriverUseCase(request);

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            clearAssigningDriverId: true,
            assignmentResult: data,
            noticeId: state.noticeId + 1,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            clearAssigningDriverId: true,
            assignmentFailure: failure,
            noticeId: state.noticeId + 1,
          ),
        );
        final isConflict =
            failure.exception.errorType == ApiErrorType.conflict ||
            failure.code == '409' ||
            failure.code.toLowerCase().contains('conflict');
        if (isConflict) {
          await _refresh();
        }
    }
  }

  Future<void> _fetchRoster(
    DispatcherDriversQueryEntity targetQuery, {
    required bool isInitial,
  }) async {
    _lastAttemptedQuery = targetQuery;
    final generation = ++_requestGeneration;
    final isFirstLoad = !state.hasLoadedOnce;

    emit(
      state.copyWith(
        query: targetQuery,
        isInitialLoading: isFirstLoad,
        isReplacementLoading: !isFirstLoad,
        clearInitialFailure: true,
        clearNonFatalFailure: true,
      ),
    );

    final result = await getRosterUseCase(targetQuery);

    if (generation != _requestGeneration) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            roster: data,
            hasLoadedOnce: true,
            isInitialLoading: false,
            isReplacementLoading: false,
            lastSelectedAreaKey:
                data.selectedAreaKey ?? state.lastSelectedAreaKey,
            lastSelectedAreaName:
                (data.selectedAreaName != null &&
                    data.selectedAreaName!.isNotEmpty)
                ? data.selectedAreaName
                : state.lastSelectedAreaName,
          ),
        );
      case ApiErrorResult(:final failure):
        if (isFirstLoad) {
          emit(
            state.copyWith(
              isInitialLoading: false,
              isReplacementLoading: false,
              initialFailure: failure,
            ),
          );
        } else {
          emit(
            state.copyWith(
              isReplacementLoading: false,
              nonFatalFailure: failure,
              noticeId: state.noticeId + 1,
            ),
          );
        }
    }
  }
}
