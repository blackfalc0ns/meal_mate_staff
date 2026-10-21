import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_notifications/domain/entities/dispatcher_notification_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_notifications/domain/repo/dispatcher_notifications_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_notifications/domain/usecase/get_dispatcher_notifications_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_notifications/domain/usecase/mark_dispatcher_notification_read_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_notifications/presentation/manager/dispatcher_notifications_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_notifications/presentation/screens/dispatcher_notifications_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_notifications/presentation/widgets/dispatcher_notification_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget({
    required Widget child,
    Locale locale = const Locale('ar'),
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const Scaffold(body: Text('Route Destination')),
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6744C2)),
      ),
      home: child,
    );
  }

  group('DispatcherNotificationsScreen', () {
    testWidgets('renders empty state when no notifications are returned', (
      tester,
    ) async {
      final repo = _FakeScreenRepository(items: []);
      final viewModel = DispatcherNotificationsViewModel(
        getNotificationsUseCase: GetDispatcherNotificationsUseCase(repo),
        markReadUseCase: MarkDispatcherNotificationReadUseCase(repo),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          child: DispatcherNotificationsScreen(viewModel: viewModel),
        ),
      );

      // Settle loading
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherNotificationCard), findsNothing);
      expect(find.text('لا توجد إشعارات حالياً'), findsOneWidget);

      await viewModel.close();
    });

    testWidgets('renders list of notification cards with Arabic translations', (
      tester,
    ) async {
      final repo = _FakeScreenRepository();
      final viewModel = DispatcherNotificationsViewModel(
        getNotificationsUseCase: GetDispatcherNotificationsUseCase(repo),
        markReadUseCase: MarkDispatcherNotificationReadUseCase(repo),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          child: DispatcherNotificationsScreen(viewModel: viewModel),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(DispatcherNotificationCard), findsNWidgets(2));
      expect(find.text('بلاغ دعم سائق'), findsOneWidget);
      expect(find.text('نقل عهدة سائق'), findsOneWidget);

      await viewModel.close();
    });

    testWidgets('switches between all and unread tabs correctly', (
      tester,
    ) async {
      final repo = _FakeScreenRepository();
      final viewModel = DispatcherNotificationsViewModel(
        getNotificationsUseCase: GetDispatcherNotificationsUseCase(repo),
        markReadUseCase: MarkDispatcherNotificationReadUseCase(repo),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          child: DispatcherNotificationsScreen(viewModel: viewModel),
        ),
      );

      await tester.pumpAndSettle();

      // Find tabs
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('غير مقروءة'), findsOneWidget);

      // Tap on 'غير مقروءة'
      await tester.tap(find.text('غير مقروءة'));
      await tester.pumpAndSettle();

      // Only unread card should appear (item 1 is unread, item 2 is read)
      expect(find.byType(DispatcherNotificationCard), findsNWidgets(1));
      expect(find.text('بلاغ دعم سائق'), findsOneWidget);
      expect(find.text('نقل عهدة سائق'), findsNothing);

      await viewModel.close();
    });

    testWidgets('tap on card invokes callback and marks as read', (
      tester,
    ) async {
      final repo = _FakeScreenRepository();
      final viewModel = DispatcherNotificationsViewModel(
        getNotificationsUseCase: GetDispatcherNotificationsUseCase(repo),
        markReadUseCase: MarkDispatcherNotificationReadUseCase(repo),
      );

      DispatcherNotificationEntity? tappedItem;

      await tester.pumpWidget(
        buildTestableWidget(
          child: DispatcherNotificationsScreen(
            viewModel: viewModel,
            onNotificationTap: (item) {
              tappedItem = item;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on first card
      await tester.tap(find.text('بلاغ دعم سائق'));
      await tester.pumpAndSettle();

      expect(tappedItem, isNotNull);
      expect(tappedItem!.id, 'n-1');
      expect(repo.markedIds, contains('n-1'));

      await viewModel.close();
    });
  });
}

class _FakeScreenRepository implements DispatcherNotificationsRepository {
  _FakeScreenRepository({List<DispatcherNotificationEntity>? items})
      : items = items ?? [
          const DispatcherNotificationEntity(
            id: 'n-1',
            type: DispatcherNotificationType.driverSupportIssue,
            title: 'بلاغ دعم سائق',
            description: 'السائق يحتاج مساعدة في التوصيل',
            timeAgo: 'منذ 3 دقيقة',
            iconAsset: AppAssets.notificationIconBoxDismiss,
            isUnread: true,
            subjectId: 'issue-1',
            deepLink: '/dispatcher/support/issues/issue-1',
          ),
          const DispatcherNotificationEntity(
            id: 'n-2',
            type: DispatcherNotificationType.driverSupportHandover,
            title: 'نقل عهدة سائق',
            description: 'تفاصيل العهدة',
            timeAgo: 'منذ ساعة',
            iconAsset: AppAssets.notificationIconBox,
            isUnread: false,
            subjectId: 'handover-1',
          ),
        ];

  final List<DispatcherNotificationEntity> items;
  final List<String> markedIds = [];

  @override
  Future<ApiResult<List<DispatcherNotificationEntity>>> getNotifications() async {
    return ApiSuccessResult(data: items);
  }

  @override
  Future<ApiResult<void>> markAsRead(String notificationId) async {
    markedIds.add(notificationId);
    return const ApiSuccessResult(data: null);
  }
}
