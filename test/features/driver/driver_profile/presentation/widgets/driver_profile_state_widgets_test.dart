import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/widget/shimmer_widget.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/entities/driver_profile_assignment_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/entities/driver_profile_document_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_assignment_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_documents_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_shimmer.dart';

Widget testApp(Widget child) {
  return MaterialApp(
    locale: const Locale('ar'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ar'), Locale('en')],
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('DriverProfileShimmer', () {
    testWidgets('initial skeleton uses ShimmerWidget and no spinner',
        (tester) async {
      await tester.pumpWidget(testApp(const DriverProfileShimmer()));
      expect(find.byType(ShimmerWidget), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('DriverProfileDocumentsCard', () {
    testWidgets('empty documents render an explicit empty state',
        (tester) async {
      await tester.pumpWidget(
        testApp(const DriverProfileDocumentsCard(documents: [])),
      );
      expect(
        find.byKey(const Key('driver_profile_documents_empty')),
        findsOneWidget,
      );
    });

    testWidgets('document color is selected by status code, not statusText',
        (tester) async {
      const expiredDoc = DriverProfileDocumentEntity(
        documentId: 'd-1',
        documentType: 'DrivingLicense',
        documentTitle: 'رخصة القيادة',
        status: 'Expired',
        statusText: 'نص مخصص غير قياسي',
        expiryDate: '2024-01-01',
      );

      await tester.pumpWidget(
        testApp(const DriverProfileDocumentsCard(documents: [expiredDoc])),
      );

      expect(
        find.byKey(const Key('driver_document_status_expired')),
        findsOneWidget,
      );
      expect(find.text('رخصة القيادة'), findsOneWidget);
      expect(find.text('نص مخصص غير قياسي'), findsOneWidget);
    });
  });

  group('DriverProfileAssignmentCard', () {
    testWidgets('renders restaurant and branch names when present',
        (tester) async {
      const assignment = DriverProfileAssignmentEntity(
        restaurantName: 'مطعم البركة',
        branchName: 'فرع المعادي',
      );

      await tester.pumpWidget(
        testApp(const DriverProfileAssignmentCard(assignment: assignment)),
      );

      expect(find.text('مطعم البركة'), findsOneWidget);
      expect(find.text('فرع المعادي'), findsOneWidget);
    });

    testWidgets('hides completely when assignment is null or names are empty',
        (tester) async {
      await tester.pumpWidget(
        testApp(const DriverProfileAssignmentCard(assignment: null)),
      );

      expect(find.byType(DriverProfileAssignmentCard), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.text('مطعم البركة'), findsNothing);
    });
  });
}
