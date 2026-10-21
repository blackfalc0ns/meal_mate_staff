import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/routing/arguments/dispatcher_support_route_arguments.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_notification_entity.dart';
import '../../domain/entities/dispatcher_notification_filter_type.dart';
import '../manager/dispatcher_notifications_event.dart';
import '../manager/dispatcher_notifications_state.dart';
import '../manager/dispatcher_notifications_view_model.dart';
import '../widgets/dispatcher_notification_card.dart';
import '../widgets/dispatcher_notifications_app_bar.dart';
import '../widgets/dispatcher_notifications_filter_tab_bar.dart';
import '../widgets/dispatcher_notifications_section_header.dart';

class DispatcherNotificationsScreen extends StatefulWidget {
  const DispatcherNotificationsScreen({
    super.key,
    this.viewModel,
    this.onNotificationTap,
    this.onFilterTap,
  });

  final DispatcherNotificationsViewModel? viewModel;
  final ValueChanged<DispatcherNotificationEntity>? onNotificationTap;
  final VoidCallback? onFilterTap;

  @override
  State<DispatcherNotificationsScreen> createState() =>
      _DispatcherNotificationsScreenState();
}

class _DispatcherNotificationsScreenState
    extends State<DispatcherNotificationsScreen> {
  late final DispatcherNotificationsViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
      _ownsViewModel = false;
    } else {
      _viewModel = getIt<DispatcherNotificationsViewModel>();
      _ownsViewModel = false;
    }

    _viewModel.add(const LoadDispatcherNotificationsEvent());
  }

  @override
  void dispose() {
    if (_ownsViewModel) {
      unawaited(_viewModel.close());
    }
    super.dispose();
  }

  void _onFilterChanged(DispatcherNotificationFilterType filter) {
    _viewModel.add(ChangeDispatcherNotificationsFilterEvent(filter));
  }

  void _onMarkAllAsRead() {
    _viewModel.add(const MarkAllLoadedDispatcherNotificationsReadEvent());
  }

  void _handleNotificationTap(DispatcherNotificationEntity item) {
    // 1. Mark as read optimistically via API
    if (item.isUnread) {
      _viewModel.add(MarkDispatcherNotificationReadEvent(item.id));
    }

    // 2. Custom external callback if provided
    widget.onNotificationTap?.call(item);

    // 3. Deep link routing: navigate safely without blocking on read response
    _navigateForNotification(item);
  }

  void _navigateForNotification(DispatcherNotificationEntity item) {
    final deepLink = item.deepLink ?? '';
    final rawType = item.rawType ?? '';

    // Route to dispatcher support issue details if target is an issue
    String? issueId = item.subjectId;
    if (issueId == null || issueId.trim().isEmpty) {
      final match = RegExp(r'/dispatcher/support/issues/([^/?]+)')
          .firstMatch(deepLink);
      if (match != null) {
        issueId = match.group(1);
      }
    }

    final isSupportIssue = item.type == DispatcherNotificationType.driverSupportIssue ||
        item.type == DispatcherNotificationType.driverSupportIssueResolved ||
        rawType == 'driver-support-issue' ||
        rawType == 'driver-support-issue-resolved' ||
        deepLink.contains('/dispatcher/support/issues/');

    if (isSupportIssue && issueId != null && issueId.trim().isNotEmpty) {
      unawaited(
        context.pushNamed(
          AppRoutes.dispatcherSupportIssueDetails,
          arguments: DispatcherSupportIssueDetailsRouteArgs(
            issueId: issueId.trim(),
          ),
        ),
      );
      return;
    }

    // For unknown or handover destinations, stay on notifications list
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return BlocProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: color.surface,
        appBar: DispatcherNotificationsAppBar(
          onFilterPressed: widget.onFilterTap,
        ),
        body: SafeArea(
          child: BlocBuilder<DispatcherNotificationsViewModel,
              DispatcherNotificationsState>(
            builder: (context, state) {
              return RefreshIndicator(
                color: color.primary,
                backgroundColor: color.surface,
                onRefresh: () async {
                  _viewModel.add(
                    const LoadDispatcherNotificationsEvent(isRefresh: true),
                  );
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: Spacing.xs),
                          DispatcherNotificationsFilterTabBar(
                            selectedFilter: state.selectedFilter,
                            onFilterChanged: _onFilterChanged,
                            allCount: state.allCount,
                            unreadCount: state.unreadCount,
                          ),
                          const SizedBox(height: Spacing.sm),
                          if (state.notifications.isNotEmpty)
                            DispatcherNotificationsSectionHeader(
                              onMarkAllAsRead: _onMarkAllAsRead,
                            ),
                          const SizedBox(height: Spacing.xs),
                        ],
                      ),
                    ),
                    if (state.isLoading && state.notifications.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (state.failure != null && state.notifications.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildErrorView(context, state),
                      )
                    else if (state.isFilteredEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyView(context, state),
                      )
                    else ...[
                      if (state.failure != null && state.notifications.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.base,
                              vertical: Spacing.xs,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(Spacing.sm),
                              decoration: BoxDecoration(
                                color: color.errorContainer.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(Spacing.radiusSm),
                                border: Border.all(
                                  color: color.error.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: Spacing.iconSm,
                                    color: color.error,
                                  ),
                                  const SizedBox(width: Spacing.xs),
                                  Expanded(
                                    child: Text(
                                      state.failure?.errorMessage ??
                                          locale.notificationsLoadFailed,
                                      style: getRegularStyle(
                                        fontSize: FontSize.size11,
                                        color: color.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: Spacing.base),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final items = state.filteredNotifications;
                              if (index >= items.length) return null;
                              final item = items[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.base,
                                  vertical: Spacing.xs / 2,
                                ),
                                child: DispatcherNotificationCard(
                                  notification: item,
                                  onTap: () => _handleNotificationTap(item),
                                ),
                              );
                            },
                            childCount: state.filteredNotifications.length,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView(
    BuildContext context,
    DispatcherNotificationsState state,
  ) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: color.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 36,
                color: color.primary,
              ),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              locale.notificationsEmpty,
              style: getBoldStyle(
                fontSize: FontSize.size14,
                color: color.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              locale.notificationsEmptyDesc,
              style: getRegularStyle(
                fontSize: FontSize.size12,
                color: color.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    DispatcherNotificationsState state,
  ) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: color.error,
            ),
            const SizedBox(height: Spacing.md),
            Text(
              locale.notificationsLoadFailed,
              style: getBoldStyle(
                fontSize: FontSize.size14,
                color: color.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              state.failure?.errorMessage ?? '',
              style: getRegularStyle(
                fontSize: FontSize.size12,
                color: color.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.base),
            OutlinedButton.icon(
              onPressed: () {
                _viewModel.add(const LoadDispatcherNotificationsEvent());
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(locale.notificationsRetry),
            ),
          ],
        ),
      ),
    );
  }
}
