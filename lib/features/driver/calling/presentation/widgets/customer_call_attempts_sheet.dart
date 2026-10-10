import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_call_attempt_entity.dart';
import '../../domain/fake_data/driver_calling_fake_data.dart';
import '../manager/driver_calling_event.dart';
import '../manager/driver_calling_view_model.dart';
import 'call_attempt_actions.dart';
import 'call_attempt_alert_banner.dart';
import 'call_attempt_indicator.dart';
import 'call_failed_recovery_options.dart';
import 'customer_call_info_card.dart';

class CustomerCallAttemptsSheet extends StatelessWidget {
  const CustomerCallAttemptsSheet({
    super.key,
    this.initialAttempt,
    this.tripStopId,
    this.viewModel,
    this.onStartCall,
    this.onDirectCall,
    this.onReportUnreachable,
  });

  final DriverCallAttemptEntity? initialAttempt;
  final String? tripStopId;
  final DriverCallingViewModel? viewModel;
  final VoidCallback? onStartCall;
  final VoidCallback? onDirectCall;
  final VoidCallback? onReportUnreachable;

  static Future<void> show(
    BuildContext context, {
    DriverCallAttemptEntity? initialAttempt,
    String? tripStopId,
    DriverCallingViewModel? viewModel,
    VoidCallback? onStartCall,
    VoidCallback? onDirectCall,
    VoidCallback? onReportUnreachable,
  }) {
    final color = context.colorScheme;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: color.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Spacing.radiusXl),
        ),
      ),
      builder: (sheetContext) => CustomerCallAttemptsSheet(
        initialAttempt: initialAttempt,
        tripStopId: tripStopId,
        viewModel: viewModel,
        onStartCall: onStartCall,
        onDirectCall: onDirectCall,
        onReportUnreachable: onReportUnreachable,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (viewModel != null) {
      return BlocProvider.value(
        value: viewModel!,
        child: _CustomerCallAttemptsSheetView(
          initialAttempt: initialAttempt,
          tripStopId: tripStopId,
          onStartCall: onStartCall,
          onDirectCall: onDirectCall,
          onReportUnreachable: onReportUnreachable,
        ),
      );
    }

    if (getIt.isRegistered<DriverCallingViewModel>()) {
      return BlocProvider.value(
        value: getIt<DriverCallingViewModel>(),
        child: _CustomerCallAttemptsSheetView(
          initialAttempt: initialAttempt,
          tripStopId: tripStopId,
          onStartCall: onStartCall,
          onDirectCall: onDirectCall,
          onReportUnreachable: onReportUnreachable,
        ),
      );
    }

    return _CustomerCallAttemptsSheetView(
      initialAttempt: initialAttempt,
      tripStopId: tripStopId,
      onStartCall: onStartCall,
      onDirectCall: onDirectCall,
      onReportUnreachable: onReportUnreachable,
    );
  }
}

class _CustomerCallAttemptsSheetView extends StatefulWidget {
  const _CustomerCallAttemptsSheetView({
    this.initialAttempt,
    this.tripStopId,
    this.onStartCall,
    this.onDirectCall,
    this.onReportUnreachable,
  });

  final DriverCallAttemptEntity? initialAttempt;
  final String? tripStopId;
  final VoidCallback? onStartCall;
  final VoidCallback? onDirectCall;
  final VoidCallback? onReportUnreachable;

  @override
  State<_CustomerCallAttemptsSheetView> createState() =>
      _CustomerCallAttemptsSheetViewState();
}

