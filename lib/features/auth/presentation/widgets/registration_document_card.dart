import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class RegistrationDocumentCard extends StatelessWidget {
  const RegistrationDocumentCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageAsset,
  });

  final String title;
  final String subtitle;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return SizedBox(
      height: Spacing.registrationDocumentCardHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.surface,
          border: Border.all(color: color.outline),
          borderRadius: BorderRadius.circular(Spacing.registrationRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.sm),
          child: Row(
            children: [
              SizedBox(
                width: Spacing.registrationDocumentImageWidth,
                height: Spacing.registrationDocumentImageHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color.primaryContainer,
                    borderRadius: BorderRadius.circular(
                      Spacing.registrationRadius,
                    ),
                  ),
                  child: imageAsset == null
                      ? Icon(
                          Icons.upload_file_rounded,
                          color: color.primary,
                          size: Spacing.iconLg,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(
                            Spacing.registrationRadius,
                          ),
                          child: Image.asset(imageAsset!, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: getSemiBoldStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size10,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      subtitle,
                      style: getRegularStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size10,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.cloud_upload_outlined,
                color: color.primary,
                size: Spacing.iconMd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
