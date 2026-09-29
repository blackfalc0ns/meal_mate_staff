import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../domain/entities/driver_support_ticket_entity.dart';
import '../../domain/fake_data/driver_support_tickets_fake_data.dart';
import '../widgets/driver_support_ticket_attached_photos_card.dart';
import '../widgets/driver_support_ticket_contact_button.dart';
import '../widgets/driver_support_ticket_details_header.dart';
import '../widgets/driver_support_ticket_issue_card.dart';
import '../widgets/driver_support_ticket_order_info_card.dart';
import '../widgets/driver_support_ticket_summary_card.dart';
import '../widgets/driver_support_ticket_timeline_card.dart';

class DriverSupportTicketDetailsScreen extends StatelessWidget {
  const DriverSupportTicketDetailsScreen({
    super.key,
    this.ticket,
    this.onBackPressed,
    this.onContactSupport,
    this.onAddPhoto,
    this.onPhotoTap,
  });

  final DriverSupportTicketEntity? ticket;
  final VoidCallback? onBackPressed;
  final VoidCallback? onContactSupport;
  final VoidCallback? onAddPhoto;
  final ValueChanged<String>? onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final resolvedTicket = ticket ?? DriverSupportTicketsFakeData.tickets.first;

    final timelineSteps =
        resolvedTicket.timelineSteps ??
        DriverSupportTicketsFakeData.defaultTimelineSteps;

    final attachedImages =
        resolvedTicket.attachedImages ??
        DriverSupportTicketsFakeData.defaultAttachedPhotos;

    final issueDesc =
        resolvedTicket.issueDescription ??
        'وصلت إلى موقع العميل ولم يكن متواجد، حاولت التواصل عبر الهاتف ولم يتم الرد.';

    final orderNumber = resolvedTicket.orderNumber ?? '#12345';
    final orderTime = resolvedTicket.orderTime ?? '12 سبتمبر 2024\n02:10 م';
    final deliveryAddress =
        resolvedTicket.deliveryAddress ?? resolvedTicket.location;

    return Scaffold(
      appBar: const DriverSupportTicketDetailsHeader(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.screenH,
            vertical: Spacing.screenV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DriverSupportTicketSummaryCard(ticket: resolvedTicket),
              const SizedBox(height: Spacing.md),
              DriverSupportTicketTimelineCard(steps: timelineSteps),
              const SizedBox(height: Spacing.md),
              DriverSupportTicketIssueCard(issueDescription: issueDesc),
              const SizedBox(height: Spacing.md),
              DriverSupportTicketAttachedPhotosCard(
                images: attachedImages,
                onAddPhotoPressed: onAddPhoto,
                onPhotoPressed: onPhotoTap,
              ),
              const SizedBox(height: Spacing.md),
              DriverSupportTicketOrderInfoCard(
                orderNumber: orderNumber,
                orderTime: orderTime,
                deliveryAddress: deliveryAddress,
              ),
              const SizedBox(height: Spacing.xl),
              DriverSupportTicketContactButton(onPressed: onContactSupport),
              const SizedBox(height: Spacing.screenV),
            ],
          ),
        ),
      ),
    );
  }
}
