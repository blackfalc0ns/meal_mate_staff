import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../../config/theme/font_manager.dart';
import '../../../../../../config/theme/spacing.dart';
import '../../../../../../config/theme/styles_manager.dart';
import '../../../../../../core/extensions/extensions.dart';

class DriverQrViewfinder extends StatefulWidget {
  const DriverQrViewfinder({
    super.key,
    required this.onScanSuccess,
    this.controller,
  });

  final VoidCallback onScanSuccess;
  final MobileScannerController? controller;

  @override
  State<DriverQrViewfinder> createState() => _DriverQrViewfinderState();
}

class _DriverQrViewfinderState extends State<DriverQrViewfinder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.15, end: 0.85).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: widget.onScanSuccess,
          child: Container(
            height: 210,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: color.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(Spacing.radiusXl),
              border: Border.all(
                color: color.outlineVariant.withValues(alpha: 0.3),
                width: Spacing.border,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Real live camera feed
                if (widget.controller != null)
                  Positioned.fill(
                    child: MobileScanner(
                      controller: widget.controller,
                      onDetect: (capture) {
                        for (final barcode in capture.barcodes) {
                          if (barcode.rawValue != null &&
                              barcode.rawValue!.isNotEmpty) {
                            widget.onScanSuccess();
                            break;
                          }
                        }
                      },
                      errorBuilder: (context, error) {
                        return Container(
                          color: color.surfaceContainerHighest.withValues(alpha: 0.4),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.videocam_off_outlined,
                                  size: Spacing.iconLg,
                                  color: color.onSurfaceVariant,
                                ),
                                const SizedBox(height: Spacing.xs),
                                Text(
                                  locale.driverQrScannerTitle,
                                  style: getMediumStyle(
                                    color: color.onSurfaceVariant,
                                    fontSize: FontSize.size11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                // Viewfinder inner frame
                Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.surface.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(Spacing.radiusLg),
                    ),
                    child: Stack(
                      children: [
                        // Viewfinder Corner Brackets
                        _buildCorner(top: 0, left: 0, color: color.primary),
                        _buildCorner(top: 0, right: 0, color: color.primary),
                        _buildCorner(bottom: 0, left: 0, color: color.primary),
                        _buildCorner(bottom: 0, right: 0, color: color.primary),

                        // Animated scanning beam
                        AnimatedBuilder(
                          animation: _scanAnimation,
                          builder: (context, child) {
                            return Align(
                              alignment: Alignment(0, (_scanAnimation.value * 2) - 1),
                              child: Container(
                                height: 3,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: Spacing.md,
                                ),
                                decoration: BoxDecoration(
                                  color: color.primary,
                                  borderRadius: BorderRadius.circular(Spacing.radiusPill),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.primary.withValues(alpha: 0.6),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner_rounded,
              size: Spacing.iconXs,
              color: color.onSurfaceVariant,
            ),
            const SizedBox(width: Spacing.xs),
            Flexible(
              child: Text(
                locale.driverQrViewfinderHint,
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
    const double cornerLength = 22;
    const double cornerThickness = 3.5;

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
