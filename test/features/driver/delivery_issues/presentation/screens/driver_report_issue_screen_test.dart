import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/delivery_issue_entity.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/fake_data/delivery_issues_fake_data.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/screens/driver_report_issue_screen.dart';

class _MockImagePickerPlatform extends ImagePickerPlatform {
  ImageSource? lastSource;
  String? returnPath = 'test_photo.jpg';

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    lastSource = source;
    return returnPath != null ? XFile(returnPath!) : null;
  }
}

Widget _buildTestWidget({
  ValueChanged<DeliveryIssueEntity>? onSubmitReport,
  VoidCallback? onRequestReassign,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ar'), Locale('en')],
    locale: const Locale('ar'),
    home: DriverReportIssueScreen(
      initialIssue: DeliveryIssuesFakeData.defaultIssue,
      onSubmitReport: onSubmitReport,
      onRequestReassign: onRequestReassign,
    ),
  );
}

void main() {
  late _MockImagePickerPlatform mockPlatform;

  setUp(() {
    mockPlatform = _MockImagePickerPlatform();
    ImagePickerPlatform.instance = mockPlatform;
  });

  group('DriverReportIssueScreen', () {
    testWidgets('renders all screen sections properly and submits',
        (tester) async {
      DeliveryIssueEntity? submitted;

      await tester.pumpWidget(
        _buildTestWidget(
          onSubmitReport: (issue) => submitted = issue,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('إبلاغ عن مشكلة'), findsOneWidget);
      expect(find.text('ساعدنا في حل المشكلة بسرعة'), findsOneWidget);
      expect(find.text('#BX-1257'), findsOneWidget);
      expect(find.text('اختر سبب المشكلة'), findsOneWidget);
      expect(find.text('تفاصيل إضافية (اختياري)'), findsOneWidget);
      expect(find.text('إرفاق صور (اختياري)'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'ملاحظة اختبارية');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('إرسال للمشرف'));
      await tester.tap(find.text('إرسال للمشرف'));
      await tester.pumpAndSettle();

      expect(submitted, isNotNull);
      expect(submitted!.notes, 'ملاحظة اختبارية');
    });

    testWidgets('tapping add photo shows camera and gallery options, selecting camera picks photo',
        (tester) async {
      mockPlatform.returnPath = 'new_camera_photo.jpg';

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      final addPhotoButton = find.text('إضافة صورة');
      await tester.ensureVisible(addPhotoButton);
      await tester.tap(addPhotoButton);
      await tester.pumpAndSettle();

      // Check bottom sheet options are visible
      expect(find.text('الكاميرا'), findsOneWidget);
      expect(find.text('المعرض'), findsOneWidget);

      // Select Camera
      await tester.tap(find.text('الكاميرا'));
      await tester.pumpAndSettle();

      expect(mockPlatform.lastSource, ImageSource.camera);
    });

    testWidgets('tapping add photo shows options, selecting gallery picks photo',
        (tester) async {
      mockPlatform.returnPath = 'new_gallery_photo.jpg';

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      final addPhotoButton = find.text('إضافة صورة');
      await tester.ensureVisible(addPhotoButton);
      await tester.tap(addPhotoButton);
      await tester.pumpAndSettle();

      // Check bottom sheet options are visible
      expect(find.text('الكاميرا'), findsOneWidget);
      expect(find.text('المعرض'), findsOneWidget);

      // Select Gallery
      await tester.tap(find.text('المعرض'));
      await tester.pumpAndSettle();

      expect(mockPlatform.lastSource, ImageSource.gallery);
    });
  });
}
