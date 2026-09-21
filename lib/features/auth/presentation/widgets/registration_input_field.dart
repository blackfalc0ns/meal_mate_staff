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
    this.suffixTooltip,
    this.onSuffixTap,
    this.isPicker = false,
    this.showPickerArrow,
    this.onTap,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.autovalidateMode,
    this.keyboardType,
    this.focusNode,
  });

  final String label;
  final String hint;
  final String? prefix;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? suffixTooltip;
  final VoidCallback? onSuffixTap;
  final bool isPicker;
  final bool? showPickerArrow;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: Spacing.registrationFieldHeight,
      ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Semantics(
                  label: label,
                  textField: true,
                  child: TextFormField(
                    focusNode: focusNode,
                    controller: controller,
                    initialValue: controller == null ? initialValue : null,
                    readOnly: isPicker,
                    canRequestFocus: !isPicker,
                    enableInteractiveSelection: !isPicker,
                    onTap: isPicker
                        ? () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            onTap?.call();
                          }
                        : onTap,
                    onChanged: onChanged,
                    validator: validator,
                    autovalidateMode: autovalidateMode,
                      keyboardType: keyboardType,
                      textAlign: TextAlign.start,
                      style: getMediumStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size12,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        constraints: const BoxConstraints(
                          minHeight: Spacing.registrationFieldInputHeight,
                        ),
                        hintText: hint,
                        hintStyle: getMediumStyle(
                          color: color.onSurfaceVariant,
                          fontSize: FontSize.size12,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Spacing.md,
                          vertical: 11,
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 38,
                          minHeight: 38,
                        ),
                        prefixIcon: prefixIcon == null
                            ? null
                            : Icon(
                                prefixIcon,
                                color: color.onSurface,
                                size: 20,
                              ),
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 38,
                          minHeight: 38,
                        ),
                        suffixIcon: suffixIcon != null
                            ? onSuffixTap == null
                                  ? Icon(
                                      suffixIcon,
                                      color: color.onSurfaceVariant,
                                      size: Spacing.iconMd,
                                    )
                                  : IconButton(
                                      tooltip: suffixTooltip,
                                      onPressed: onSuffixTap,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 38,
                                        minHeight: 38,
                                      ),
                                      icon: Icon(
                                        suffixIcon,
                                        color: color.onSurfaceVariant,
                                        size: Spacing.iconMd,
                                      ),
                                    )
                            : (isPicker &&
                                  (showPickerArrow ?? (prefixIcon == null)))
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
