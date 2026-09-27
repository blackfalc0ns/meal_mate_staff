import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/routing/arguments/dispatcher_map_route_arguments.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_snak_bar.dart';
import '../../../dispatcher_driver_details/presentation/services/driver_contact_launcher.dart';
import '../../data/data_source/dispatcher_driver_details_fake_data.dart';
import '../../domain/entities/dispatcher_driver_details_entity.dart';
import '../widgets/dispatcher_driver_details_app_bar.dart';
import '../widgets/dispatcher_driver_details_contact_card.dart';
import '../widgets/dispatcher_driver_details_documents_card.dart';
import '../widgets/dispatcher_driver_details_location_card.dart';
import '../widgets/dispatcher_driver_details_metrics_row.dart';
import '../widgets/dispatcher_driver_details_performance_card.dart';
import '../widgets/dispatcher_driver_details_profile_card.dart';
import '../widgets/dispatcher_driver_details_vehicle_card.dart';

class DispatcherDriverStatusDetailsScreen extends StatefulWidget {
  const DispatcherDriverStatusDetailsScreen({
    super.key,
    required this.driverId,
    this.initialDetails,
    this.contactLauncher,
    this.onBack,
    this.onOpenMap,
  });

  final String driverId;
  final DispatcherDriverDetailsEntity? initialDetails;
  final DriverContactLauncher? contactLauncher;
  final VoidCallback? onBack;
  final VoidCallback? onOpenMap;

  @override
  State<DispatcherDriverStatusDetailsScreen> createState() =>
      _DispatcherDriverStatusDetailsScreenState();
}

class _DispatcherDriverStatusDetailsScreenState
    extends State<DispatcherDriverStatusDetailsScreen> {
  late DispatcherDriverDetailsEntity _details;
  late final DriverContactLauncher _contactLauncher;

  @override
  void initState() {
    super.initState();
    _details = widget.initialDetails ??
        DispatcherDriverDetailsFakeData.getSampleDriverDetails(
          driverId: widget.driverId,
        );

    _contactLauncher = widget.contactLauncher ??
        (getIt.isRegistered<DriverContactLauncher>()
            ? getIt<DriverContactLauncher>()
            : const DriverContactLauncherImpl());
  }

  void _handleToggleAvailable(bool value) {
    setState(() {
      _details = _details.copyWith(isAvailable: value);
    });
  }

  Future<void> _handleCall() async {
    final success = await _contactLauncher.launchPhone(_details.phoneNumber);
    if (!success && mounted) {
      CustomSnackbar.showError(
        context: context,
        message: context.localization.driverDetailsUnableToCall,
      );
    }
  }

  Future<void> _handleChat() async {
    final success = await _contactLauncher.launchWhatsApp(_details.phoneNumber);
    if (!success && mounted) {
      CustomSnackbar.showError(
        context: context,
        message: context.localization.driverDetailsUnableToWhatsApp,
      );
    }
  }

  void _handleOpenMap() {
    if (widget.onOpenMap != null) {
      widget.onOpenMap!();
      return;
    }

    unawaited(
      Navigator.of(context).pushNamed(
        AppRoutes.dispatcherMap,
        arguments: DispatcherMapRouteArgs(focusDriverId: widget.driverId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DispatcherDriverDetailsAppBar(
        onBack: widget.onBack,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Spacing.xs),
              DispatcherDriverDetailsProfileCard(
                details: _details,
                onToggleAvailable: _handleToggleAvailable,
              ),
              const SizedBox(height: Spacing.sm),
              DispatcherDriverDetailsMetricsRow(
                details: _details,
              ),
              const SizedBox(height: Spacing.sm),
              DispatcherDriverDetailsContactCard(
                phoneNumber: _details.phoneNumber,
                onCall: _handleCall,
                onChat: _handleChat,
              ),
              const SizedBox(height: Spacing.sm),
              DispatcherDriverDetailsVehicleCard(
                vehicle: _details.vehicle,
              ),
              const SizedBox(height: Spacing.sm),
              DispatcherDriverDetailsLocationCard(
                location: _details.location,
                onShowOnMap: _handleOpenMap,
              ),
              const SizedBox(height: Spacing.sm),
              DispatcherDriverDetailsPerformanceCard(
                performance: _details.performance,
              ),
              const SizedBox(height: Spacing.sm),
              DispatcherDriverDetailsDocumentsCard(
                documents: _details.documents,
              ),
              const SizedBox(height: Spacing.bottomNavHeight + Spacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
