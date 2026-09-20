import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class OperationsDriverInfo extends StatelessWidget {
  const OperationsDriverInfo({
    super.key,
    required this.name,
    required this.orderId,
    this.avatarUrl,
    this.isOnline = true,
  });

  final String name;
  final String orderId;
  final String? avatarUrl;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: color.surfaceContainerHigh,
              backgroundImage: avatarUrl != null
                  ? AssetImage(avatarUrl!)
                  : null,
              child: avatarUrl == null
                  ? Icon(
                      Icons.person_rounded,
                      size: 18,
                      color: color.onSurfaceVariant,
                    )
                  : null,
            ),
            if (isOnline)
              PositionedDirectional(
                bottom: 0,
                end: 0,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: color.primary,
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
                orderId,
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
