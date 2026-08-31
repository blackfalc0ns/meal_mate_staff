import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: AccountStatusContent(
            kind: kind,
            onPrimaryPressed: onPrimaryPressed,
            onSecondaryPressed: onSecondaryPressed,
            onHelpPressed: onHelpPressed,
          ),
        ),
      ),
    );
  }
}
