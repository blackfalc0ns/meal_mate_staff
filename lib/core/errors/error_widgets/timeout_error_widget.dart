import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';
import '../api_error_type.dart';
import 'base_error_widget.dart';

class TimeoutErrorWidget extends StatelessWidget {
  const TimeoutErrorWidget({
    super.key,
    required this.timeoutType,
    this.onRetry,
  });

  final ApiErrorType timeoutType;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return BaseErrorWidget(
      title: 'Connection timeout',
      description: timeoutType.message,
      icon: Icons.schedule_rounded,
      onRetry: onRetry,
      primaryColor: AppColors.warning,
    );
  }
}
