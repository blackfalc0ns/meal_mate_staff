import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_issue_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/support/dispatcher_support_issue_card.dart';

Widget _wrapWithApp(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('ar')],
    home: Scaffold(body: child),
  );
}

void main() {
  group('DispatcherSupportIssueCard', () {
    testWidgets('renders canonical entity values without crashing', (
      tester,
    ) async {
      const issue = DispatcherSupportIssueEntity(
        id: 'iss-99',
        boxCode: 'BOX-888',
        title: 'Package damaged',
        issueCategory: 'DamagedBox',
        categoryLabel: 'Damaged Box',
        categoryColor: 0xFFFF5722,
        timeAgo: '12m ago',
        driverName: 'Fahad Al-Otaibi',
        area: 'Al Olaya',
        vehicleInfo: 'Toyota Camry • White',
        status: DispatcherSupportStatus.open,
      );

      bool viewDetailsTapped = false;
      bool assignTapped = false;

      await tester.pumpWidget(
        _wrapWithApp(
          DispatcherSupportIssueCard(
            issue: issue,
            onViewDetails: () => viewDetailsTapped = true,
            onAssignAlternativeDriver: () => assignTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('#BOX-888'), findsOneWidget);
      expect(find.text('Damaged Box'), findsOneWidget);
      expect(find.text('12m ago'), findsOneWidget);
      expect(find.text('Fahad Al-Otaibi'), findsOneWidget);
      expect(find.text('Al Olaya'), findsOneWidget);
      expect(find.text('Toyota Camry • White'), findsOneWidget);

      await tester.tap(find.text('View Details'));
      expect(viewDetailsTapped, isTrue);

      await tester.tap(find.text('Assign Alternative Driver'));
      expect(assignTapped, isTrue);
    });

    testWidgets('renders properly on narrow viewport 360x720 in RTL Arabic', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const issue = DispatcherSupportIssueEntity(
        id: 'iss-101',
        boxCode: 'BX-12345',
        title: 'تأخير شديد في تسليم الطلب للعميل',
        issueCategory: 'SevereDelay',
        categoryLabel: 'تأخير شديد',
        categoryColor: 0xFFE53935,
        timeAgo: 'منذ 25 دقيقة',
        driverName: 'عبدالرحمن محمد الشمري',
        area: 'حي الملقا - الرياض',
        vehicleInfo: 'هيونداي النترا • فضي',
        status: DispatcherSupportStatus.open,
      );

      await tester.pumpWidget(
        _wrapWithApp(
          const DispatcherSupportIssueCard(issue: issue),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('#BX-12345'), findsOneWidget);
      expect(find.text('تأخير شديد'), findsOneWidget);
      expect(find.text('منذ 25 دقيقة'), findsOneWidget);
      expect(find.text('عبدالرحمن محمد الشمري'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
