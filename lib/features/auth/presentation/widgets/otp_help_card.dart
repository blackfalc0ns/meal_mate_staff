import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class OtpHelpCard extends StatelessWidget {
  const OtpHelpCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Material(
      color: color.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        side: BorderSide(color: color.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 10),
          child: Row(
            children: [
              Icon(
                Icons.chevron_left_rounded,
                color: color.primary,
                size: Spacing.iconMd,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: getMediumStyle(
                        color: color.primary,
                        fontSize: FontSize.size12,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      subtitle,
                      style: getRegularStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.base),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.primary,
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Icon(icon, color: color.onPrimary, size: Spacing.iconLg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
