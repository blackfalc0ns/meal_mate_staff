import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../../core/errors/error_widgets/empty_state_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/services/token_service.dart';
import '../../domain/entities/dispatcher_home_alert_entity.dart';
import '../../domain/entities/dispatcher_home_kpi_entity.dart';
import '../../domain/entities/dispatcher_home_operations_status_entity.dart';
import '../../domain/entities/dispatcher_home_overview_entity.dart';
import '../../domain/entities/dispatcher_home_quick_action_entity.dart';
import '../manager/dispatcher_home_event.dart';
import '../manager/dispatcher_home_state.dart';
import '../manager/dispatcher_home_view_model.dart';
import '../widgets/dispatcher_home_alert_banner.dart';
import '../widgets/dispatcher_home_areas_card.dart';
import '../widgets/dispatcher_home_drivers_card.dart';
import '../widgets/dispatcher_home_header.dart';
import '../widgets/dispatcher_home_kpi_row.dart';
import '../widgets/dispatcher_home_map_card.dart';
import '../widgets/dispatcher_home_operations_card.dart';
import '../widgets/dispatcher_home_quick_actions.dart';
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
    final canLoad =
        widget.viewModel != null ||
        (getIt.isRegistered<TokenService>() &&
            getIt<TokenService>().isAccessTokenSaved);
    if (canLoad) {
      _viewModel?.doIntent(const DispatcherHomeLoadEvent());
    }
  }

  @override
  void dispose() {
    if (widget.viewModel == null) _viewModel?.close();
    super.dispose();
  }

  void _handleQuickAction(
    BuildContext context,
    DispatcherHomeQuickActionType type,
  ) {
    switch (type) {
      case DispatcherHomeQuickActionType.assignDriver:
        context.pushNamed(AppRoutes.dispatcherOrders);
      case DispatcherHomeQuickActionType.solveIssues:
        context.pushNamed(AppRoutes.dispatcherSupport);
      case DispatcherHomeQuickActionType.driversMap:
        context.pushNamed(AppRoutes.dispatcherMap);
      case DispatcherHomeQuickActionType.allDrivers:
        context.pushNamed(AppRoutes.dispatcherDrivers);
    }
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
    final locale = context.localization;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final operations = _localizedOperations(
      overview.operationsStatus,
      isArabic,
    );
    final quickActions = <DispatcherHomeQuickActionEntity>[
      DispatcherHomeQuickActionEntity(
        type: DispatcherHomeQuickActionType.assignDriver,
        title: locale.homeActionAssignDriver,
        iconAsset: AppAssets.dispatcherHomeActionAssignDriver,
      ),
      DispatcherHomeQuickActionEntity(
        type: DispatcherHomeQuickActionType.solveIssues,
        title: locale.homeActionSolveIssues,
        iconAsset: AppAssets.dispatcherHomeActionSolveIssues,
      ),
      DispatcherHomeQuickActionEntity(
        type: DispatcherHomeQuickActionType.driversMap,
        title: locale.homeActionDriversMap,
        iconAsset: AppAssets.dispatcherHomeActionDriversMap,
      ),
      DispatcherHomeQuickActionEntity(
        type: DispatcherHomeQuickActionType.allDrivers,
        title: locale.homeActionAllDrivers,
        iconAsset: AppAssets.dispatcherHomeActionAllDrivers,
      ),
    ];

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
                DispatcherHomeHeader(
                  restaurantName: isArabic
                      ? overview.restaurant.nameAr
                      : overview.restaurant.nameEn,
                  role: overview.restaurant.role,
                  greeting: overview.greeting.title,
                  greetingSubtitle: overview.greeting.subtitle,
                ),
                const SizedBox(height: Spacing.base),
                DispatcherHomeKpiRow(items: _kpis(overview, isArabic)),
                const SizedBox(height: Spacing.lg),
                DispatcherHomeQuickActions(
                  actions: quickActions,
                  onActionTap: (type) => _handleQuickAction(context, type),
                ),
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
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 9,
                        child: DispatcherHomeOperationsCard(
                          operations: operations,
                          onViewReports: () =>
                              context.pushNamed(AppRoutes.dispatcherOperations),
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        flex: 11,
                        child: DispatcherHomeDriversCard(
                          drivers: overview.topDrivers,
                          onViewAllDrivers: () =>
                              context.pushNamed(AppRoutes.dispatcherDrivers),
                          onDriverTap: (_) =>
                              context.pushNamed(AppRoutes.dispatcherDrivers),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                DispatcherHomeAreasCard(
                  areas: overview.regions.take(4).toList(growable: false),
                ),
                if (overview.activeIssues.count > 0) ...[
                  const SizedBox(height: Spacing.lg),
                  DispatcherHomeAlertBanner(
                    alert: DispatcherHomeAlertEntity(
                      id: 'active-issues',
                      title: isArabic
                          ? 'هناك ${overview.activeIssues.count} مشكلة تحتاج إلى انتباهك'
                          : '${overview.activeIssues.count} issues need your attention',
                      description: isArabic
                          ? overview.activeIssues.summaryAr
                          : overview.activeIssues.summaryEn,
                    ),
                    onTap: () => context.pushNamed(AppRoutes.dispatcherSupport),
                  ),
                ],
                const SizedBox(height: Spacing.bottomNavHeight + Spacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DispatcherHomeKpiItemEntity> _kpis(
    DispatcherHomeOverviewEntity overview,
    bool isArabic,
  ) => [
    DispatcherHomeKpiItemEntity(
      id: 'total',
      label: isArabic ? "طلبات اليوم" : 'Total orders today',
      value: '${overview.kpis.totalOrdersToday}',
      iconAsset: AppAssets.dispatcherHomeKpiBox,
      accentColorType: DispatcherHomeKpiColorType.purple,
    ),
    DispatcherHomeKpiItemEntity(
      id: 'delivery',
      label: isArabic ? 'في التوصيل' : 'In delivery',
      value: '${overview.kpis.inDeliveryCount}',
      iconAsset: AppAssets.dispatcherHomeKpiTruck,
      accentColorType: DispatcherHomeKpiColorType.blue,
    ),
    DispatcherHomeKpiItemEntity(
      id: 'pending',
      label: isArabic ? 'بانتظار الإسناد' : 'Pending assignment',
      value: '${overview.kpis.pendingAssignmentCount}',
      iconAsset: AppAssets.dispatcherHomeKpiClock,
      accentColorType: DispatcherHomeKpiColorType.orange,
    ),
    DispatcherHomeKpiItemEntity(
      id: 'issues',
      label: isArabic ? 'مشاكل حالية' : 'Active issues',
      value: '${overview.kpis.activeIssuesCount}',
      iconAsset: AppAssets.dispatcherHomeKpiInfo,
      accentColorType: DispatcherHomeKpiColorType.red,
    ),
  ];

  DispatcherHomeOperationsStatusEntity _localizedOperations(
    DispatcherHomeOperationsStatusEntity source,
    bool isArabic,
  ) => DispatcherHomeOperationsStatusEntity(
    completionRate: source.completionRate,
    deliveredCount: source.deliveredCount,
    deliveredLabel: isArabic ? 'تم التوصيل' : 'Delivered',
    inDeliveryCount: source.inDeliveryCount,
    inDeliveryLabel: isArabic ? 'في التوصيل' : 'In delivery',
    pendingCount: source.pendingCount,
    pendingLabel: isArabic ? 'بانتظار الإسناد' : 'Pending assignment',
    cancelledCount: source.cancelledCount,
    cancelledLabel: isArabic ? 'تم الإلغاء' : 'Cancelled',
  );
}
