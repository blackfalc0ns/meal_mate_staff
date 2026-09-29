import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import 'driver_call_action_button.dart';
import 'driver_call_end_button.dart';

class DriverCallControlsRow extends StatelessWidget {
  const DriverCallControlsRow({
    super.key,
    required this.isSpeakerOn,
    required this.isMuted,
    required this.onToggleSpeaker,
    required this.onToggleMute,
    required this.onEndCall,
  });

  final bool isSpeakerOn;
  final bool isMuted;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onToggleMute;
  final VoidCallback onEndCall;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DriverCallActionButton(
                icon: isSpeakerOn
                    ? Icons.volume_up_rounded
                    : Icons.volume_up_outlined,
                label: locale.driverCallSpeaker,
                isActive: isSpeakerOn,
                onTap: onToggleSpeaker,
              ),
              DriverCallActionButton(
                icon: isMuted ? Icons.mic_off_rounded : Icons.mic_off_outlined,
                label: locale.driverCallMute,
                isActive: isMuted,
                onTap: onToggleMute,
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          DriverCallEndButton(
            onEndCall: onEndCall,
          ),
        ],
      ),
    );
  }
}
