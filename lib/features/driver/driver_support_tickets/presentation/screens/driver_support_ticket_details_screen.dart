import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/helpers/image_picker_helper.dart';
import '../../data/mapper/driver_support_mapper.dart';
import '../../domain/entities/driver_support_ticket_details_entity.dart';
import '../../domain/entities/driver_support_ticket_entity.dart';
import '../../domain/fake_data/driver_support_tickets_fake_data.dart';
import '../manager/driver_support_ticket_details_event.dart';
import '../manager/driver_support_ticket_details_state.dart';
import '../manager/driver_support_ticket_details_view_model.dart';
import '../widgets/driver_support_ticket_attached_photos_card.dart';
import '../widgets/driver_support_ticket_contact_button.dart';
import '../widgets/driver_support_ticket_details_header.dart';
import '../widgets/driver_support_ticket_details_shimmer.dart';
import '../widgets/driver_support_ticket_issue_card.dart';
import '../widgets/driver_support_ticket_order_info_card.dart';
import '../widgets/driver_support_ticket_summary_card.dart';
import '../widgets/driver_support_ticket_timeline_card.dart';

class DriverSupportTicketDetailsScreen extends StatefulWidget {
  const DriverSupportTicketDetailsScreen({
    super.key,
    this.issueId,
    this.ticket,
    this.viewModel,
    this.onBackPressed,
    this.onContactSupport,
    this.onAddPhoto,
    this.onPhotoTap,
  });

  final String? issueId;
  final DriverSupportTicketEntity? ticket;
  final DriverSupportTicketDetailsViewModel? viewModel;
  final VoidCallback? onBackPressed;
  final VoidCallback? onContactSupport;
  final VoidCallback? onAddPhoto;
  final ValueChanged<String>? onPhotoTap;

  @override
  State<DriverSupportTicketDetailsScreen> createState() =>
      _DriverSupportTicketDetailsScreenState();
}

