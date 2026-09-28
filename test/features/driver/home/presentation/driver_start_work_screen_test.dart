import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/home/data/datasources/driver_home_fake_datasource.dart';
import 'package:meal_mate_delivery/features/driver/home/data/repositories/driver_home_repository_impl.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/usecases/get_driver_start_work_usecase.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/usecases/start_driver_shift_usecase.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/manager/driver_start_work_view_model.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/screens/driver_start_work_screen.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/start_work/driver_start_work_action_button.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/start_work/driver_start_work_header_logo.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/start_work/driver_start_work_status_card.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/start_work/driver_start_work_title_section.dart';

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

  group('DriverStartWorkScreen Widget Tests', () {
    late DriverHomeFakeDataSource fakeDataSource;
    late DriverHomeRepositoryImpl repository;
    late DriverStartWorkViewModel viewModel;

    setUp(() {
      fakeDataSource = DriverHomeFakeDataSource();
      repository = DriverHomeRepositoryImpl(fakeDataSource);
      viewModel = DriverStartWorkViewModel(
        getDriverStartWorkUseCase: GetDriverStartWorkUseCase(repository),
        startDriverShiftUseCase: StartDriverShiftUseCase(repository),
      );
    });

    testWidgets('renders all 05.01 components and triggers start shift on card tap', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      bool startWorkCalled = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: DriverStartWorkScreen(
            viewModel: viewModel,
            onStartWorkSuccess: () {
              startWorkCalled = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DriverStartWorkHeaderLogo), findsOneWidget);
      expect(find.byType(DriverStartWorkTitleSection), findsOneWidget);
      expect(find.text('غير متاح للعمل'), findsOneWidget);
      expect(find.text('أكمل المتطلبات لبدء استلام الطلبات'), findsOneWidget);
      expect(find.byType(DriverStartWorkStatusCard), findsOneWidget);
      expect(find.text('حالتك الآن'), findsOneWidget);
      expect(find.text('غير متاح'), findsOneWidget);
      expect(find.text('أنت غير متاح لاستلام الطلبات'), findsOneWidget);
      expect(find.byType(DriverStartWorkActionButton), findsOneWidget);
      expect(find.text('بدء العمل'), findsOneWidget);

      await tester.tap(find.byType(DriverStartWorkActionButton));
      await tester.pumpAndSettle();

      expect(startWorkCalled, isTrue);
      expect(fakeDataSource.isShiftActive, isTrue);
    });
  });
}
