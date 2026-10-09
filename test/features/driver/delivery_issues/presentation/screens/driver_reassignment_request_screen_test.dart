import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/reassignment_delivery_context_entity.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/reassignment_reason.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/reassignment_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/reassignment_result_entity.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/usecase/submit_driver_reassignment_usecase.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/manager/driver_reassignment_view_model.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/screens/driver_reassignment_request_screen.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/widgets/reassignment_submission_shimmer.dart';

class TestFakeSubmitUseCase implements SubmitDriverReassignmentUseCase {
  Completer<ApiResult<ReassignmentResultEntity>> completer = Completer();
  int callCount = 0;
  String? capturedBoxId;
  ReassignmentRequestEntity? capturedRequest;


  @override
  Future<ApiResult<ReassignmentResultEntity>> call({
    required String boxId,
    required ReassignmentRequestEntity request,
  }) {
    callCount++;
    capturedBoxId = boxId;
    capturedRequest = request;
    return completer.future;
  }
}

Widget _buildTestApp({
  ValueChanged<ReassignmentRequestEntity>? onSubmitRequest,
  VoidCallback? onBackPressed,
  ReassignmentRequestEntity? initialRequest,
  ReassignmentDeliveryContextEntity? deliveryContext,
  DriverReassignmentViewModel? viewModel,
  Locale locale = const Locale('ar'),
  void Function(ReassignmentResultEntity? result)? onNavigateSuccess,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ar'), Locale('en')],
    locale: locale,
    onGenerateRoute: (settings) {
      if (settings.name == AppRoutes.driverReassignmentSubmitted) {
        final result = settings.arguments as ReassignmentResultEntity?;
        onNavigateSuccess?.call(result);
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(body: Text('Submitted Confirmation Screen')),
        );
      }
      return null;
    },
    home: DriverReassignmentRequestScreen(
      onSubmitRequest: onSubmitRequest,
      onBackPressed: onBackPressed,
      initialRequest: initialRequest,
      deliveryContext: deliveryContext,
      viewModel: viewModel,
    ),
  );
}

