import 'package:flutter/material.dart';

import '../../../../config/theme/styles_manager.dart';
import '../../../extensions/extensions.dart';

/// Centered muted footer displaying the application version.
class SidebarVersionFooter extends StatelessWidget {
  const SidebarVersionFooter({
    super.key,
    required this.version,
  });

  final String version;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Center(
      child: Text(
        locale.sidebarAppVersion(version),
        style: getRegularStyle(
          fontSize: 10,
          color: color.onSurfaceVariant,
        ),
      ),
    );
  }
}
