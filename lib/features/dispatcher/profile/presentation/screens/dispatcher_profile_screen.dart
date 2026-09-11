import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';
import '../../../../../core/widget/notification_button.dart';
import '../../domain/entities/dispatcher_notification_setting_entity.dart';
import '../../domain/entities/dispatcher_profile_entity.dart';
import '../../domain/fake_data/dispatcher_profile_fake_data.dart';
import '../widgets/dispatcher_profile_admin_card.dart';
import '../widgets/dispatcher_profile_app_info_card.dart';
import '../widgets/dispatcher_profile_logout_button.dart';
import '../widgets/dispatcher_profile_notification_settings_card.dart';

class DispatcherProfileScreen extends StatefulWidget {
  const DispatcherProfileScreen({
    super.key,
    this.profile,
    this.showBackButton = true,
    this.showBottomNavBar = false,
  });

  final DispatcherProfileEntity? profile;
  final bool showBackButton;
  final bool showBottomNavBar;

  @override
  State<DispatcherProfileScreen> createState() =>
      _DispatcherProfileScreenState();
}

class _DispatcherProfileScreenState extends State<DispatcherProfileScreen> {
  late final DispatcherProfileEntity _profile;
  late List<DispatcherNotificationSettingEntity> _settings;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile ?? DispatcherProfileFakeData.sampleProfile;
    _settings = List.of(DispatcherProfileFakeData.sampleNotificationSettings);
  }

  void _onSettingChanged(String id, bool isEnabled) {
    setState(() {
      _settings = _settings.map((item) {
        if (item.id == id) {
          return item.copyWith(isEnabled: isEnabled);
        }
        return item;
      }).toList();
    });
  }

  void _onLogoutTap() {
    final locale = context.localization;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(locale.profileLogout),
          content: Text(locale.profileLogoutConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(locale.profileCancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.pushReplacementNamed(AppRoutes.login);
              },
              child: Text(
                locale.profileLogout,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Scaffold(
      backgroundColor: color.surfaceContainerLowest,
      extendBody: true,
      appBar: CustomAppBar(
        title: locale.profileSettingsTitle,
        centerTitle: true,
        showBackButton: false,
        actions: [
          NotificationButton(
            hasUnread: true,
            onPressed: () =>
                context.pushNamed(AppRoutes.dispatcherNotifications),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.base,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DispatcherProfileAdminCard(profile: _profile),
              const SizedBox(height: Spacing.md),
              DispatcherProfileNotificationSettingsCard(
                settings: _settings,
                onSettingChanged: _onSettingChanged,
              ),
              const SizedBox(height: Spacing.md),
              const DispatcherProfileAppInfoCard(
                appVersion: DispatcherProfileFakeData.appVersion,
              ),
              const SizedBox(height: Spacing.lg),
              DispatcherProfileLogoutButton(onTap: _onLogoutTap),
              const SizedBox(height: Spacing.bottomNavHeight + Spacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
