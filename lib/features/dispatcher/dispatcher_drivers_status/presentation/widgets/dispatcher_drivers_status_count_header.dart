import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriversStatusCountHeader extends StatelessWidget {
  const DispatcherDriversStatusCountHeader({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Text(
        locale.driversStatusCount(count),
        style: getSemiBoldStyle(
          fontFamily: FontConstant.alexandria,
          fontSize: FontSize.size14,
          color: color.onSurface,
        ),
      ),
    );
  }
}
