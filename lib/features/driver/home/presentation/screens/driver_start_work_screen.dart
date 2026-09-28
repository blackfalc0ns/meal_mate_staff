import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

import '../manager/driver_start_work_state.dart';
import '../manager/driver_start_work_view_model.dart';
import '../widgets/start_work/driver_start_work_action_button.dart';
import '../widgets/start_work/driver_start_work_header_logo.dart';
import '../widgets/start_work/driver_start_work_status_card.dart';
import '../widgets/start_work/driver_start_work_title_section.dart';

class DriverStartWorkScreen extends StatefulWidget {
  const DriverStartWorkScreen({
    super.key,
    this.viewModel,
    this.onStartWorkSuccess,
  });

  final DriverStartWorkViewModel? viewModel;
  final VoidCallback? onStartWorkSuccess;

  @override
  State<DriverStartWorkScreen> createState() => _DriverStartWorkScreenState();
}

class _DriverStartWorkScreenState extends State<DriverStartWorkScreen> {
  late final DriverStartWorkViewModel _viewModel;
  bool _isLocalLoading = false;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ??
        (getIt.isRegistered<DriverStartWorkViewModel>()
            ? getIt<DriverStartWorkViewModel>()
            : DriverStartWorkViewModel(
                getDriverStartWorkUseCase: getIt(),
                startDriverShiftUseCase: getIt(),
              ));
    unawaited(_viewModel.loadOverview());
  }

  Future<void> _handleStartWork() async {
    setState(() => _isLocalLoading = true);
    await _viewModel.startShift();
    if (!mounted) return;
    setState(() => _isLocalLoading = false);

    if (widget.onStartWorkSuccess != null) {
      widget.onStartWorkSuccess!();
    } else {
      context.pushNamed(AppRoutes.driverHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return BlocBuilder<DriverStartWorkViewModel, DriverStartWorkState>(
      bloc: _viewModel,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: color.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.screenH,
                vertical: Spacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: Spacing.xs),
                  const DriverStartWorkHeaderLogo(),
                  const SizedBox(height: Spacing.base),
                  const DriverStartWorkTitleSection(),
                  const SizedBox(height: Spacing.base),
                  DriverStartWorkStatusCard(
                    onTap: _handleStartWork,
                  ),
                  const SizedBox(height: Spacing.xl),
                  DriverStartWorkActionButton(
                    isLoading: _isLocalLoading,
                    onPressed: _handleStartWork,
                  ),
                  const SizedBox(height: Spacing.base),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
