import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/box_issue_type.dart';
import '../../domain/entities/report_box_issue_request_entity.dart';
import '../../domain/usecase/get_box_tracking_usecase.dart';
import '../../domain/usecase/report_box_issue_usecase.dart';
import 'box_tracking_event.dart';
import 'box_tracking_state.dart';

@injectable
class BoxTrackingViewModel extends Cubit<BoxTrackingState> {
  BoxTrackingViewModel(
    this._getTrackingUseCase,
    this._reportIssueUseCase, {
    @factoryParam required String boxId,
  }) : super(BoxTrackingState(boxId: boxId));

  final GetBoxTrackingUseCase _getTrackingUseCase;
  final ReportBoxIssueUseCase _reportIssueUseCase;

  int _requestGeneration = 0;

  Future<void> doIntent(BoxTrackingEvent event) async {
    switch (event) {
      case LoadBoxTrackingEvent():
      case RetryBoxTrackingEvent():
        await _loadTracking(isRefresh: false);
      case RefreshBoxTrackingEvent():
        await _loadTracking(isRefresh: true);
      case ChangeBoxIssueTypeEvent(:final issueType):
        emit(state.copyWith(selectedIssueType: issueType));
      case ChangeBoxIssueDescriptionEvent(:final description):
        emit(state.copyWith(issueDescription: description));
      case SubmitBoxIssueEvent():
        await _submitIssue();
      case ResetBoxIssueFormEvent():
        emit(
          state.copyWith(
            issueDescription: '',
            selectedIssueType: BoxIssueType.other,
            clearReportFailure: true,
            clearReportSuccess: true,
          ),
        );
    }
  }

  Future<void> _loadTracking({required bool isRefresh}) async {
    final generation = ++_requestGeneration;

    if (isRefresh) {
      emit(state.copyWith(isRefreshing: true, clearNonFatalFailure: true));
    } else {
      emit(state.copyWith(isInitialLoading: true, clearInitialFailure: true));
    }

    final result = await _getTrackingUseCase(state.boxId);

    if (generation != _requestGeneration) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        if (isRefresh) {
          emit(
            state.copyWith(
              tracking: data,
              isRefreshing: false,
              clearNonFatalFailure: true,
            ),
          );
        } else {
          emit(
            state.copyWith(
              tracking: data,
              isInitialLoading: false,
              clearInitialFailure: true,
            ),
          );
        }
      case ApiErrorResult(:final failure):
        if (isRefresh) {
          emit(
            state.copyWith(
              isRefreshing: false,
              nonFatalFailure: failure,
              noticeId: state.noticeId + 1,
            ),
          );
        } else {
          emit(
            state.copyWith(isInitialLoading: false, initialFailure: failure),
          );
        }
    }
  }

  Future<void> _submitIssue() async {
    final trimmedDesc = state.issueDescription.trim();
    if (state.isSubmittingIssue || trimmedDesc.isEmpty) return;

    emit(
      state.copyWith(
        isSubmittingIssue: true,
        clearReportFailure: true,
        clearReportSuccess: true,
      ),
    );

    final request = ReportBoxIssueRequestEntity(
      issueType: state.selectedIssueType,
      description: trimmedDesc,
      severity: 'Medium',
    );

    final result = await _reportIssueUseCase(state.boxId, request);

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            isSubmittingIssue: false,
            reportSuccessMessage: data.message,
            reportNoticeId: state.reportNoticeId + 1,
            issueDescription: '',
            selectedIssueType: BoxIssueType.other,
            clearReportFailure: true,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            isSubmittingIssue: false,
            reportFailure: failure,
            reportNoticeId: state.reportNoticeId + 1,
            clearReportSuccess: true,
          ),
        );
    }
  }
}
