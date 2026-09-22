import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';
import '../../extensions/extensions.dart';
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
    final l10n = context.localization;
    return BaseErrorWidget(
      title: l10n.connectionTimeout,
      description: timeoutType.localizedMessage(context),
      icon: Icons.schedule_rounded,
      onRetry: onRetry,
      primaryColor: AppColors.warning,
    );
  }
}
