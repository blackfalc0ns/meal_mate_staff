import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class RegisterReviewField extends StatelessWidget {
  const RegisterReviewField({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: getMediumStyle(
            color: color.onSurfaceVariant,
            fontSize: FontSize.size10,
            height: 1.4,
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: getSemiBoldStyle(
            color: color.onSurface,
            fontSize: FontSize.size10,
            height: 1.3,
          ),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
