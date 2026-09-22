import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/widget/shimmer_widget.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_date_preset.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_response_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/support/dispatcher_support_date_filter_sheet.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/support/dispatcher_support_empty_state.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/support/dispatcher_support_filter_chips.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/support/dispatcher_support_pagination_footer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/support/dispatcher_support_shimmer.dart';

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
  group('DispatcherSupportShimmer', () {
    testWidgets('renders structural skeleton using ShimmerWidget', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapWithApp(const DispatcherSupportShimmer()));
      expect(find.byType(ShimmerWidget), findsWidgets);
    });
  });

  group('DispatcherSupportEmptyState', () {
    testWidgets('renders localized copy and retry button in Arabic', (
      tester,
    ) async {
      bool retried = false;
      await tester.pumpWidget(
        _wrapWithApp(
          DispatcherSupportEmptyState(onRetry: () => retried = true),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('لا توجد مشاكل'), findsOneWidget);
      expect(
        find.text('لا توجد مشاكل دعم تطابق معايير البحث المحددة.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.support_agent_rounded), findsOneWidget);

      await tester.tap(find.text('إعادة المحاولة'));
      expect(retried, isTrue);
    });
  });

  group('DispatcherSupportFilterChips', () {
    testWidgets(
      'renders backend area chips with counts and triggers selection',
      (tester) async {
        String? selected;
        const chips = [
          DispatcherSupportAreaChipEntity(
            areaKey: 'all',
            displayName: 'All Areas',
            count: 15,
          ),
          DispatcherSupportAreaChipEntity(
            areaKey: 'malqa',
            displayName: 'Al Malqa',
            count: 6,
          ),
        ];

        await tester.pumpWidget(
          _wrapWithApp(
            DispatcherSupportFilterChips(
              areaChips: chips,
              selectedArea: 'malqa',
              onAreaSelected: (key) => selected = key,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('All Areas (15)'), findsOneWidget);
        expect(find.text('Al Malqa (6)'), findsOneWidget);

        await tester.tap(find.text('All Areas (15)'));
        expect(selected, '');
      },
    );
  });

  group('DispatcherSupportDateFilterSheet', () {
    testWidgets('displays all 5 date presets and selects preset', (
      tester,
    ) async {
      DispatcherSupportDatePreset? picked;
      await tester.pumpWidget(
        _wrapWithApp(
          DispatcherSupportDateFilterSheet(
            selectedPreset: DispatcherSupportDatePreset.last7Days,
            onPresetSelected: (preset) => picked = preset,
            onCustomRangeSelected: (_, _) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('Last 7 Days'), findsOneWidget);
      expect(find.text('Last 30 Days'), findsOneWidget);
      expect(find.text('Custom Range'), findsOneWidget);

      await tester.tap(find.text('Today'));
      expect(picked, DispatcherSupportDatePreset.today);
    });
  });

  group('DispatcherSupportPaginationFooter', () {
    testWidgets('renders loading state when isLoading is true', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(const DispatcherSupportPaginationFooter(isLoading: true)),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading more...'), findsOneWidget);
    });

    testWidgets(
      'renders error state and triggers retry when hasError is true',
      (tester) async {
        bool retried = false;
        await tester.pumpWidget(
          _wrapWithApp(
            DispatcherSupportPaginationFooter(
              isLoading: false,
              hasError: true,
              onRetry: () => retried = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Failed to load more. Tap to retry.'), findsOneWidget);
        await tester.tap(find.text('Failed to load more. Tap to retry.'));
        expect(retried, isTrue);
      },
    );
  });
}
