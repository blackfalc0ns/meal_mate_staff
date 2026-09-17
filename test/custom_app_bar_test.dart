import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/widget/custom_app_bar.dart';

void main() {
  group('CustomAppBar Flexible Title Tests', () {
    testWidgets('renders plain text title when title is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              title: 'عنوان عادي',
            ),
          ),
        ),
      );

      expect(find.text('عنوان عادي'), findsOneWidget);
    });

    testWidgets('renders custom widget / image in titleWidget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              titleWidget: Icon(Icons.star, key: Key('custom_title_icon')),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('custom_title_icon')), findsOneWidget);
    });

    testWidgets(
        'renders both titleWidget (logo) and title (text) and subtitle together',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              titleWidget: Icon(Icons.directions_car, key: Key('logo_icon')),
              title: 'بيانات المركبة',
              subtitle: 'عرض وتحديث بيانات وسيلة التوصيل',
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('logo_icon')), findsOneWidget);
      expect(find.text('بيانات المركبة'), findsOneWidget);
      expect(find.text('عرض وتحديث بيانات وسيلة التوصيل'), findsOneWidget);
    });

    testWidgets('CustomAppBar.logo factory works with title and subtitle', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar.logo(
              title: 'عنوان الشعار',
              subtitle: 'وصف إضافي',
            ),
          ),
        ),
      );

      expect(find.text('عنوان الشعار'), findsOneWidget);
      expect(find.text('وصف إضافي'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
