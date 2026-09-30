import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/core/widget/custom_progress_indecator.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/domain/entities/driver_notification_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/domain/entities/driver_notification_filter_type.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/domain/entities/driver_notification_type.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/domain/repo/driver_notifications_repository.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/domain/usecase/get_driver_notifications_usecase.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/domain/usecase/mark_driver_notification_as_read_usecase.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/presentation/manager/driver_notifications_event.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/presentation/manager/driver_notifications_state.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/presentation/manager/driver_notifications_view_model.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/presentation/screens/driver_notifications_screen.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/presentation/widgets/driver_notification_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/presentation/widgets/driver_notifications_shimmer.dart';

class _FakeDriverNotificationsRepository
    implements DriverNotificationsRepository {
  ApiResult<List<DriverNotificationEntity>>? getNotificationsResult;
  ApiResult<void>? markAsReadResult;

  @override
  Future<ApiResult<List<DriverNotificationEntity>>> getNotifications() async {
    return getNotificationsResult ?? const ApiSuccessResult(data: []);
  }

  @override
  Future<ApiResult<void>> markAsRead(String notificationId) async {
    return markAsReadResult ?? const ApiSuccessResult(data: null);
  }
}

class FakeDriverNotificationsViewModel extends DriverNotificationsViewModel {
  FakeDriverNotificationsViewModel(DriverNotificationsState initialState)
      : super(
          getNotificationsUseCase: GetDriverNotificationsUseCase(
            _FakeDriverNotificationsRepository(),
          ),
          markAsReadUseCase: MarkDriverNotificationAsReadUseCase(
            _FakeDriverNotificationsRepository(),
          ),
        ) {
    emit(initialState);
  }

  @override
  void doIntent(DriverNotificationsEvent event) {
    // No-op in fake to preserve explicit test state
  }
}

void main() {
  Widget buildSubject(DriverNotificationsViewModel viewModel) {
    return MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      home: DriverNotificationsScreen(viewModel: viewModel),
    );
  }

  testWidgets('displays DriverNotificationsShimmer when initial loading', (
    tester,
  ) async {
    final fakeViewModel = FakeDriverNotificationsViewModel(
      const DriverNotificationsState(
        status: DriverNotificationsStateStatus.loading,
      ),
    );

    await tester.pumpWidget(buildSubject(fakeViewModel));
    await tester.pump();

    expect(find.byType(DriverNotificationsShimmer), findsOneWidget);
  });

  testWidgets('displays ApiErrorWidget when load fails and list is empty', (
    tester,
  ) async {
    final fakeViewModel = FakeDriverNotificationsViewModel(
      DriverNotificationsState(
        status: DriverNotificationsStateStatus.error,
        failure: Failure(errorMessage: 'Connection lost'),
      ),
    );

    await tester.pumpWidget(buildSubject(fakeViewModel));
    await tester.pump();

    expect(find.byType(ApiErrorWidget), findsOneWidget);
  });

  testWidgets(
    'displays notifications and centered CustomProgressIndicator during action loading',
    (tester) async {
      final fakeViewModel = FakeDriverNotificationsViewModel(
        const DriverNotificationsState(
          status: DriverNotificationsStateStatus.actionLoading,
          notifications: [
            DriverNotificationEntity(
              id: 'n1',
              type: DriverNotificationType.newOrder,
              title: 'طلب جديد',
              body: 'لديك طلب استلام جديد',
              time: 'الان',
              isRead: false,
              isToday: true,
              filterCategory: DriverNotificationFilterType.deliveryOrders,
            ),
          ],
        ),
      );

      await tester.pumpWidget(buildSubject(fakeViewModel));
      await tester.pump();

      expect(find.byType(DriverNotificationCard), findsOneWidget);
      final barrierFinder = find.descendant(
        of: find.byType(Stack),
        matching: find.byType(ModalBarrier),
      );
      expect(barrierFinder, findsOneWidget);
      expect(find.byType(CustomProgressIndicator), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is Center && w.child is CustomProgressIndicator,
        ),
        findsOneWidget,
      );
    },
  );
}
