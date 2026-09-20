import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routing/app_routes.dart';
import '../../../../config/routing/arguments/auth_route_arguments.dart';
import '../../../../core/di/di.dart';
import '../../../../core/errors/api_error_type.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/network/api_results.dart';
import '../../../../core/widget/custom_progress_indecator.dart';
import '../../../../core/widget/custom_snak_bar.dart';
import '../../../auth/domain/user_role.dart';
import '../../../driver_auth/presentation/manager/driver_auth_coordinator.dart';
import '../../domain/account_status_kind.dart';
import '../../domain/entities/driver_registration_status_entity.dart';
import '../../domain/repo/account_status_repository.dart';
import '../../domain/usecase/get_account_status_usecase.dart';
import '../manager/account_status_event.dart';
import '../manager/account_status_state.dart';
import '../manager/account_status_view_model.dart';
import '../widgets/account_status_content.dart';

class _FakeAccountStatusRepo implements AccountStatusRepository {
  @override
  Future<ApiResult<DriverRegistrationStatusEntity>> getRegistrationStatus({
    String? phone,
    String? registrationId,
  }) async => ApiSuccessResult(
    data: const DriverRegistrationStatusEntity(
      registrationId: 'reg-1',
      kind: AccountStatusKind.underReview,
    ),
  );
}

class AccountStatusScreen extends StatefulWidget {
  const AccountStatusScreen({
    super.key,
    required this.kind,
    this.phone,
    this.registrationId,
    this.viewModel,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.onHelpPressed,
  });

  final AccountStatusKind kind;
  final String? phone;
  final String? registrationId;
  final AccountStatusViewModel? viewModel;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final VoidCallback? onHelpPressed;

  @override
  State<AccountStatusScreen> createState() => _AccountStatusScreenState();
}

class _AccountStatusScreenState extends State<AccountStatusScreen> {
  late final AccountStatusViewModel _viewModel;
  late final bool _isInternalViewModel;

  @override
  void initState() {
    super.initState();
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
      _isInternalViewModel = false;
    } else if (getIt.isRegistered<AccountStatusViewModel>()) {
      _viewModel = getIt<AccountStatusViewModel>();
      _isInternalViewModel = true;
    } else {
      final fakeRepo = _FakeAccountStatusRepo();
      _viewModel = AccountStatusViewModel(
        getAccountStatusUseCase: GetAccountStatusUseCase(fakeRepo),
      );
      _isInternalViewModel = true;
    }

    _viewModel.doIntent(AccountStatusSetKindEvent(widget.kind));

    if (widget.phone != null || widget.registrationId != null) {
      _viewModel.doIntent(
        AccountStatusLoadEvent(
          phone: widget.phone,
          registrationId: widget.registrationId,
        ),
      );
    }
  }

  @override
  void dispose() {
    if (_isInternalViewModel) {
      _viewModel.close();
    }
    super.dispose();
  }

  void _handlePrimary(
    BuildContext context,
    AccountStatusKind currentKind,
    DriverRegistrationStatusEntity? entity,
  ) {
    if (widget.onPrimaryPressed != null) {
      widget.onPrimaryPressed!();
      return;
    }

    final effectivePhone = widget.phone ?? entity?.phone;
    final effectiveRegId = widget.registrationId ?? entity?.registrationId;

    switch (currentKind) {
      case AccountStatusKind.accepted:
        if (effectivePhone != null && effectivePhone.isNotEmpty) {
          _viewModel.doIntent(
            AccountStatusActivateApprovedEvent(effectivePhone),
          );
        } else {
          context.pushReplacementNamed(
            AppRoutes.login,
            arguments: const LoginRouteArgs(role: UserRole.driver),
          );
        }
        break;
      case AccountStatusKind.rejected:
      case AccountStatusKind.moreInformationRequired:
        context.pushReplacementNamed(
          AppRoutes.register,
          arguments: DriverRegistrationRouteArgs(
            role: UserRole.driver,
            phone: effectivePhone,
            isResubmission: true,
            registrationId: effectiveRegId,
          ),
        );
        break;
      case AccountStatusKind.underReview:
        break;
    }
  }

  void _handleSecondary(BuildContext context) {
    if (widget.onSecondaryPressed != null) {
      widget.onSecondaryPressed!();
      return;
    }

    context.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return BlocProvider.value(
      value: _viewModel,
      child: BlocConsumer<AccountStatusViewModel, AccountStatusState>(
        listener: (context, state) {
          if (state.status == AccountStatusStateStatus.activationSuccess) {
            final lookup = state.lookupResult;
            if (lookup != null) {
              const coordinator = DriverAuthCoordinator();
              final destination = coordinator.resolve(lookup);
              coordinator.navigate(context, destination);
            } else {
              context.pushReplacementNamed(
                AppRoutes.login,
                arguments: const LoginRouteArgs(role: UserRole.driver),
              );
            }
          } else if (state.status == AccountStatusStateStatus.error &&
              state.errorMessage != null &&
              state.hasEntity) {
            CustomSnackbar.showError(
              context: context,
              message: state.errorMessage!,
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && !state.hasEntity) {
            return Scaffold(
              backgroundColor: color.surface,
              body: const Center(child: CustomProgressIndicator()),
            );
          }

          if (state.status == AccountStatusStateStatus.error &&
              !state.hasEntity) {
            return Scaffold(
              backgroundColor: color.surface,
              body: Center(
                child: ApiErrorWidget(
                  exception:
                      state.failure?.exception ??
                      ApiException(
                        errorType: ApiErrorType.unknown,
                        message: state.errorMessage ?? 'An error occurred',
                      ),
                  onRetry: () {
                    _viewModel.doIntent(
                      AccountStatusLoadEvent(
                        phone: widget.phone,
                        registrationId: widget.registrationId,
                      ),
                    );
                  },
                ),
              ),
            );
          }

          final effectiveKind = state.hasEntity ? state.kind : widget.kind;

          final content = Scaffold(
            backgroundColor: color.surface,
            body: SafeArea(
              child: SingleChildScrollView(
                child: AccountStatusContent(
                  kind: effectiveKind,
                  statusEntity: state.statusEntity,
                  onPrimaryPressed: () => _handlePrimary(
                    context,
                    effectiveKind,
                    state.statusEntity,
                  ),
                  onSecondaryPressed: () => _handleSecondary(context),
                  onHelpPressed: widget.onHelpPressed,
                ),
              ),
            ),
          );

          if (state.isActivating) {
            return Stack(
              children: [
                content,
                const ModalBarrier(dismissible: false, color: Colors.black26),
                const Center(child: CustomProgressIndicator()),
              ],
            );
          }

          return content;
        },
      ),
    );
  }
}
