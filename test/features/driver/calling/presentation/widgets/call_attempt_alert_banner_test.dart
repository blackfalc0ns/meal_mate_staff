import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/call_attempt_alert_banner.dart';

Widget _buildTestWidget({required int attemptNumber}) {
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
      body: CallAttemptAlertBanner(attemptNumber: attemptNumber),
    ),
  );
}

void main() {
  group('CallAttemptAlertBanner', () {
    testWidgets('renders empty box when attempt is 1', (tester) async {
      await tester.pumpWidget(_buildTestWidget(attemptNumber: 1));
      await tester.pumpAndSettle();

      expect(find.text('لم يتم الرد من العميل'), findsNothing);
      expect(find.text('تعذر التواصل مع العميل'), findsNothing);
    });

    testWidgets('renders warning banner when attempt is 2', (tester) async {
      await tester.pumpWidget(_buildTestWidget(attemptNumber: 2));
      await tester.pumpAndSettle();

      expect(find.text('لم يتم الرد من العميل'), findsOneWidget);
      expect(find.text('المحاولة 1 من 3'), findsOneWidget);
      expect(find.text('لم يتم الرد'), findsOneWidget);
    });

    testWidgets('renders error banner when attempt is 3', (tester) async {
      await tester.pumpWidget(_buildTestWidget(attemptNumber: 3));
      await tester.pumpAndSettle();

      expect(find.text('تعذر التواصل مع العميل'), findsOneWidget);
      expect(find.text('بعد 3 محاولات اتصال لم يتم الرد'), findsOneWidget);
      expect(find.text('لم يتم الرد'), findsOneWidget);
    });
  });
}
