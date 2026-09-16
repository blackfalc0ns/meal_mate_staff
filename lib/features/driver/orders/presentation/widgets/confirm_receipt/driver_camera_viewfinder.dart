import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../../config/theme/font_manager.dart';
import '../../../../../../config/theme/spacing.dart';
import '../../../../../../config/theme/styles_manager.dart';
import '../../../../../../core/constants/assets.dart';
import '../../../../../../core/extensions/extensions.dart';

class DriverCameraViewfinder extends StatelessWidget {
  const DriverCameraViewfinder({
    super.key,
    required this.isPhotoCaptured,
    required this.onCapturePhoto,
    this.capturedPhotoPath,
  });

  final bool isPhotoCaptured;
  final VoidCallback onCapturePhoto;
  final String? capturedPhotoPath;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final hasPhoto = isPhotoCaptured || (capturedPhotoPath != null && capturedPhotoPath!.isNotEmpty);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 250,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: color.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(Spacing.radiusXl),
            border: Border.all(
              color: hasPhoto
                  ? color.tertiary
                  : color.outlineVariant.withValues(alpha: 0.4),
              width: hasPhoto ? 2 : Spacing.border,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Captured Real Photo or Sample Image
              if (capturedPhotoPath != null && capturedPhotoPath!.isNotEmpty)
                Image.file(
                  File(capturedPhotoPath!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Image.asset(
                    AppAssets.driverCameraBoxSample,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Image.asset(
                  AppAssets.driverCameraBoxSample,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Center(
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ),

              // Top guideline chip
              Positioned(
                top: Spacing.md,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: color.scrim.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(Spacing.radiusPill),
                    ),
                    child: Text(
                      locale.driverPhotographBoxSubtitle,
                      style: getMediumStyle(
                        color: color.surface,
                        fontSize: FontSize.size11,
                      ),
                    ),
                  ),
                ),
              ),

              // Viewfinder corners
              _buildCorner(top: Spacing.md, left: Spacing.md, color: color.surface),
              _buildCorner(top: Spacing.md, right: Spacing.md, color: color.surface),
              _buildCorner(bottom: Spacing.md, left: Spacing.md, color: color.surface),
              _buildCorner(bottom: Spacing.md, right: Spacing.md, color: color.surface),

              // Bottom camera capture button
              Positioned(
                bottom: Spacing.sm,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: onCapturePhoto,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isPhotoCaptured
                            ? color.tertiaryContainer
                            : color.surface.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isPhotoCaptured ? color.tertiary : color.primary,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.shadow.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isPhotoCaptured
                            ? Icons.check_circle_rounded
                            : Icons.camera_alt_rounded,
                        color: isPhotoCaptured ? color.tertiary : color.primary,
                        size: Spacing.iconMd,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: Spacing.iconXs,
              color: color.onSurfaceVariant,
            ),
            const SizedBox(width: Spacing.xs),
            Flexible(
              child: Text(
                locale.driverCameraBoxLightingHint,
                style: getRegularStyle(
                  color: color.onSurfaceVariant,
                  fontSize: FontSize.size11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
  }) {
    const double cornerLength = 24;
    const double cornerThickness = 3;

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: cornerLength,
        height: cornerLength,
        decoration: BoxDecoration(
          border: Border(
            top: top != null
                ? BorderSide(color: color, width: cornerThickness)
                : BorderSide.none,
            bottom: bottom != null
                ? BorderSide(color: color, width: cornerThickness)
                : BorderSide.none,
            left: left != null
                ? BorderSide(color: color, width: cornerThickness)
                : BorderSide.none,
            right: right != null
                ? BorderSide(color: color, width: cornerThickness)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: top != null && left != null
                ? const Radius.circular(Spacing.radiusMd)
                : Radius.zero,
            topRight: top != null && right != null
                ? const Radius.circular(Spacing.radiusMd)
                : Radius.zero,
            bottomLeft: bottom != null && left != null
                ? const Radius.circular(Spacing.radiusMd)
                : Radius.zero,
            bottomRight: bottom != null && right != null
                ? const Radius.circular(Spacing.radiusMd)
                : Radius.zero,
          ),
        ),
      ),
    );
  }
}
