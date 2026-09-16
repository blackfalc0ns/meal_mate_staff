import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriversVerticalDivider extends StatelessWidget {
  const DispatcherDriversVerticalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      height: Spacing.xxl,
      width: Spacing.border,
      color: color.outlineVariant.withValues(alpha: Spacing.hairline),
      margin: const EdgeInsets.symmetric(horizontal: Spacing.border + Spacing.border),
    );
  }
}
