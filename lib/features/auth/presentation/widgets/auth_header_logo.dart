import 'package:flutter/material.dart';

import '../../../../core/constants/assets.dart';

class AuthHeaderLogo extends StatelessWidget {
  const AuthHeaderLogo({
    super.key,
    this.asset = AppAssets.authLogo,
    this.height = 112,
  });

  const AuthHeaderLogo.compact({super.key})
    : asset = AppAssets.authHeaderLogo,
      height = 29;

  final String asset;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(asset, height: height, fit: BoxFit.contain);
  }
}
