import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';
import '../../extensions/extensions.dart';
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
    final l10n = context.localization;
    return BaseErrorWidget(
      title: l10n.somethingWentWrong,
      description: serverMessage ?? errorType.localizedMessage(context),
      icon: Icons.warning_amber_rounded,
      onRetry: onRetry,
      onSecondaryAction: onGoBack,
      secondaryActionText: onGoBack == null ? null : l10n.goBack,
      primaryColor: AppColors.warning,
    );
  }
}
