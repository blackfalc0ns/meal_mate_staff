import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../../core/errors/error_widgets/empty_state_widget.dart';
import '../../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_map_connection_status.dart';
import '../../domain/entities/dispatcher_map_driver_entity.dart';
import '../../domain/entities/dispatcher_map_kpi_entity.dart';
import '../manager/dispatcher_map_event.dart';
import '../manager/dispatcher_map_state.dart';
import '../manager/dispatcher_map_view_model.dart';
import '../widgets/dispatcher_map_background.dart';
import '../widgets/dispatcher_map_camera_controller.dart';
import '../widgets/dispatcher_map_controls.dart';
import '../widgets/dispatcher_map_drivers_carousel.dart';
import '../widgets/dispatcher_map_header.dart';
import '../widgets/dispatcher_map_kpi_bar.dart';
import '../widgets/dispatcher_map_reconnect_banner.dart';
import '../widgets/dispatcher_map_shimmer.dart';

class DispatcherMapScreen extends StatefulWidget {
  const DispatcherMapScreen({
    super.key,
    this.onBack,
    this.isActive = true,
    this.viewModel,
    this.cameraController,
  });

  final VoidCallback? onBack;
  final bool isActive;
  final DispatcherMapViewModel? viewModel;
  final DispatcherMapCameraController? cameraController;

  @override
  State<DispatcherMapScreen> createState() => _DispatcherMapScreenState();
}

