import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class AuthHelpCard extends StatelessWidget {
  const AuthHelpCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 12, 10),
      decoration: BoxDecoration(
        color: color.primaryContainer,

        borderRadius: BorderRadius.circular(Spacing.radiusSm),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color.onPrimary, size: Spacing.iconLg),
          ),
          const SizedBox(width: Spacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: getMediumStyle(
                    color: color.primary,
                    fontSize: FontSize.size11,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  subtitle,
                  style: getMediumStyle(
                    color: color.onSecondary,
                    fontSize: FontSize.size10,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
