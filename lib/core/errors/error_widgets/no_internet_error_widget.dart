import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';
import 'base_error_widget.dart';

class NoInternetErrorWidget extends StatelessWidget {
  const NoInternetErrorWidget({
    super.key,
    this.onRetry,
    this.onCheckConnection,
  });

  final VoidCallback? onRetry;
  final VoidCallback? onCheckConnection;

  @override
  Widget build(BuildContext context) {
    return BaseErrorWidget(
      title: 'No internet connection',
      description: 'Check your connection and try again.',
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
      onSecondaryAction: onCheckConnection,
      secondaryActionText: onCheckConnection == null
          ? null
          : 'Check connection',
      primaryColor: AppColors.warning,
    );
  }
}
