import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/routing/arguments/auth_route_arguments.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/l10n/translations/app_localizations.dart';
import '../../../../../core/network/failures.dart';
import '../../../../../core/services/token_service.dart';
import '../../../../auth/domain/usecase/logout_usecase.dart';
import '../../../../auth/domain/user_role.dart';
import '../../domain/entities/driver_profile_assignment_entity.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../manager/driver_profile_event.dart';
import '../manager/driver_profile_state.dart';
import '../manager/driver_profile_view_model.dart';
import '../widgets/driver_profile_assignment_card.dart';
import '../widgets/driver_profile_contact_card.dart';
import '../widgets/driver_profile_documents_card.dart';
import '../widgets/driver_profile_header.dart';
import '../widgets/driver_profile_hero_card.dart';
import '../widgets/driver_profile_policy_banner.dart';
import '../widgets/driver_profile_quick_actions_row.dart';
import '../widgets/driver_profile_shimmer.dart';
import '../widgets/driver_profile_ticket_card.dart';
import '../widgets/driver_profile_vehicle_card.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({
    super.key,
    this.profile,
    this.viewModel,
    this.isActive = true,
    this.onNotificationTap,
    this.onVehicleInfoTap,
    this.onContactUsTap,
    this.onViewAllTicketsTap,
    this.onRecentTicketTap,
    this.onLanguageTap,
    this.onSettingsTap,
    this.onLogoutTap,
  });

  final DriverProfileEntity? profile;
  final DriverProfileViewModel? viewModel;
  final bool isActive;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onVehicleInfoTap;
  final VoidCallback? onContactUsTap;
  final VoidCallback? onViewAllTicketsTap;
  final VoidCallback? onRecentTicketTap;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogoutTap;

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  late final DriverProfileViewModel? _viewModel;
  late final bool _createdInternalViewModel;
  bool _initialized = false;
  String? _lastLocale;
  String? _lastFailedAvatarUrl;

  @override
  void initState() {
    super.initState();
    if (widget.viewModel != null) {
      _createdInternalViewModel = false;
      _viewModel = widget.viewModel;
    } else if (getIt.isRegistered<DriverProfileViewModel>()) {
      _createdInternalViewModel = true;
      _viewModel = getIt<DriverProfileViewModel>();
    } else {
      _createdInternalViewModel = false;
      _viewModel = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = _viewModel;
    if (vm == null) return;
    final locale = Localizations.localeOf(context).languageCode;
    if (!_initialized) {
      _initialized = true;
      _lastLocale = locale;
      unawaited(vm.doIntent(DriverProfileStarted(locale: locale)));
    } else if (_lastLocale != null && _lastLocale != locale) {
      _lastLocale = locale;
      unawaited(vm.doIntent(DriverProfileLocaleChanged(locale: locale)));
    }
  }

  @override
  void didUpdateWidget(covariant DriverProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final vm = _viewModel;
    if (vm == null) return;
    if (!oldWidget.isActive && widget.isActive) {
      final locale = Localizations.localeOf(context).languageCode;
      unawaited(vm.doIntent(DriverProfileActivated(locale: locale)));
    }
  }

  @override
  void dispose() {
    if (_createdInternalViewModel) {
      unawaited(_viewModel?.close());
    }
    super.dispose();
  }

  void _handleAvatarResolved(bool resolved, String? profileImageUrl) {
    final vm = _viewModel;
    if (!resolved && profileImageUrl != null && vm != null) {
      if (_lastFailedAvatarUrl != profileImageUrl) {
        _lastFailedAvatarUrl = profileImageUrl;
        final locale = Localizations.localeOf(context).languageCode;
        unawaited(vm.doIntent(DriverProfileAvatarFailed(locale: locale)));
      }
    }
  }

  Future<void> _handleRefresh() async {
    final vm = _viewModel;
    if (vm == null) return;
    final locale = Localizations.localeOf(context).languageCode;
    unawaited(vm.doIntent(DriverProfileRefreshed(locale: locale)));
    await vm.stream
        .firstWhere((s) => !s.isRefreshing)
        .timeout(const Duration(seconds: 10), onTimeout: () => vm.state);
  }

  bool _hasAssignment(DriverProfileAssignmentEntity? assignment) {
    if (assignment == null) return false;
    final r = assignment.restaurantName?.trim();
    final b = assignment.branchName?.trim();
    return (r != null && r.isNotEmpty) || (b != null && b.isNotEmpty);
  }

  void _handleSettingsTap(BuildContext context) {
    if (widget.onSettingsTap != null) {
      widget.onSettingsTap!();
      return;
    }
    unawaited(context.pushNamed(AppRoutes.driverSettings));
  }

  void _handleNotificationTap(BuildContext context) {
    if (widget.onNotificationTap != null) {
      widget.onNotificationTap!();
      return;
    }
    unawaited(context.pushNamed(AppRoutes.driverNotifications));
  }

  void _handleVehicleInfoTap(BuildContext context) {
    if (widget.onVehicleInfoTap != null) {
      widget.onVehicleInfoTap!();
      return;
    }
    unawaited(context.pushNamed(AppRoutes.driverVehicleDetails));
  }

  void _handleContactUsTap(BuildContext context) {
    if (widget.onContactUsTap != null) {
      widget.onContactUsTap!();
      return;
    }
    unawaited(context.pushNamed(AppRoutes.driverSupport));
  }

  void _handleViewAllTicketsTap(BuildContext context) {
    if (widget.onViewAllTicketsTap != null) {
      widget.onViewAllTicketsTap!();
      return;
    }
    unawaited(context.pushNamed(AppRoutes.driverSupportTickets));
  }

  void _handleRecentTicketTap(BuildContext context) {
    if (widget.onRecentTicketTap != null) {
      widget.onRecentTicketTap!();
      return;
    }
    unawaited(context.pushNamed(AppRoutes.driverSupportTickets));
  }

  void _handleLogout(BuildContext context) {
    if (widget.onLogoutTap != null) {
      widget.onLogoutTap!();
      return;
    }

    final locale = context.localization;
    final color = context.colorScheme;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(locale.driverLogoutConfirmTitle),
            content: Text(locale.driverLogoutConfirmMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(locale.profileCancel),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  if (getIt.isRegistered<LogoutUseCase>()) {
                    await getIt<LogoutUseCase>()();
                  } else if (getIt.isRegistered<TokenService>()) {
                    await getIt<TokenService>().clearTokens();
                  }
                  if (!context.mounted) return;
                  context.pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (route) => false,
                    arguments: const LoginRouteArgs(role: UserRole.driver),
                  );
                },
                child: Text(
                  locale.driverQuickActionLogout,
                  style: TextStyle(color: color.error),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.sm,
      ),
      child: DriverProfileShimmer(),
    );
  }

  Widget _buildError(BuildContext context, Failure failure) {
    final lang = Localizations.localeOf(context).languageCode;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.screenH,
          vertical: Spacing.md,
        ),
        child: ApiErrorWidget.fromTypedFailure(
          failure: failure,
          onRetry: () => _viewModel?.doIntent(
            DriverProfileRefreshed(locale: lang),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DriverProfileEntity profile,
    ColorScheme color,
    AppLocalizations locale,
  ) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.screenH,
          vertical: Spacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DriverProfileHeroCard(
              profile: profile,
              onAvatarResolved: (resolved) => _handleAvatarResolved(
                resolved,
                profile.profileImageUrl,
              ),
            ),
            const SizedBox(height: Spacing.md),
            DriverProfileVehicleCard(
              vehicle: profile.vehicle,
              onTap: () => _handleVehicleInfoTap(context),
            ),
            const SizedBox(height: Spacing.md),
            DriverProfileDocumentsCard(
              documents: profile.documents,
            ),
            if (_hasAssignment(profile.assignment)) ...[
              const SizedBox(height: Spacing.md),
              DriverProfileAssignmentCard(
                assignment: profile.assignment,
              ),
            ],
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Icon(
                  Icons.headset_mic_outlined,
                  size: 20,
                  color: color.primary,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  locale.driverSupportSectionTitle,
                  style: getBoldStyle(
                    fontSize: FontSize.size13,
                    color: color.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs + 2),
            DriverProfileContactCard(
              onTap: () => _handleContactUsTap(context),
            ),
            const SizedBox(height: Spacing.md),
            DriverProfileTicketCard(
              ticket: profile.latestSupportTicket,
              onTap: () => _handleRecentTicketTap(context),
              onViewAllTap: () => _handleViewAllTicketsTap(context),
            ),
            const SizedBox(height: Spacing.md),
            DriverProfileQuickActionsRow(
              onLanguageTap: widget.onLanguageTap,
              onSettingsTap: () => _handleSettingsTap(context),
              onLogoutTap: () => _handleLogout(context),
            ),
            const SizedBox(height: Spacing.md),
            const DriverProfilePolicyBanner(),
            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final scaffold = Scaffold(
      backgroundColor: color.surface,
      appBar: DriverProfileHeader(
        onNotificationTap: () => _handleNotificationTap(context),
      ),
      body: SafeArea(
        child: _viewModel == null
            ? (widget.profile != null
                ? _buildContent(context, widget.profile!, color, locale)
                : _buildShimmer())
            : BlocBuilder<DriverProfileViewModel, DriverProfileState>(
                buildWhen: (previous, current) =>
                    previous.profile != current.profile ||
                    previous.failure != current.failure ||
                    previous.isInitialLoading != current.isInitialLoading,
                builder: (context, state) {
                  final currentProfile = state.profile ?? widget.profile;

                  if (state.isInitialLoading && currentProfile == null) {
                    return _buildShimmer();
                  }

                  if (state.failure != null && currentProfile == null) {
                    return _buildError(context, state.failure!);
                  }

                  if (currentProfile == null) {
                    return _buildShimmer();
                  }

                  return _buildContent(context, currentProfile, color, locale);
                },
              ),
      ),
    );

    final vm = _viewModel;
    if (vm == null) {
      return scaffold;
    }

    return BlocProvider.value(
      value: vm,
      child: BlocListener<DriverProfileViewModel, DriverProfileState>(
        listenWhen: (previous, current) =>
            previous.inlineFailure != current.inlineFailure &&
            current.inlineFailure != null,
        listener: (context, state) {
          if (state.inlineFailure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.inlineFailure!.errorMessage),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: scaffold,
      ),
    );
  }
}
