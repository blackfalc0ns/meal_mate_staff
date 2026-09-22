import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/inline_api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_attachment_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_detail_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_resolution_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_trip_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassignment_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/resolve_issue_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/repo/dispatcher_support_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/usecase/get_dispatcher_issue_details_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/usecase/resolve_dispatcher_issue_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/manager/issue_details/dispatcher_issue_details_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/screens/dispatcher_issue_details_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_evidence_photo_viewer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_issue_details_action_buttons.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_issue_details_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_issue_resolution_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_resolve_issue_dialog.dart';

class _TestDetailsRepository implements DispatcherSupportRepository {
  Completer<ApiResult<DispatcherIssueDetailEntity>>? pendingCompleter;
  ApiResult<DispatcherIssueDetailEntity>? nextDetailsResult;
  ApiResult<ResolveIssueResultEntity>? nextResolveResult;
  int detailsCallCount = 0;
  int resolveCallCount = 0;

  @override
  Future<ApiResult<DispatcherIssueDetailEntity>> getIssueDetails(String issueId) async {
    detailsCallCount++;
    if (pendingCompleter != null) {
      return pendingCompleter!.future;
    }
    return nextDetailsResult ??
        ApiSuccessResult(data: _sampleDetail(issueId: issueId));
  }

  @override
  Future<ApiResult<ResolveIssueResultEntity>> resolveIssue(
    String issueId,
    String resolutionNotes,
  ) async {
    resolveCallCount++;
    return nextResolveResult ??
        ApiSuccessResult(
          data: ResolveIssueResultEntity(
            issueId: issueId,
            status: DispatcherIssueStatus.resolved,
            resolution: DispatcherIssueResolutionEntity(
              resolutionNotes: resolutionNotes,
              resolvedAtUtc: DateTime.utc(2026, 9, 22, 12, 0),
            ),
          ),
        );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DispatcherIssueDetailEntity _sampleDetail({
  required String issueId,
  DispatcherIssueStatus status = DispatcherIssueStatus.open,
  List<DispatcherIssueAttachmentEntity> attachments = const [],
  DispatcherIssueResolutionEntity? resolution,
}) {
  return DispatcherIssueDetailEntity(
    issueId: issueId,
    title: 'تلف وجبات في الطريق',
    category: 'MEAL_DAMAGE',
    categoryLabel: 'تلف وجبة',
    status: status,
    statusLabel: status == DispatcherIssueStatus.resolved ? 'محلولة' : 'مفتوحة',
    boxCode: 'BX-555',
    area: 'الرياض - السليمانية',
    affectedBoxesCount: 3,
    driver: const DispatcherIssueDriverEntity(
      id: 'drv-1',
      name: 'علي المنصور',
      code: 'DRV-77',
      isOnline: true,
    ),
    description: 'سقوط البوكس أثناء القيادة وتلف 3 وجبات',
    evidencePhotos: attachments,
    tripInfo: const DispatcherIssueTripEntity(
      clientName: 'شركة التقنية الحديثة',
      mealsCount: 6,
      expectedDeliveryTime: '01:30 PM',
      pickupLocation: 'مطعم ميل ميت',
      dropoffLocation: 'برج الفيصلية',
    ),
    resolution: resolution,
  );
}

void main() {
  late _TestDetailsRepository repository;
  late GetDispatcherIssueDetailsUseCase getDetailsUseCase;
  late ResolveDispatcherIssueUseCase resolveUseCase;

  setUp(() {
    repository = _TestDetailsRepository();
    getDetailsUseCase = GetDispatcherIssueDetailsUseCase(repository);
    resolveUseCase = ResolveDispatcherIssueUseCase(repository);
  });

  DispatcherIssueDetailsViewModel createViewModel({String issueId = 'ISS-001'}) {
    return DispatcherIssueDetailsViewModel(
      issueId: issueId,
      getDetailsUseCase: getDetailsUseCase,
      resolveUseCase: resolveUseCase,
    );
  }

  Widget buildSubject({
    required DispatcherIssueDetailsViewModel viewModel,
    ReassignmentResultEntity? simulatedReassignResult,
  }) {
    return MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.dispatcherReassignDriver) {
          return MaterialPageRoute<dynamic>(
            builder: (routeContext) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const Key('simulate_reassign_pop'),
                  onPressed: () {
                    Navigator.pop(
                      routeContext,
                      simulatedReassignResult ??
                          const ReassignmentResultEntity(
                            issueId: 'ISS-001',
                            status: DispatcherIssueStatus.resolved,
                            reassignedDriver: DispatcherIssueDriverEntity(
                              id: 'drv-new',
                              name: 'سائق جديد بديل',
                              code: 'DRV-NEW',
                            ),
                          ),
                    );
                  },
                  child: const Text('Pop Reassign'),
                ),
              ),
            ),
          );
        }
        return null;
      },
      home: DispatcherIssueDetailsScreen(
        issueId: viewModel.issueId,
        viewModel: viewModel,
      ),
    );
  }

  testWidgets('displays DispatcherIssueDetailsShimmer during initial loading', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final completer = Completer<ApiResult<DispatcherIssueDetailEntity>>();
    repository.pendingCompleter = completer;
    final vm = createViewModel();

    await tester.pumpWidget(buildSubject(viewModel: vm));
    await tester.pump();

    expect(find.byType(DispatcherIssueDetailsShimmer), findsOneWidget);
    expect(find.byType(ApiErrorWidget), findsNothing);

    completer.complete(ApiSuccessResult(data: _sampleDetail(issueId: 'ISS-001')));
    await tester.pumpAndSettle();

    expect(find.byType(DispatcherIssueDetailsShimmer), findsNothing);
    expect(find.text('تلف وجبات في الطريق'), findsOneWidget);
  });

  testWidgets('displays ApiErrorWidget on initial failure and retries on press', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    repository.nextDetailsResult = ApiErrorResult(failure: Failure(errorMessage: 'خطأ في الشبكة'));
    final vm = createViewModel();

    await tester.pumpWidget(buildSubject(viewModel: vm));
    await tester.pumpAndSettle();

    expect(find.byType(ApiErrorWidget), findsOneWidget);
    expect(find.text('تلف وجبات في الطريق'), findsNothing);

    // Prepare success for retry
    repository.nextDetailsResult = ApiSuccessResult(data: _sampleDetail(issueId: 'ISS-001'));

    final retryButton = find.byType(AppButton);
    expect(retryButton, findsOneWidget);

    await tester.tap(retryButton);
    await tester.pumpAndSettle();

    expect(find.byType(ApiErrorWidget), findsNothing);
    expect(find.text('تلف وجبات في الطريق'), findsOneWidget);
  });

  testWidgets('renders mapped live content and graceful empty evidence', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final vm = createViewModel();
    repository.nextDetailsResult = ApiSuccessResult(
      data: _sampleDetail(issueId: 'ISS-001', attachments: []),
    );

    await tester.pumpWidget(buildSubject(viewModel: vm));
    await tester.pumpAndSettle();

    expect(find.text('تلف وجبات في الطريق'), findsOneWidget);
    expect(find.text('علي المنصور'), findsOneWidget);
    expect(find.text('DRV-77'), findsOneWidget);
    expect(find.text('شركة التقنية الحديثة'), findsOneWidget);
    expect(find.text('برج الفيصلية'), findsOneWidget);
    expect(find.text('مرفقات / صورة مرفوعة'), findsNothing);
    expect(find.byType(DispatcherIssueDetailsActionButtons), findsOneWidget);
    expect(find.byType(DispatcherIssueResolutionCard), findsNothing);
  });

  testWidgets('clicking evidence photo opens full-screen DispatcherEvidencePhotoViewer with InteractiveViewer', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final vm = createViewModel();
    repository.nextDetailsResult = ApiSuccessResult(
      data: _sampleDetail(
        issueId: 'ISS-001',
        attachments: [
          const DispatcherIssueAttachmentEntity(
            id: 'att-1',
            url: 'assets/images/dispatcher/issue_attachment_1.png',
            thumbnailUrl: null,
            imageAsset: 'assets/images/dispatcher/issue_attachment_1.png',
            orderNumber: 1,
          ),
        ],
      ),
    );

    await tester.pumpWidget(buildSubject(viewModel: vm));
    await tester.pumpAndSettle();

    expect(find.text('مرفقات / صورة مرفوعة'), findsOneWidget);

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    expect(find.byType(DispatcherEvidencePhotoViewer), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(DispatcherEvidencePhotoViewer), findsNothing);
  });

  testWidgets('resolve dialog validates notes between 3 and 500 characters and handles inline resolve error', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final vm = createViewModel();
    repository.nextDetailsResult = ApiSuccessResult(data: _sampleDetail(issueId: 'ISS-001'));

    await tester.pumpWidget(buildSubject(viewModel: vm));
    await tester.pumpAndSettle();

    await tester.tap(find.text('حل المشكلة'));
    await tester.pumpAndSettle();

    expect(find.byType(DispatcherResolveIssueDialog), findsOneWidget);

    await tester.tap(find.text('تأكيد الحل'));
    await tester.pumpAndSettle();

    expect(find.text('ملاحظات الحل يجب أن تكون 3 أحرف على الأقل'), findsOneWidget);
    expect(repository.resolveCallCount, 0);

    repository.nextResolveResult = ApiErrorResult(
      failure: Failure(errorMessage: 'تعذر حل المشكلة حالياً'),
    );

    await tester.enterText(find.byType(TextField), 'تم حل المشكلة وتفقد الطلب');
    await tester.pump();
    await tester.tap(find.text('تأكيد الحل'));
    await tester.pumpAndSettle();

    expect(repository.resolveCallCount, 1);
    expect(find.byType(InlineApiErrorWidget), findsOneWidget);
    expect(find.text('تعذر حل المشكلة حالياً'), findsOneWidget);
    expect(find.byType(DispatcherResolveIssueDialog), findsOneWidget);
  });

  testWidgets('successful resolution closes dialog, renders DispatcherIssueResolutionCard, and hides actions', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final vm = createViewModel();
    repository.nextDetailsResult = ApiSuccessResult(data: _sampleDetail(issueId: 'ISS-001'));

    await tester.pumpWidget(buildSubject(viewModel: vm));
    await tester.pumpAndSettle();

    await tester.tap(find.text('حل المشكلة'));
    await tester.pumpAndSettle();

    repository.nextResolveResult = const ApiSuccessResult(
      data: ResolveIssueResultEntity(
        issueId: 'ISS-001',
        status: DispatcherIssueStatus.resolved,
        resolution: DispatcherIssueResolutionEntity(
          resolutionNotes: 'تم تسليم البوكسات التالفة للمطعم بنجاح',
          resolvedBy: 'فهد المطيري',
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'تم تسليم البوكسات التالفة للمطعم بنجاح');
    await tester.pump();
    await tester.tap(find.text('تأكيد الحل'));
    await tester.pumpAndSettle();

    expect(find.byType(DispatcherResolveIssueDialog), findsNothing);
    expect(find.byType(DispatcherIssueDetailsActionButtons), findsNothing);
    expect(find.byType(DispatcherIssueResolutionCard), findsOneWidget);
    expect(find.text('تم تسليم البوكسات التالفة للمطعم بنجاح'), findsOneWidget);
  });

  testWidgets('navigating to 04.13 and returning result updates driver and status without refetching', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final vm = createViewModel();
    repository.nextDetailsResult = ApiSuccessResult(data: _sampleDetail(issueId: 'ISS-001'));

    await tester.pumpWidget(buildSubject(viewModel: vm));
    await tester.pumpAndSettle();

    expect(find.text('علي المنصور'), findsOneWidget);
    expect(repository.detailsCallCount, 1);

    await tester.tap(find.text('تعيين سائق بديل'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('simulate_reassign_pop')));
    await tester.pumpAndSettle();

    expect(repository.detailsCallCount, 1);
    expect(find.text('سائق جديد بديل'), findsOneWidget);
    expect(find.text('DRV-NEW'), findsOneWidget);
  });
}
