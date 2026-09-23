import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_cached_network_image.dart';

class OperationsReassignedInfo extends StatelessWidget {
  const OperationsReassignedInfo({
    super.key,
    required this.fromDriverName,
    required this.toDriverName,
    this.fromAvatarUrl,
    this.toAvatarUrl,
  });

  final String fromDriverName;
  final String toDriverName;
  final String? fromAvatarUrl;
  final String? toAvatarUrl;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // From driver avatar
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.surfaceContainerHigh,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: fromAvatarUrl != null && fromAvatarUrl!.trim().isNotEmpty
              ? AppCachedNetworkImage(
                  imageUrl: fromAvatarUrl!,
                  width: 26,
                  height: 26,
                  shape: BoxShape.circle,
                  errorWidget: Icon(
                    Icons.person_outline_rounded,
                    size: 13,
                    color: color.onSurfaceVariant,
                  ),
                )
              : Icon(
                  Icons.person_outline_rounded,
                  size: 13,
                  color: color.onSurfaceVariant,
                ),
        ),
        const SizedBox(width: Spacing.xs / 2),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 38),
          child: Text(
            fromDriverName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: getRegularStyle(
              fontFamily: FontConstant.alexandria,
              fontSize: FontSize.size8,
              color: color.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: Spacing.xs / 2),
        Icon(Icons.arrow_forward_rounded, size: 11, color: color.primary),
        const SizedBox(width: Spacing.xs / 2),
        // To driver avatar
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.surfaceContainerHigh,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: toAvatarUrl != null && toAvatarUrl!.trim().isNotEmpty
              ? AppCachedNetworkImage(
                  imageUrl: toAvatarUrl!,
                  width: 26,
                  height: 26,
                  shape: BoxShape.circle,
                  errorWidget: Icon(
                    Icons.person_rounded,
                    size: 13,
                    color: color.onSurfaceVariant,
                  ),
                )
              : Icon(
                  Icons.person_rounded,
                  size: 13,
                  color: color.onSurfaceVariant,
                ),
        ),
        const SizedBox(width: Spacing.xs / 2),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 38),
          child: Text(
            toDriverName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: getBoldStyle(
              fontFamily: FontConstant.alexandria,
              fontSize: FontSize.size8,
              color: color.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
