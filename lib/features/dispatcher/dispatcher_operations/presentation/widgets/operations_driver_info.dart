import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_cached_network_image.dart';
import '../../domain/entities/operations_indicator_color.dart';

class OperationsDriverInfo extends StatelessWidget {
  const OperationsDriverInfo({
    super.key,
    required this.name,
    this.boxCode,
    String? orderId,
    this.avatarUrl,
    this.indicatorColor = OperationsIndicatorColor.unknown,
    bool? isOnline,
  }) : resolvedBoxCode = boxCode ?? orderId ?? '',
       resolvedIndicatorColor =
           indicatorColor != OperationsIndicatorColor.unknown
           ? indicatorColor
           : (isOnline == true
                 ? OperationsIndicatorColor.green
                 : OperationsIndicatorColor.unknown);

  final String name;
  final String? boxCode;
  final String resolvedBoxCode;
  final String? avatarUrl;
  final OperationsIndicatorColor indicatorColor;
  final OperationsIndicatorColor resolvedIndicatorColor;

  Color _resolveIndicatorColor(
    ColorScheme color,
    OperationsIndicatorColor indicator,
  ) {
    switch (indicator) {
      case OperationsIndicatorColor.green:
        return color.primary;
      case OperationsIndicatorColor.orange:
        return color.tertiary;
      case OperationsIndicatorColor.red:
        return color.error;
      case OperationsIndicatorColor.grey:
      case OperationsIndicatorColor.unknown:
        return color.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: avatarUrl != null && avatarUrl!.trim().isNotEmpty
                  ? AppCachedNetworkImage(
                      imageUrl: avatarUrl!,
                      width: 34,
                      height: 34,
                      shape: BoxShape.circle,
                      errorWidget: Icon(
                        Icons.person_rounded,
                        size: 18,
                        color: color.onSurfaceVariant,
                      ),
                    )
                  : Icon(
                      Icons.person_rounded,
                      size: 18,
                      color: color.onSurfaceVariant,
                    ),
            ),
            if (resolvedIndicatorColor != OperationsIndicatorColor.unknown)
              PositionedDirectional(
                bottom: 0,
                end: 0,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _resolveIndicatorColor(
                      color,
                      resolvedIndicatorColor,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.surface, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: Spacing.xs),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getBoldStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: FontSize.size10,
                  color: color.onSurface,
                ),
              ),
              const SizedBox(height: Spacing.xs / 2),
              Text(
                resolvedBoxCode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getRegularStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: FontSize.size9,
                  color: color.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
