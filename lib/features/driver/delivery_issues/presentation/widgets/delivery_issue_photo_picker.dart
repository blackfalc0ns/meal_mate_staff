import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/issue_photo_item.dart';

class DeliveryIssuePhotoPicker extends StatelessWidget {
  const DeliveryIssuePhotoPicker({
    super.key,
    this.photos = const [],
    this.photoItems,
    this.onAddPhoto,
    this.onRemovePhoto,
    this.onRetryPhoto,
    this.maxPhotos = 3,
  });

  final List<String> photos;
  final List<IssuePhotoItem>? photoItems;
  final VoidCallback? onAddPhoto;
  final ValueChanged<int>? onRemovePhoto;
  final ValueChanged<IssuePhotoItem>? onRetryPhoto;
  final int maxPhotos;

  List<IssuePhotoItem> get _effectiveItems {
    if (photoItems != null) return photoItems!;
    return photos
        .map((p) => IssuePhotoItem(
              id: p,
              localPath: p,
              status: IssuePhotoStatus.success,
              storageKey: p,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final items = _effectiveItems;
    final canAdd = items.length < maxPhotos;

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
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: (canAdd ? 1 : 0) + items.length,
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

              final itemIndex = canAdd ? index - 1 : index;
              final item = items[itemIndex];

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Spacing.radiusMd),
                      border: Border.all(
                        color: item.isFailed
                            ? color.error
                            : item.isSuccess
                                ? color.primary.withValues(alpha: 0.5)
                                : color.outlineVariant.withValues(alpha: 0.8),
                        width: item.isFailed ? 1.5 : Spacing.border,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Spacing.radiusMd - 1),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          item.localPath.startsWith('assets/')
                              ? Image.asset(
                                  item.localPath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => ColoredBox(
                                    color: color.surfaceContainerHigh,
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      size: Spacing.iconSm,
                                      color: color.onSurfaceVariant,
                                    ),
                                  ),
                                )
                              : Image.file(
                                  File(item.localPath),
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
                          if (item.isUploading)
                            Container(
                              color: Colors.black45,
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    color.primary,
                                  ),
                                ),
                              ),
                            ),
                          if (item.isFailed)
                            Container(
                              color: color.error.withValues(alpha: 0.25),
                              alignment: Alignment.center,
                              child: IconButton(
                                tooltip: locale.reportIssuePhotoRetry,
                                icon: Icon(
                                  Icons.refresh_rounded,
                                  color: color.error,
                                  size: Spacing.iconMd,
                                ),
                                onPressed: () => onRetryPhoto?.call(item),
                              ),
                            ),
                          if (item.isSuccess)
                            PositionedDirectional(
                              bottom: 4,
                              start: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: -6,
                    end: -6,
                    child: InkWell(
                      onTap: () => onRemovePhoto?.call(itemIndex),
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
