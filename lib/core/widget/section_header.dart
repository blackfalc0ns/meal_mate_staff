import 'package:flutter/material.dart';

import '../../config/theme/colors.dart';
import '../../config/theme/font_manager.dart';
import '../../config/theme/styles_manager.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: getSemiBoldStyle(
                  color: AppColors.textPrimary,
                  fontSize: FontSize.size18,
                  height: 1.4,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: getRegularStyle(
                    color: AppColors.textSecondary,
                    fontSize: FontSize.size12,
                    height: 1.5,
                  ),
                ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
