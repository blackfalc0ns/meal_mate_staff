import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class AuthInputField extends StatelessWidget {
  const AuthInputField({
    super.key,
    required this.hint,
    required this.icon,
    required this.label,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.countryCode,
    this.showCountryPicker = false,
  });

  final String hint;
  final IconData icon;
  final String label;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? countryCode;
  final bool showCountryPicker;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surface,
        border: Border.all(color: color.outline),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        height: 62,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(top: 11, start: 32),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color.primary, size: Spacing.iconSm),

                    const SizedBox(width: Spacing.xs),

                    Text(
                      label,
                      style: getRegularStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size10,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showCountryPicker)
              PositionedDirectional(
                top: 26,
                bottom: 14,
                start: 138,
                child: Container(width: 1, color: color.outline),
              ),
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: showCountryPicker ? 154 : 32,
                top: 20,
                end: suffixIcon == null ? 24 : 82,
              ),
              child: TextFormField(
                keyboardType: keyboardType,
                obscureText: obscureText,
                textAlign: TextAlign.start,
                style: getRegularStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size12,
                  height: 1.2,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  hintText: hint,
                  hintStyle: getRegularStyle(
                    color: color.onSurfaceVariant,
                    fontSize: FontSize.size12,
                    height: 1.2,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (showCountryPicker && countryCode != null)
              PositionedDirectional(
                top: 32,
                start: 32,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      countryCode!,
                      style: getBoldStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size12,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    const _KuwaitFlag(),
                    //  const SizedBox(width: Spacing.base),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: color.onSurfaceVariant,
                      size: 18,
                    ),
                  ],
                ),
              ),
            if (suffixIcon != null)
              PositionedDirectional(
                top: 0,
                bottom: 0,
                end: 20,
                child: Center(child: suffixIcon),
              ),
          ],
        ),
      ),
    );
  }
}

class _KuwaitFlag extends StatelessWidget {
  const _KuwaitFlag();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 16,
        height: 11,
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: const [
                  Expanded(child: ColoredBox(color: Color(0xFF007A3D))),
                  Expanded(child: ColoredBox(color: Colors.white)),
                  Expanded(child: ColoredBox(color: Color(0xFFCE1126))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
