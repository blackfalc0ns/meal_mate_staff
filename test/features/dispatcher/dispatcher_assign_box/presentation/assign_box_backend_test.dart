import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/arguments/assign_box_route_arguments.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_candidate_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_details_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_driver_status_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_order_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_priority.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_summary_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/repo/assign_box_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/usecase/get_assign_box_details_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/usecase/get_assign_box_summary_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/manager/assign_box_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/screens/assign_box_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_bottom_actions.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_summary_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/assign_driver_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/driver_assignment_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/repo/dispatcher_drivers_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/usecase/assign_driver_to_box_usecase.dart';

class MockBoxRepo implements AssignBoxRepository {
  int detailsCalls = 0;
  int summaryCalls = 0;
  Completer<ApiResult<AssignBoxDetailsEntity>>? detailsCompleter;
  Completer<ApiResult<AssignBoxSummaryEntity>>? summaryCompleter;

  ApiResult<AssignBoxDetailsEntity>? nextDetailsResult;
  ApiResult<AssignBoxSummaryEntity>? nextSummaryResult;

  @override
  Future<ApiResult<AssignBoxDetailsEntity>> getDetails(String boxId) {
    detailsCalls++;
    if (detailsCompleter != null) return detailsCompleter!.future;
    return Future.value(nextDetailsResult);
  }

  @override
  Future<ApiResult<AssignBoxSummaryEntity>> getSummary(String boxId) {
    summaryCalls++;
    if (summaryCompleter != null) return summaryCompleter!.future;
    return Future.value(nextSummaryResult);
  }
}

class MockDriversRepo implements DispatcherDriversRepository {
  int assignCalls = 0;
  AssignDriverRequestEntity? lastRequest;
  Completer<ApiResult<DriverAssignmentResultEntity>>? assignCompleter;
  ApiResult<DriverAssignmentResultEntity>? nextAssignResult;

  @override
  Future<ApiResult<DriverAssignmentResultEntity>> assignDriver(
    AssignDriverRequestEntity request,
  ) {
    assignCalls++;
    lastRequest = request;
    if (assignCompleter != null) return assignCompleter!.future;
    return Future.value(nextAssignResult);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const boxId = 'a1111111-1111-1111-1111-111111111111';
  const driverId1 = '33333333-3333-3333-3333-333333333333';
  const driverId2 = '44444444-4444-4444-4444-444444444444';

  const sampleBox = AssignBoxOrderEntity(
    boxId: boxId,
    boxCode: '#BX-1256',
    zoneName: 'المنطقة الشرقية',
    deliveryTimeWindow: '10:00 - 11:30 ص',
    mealsCount: 4,
    mealsCountText: '4 وجبات',
    distanceKm: 3.5,
    distanceText: '3.5 كم',
    priority: AssignBoxPriority.high,
    priorityText: 'أولوية عالية',
    status: AssignBoxStatus.pending,
    statusText: 'قيد الانتظار',
  );

  const sampleBestDriver = AssignBoxCandidateDriverEntity(
    driverId: driverId1,
    fullName: 'سالم الحربي',
    distanceText: '2.4 كم',
    activeOrdersCount: 1,
    currentLoadBoxes: 4,
    currentLoadLabel: '4 بوكسات',
    status: AssignBoxDriverStatusType.available,
    driverStatusText: 'متاح',
    statusTag: 'الأسرع وصولاً',
    estimatedFinishTimeText: '10:20 ص',
    rank: 1,
    isRecommended: true,
  );

  const sampleCandidate = AssignBoxCandidateDriverEntity(
    driverId: driverId2,
    fullName: 'عمر الدوسري',
    distanceText: '5.2 كم',
    activeOrdersCount: 3,
    currentLoadBoxes: 5,
    currentLoadLabel: '5 بوكسات',
    status: AssignBoxDriverStatusType.inDelivery,
    driverStatusText: 'في الطريق',
    statusTag: 'في المنطقة',
    estimatedFinishTimeText: '10:45 ص',
    rank: 2,
  );

  const sampleDetails = AssignBoxDetailsEntity(
    box: sampleBox,
    bestSuggestion: sampleBestDriver,
    candidates: [sampleCandidate],
  );

  const sampleSummary = AssignBoxSummaryEntity(
    boxId: boxId,
    boxCode: '#BX-1256',
    boxCount: 1,
  );

  late MockBoxRepo boxRepo;
  late MockDriversRepo driversRepo;
  late AssignBoxViewModel viewModel;

  Widget buildSubject({
    ValueChanged<String>? onViewAllDrivers,
  }) {
    return MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AssignBoxScreen(
        args: const AssignBoxRouteArgs(boxId: boxId),
        viewModel: viewModel,
        onViewAllDrivers: onViewAllDrivers,
      ),
    );
  }

