import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/timeout_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';

Widget _buildTestApp({
  required Widget child,
  Locale locale = const Locale('ar'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: child),
  );
}

void main() {
  group('TimeoutErrorWidget Localization Tests', () {
    testWidgets('renders Arabic localization for timeout widget and retry button', (
      tester,
    ) async {
      var retried = false;

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('ar'),
          child: TimeoutErrorWidget(
            timeoutType: ApiErrorType.receiveTimeout,
            onRetry: () => retried = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Title in Arabic
      expect(find.text('انتهت مهلة الاتصال'), findsOneWidget);
      // Description in Arabic for receive timeout
      expect(find.text('انتهت مهلة استلام البيانات'), findsOneWidget);
      // Retry button in Arabic
      expect(find.text('إعادة المحاولة'), findsOneWidget);

      await tester.tap(find.text('إعادة المحاولة'));
      expect(retried, isTrue);
    });

    testWidgets('renders English localization for timeout widget and retry button', (
      tester,
    ) async {
      var retried = false;

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('en'),
          child: TimeoutErrorWidget(
            timeoutType: ApiErrorType.receiveTimeout,
            onRetry: () => retried = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Title in English
      expect(find.text('Connection timeout'), findsOneWidget);
      // Description in English
      expect(find.text('Receive timeout'), findsOneWidget);
      // Retry button in English
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });
  });
}