class _DispatcherMapScreenState extends State<DispatcherMapScreen>
    with WidgetsBindingObserver {
  late final DispatcherMapViewModel _viewModel;
  late final DispatcherMapCameraController _cameraController;
  late final ScrollController _carouselScrollController;
  bool _ownsViewModel = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _carouselScrollController = ScrollController();

    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
    } else {
      _viewModel = getIt<DispatcherMapViewModel>();
      _ownsViewModel = true;
    }

    if (widget.cameraController != null) {
      _cameraController = widget.cameraController!;
    } else {
      _cameraController = GoogleMapCameraControllerImpl();
    }

    if (widget.isActive) {
      _viewModel.doIntent(const LoadDispatcherMapEvent());
    }
  }

  @override
  void didUpdateWidget(covariant DispatcherMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _viewModel.doIntent(const DispatcherMapTabActivatedEvent());
      } else {
        _viewModel.doIntent(const DispatcherMapTabDeactivatedEvent());
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isActive) return;
    if (state == AppLifecycleState.resumed) {
      _viewModel.doIntent(const DispatcherMapAppResumedEvent());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _viewModel.doIntent(const DispatcherMapAppPausedEvent());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _carouselScrollController.dispose();
    if (_ownsViewModel) {
      _viewModel.close();
    }
    super.dispose();
  }

  void _handleDriverSelected(DispatcherMapDriverEntity driver) {
    _viewModel.doIntent(SelectDriverDispatcherMapEvent(driver.id));

    if (driver.latitude != null &&
        driver.longitude != null &&
        driver.latitude!.isFinite &&
        driver.longitude!.isFinite) {
      _cameraController.centerOn(
        LatLng(driver.latitude!, driver.longitude!),
      );
    }
  }

  void _handleLocationTap(List<DispatcherMapDriverEntity> drivers, String? selectedId) {
    if (selectedId != null) {
      final selected = drivers.where((d) => d.id == selectedId).firstOrNull;
      if (selected != null &&
          selected.latitude != null &&
          selected.longitude != null &&
          selected.latitude!.isFinite &&
          selected.longitude!.isFinite) {
        _cameraController.centerOn(
          LatLng(selected.latitude!, selected.longitude!),
        );
        return;
      }
    }
    _cameraController.fitDrivers(drivers);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return BlocProvider.value(
      value: _viewModel,
      child: BlocBuilder<DispatcherMapViewModel, DispatcherMapState>(
        builder: (context, state) {
          // Initial Loading / Failure states
          if (state.snapshot == null) {
            if (state.failure != null) {
              return Scaffold(
                backgroundColor: color.surface,
                body: SafeArea(
                  child: ApiErrorWidget(
                    exception: state.failure!.exception,
                    onRetry: () =>
                        _viewModel.doIntent(const RetryDispatcherMapEvent()),
                  ),
                ),
              );
            }
            return const Scaffold(
              body: DispatcherMapShimmer(),
            );
          }

          final drivers = state.drivers;
          final selectedDriverId = state.selectedDriverId;

          return Scaffold(
            backgroundColor: color.surface,
            body: Stack(
              children: [
                // 1. Google Map Background
                Positioned.fill(
                  child: DispatcherMapBackground(
                    drivers: drivers,
                    selectedDriverId: selectedDriverId,
                    onSelectDriver: _handleDriverSelected,
                    cameraController: _cameraController,
                  ),
                ),

                // 2. Top Header & KPI bar with subtle gradient
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color.surface,
                          color.surface.withValues(alpha: 0.92),
                          color.surface.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.8, 1.0],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DispatcherMapHeader(onMenuTap: widget.onBack),
                          const SizedBox(height: Spacing.xs),
                          DispatcherMapKpiBar(
                            kpi: state.kpi ??
                                const DispatcherMapKpiEntity(
                                  activeDriversCount: 0,
                                  inDeliveryCount: 0,
                                  pausedCount: 0,
                                  issuesCount: 0,
                                ),
                          ),
                          if (state.connectionStatus !=
                              DispatcherMapConnectionStatus.connected) ...[
                            const SizedBox(height: Spacing.xs),
                            DispatcherMapReconnectBanner(
                              status: state.connectionStatus,
                              onRetry: () => _viewModel.doIntent(
                                const RetryDispatcherMapRealtimeEvent(),
                              ),
                            ),
                          ],
                          if (state.isRefreshLoading || state.isReconciling) ...[
                            const SizedBox(height: Spacing.xs),
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: color.primary,
                              ),
                            ),
                          ],
                          if (state.failure != null) ...[
                            const SizedBox(height: Spacing.xs),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.base,
                              ),
                              child: InlineApiErrorWidget(
                                failure: state.failure!,
                                onRetry: () => _viewModel.doIntent(
                                  const RefreshDispatcherMapEvent(),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: Spacing.base),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Floating Map Controls
                PositionedDirectional(
                  end: Spacing.base,
                  bottom: Spacing.dispatcherMapBottomCarouselHeight + Spacing.lg,
                  child: DispatcherMapControls(
                    onLocationTap: () =>
                        _handleLocationTap(drivers, selectedDriverId),
                    onZoomInTap: () => _cameraController.zoomIn(),
                    onZoomOutTap: () => _cameraController.zoomOut(),
                  ),
                ),

                // 4. Bottom Driver Carousel or Empty State
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: drivers.isEmpty
                        ? Container(
                            height: Spacing.dispatcherMapBottomCarouselHeight,
                            padding: const EdgeInsets.all(Spacing.base),
                            decoration: BoxDecoration(
                              color: color.surface,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(Spacing.radiusLg),
                              ),
                            ),
                            child: EmptyStateWidget(
                              title: isAr
                                  ? 'لا يوجد سائقين حالياً'
                                  : 'No drivers active',
                              description: isAr
                                  ? 'لا توجد بيانات حركة مباشرة في هذا الوقت'
                                  : 'There are no active drivers to monitor right now.',
                              icon: Icons.delivery_dining_outlined,
                              onAction: () => _viewModel.doIntent(
                                const RefreshDispatcherMapEvent(),
                              ),
                              actionText: isAr ? 'تحديث' : 'Refresh',
                            ),
                          )
                        : DispatcherMapDriversCarousel(
                            drivers: drivers,
                            selectedDriverId: selectedDriverId,
                            onSelectDriver: _handleDriverSelected,
                            scrollController: _carouselScrollController,
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