void main() {
  group('DriverReassignmentRequestScreen', () {
    testWidgets(
        'renders unselected reason initially, prevents submit until reason selected, and supports cancel',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      ReassignmentRequestEntity? submitted;
      bool backPressed = false;

      await tester.pumpWidget(
        _buildTestApp(
          onSubmitRequest: (req) => submitted = req,
          onBackPressed: () => backPressed = true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('طلب إعادة إسناد'), findsWidgets);
      expect(find.text('سبب الطلب'), findsOneWidget);
      expect(find.text('اختر سبب إعادة الإسناد'), findsOneWidget);
      expect(find.text('إرسال الطلب'), findsOneWidget);
      expect(find.text('إلغاء'), findsOneWidget);

      // Attempt to submit while button is disabled
      await tester.ensureVisible(find.text('إرسال الطلب'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('إرسال الطلب'));
      await tester.pumpAndSettle();
      expect(submitted, isNull);

      // Tap cancel button
      await tester.ensureVisible(find.text('إلغاء'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();
      expect(backPressed, isTrue);

      // Select reason
      await tester.ensureVisible(find.byType(DropdownButton<ReassignmentReason>));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButton<ReassignmentReason>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('عطل في المركبة').last);
      await tester.pumpAndSettle();

      // Submit now that reason is selected
      await tester.ensureVisible(find.text('إرسال الطلب'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('إرسال الطلب'));
      await tester.pumpAndSettle();

      expect(submitted, isNotNull);
      expect(submitted?.reason, equals(ReassignmentReason.vehicleBreakdown));
    });

    testWidgets('shows Shimmer while pending, retains inputs, and navigates to confirmation only on success',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeUseCase = TestFakeSubmitUseCase();
      final viewModel = DriverReassignmentViewModel(submitUseCase: fakeUseCase);
      addTearDown(viewModel.close);

      ReassignmentResultEntity? navigatedResult;

      const validContext = ReassignmentDeliveryContextEntity(
        boxId: 'box-uuid-1234',
        boxCode: '#BX-99',
        isPickedUp: true,
        driverLatitude: 29.35,
        driverLongitude: 47.95,
      );

      await tester.pumpWidget(
        _buildTestApp(
          deliveryContext: validContext,
          viewModel: viewModel,
          onNavigateSuccess: (res) => navigatedResult = res,
        ),
      );
      await tester.pumpAndSettle();

      // Select reason
      await tester.tap(find.byType(DropdownButton<ReassignmentReason>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('عطل في المركبة').last);
      await tester.pumpAndSettle();

      // Type notes
      await tester.enterText(find.byType(TextField), 'Engine problem');
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('إرسال الطلب'));
      await tester.pump(); // Start async submission

      // Verify Shimmer is displayed in button footprint while pending
      expect(find.byType(ReassignmentSubmissionShimmer), findsOneWidget);
      expect(find.text('Submitted Confirmation Screen'), findsNothing);
      expect(navigatedResult, isNull);

      // Verify notes are retained in textfield
      expect(find.text('Engine problem'), findsOneWidget);

      // Resolve UseCase successfully
      fakeUseCase.completer.complete(
        const ApiSuccessResult(
          data: ReassignmentResultEntity(
            requestId: 'req-uuid-999',
            boxId: 'box-uuid-1234',
            status: 'ReassignmentRequested',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Now navigation happens
      expect(find.text('Submitted Confirmation Screen'), findsOneWidget);
      expect(navigatedResult?.requestId, equals('req-uuid-999'));
    });

    testWidgets('409 already active keeps form mounted with retained notes, shows banner, and never opens confirmation',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeUseCase = TestFakeSubmitUseCase();
      final viewModel = DriverReassignmentViewModel(submitUseCase: fakeUseCase);
      addTearDown(viewModel.close);

      bool navigated = false;

      const validContext = ReassignmentDeliveryContextEntity(
        boxId: 'box-uuid-1234',
        boxCode: '#BX-99',
        isPickedUp: true,
      );

      await tester.pumpWidget(
        _buildTestApp(
          deliveryContext: validContext,
          viewModel: viewModel,
          onNavigateSuccess: (_) => navigated = true,
        ),
      );
      await tester.pumpAndSettle();

      // Select reason and notes
      await tester.tap(find.byType(DropdownButton<ReassignmentReason>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('عطل في المركبة').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'My persistent notes');
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('إرسال الطلب'));
      await tester.pump();

      // Complete with 409 already active
      fakeUseCase.completer.complete(
        ApiErrorResult(
          failure: Failure(
            errorMessage: 'Request already active',
            code: 'driver.reassignment.request_already_active',
            exception: const ApiException(
              errorType: ApiErrorType.conflict,
              message: 'Request already active',
              statusCode: 409,
              backendErrorCode: 'driver.reassignment.request_already_active',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Confirmation is NOT opened
      expect(navigated, isFalse);
      expect(find.text('Submitted Confirmation Screen'), findsNothing);

      // Form stays mounted, notes retained, conflict banner shown
      expect(find.text('My persistent notes'), findsOneWidget);
      expect(find.text('يوجد طلب إعادة إسناد نشط بالفعل لهذا الطلب.'), findsOneWidget);
    });

    testWidgets('unpicked or missing context shows unavailable context warning and disables submit',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const unpickedContext = ReassignmentDeliveryContextEntity(
        boxId: 'box-uuid-1234',
        isPickedUp: false, // Not picked up
      );

      await tester.pumpWidget(
        _buildTestApp(deliveryContext: unpickedContext),
      );
      await tester.pumpAndSettle();

      expect(find.text('لا توجد شحنة نشطة متاحة لإعادة الإسناد.'), findsOneWidget);

      // Select reason
      await tester.tap(find.byType(DropdownButton<ReassignmentReason>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('عطل في المركبة').last);
      await tester.pumpAndSettle();

      // Submit button is disabled because context is not picked up
      final submitFinder = find.widgetWithText(ElevatedButton, 'إرسال الطلب');
      final submitButton = tester.widget<ElevatedButton>(submitFinder);
      expect(submitButton.onPressed, isNull);
    });

    testWidgets('English LTR renders without overflow', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const validContext = ReassignmentDeliveryContextEntity(
        boxId: 'box-uuid-1234',
        isPickedUp: true,
      );

      await tester.pumpWidget(
        _buildTestApp(
          deliveryContext: validContext,
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reassignment Request'), findsWidgets);
      expect(find.text('Submit Request'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
