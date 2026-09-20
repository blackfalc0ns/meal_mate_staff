import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/screens/driver_support_screen.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_support_contact_section.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_support_faq_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_support_form_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_support_header.dart';

void main() {
  Widget buildSubject({
    Locale locale = const Locale('ar'),
    VoidCallback? onCallTap,
    VoidCallback? onEmailTap,
    ValueChanged<String>? onSubmitMessage,
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
      home: DriverSupportScreen(
        onCallTap: onCallTap,
        onEmailTap: onEmailTap,
        onSubmitMessage: onSubmitMessage,
      ),
    );
  }

  group('DriverSupportScreen Widget Tests', () {
    testWidgets('renders all major sections and components in RTL Arabic', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(DriverSupportHeader), findsOneWidget);
      expect(find.byType(DriverSupportContactSection), findsOneWidget);
      expect(find.byType(DriverSupportFaqCard), findsOneWidget);
      expect(find.byType(DriverSupportFormCard), findsOneWidget);

      expect(find.text('التواصل مع الدعم الفني'), findsOneWidget);
      expect(find.text('نحن هنا لمساعدتك في أي وقت'), findsOneWidget);
      expect(find.text('طرق التواصل'), findsOneWidget);
      expect(find.text('اتصل بنا'), findsOneWidget);
      expect(find.text('800 123 4567'), findsOneWidget);
      expect(find.text('متاح من 8 ص - 10 م'), findsOneWidget);
      expect(find.text('البريد الإلكتروني'), findsOneWidget);
      expect(find.text('support@Resturant.com'), findsOneWidget);
      expect(find.text('نرد خلال 24 ساعة'), findsOneWidget);

      expect(find.text('مواضيع شائعة'), findsOneWidget);
      expect(find.text('مشكلة في تسليم الطلب'), findsOneWidget);
      expect(find.text('مشكلة في التطبيق'), findsOneWidget);
      expect(find.text('الطلبات والمدفوعات'), findsOneWidget);
      expect(find.text('الحساب والملف الشخصي'), findsOneWidget);
      expect(find.text('عرض جميع المواضيع'), findsOneWidget);

      expect(find.text('أرسل لنا رسالة'), findsOneWidget);
      expect(find.text('تصنيف المشكلة'), findsOneWidget);
      expect(find.text('اختر التصنيف'), findsOneWidget);
      expect(find.text('إضافة مرفق (اختياري)'), findsOneWidget);
      expect(find.text('إرسال الرسالة'), findsOneWidget);
    });

    testWidgets('submitting message enables when filled and triggers submit', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      String? submittedText;
      await tester.pumpWidget(
        buildSubject(
          onSubmitMessage: (msg) => submittedText = msg,
        ),
      );
      await tester.pumpAndSettle();

      // Enter message in input
      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);
      await tester.enterText(textFieldFinder, 'لدي مشكلة في إكمال التسليم');
      await tester.pumpAndSettle();

      // Button should be active
      final submitButton = find.text('إرسال الرسالة');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(submittedText, 'لدي مشكلة في إكمال التسليم');
    });

    testWidgets('adding attachment displays attachment file name', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final attachmentBox = find.text('إضافة مرفق (اختياري)');
      expect(attachmentBox, findsOneWidget);

      await tester.tap(attachmentBox);
      await tester.pumpAndSettle();

      expect(find.textContaining('issue_attachment.png'), findsOneWidget);
    });

    testWidgets('renders in English LTR without overflow', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Technical Support'), findsOneWidget);
      expect(find.text('Contact Methods'), findsOneWidget);
      expect(find.text('Call Us'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Common Topics'), findsOneWidget);
      expect(find.text('Send Us a Message'), findsOneWidget);
      expect(find.text('Send Message'), findsOneWidget);
    });
  });
}
