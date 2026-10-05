import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/inline_api_error_widget.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'package:meal_mate_delivery/core/widget/custom_app_bar.dart';

import '../../domain/entities/driver_home_entity.dart';
import '../manager/driver_home_event.dart';
import '../manager/driver_home_state.dart';
import '../manager/driver_home_view_model.dart';
import '../widgets/active_home/driver_active_home_view.dart';
import '../widgets/driver_home_shimmer.dart';
import '../widgets/inactive_home/driver_inactive_home_view.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({
    super.key,
    this.viewModel,
    this.onNotificationTap,
    this.onMenuTap,
    this.onOrderDetailsTap,
    this.onIssuesTap,
  });

  final DriverHomeViewModel? viewModel;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onOrderDetailsTap;
  final VoidCallback? onIssuesTap;

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with WidgetsBindingObserver {
  late final DriverHomeViewModel _viewModel;
  late final bool _isInternalViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
      _isInternalViewModel = false;
    } else if (getIt.isRegistered<DriverHomeViewModel>()) {
      _viewModel = getIt<DriverHomeViewModel>();
      _isInternalViewModel = false;
    } else {
      _viewModel = DriverHomeViewModel(getDriverHomeUseCase: getIt());
      _isInternalViewModel = true;
    }

    unawaited(_viewModel.doIntent(const DriverHomeInitialLoadEvent()));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isInternalViewModel) {
      unawaited(_viewModel.close());
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_viewModel.doIntent(const DriverHomeLifecycleResumeEvent()));
    }
  }

  void _handleMenuTap() {
    if (widget.onMenuTap != null) {
      widget.onMenuTap!();
      return;
    }
    final rootScaffold = context.findRootAncestorStateOfType<ScaffoldState>();
    if (rootScaffold != null && rootScaffold.hasDrawer) {
      rootScaffold.openDrawer();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _handleNotificationTap() {
    if (widget.onNotificationTap != null) {
      widget.onNotificationTap!();
    } else {
      unawaited(context.pushNamed(AppRoutes.driverNotifications));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return BlocBuilder<DriverHomeViewModel, DriverHomeState>(
      bloc: _viewModel,
      builder: (context, state) {
        final home = state.home;
        final isActive = home?.shiftStatus == DriverShiftStatus.active;
        final unreadCount = home?.unreadNotificationsCount ?? 0;
        final showNotificationBadge = isActive && unreadCount > 0;

        return Scaffold(
          backgroundColor: color.surface,
          appBar: CustomAppBar(
            showBackButton: false,
            backgroundColor: color.surface,
            leading: IconButton(
              onPressed: _handleMenuTap,
              icon: Icon(Icons.menu_rounded, color: color.onSurface, size: 28),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            titleWidget: Image.asset(
              AppAssets.authHeaderLogo,
              height: 28,
              fit: BoxFit.contain,
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: Spacing.screenH),
                child: InkWell(
                  onTap: _handleNotificationTap,
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.surface,
                      borderRadius: BorderRadius.circular(Spacing.radiusMd),
                      border: Border.all(
                        color: color.outlineVariant.withValues(alpha: 0.5),
                        width: Spacing.hairline,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_rounded,
                          color: Color(0xFF1E293B),
                          size: 22,
                        ),
                        if (showNotificationBadge)
                          Positioned(
                            top: 10,
                            right: 11,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: color.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(child: _buildBody(context, state)),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DriverHomeState state) {
    final home = state.home;

    // 1. Initial loading shimmer
    if (state.isLoading && home == null) {
      return const DriverHomeShimmer();
    }

    // 2. Initial error widget
    if (state.failure != null && home == null) {
      return ApiErrorWidget.fromTypedFailure(
        failure: state.failure!,
        onRetry: () => _viewModel.doIntent(const DriverHomeRetryEvent()),
      );
    }

    // 3. Loaded content
    if (home != null) {
      final isInactive = home.shiftStatus == DriverShiftStatus.inactive;

      return Column(
        children: [
          // Inline refresh error banner
          if (state.failure != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.screenH,
                vertical: Spacing.xs,
              ),
              child: InlineApiErrorWidget(
                failure: state.failure!,
                onRetry: () =>
                    _viewModel.doIntent(const DriverHomeRetryEvent()),
              ),
            ),
          Expanded(
            child: isInactive
                ? DriverInactiveHomeView(
                    home: home,
                    onRefresh: () =>
                        _viewModel.doIntent(const DriverHomeRetryEvent()),
                  )
                : DriverActiveHomeView(
                    home: home,
                    onRefresh: () =>
                        _viewModel.doIntent(const DriverHomeRetryEvent()),
                    onOrderDetailsTap: widget.onOrderDetailsTap,
                    onIssuesTap: widget.onIssuesTap,
                  ),
          ),
        ],
      );
    }

    return const DriverHomeShimmer();
  }
}
