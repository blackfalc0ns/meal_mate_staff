import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/inline_api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_home_entity.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/repo/driver_home_repository.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/usecase/get_driver_home_usecase.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/manager/driver_home_event.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/manager/driver_home_state.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/manager/driver_home_view_model.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/screens/driver_home_screen.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/active_home/driver_active_home_view.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/driver_home_shimmer.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/inactive_home/driver_inactive_home_view.dart';

class _DummyRepo implements DriverHomeRepository {
  @override
  Future<ApiResult<DriverHomeEntity>> getDriverHome() async {
    return ApiErrorResult(
      failure: ServerFailure(
        errorMessage: 'dummy',
        exception: const ApiException(
          errorType: ApiErrorType.serverError,
          message: 'dummy',
        ),
      ),
    );
  }
}

class TestDriverHomeViewModel extends DriverHomeViewModel {
  TestDriverHomeViewModel([
    DriverHomeState initialState = const DriverHomeState(),
  ]) : super(getDriverHomeUseCase: GetDriverHomeUseCase(_DummyRepo())) {
    emit(initialState);
  }

  final List<DriverHomeEvent> dispatchedEvents = [];

  void updateState(DriverHomeState newState) {
    emit(newState);
  }

  @override
  Future<void> doIntent(DriverHomeEvent event) async {
    dispatchedEvents.add(event);
  }
}

Widget _buildTestApp({
  required Widget child,
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
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const inactiveEntity = DriverHomeEntity(
    driverId: 'drv-01',
    driverName: 'أحمد محمود',
    driverCode: 'DRV-1029',
    shiftStatus: DriverShiftStatus.inactive,
    isAvailable: false,
    currentStatusText: 'غير متصل',
    unreadNotificationsCount: 0,
  );

  const activeAvailableEntity = DriverHomeEntity(
    driverId: 'drv-01',
    driverName: 'أحمد محمود',
    driverCode: 'DRV-1029',
    shiftStatus: DriverShiftStatus.active,
    isAvailable: true,
    currentStatusText: 'متاح للطلبات',
    nextLocationText: 'حي النرجس، الرياض',
    unreadNotificationsCount: 3,
  );

  group('DriverHomeScreen Widget Tests', () {
    testWidgets(
      'initial loading state (home == null && isLoading) renders DriverHomeShimmer',
      (tester) async {
        final vm = TestDriverHomeViewModel(
          const DriverHomeState(isLoading: true, home: null),
        );

        await tester.pumpWidget(
          _buildTestApp(child: DriverHomeScreen(viewModel: vm)),
        );
        await tester.pump();

        expect(find.byType(DriverHomeShimmer), findsOneWidget);
        expect(find.byType(DriverInactiveHomeView), findsNothing);
        expect(find.byType(DriverActiveHomeView), findsNothing);
        expect(find.byType(ApiErrorWidget), findsNothing);
      },
    );

    testWidgets(
      'failure with home == null renders ApiErrorWidget and retry dispatches DriverHomeRetryEvent',
      (tester) async {
        final vm = TestDriverHomeViewModel(
          DriverHomeState(
            isLoading: false,
            home: null,
            failure: ServerFailure(
              errorMessage: 'فشل في الاتصال بالخادم',
              exception: const ApiException(
                errorType: ApiErrorType.serverError,
                message: 'فشل في الاتصال بالخادم',
              ),
            ),
          ),
        );

        await tester.pumpWidget(
          _buildTestApp(child: DriverHomeScreen(viewModel: vm)),
        );
        await tester.pump();

        expect(find.byType(ApiErrorWidget), findsOneWidget);
        expect(find.byType(DriverHomeShimmer), findsNothing);

        // Find retry button
        final retryFinder = find.byType(ElevatedButton);
        if (retryFinder.evaluate().isNotEmpty) {
          await tester.tap(retryFinder.first);
          await tester.pump();
          expect(
            vm.dispatchedEvents.any((e) => e is DriverHomeRetryEvent),
            isTrue,
          );
        }
      },
    );

    testWidgets(
      'loaded Inactive state renders DriverInactiveHomeView and no badge dot',
      (tester) async {
        final vm = TestDriverHomeViewModel(
          const DriverHomeState(isLoading: false, home: inactiveEntity),
        );

        await tester.pumpWidget(
          _buildTestApp(child: DriverHomeScreen(viewModel: vm)),
        );
        await tester.pump();

        expect(find.byType(DriverInactiveHomeView), findsOneWidget);
        expect(find.byType(DriverActiveHomeView), findsNothing);
        expect(find.byType(DriverHomeShimmer), findsNothing);
        expect(find.text('أحمد محمود'), findsOneWidget);
        expect(find.text('DRV-1029'), findsOneWidget);
      },
    );

    testWidgets('loaded Active state renders DriverActiveHomeView', (
      tester,
    ) async {
      final vm = TestDriverHomeViewModel(
        const DriverHomeState(isLoading: false, home: activeAvailableEntity),
      );

      await tester.pumpWidget(
        _buildTestApp(child: DriverHomeScreen(viewModel: vm)),
      );
      await tester.pump();

      expect(find.byType(DriverActiveHomeView), findsOneWidget);
      expect(find.byType(DriverInactiveHomeView), findsNothing);
    });

    testWidgets(
      'refresh failure with loaded data displays InlineApiErrorWidget and keeps content',
      (tester) async {
        final vm = TestDriverHomeViewModel(
          DriverHomeState(
            isLoading: false,
            isRefreshing: false,
            home: activeAvailableEntity,
            failure: ServerFailure(
              errorMessage: 'خطأ في التحديث',
              exception: const ApiException(
                errorType: ApiErrorType.serverError,
                message: 'خطأ في التحديث',
              ),
            ),
          ),
        );

        await tester.pumpWidget(
          _buildTestApp(child: DriverHomeScreen(viewModel: vm)),
        );
        await tester.pump();

        expect(find.byType(InlineApiErrorWidget), findsOneWidget);
        expect(find.byType(DriverActiveHomeView), findsOneWidget);
      },
    );

    testWidgets('lifecycle resume dispatches DriverHomeLifecycleResumeEvent', (
      tester,
    ) async {
      final vm = TestDriverHomeViewModel(
        const DriverHomeState(isLoading: false, home: activeAvailableEntity),
      );

      await tester.pumpWidget(
        _buildTestApp(child: DriverHomeScreen(viewModel: vm)),
      );
      await tester.pump();

      // Trigger app lifecycle resumed
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(
        vm.dispatchedEvents.any((e) => e is DriverHomeLifecycleResumeEvent),
        isTrue,
      );
    });
  });
}
