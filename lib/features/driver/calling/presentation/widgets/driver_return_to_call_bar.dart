import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../../config/routing/app_routes.dart';
import '../../domain/entities/voice_call_status.dart';

class DriverReturnToCallBar extends StatelessWidget {
  const DriverReturnToCallBar({
    super.key,
    required this.callId,
    required this.status,
    required this.customerName,
    this.durationSeconds = 0,
    this.onTap,
  });

  final String callId;
  final VoiceCallStatus status;
  final String customerName;
  final int durationSeconds;
  final VoidCallback? onTap;

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (status.isTerminal) {
      return const SizedBox.shrink();
    }

    final isConnected = status == VoiceCallStatus.active;
    final statusText = isConnected
        ? _formatDuration(durationSeconds)
        : (status == VoiceCallStatus.ringing ? 'Ringing...' : 'Dialing...');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ??
            () {
              unawaited(
                Navigator.of(context).pushNamed(
                  AppRoutes.driverActiveCall,
                ),
              );
            },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF095550),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_in_talk,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      customerName.isNotEmpty ? customerName : 'Customer Call',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
