import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_active_call_entity.dart';
import '../../domain/fake_data/driver_calling_fake_data.dart';
import '../widgets/driver_call_address_card.dart';
import '../widgets/driver_call_avatar.dart';
import '../widgets/driver_call_controls_row.dart';
import '../widgets/driver_call_header.dart';
import '../widgets/driver_call_top_bar.dart';

class DriverActiveCallScreen extends StatefulWidget {
  const DriverActiveCallScreen({
    super.key,
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
  State<DriverActiveCallScreen> createState() => _DriverActiveCallScreenState();
}

class _DriverActiveCallScreenState extends State<DriverActiveCallScreen> {
  late final DriverActiveCallEntity _activeCall;
  late final ValueNotifier<int> _secondsNotifier;
  late final ValueNotifier<bool> _isSpeakerOnNotifier;
  late final ValueNotifier<bool> _isMutedNotifier;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _activeCall = widget.callData ?? DriverCallingFakeData.activeCall;
    _secondsNotifier = ValueNotifier<int>(_activeCall.initialDurationSeconds);
    _isSpeakerOnNotifier = ValueNotifier<bool>(false);
    _isMutedNotifier = ValueNotifier<bool>(false);

    if (widget.enableTimer) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _secondsNotifier.value++;
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

  void _handleEndCall() {
    if (widget.onEndCall != null) {
      widget.onEndCall!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _secondsNotifier.dispose();
    _isSpeakerOnNotifier.dispose();
    _isMutedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

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
                        valueListenable: _secondsNotifier,
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
                        valueListenable: _isSpeakerOnNotifier,
                        builder: (context, isSpeakerOn, _) {
                          return ValueListenableBuilder<bool>(
                            valueListenable: _isMutedNotifier,
                            builder: (context, isMuted, _) {
                              return DriverCallControlsRow(
                                isSpeakerOn: isSpeakerOn,
                                isMuted: isMuted,
                                onToggleSpeaker: () {
                                  _isSpeakerOnNotifier.value =
                                      !_isSpeakerOnNotifier.value;
                                },
                                onToggleMute: () {
                                  _isMutedNotifier.value =
                                      !_isMutedNotifier.value;
                                },
                                onEndCall: _handleEndCall,
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
