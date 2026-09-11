import 'package:flutter/material.dart';

import '../../../../config/routing/app_routes.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/account_status_kind.dart';
import '../widgets/account_status_content.dart';

class AccountStatusScreen extends StatelessWidget {
  const AccountStatusScreen({
    super.key,
    required this.kind,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.onHelpPressed,
  });

  final AccountStatusKind kind;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final VoidCallback? onHelpPressed;

  void _handlePrimary(BuildContext context) {
    if (onPrimaryPressed != null) {
      onPrimaryPressed!();
      return;
    }

    switch (kind) {
      case AccountStatusKind.accepted:
        context.pushNamedAndRemoveUntil(
          AppRoutes.appShell,
          (route) => false,
        );
        break;
      case AccountStatusKind.rejected:
      case AccountStatusKind.moreInformationRequired:
        context.pushReplacementNamed(AppRoutes.register);
        break;
      case AccountStatusKind.underReview:
        break;
    }
  }

  void _handleSecondary(BuildContext context) {
    if (onSecondaryPressed != null) {
      onSecondaryPressed!();
      return;
    }

    context.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: AccountStatusContent(
            kind: kind,
            onPrimaryPressed: () => _handlePrimary(context),
            onSecondaryPressed: () => _handleSecondary(context),
            onHelpPressed: onHelpPressed,
          ),
        ),
      ),
    );
  }
}
