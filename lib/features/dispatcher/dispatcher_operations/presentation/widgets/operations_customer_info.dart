import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class OperationsCustomerInfo extends StatelessWidget {
  const OperationsCustomerInfo({
    super.key,
    required this.customerName,
    required this.area,
  });

  final String customerName;
  final String area;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${locale.operationsCustomerLabel} $customerName',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: getMediumStyle(
            fontFamily: FontConstant.alexandria,
            fontSize: FontSize.size10,
            color: color.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.xs / 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 11,
              color: color.onSurfaceVariant,
            ),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                area,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getRegularStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: FontSize.size9,
                  color: color.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
