import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';
import '../api_error_type.dart';
import 'base_error_widget.dart';

class ServerErrorWidget extends StatelessWidget {
  const ServerErrorWidget({
    super.key,
    required this.serverErrorType,
    this.statusCode,
    this.serverMessage,
    this.onRetry,
    this.onContactSupport,
  });

  final ApiErrorType serverErrorType;
  final int? statusCode;
  final String? serverMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onContactSupport;

  @override
  Widget build(BuildContext context) {
    final codeText = statusCode == null ? '' : ' ($statusCode)';
    return BaseErrorWidget(
      title: 'Server error$codeText',
      description: serverMessage ?? serverErrorType.message,
      icon: Icons.cloud_off_rounded,
      onRetry: onRetry,
      onSecondaryAction: onContactSupport,
      secondaryActionText: onContactSupport == null ? null : 'Contact support',
      primaryColor: AppColors.error,
    );
  }
}
