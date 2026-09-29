import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../domain/entities/driver_support_ticket_status.dart';

class DriverSupportTicketsKpiCard extends StatelessWidget {
  const DriverSupportTicketsKpiCard({
    super.key,
    required this.filter,
    required this.label,
    required this.count,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final DriverSupportTicketFilter filter;
  final String label;
  final int count;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  Color _getBackgroundColor() {
    switch (filter) {
      case DriverSupportTicketFilter.all:
        return const Color(0xFFEFEBF7);
      case DriverSupportTicketFilter.underReview:
        return const Color(0xFFFCEBED);
      case DriverSupportTicketFilter.awaitingResponse:
        return const Color(0xFFFEF5E7);
      case DriverSupportTicketFilter.resolved:
        return const Color(0xFFEBF7EE);
    }
  }

  Color _getForegroundColor() {
    switch (filter) {
      case DriverSupportTicketFilter.all:
        return const Color(0xFF603BC1);
      case DriverSupportTicketFilter.underReview:
        return const Color(0xFFE53935);
      case DriverSupportTicketFilter.awaitingResponse:
        return const Color(0xFFFD8020);
      case DriverSupportTicketFilter.resolved:
        return const Color(0xFF1BC74E);
    }
  }

  Color _getBorderColor() {
    if (isSelected) {
      switch (filter) {
        case DriverSupportTicketFilter.all:
          return const Color(0xFF603BC1);
        case DriverSupportTicketFilter.underReview:
          return const Color(0xFFE53935);
        case DriverSupportTicketFilter.awaitingResponse:
          return const Color(0xFFFD8020);
        case DriverSupportTicketFilter.resolved:
          return const Color(0xFF1BC74E);
      }
    }
    switch (filter) {
      case DriverSupportTicketFilter.all:
        return const Color(0xFFD5CEE2);
      case DriverSupportTicketFilter.underReview:
        return const Color(0xFFF6CCD0);
      case DriverSupportTicketFilter.awaitingResponse:
        return const Color(0xFFFCDFB8);
      case DriverSupportTicketFilter.resolved:
        return const Color(0xFFC3E8CC);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fgColor = _getForegroundColor();
    final bgColor = _getBackgroundColor();
    final borderColor = _getBorderColor();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.cardRadius),
      child: Ink(
        padding: const EdgeInsets.symmetric(
          vertical: Spacing.sm,
          horizontal: Spacing.xs,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.5 : Spacing.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: Spacing.iconSm,
              color: fgColor,
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              label,
              style: getBoldStyle(
                fontSize: FontSize.size11,
                color: fgColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              '$count',
              style: getBoldStyle(
                fontSize: FontSize.size16,
                color: const Color(0xFF17151C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