class _CustomerCallAttemptsSheetViewState
    extends State<_CustomerCallAttemptsSheetView> {
  late final ValueNotifier<DriverCallAttemptEntity> _attemptNotifier;

  @override
  void initState() {
    super.initState();
    _attemptNotifier = ValueNotifier<DriverCallAttemptEntity>(
      widget.initialAttempt ?? DriverCallingFakeData.defaultAttempt,
    );

    if (widget.tripStopId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          context
              .read<DriverCallingViewModel>()
              .doIntent(CheckEligibilityEvent(widget.tripStopId!));
        } catch (_) {}
      });
    }
  }

  @override
  void dispose() {
    _attemptNotifier.dispose();
    super.dispose();
  }

  Future<void> _handleStartCall(BuildContext context) async {
    if (widget.onStartCall != null) {
      widget.onStartCall!();
      return;
    }

    if (widget.tripStopId != null) {
      try {
        final vm = context.read<DriverCallingViewModel>();
        if (vm.state.isInitiating) return; // prevent double taps
        final attempt = _attemptNotifier.value;
        vm.doIntent(InitiateCallEvent(
          tripStopId: widget.tripStopId!,
          customerName: attempt.customerName,
        ));
      } catch (_) {}
    }

    await context.pushNamed(AppRoutes.driverActiveCall);
    if (!mounted) return;

    final current = _attemptNotifier.value;
    if (current.attemptNumber < 3) {
      _attemptNotifier.value = current.copyWith(
        attemptNumber: current.attemptNumber + 1,
      );
    }
  }

  void _handleDirectCall(BuildContext context) {
    if (widget.onDirectCall != null) {
      widget.onDirectCall!();
      return;
    }

    try {
      final vm = context.read<DriverCallingViewModel>();
      if (vm.state.contactCase?.canRevealPhone == true ||
          vm.state.eligibility?.canRevealPhone == true) {
        vm.doIntent(const RevealPhoneEvent(
          reason: 'Customer unreachable after missed call attempts',
        ));
        return;
      }
    } catch (_) {}

    unawaited(Navigator.of(context).maybePop());
  }

  void _handleReportUnreachable(BuildContext context) {
    if (widget.onReportUnreachable != null) {
      widget.onReportUnreachable!();
      return;
    }

    try {
      final vm = context.read<DriverCallingViewModel>();
      if (vm.state.contactCase?.canHold == true ||
          vm.state.eligibility?.canHold == true) {
        vm.doIntent(const HoldCallEvent(
          notes: 'Customer unreachable after attempts',
        ));
      }
    } catch (_) {}

    Navigator.of(context).pop();
    unawaited(context.pushNamed(AppRoutes.driverReportIssue));
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    DriverCallingViewModel? blocVm;
    try {
      blocVm = context.watch<DriverCallingViewModel>();
    } catch (_) {
      blocVm = null;
    }

    return ValueListenableBuilder<DriverCallAttemptEntity>(
      valueListenable: _attemptNotifier,
      builder: (context, attempt, _) {
        final caseData = blocVm?.state.contactCase;
        final eligibility = blocVm?.state.eligibility;

        final isPhoneUnlocked =
            caseData?.canRevealPhone == true ||
            eligibility?.canRevealPhone == true ||
            attempt.attemptNumber >= 3;

        final isAttempt3 =
            attempt.attemptNumber >= 3 || caseData?.canHold == true;

        final canInitiate = eligibility?.canInitiate ?? true;
        final isInitiating = blocVm?.state.isInitiating ?? false;

        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: Spacing.xxl,
                    height: Spacing.xs,
                    margin: const EdgeInsets.only(bottom: Spacing.md),
                    decoration: BoxDecoration(
                      color: color.outlineVariant.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(Spacing.radiusPill),
                    ),
                  ),
                ),
                CallAttemptAlertBanner(attemptNumber: attempt.attemptNumber),
                Center(
                  child: Container(
                    width: Spacing.xxxl,
                    height: Spacing.xxxl,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.primary.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.phone_in_talk_rounded,
                      size: Spacing.iconMd,
                      color: color.primary,
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  locale.driverCallAttemptTitle,
                  textAlign: TextAlign.center,
                  style: getBoldStyle(
                    fontSize: FontSize.size16,
                    color: color.onSurface,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  locale.driverCallAttemptPrompt(attempt.customerName),
                  textAlign: TextAlign.center,
                  style: getMediumStyle(
                    fontSize: FontSize.size13,
                    color: color.onSurface,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  locale.driverCallAttemptSubtitle,
                  textAlign: TextAlign.center,
                  style: getRegularStyle(
                    fontSize: FontSize.size11,
                    color: color.onSurfaceVariant,
                  ),
                ),
                if (!canInitiate && eligibility?.reasonCode != null) ...[
                  const SizedBox(height: Spacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: color.errorContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(Spacing.radiusSm),
                    ),
                    child: Text(
                      eligibility!.reasonCode,
                      textAlign: TextAlign.center,
                      style: getRegularStyle(
                        fontSize: FontSize.size12,
                        color: color.error,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: Spacing.base),
                CustomerCallInfoCard(
                  customerName: attempt.customerName,
                  customerPhone: attempt.customerPhone,
                  isPhoneUnlocked: isPhoneUnlocked,
                ),
                const SizedBox(height: Spacing.lg),
                if (!isAttempt3)
                  CallAttemptActions(
                    onCallNowPressed: (!canInitiate || isInitiating)
                        ? null
                        : () => _handleStartCall(context),
                    onCancelPressed: () =>
                        unawaited(Navigator.of(context).maybePop()),
                  )
                else
                  CallFailedRecoveryOptions(
                    onDirectCallPressed: () => _handleDirectCall(context),
                    onReportUnreachablePressed: () =>
                        _handleReportUnreachable(context),
                    onCancelPressed: () =>
                        unawaited(Navigator.of(context).maybePop()),
                  ),
                const SizedBox(height: Spacing.base),
                CallAttemptIndicator(currentAttempt: attempt.attemptNumber),
                const SizedBox(height: Spacing.sm),
              ],
            ),
          ),
        );
      },
    );
  }
}
