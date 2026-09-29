import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverSupportTicketsSearchField extends StatelessWidget {
  const DriverSupportTicketsSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return SizedBox(
      height: Spacing.inputHeight,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: getRegularStyle(
          fontSize: FontSize.size14,
          color: color.onSurface,
        ),
        decoration: InputDecoration(
          hintText: locale.driverSupportTicketsSearchHint,
          hintStyle: getRegularStyle(
            fontSize: FontSize.size13,
            color: color.onSurfaceVariant,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF878685),
            size: Spacing.iconMd,
          ),
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Spacing.inputRadius),
            borderSide: const BorderSide(
              color: Color(0xFFE5E2EC),
              width: Spacing.border,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Spacing.inputRadius),
            borderSide: const BorderSide(
              color: Color(0xFF603BC1),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
