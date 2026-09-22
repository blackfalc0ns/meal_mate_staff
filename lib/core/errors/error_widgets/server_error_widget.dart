import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';
import '../../extensions/extensions.dart';
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
    final l10n = context.localization;
    final codeText = statusCode == null ? '' : ' ($statusCode)';
    return BaseErrorWidget(
      title: '${l10n.serverError}$codeText',
      description: serverMessage ?? serverErrorType.localizedMessage(context),
      icon: Icons.cloud_off_rounded,
      onRetry: onRetry,
      onSecondaryAction: onContactSupport,
      secondaryActionText: onContactSupport == null
          ? null
          : l10n.contactSupport,
      primaryColor: AppColors.error,
    );
  }
}
