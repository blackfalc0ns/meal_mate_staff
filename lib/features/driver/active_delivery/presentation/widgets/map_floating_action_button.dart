import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';

class MapFloatingActionButton extends StatelessWidget {
  const MapFloatingActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Material(
      color: backgroundColor ?? color.surface,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: color.shadow,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.sm + 2),
          child: Icon(
            icon,
            size: Spacing.iconMd,
            color: iconColor ?? color.primary,
          ),
        ),
      ),
    );
  }
}
