import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/widget/shimmer_widget.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_summary_shimmer.dart';

void main() {
  group('AssignBoxShimmer', () {
    testWidgets(
      'renders all structural sections using ShimmerWidget without CircularProgressIndicator',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: AssignBoxShimmer())),
        );

        expect(find.byType(AssignBoxShimmer), findsOneWidget);
        expect(find.byType(ShimmerWidget), findsWidgets);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Verify sections: box card block, recommended driver block, 4 candidate blocks, bottom actions
        expect(
          find.byKey(const Key('assign_box_shimmer_box_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('assign_box_shimmer_recommended_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('assign_box_shimmer_candidates_header')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('assign_box_shimmer_candidate_row_0')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('assign_box_shimmer_candidate_row_1')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('assign_box_shimmer_candidate_row_2')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('assign_box_shimmer_candidate_row_3')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('assign_box_shimmer_bottom_actions')),
          findsOneWidget,
        );
      },
    );

    testWidgets('renders safely on narrow 360px viewport without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AssignBoxShimmer())),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('AssignBoxSummaryShimmer', () {
    testWidgets(
      'renders modal summary sections with identity, customer/address, and at least 3 meal rows',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: AssignBoxSummaryShimmer())),
        );

        expect(find.byType(AssignBoxSummaryShimmer), findsOneWidget);
        expect(find.byType(ShimmerWidget), findsWidgets);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        expect(
          find.byKey(const Key('assign_box_summary_shimmer_identity')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('assign_box_summary_shimmer_customer')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('assign_box_summary_shimmer_meal_0')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('assign_box_summary_shimmer_meal_1')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('assign_box_summary_shimmer_meal_2')),
          findsOneWidget,
        );
      },
    );
  });
}
