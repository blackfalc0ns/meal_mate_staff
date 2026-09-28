import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';

class DriverStartWorkIllustrationCard extends StatelessWidget {
  const DriverStartWorkIllustrationCard({super.key});

  static const double _cardHeight = 160;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Spacing.radiusLg),
      child: Image.asset(
        AppAssets.driverStartWorkIllustration,
        height: _cardHeight,
        width: double.infinity,
        fit: BoxFit.contain,
      ),
    );
  }
}
