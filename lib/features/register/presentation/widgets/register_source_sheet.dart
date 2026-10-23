import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class RegisterSourceSheet extends StatelessWidget {
  const RegisterSourceSheet({
    super.key,
    this.title,
  });

  final String? title;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.base,
          vertical: Spacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null && title!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(
                  top: Spacing.xs,
                  bottom: Spacing.md,
                ),
                child: Text(
                  title!,
                  style: getBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
              ),
              leading: Container(
                padding: const EdgeInsets.all(Spacing.xs),
                decoration: BoxDecoration(
                  color: color.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Icon(
                  Icons.photo_camera_rounded,
                  color: color.primary,
                  size: Spacing.iconMd,
                ),
              ),
              title: Text(
                locale.registrationCamera,
                style: getSemiBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size14,
                ),
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            const SizedBox(height: Spacing.xs),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
              ),
              leading: Container(
                padding: const EdgeInsets.all(Spacing.xs),
                decoration: BoxDecoration(
                  color: color.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Icon(
                  Icons.photo_library_rounded,
                  color: color.primary,
                  size: Spacing.iconMd,
                ),
              ),
              title: Text(
                locale.registrationGallery,
                style: getSemiBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size14,
                ),
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            const SizedBox(height: Spacing.xs),
          ],
        ),
      ),
    );
  }
}
