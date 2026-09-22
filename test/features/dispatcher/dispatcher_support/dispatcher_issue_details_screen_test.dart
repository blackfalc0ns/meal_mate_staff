import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_attachment_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_detail_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_trip_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/repo/dispatcher_support_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/usecase/get_dispatcher_issue_details_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/usecase/resolve_dispatcher_issue_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/screens/dispatcher_issue_details_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_issue_details_action_buttons.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_issue_details_attachments_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_issue_details_description_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_issue_details_driver_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_issue_details_header_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_issue_details_trip_card.dart';

const DispatcherIssueDetailEntity _sampleIssueDetail =
    DispatcherIssueDetailEntity(
  issueId: 'ISSUE-1258',
  title: 'تعطل الدراجة أثناء التوصيل',
  category: 'VEHICLE_BREAKDOWN',
  categoryLabel: 'عطل في الدراجة',
  reportedTimeText: 'منذ 12 دقيقة',
  boxCode: '#BX-1258',
  area: 'السالمية',
  affectedBoxesCount: 3,
  affectedBoxesText: '3 صناديق',
  priority: 'عالية',
  priorityText: 'عالية',
  driver: DispatcherIssueDriverEntity(
    id: 'DR-2011',
    name: 'أحمد السيد',
    code: 'DR-2011',
    avatarUrl: AppAssets.registrationDriverRole,
    isOnline: true,
    subStatus: 'على المهمة',
  ),
  description:
      'أبلغ السائق عن عطل مفاجئ في الدراجة اثناء طريقة في تسليم الطلب، ولم يمكنه استكمال المهمة الحالية حتي وصول دعم أو سائق آخر',
  evidencePhotos: [
    DispatcherIssueAttachmentEntity(
      id: 'att-1',
      url: AppAssets.dispatcherIssueAttachment1,
      imageAsset: AppAssets.dispatcherIssueAttachment1,
      orderNumber: 1,
    ),
    DispatcherIssueAttachmentEntity(
      id: 'att-2',
      url: AppAssets.dispatcherIssueAttachment2,
      imageAsset: AppAssets.dispatcherIssueAttachment2,
      orderNumber: 2,
    ),
  ],
  tripInfo: DispatcherIssueTripEntity(
    clientName: 'محمد الشمري',
    mealsCount: 3,
    expectedDeliveryTime: '12:15 م',
    pickupLocation: 'مطعم MealMate - السالمية',
    dropoffLocation: 'شارع الخليج العربي ، قطعة 5 ، منزل 12',
  ),
);

class _FakeDetailsRepository implements DispatcherSupportRepository {
  @override
  Future<ApiResult<DispatcherIssueDetailEntity>> getIssueDetails(
    String issueId,
  ) async {
    return const ApiSuccessResult(data: _sampleIssueDetail);
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
    if (getIt.isRegistered<GetDispatcherIssueDetailsUseCase>()) {
      await getIt.unregister<GetDispatcherIssueDetailsUseCase>();
    }
    if (getIt.isRegistered<ResolveDispatcherIssueUseCase>()) {
      await getIt.unregister<ResolveDispatcherIssueUseCase>();
    }
    final repo = _FakeDetailsRepository();
    getIt.registerLazySingleton<DispatcherSupportRepository>(() => repo);
    getIt.registerFactory<GetDispatcherIssueDetailsUseCase>(
      () => GetDispatcherIssueDetailsUseCase(repo),
    );
    getIt.registerFactory<ResolveDispatcherIssueUseCase>(
      () => ResolveDispatcherIssueUseCase(repo),
    );
  });

  group('DispatcherIssueDetailsScreen Tests', () {
    testWidgets('renders all major components and cards in RTL', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 907 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(child: const DispatcherIssueDetailsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherIssueDetailsScreen), findsOneWidget);
      expect(find.byType(DispatcherIssueDetailsHeaderCard), findsOneWidget);
      expect(find.byType(DispatcherIssueDetailsDriverCard), findsOneWidget);
      expect(
        find.byType(DispatcherIssueDetailsDescriptionCard),
        findsOneWidget,
      );
      expect(
        find.byType(DispatcherIssueDetailsAttachmentsCard),
        findsOneWidget,
      );
      expect(find.byType(DispatcherIssueDetailsTripCard), findsOneWidget);
      expect(find.byType(DispatcherIssueDetailsActionButtons), findsOneWidget);

      // Verify header details
      expect(find.text(_sampleIssueDetail.title), findsOneWidget);
      expect(find.text(_sampleIssueDetail.taskNumber), findsOneWidget);
      expect(find.text(_sampleIssueDetail.area), findsOneWidget);

      // Verify driver info
      expect(find.text(_sampleIssueDetail.driverName), findsOneWidget);
      expect(find.text(_sampleIssueDetail.driverCode), findsOneWidget);

      // Verify trip info
      expect(find.text(_sampleIssueDetail.clientName), findsOneWidget);
      expect(find.text(_sampleIssueDetail.pickupLocation), findsOneWidget);
    });

    testWidgets('renders properly in LTR English without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 907 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(
          locale: const Locale('en'),
          child: const DispatcherIssueDetailsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherIssueDetailsScreen), findsOneWidget);
      expect(find.text('Problem Details'), findsOneWidget);
      expect(find.text('Driver Info'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
    });

    testWidgets('quick action buttons are tappable', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 907 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool assignTapped = false;
      bool contactTapped = false;

      await tester.pumpWidget(
        _buildTestableWidget(
          child: Scaffold(
            body: DispatcherIssueDetailsActionButtons(
              onAssignReplacementTap: () => assignTapped = true,
              onContactDriverTap: () => contactTapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pump();
      expect(assignTapped, isTrue);

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();
      expect(contactTapped, isTrue);
    });
  });
}
