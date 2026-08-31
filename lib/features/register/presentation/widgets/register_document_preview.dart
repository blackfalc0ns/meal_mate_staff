import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/register_document.dart';

class RegisterDocumentPreview extends StatelessWidget {
  const RegisterDocumentPreview({
    super.key,
    required this.document,
    required this.isUploaded,
    this.selectedImagePath,
  });

  final RegisterDocument document;
  final bool isUploaded;
  final String? selectedImagePath;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return SizedBox(
      width: Spacing.registrationDocumentImageWidth,
      height: Spacing.registrationDocumentImageHeight,
      child: isUploaded
          ? ClipRRect(
              borderRadius: BorderRadius.circular(Spacing.registrationRadius),
              child: selectedImagePath == null
                  ? Image.asset(document.imageAsset, fit: BoxFit.cover)
                  : Image.file(File(selectedImagePath!), fit: BoxFit.cover),
            )
          : CustomPaint(
              painter: _DashedBorderPainter(color: color.outlineVariant),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(
                    Spacing.registrationDocumentUploadRadius,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: color.onSurfaceVariant,
                      size: Spacing.registrationDocumentUploadIcon,
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      locale.registrationTapToUpload,
                      style: getSemiBoldStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size7,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      locale.registrationUploadFormats,
                      style: getMediumStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size7,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = Spacing.border;
    final radius = Radius.circular(Spacing.registrationDocumentUploadRadius);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, radius));

    for (final metric in path.computeMetrics()) {
      var distance = Spacing.zero;
      while (distance < metric.length) {
        final next = distance + Spacing.registrationDocumentUploadDash;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + Spacing.registrationDocumentUploadDash;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
