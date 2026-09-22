import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_response_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_candidate_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_candidates_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassignment_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/repo/dispatcher_support_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/usecase/get_replacement_driver_candidates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/usecase/reassign_dispatcher_issue_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/screens/dispatcher_reassign_driver_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_app_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_bottom_button.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_issue_summary_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_list_header.dart';

const List<ReassignDriverCandidateEntity> _testCandidates = [
  ReassignDriverCandidateEntity(
    id: 'driver_1',
    name: 'محمد العازمي',
    code: 'DR-2011',
    isAvailable: true,
    rating: 4.8,
    ordersCount: 18,
    distanceKm: 1.2,
    avatarAsset: AppAssets.registrationDriverRole,
  ),
  ReassignDriverCandidateEntity(
    id: 'driver_2',
    name: 'يوسف المطيري',
    code: 'DR-2054',
    isAvailable: true,
    rating: 4.7,
    ordersCount: 12,
    distanceKm: 1.6,
    avatarAsset: AppAssets.registrationDriverRole,
  ),
  ReassignDriverCandidateEntity(
    id: 'driver_3',
    name: 'عبدالله الشمري',
    code: 'DR-1988',
    isAvailable: true,
    rating: 4.6,
    ordersCount: 9,
    distanceKm: 2.1,
    avatarAsset: AppAssets.registrationDriverRole,
  ),
  ReassignDriverCandidateEntity(
    id: 'driver_4',
    name: 'سالم الحربي',
    code: 'DR-2100',
    isAvailable: true,
    rating: 4.5,
    ordersCount: 15,
    distanceKm: 2.4,
    avatarAsset: AppAssets.registrationDriverRole,
  ),
  ReassignDriverCandidateEntity(
    id: 'driver_5',
    name: 'فهد العنزي',
    code: 'DR-2077',
    isAvailable: true,
    rating: 4.4,
    ordersCount: 8,
    distanceKm: 2.8,
    avatarAsset: AppAssets.registrationDriverRole,
  ),
];

class _FakeReassignRepository implements DispatcherSupportRepository {
  @override
  Future<ApiResult<ReassignDriverCandidatesEntity>> getReplacementCandidates(
    String issueId, {
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    return const ApiSuccessResult(
      data: ReassignDriverCandidatesEntity(
        summary: ReassignDriverIssueSummaryEntity(
          issueId: 'ISSUE-1258',
          title: 'تعطل الدراجة أثناء التوصيل',
          taskNumber: '#BX-1258',
          area: 'السالمية',
        ),
        currentDriver: DispatcherIssueDriverEntity(
          id: 'DR-2011',
          name: 'أحمد السيد',
          code: 'DR-2011',
        ),
        candidates: _testCandidates,
        pagination: DispatcherSupportPaginationEntity(
          pageNumber: 1,
          totalPages: 1,
          totalCount: 5,
        ),
      ),
    );
  }

  @override
  Future<ApiResult<ReassignmentResultEntity>> reassignIssue(
    String issueId,
    ReassignDriverRequestEntity request,
  ) async {
    final candidate = _testCandidates.firstWhere(
      (c) => c.id == request.replacementDriverId,
      orElse: () => _testCandidates.first,
    );
    return ApiSuccessResult(
      data: ReassignmentResultEntity(
        issueId: issueId,
        reassignedDriver: DispatcherIssueDriverEntity(
          id: candidate.id,
          name: candidate.name,
          code: candidate.code,
        ),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildTestableWidget({
  required Widget child,
  Locale locale = const Locale('ar'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6744C2)),
    ),
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    if (getIt.isRegistered<DispatcherSupportRepository>()) {
      await getIt.unregister<DispatcherSupportRepository>();
    }
    if (getIt.isRegistered<GetReplacementDriverCandidatesUseCase>()) {
      await getIt.unregister<GetReplacementDriverCandidatesUseCase>();
    }
    if (getIt.isRegistered<ReassignDispatcherIssueUseCase>()) {
      await getIt.unregister<ReassignDispatcherIssueUseCase>();
    }
    final repo = _FakeReassignRepository();
    getIt.registerLazySingleton<DispatcherSupportRepository>(() => repo);
    getIt.registerFactory<GetReplacementDriverCandidatesUseCase>(
      () => GetReplacementDriverCandidatesUseCase(repo),
    );
    getIt.registerFactory<ReassignDispatcherIssueUseCase>(
      () => ReassignDispatcherIssueUseCase(repo),
    );
  });

  group('DispatcherReassignDriverScreen Tests', () {
    testWidgets('renders all major components and cards in RTL Arabic', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 882 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(child: const DispatcherReassignDriverScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherReassignDriverScreen), findsOneWidget);
      expect(find.byType(ReassignDriverAppBar), findsOneWidget);
      expect(find.byType(ReassignDriverIssueSummaryCard), findsOneWidget);
      expect(find.byType(ReassignDriverListHeader), findsOneWidget);
      expect(find.byType(ReassignDriverCard), findsNWidgets(_testCandidates.length));
      expect(find.byType(ReassignDriverBottomButton), findsOneWidget);

      // Verify task number and issue title
      expect(find.text('تعطل الدراجة أثناء التوصيل'), findsOneWidget);
      expect(find.text('#BX-1258'), findsOneWidget);

      // Verify first candidate driver name
      expect(find.text(_testCandidates.first.name), findsOneWidget);
    });

    testWidgets('renders properly in English locale', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 882 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(
          locale: const Locale('en'),
          child: const DispatcherReassignDriverScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherReassignDriverScreen), findsOneWidget);
      expect(find.text('Assign Replacement Driver'), findsOneWidget);
      expect(find.text('Select Replacement Driver'), findsOneWidget);
      expect(find.text('Confirm Driver Selection'), findsOneWidget);
    });

    testWidgets('allows selecting another driver and triggers onConfirm', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 882 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      ReassignmentResultEntity? selectedResult;

      await tester.pumpWidget(
        _buildTestableWidget(
          child: DispatcherReassignDriverScreen(
            onConfirm: (res) {
              selectedResult = res;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap second driver
      final secondDriver = _testCandidates[1];
      await tester.tap(find.text(secondDriver.name));
      await tester.pumpAndSettle();

      // Tap confirm button
      await tester.tap(find.byType(ReassignDriverBottomButton));
      await tester.pumpAndSettle();

      expect(selectedResult, isNotNull);
      expect(selectedResult!.reassignedDriver?.id, secondDriver.id);
      expect(selectedResult!.reassignedDriver?.name, secondDriver.name);
    });

    testWidgets('renders without overflow on narrow viewport (360x720)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360 * 2, 720 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(child: const DispatcherReassignDriverScreen()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on extra small viewport (320x640)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(child: const DispatcherReassignDriverScreen()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
