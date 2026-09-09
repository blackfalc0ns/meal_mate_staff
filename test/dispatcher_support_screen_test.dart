import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/support/domain/entities/dispatcher_support_issue_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/support/presentation/screens/dispatcher_support_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/support/presentation/widgets/dispatcher_support_area_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/support/presentation/widgets/dispatcher_support_filter_chips.dart';
import 'package:meal_mate_delivery/features/dispatcher/support/presentation/widgets/dispatcher_support_header.dart';
import 'package:meal_mate_delivery/features/dispatcher/support/presentation/widgets/dispatcher_support_info_banner.dart';
import 'package:meal_mate_delivery/features/dispatcher/support/presentation/widgets/dispatcher_support_issue_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/support/presentation/widgets/dispatcher_support_kpi_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/support/presentation/widgets/dispatcher_support_kpi_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/support/presentation/widgets/dispatcher_support_search_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/support/presentation/widgets/dispatcher_support_status_tabs.dart';

void main() {
  Widget buildSubject({
    Locale locale = const Locale('ar'),
    ValueChanged<DispatcherSupportIssueEntity>? onViewDetails,
    ValueChanged<DispatcherSupportIssueEntity>? onAssignAlternativeDriver,
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: DispatcherSupportScreen(
        onViewDetails: onViewDetails,
        onAssignAlternativeDriver: onAssignAlternativeDriver,
      ),
    );
  }

  group('DispatcherSupportScreen Widget Tests', () {
    testWidgets('renders all sections and elements in Arabic locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Header
      expect(find.byType(DispatcherSupportHeader), findsOneWidget);
      expect(find.text('الدعم والمشاكل'), findsOneWidget);
      expect(find.text('متابعة وحل المشاكل الاستثنائية'), findsOneWidget);

      // KPI Bar & Cards
      expect(find.byType(DispatcherSupportKpiBar), findsOneWidget);
      expect(find.byType(DispatcherSupportAreaCard), findsOneWidget);
      expect(find.text('المنطقة الحالية'), findsOneWidget);
      expect(find.text('السالمية'), findsWidgets);
      expect(find.byType(DispatcherSupportKpiCard), findsNWidgets(3));
      expect(find.text('مفقودة'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('جاري الحل'), findsWidgets);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('تم الحل'), findsWidgets);
      expect(find.text('15'), findsOneWidget);

      // Status Tabs
      expect(find.byType(DispatcherSupportStatusTabs), findsOneWidget);
      expect(find.text('مفتوحة (8)'), findsOneWidget);
      expect(find.text('تم الحل (15)'), findsOneWidget);
      expect(find.text('جاري الحل (3)'), findsOneWidget);

      // Search Bar
      expect(find.byType(DispatcherSupportSearchBar), findsOneWidget);
      expect(
        find.text('ابحث برقم البوكس أو اسم السائق أو نوع المشكلة'),
        findsOneWidget,
      );

      // Filter Chips
      expect(find.byType(DispatcherSupportFilterChips), findsOneWidget);
      expect(find.text('كل المناطق'), findsOneWidget);
      expect(find.text('آخر 7 أيام', skipOffstage: false), findsOneWidget);

      // Issue Cards
      expect(find.byType(DispatcherSupportIssueCard), findsWidgets);
      expect(find.text('أحمد السعيد'), findsOneWidget);
      expect(find.text('محمد العازمي'), findsOneWidget);
      expect(find.text('سالم المطيري'), findsOneWidget);
      expect(find.text('#BX-1256'), findsWidgets);
      expect(find.text('عرض التفاصيل'), findsWidgets);
      expect(find.text('تعيين سائق بديل'), findsWidgets);

      // Info Banner
      expect(find.byType(DispatcherSupportInfoBanner), findsOneWidget);
      expect(
        find.text(
          'يمكنك التواصل مع السائق مباشرة من تفاصيل المشكلة لحلها بسرعة',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders all sections in English locale', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Support & Issues'), findsOneWidget);
      expect(
        find.text('Monitor and resolve exceptional issues'),
        findsOneWidget,
      );
      expect(find.text('Current Area'), findsOneWidget);
      expect(find.text('Missing'), findsOneWidget);
      expect(find.text('Open (8)'), findsOneWidget);
      expect(find.text('Resolved (15)'), findsOneWidget);
      expect(find.text('In Progress (3)'), findsOneWidget);
      expect(find.text('All Areas'), findsOneWidget);
      expect(find.text('Last 7 Days', skipOffstage: false), findsOneWidget);
      expect(find.text('View Details'), findsWidgets);
      expect(find.text('Assign Alternative Driver'), findsWidgets);
    });

    testWidgets('switching status tab filters issues list', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Initially on Open tab (3 open issues)
      expect(find.text('أحمد السعيد'), findsOneWidget);
      expect(find.text('عبدالله العنزي'), findsNothing);

      // Tap on In Progress tab
      await tester.tap(find.text('جاري الحل (3)'));
      await tester.pumpAndSettle();

      // Now shows عبدالله العنزي
      expect(find.text('عبدالله العنزي'), findsOneWidget);
      expect(find.text('أحمد السعيد'), findsNothing);
    });

    testWidgets('tapping view details triggers callback', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      DispatcherSupportIssueEntity? tappedIssue;

      await tester.pumpWidget(
        buildSubject(
          onViewDetails: (issue) {
            tappedIssue = issue;
          },
        ),
      );
      await tester.pumpAndSettle();

      final viewDetailsButtons = find.text('عرض التفاصيل');
      expect(viewDetailsButtons, findsWidgets);

      await tester.tap(viewDetailsButtons.first);
      await tester.pumpAndSettle();

      expect(tappedIssue, isNotNull);
      expect(tappedIssue!.id, 'ISS-001');
    });

    testWidgets('renders without overflow on narrow viewport (360x720)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DispatcherSupportScreen), findsOneWidget);
    });
  });
}
