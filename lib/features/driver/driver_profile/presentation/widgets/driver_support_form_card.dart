import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';
import 'driver_support_attachment_box.dart';
import 'driver_support_category_dropdown.dart';
import 'driver_support_message_input.dart';

class DriverSupportFormCard extends StatelessWidget {
  const DriverSupportFormCard({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.messageController,
    this.attachedFileName,
    this.onAttachmentTap,
    this.onAttachmentRemove,
    this.onSubmit,
    this.isSubmitting = false,
  });

  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final TextEditingController messageController;
  final String? attachedFileName;
  final VoidCallback? onAttachmentTap;
  final VoidCallback? onAttachmentRemove;
  final VoidCallback? onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          locale.driverSupportSendMessageTitle,
          style: getBoldStyle(
            fontFamily: FontConstant.alexandria,
            fontSize: FontSize.size12,
            color: color.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Container(
          padding: const EdgeInsets.all(Spacing.sm + 2),
          decoration: BoxDecoration(
            color: color.surface,
            borderRadius: BorderRadius.circular(Spacing.cardRadius),
            border: Border.all(
              color: color.outlineVariant.withValues(alpha: 0.6),
              width: Spacing.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              DriverSupportCategoryDropdown(
                categories: categories,
                selectedCategory: selectedCategory,
                onCategorySelected: onCategorySelected,
              ),
              const SizedBox(height: Spacing.sm),
              DriverSupportMessageInput(controller: messageController),
              const SizedBox(height: Spacing.sm),
              DriverSupportAttachmentBox(
                attachedFileName: attachedFileName,
                onTap: onAttachmentTap,
                onRemove: onAttachmentRemove,
              ),
              const SizedBox(height: Spacing.sm + 2),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: messageController,
                builder: (context, value, _) {
                  final canSubmit =
                      value.text.trim().isNotEmpty && !isSubmitting;

                  return AppButton(
                    text: locale.driverSupportSubmitButton,
                    onPressed: canSubmit ? onSubmit : null,
                    height: 42,
                    color: canSubmit
                        ? color.primary
                        : color.primary.withValues(alpha: 0.25),
                    textColor: canSubmit
                        ? color.onPrimary
                        : color.onPrimary.withValues(alpha: 0.9),
                    textStyle: getBoldStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size13,
                      color: canSubmit
                          ? color.onPrimary
                          : color.onPrimary.withValues(alpha: 0.9),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
