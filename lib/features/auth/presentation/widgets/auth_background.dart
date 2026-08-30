import 'package:flutter/material.dart';

import '../../../../core/constants/assets.dart';
import '../../../../core/extensions/extensions.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: color.surface),
        Image.asset(AppAssets.authLoginBackground, fit: BoxFit.cover),
        child,
      ],
    );
  }
}
