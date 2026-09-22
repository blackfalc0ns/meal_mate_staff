import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';
import '../../extensions/extensions.dart';
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
    final l10n = context.localization;
    return BaseErrorWidget(
      title: l10n.noInternetConnection,
      description: l10n.noInternetConnectionDesc,
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
      onSecondaryAction: onCheckConnection,
      secondaryActionText: onCheckConnection == null
          ? null
          : l10n.checkConnection,
      primaryColor: AppColors.warning,
    );
  }
}
