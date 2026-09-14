import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/widget/custom_bottom_sheet.dart';

void main() {
  Widget buildTestWidget({
    required Widget child,
    Locale locale = const Locale('ar'),
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: Scaffold(body: child),
    );
  }

  group('CustomBottomSheet Widget Tests', () {
    testWidgets('renders title, subtitle, headers, content and footer', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const CustomBottomSheet(
            title: 'Sheet Title',
            subtitle: 'Sheet Subtitle',
            headerLeading: Icon(Icons.arrow_back),
            headerTrailing: Icon(Icons.close),
            footer: Text('Footer Content'),
            child: Text('Body Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sheet Title'), findsOneWidget);
      expect(find.text('Sheet Subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Body Content'), findsOneWidget);
      expect(find.text('Footer Content'), findsOneWidget);
    });

    testWidgets('renders custom fixed header outside scrollable area', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const CustomBottomSheet(
            header: Text('Fixed Custom Header'),
            child: Text('Scrollable Body Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fixed Custom Header'), findsOneWidget);
      expect(find.text('Scrollable Body Content'), findsOneWidget);
    });

    testWidgets('CustomBottomSheet.show opens modal bottom sheet', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  CustomBottomSheet.show<void>(
                    context: context,
                    title: 'Modal Title',
                    child: const Text('Modal Body'),
                  );
                },
                child: const Text('Open Sheet'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Open Sheet'), findsOneWidget);
      expect(find.text('Modal Title'), findsNothing);

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Modal Title'), findsOneWidget);
      expect(find.text('Modal Body'), findsOneWidget);
    });
  });
}
