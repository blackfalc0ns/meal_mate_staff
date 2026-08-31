import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class RegistrationNoteCard extends StatelessWidget {
  const RegistrationNoteCard({
    super.key,
    this.title,
    required this.text,
    this.icon,
  });

  final String? title;
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.primaryContainer,
        borderRadius: BorderRadius.circular(Spacing.registrationRadius),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: color.primary, size: Spacing.lg),
                const SizedBox(width: Spacing.sm),
              ],
              Flexible(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null) ...[
                      Text(
                        title!,
                        style: getBoldStyle(
                          color: color.primary,
                          fontSize: FontSize.size10,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                    ],
                    Text(
                      text,
                      style: getMediumStyle(
                        color: color.primary,
                        fontSize: FontSize.size10,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
