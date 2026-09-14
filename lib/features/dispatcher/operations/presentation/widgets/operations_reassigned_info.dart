import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

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
        CircleAvatar(
          radius: 14,
          backgroundColor: color.surfaceContainerHigh,
          backgroundImage: fromAvatarUrl != null
              ? AssetImage(fromAvatarUrl!)
              : null,
          child: fromAvatarUrl == null
              ? Icon(
                  Icons.person_outline_rounded,
                  size: 14,
                  color: color.onSurfaceVariant,
                )
              : null,
        ),
        const SizedBox(width: Spacing.xs / 2),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 48),
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
        Icon(
          Icons.arrow_forward_rounded,
          size: 12,
          color: color.primary,
        ),
        const SizedBox(width: Spacing.xs / 2),
        // To driver avatar
        CircleAvatar(
          radius: 14,
          backgroundColor: color.surfaceContainerHigh,
          backgroundImage:
              toAvatarUrl != null ? AssetImage(toAvatarUrl!) : null,
          child: toAvatarUrl == null
              ? Icon(
                  Icons.person_rounded,
                  size: 14,
                  color: color.onSurfaceVariant,
                )
              : null,
        ),
        const SizedBox(width: Spacing.xs / 2),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 48),
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
