import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/widget/custom_app_bar.dart';
import 'package:meal_mate_delivery/features/driver/home/data/datasources/driver_home_fake_datasource.dart';
import 'package:meal_mate_delivery/features/driver/home/data/repositories/driver_home_repository_impl.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/usecases/get_driver_active_home_usecase.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/manager/driver_active_home_view_model.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/screens/driver_active_home_screen.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/active_home/driver_active_status_location_row.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/active_home/driver_current_order_card.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/active_home/driver_daily_goal_card.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/active_home/driver_daily_performance_section.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/active_home/driver_daily_summary_section.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/active_home/driver_home_map_card.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/active_home/driver_issues_help_banner.dart';

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

  group('DriverActiveHomeScreen Widget Tests', () {
    late DriverHomeFakeDataSource fakeDataSource;
    late DriverHomeRepositoryImpl repository;
    late DriverActiveHomeViewModel viewModel;

    setUp(() {
      fakeDataSource = DriverHomeFakeDataSource();
      repository = DriverHomeRepositoryImpl(fakeDataSource);
      viewModel = DriverActiveHomeViewModel(
        getDriverActiveHomeUseCase: GetDriverActiveHomeUseCase(repository),
      );
    });

    testWidgets('renders all 05.02 active home components accurately', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      bool orderDetailsTapped = false;
      bool issuesTapped = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: DriverActiveHomeScreen(
            viewModel: viewModel,
            onOrderDetailsTap: () {
              orderDetailsTapped = true;
            },
            onIssuesTap: () {
              issuesTapped = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomAppBar), findsOneWidget);
      expect(find.byType(DriverActiveStatusLocationRow), findsOneWidget);
      expect(find.text('توصيل الطلب'), findsOneWidget);
      expect(find.byType(DriverDailyGoalCard), findsOneWidget);
      expect(find.text('مؤشر الإنجاز اليومي'), findsOneWidget);
      expect(find.byType(DriverHomeMapCard), findsOneWidget);
      expect(find.byType(DriverCurrentOrderCard), findsOneWidget);
      expect(find.text('BX-458722'), findsOneWidget);
      expect(find.text('محمد علي'), findsOneWidget);
      expect(find.byType(DriverIssuesHelpBanner), findsOneWidget);
      expect(find.text('في حال وجود مشكلة في التوصيل'), findsOneWidget);
      expect(find.byType(DriverDailySummarySection), findsOneWidget);
      expect(find.text('ملخص اليوم'), findsOneWidget);
      expect(find.byType(DriverDailyPerformanceSection), findsOneWidget);
      expect(find.text('أداء اليوم'), findsOneWidget);

      await tester.ensureVisible(find.byType(DriverIssuesHelpBanner));
      await tester.tap(find.byType(DriverIssuesHelpBanner));
      await tester.pump();
      expect(issuesTapped, isTrue);

      await tester.ensureVisible(find.text('عرض التفاصيل'));
      await tester.tap(find.text('عرض التفاصيل'));
      await tester.pump();
      expect(orderDetailsTapped, isTrue);
    });
  });
}
