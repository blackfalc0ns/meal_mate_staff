import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DeliveryIssuePhotoPicker extends StatelessWidget {
  const DeliveryIssuePhotoPicker({
    super.key,
    required this.photos,
    this.onAddPhoto,
    this.onRemovePhoto,
    this.maxPhotos = 4,
  });

  final List<String> photos;
  final VoidCallback? onAddPhoto;
  final ValueChanged<int>? onRemovePhoto;
  final int maxPhotos;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final canAdd = photos.length < maxPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          locale.reportIssuePhotosTitle,
          style: getBoldStyle(
            fontSize: FontSize.size14,
            color: color.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          locale.reportIssuePhotosSubtitle,
          style: getRegularStyle(
            fontSize: FontSize.size12,
            color: color.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: (canAdd ? 1 : 0) + photos.length,
            separatorBuilder: (_, _) => const SizedBox(width: Spacing.sm),
            itemBuilder: (context, index) {
              if (canAdd && index == 0) {
                return InkWell(
                  onTap: onAddPhoto,
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: color.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(Spacing.radiusMd),
                      border: Border.all(
                        color: color.outlineVariant.withValues(alpha: 0.8),
                        width: Spacing.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: Spacing.iconSm,
                          color: color.onSurfaceVariant,
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          locale.reportIssueAddPhoto,
                          style: getRegularStyle(
                            fontSize: FontSize.size10,
                            color: color.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final photoIndex = canAdd ? index - 1 : index;
              final photo = photos[photoIndex];

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Spacing.radiusMd),
                    child: SizedBox(
                      width: 78,
                      height: 78,
                      child: Image.asset(
                        photo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => ColoredBox(
                          color: color.surfaceContainerHigh,
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: Spacing.iconSm,
                            color: color.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: -6,
                    end: -6,
                    child: InkWell(
                      onTap: () => onRemovePhoto?.call(photoIndex),
                      borderRadius: BorderRadius.circular(Spacing.radiusPill),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: color.error,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 12,
                          color: color.onError,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          locale.reportIssuePhotosLimitNote,
          style: getRegularStyle(
            fontSize: FontSize.size11,
            color: color.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
