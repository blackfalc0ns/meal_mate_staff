import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_support_ticket_status.dart';

class DriverSupportTicketStatusBadge extends StatelessWidget {
  const DriverSupportTicketStatusBadge({
    super.key,
    required this.status,
  });

  final DriverSupportTicketStatus status;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    final Color bgColor;
    final Color fgColor;
    final String label;

    switch (status) {
      case DriverSupportTicketStatus.underReview:
        bgColor = const Color(0xFFFCEBED);
        fgColor = const Color(0xFFE53935);
        label = locale.driverSupportTicketsStatusUnderReview;
        break;
      case DriverSupportTicketStatus.awaitingResponse:
        bgColor = const Color(0xFFEFEBF7);
        fgColor = const Color(0xFF603BC1);
        label = locale.driverSupportTicketsStatusAwaitingResponse;
        break;
      case DriverSupportTicketStatus.resolved:
        bgColor = const Color(0xFFEBF7EE);
        fgColor = const Color(0xFF1BC74E);
        label = locale.driverSupportTicketsStatusResolved;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: Spacing.sm,
            height: Spacing.sm,
            decoration: BoxDecoration(
              color: fgColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Flexible(
            child: Text(
              label,
              style: getMediumStyle(
                fontSize: FontSize.size11,
                color: fgColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
