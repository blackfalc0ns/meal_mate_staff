import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/widget/shimmer_widget.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_shimmer.dart';

void main() {
  testWidgets(
    'BoxTrackingShimmer renders all expected sections with keys and without CircularProgressIndicator',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: BoxTrackingShimmer()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ShimmerWidget), findsWidgets);

      expect(
        find.byKey(const Key('box_tracking_shimmer_header')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('box_tracking_shimmer_timeline')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('box_tracking_shimmer_step_0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('box_tracking_shimmer_step_1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('box_tracking_shimmer_step_2')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('box_tracking_shimmer_step_3')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('box_tracking_shimmer_driver')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('box_tracking_shimmer_details')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('box_tracking_shimmer_report_button')),
        findsOneWidget,
      );
    },
  );
}
