import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/auth/presentation/widgets/registration_step_progress.dart';

void main() {
  testWidgets(
    'shows completed registration steps with check icons and a full progress line',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.lightTheme,
          home: const Directionality(
            textDirection: TextDirection.ltr,
            child: Scaffold(
              body: Center(child: RegistrationStepProgress(currentStep: 4)),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_rounded), findsNWidgets(3));
      expect(find.text('1'), findsNothing);
      expect(find.text('2'), findsNothing);
      expect(find.text('3'), findsNothing);
      expect(find.text('4'), findsOneWidget);

      final trackWidth = tester
          .getSize(find.byKey(const Key('registration-step-progress-track')))
          .width;
      final fillWidth = tester
          .getSize(find.byKey(const Key('registration-step-progress-fill')))
          .width;

      expect(fillWidth, closeTo(trackWidth, 0.1));
    },
  );

  testWidgets(
    'track starts at the center of the first circle and ends at the center of the last circle',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.lightTheme,
          home: const Directionality(
            textDirection: TextDirection.ltr,
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 400,
                  child: RegistrationStepProgress(currentStep: 1),
                ),
              ),
            ),
          ),
        ),
      );

      final trackRect = tester
          .getRect(find.byKey(const Key('registration-step-progress-track')));
      final checkOrNumFinders = find.byType(DecoratedBox);
      // The circles are decorated boxes with circle shape
      final circleRects = tester
          .widgetList<DecoratedBox>(checkOrNumFinders)
          .where((w) => (w.decoration as BoxDecoration?)?.shape == BoxShape.circle)
          .map((w) => tester.getRect(find.byWidget(w)))
          .toList();

      expect(circleRects.length, 4);

      final firstCircleCenter = circleRects.first.center.dx;
      final lastCircleCenter = circleRects.last.center.dx;

      expect(trackRect.left, closeTo(firstCircleCenter, 0.5));
      expect(trackRect.right, closeTo(lastCircleCenter, 0.5));
    },
  );
}
