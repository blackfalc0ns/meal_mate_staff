import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverDeliveryProofPhotoSection extends StatelessWidget {
  const DriverDeliveryProofPhotoSection({
    super.key,
    this.localPhotoPath,
    this.isUploading = false,
    this.isUploaded = false,
    this.errorMessage,
    required this.onPickPhoto,
    required this.onRetryUpload,
  });

  final String? localPhotoPath;
  final bool isUploading;
  final bool isUploaded;
  final String? errorMessage;
  final VoidCallback onPickPhoto;
  final VoidCallback onRetryUpload;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: errorMessage != null
              ? color.error.withValues(alpha: 0.5)
              : isUploaded
                  ? const Color(0xFF28A745).withValues(alpha: 0.5)
                  : color.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.camera_alt_rounded,
                      color: color.primary,
                      size: Spacing.iconSm,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Flexible(
                      child: Text(
                        isAr ? 'صورة إثبات التسليم' : 'Delivery Proof Photo',
                        style: getBoldStyle(
                          fontSize: FontSize.size13,
                          color: color.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs - 2,
                ),
                decoration: BoxDecoration(
                  color: isUploaded
                      ? const Color(0xFFE8F8F0)
                      : color.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(Spacing.radiusPill),
                ),
                child: Text(
                  isUploaded
                      ? (isAr ? 'تم الرفع' : 'Uploaded')
                      : (isAr ? 'مطلوب *' : 'Required *'),
                  style: getSemiBoldStyle(
                    fontSize: FontSize.size10,
                    color: isUploaded
                        ? const Color(0xFF28A745)
                        : color.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            isAr
                ? 'يرجى التقاط صورة واضحة للبوكس عند باب العميل لإثبات التسليم'
                : 'Please capture a clear photo of the box at the customer door as proof of delivery',
            style: getRegularStyle(
              fontSize: FontSize.size11,
              color: color.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.md),
          if (localPhotoPath == null)
            InkWell(
              onTap: onPickPhoto,
              borderRadius: BorderRadius.circular(Spacing.cardRadius),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: color.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(Spacing.cardRadius),
                  border: Border.all(
                    color: color.outlineVariant,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color.primaryContainer.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_a_photo_rounded,
                        color: color.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      isAr ? 'اضغط لالتقاط صورة' : 'Tap to capture photo',
                      style: getMediumStyle(
                        fontSize: FontSize.size12,
                        color: color.primary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(Spacing.cardRadius),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  File(localPhotoPath!).existsSync()
                      ? Image.file(
                          File(localPhotoPath!),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            height: 180,
                            color: color.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: Icon(Icons.broken_image_rounded, color: color.error),
                          ),
                        )
                      : Container(
                          height: 180,
                          width: double.infinity,
                          color: color.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.photo_camera_back_outlined,
                            size: 48,
                            color: color.primary,
                          ),
                        ),
                  if (isUploading)
                    Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: Spacing.sm),
                          Text(
                            isAr ? 'جاري رفع الصورة...' : 'Uploading photo...',
                            style: getMediumStyle(
                              fontSize: FontSize.size12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isUploaded && !isUploading)
                    Positioned(
                      top: Spacing.sm,
                      right: Spacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                          vertical: Spacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF28A745),
                          borderRadius: BorderRadius.circular(Spacing.radiusPill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check, size: 14, color: Colors.white),
                            const SizedBox(width: Spacing.xs),
                            Text(
                              isAr ? 'تم الرفع بنجاح' : 'Uploaded successfully',
                              style: getMediumStyle(
                                fontSize: FontSize.size10,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.sm),
            if (errorMessage != null && !isUploading) ...[
              Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: color.errorContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, size: 18, color: color.error),
                    const SizedBox(width: Spacing.xs),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: getRegularStyle(
                          fontSize: FontSize.size11,
                          color: color.error,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onRetryUpload,
                      child: Text(
                        isAr ? 'إعادة المحاولة' : 'Retry',
                        style: getBoldStyle(
                          fontSize: FontSize.size11,
                          color: color.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.xs),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: isUploading ? null : onPickPhoto,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    isAr ? 'التقاط صورة أخرى' : 'Retake Photo',
                    style: getMediumStyle(fontSize: FontSize.size11),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
