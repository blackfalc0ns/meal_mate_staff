import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/reassignment_result_entity.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/screens/driver_reassignment_submitted_screen.dart';

Widget _buildTestWidget({
  ReassignmentResultEntity? result,
  VoidCallback? onReturnHome,
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
    home: DriverReassignmentSubmittedScreen(
      result: result,
      onReturnHome: onReturnHome,
    ),
  );
}

void main() {
  group('DriverReassignmentSubmittedScreen', () {
    const validResult = ReassignmentResultEntity(
      requestId: 'f4444444-4444-4444-4444-444444444444',
      boxId: 'c2222222-2222-2222-2222-222222222222',
      boxCode: '#BX-1256',
      status: 'ReassignmentRequested',
    );

    testWidgets(
        'renders success card with review wording and no acceptance promise, and triggers onReturnHome',
        (tester) async {
      bool returnedHome = false;

      await tester.pumpWidget(
        _buildTestWidget(
          result: validResult,
          onReturnHome: () => returnedHome = true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تم إرسال طلب\nإعادة الإسناد'), findsOneWidget);
      // Explicit requirement: Review copy without acceptance/push promise
      expect(
        find.text('تم إرسال طلب إعادة الإسناد للدعم للمراجعة.'),
        findsOneWidget,
      );
      expect(find.text('العودة للرئيسية'), findsOneWidget);

      await tester.tap(find.text('العودة للرئيسية'));
      expect(returnedHome, isTrue);
    });

    testWidgets('renders unavailable feedback when result is missing',
        (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          result: null,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تم إرسال طلب\nإعادة الإسناد'), findsNothing);
      expect(find.text('لا توجد شحنة نشطة متاحة لإعادة الإسناد.'), findsOneWidget);
      expect(find.text('العودة للرئيسية'), findsOneWidget);
    });
  });
}