class _DriverSupportTicketDetailsScreenState
    extends State<DriverSupportTicketDetailsScreen> {
  DriverSupportTicketDetailsViewModel? _viewModel;
  bool _ownsViewModel = false;

  @override
  void initState() {
    super.initState();
    final targetId = widget.issueId ?? widget.ticket?.id ?? '';

    if (widget.viewModel != null) {
      _viewModel = widget.viewModel;
      _ownsViewModel = false;
      if (targetId.isNotEmpty) {
        _viewModel?.doIntent(LoadDriverSupportTicketDetailsEvent(targetId));
      }
    } else if (targetId.isNotEmpty &&
        getIt.isRegistered<DriverSupportTicketDetailsViewModel>()) {
      _viewModel = getIt<DriverSupportTicketDetailsViewModel>();
      _ownsViewModel = true;
      _viewModel?.doIntent(LoadDriverSupportTicketDetailsEvent(targetId));
    }
  }

  @override
  void dispose() {
    if (_ownsViewModel) {
      unawaited(_viewModel?.close());
    }
    super.dispose();
  }

  Future<void> _pickAndAddPhoto(BuildContext context) async {
    if (widget.onAddPhoto != null) {
      widget.onAddPhoto!();
      return;
    }

    final file = await ImagePickerHelper.pickImageWithSourceSheet(
      context,
      title: context.localization.driverSupportTicketAttachedPhotosTitle,
    );

    if (file != null && mounted) {
      _viewModel?.doIntent(AddDriverSupportTicketPhotoEvent(file));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel;

    if (vm == null) {
      return _buildStaticTicketView(context);
    }

    return BlocBuilder<
      DriverSupportTicketDetailsViewModel,
      DriverSupportTicketDetailsState
    >(
      bloc: vm,
      builder: (context, state) {
        if (state.isLoading && state.details == null) {
          return Scaffold(
            appBar: DriverSupportTicketDetailsHeader(
              onBackPressed: widget.onBackPressed,
            ),
            body: const SafeArea(
              top: false,
              child: DriverSupportTicketDetailsShimmer(),
            ),
          );
        }

        if (state.failure != null && state.details == null) {
          return Scaffold(
            appBar: DriverSupportTicketDetailsHeader(
              onBackPressed: widget.onBackPressed,
            ),
            body: SafeArea(
              child: ApiErrorWidget.fromTypedFailure(
                failure: state.failure!,
                onRetry: () {
                  final targetId = widget.issueId ?? widget.ticket?.id ?? '';
                  vm.doIntent(LoadDriverSupportTicketDetailsEvent(targetId));
                },
              ),
            ),
          );
        }

        final details = state.details;
        if (details == null) {
          return _buildStaticTicketView(context);
        }

        return _buildDetailsContent(context, vm, state, details);
      },
    );
  }

  Widget _buildDetailsContent(
    BuildContext context,
    DriverSupportTicketDetailsViewModel vm,
    DriverSupportTicketDetailsState state,
    DriverSupportTicketDetailsEntity details,
  ) {
    final summaryTicket = DriverSupportTicketEntity(
      id: details.issueId,
      boxNumber:
          details.orderCode ??
          (details.categoryLabel.isNotEmpty
              ? details.categoryLabel
              : details.title),
      title: details.title.isNotEmpty ? details.title : details.categoryLabel,
      location: details.area ?? details.address ?? '',
      updatedAt: DriverSupportMapper.formatDate(
        details.updatedAtUtc ?? details.submittedAtUtc,
      ),
      status: details.status,
      createdAt: DriverSupportMapper.formatDate(details.submittedAtUtc),
      category: details.category,
      categoryLabel: details.categoryLabel,
      statusLabel: details.statusLabel,
      rawStatus: details.rawStatus,
      submittedAtUtc: details.submittedAtUtc,
      orderCode: details.orderCode,
    );

    final hasOrderInfo =
        details.orderCode != null ||
        details.address != null ||
        details.area != null ||
        details.orderCreatedAtUtc != null;

    final formattedOrderTime = details.orderCreatedAtUtc != null
        ? DriverSupportMapper.formatDate(details.orderCreatedAtUtc)
        : '';
    final formattedAddress =
        details.address ?? details.area ?? details.orderCode ?? '';

    return Scaffold(
      appBar: DriverSupportTicketDetailsHeader(
        onBackPressed: widget.onBackPressed,
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            vm.doIntent(const RefreshDriverSupportTicketDetailsEvent());
            await vm.stream
                .firstWhere((s) => !s.isRefreshing)
                .timeout(const Duration(seconds: 5), onTimeout: () => vm.state);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.screenH,
              vertical: Spacing.screenV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.actionFailure != null) ...[
                  InlineApiErrorWidget(
                    failure: state.actionFailure!,
                    onRetry: state.pendingStorageKeys.isNotEmpty
                        ? () => vm.doIntent(const RetryAttachPhotosEvent())
                        : () => vm.doIntent(
                            const RefreshDriverSupportTicketDetailsEvent(),
                          ),
                  ),
                  const SizedBox(height: Spacing.md),
                ],
                DriverSupportTicketSummaryCard(ticket: summaryTicket),
                const SizedBox(height: Spacing.md),
                if (details.timeline.isNotEmpty) ...[
                  DriverSupportTicketTimelineCard(steps: details.timeline),
                  const SizedBox(height: Spacing.md),
                ],
                DriverSupportTicketIssueCard(
                  issueDescription: details.description ?? details.title,
                ),
                const SizedBox(height: Spacing.md),
                DriverSupportTicketAttachedPhotosCard(
                  images: details.evidenceUrls,
                  onImageLoadFailed: () =>
                      vm.doIntent(const RefreshSupportEvidenceUrlsEvent()),
                  canAddPhoto: details.canAddPhotos,
                  isUploading: state.isActionInProgress,
                  onAddPhotoPressed: () => _pickAndAddPhoto(context),
                  onPhotoPressed: widget.onPhotoTap,
                ),
                if (details.resolutionNotes != null &&
                    details.resolutionNotes!.trim().isNotEmpty) ...[
                  const SizedBox(height: Spacing.md),
                  _buildResolutionNotesCard(context, details),
                ],
                if (hasOrderInfo) ...[
                  const SizedBox(height: Spacing.md),
                  DriverSupportTicketOrderInfoCard(
                    orderNumber: details.orderCode ?? '',
                    orderTime: formattedOrderTime,
                    deliveryAddress: formattedAddress,
                  ),
                ],
                if (details.canContactSupport) ...[
                  const SizedBox(height: Spacing.xl),
                  DriverSupportTicketContactButton(
                    onPressed: widget.onContactSupport,
                  ),
                ],
                const SizedBox(height: Spacing.screenV),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResolutionNotesCard(
    BuildContext context,
    DriverSupportTicketDetailsEntity details,
  ) {
    final color = context.colorScheme;
    final resolvedAt = details.resolvedAtUtc != null
        ? DriverSupportMapper.formatDate(details.resolvedAtUtc)
        : '';

    return Container(
      padding: const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: Spacing.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.task_alt_rounded,
                color: color.primary,
                size: Spacing.iconSm + 2,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                'ملاحظات الحل',
                style: getBoldStyle(
                  fontSize: FontSize.size14,
                  color: color.onSurface,
                ),
              ),
              if (resolvedAt.isNotEmpty) ...[
                const Spacer(),
                Text(
                  resolvedAt,
                  style: getRegularStyle(
                    fontSize: FontSize.size10,
                    color: color.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Spacing.xs + 2),
          Text(
            details.resolutionNotes!,
            style: getRegularStyle(
              fontSize: FontSize.size12,
              color: color.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticTicketView(BuildContext context) {
    final resolvedTicket =
        widget.ticket ?? DriverSupportTicketsFakeData.tickets.first;

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
      appBar: DriverSupportTicketDetailsHeader(
        onBackPressed: widget.onBackPressed,
      ),
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
                onAddPhotoPressed: widget.onAddPhoto,
                onPhotoPressed: widget.onPhotoTap,
              ),
              const SizedBox(height: Spacing.md),
              DriverSupportTicketOrderInfoCard(
                orderNumber: orderNumber,
                orderTime: orderTime,
                deliveryAddress: deliveryAddress,
              ),
              const SizedBox(height: Spacing.xl),
              DriverSupportTicketContactButton(
                onPressed: widget.onContactSupport,
              ),
              const SizedBox(height: Spacing.screenV),
            ],
          ),
        ),
      ),
    );
  }
}
