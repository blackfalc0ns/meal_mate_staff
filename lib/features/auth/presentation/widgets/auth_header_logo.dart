import 'package:flutter/material.dart';

import '../../../../core/constants/assets.dart';

class AuthHeaderLogo extends StatelessWidget {
  const AuthHeaderLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(AssetsFake.authLogo, height: 112, fit: BoxFit.contain);
  }
}
