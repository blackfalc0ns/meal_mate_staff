import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../../core/errors/error_widgets/empty_state_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/services/token_service.dart';
import '../../domain/entities/dispatcher_metric_entity.dart';
import '../../domain/entities/dispatcher_metric_type.dart';
import '../../domain/entities/dispatcher_order_entity.dart';
import '../../domain/entities/dispatcher_order_queue_entity.dart';
import '../manager/dispatcher_orders_event.dart';
import '../manager/dispatcher_orders_state.dart';
import '../manager/dispatcher_orders_view_model.dart';
import '../widgets/dispatcher_filter_bar.dart';
import '../widgets/dispatcher_metrics_grid.dart';
import '../widgets/dispatcher_orders_list.dart';
import '../widgets/dispatcher_orders_shimmer.dart';
import '../widgets/dispatcher_title_section.dart';
import '../widgets/dispatcher_top_header.dart';

class DispatcherOrdersScreen extends StatefulWidget {
  const DispatcherOrdersScreen({
    super.key,
    this.onAssignOrder,
    this.onOrderDetails,
    this.viewModel,
  });

  final ValueChanged<DispatcherOrderEntity>? onAssignOrder;
  final ValueChanged<DispatcherOrderEntity>? onOrderDetails;
  final DispatcherOrdersViewModel? viewModel;

  @override
  State<DispatcherOrdersScreen> createState() => _DispatcherOrdersScreenState();
}

class _DispatcherOrdersScreenState extends State<DispatcherOrdersScreen> {
  DispatcherOrdersViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel =
        widget.viewModel ??
        (getIt.isRegistered<DispatcherOrdersViewModel>()
            ? getIt<DispatcherOrdersViewModel>()
            : null);
    final canLoad =
        widget.viewModel != null ||
        (getIt.isRegistered<TokenService>() &&
            getIt<TokenService>().isAccessTokenSaved);
    if (canLoad) {
      _viewModel?.doIntent(const LoadDispatcherOrdersEvent());
    }
  }

  @override
  void dispose() {
    if (widget.viewModel == null) {
      _viewModel?.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel;
    if (viewModel == null) {
      return const Scaffold(
        body: SafeArea(child: DispatcherOrdersShimmer()),
      );
    }

    return BlocProvider.value(
      value: viewModel,
      child: BlocBuilder<DispatcherOrdersViewModel, DispatcherOrdersState>(
        builder: (context, state) {
          if (state.queue == null) {
            if (state.failure != null) {
              return Scaffold(
                body: SafeArea(
                  child: ApiErrorWidget(
                    exception: state.failure!.exception,
                    onRetry: () =>
                        viewModel.doIntent(const RetryDispatcherOrdersEvent()),
                  ),
                ),
              );
            }
            return const Scaffold(
              body: SafeArea(child: DispatcherOrdersShimmer()),
            );
          }

          return _content(context, state, state.queue!, viewModel);
        },
      ),
    );
  }

  Widget _content(
    BuildContext context,
    DispatcherOrdersState state,
    DispatcherOrderQueueEntity queue,
    DispatcherOrdersViewModel viewModel,
  ) {
    final color = context.colorScheme;
    final locale = context.localization;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final restaurantName = isArabic
        ? queue.restaurant.nameAr
        : queue.restaurant.nameEn;
    final role = queue.restaurant.role;
    final counts = queue.counts;

    final metrics = [
      DispatcherMetricEntity(
        type: DispatcherMetricType.pendingAssignment,
        count: counts.pendingCount,
      ),
      DispatcherMetricEntity(
        type: DispatcherMetricType.assigned,
        count: counts.assignedCount,
      ),
      DispatcherMetricEntity(
        type: DispatcherMetricType.inDelivery,
        count: counts.inDeliveryCount,
      ),
      DispatcherMetricEntity(
        type: DispatcherMetricType.problems,
        count: counts.issuesCount,
      ),
    ];

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              viewModel.doIntent(const RefreshDispatcherOrdersEvent()),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DispatcherTopHeader(restaurantName: restaurantName, role: role),
                const SizedBox(height: Spacing.xs),
                const DispatcherTitleSection(),
                const SizedBox(height: Spacing.xs),
                DispatcherMetricsGrid(metrics: metrics),
                const SizedBox(height: Spacing.xs),
                DispatcherFilterBar(
                  selectedFilter: state.selectedFilter,
                  counts: counts,
                  onFilterSelected: (filter) {
                    viewModel.doIntent(SelectDispatcherFilterEvent(filter));
                  },
                ),
                const SizedBox(height: Spacing.xs),
                if (state.isLoading)
                  const DispatcherCardsShimmer()
                else if (queue.boxes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.screenH,
                      vertical: Spacing.xl,
                    ),
                    child: EmptyStateWidget(
                      title: locale.dispatcherNoOrdersTitle,
                      description: locale.dispatcherNoOrdersSubtitle,
                      onAction: () => viewModel.doIntent(
                        const RefreshDispatcherOrdersEvent(),
                      ),
                      actionText: isArabic ? 'تحديث' : 'Refresh',
                    ),
                  )
                else
                  DispatcherOrdersList(
                    orders: queue.boxes,
                    onAssignOrder:
                        widget.onAssignOrder ??
                        (_) => context.pushNamed(AppRoutes.assignBox),
                    onOrderDetails: widget.onOrderDetails,
                  ),
                const SizedBox(height: Spacing.base),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
