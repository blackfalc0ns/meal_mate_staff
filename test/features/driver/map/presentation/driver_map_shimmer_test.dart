import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/widget/shimmer_widget.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_shimmer.dart';

void main() {
  testWidgets('DriverMapShimmer renders shimmer boxes and neutral background', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DriverMapShimmer(),
        ),
      ),
    );

    // Verify multiple ShimmerWidgets are present
    expect(find.byType(ShimmerWidget), findsWidgets);
    expect(find.byIcon(Icons.map_outlined), findsOneWidget);

    // Pump animation frame
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('DriverMapNavigationShimmer renders compact placeholder', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DriverMapNavigationShimmer(),
        ),
      ),
    );

    expect(find.byType(ShimmerWidget), findsWidgets);
  });
}
