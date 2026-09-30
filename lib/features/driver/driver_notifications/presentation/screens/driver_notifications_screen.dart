import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_progress_indecator.dart';
import '../../../../../core/widget/custom_snak_bar.dart';
import '../../domain/entities/driver_notification_entity.dart';
import '../../domain/entities/driver_notification_filter_type.dart';
import '../../domain/fake_data/driver_notifications_fake_data.dart';
import '../manager/driver_notifications_event.dart';
import '../manager/driver_notifications_state.dart';
import '../manager/driver_notifications_view_model.dart';
import '../widgets/driver_notification_card.dart';
import '../widgets/driver_notifications_filter_tab_bar.dart';
import '../widgets/driver_notifications_header.dart';
import '../widgets/driver_notifications_mark_all_button.dart';
import '../widgets/driver_notifications_section_header.dart';
import '../widgets/driver_notifications_shimmer.dart';

class DriverNotificationsScreen extends StatefulWidget {
  const DriverNotificationsScreen({
    super.key,
    this.initialNotifications,
    this.viewModel,
    this.onBack,
    this.onSettingsTap,
  });

  final List<DriverNotificationEntity>? initialNotifications;
  final DriverNotificationsViewModel? viewModel;
  final VoidCallback? onBack;
  final VoidCallback? onSettingsTap;

  @override
  State<DriverNotificationsScreen> createState() =>
      _DriverNotificationsScreenState();
}

class _DriverNotificationsScreenState extends State<DriverNotificationsScreen> {
  DriverNotificationsViewModel? _viewModel;
  late final bool _ownsViewModel;
  late final bool _useViewModel;

  // Fallback state for tests without GetIt or ViewModel
  DriverNotificationFilterType _selectedFilter =
      DriverNotificationFilterType.all;
  late List<DriverNotificationEntity> _notifications;

