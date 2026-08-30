import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';
import '../api_error_type.dart';
import 'base_error_widget.dart';

class GenericErrorWidget extends StatelessWidget {
  const GenericErrorWidget({
    super.key,
    required this.errorType,
    this.serverMessage,
    this.onRetry,
    this.onGoBack,
  });

  final ApiErrorType errorType;
  final String? serverMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;

  @override
  Widget build(BuildContext context) {
    return BaseErrorWidget(
      title: 'Something went wrong',
      description: serverMessage ?? errorType.message,
      icon: Icons.warning_amber_rounded,
      onRetry: onRetry,
      onSecondaryAction: onGoBack,
      secondaryActionText: onGoBack == null ? null : 'Go back',
      primaryColor: AppColors.warning,
    );
  }
}
