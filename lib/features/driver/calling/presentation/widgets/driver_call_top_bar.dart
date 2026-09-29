import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverCallTopBar extends StatelessWidget {
  const DriverCallTopBar({
    super.key,
    this.onDismiss,
  });

  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: IconButton(
          onPressed: onDismiss ?? () => unawaited(Navigator.of(context).maybePop()),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: Spacing.iconLg,
            color: color.onPrimary,
          ),
          splashRadius: Spacing.lg,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
      ),
    );
  }
}
