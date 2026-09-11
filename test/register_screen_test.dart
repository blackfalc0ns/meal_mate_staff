import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/widget/custom_app_bar.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/auth/presentation/widgets/registration_step_progress.dart';
import 'package:meal_mate_delivery/features/register/presentation/screens/register_screen.dart';

void main() {
  testWidgets(
    'starts with personal data fields as the first registration step',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.lightTheme,
          home: const RegisterScreen(),
        ),
      );

      expect(find.byType(CustomAppBar), findsOneWidget);
      expect(find.text('Personal data'), findsWidgets);
      expect(find.text('Enter first name'), findsOneWidget);
      expect(find.text('Enter last name'), findsOneWidget);
      expect(find.text('Enter phone number'), findsOneWidget);
      expect(find.text('Enter email'), findsOneWidget);
      expect(find.text('Choose birth date'), findsOneWidget);
      expect(find.text('Choose nationality'), findsOneWidget);
      expect(find.text('Enter civil ID'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Uploaded documents'), findsNothing);
    },
  );

  testWidgets('shows vehicle data as the second registration step', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Vehicle data'), findsWidgets);
    expect(find.text('Choose vehicle type'), findsOneWidget);
    expect(find.text('Choose company / model'), findsOneWidget);
    expect(find.text('Choose manufacture year'), findsOneWidget);
    expect(find.text('Enter plate number'), findsOneWidget);
    expect(find.text('Do you own the vehicle?'), findsOneWidget);
    expect(find.text('Uploaded documents'), findsNothing);
  });

  testWidgets('uses app buttons for registration actions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    expect(find.widgetWithText(AppButton, 'Continue'), findsOneWidget);

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppButton, 'Continue'), findsOneWidget);

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(AppButton, 'Continue'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppButton, 'Edit'), findsNWidgets(3));
    expect(
      find.widgetWithText(AppButton, 'Submit acceptance request'),
      findsOneWidget,
    );
    expect(find.widgetWithText(AppButton, 'Back to edit'), findsOneWidget);
  });

  testWidgets('keeps registration progress outside the scrollable content', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    expect(
      find.ancestor(
        of: find.byType(RegistrationStepProgress),
        matching: find.byType(SingleChildScrollView),
      ),
      findsNothing,
    );
  });

  testWidgets('app bar back button returns to the previous registration step', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Personal data'), findsWidgets);
    expect(find.text('Enter first name'), findsOneWidget);
    expect(find.text('Choose vehicle type'), findsNothing);
  });

  testWidgets('app bar back button returns from review to documents', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Documents'), findsWidgets);
    expect(find.text('Civil card'), findsOneWidget);
    expect(find.text('Back to edit'), findsNothing);
  });

  testWidgets('shows upload documents as the third registration step', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Documents'), findsWidgets);
    expect(find.text('Civil card'), findsOneWidget);
    expect(find.text('Clear photo of a valid civil card'), findsOneWidget);
    expect(find.text('Driving license'), findsOneWidget);
    expect(find.text('Clear photo of a valid driving license'), findsOneWidget);
    expect(find.text('Car registration'), findsOneWidget);
    expect(find.text('Front side of the car registration'), findsOneWidget);
    expect(find.text('Vehicle photo'), findsOneWidget);
    expect(find.text('Clear exterior photo of the vehicle'), findsOneWidget);
    expect(find.text('Personal photo'), findsOneWidget);
    expect(find.text('Personal photo with clear background'), findsOneWidget);
    expect(find.text('Important note'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Uploaded documents'), findsNothing);
  });

  testWidgets('renders review sections after submitting documents', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Review order'), findsWidgets);
    expect(find.text('Personal data'), findsWidgets);
    expect(find.text('Vehicle data'), findsWidgets);
    expect(find.text('Uploaded documents'), findsOneWidget);
    expect(find.text('Submit acceptance request'), findsOneWidget);
    expect(find.text('Back to edit'), findsOneWidget);
  });

  testWidgets('opens camera and gallery choices for photo upload', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Personal photo'));
    await tester.tap(find.text('Personal photo'));
    await tester.pumpAndSettle();

    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
  });

  testWidgets('opens camera and gallery choices from review documents', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Personal photo'));
    await tester.tap(find.text('Personal photo'));
    await tester.pumpAndSettle();

    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
  });
}
