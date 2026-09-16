import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

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
            height: 235,
            padding: const EdgeInsets.all(Spacing.base),
            decoration: BoxDecoration(
              color: const Color(0xFFB5B8BF),
              borderRadius: BorderRadius.circular(Spacing.radiusXl + 4),
            ),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(Spacing.radiusLg),
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
                            color: color.surface,
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

                  // Viewfinder Corner Brackets
                  _buildCorner(top: 10, left: 10, color: color.primary),
                  _buildCorner(top: 10, right: 10, color: color.primary),
                  _buildCorner(bottom: 10, left: 10, color: color.primary),
                  _buildCorner(bottom: 10, right: 10, color: color.primary),

                  // Animated scanning beam
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Align(
                        alignment: Alignment(0, (_scanAnimation.value * 2) - 1),
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(
                            horizontal: Spacing.xl,
                          ),
                          decoration: BoxDecoration(
                            color: color.primary.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(
                              Spacing.radiusPill,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.primary.withValues(alpha: 0.45),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: const Color(
                                  0xFFD8B4FE,
                                ).withValues(alpha: 0.7),
                                blurRadius: 6,
                                spreadRadius: 1,
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
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: CustomPaint(
        size: const Size(34, 34),
        painter: _CornerBracketPainter(
          color: color,
          thickness: 2.8,
          radius: 12,
          isTop: top != null,
          isLeft: left != null,
        ),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  const _CornerBracketPainter({
    required this.color,
    required this.thickness,
    required this.radius,
    required this.isTop,
    required this.isLeft,
  });

  final Color color;
  final double thickness;
  final double radius;
  final bool isTop;
  final bool isLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final halfThick = thickness / 2;

    if (isTop && isLeft) {
      path.moveTo(halfThick, size.height);
      path.lineTo(halfThick, radius + halfThick);
      path.quadraticBezierTo(
        halfThick,
        halfThick,
        radius + halfThick,
        halfThick,
      );
      path.lineTo(size.width, halfThick);
    } else if (isTop && !isLeft) {
      path.moveTo(0, halfThick);
      path.lineTo(size.width - radius - halfThick, halfThick);
      path.quadraticBezierTo(
        size.width - halfThick,
        halfThick,
        size.width - halfThick,
        radius + halfThick,
      );
      path.lineTo(size.width - halfThick, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(halfThick, 0);
      path.lineTo(halfThick, size.height - radius - halfThick);
      path.quadraticBezierTo(
        halfThick,
        size.height - halfThick,
        radius + halfThick,
        size.height - halfThick,
      );
      path.lineTo(size.width, size.height - halfThick);
    } else {
      path.moveTo(0, size.height - halfThick);
      path.lineTo(size.width - radius - halfThick, size.height - halfThick);
      path.quadraticBezierTo(
        size.width - halfThick,
        size.height - halfThick,
        size.width - halfThick,
        size.height - radius - halfThick,
      );
      path.lineTo(size.width - halfThick, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.thickness != thickness ||
        oldDelegate.radius != radius;
  }
}
