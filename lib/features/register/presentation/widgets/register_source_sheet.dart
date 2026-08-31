import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class RegisterSourceSheet extends StatelessWidget {
  const RegisterSourceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.base),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.photo_camera_outlined,
                color: color.primary,
                size: Spacing.iconMd,
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
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: color.primary,
                size: Spacing.iconMd,
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
          ],
        ),
      ),
    );
  }
}
