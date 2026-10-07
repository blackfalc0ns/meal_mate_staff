import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/reassignment_reason.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/reassignment_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/screens/driver_reassignment_request_screen.dart';

Widget _buildTestWidget({
  ValueChanged<ReassignmentRequestEntity>? onSubmitRequest,
  VoidCallback? onBackPressed,
  ReassignmentRequestEntity? initialRequest,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ar'), Locale('en')],
    locale: const Locale('ar'),
    home: DriverReassignmentRequestScreen(
      onSubmitRequest: onSubmitRequest,
      onBackPressed: onBackPressed,
      initialRequest: initialRequest,
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
        _buildTestWidget(
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
      expect(submitted?.reason, equals(ReassignmentReason.vehicleFailure));
    });
  });
}
