import 'package:flutter/material.dart';

import '../../../../../core/constants/assets.dart';

class DriverBoxesHeaderLogo extends StatelessWidget {
  const DriverBoxesHeaderLogo({super.key});

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
