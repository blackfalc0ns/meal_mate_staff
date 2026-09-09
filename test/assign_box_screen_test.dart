import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';
import 'package:meal_mate_delivery/core/widget/custom_app_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/assign_box/presentation/screens/assign_box_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/assign_box/presentation/widgets/assign_box_bottom_actions.dart';
import 'package:meal_mate_delivery/features/dispatcher/assign_box/presentation/widgets/assign_box_driver_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/assign_box/presentation/widgets/assign_box_recommended_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/assign_box/presentation/widgets/assign_box_summary_card.dart';

void main() {
  Widget buildSubject({Locale locale = const Locale('ar')}) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: const AssignBoxScreen(),
    );
  }

  testWidgets('renders AssignBoxScreen with all components in Arabic', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // App Bar
    expect(find.byType(CustomAppBar), findsOneWidget);
    expect(find.text('إسناد البوكس #BX-1256'), findsOneWidget);

    // Box Summary Card
    expect(find.byType(AssignBoxSummaryCard), findsOneWidget);
    expect(find.text('#BX-1256'), findsWidgets);
    expect(find.text('جديد'), findsOneWidget);
    expect(find.text('منطقة السالمية'), findsOneWidget);
    expect(find.text('6.2 كم'), findsWidgets);
    expect(find.text('09:30-10:30 ص'), findsOneWidget);
    expect(find.text('عالية'), findsOneWidget);
    expect(find.text('8 وجبات'), findsOneWidget);

    // Best Suggestion Card
    expect(find.byType(AssignBoxRecommendedCard), findsOneWidget);
    expect(find.text('أفضل اقتراح'), findsOneWidget);
    expect(find.text('سالم الحربي'), findsOneWidget);
    expect(find.text('الأقرب'), findsOneWidget);

    // Candidate Drivers List
    expect(find.text('اختر سائقاً للإسناد'), findsOneWidget);
    expect(find.text('عرض الكل'), findsOneWidget);
    expect(find.byType(AssignBoxDriverCard), findsNWidgets(4));
    expect(find.text('أحمد إبراهيم'), findsOneWidget);
    expect(find.text('محمد السعيد'), findsOneWidget);
    expect(find.text('يوسف العتيبي'), findsOneWidget);
    expect(find.text('سالم الدوسري'), findsOneWidget);

    // Bottom Action Buttons
    expect(find.byType(AssignBoxBottomActions), findsOneWidget);
    expect(find.byType(AppButton), findsNWidgets(2));
    expect(find.text('عرض البوكس'), findsOneWidget);
    expect(find.text('تأكيد الإسناد'), findsOneWidget);
  });

  testWidgets('allows selecting a different candidate driver', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Tap on Ahmad Ibrahim driver card
    await tester.tap(find.text('أحمد إبراهيم'));
    await tester.pumpAndSettle();

    // Verify radio icon state changed
    expect(find.byIcon(Icons.radio_button_checked_rounded), findsOneWidget);
  });

  testWidgets('renders AssignBoxScreen in English locale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject(locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Assign Box #BX-1256'), findsOneWidget);
    expect(find.text('Best Suggestion'), findsOneWidget);
    expect(find.text('Select Driver to Assign'), findsOneWidget);
    expect(find.text('View All'), findsOneWidget);
    expect(find.text('View Box'), findsOneWidget);
    expect(find.text('Confirm Assignment'), findsOneWidget);
  });
}
