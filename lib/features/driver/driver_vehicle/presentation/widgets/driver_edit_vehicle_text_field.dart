import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverEditVehicleTextField extends StatelessWidget {
  const DriverEditVehicleTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hintText,
    this.icon,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final IconData? icon;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: getRegularStyle(
            color: color.onSurfaceVariant,
            fontSize: FontSize.size11,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          style: getMediumStyle(
            color: color.onSurface,
            fontSize: FontSize.size13,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: getRegularStyle(
              color: color.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: FontSize.size12,
            ),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    size: Spacing.iconSm + 2,
                    color: color.primary,
                  )
                : null,
            filled: true,
            fillColor: color.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.sm + 2,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Spacing.cardRadius),
              borderSide: BorderSide(
                color: color.outline,
                width: Spacing.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Spacing.cardRadius),
              borderSide: BorderSide(
                color: color.primary,
                width: Spacing.border * 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
