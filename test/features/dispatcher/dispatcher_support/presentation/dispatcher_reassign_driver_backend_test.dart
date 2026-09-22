import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/inline_api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_response_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_candidate_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_candidates_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassignment_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/repo/dispatcher_support_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/usecase/get_replacement_driver_candidates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/usecase/reassign_dispatcher_issue_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/manager/reassignment/dispatcher_reassignment_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/screens/dispatcher_reassign_driver_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/dispatcher_reassign_empty_state_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/dispatcher_reassign_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_card.dart';

class _TestReassignRepository implements DispatcherSupportRepository {
  Completer<ApiResult<ReassignDriverCandidatesEntity>>? pendingCandidatesCompleter;
  ApiResult<ReassignDriverCandidatesEntity>? nextCandidatesResult;
  ApiResult<ReassignmentResultEntity>? nextReassignResult;
  int candidatesCallCount = 0;
  int reassignCallCount = 0;
  List<int> requestedPages = [];

  @override
  Future<ApiResult<ReassignDriverCandidatesEntity>> getReplacementCandidates(
    String issueId, {
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    candidatesCallCount++;
    requestedPages.add(pageNumber);
    if (pendingCandidatesCompleter != null) {
      return pendingCandidatesCompleter!.future;
    }
    return nextCandidatesResult ??
        ApiSuccessResult(
          data: _sampleCandidates(
            issueId: issueId,
            page: pageNumber,
          ),
        );
  }

  @override
  Future<ApiResult<ReassignmentResultEntity>> reassignIssue(
    String issueId,
    ReassignDriverRequestEntity request,
  ) async {
    reassignCallCount++;
    return nextReassignResult ??
        ApiSuccessResult(
          data: ReassignmentResultEntity(
            issueId: issueId,
            status: DispatcherIssueStatus.resolved,
            reassignedDriver: DispatcherIssueDriverEntity(
              id: request.replacementDriverId,
              name: 'سالم الدوسري',
              code: 'DRV-101',
              phoneNumber: '+96598765432',
            ),
          ),
        );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ReassignDriverCandidatesEntity _sampleCandidates({
  required String issueId,
  int page = 1,
  int totalPages = 1,
  List<ReassignDriverCandidateEntity>? candidates,
}) {
  return ReassignDriverCandidatesEntity(
    summary: ReassignDriverIssueSummaryEntity(
      issueId: issueId,
      title: 'عطل مركبة في الطريق',
      category: 'VEHICLE_BREAKDOWN',
      priorityText: 'عالية',
      taskNumber: 'BX-999',
      area: 'السالمية',
      affectedBoxesCount: 2,
    ),
    currentDriver: const DispatcherIssueDriverEntity(
      id: 'drv-current',
      name: 'محمد خالد',
      code: 'DRV-001',
      phoneNumber: '+96591234567',
      vehicleInfo: '12345',
      rating: 4.8,
    ),
    candidates: candidates ??
        [
          const ReassignDriverCandidateEntity(
            id: 'drv-c1',
            name: 'سالم الدوسري',
            code: 'DRV-101',
            rating: 4.9,
            distanceKm: 1.2,
            isAvailable: true,
            activeOrdersCount: 1,
          ),
          const ReassignDriverCandidateEntity(
            id: 'drv-c2',
            name: 'خالد الحربي',
            code: 'DRV-102',
            rating: 4.7,
            distanceKm: 2.5,
            isAvailable: true,
            activeOrdersCount: 2,
          ),
        ],
    pagination: DispatcherSupportPaginationEntity(
      pageNumber: page,
      totalPages: totalPages,
      totalCount: 2,
      hasNextPage: page < totalPages,
    ),
  );
}

Widget buildSubject({
  required DispatcherReassignmentViewModel viewModel,
  String issueId = 'ISS-001',
  ValueChanged<ReassignmentResultEntity>? onConfirm,
}) {
  return MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: DispatcherReassignDriverScreen(
      issueId: issueId,
      viewModel: viewModel,
      onConfirm: onConfirm,
    ),
  );
}

void main() {
  late _TestReassignRepository repository;
  late GetReplacementDriverCandidatesUseCase getCandidatesUseCase;
  late ReassignDispatcherIssueUseCase reassignUseCase;

  setUp(() {
    repository = _TestReassignRepository();
    getCandidatesUseCase = GetReplacementDriverCandidatesUseCase(repository);
    reassignUseCase = ReassignDispatcherIssueUseCase(repository);
  });

  testWidgets('displays DispatcherReassignShimmer during initial loading', (tester) async {
    repository.pendingCandidatesCompleter = Completer();
    final vm = DispatcherReassignmentViewModel(
      issueId: 'ISS-001',
      getCandidatesUseCase: getCandidatesUseCase,
      reassignUseCase: reassignUseCase,
    );

    await tester.pumpWidget(buildSubject(viewModel: vm));
    await tester.pump();

    expect(find.byType(DispatcherReassignShimmer), findsOneWidget);

    repository.pendingCandidatesCompleter!.complete(
      ApiSuccessResult(data: _sampleCandidates(issueId: 'ISS-001')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DispatcherReassignShimmer), findsNothing);
    expect(find.text('عطل مركبة في الطريق'), findsOneWidget);
  });

  testWidgets('displays ApiErrorWidget on initial failure and retries on press', (tester) async {
    repository.nextCandidatesResult = ApiErrorResult(
      failure: Failure(errorMessage: 'فشل تحميل السائقين البدلاء'),
    );

    final vm = DispatcherReassignmentViewModel(
      issueId: 'ISS-001',
      getCandidatesUseCase: getCandidatesUseCase,
      reassignUseCase: reassignUseCase,
    );

    await tester.pumpWidget(buildSubject(viewModel: vm));
    await tester.pumpAndSettle();

    expect(find.byType(ApiErrorWidget), findsOneWidget);
    expect(find.text('فشل تحميل السائقين البدلاء'), findsOneWidget);

    repository.nextCandidatesResult = ApiSuccessResult(data: _sampleCandidates(issueId: 'ISS-001'));
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    expect(find.byType(ApiErrorWidget), findsNothing);
    expect(find.text('عطل مركبة في الطريق'), findsOneWidget);
    expect(repository.candidatesCallCount, 2);
  });

  testWidgets('renders current driver and candidate cards from domain entities', (tester) async {
    final vm = DispatcherReassignmentViewModel(
      issueId: 'ISS-001',
      getCandidatesUseCase: getCandidatesUseCase,
      reassignUseCase: reassignUseCase,
    );

    await tester.pumpWidget(buildSubject(viewModel: vm));
    await tester.pumpAndSettle();

    expect(find.text('عطل مركبة في الطريق'), findsOneWidget);
    expect(find.text('محمد خالد'), findsOneWidget);
    expect(find.text('سالم الدوسري'), findsOneWidget);
    expect(find.text('خالد الحربي'), findsOneWidget);
    expect(find.byType(ReassignDriverCard), findsNWidgets(2));
  });

  testWidgets('displays DispatcherReassignEmptyStateCard when candidate list is empty', (tester) async {
    repository.nextCandidatesResult = ApiSuccessResult(
      data: _sampleCandidates(
        issueId: 'ISS-001',
        candidates: const [],
      ),
    );

    final vm = DispatcherReassignmentViewModel(
      issueId: 'ISS-001',
      getCandidatesUseCase: getCandidatesUseCase,
      reassignUseCase: reassignUseCase,
    );

    await tester.pumpWidget(buildSubject(viewModel: vm));
    await tester.pumpAndSettle();

    expect(find.byType(DispatcherReassignEmptyStateCard), findsOneWidget);
    expect(find.text('لا يوجد سائقون بدلاء متاحون'), findsOneWidget);
  });

  testWidgets('pagination scroll triggers loadNextPage and shows inline error on failure', (tester) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    repository.nextCandidatesResult = ApiSuccessResult(
      data: _sampleCandidates(
        issueId: 'ISS-001',
        page: 1,
        totalPages: 2,
        candidates: List.generate(
          10,
          (i) => ReassignDriverCandidateEntity(
            id: 'drv-$i',
            name: 'سائق $i',
            code: 'DRV-$i',
            rating: 4.5,
            distanceKm: i * 0.5,
            isAvailable: true,
          ),
        ),
      ),
    );

    final vm = DispatcherReassignmentViewModel(
      issueId: 'ISS-001',
      getCandidatesUseCase: getCandidatesUseCase,
      reassignUseCase: reassignUseCase,
    );

    await tester.pumpWidget(buildSubject(viewModel: vm));
    await tester.pumpAndSettle();

    expect(find.text('سائق 0'), findsOneWidget);

    // Simulate page 2 failure
    repository.nextCandidatesResult = ApiErrorResult(
      failure: Failure(errorMessage: 'فشل تحميل الصفحة التالية'),
    );

    // Scroll to bottom
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -1000));
    await tester.pumpAndSettle();

    expect(repository.candidatesCallCount, 2);
    expect(repository.requestedPages, contains(2));
    expect(find.byType(InlineApiErrorWidget), findsOneWidget);
    expect(find.text('فشل تحميل الصفحة التالية'), findsOneWidget);
  });

  testWidgets('tapping candidate selects candidate and enables submit', (tester) async {
    final vm = DispatcherReassignmentViewModel(
      issueId: 'ISS-001',
      getCandidatesUseCase: getCandidatesUseCase,
      reassignUseCase: reassignUseCase,
    );

    await tester.pumpWidget(buildSubject(viewModel: vm));
    await tester.pumpAndSettle();

    // Tap second candidate
    await tester.tap(find.text('خالد الحربي'));
    await tester.pumpAndSettle();

    expect(vm.state.selectedDriverId, 'drv-c2');
  });

  testWidgets('handles conflict REPLACEMENT_DRIVER_NO_LONGER_AVAILABLE and refreshes candidates', (tester) async {
    repository.nextReassignResult = ApiErrorResult(
      failure: Failure(
        errorMessage: 'السائق غير متاح حالياً',
        code: 'REPLACEMENT_DRIVER_NO_LONGER_AVAILABLE',
      ),
    );

    final vm = DispatcherReassignmentViewModel(
      issueId: 'ISS-001',
      getCandidatesUseCase: getCandidatesUseCase,
      reassignUseCase: reassignUseCase,
    );

    await tester.pumpWidget(buildSubject(viewModel: vm));
    await tester.pumpAndSettle();

    // Confirm button
    await tester.tap(find.text('تأكيد اختيار السائق'));
    await tester.pumpAndSettle();

    expect(find.byType(InlineApiErrorWidget), findsOneWidget);
    expect(repository.reassignCallCount, 1);
    expect(repository.candidatesCallCount, 2); // Auto refreshed
  });

  testWidgets('handles terminal conflict ISSUE_ALREADY_RESOLVED_OR_REASSIGNED and disables submit', (tester) async {
    repository.nextReassignResult = ApiErrorResult(
      failure: Failure(
        errorMessage: 'تم حل المشكلة مسبقاً',
        code: 'ISSUE_ALREADY_RESOLVED_OR_REASSIGNED',
      ),
    );

    final vm = DispatcherReassignmentViewModel(
      issueId: 'ISS-001',
      getCandidatesUseCase: getCandidatesUseCase,
      reassignUseCase: reassignUseCase,
    );

    await tester.pumpWidget(buildSubject(viewModel: vm));
    await tester.pumpAndSettle();

    await tester.tap(find.text('تأكيد اختيار السائق'));
    await tester.pumpAndSettle();

    expect(vm.state.terminalIssueConflict, isTrue);
    expect(vm.state.canSubmit, isFalse);
    expect(find.byType(InlineApiErrorWidget), findsOneWidget);
  });

  testWidgets('successful reassignment invokes onConfirm and pops with ReassignmentResultEntity', (tester) async {
    ReassignmentResultEntity? confirmedResult;

    final vm = DispatcherReassignmentViewModel(
      issueId: 'ISS-001',
      getCandidatesUseCase: getCandidatesUseCase,
      reassignUseCase: reassignUseCase,
    );

    await tester.pumpWidget(
      buildSubject(
        viewModel: vm,
        onConfirm: (res) => confirmedResult = res,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('تأكيد اختيار السائق'));
    await tester.pumpAndSettle();

    expect(repository.reassignCallCount, 1);
    expect(confirmedResult, isNotNull);
    expect(confirmedResult!.reassignedDriver?.id, 'drv-c1');
    expect(confirmedResult!.reassignedDriver?.name, 'سالم الدوسري');
  });
}
