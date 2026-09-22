import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../../core/errors/error_widgets/empty_state_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_home_overview_entity.dart';
import '../manager/dispatcher_home_event.dart';
import '../manager/dispatcher_home_state.dart';
import '../manager/dispatcher_home_view_model.dart';
import '../widgets/dispatcher_home_areas_section.dart';
import '../widgets/dispatcher_home_header_section.dart';
import '../widgets/dispatcher_home_issues_banner_section.dart';
import '../widgets/dispatcher_home_kpi_section.dart';
import '../widgets/dispatcher_home_map_card.dart';
import '../widgets/dispatcher_home_operations_drivers_section.dart';
import '../widgets/dispatcher_home_quick_actions_section.dart';
import '../widgets/dispatcher_home_shimmer.dart';

class DispatcherHomeScreen extends StatefulWidget {
  const DispatcherHomeScreen({super.key, this.viewModel});

  final DispatcherHomeViewModel? viewModel;

  @override
  State<DispatcherHomeScreen> createState() => _DispatcherHomeScreenState();
}

class _DispatcherHomeScreenState extends State<DispatcherHomeScreen> {
  DispatcherHomeViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel =
        widget.viewModel ??
        (getIt.isRegistered<DispatcherHomeViewModel>()
            ? getIt<DispatcherHomeViewModel>()
            : null);
    _viewModel?.doIntent(const DispatcherHomeLoadEvent());
  }

  @override
  void dispose() {
    if (widget.viewModel == null) _viewModel?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel;
    if (viewModel == null) {
      return const Scaffold(body: EmptyStateWidget());
    }
    return BlocProvider.value(
      value: viewModel,
      child: BlocBuilder<DispatcherHomeViewModel, DispatcherHomeState>(
        builder: (context, state) {
          if (state.isOverviewLoading && state.overview == null) {
            return const Scaffold(
              body: SafeArea(child: DispatcherHomeShimmer()),
            );
          }
          if (state.overviewFailure != null && state.overview == null) {
            return Scaffold(
              body: SafeArea(
                child: ApiErrorWidget(
                  exception: state.overviewFailure!.exception,
                  onRetry: () => viewModel.doIntent(
                    const DispatcherHomeRetryOverviewEvent(),
                  ),
                ),
              ),
            );
          }
          final overview = state.overview;
          if (overview == null) {
            return const Scaffold(body: EmptyStateWidget());
          }
          return _content(context, state, overview, viewModel);
        },
      ),
    );
  }

  Widget _content(
    BuildContext context,
    DispatcherHomeState state,
    DispatcherHomeOverviewEntity overview,
    DispatcherHomeViewModel viewModel,
  ) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            viewModel.doIntent(const DispatcherHomeRefreshEvent());
            await viewModel.stream.firstWhere(
              (next) => !next.isOverviewLoading && !next.isLiveDriversLoading,
            );
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DispatcherHomeHeaderSection(overview: overview),
                const SizedBox(height: Spacing.base),
                DispatcherHomeKpiSection(kpis: overview.kpis),
                const SizedBox(height: Spacing.lg),
                const DispatcherHomeQuickActionsSection(),
                const SizedBox(height: Spacing.lg),
                DispatcherHomeMapCard(
                  pins: state.liveDrivers,
                  isLoading: state.isLiveDriversLoading,
                  failure: state.liveDriversFailure,
                  onRetry: () => viewModel.doIntent(
                    const DispatcherHomeRetryLiveDriversEvent(),
                  ),
                  onViewFullMap: () =>
                      context.pushNamed(AppRoutes.dispatcherMap),
                ),
                const SizedBox(height: Spacing.lg),
                DispatcherHomeOperationsDriversSection(
                  operationsStatus: overview.operationsStatus,
                  topDrivers: overview.topDrivers,
                ),
                const SizedBox(height: Spacing.lg),
                DispatcherHomeAreasSection(regions: overview.regions),
                DispatcherHomeIssuesBannerSection(
                  activeIssues: overview.activeIssues,
                ),
                const SizedBox(height: Spacing.bottomNavHeight + Spacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
