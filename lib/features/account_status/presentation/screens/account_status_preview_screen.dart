import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';
import '../../domain/account_status_kind.dart';
import '../widgets/account_status_content.dart';

class AccountStatusPreviewScreen extends StatelessWidget {
  const AccountStatusPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              AccountStatusContent(kind: AccountStatusKind.underReview),
              AccountStatusContent(
                kind: AccountStatusKind.moreInformationRequired,
              ),
              AccountStatusContent(kind: AccountStatusKind.rejected),
              AccountStatusContent(kind: AccountStatusKind.accepted),
            ],
          ),
        ),
      ),
    );
  }
}
