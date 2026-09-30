import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/call_failed_recovery_options.dart';

Widget _buildTestWidget({
  VoidCallback? onDirectCall,
  VoidCallback? onReportUnreachable,
  VoidCallback? onCancel,
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
      body: CallFailedRecoveryOptions(
        onDirectCallPressed: onDirectCall,
        onReportUnreachablePressed: onReportUnreachable,
        onCancelPressed: onCancel,
      ),
    ),
  );
}

void main() {
  group('CallFailedRecoveryOptions', () {
    testWidgets('renders all 3 recovery buttons and responds to taps',
        (tester) async {
      var directCalled = false;
      var reportCalled = false;
      var cancelCalled = false;

      await tester.pumpWidget(_buildTestWidget(
        onDirectCall: () => directCalled = true,
        onReportUnreachable: () => reportCalled = true,
        onCancel: () => cancelCalled = true,
      ));
      await tester.pumpAndSettle();

      expect(find.text('اتصل برقم الهاتف الخارجي'), findsOneWidget);
      expect(find.text('إبلاغ عن تعذر التواصل'), findsOneWidget);
      expect(find.text('إلغاء'), findsOneWidget);

      await tester.tap(find.text('اتصل برقم الهاتف الخارجي'));
      await tester.pump();
      expect(directCalled, isTrue);

      await tester.tap(find.text('إبلاغ عن تعذر التواصل'));
      await tester.pump();
      expect(reportCalled, isTrue);

      await tester.tap(find.text('إلغاء'));
      await tester.pump();
      expect(cancelCalled, isTrue);
    });
  });
}
