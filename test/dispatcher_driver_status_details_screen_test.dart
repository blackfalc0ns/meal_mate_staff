import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/services/driver_contact_launcher.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/data_source/dispatcher_driver_details_fake_data.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/screens/dispatcher_driver_status_details_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_driver_details_app_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_driver_details_contact_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_driver_details_documents_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_driver_details_location_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_driver_details_metrics_row.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_driver_details_performance_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_driver_details_profile_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_driver_details_vehicle_card.dart';

class _FakeContactLauncher implements DriverContactLauncher {
  bool calledPhone = false;
  bool calledWhatsApp = false;

  @override
  Uri? phoneUri(String? phone) => phone != null ? Uri.parse('tel:$phone') : null;

  @override
  Uri? smsUri(String? phone) => phone != null ? Uri.parse('sms:$phone') : null;

  @override
  Uri? whatsAppUri(String? phone) =>
      phone != null ? Uri.parse('https://wa.me/$phone') : null;

  @override
  Future<bool> launchPhone(String? phoneNumber) async {
    calledPhone = true;
    return true;
  }

  @override
  Future<bool> launchSms(String? phoneNumber) async {
    return true;
  }

  @override
  Future<bool> launchWhatsApp(String? phoneNumber) async {
    calledWhatsApp = true;
    return true;
  }
}

void main() {
  Widget buildTestableWidget({
    Locale locale = const Locale('ar'),
    DriverContactLauncher? contactLauncher,
    VoidCallback? onBack,
    VoidCallback? onOpenMap,
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      home: DispatcherDriverStatusDetailsScreen(
        driverId: '4a6f235e-c04d-45db-9c3f-c39775c96da1',
        initialDetails: DispatcherDriverDetailsFakeData.getSampleDriverDetails(),
        contactLauncher: contactLauncher ?? _FakeContactLauncher(),
        onBack: onBack,
        onOpenMap: onOpenMap,
      ),
    );
  }

  testWidgets('renders DispatcherDriverStatusDetailsScreen with all sections',
      (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify AppBar
    expect(find.byType(DispatcherDriverDetailsAppBar), findsOneWidget);
    expect(find.text('تفاصيل السائق'), findsOneWidget);

    // Verify Profile Card
    expect(find.byType(DispatcherDriverDetailsProfileCard), findsOneWidget);
    expect(find.text('أحمد محمد'), findsOneWidget);
    expect(find.text('#KD-4582'), findsOneWidget);
    expect(find.text('4.8'), findsWidgets);
    expect(find.text('(128 تقييم)'), findsOneWidget);
    expect(find.text('متصل الآن'), findsOneWidget);
    expect(find.text('السائق متاح لإستقبال الطلبات'), findsOneWidget);

    // Verify Metrics Row
    expect(find.byType(DispatcherDriverDetailsMetricsRow), findsOneWidget);
    expect(find.text('إجمالي الطلبات'), findsWidgets);
    expect(find.text('وقت العمل اليوم'), findsOneWidget);
    expect(find.text('المسافة اليوم'), findsOneWidget);
    expect(find.text('الطلبات النشطة'), findsOneWidget);

    // Verify Contact Card
    expect(find.byType(DispatcherDriverDetailsContactCard), findsOneWidget);
    expect(find.text('+965 5012 3456'), findsOneWidget);
    expect(find.text('اتصال عبر الواتساب أو الجوال'), findsOneWidget);

    // Verify Vehicle Card
    expect(find.byType(DispatcherDriverDetailsVehicleCard), findsOneWidget);
    expect(find.text('تويوتا كورولا'), findsOneWidget);
    expect(find.text('أبيض'), findsOneWidget);
    expect(find.text('#KU-7319'), findsOneWidget);

    // Verify Location Card
    expect(find.byType(DispatcherDriverDetailsLocationCard), findsOneWidget);
    expect(find.text('المنطقة السالمية'), findsOneWidget);
    expect(find.text('عرض على الخريطة'), findsOneWidget);

    // Verify Performance Card
    expect(find.byType(DispatcherDriverDetailsPerformanceCard), findsOneWidget);
    expect(find.text('الأداء والتقييم'), findsOneWidget);
    expect(find.text('98%'), findsOneWidget);
    expect(find.text('معدل الالتزام'), findsOneWidget);
    expect(find.text('مخالفات'), findsOneWidget);

    // Verify Documents Card
    expect(find.byType(DispatcherDriverDetailsDocumentsCard), findsOneWidget);
    expect(find.text('المستندات'), findsOneWidget);
    expect(find.text('رخصة القيادة'), findsOneWidget);
    expect(find.text('استمارة المركبة'), findsOneWidget);
    expect(find.text('التأمين'), findsOneWidget);
  });

  testWidgets('toggle switch changes availability text', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.text('السائق متاح لإستقبال الطلبات'), findsOneWidget);

    // Find and tap switch
    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(find.text('السائق غير متاح حالياً'), findsOneWidget);
  });

  testWidgets('calls contact launcher on phone and chat buttons tap',
      (tester) async {
    final launcher = _FakeContactLauncher();
    await tester.pumpWidget(buildTestableWidget(contactLauncher: launcher));
    await tester.pumpAndSettle();

    // Tap call button
    final callButton = find.byIcon(Icons.phone_rounded);
    expect(callButton, findsOneWidget);
    await tester.tap(callButton);
    await tester.pumpAndSettle();
    expect(launcher.calledPhone, isTrue);

    // Tap chat button
    final chatButton = find.byIcon(Icons.chat_bubble_outline_rounded);
    expect(chatButton, findsOneWidget);
    await tester.tap(chatButton);
    await tester.pumpAndSettle();
    expect(launcher.calledWhatsApp, isTrue);
  });
}
