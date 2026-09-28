import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';

class DriverStartWorkHeaderLogo extends StatelessWidget {
  const DriverStartWorkHeaderLogo({super.key});

  static const double _logoHeight = 29;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        AppAssets.authHeaderLogo,
        height: _logoHeight,
        fit: BoxFit.contain,
      ),
    );
  }
}
