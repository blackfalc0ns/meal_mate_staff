import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Row(
      children: [
        Expanded(child: Divider(color: color.outline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
          child: Text(
            text,
            style: getRegularStyle(
              color: color.primary,
              fontSize: FontSize.size11,
              height: 1.4,
            ),
          ),
        ),
        Expanded(child: Divider(color: color.outline)),
      ],
    );
  }
}
