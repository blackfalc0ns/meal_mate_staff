import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../features/auth/domain/user_role.dart';
import '../../domain/entities/sidebar_item_entity.dart';
import '../../domain/entities/sidebar_user_entity.dart';
import '../../domain/fake_data/sidebar_fake_data.dart';
import '../../../extensions/extensions.dart';
import 'sidebar_driver_status_card.dart';
import 'sidebar_logout_button.dart';
import 'sidebar_nav_list.dart';
import 'sidebar_user_header.dart';
import 'sidebar_version_footer.dart';

/// Shared navigation sidebar (Drawer) used across Driver and Dispatcher roles.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    this.role = UserRole.operations,
    this.user,
    this.items,
    this.activeItemId = 'home',
    this.onItemSelected,
    this.onLogout,
    this.width = 280.0,
  });

  final UserRole role;
  final SidebarUserEntity? user;
  final List<SidebarItemEntity>? items;
  final String activeItemId;
  final ValueChanged<SidebarItemEntity>? onItemSelected;
  final VoidCallback? onLogout;
  final double width;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    final resolvedUser = user ?? SidebarFakeData.getDefaultUser(role);
    final resolvedItems = items ??
        SidebarFakeData.getDefaultItems(
          role: role,
          activeId: activeItemId,
        );

    return Drawer(
      width: width,
      backgroundColor: color.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SidebarUserHeader(user: resolvedUser),
              const SizedBox(height: Spacing.sm),
              SidebarNavList(
                items: resolvedItems,
                onItemTap: onItemSelected,
              ),
              const SizedBox(height: Spacing.base),
              if (role == UserRole.driver) ...[
                SidebarDriverStatusCard(user: resolvedUser),
                const SizedBox(height: Spacing.base),
              ],
              SidebarLogoutButton(onLogout: onLogout),
              const SizedBox(height: Spacing.base),
              SidebarVersionFooter(version: resolvedUser.appVersion),
              const SizedBox(height: Spacing.base),
            ],
          ),
        ),
      ),
    );
  }
}
