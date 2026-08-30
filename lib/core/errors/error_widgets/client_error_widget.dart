import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';
import '../api_error_type.dart';
import 'base_error_widget.dart';

class ClientErrorWidget extends StatelessWidget {
  const ClientErrorWidget({
    super.key,
    required this.clientErrorType,
    this.statusCode,
    this.serverMessage,
    this.onRetry,
    this.onGoBack,
  });

  final ApiErrorType clientErrorType;
  final int? statusCode;
  final String? serverMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;

  @override
  Widget build(BuildContext context) {
    final codeText = statusCode == null ? '' : ' ($statusCode)';
    return BaseErrorWidget(
      title: 'Request error$codeText',
      description: serverMessage ?? clientErrorType.message,
      icon: Icons.error_outline_rounded,
      onRetry: onRetry,
      onSecondaryAction: onGoBack,
      secondaryActionText: onGoBack == null ? null : 'Go back',
      primaryColor: AppColors.error,
    );
  }
}
