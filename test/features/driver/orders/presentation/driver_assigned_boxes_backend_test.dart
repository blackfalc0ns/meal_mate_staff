import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/empty_state_widget.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/inline_api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_assigned_box_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_box_delivery_status.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_boxes_filter_type.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_pickup_manifest_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/repo/driver_pickup_manifest_repository.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/usecase/get_driver_pickup_manifest_usecase.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/manager/driver_pickup_manifest_state.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/manager/driver_pickup_manifest_view_model.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/screens/driver_assigned_boxes_screen.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_assigned_box_card.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_assigned_boxes_shimmer.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_no_assigned_boxes_view.dart';

class _MockRepo implements DriverPickupManifestRepository {
  Future<ApiResult<DriverPickupManifestEntity>> Function(
    DriverBoxesFilterType filter,
  )?
  onGetManifest;

  @override
  Future<ApiResult<DriverPickupManifestEntity>> getDriverPickupManifest({
    required DriverBoxesFilterType filter,
  }) {
    return onGetManifest!(filter);
  }
}

void main() {
  late _MockRepo mockRepo;
  late GetDriverPickupManifestUseCase useCase;
  late DriverPickupManifestViewModel viewModel;

  const sampleBox = DriverAssignedBoxEntity(
    boxId: 'uuid-box-101',
    boxCode: '#BOX-101',
    customerName: 'Customer A',
    deliveryZone: 'حي النرجس',
    mealsCount: 4,
    mealsSummary: '4x Chicken Rice',
    deliveryTimeSlot: '12:00 PM - 02:00 PM',
    status: DriverBoxDeliveryStatus.pendingScan,
    statusText: 'لم يتم التحميل',
    isPickedUp: false,
  );

  const sampleManifest = DriverPickupManifestEntity(
    tripId: 'trip-1',
    tripCode: 'TRIP-1',
    driverId: 'drv-1',
    driverName: 'Driver Name',
    totalBoxesCount: 8,
    totalMealsCount: 32,
    pendingScanBoxesCount: 7,
    pickedUpBoxesCount: 1,
    allBoxesPickedUp: false,
    canStartTrip: false,
    boxes: [sampleBox],
  );

  const emptyManifest = DriverPickupManifestEntity(
    tripId: 'trip-1',
    tripCode: 'TRIP-1',
    driverId: 'drv-1',
    driverName: 'Driver Name',
    totalBoxesCount: 0,
    totalMealsCount: 0,
    pendingScanBoxesCount: 0,
    pickedUpBoxesCount: 0,
    allBoxesPickedUp: false,
    canStartTrip: false,
    boxes: [],
  );

  setUp(() {
    mockRepo = _MockRepo();
    mockRepo.onGetManifest = (_) async =>
        const ApiSuccessResult(data: sampleManifest);
    useCase = GetDriverPickupManifestUseCase(mockRepo);
    viewModel = DriverPickupManifestViewModel(getManifestUseCase: useCase);
  });

  tearDown(() {
    viewModel.close();
  });

  Widget buildSubject({DriverPickupManifestViewModel? vm}) {
    return MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      home: DriverAssignedBoxesScreen(viewModel: vm ?? viewModel),
    );
  }

  group('DriverAssignedBoxesScreen backend state decision table', () {
    testWidgets(
      'initial loading + no data renders DriverAssignedBoxesShimmer',
      (tester) async {
        mockRepo.onGetManifest = (_) =>
            Future.value(const ApiSuccessResult(data: sampleManifest));

        // Force initial loading state without completing
        viewModel.emit(
          const DriverPickupManifestState(
            isInitialLoading: true,
            manifest: null,
          ),
        );

        await tester.pumpWidget(buildSubject());
        expect(find.byType(DriverAssignedBoxesShimmer), findsOneWidget);
      },
    );

    testWidgets('failure + no data renders ApiErrorWidget with retry intent', (
      tester,
    ) async {
      mockRepo.onGetManifest = (_) async =>
          const ApiSuccessResult(data: sampleManifest);

      viewModel.emit(
        DriverPickupManifestState(
          isInitialLoading: false,
          manifest: null,
          failure: ServerFailure(
            errorMessage: 'Server down',
            exception: const ApiException(
              errorType: ApiErrorType.serverError,
              message: 'Server down',
            ),
          ),
        ),
      );

      await tester.pumpWidget(buildSubject());
      expect(find.byType(ApiErrorWidget), findsOneWidget);

      // Tap retry button in error widget
      final retryBtn = find.text('إعادة المحاولة');
      if (retryBtn.evaluate().isNotEmpty) {
        await tester.tap(retryBtn.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('success + empty boxes renders DriverNoAssignedBoxesView', (
      tester,
    ) async {
      viewModel.emit(
        const DriverPickupManifestState(
          isInitialLoading: false,
          manifest: emptyManifest,
        ),
      );

      await tester.pumpWidget(buildSubject());
      expect(find.byType(DriverNoAssignedBoxesView), findsOneWidget);
    });

    testWidgets('filter loading renders cards shimmer, not full page shimmer', (
      tester,
    ) async {
      viewModel.emit(
        const DriverPickupManifestState(
          isInitialLoading: false,
          isFilterLoading: true,
          manifest: sampleManifest,
        ),
      );

      await tester.pumpWidget(buildSubject());
      expect(find.byType(DriverAssignedBoxesCardsShimmer), findsOneWidget);
      expect(find.byType(DriverAssignedBoxesShimmer), findsNothing);
    });

    testWidgets(
      'refresh failure + existing data retains cards and shows InlineApiErrorWidget',
      (tester) async {
        viewModel.emit(
          DriverPickupManifestState(
            isInitialLoading: false,
            manifest: sampleManifest,
            failure: ServerFailure(
              errorMessage: 'Refresh error',
              exception: const ApiException(
                errorType: ApiErrorType.serverError,
                message: 'Refresh error',
              ),
            ),
          ),
        );

        await tester.pumpWidget(buildSubject());
        expect(find.byType(InlineApiErrorWidget), findsOneWidget);
        expect(find.byType(DriverAssignedBoxCard), findsOneWidget);
        expect(find.text('#BOX-101'), findsOneWidget);
      },
    );

    testWidgets('content renders backend counters and boxes', (tester) async {
      viewModel.emit(
        const DriverPickupManifestState(
          isInitialLoading: false,
          manifest: sampleManifest,
        ),
      );

      await tester.pumpWidget(buildSubject());
      expect(find.byType(DriverAssignedBoxCard), findsOneWidget);
      expect(find.text('#BOX-101'), findsOneWidget);
      expect(find.text('32'), findsOneWidget); // total meals
      expect(find.text('8'), findsOneWidget); // total boxes
    });
  });
}