  @override
  void initState() {
    super.initState();
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel;
      _ownsViewModel = false;
      _useViewModel = true;
      _viewModel!.doIntent(const DriverNotificationsLoadEvent());
    } else if (getIt.isRegistered<DriverNotificationsViewModel>()) {
      _viewModel = getIt<DriverNotificationsViewModel>();
      _ownsViewModel = true;
      _useViewModel = true;
      _viewModel!.doIntent(const DriverNotificationsLoadEvent());
    } else {
      _viewModel = null;
      _ownsViewModel = false;
      _useViewModel = false;
      _notifications = List.of(
        widget.initialNotifications ??
            DriverNotificationsFakeData.defaultNotifications,
      );
    }
  }

  @override
  void dispose() {
    if (_ownsViewModel && _viewModel != null) {
      _viewModel!.close();
    }
    super.dispose();
  }

  List<DriverNotificationEntity> get _filteredNotifications {
    if (_selectedFilter == DriverNotificationFilterType.all) {
      return _notifications;
    }
    return _notifications
        .where((n) => n.filterCategory == _selectedFilter)
        .toList();
  }

  void _handleFilterChanged(DriverNotificationFilterType filter) {
    if (_selectedFilter != filter) {
      setState(() {
        _selectedFilter = filter;
      });
    }
  }

  void _handleNotificationTap(DriverNotificationEntity notification) {
    if (!notification.isRead) {
      setState(() {
        final index =
            _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }
      });
    }
  }

  void _handleMarkAllRead() {
    final hasUnread = _notifications.any((n) => !n.isRead);
    if (!hasUnread) return;

    setState(() {
      _notifications = _notifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList();
    });

    final locale = context.localization;
    CustomSnackbar.showSuccess(
      context: context,
      message: locale.driverNotificationsMarkedAllReadSuccess,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_useViewModel || _viewModel == null) {
      return _buildFallbackView(context);
    }

    return BlocProvider.value(
      value: _viewModel!,
      child: BlocConsumer<DriverNotificationsViewModel, DriverNotificationsState>(
        bloc: _viewModel!,
        listenWhen: (previous, current) =>
            previous.status == DriverNotificationsStateStatus.actionLoading &&
            current.status == DriverNotificationsStateStatus.loaded,
        listener: (context, state) {
          final locale = context.localization;
          CustomSnackbar.showSuccess(
            context: context,
            message: locale.driverNotificationsMarkedAllReadSuccess,
          );
        },
        builder: (context, state) {
          final color = context.colorScheme;
          final locale = context.localization;

          if (state.isLoading && state.notifications.isEmpty) {
            return Scaffold(
              backgroundColor: color.surface,
              appBar: DriverNotificationsHeader(
                onBack: widget.onBack,
                onSettingsTap: widget.onSettingsTap,
              ),
              body: const SafeArea(
                top: false,
                child: DriverNotificationsShimmer(),
              ),
            );
          }

          if (state.status == DriverNotificationsStateStatus.error &&
              state.notifications.isEmpty) {
            return Scaffold(
              backgroundColor: color.surface,
              appBar: DriverNotificationsHeader(
                onBack: widget.onBack,
                onSettingsTap: widget.onSettingsTap,
              ),
              body: SafeArea(
                top: false,
                child: Center(
                  child: state.failure != null
                      ? ApiErrorWidget.fromTypedFailure(
                          failure: state.failure!,
                          onRetry: () => _viewModel!.doIntent(
                            const DriverNotificationsLoadEvent(),
                          ),
                        )
                      : Text(
                          state.errorMessage ?? locale.somethingWentWrong,
                          style: getRegularStyle(
                            color: color.onSurfaceVariant,
                            fontSize: FontSize.size14,
                          ),
                        ),
                ),
              ),
            );
          }

          final filtered = state.filteredNotifications;
          final todayNotifications = filtered.where((n) => n.isToday).toList();
          final yesterdayNotifications =
              filtered.where((n) => !n.isToday).toList();

          final content = Scaffold(
            backgroundColor: color.surface,
            appBar: DriverNotificationsHeader(
              onBack: widget.onBack,
              onSettingsTap: widget.onSettingsTap,
            ),
            body: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DriverNotificationsFilterTabBar(
                    selectedFilter: state.selectedFilter,
                    onFilterChanged: (filter) => _viewModel!.doIntent(
                      DriverNotificationsFilterChangedEvent(filter),
                    ),
                  ),
                  if (state.failure != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.base,
                        vertical: Spacing.xs,
                      ),
                      child: InlineApiErrorWidget(
                        failure: state.failure!,
                        onRetry: () => _viewModel!.doIntent(
                          const DriverNotificationsRefreshEvent(),
                        ),
                      ),
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _viewModel!.doIntent(
                          const DriverNotificationsRefreshEvent(),
                        );
                      },
                      child: filtered.isEmpty
                          ? LayoutBuilder(
                              builder: (context, constraints) => SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Center(
                                    child: Text(
                                      locale.driverNotificationsEmpty,
                                      style: getRegularStyle(
                                        color: color.onSurfaceVariant,
                                        fontSize: FontSize.size14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.base,
                                vertical: Spacing.sm,
                              ),
                              children: [
                                if (todayNotifications.isNotEmpty) ...[
                                  DriverNotificationsSectionHeader(
                                    title:
                                        locale.driverNotificationsSectionToday,
                                  ),
                                  const SizedBox(height: Spacing.xs),
                                  for (final notification
                                      in todayNotifications) ...[
                                    DriverNotificationCard(
                                      notification: notification,
                                      onTap: () => _viewModel!.doIntent(
                                        DriverNotificationsMarkReadEvent(
                                          notification.id,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: Spacing.sm),
                                  ],
                                ],
                                if (yesterdayNotifications.isNotEmpty) ...[
                                  const SizedBox(height: Spacing.xs),
                                  DriverNotificationsSectionHeader(
                                    title: locale
                                        .driverNotificationsSectionYesterday,
                                  ),
                                  const SizedBox(height: Spacing.xs),
                                  for (final notification
                                      in yesterdayNotifications) ...[
                                    DriverNotificationCard(
                                      notification: notification,
                                      onTap: () => _viewModel!.doIntent(
                                        DriverNotificationsMarkReadEvent(
                                          notification.id,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: Spacing.sm),
                                  ],
                                ],
                                const SizedBox(height: Spacing.md),
                                DriverNotificationsMarkAllButton(
                                  onPressed: () => _viewModel!.doIntent(
                                    const DriverNotificationsMarkAllReadEvent(),
                                  ),
                                ),
                                const SizedBox(height: Spacing.base),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );

          if (state.isActionLoading) {
            return Stack(
              children: [
                content,
                const ModalBarrier(dismissible: false, color: Colors.black26),
                const Center(child: CustomProgressIndicator()),
              ],
            );
          }

          return content;
        },
      ),
    );
  }

  Widget _buildFallbackView(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final filtered = _filteredNotifications;
    final todayNotifications = filtered.where((n) => n.isToday).toList();
    final yesterdayNotifications = filtered.where((n) => !n.isToday).toList();

    return Scaffold(
      backgroundColor: color.surface,
      appBar: DriverNotificationsHeader(
        onBack: widget.onBack,
        onSettingsTap: widget.onSettingsTap,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DriverNotificationsFilterTabBar(
              selectedFilter: _selectedFilter,
              onFilterChanged: _handleFilterChanged,
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        locale.driverNotificationsEmpty,
                        style: getRegularStyle(
                          color: color.onSurfaceVariant,
                          fontSize: FontSize.size14,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.base,
                        vertical: Spacing.sm,
                      ),
                      children: [
                        if (todayNotifications.isNotEmpty) ...[
                          DriverNotificationsSectionHeader(
                            title: locale.driverNotificationsSectionToday,
                          ),
                          const SizedBox(height: Spacing.xs),
                          for (final notification in todayNotifications) ...[
                            DriverNotificationCard(
                              notification: notification,
                              onTap: () => _handleNotificationTap(notification),
                            ),
                            const SizedBox(height: Spacing.sm),
                          ],
                        ],
                        if (yesterdayNotifications.isNotEmpty) ...[
                          const SizedBox(height: Spacing.xs),
                          DriverNotificationsSectionHeader(
                            title: locale.driverNotificationsSectionYesterday,
                          ),
                          const SizedBox(height: Spacing.xs),
                          for (final notification in yesterdayNotifications) ...[
                            DriverNotificationCard(
                              notification: notification,
                              onTap: () => _handleNotificationTap(notification),
                            ),
                            const SizedBox(height: Spacing.sm),
                          ],
                        ],
                        const SizedBox(height: Spacing.md),
                        DriverNotificationsMarkAllButton(
                          onPressed: _handleMarkAllRead,
                        ),
                        const SizedBox(height: Spacing.base),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
