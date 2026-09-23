import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/routing/arguments/auth_route_arguments.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/services/token_service.dart';
import '../../../../../core/widget/custom_app_bar.dart';
import '../../../../../core/widget/notification_button.dart';
import '../../../../auth/domain/usecase/logout_usecase.dart';
import '../../../../auth/domain/user_role.dart';
import '../../../dispatcher_map/presentation/widgets/dispatcher_map_driver_marker_factory.dart';
import '../../domain/entities/dispatcher_notification_setting_entity.dart';
import '../../domain/entities/dispatcher_profile_entity.dart';
import '../../domain/fake_data/dispatcher_profile_fake_data.dart';
import '../widgets/dispatcher_profile_admin_card.dart';
import '../widgets/dispatcher_profile_app_info_card.dart';
import '../widgets/dispatcher_profile_driver_performance_card.dart';
import '../widgets/dispatcher_profile_logout_button.dart';
import '../widgets/dispatcher_profile_notification_settings_card.dart';
import '../widgets/dispatcher_profile_operations_card.dart';

class DispatcherProfileScreen extends StatefulWidget {
  const DispatcherProfileScreen({
    super.key,
    this.profile,
    this.showBackButton = true,
    this.logoutUseCase,
    this.tokenService,
    this.onLogoutTap,
  });

  final DispatcherProfileEntity? profile;
  final bool showBackButton;
  final LogoutUseCase? logoutUseCase;
  final TokenService? tokenService;
  final VoidCallback? onLogoutTap;

  @override
  State<DispatcherProfileScreen> createState() =>
      _DispatcherProfileScreenState();
}

class _DispatcherProfileScreenState extends State<DispatcherProfileScreen> {
  late final DispatcherProfileEntity _profile;
  late List<DispatcherNotificationSettingEntity> _settings;

  LogoutUseCase? get _logoutUseCase =>
      widget.logoutUseCase ??
      (getIt.isRegistered<LogoutUseCase>() ? getIt<LogoutUseCase>() : null);

  TokenService? get _tokenService =>
      widget.tokenService ??
      (getIt.isRegistered<TokenService>() ? getIt<TokenService>() : null);

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

  Future<void> _performLogout() async {
    if (_logoutUseCase != null) {
      await _logoutUseCase!.call();
    } else if (_tokenService != null) {
      await _tokenService!.clearTokens();
    }
    DispatcherMapMarkerBitmapFactory.clearCache();
  }

  void _onLogoutTap() {
    if (widget.onLogoutTap != null) {
      widget.onLogoutTap!();
      return;
    }

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
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _performLogout();
                if (!context.mounted) return;
                context.pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                  arguments: const LoginRouteArgs(role: UserRole.operations),
                );
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
              DispatcherProfileOperationsCard(
                onTap: () => context.pushNamed(AppRoutes.dispatcherOperations),
              ),
              const SizedBox(height: Spacing.md),
              DispatcherProfileDriverPerformanceCard(
                onTap: () =>
                    context.pushNamed(AppRoutes.dispatcherDriverPerformance),
              ),
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
