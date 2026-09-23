import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/empty_state_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/widget/shimmer_widget.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_date_preset.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/dispatcher_operations_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/operations_cards_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/operations_date_filter_sheet.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/operations_empty_state.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/operations_search_filter_bar.dart';

Widget createLocalizedTestWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ar'), Locale('en')],
    locale: const Locale('ar'),
    home: Scaffold(body: child),
  );
}

void main() {
  group('OperationsDateFilterSheet', () {
    testWidgets('renders all 5 presets in Arabic and fires onPresetSelected', (
      tester,
    ) async {
      OperationsDatePreset? selected;

      await tester.pumpWidget(
        createLocalizedTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  unawaited(
                    OperationsDateFilterSheet.show(
                      context,
                      selectedPreset: OperationsDatePreset.last7Days,
                      initialCustomFrom: null,
                      initialCustomTo: null,
                      onPresetSelected: (preset) => selected = preset,
                      onCustomRangeSelected: (fromUtc, toUtc) {},
                    ),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('اليوم'), findsOneWidget);
      expect(find.text('آخر 7 أيام'), findsOneWidget);
      expect(find.text('آخر 30 يوماً'), findsOneWidget);
      expect(find.text('الكل'), findsOneWidget);

      await tester.tap(find.text('اليوم'));
      await tester.pumpAndSettle();

      expect(selected, OperationsDatePreset.today);
    });
  });

  group('Shimmers & EmptyState', () {
    testWidgets(
      'DispatcherOperationsShimmer uses ShimmerWidget and no CircularProgressIndicator',
      (tester) async {
        await tester.pumpWidget(
          createLocalizedTestWidget(const DispatcherOperationsShimmer()),
        );

        expect(find.byType(ShimmerWidget), findsWidgets);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets('OperationsCardsShimmer renders shimmer widgets', (
      tester,
    ) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(const OperationsCardsShimmer()),
      );

      expect(find.byType(ShimmerWidget), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets(
      'OperationsEmptyState renders EmptyStateWidget with retry action',
      (tester) async {
        var retried = false;
        await tester.pumpWidget(
          createLocalizedTestWidget(
            OperationsEmptyState(onRetry: () => retried = true),
          ),
        );

        expect(find.byType(EmptyStateWidget), findsOneWidget);
        await tester.tap(find.byType(ElevatedButton));
        expect(retried, isTrue);
      },
    );
  });

  group('OperationsSearchFilterBar', () {
    testWidgets('respects isEnabled flag and fires callbacks', (tester) async {
      final controller = TextEditingController(text: 'test');
      var dateTapped = false;

      await tester.pumpWidget(
        createLocalizedTestWidget(
          OperationsSearchFilterBar(
            searchController: controller,
            isEnabled: false,
            dateLabel: 'آخر 7 أيام',
            onDateFilterTap: () => dateTapped = true,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);

      await tester.tap(find.text('آخر 7 أيام'));
      expect(dateTapped, isFalse); // disabled!
    });
  });
}
