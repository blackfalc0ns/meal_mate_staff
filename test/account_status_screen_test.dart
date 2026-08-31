import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';
import 'package:meal_mate_delivery/features/account_status/domain/account_status_kind.dart';
import 'package:meal_mate_delivery/features/account_status/presentation/screens/account_status_screen.dart';

void main() {
  Widget buildSubject(
    AccountStatusKind kind, {
    Locale locale = const Locale('en'),
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: AccountStatusScreen(kind: kind),
    );
  }

  testWidgets('renders accepted status actions', (tester) async {
    await tester.pumpWidget(buildSubject(AccountStatusKind.accepted));

    expect(find.text('Your account has been accepted!'), findsOneWidget);
    expect(
      find.text(
        'Your account was activated successfully\nYou can start working now',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(AppButton, 'Start work'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Back to login'), findsOneWidget);
  });

  testWidgets('renders rejected status reasons', (tester) async {
    await tester.pumpWidget(buildSubject(AccountStatusKind.rejected));

    expect(find.text('Application rejected'), findsOneWidget);
    expect(find.text('Rejection reason'), findsOneWidget);
    expect(
      find.text('Civil ID does not match the submitted data'),
      findsOneWidget,
    );
    expect(
      find.text('Driving license validity date has expired'),
      findsOneWidget,
    );
    expect(find.text('Vehicle registration photo is unclear'), findsOneWidget);
  });

  testWidgets('renders more information required reasons', (tester) async {
    await tester.pumpWidget(
      buildSubject(AccountStatusKind.moreInformationRequired),
    );

    expect(find.text('Data changes required'), findsOneWidget);
    expect(find.text('Reason for requested changes'), findsOneWidget);
    expect(find.text('Driving license is unclear'), findsOneWidget);
    expect(find.text('Vehicle registration is expired'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Edit and resend'), findsOneWidget);
  });

  testWidgets('renders under review dashboard status', (tester) async {
    await tester.pumpWidget(buildSubject(AccountStatusKind.underReview));

    expect(find.text('Account status'), findsOneWidget);
    expect(
      find.text('We are checking your data and documents'),
      findsOneWidget,
    );
    expect(find.text('Your account is under review'), findsOneWidget);
    expect(find.text('Need help?'), findsOneWidget);
    expect(find.text('Get help'), findsOneWidget);
    expect(find.byIcon(Icons.headset_mic_rounded), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
    expect(
      find.text(
        'We appreciate your patience, and promise you a successful and safe delivery experience\nwith MealMate',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'places help icon on the left and support content on the right in rtl',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(AccountStatusKind.underReview, locale: const Locale('ar')),
      );

      final iconCenter = tester.getCenter(
        find.byIcon(Icons.headset_mic_rounded),
      );
      final titleCenter = tester.getCenter(find.text('تحتاج مساعدة؟'));
      final subtitleBottom = tester
          .getBottomLeft(find.text('فريق الدعم متاح للإجابة على استفساراتك'))
          .dy;
      final buttonCenter = tester.getCenter(
        find.widgetWithText(AppButton, 'الحصول على مساعدة'),
      );
      final buttonTop = tester
          .getTopLeft(find.widgetWithText(AppButton, 'الحصول على مساعدة'))
          .dy;

      expect(iconCenter.dx, lessThan(titleCenter.dx));
      expect(buttonCenter.dx, greaterThan(iconCenter.dx));
      expect(buttonTop, greaterThan(subtitleBottom));
    },
  );
}
