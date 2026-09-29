import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/driver_call_action_button.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/driver_call_controls_row.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/driver_call_end_button.dart';

void main() {
  Widget buildSubject({
    required Widget child,
    Locale locale = const Locale('ar'),
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('DriverCallActionButton', () {
    testWidgets('renders icon, label, and responds to tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildSubject(
          child: DriverCallActionButton(
            icon: Icons.volume_up_outlined,
            label: 'سماعة',
            isActive: false,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('سماعة'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_outlined), findsOneWidget);

      await tester.tap(find.text('سماعة'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });

  group('DriverCallEndButton', () {
    testWidgets('renders end call icon, label, and responds to tap', (tester) async {
      bool endTapped = false;
      await tester.pumpWidget(
        buildSubject(
          child: DriverCallEndButton(
            onEndCall: () => endTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('إنهاء المكالمة'), findsOneWidget);
      expect(find.byIcon(Icons.call_end_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.call_end_rounded));
      await tester.pumpAndSettle();
      expect(endTapped, isTrue);
    });
  });

  group('DriverCallControlsRow', () {
    testWidgets('renders speaker, mute, and end call controls with proper toggles', (
      tester,
    ) async {
      bool speakerTapped = false;
      bool muteTapped = false;
      bool endTapped = false;

      await tester.pumpWidget(
        buildSubject(
          child: DriverCallControlsRow(
            isSpeakerOn: false,
            isMuted: true,
            onToggleSpeaker: () => speakerTapped = true,
            onToggleMute: () => muteTapped = true,
            onEndCall: () => endTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('سماعة'), findsOneWidget);
      expect(find.text('كتم الميكروفون'), findsOneWidget);
      expect(find.text('إنهاء المكالمة'), findsOneWidget);

      await tester.tap(find.text('سماعة'));
      expect(speakerTapped, isTrue);

      await tester.tap(find.text('كتم الميكروفون'));
      expect(muteTapped, isTrue);

      await tester.tap(find.text('إنهاء المكالمة'));
      expect(endTapped, isTrue);
    });
  });
}
