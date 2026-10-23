import 'dart:io';

import 'support_evidence_url.dart';

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/network/network_constants.dart';
import '../../../../../core/services/token_service.dart';

class DriverSupportTicketAttachedPhotosCard extends StatelessWidget {
  const DriverSupportTicketAttachedPhotosCard({
    super.key,
    required this.images,
    this.onAddPhotoPressed,
    this.onPhotoPressed,
    this.canAddPhoto = true,
    this.isUploading = false,
    this.onImageLoadFailed,
  });

  final List<String> images;
  final VoidCallback? onAddPhotoPressed;
  final ValueChanged<String>? onPhotoPressed;
  final bool canAddPhoto;
  final bool isUploading;
  final VoidCallback? onImageLoadFailed;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: Spacing.border,
        ),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: Spacing.iconLg + 2,
                height: Spacing.iconLg + 2,
                decoration: BoxDecoration(
                  color: color.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Icon(
                  Icons.image_outlined,
                  size: Spacing.iconSm + 4,
                  color: color.primary,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                locale.driverSupportTicketAttachedPhotosTitle,
                style: getBoldStyle(
                  fontSize: FontSize.size14,
                  color: color.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Directionality(
            textDirection: TextDirection.ltr,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (canAddPhoto || isUploading) ...[
                    InkWell(
                      onTap: isUploading ? null : onAddPhotoPressed,
                      borderRadius: BorderRadius.circular(Spacing.radiusMd),
                      child: CustomPaint(
                        painter: _DashedBorderPainter(
                          color: color.primary.withValues(alpha: 0.5),
                          radius: Spacing.radiusMd,
                          strokeWidth: 1.5,
                          dash: 4.0,
                          gap: 3.5,
                        ),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: color.primary.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(
                              Spacing.radiusMd,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: isUploading
                              ? SizedBox(
                                  width: Spacing.iconSm,
                                  height: Spacing.iconSm,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: color.primary,
                                  ),
                                )
                              : Icon(
                                  Icons.add_rounded,
                                  size: Spacing.iconMd + 2,
                                  color: color.primary,
                                ),
                        ),
                      ),
                    ),
                  ],
                  for (final imagePath in images) ...[
                    const SizedBox(width: Spacing.sm),
                    InkWell(
                      onTap: () => onPhotoPressed?.call(imagePath),
                      borderRadius: BorderRadius.circular(Spacing.radiusMd),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Spacing.radiusMd),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: _EvidenceImage(
                            imagePath: imagePath,
                            onLoadFailed: onImageLoadFailed,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidenceImage extends StatelessWidget {
  const _EvidenceImage({required this.imagePath, this.onLoadFailed});

  final String imagePath;
  final VoidCallback? onLoadFailed;

  Widget _networkError(BuildContext context) {
    // Image error builders run during build; refresh on the next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) onLoadFailed?.call();
    });
    return _buildErrorPlaceholder(context);
  }

  @override
  Widget build(BuildContext context) {
    final clean = imagePath.trim();
    if (clean.isEmpty) {
      return _buildErrorPlaceholder(context);
    }

    if (clean.startsWith('assets/')) {
      return Image.asset(
        clean,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildErrorPlaceholder(context),
      );
    }

    final isLocal =
        !clean.startsWith('http') &&
        !clean.startsWith('/') &&
        File(clean).existsSync();
    if (isLocal) {
      return Image.file(
        File(clean),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildErrorPlaceholder(context),
      );
    }

    final fullUrl = resolveSupportEvidenceUrl(clean, NetworkConstants.baseUrl);
    final needsBearer = supportEvidenceNeedsBearer(
      fullUrl,
      NetworkConstants.baseUrl,
    );

    if (needsBearer && getIt.isRegistered<TokenService>()) {
      return FutureBuilder<String?>(
        future: getIt<TokenService>().getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
          final token = snapshot.data;
          final headers = <String, String>{};
          if (token != null && token.isNotEmpty) {
            headers['Authorization'] = 'Bearer $token';
          }

          return Image.network(
            fullUrl,
            headers: headers.isEmpty ? null : headers,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (_, _, _) => _networkError(context),
          );
        },
      );
    }

    return Image.network(
      fullUrl,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, _, _) => _networkError(context),
    );
  }

  Widget _buildErrorPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image_rounded,
        size: 24,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 1.0,
    this.dash = 4.0,
    this.gap = 3.0,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final halfStroke = strokeWidth / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Rect.fromLTWH(
      halfStroke,
      halfStroke,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(radius > halfStroke ? radius - halfStroke : radius),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dash;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dash != dash ||
        oldDelegate.gap != gap;
  }
}
