import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';
import 'package:meal_mate_delivery/features/register/domain/register_document.dart';
import 'package:meal_mate_delivery/features/register/presentation/screens/register_review_screen.dart';

void main() {
  testWidgets('renders review cards as bordered tables', (tester) async {
    await _pumpReviewScreen(tester);

    expect(
      find.byKey(const Key('register-review-card-table')),
      findsNWidgets(2),
    );
    expect(
      find.byKey(const Key('register-uploaded-documents-table')),
      findsOneWidget,
    );
  });

  testWidgets('renders larger edit buttons in review sections', (tester) async {
    await _pumpReviewScreen(tester);

    final editButtons = find.widgetWithText(AppButton, 'Edit');

    expect(editButtons, findsNWidgets(3));
    for (final element in editButtons.evaluate()) {
      final renderBox = element.renderObject! as RenderBox;

      expect(renderBox.size.width, greaterThanOrEqualTo(68));
      expect(renderBox.size.height, greaterThanOrEqualTo(30));
    }
  });

  testWidgets(
    'keeps single-value review rows full width without extra borders',
    (tester) async {
      await _pumpReviewScreen(tester);

      final reviewTables = find.byKey(const Key('register-review-card-table'));

      expect(
        find.byKey(const Key('register-review-single-row')),
        findsNWidgets(2),
      );
      for (final table in tester.widgetList<Table>(reviewTables)) {
        expect(table.border?.bottom, BorderSide.none);
      }
    },
  );
}

Future<void> _pumpReviewScreen(WidgetTester tester) {
  return tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: RegisterReviewScreen(
          selectedImagePaths: const {},
          onDocumentTap: (RegisterDocument document) {},
          onSubmit: () {},
          onBackToEdit: () {},
        ),
      ),
    ),
  );
}
