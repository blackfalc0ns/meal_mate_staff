import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_call_attempt_entity.dart';
import '../../domain/fake_data/driver_calling_fake_data.dart';
import 'call_attempt_actions.dart';
import 'call_attempt_alert_banner.dart';
import 'call_attempt_indicator.dart';
import 'call_failed_recovery_options.dart';
import 'customer_call_info_card.dart';

class CustomerCallAttemptsSheet extends StatefulWidget {
  const CustomerCallAttemptsSheet({
    super.key,
    this.initialAttempt,
    this.onStartCall,
    this.onDirectCall,
    this.onReportUnreachable,
  });

  final DriverCallAttemptEntity? initialAttempt;
  final VoidCallback? onStartCall;
  final VoidCallback? onDirectCall;
  final VoidCallback? onReportUnreachable;

  static Future<void> show(
    BuildContext context, {
    DriverCallAttemptEntity? initialAttempt,
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
        onStartCall: onStartCall,
        onDirectCall: onDirectCall,
        onReportUnreachable: onReportUnreachable,
      ),
    );
  }

  @override
  State<CustomerCallAttemptsSheet> createState() =>
      _CustomerCallAttemptsSheetState();
}

class _CustomerCallAttemptsSheetState
    extends State<CustomerCallAttemptsSheet> {
  late final ValueNotifier<DriverCallAttemptEntity> _attemptNotifier;

  @override
  void initState() {
    super.initState();
    _attemptNotifier = ValueNotifier<DriverCallAttemptEntity>(
      widget.initialAttempt ?? DriverCallingFakeData.defaultAttempt,
    );
  }

  @override
  void dispose() {
    _attemptNotifier.dispose();
    super.dispose();
  }

  void _handleStartCall() {
    if (widget.onStartCall != null) {
      widget.onStartCall!();
      return;
    }

    unawaited(_launchInAppCall());
  }

  Future<void> _launchInAppCall() async {
    await context.pushNamed(AppRoutes.driverActiveCall);
    if (!mounted) return;

    final current = _attemptNotifier.value;
    if (current.attemptNumber < 3) {
      _attemptNotifier.value = current.copyWith(
        attemptNumber: current.attemptNumber + 1,
      );
    }
  }

  void _handleDirectCall() {
    if (widget.onDirectCall != null) {
      widget.onDirectCall!();
      return;
    }
    unawaited(Navigator.of(context).maybePop());
  }

  void _handleReportUnreachable() {
    if (widget.onReportUnreachable != null) {
      widget.onReportUnreachable!();
      return;
    }
    Navigator.of(context).pop();
    unawaited(context.pushNamed(AppRoutes.driverReportIssue));
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return ValueListenableBuilder<DriverCallAttemptEntity>(
      valueListenable: _attemptNotifier,
      builder: (context, attempt, _) {
        final isAttempt3 = attempt.attemptNumber >= 3;

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
                const SizedBox(height: Spacing.base),
                CustomerCallInfoCard(
                  customerName: attempt.customerName,
                  customerPhone: attempt.customerPhone,
                  isPhoneUnlocked: attempt.isPhoneUnlocked,
                ),
                const SizedBox(height: Spacing.lg),
                if (!isAttempt3)
                  CallAttemptActions(
                    onCallNowPressed: _handleStartCall,
                    onCancelPressed: () =>
                        unawaited(Navigator.of(context).maybePop()),
                  )
                else
                  CallFailedRecoveryOptions(
                    onDirectCallPressed: _handleDirectCall,
                    onReportUnreachablePressed: _handleReportUnreachable,
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
