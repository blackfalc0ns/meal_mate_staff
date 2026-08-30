import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/features/auth/presentation/widgets/registration_role_card.dart';

void main() {
  testWidgets('places action column before text and image after text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: RegistrationRoleCard(
                title: 'Driver',
                subtitle: 'Receive orders',
                imageAsset: AppAssets.registrationDriverRole,
                badgeText: 'Default',
                isSelected: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );

    final titleLeft = tester.getTopLeft(find.text('Driver')).dx;
    final imageLeft = tester
        .getTopLeft(
          find.byWidgetPredicate(
            (widget) =>
                widget is Image &&
                widget.image is AssetImage &&
                (widget.image as AssetImage).assetName ==
                    AppAssets.registrationDriverRole,
          ),
        )
        .dx;
    final actionLeft = tester
        .getTopLeft(find.byIcon(Icons.chevron_right_rounded))
        .dx;

    expect(actionLeft, lessThan(titleLeft));
    expect(imageLeft, greaterThan(titleLeft));
  });
}
