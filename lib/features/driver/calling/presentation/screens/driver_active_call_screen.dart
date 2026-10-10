import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_active_call_entity.dart';
import '../../domain/entities/voice_call_status.dart';
import '../../domain/fake_data/driver_calling_fake_data.dart';
import '../manager/driver_calling_event.dart';
import '../manager/driver_calling_state.dart';
import '../manager/driver_calling_view_model.dart';
import '../widgets/driver_call_address_card.dart';
import '../widgets/driver_call_avatar.dart';
import '../widgets/driver_call_controls_row.dart';
import '../widgets/driver_call_header.dart';
import '../widgets/driver_call_top_bar.dart';

class DriverActiveCallScreen extends StatelessWidget {
  const DriverActiveCallScreen({
    super.key,
    this.callData,
    this.onEndCall,
    this.onDismiss,
    this.enableTimer = true,
    this.viewModel,
  });

  final DriverActiveCallEntity? callData;
  final VoidCallback? onEndCall;
  final VoidCallback? onDismiss;
  final bool enableTimer;
  final DriverCallingViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel != null) {
      return BlocProvider.value(
        value: viewModel!,
        child: _DriverActiveCallView(
          callData: callData,
          onEndCall: onEndCall,
          onDismiss: onDismiss,
          enableTimer: enableTimer,
        ),
      );
    }

    if (getIt.isRegistered<DriverCallingViewModel>()) {
      return BlocProvider.value(
        value: getIt<DriverCallingViewModel>(),
        child: _DriverActiveCallView(
          callData: callData,
          onEndCall: onEndCall,
          onDismiss: onDismiss,
          enableTimer: enableTimer,
        ),
      );
    }

    return _DriverActiveCallView(
      callData: callData,
      onEndCall: onEndCall,
      onDismiss: onDismiss,
      enableTimer: enableTimer,
    );
  }
}

class _DriverActiveCallView extends StatefulWidget {
  const _DriverActiveCallView({
    this.callData,
    this.onEndCall,
    this.onDismiss,
    this.enableTimer = true,
  });

  final DriverActiveCallEntity? callData;
  final VoidCallback? onEndCall;
  final VoidCallback? onDismiss;
  final bool enableTimer;

  @override
  State<_DriverActiveCallView> createState() => _DriverActiveCallViewState();
}

class _DriverActiveCallViewState extends State<_DriverActiveCallView> {
  late final DriverActiveCallEntity _activeCall;
  late final ValueNotifier<int> _fallbackSecondsNotifier;
  late final ValueNotifier<bool> _fallbackSpeakerNotifier;
  late final ValueNotifier<bool> _fallbackMutedNotifier;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _activeCall = widget.callData ?? DriverCallingFakeData.activeCall;
    _fallbackSecondsNotifier =
        ValueNotifier<int>(_activeCall.initialDurationSeconds);
    _fallbackSpeakerNotifier = ValueNotifier<bool>(false);
    _fallbackMutedNotifier = ValueNotifier<bool>(false);

    if (widget.enableTimer) {
      _startFallbackTimer();
    }
  }

  void _startFallbackTimer() {
    _fallbackTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _fallbackSecondsNotifier.value++;
      }
    });
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  void _handleEndCall(BuildContext context) {
    if (widget.onEndCall != null) {
      widget.onEndCall!();
      return;
    }

    try {
      final vm = context.read<DriverCallingViewModel>();
      vm.doIntent(const EndCallEvent());
    } catch (_) {}

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _fallbackSecondsNotifier.dispose();
    _fallbackSpeakerNotifier.dispose();
    _fallbackMutedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    // Check if DriverCallingViewModel is available via Bloc
    DriverCallingViewModel? blocVm;
    try {
      blocVm = context.watch<DriverCallingViewModel>();
    } catch (_) {
      blocVm = null;
    }

    if (blocVm != null) {
      return BlocConsumer<DriverCallingViewModel, DriverCallingState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status.isTerminal || state.status == VoiceCallStatus.ended) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }
        },
        builder: (context, state) {
          final displayCall = state.activeCallData ?? _activeCall;
          final effectiveAddress =
              (state.displayData?.deliveryAddress?.isNotEmpty ?? false)
                  ? state.displayData!.deliveryAddress!
                  : displayCall.addressLine;
          final effectiveArea =
              (state.displayData?.deliveryZone?.isNotEmpty ?? false)
                  ? state.displayData!.deliveryZone!
                  : displayCall.area;
          final durationText = state.status == VoiceCallStatus.active
              ? _formatDuration(state.durationSeconds)
              : switch (state.status) {
                  VoiceCallStatus.ringing => 'Ringing...',
                  VoiceCallStatus.connecting ||
                  VoiceCallStatus.accepted =>
                    'Connecting...',
                  _ => _formatDuration(state.durationSeconds),
                };

          return Scaffold(
            backgroundColor: color.inverseSurface,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            DriverCallTopBar(
                              onDismiss: widget.onDismiss,
                            ),
                            const SizedBox(height: Spacing.sm),
                            DriverCallHeader(
                              customerName: displayCall.customerName,
                              durationText: durationText,
                            ),
                            const Spacer(flex: 2),
                            const DriverCallAvatar(),
                            const Spacer(flex: 3),
                            DriverCallAddressCard(
                              addressLine: effectiveAddress,
                              area: effectiveArea,
                            ),
                            const SizedBox(height: Spacing.xl),
                            DriverCallControlsRow(
                              isSpeakerOn: state.isSpeakerOn,
                              isMuted: state.isMuted,
                              onToggleSpeaker: () {
                                context
                                    .read<DriverCallingViewModel>()
                                    .doIntent(const ToggleSpeakerEvent());
                              },
                              onToggleMute: () {
                                context
                                    .read<DriverCallingViewModel>()
                                    .doIntent(const ToggleMuteEvent());
                              },
                              onEndCall: () => _handleEndCall(context),
                            ),
                            const SizedBox(height: Spacing.xxl),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    }

    // Standalone fallback
    return Scaffold(
      backgroundColor: color.inverseSurface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      DriverCallTopBar(
                        onDismiss: widget.onDismiss,
                      ),
                      const SizedBox(height: Spacing.sm),
                      ValueListenableBuilder<int>(
                        valueListenable: _fallbackSecondsNotifier,
                        builder: (context, seconds, _) {
                          return DriverCallHeader(
                            customerName: _activeCall.customerName,
                            durationText: _formatDuration(seconds),
                          );
                        },
                      ),
                      const Spacer(flex: 2),
                      const DriverCallAvatar(),
                      const Spacer(flex: 3),
                      DriverCallAddressCard(
                        addressLine: _activeCall.addressLine,
                        area: _activeCall.area,
                      ),
                      const SizedBox(height: Spacing.xl),
                      ValueListenableBuilder<bool>(
                        valueListenable: _fallbackSpeakerNotifier,
                        builder: (context, isSpeakerOn, _) {
                          return ValueListenableBuilder<bool>(
                            valueListenable: _fallbackMutedNotifier,
                            builder: (context, isMuted, _) {
                              return DriverCallControlsRow(
                                isSpeakerOn: isSpeakerOn,
                                isMuted: isMuted,
                                onToggleSpeaker: () {
                                  _fallbackSpeakerNotifier.value =
                                      !_fallbackSpeakerNotifier.value;
                                },
                                onToggleMute: () {
                                  _fallbackMutedNotifier.value =
                                      !_fallbackMutedNotifier.value;
                                },
                                onEndCall: () => _handleEndCall(context),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: Spacing.xxl),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
