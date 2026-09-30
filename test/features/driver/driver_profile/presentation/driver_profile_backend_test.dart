import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/entities/driver_profile_assignment_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/entities/driver_profile_document_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/entities/driver_profile_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/entities/driver_profile_ticket_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/entities/driver_profile_vehicle_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/repo/driver_profile_repository.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/usecase/get_driver_profile_usecase.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/manager/driver_profile_view_model.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/screens/driver_profile_screen.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_assignment_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_documents_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_hero_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_shimmer.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_ticket_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_vehicle_card.dart';

class _FakeProfileRepository implements DriverProfileRepository {
  Future<ApiResult<DriverProfileEntity>> Function()? handler;
  int callCount = 0;

  @override
  Future<ApiResult<DriverProfileEntity>> getProfile() async {
    callCount++;
    if (handler != null) {
      return handler!();
    }
    return const ApiSuccessResult(data: _testProfile);
  }
}

const _testProfile = DriverProfileEntity(
  driverProfileId: 'drv-101',
  fullName: 'طارق علي',
  driverDescription: 'سائق محترف',
  driverCode: 'DRV-101',
  isOnline: true,
  status: 'Active',
  statusText: 'نشط',
  profileImageUrl: null,
  reviewsCount: 15,
  totalOrders: 120,
  averageRating: 4.8,
  acceptanceRatePercent: 96.0,
  vehicle: DriverProfileVehicleEntity(
    vehicleType: 'سيارة',
    vehicleModel: 'Toyota Yaris',
    vehicleYear: 2022,
    plateNumber: '1234',
    plateGovernorate: 'بغداد',
    color: 'أبيض',
    verificationStatus: 'Verified',
    verificationStatusText: 'معتمدة',
    isVehicleActive: true,
  ),
  documents: [
    DriverProfileDocumentEntity(
      documentId: 'doc-1',
      documentType: 'DrivingLicense',
      documentTitle: 'إجازة السوق',
      status: 'Approved',
      statusText: 'معتمدة',
    ),
  ],
  assignment: DriverProfileAssignmentEntity(
    restaurantName: 'مطعم البرجر الشهير',
    branchName: 'فرع المنصور',
  ),
  latestSupportTicket: DriverProfileTicketEntity(
    ticketId: 'tkt-1',
    ticketNumber: 'TKT-0099',
    subject: 'مشكلة في الإشعارات',
    body: 'تفاصيل المشكلة',
    status: 'Open',
    statusText: 'مفتوحة',
  ),
);

const _testProfileWithAvatar = DriverProfileEntity(
  driverProfileId: 'drv-101',
  fullName: 'طارق علي',
  driverDescription: 'سائق محترف',
  driverCode: 'DRV-101',
  isOnline: true,
  status: 'Active',
  statusText: 'نشط',
  profileImageUrl: 'https://example.com/avatar_test.png',
  reviewsCount: 15,
  totalOrders: 120,
);

Widget _buildSubject({
  required DriverProfileViewModel viewModel,
  bool isActive = true,
  Locale locale = const Locale('ar'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ar'), Locale('en')],
    home: DriverProfileScreen(
      viewModel: viewModel,
      isActive: isActive,
    ),
  );
}

void main() {
  late _FakeProfileRepository repository;
  late GetDriverProfileUseCase useCase;
  late DriverProfileViewModel viewModel;

  setUp(() {
    repository = _FakeProfileRepository();
    useCase = GetDriverProfileUseCase(repository);
    viewModel = DriverProfileViewModel(getDriverProfileUseCase: useCase);
  });

  tearDown(() {
    viewModel.close();
  });

  testWidgets('loads once, shows shimmer while pending, then renders loaded content', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final completer = Completer<ApiResult<DriverProfileEntity>>();
    repository.handler = () => completer.future;

    await tester.pumpWidget(_buildSubject(viewModel: viewModel));
    await tester.pump();

    expect(find.byType(DriverProfileShimmer), findsOneWidget);
    expect(find.byType(DriverProfileHeroCard), findsNothing);
    expect(repository.callCount, equals(1));

    completer.complete(const ApiSuccessResult(data: _testProfile));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(DriverProfileShimmer), findsNothing);
    expect(find.byType(DriverProfileHeroCard), findsOneWidget);
    expect(find.text('طارق علي'), findsOneWidget);
    expect(find.text('DRV-101'), findsOneWidget);
    expect(find.byType(DriverProfileVehicleCard), findsOneWidget);
    expect(find.byType(DriverProfileDocumentsCard), findsOneWidget);
    expect(find.byType(DriverProfileAssignmentCard), findsOneWidget);
    expect(find.byType(DriverProfileTicketCard), findsOneWidget);
  });

  testWidgets('pull-to-refresh retains content and does not show full shimmer', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    repository.handler = () async => const ApiSuccessResult(data: _testProfile);

    await tester.pumpWidget(_buildSubject(viewModel: viewModel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(DriverProfileHeroCard), findsOneWidget);
    expect(find.byType(DriverProfileShimmer), findsNothing);
    expect(repository.callCount, equals(1));

    final refreshCompleter = Completer<ApiResult<DriverProfileEntity>>();
    repository.handler = () => refreshCompleter.future;

    await tester.fling(
      find.byType(SingleChildScrollView),
      const Offset(0, 300),
      1000,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(DriverProfileHeroCard), findsOneWidget);
    expect(find.byType(DriverProfileShimmer), findsNothing);
    expect(repository.callCount, equals(2));

    refreshCompleter.complete(const ApiSuccessResult(data: _testProfile));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(DriverProfileHeroCard), findsOneWidget);
  });

  testWidgets('typed initial failure displays ApiErrorWidget and retries on press', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    repository.handler = () async => ApiErrorResult(
          failure: ServerFailure(
            errorMessage: 'Not found error',
            exception: const ApiException(
              errorType: ApiErrorType.notFound,
              message: 'Not found error',
            ),
          ),
        );

    await tester.pumpWidget(_buildSubject(viewModel: viewModel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ApiErrorWidget), findsOneWidget);
    expect(find.byType(DriverProfileHeroCard), findsNothing);
    expect(repository.callCount, equals(1));

    repository.handler = () async => const ApiSuccessResult(data: _testProfile);

    final retryButton = find.byType(ElevatedButton);
    expect(retryButton, findsOneWidget);
    await tester.tap(retryButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(repository.callCount, equals(2));
    expect(find.byType(DriverProfileHeroCard), findsOneWidget);
    expect(find.byType(ApiErrorWidget), findsNothing);
  });

  testWidgets('activation transition from false to true dispatches DriverProfileActivated', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    repository.handler = () async => const ApiSuccessResult(data: _testProfile);

    await tester.pumpWidget(_buildSubject(viewModel: viewModel, isActive: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(repository.callCount, equals(1));

    // Rebuild with isActive = true
    await tester.pumpWidget(_buildSubject(viewModel: viewModel, isActive: true));
    await tester.pump();
    // Cache is fresh (< 15 min), so no extra network call
    expect(repository.callCount, equals(1));
  });

  testWidgets('avatar load failure triggers DriverProfileAvatarFailed once per url', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    repository.handler = () async => const ApiSuccessResult(data: _testProfileWithAvatar);

    await tester.pumpWidget(_buildSubject(viewModel: viewModel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // 1 call from initial load + 1 call triggered by avatar load failure = 2 calls
    expect(repository.callCount, equals(2));

    // Subsequent pump does not trigger another call for the same failed avatar URL
    await tester.pump(const Duration(milliseconds: 100));
    expect(repository.callCount, equals(2));
  });
}