  setUp(() {
    boxRepo = MockBoxRepo();
    driversRepo = MockDriversRepo();
    final getDetailsUseCase = GetAssignBoxDetailsUseCase(boxRepo);
    final getSummaryUseCase = GetAssignBoxSummaryUseCase(boxRepo);
    final assignDriverUseCase = AssignDriverToBoxUseCase(driversRepo);
    viewModel = AssignBoxViewModel(
      getDetailsUseCase,
      getSummaryUseCase,
      assignDriverUseCase,
      boxId: boxId,
    );
  });

  testWidgets('renders AssignBoxShimmer on first frame while loading', (tester) async {
    boxRepo.detailsCompleter = Completer<ApiResult<AssignBoxDetailsEntity>>();

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(AssignBoxShimmer), findsOneWidget);
  });

  testWidgets('renders ApiErrorWidget on initial load failure and retries on tap', (tester) async {
    boxRepo.nextDetailsResult = ApiErrorResult(
      failure: Failure(
        errorMessage: 'Network error',
        code: '500',
        exception: const ApiException(
          errorType: ApiErrorType.serverError,
          message: 'Server error',
        ),
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byType(ApiErrorWidget), findsOneWidget);
    expect(boxRepo.detailsCalls, 1);

    boxRepo.nextDetailsResult = const ApiSuccessResult(data: sampleDetails);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.text('#BX-1256'), findsOneWidget);
    expect(boxRepo.detailsCalls, 2);
  });

  testWidgets('renders API data, selects bestSuggestion by default, and single selection works', (tester) async {
    boxRepo.nextDetailsResult = const ApiSuccessResult(data: sampleDetails);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('#BX-1256'), findsOneWidget);
    expect(find.text('سالم الحربي'), findsOneWidget);
    expect(find.text('عمر الدوسري'), findsOneWidget);
    expect(viewModel.state.selectedDriverId, driverId1);

    // Select candidate
    await tester.tap(find.text('عمر الدوسري'));
    await tester.pumpAndSettle();

    expect(viewModel.state.selectedDriverId, driverId2);
    expect(boxRepo.detailsCalls, 1); // No new request
  });

  testWidgets('View Box modal opens with AssignBoxSummaryShimmer then displays summary', (tester) async {
    boxRepo.nextDetailsResult = const ApiSuccessResult(data: sampleDetails);
    boxRepo.summaryCompleter = Completer<ApiResult<AssignBoxSummaryEntity>>();

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Tap View Box
    await tester.tap(find.text('عرض البوكس'));
    await tester.pump();

    expect(find.byType(AssignBoxSummaryShimmer), findsOneWidget);

    boxRepo.summaryCompleter!.complete(const ApiSuccessResult(data: sampleSummary));
    await tester.pumpAndSettle();

    expect(find.byType(AssignBoxSummaryShimmer), findsNothing);
    expect(find.text('1 بوكس'), findsOneWidget);
  });

  testWidgets('submit shows progress in Confirm button and handles successful assignment', (tester) async {
    boxRepo.nextDetailsResult = const ApiSuccessResult(data: sampleDetails);
    driversRepo.assignCompleter = Completer<ApiResult<DriverAssignmentResultEntity>>();

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Confirm button is enabled with default selection
    expect(find.byType(AssignBoxBottomActions), findsOneWidget);

    await tester.tap(find.text('تأكيد الإسناد'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(driversRepo.assignCalls, 1);

    driversRepo.assignCompleter!.complete(
      const ApiSuccessResult(
        data: DriverAssignmentResultEntity(
          success: true,
          message: 'تم إسناد البوكس بنجاح',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(viewModel.state.successId, 1);
  });

  testWidgets('View All triggers callback with boxId', (tester) async {
    boxRepo.nextDetailsResult = const ApiSuccessResult(data: sampleDetails);
    String? capturedBoxId;

    await tester.pumpWidget(
      buildSubject(onViewAllDrivers: (id) => capturedBoxId = id),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('عرض الكل'));
    await tester.pumpAndSettle();

    expect(capturedBoxId, boxId);
  });
}
