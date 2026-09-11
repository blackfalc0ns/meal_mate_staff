import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class RegistrationInputField extends StatelessWidget {
  const RegistrationInputField({
    super.key,
    required this.label,
    required this.hint,
    this.prefix,
    this.prefixIcon,
    this.suffixIcon,
    this.isPicker = false,
    this.showPickerArrow,
    this.onTap,
    this.controller,
    this.initialValue,
    this.onChanged,
  });

  final String label;
  final String hint;
  final String? prefix;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPicker;
  final bool? showPickerArrow;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return SizedBox(
      height: Spacing.registrationFieldHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: getBoldStyle(
              color: color.onSurface,
              fontSize: FontSize.size12,
              height: 1.2,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: isPicker ? onTap : null,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    height: Spacing.registrationFieldInputHeight,
                    child: TextFormField(
                      controller: controller,
                      initialValue: controller == null ? initialValue : null,
                      readOnly: isPicker,
                      onTap: onTap,
                      onChanged: onChanged,
                      textAlign: TextAlign.start,
                      style: getMediumStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size12,
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: getMediumStyle(
                          color: color.onSurfaceVariant,
                          fontSize: FontSize.size12,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Spacing.md,
                          vertical: Spacing.sm,
                        ),
                        prefixIconConstraints: prefixIcon != null
                            ? const BoxConstraints(
                                minWidth: 38,
                                minHeight: 38,
                              )
                            : null,
                        prefixIcon: prefixIcon == null
                            ? null
                            : Icon(
                                prefixIcon,
                                color: color.onSurface,
                                size: 20,
                              ),
                        suffixIcon: suffixIcon != null
                            ? Icon(
                                suffixIcon,
                                color: color.onSurfaceVariant,
                                size: Spacing.iconMd,
                              )
                            : (isPicker && (showPickerArrow ?? (prefixIcon == null)))
                            ? Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: color.onSurfaceVariant,
                                size: Spacing.iconMd,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              if (prefix != null) ...[
                const SizedBox(width: Spacing.md),
                SizedBox(
                  width: Spacing.xxxl * 2,
                  height: Spacing.registrationFieldInputHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: color.surface,
                      border: Border.all(color: color.outline),
                      borderRadius: BorderRadius.circular(
                        Spacing.registrationRadius,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        prefix!,
                        style: getBoldStyle(
                          color: color.onSurface,
                          fontSize: FontSize.size13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
