import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/driver_call_attempt_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/customer_call_attempts_sheet.dart';

Widget _buildTestWidget({
  DriverCallAttemptEntity? attempt,
  VoidCallback? onStartCall,
  VoidCallback? onDirectCall,
  VoidCallback? onReportUnreachable,
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
    home: Scaffold(
      body: CustomerCallAttemptsSheet(
        initialAttempt: attempt,
        onStartCall: onStartCall,
        onDirectCall: onDirectCall,
        onReportUnreachable: onReportUnreachable,
      ),
    ),
  );
}

void main() {
  group('CustomerCallAttemptsSheet', () {
    testWidgets('renders Attempt 1 UI with Call Now and Cancel buttons',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        attempt: const DriverCallAttemptEntity(
          customerName: 'محمد علي',
          customerPhone: '+966 50 123 4567',
          attemptNumber: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('الاتصال بالعميل'), findsOneWidget);
      expect(find.text('هل تريد الاتصال بالعميل محمد علي الآن؟'), findsOneWidget);
      expect(find.text('اتصل الآن'), findsOneWidget);
      expect(find.text('إلغاء'), findsOneWidget);
      expect(find.text('رقم الهاتف محمي'), findsOneWidget);
    });

    testWidgets('renders Attempt 2 UI with warning banner', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        attempt: const DriverCallAttemptEntity(
          customerName: 'محمد علي',
          customerPhone: '+966 50 123 4567',
          attemptNumber: 2,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('لم يتم الرد من العميل'), findsOneWidget);
      expect(find.text('المحاولة 1 من 3'), findsOneWidget);
      expect(find.text('اتصل الآن'), findsOneWidget);
    });

    testWidgets('renders Attempt 3 UI with recovery options and phone unlocked',
        (tester) async {
      var directCalled = false;
      var reportCalled = false;

      await tester.pumpWidget(_buildTestWidget(
        attempt: const DriverCallAttemptEntity(
          customerName: 'محمد علي',
          customerPhone: '+966 50 123 4567',
          attemptNumber: 3,
        ),
        onDirectCall: () => directCalled = true,
        onReportUnreachable: () => reportCalled = true,
      ));
      await tester.pumpAndSettle();

      expect(find.text('تعذر التواصل مع العميل'), findsOneWidget);
      expect(find.text('تم إتاحة الاتصال الخارجي'), findsOneWidget);
      expect(find.text('اتصل برقم الهاتف الخارجي'), findsOneWidget);
      expect(find.text('إبلاغ عن تعذر التواصل'), findsOneWidget);

      await tester.tap(find.text('اتصل برقم الهاتف الخارجي'));
      await tester.pump();
      expect(directCalled, isTrue);

      await tester.tap(find.text('إبلاغ عن تعذر التواصل'));
      await tester.pump();
      expect(reportCalled, isTrue);
    });

    testWidgets('triggers onStartCall callback when tapping Call Now',
        (tester) async {
      var callStarted = false;

      await tester.pumpWidget(_buildTestWidget(
        onStartCall: () => callStarted = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('اتصل الآن'));
      await tester.pump();
      expect(callStarted, isTrue);
    });
  });
}
