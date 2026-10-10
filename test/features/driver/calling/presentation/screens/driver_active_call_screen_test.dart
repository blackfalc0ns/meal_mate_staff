import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/driver_active_call_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/screens/driver_active_call_screen.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/driver_call_address_card.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/driver_call_avatar.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/driver_call_controls_row.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/driver_call_header.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/driver_call_top_bar.dart';

void main() {
  Widget buildSubject({
    DriverActiveCallEntity? callData,
    VoidCallback? onEndCall,
    VoidCallback? onDismiss,
    Locale locale = const Locale('ar'),
    bool enableTimer = false,
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
      home: DriverActiveCallScreen(
        callData: callData,
        onEndCall: onEndCall,
        onDismiss: onDismiss,
        enableTimer: enableTimer,
      ),
    );
  }

  group('DriverActiveCallScreen', () {
    setUp(TestWidgetsFlutterBinding.ensureInitialized);

    testWidgets('renders all call components in RTL Arabic with default fake data', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(DriverCallTopBar), findsOneWidget);
      expect(find.byType(DriverCallHeader), findsOneWidget);
      expect(find.byType(DriverCallAvatar), findsOneWidget);
      expect(find.byType(DriverCallAddressCard), findsOneWidget);
      expect(find.byType(DriverCallControlsRow), findsOneWidget);

      expect(find.text('اتصال جاري...'), findsOneWidget);
      expect(find.text('محمد علي'), findsOneWidget);
      expect(find.text('00:24'), findsOneWidget);
      expect(find.text('شارع الخليج العربي ، قطعة 12 ، منزل 45'), findsOneWidget);
      expect(find.text('السلمانية'), findsOneWidget);
      expect(find.text('سماعة'), findsOneWidget);
      expect(find.text('كتم الميكروفون'), findsOneWidget);
      expect(find.text('إنهاء المكالمة'), findsOneWidget);
    });

    testWidgets('renders all call components in LTR English', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const customCall = DriverActiveCallEntity(
        customerName: 'Mohammad Ali',
        addressLine: 'Arabian Gulf St, Block 12, House 45',
        area: 'Salmiya',
        initialDurationSeconds: 45,
      );

      await tester.pumpWidget(
        buildSubject(
          callData: customCall,
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Call in progress...'), findsOneWidget);
      expect(find.text('Mohammad Ali'), findsOneWidget);
      expect(find.text('00:45'), findsOneWidget);
      expect(find.text('Arabian Gulf St, Block 12, House 45'), findsOneWidget);
      expect(find.text('Salmiya'), findsOneWidget);
      expect(find.text('Speaker'), findsOneWidget);
      expect(find.text('Mute Microphone'), findsOneWidget);
      expect(find.text('End Call'), findsOneWidget);
    });

    testWidgets('triggers onDismiss and onEndCall callbacks', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool dismissed = false;
      bool ended = false;

      await tester.pumpWidget(
        buildSubject(
          onDismiss: () => dismissed = true,
          onEndCall: () => ended = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);

      await tester.tap(find.byIcon(Icons.call_end_rounded));
      await tester.pumpAndSettle();
      expect(ended, isTrue);
    });

    testWidgets('timer increments duration when enableTimer is true', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject(enableTimer: true));
      await tester.pump();
      expect(find.text('00:24'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:25'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      expect(find.text('00:27'), findsOneWidget);
    });
  });
}
