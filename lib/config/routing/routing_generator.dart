import 'package:flutter/material.dart';

import '../../core/app_shell/screens/app_shell_screen.dart';
import '../../core/constants/assets.dart';
import '../../features/account_status/domain/account_status_kind.dart';
import '../../features/account_status/presentation/screens/account_status_preview_screen.dart';
import '../../features/account_status/presentation/screens/account_status_screen.dart';
import '../../features/auth/domain/auth_verification_target.dart';
import '../../features/auth/domain/user_role.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import 'arguments/auth_route_arguments.dart';
import '../../features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_order_entity.dart';
import '../../features/dispatcher/dispatcher_assign_box/presentation/screens/assign_box_screen.dart';
import '../../features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_entity.dart';
import '../../features/dispatcher/dispatcher_box_tracking/domain/fake_data/box_tracking_fake_data.dart';
import '../../features/dispatcher/dispatcher_box_tracking/presentation/screens/dispatcher_box_tracking_screen.dart';
import '../../features/dispatcher/dispatcher_driver_details/domain/entities/driver_details_entity.dart';
import '../../features/dispatcher/dispatcher_driver_details/domain/fake_data/driver_details_fake_data.dart';
import '../../features/dispatcher/dispatcher_driver_details/presentation/screens/dispatcher_driver_details_screen.dart';
import '../../features/dispatcher/dispatcher_driver_performance/presentation/screens/dispatcher_driver_performance_screen.dart';
import '../../features/dispatcher/dispatcher_drivers/presentation/screens/dispatcher_drivers_screen.dart';
import '../../features/dispatcher/dispatcher_home/presentation/screens/dispatcher_home_screen.dart';
import '../../features/dispatcher/dispatcher_map/presentation/screens/dispatcher_map_screen.dart';
import '../../features/dispatcher/dispatcher_notifications/presentation/screens/dispatcher_notifications_screen.dart';
import '../../features/dispatcher/dispatcher_operations/presentation/screens/dispatcher_operations_screen.dart';
import '../../features/dispatcher/dispatcher_orders/presentation/screens/dispatcher_orders_screen.dart';
import '../../features/dispatcher/dispatcher_profile/domain/entities/dispatcher_profile_entity.dart';
import '../../features/dispatcher/dispatcher_profile/presentation/screens/dispatcher_profile_screen.dart';
import '../../features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_detail_entity.dart';
import '../../features/dispatcher/dispatcher_support/presentation/screens/dispatcher_issue_details_screen.dart';
import '../../features/dispatcher/dispatcher_support/presentation/screens/dispatcher_reassign_driver_screen.dart';
import '../../features/dispatcher/dispatcher_support/presentation/screens/dispatcher_support_screen.dart';
import '../../features/driver/orders/domain/entities/driver_assigned_box_entity.dart';
import '../../features/driver/orders/presentation/screens/driver_assigned_boxes_screen.dart';
import '../../features/driver/confirm_receipt/presentation/screens/driver_confirm_receipt_screen.dart';
import '../../features/driver/confirm_receipt/presentation/screens/driver_boxes_received_screen.dart';
import '../../features/driver/confirm_receipt/domain/entities/driver_received_box_item_entity.dart';
import '../../features/driver/driver_profile/presentation/screens/driver_profile_screen.dart';
import '../../features/driver/driver_profile/domain/entities/driver_profile_entity.dart';
import '../../features/driver/driver_notifications/presentation/screens/driver_notifications_screen.dart';
import '../../features/driver/driver_notifications/domain/entities/driver_notification_entity.dart';
import '../../features/driver/driver_vehicle/domain/entities/driver_vehicle_entity.dart';
import '../../features/driver/driver_vehicle/presentation/screens/driver_edit_vehicle_details_screen.dart';
import '../../features/driver/driver_vehicle/presentation/screens/driver_vehicle_details_screen.dart';
import '../../features/driver/driver_profile/presentation/screens/driver_support_screen.dart';
import '../../features/register/presentation/screens/register_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  const RouteGenerator._();

  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(settings: settings, page: const SplashScreen());

      case AppRoutes.appShell || AppRoutes.home:
        int initialIndex = 0;
        UserRole role = UserRole.operations;
        final args = settings.arguments;
        if (args is AppShellRouteArgs) {
          initialIndex = args.initialIndex;
          role = args.role;
        } else if (args is int) {
          initialIndex = args;
        } else if (args is UserRole) {
          role = args;
        } else if (args is Map) {
          initialIndex = (args['index'] ?? 0) as int;
          role = (args['role'] ?? UserRole.operations) as UserRole;
        }
        return _buildRoute(
          settings: settings,
          page: AppShellScreen(
            initialIndex: initialIndex,
            role: role,
          ),
        );

      case AppRoutes.login:
        UserRole role = UserRole.operations;
        final args = settings.arguments;
        if (args is LoginRouteArgs) {
          role = args.role;
        } else if (args is UserRole) {
          role = args;
        }
        return _buildRoute(
          settings: settings,
          page: LoginScreen(role: role),
        );

      case AppRoutes.verifyPhoneOtp:
        AuthVerificationTarget target = const AuthVerificationTarget(
          value: '',
          imageAsset: AppAssets.authPhoneOtp,
        );
        UserRole role = UserRole.driver;
        final args = settings.arguments;
        if (args is OtpVerificationRouteArgs) {
          target = args.target;
          role = args.role;
        } else if (args is AuthVerificationTarget) {
          target = args;
        } else if (args is Map) {
          final phone = args['phone'] as String? ?? '';
          target = AuthVerificationTarget(
            value: phone,
            imageAsset: AppAssets.authPhoneOtp,
          );
          role = (args['role'] as UserRole?) ?? UserRole.driver;
        }
        return _buildRoute(
          settings: settings,
          page: OtpVerificationScreen.phone(
            target: target,
            role: role,
          ),
        );

      case AppRoutes.verifyEmailOtp:
        AuthVerificationTarget target = const AuthVerificationTarget(
          value: '',
          imageAsset: AppAssets.authEmailOtp,
        );
        UserRole role = UserRole.driver;
        final args = settings.arguments;
        if (args is OtpVerificationRouteArgs) {
          target = args.target;
          role = args.role;
        } else if (args is AuthVerificationTarget) {
          target = args;
        }
        return _buildRoute(
          settings: settings,
          page: OtpVerificationScreen.email(
            target: target,
            role: role,
          ),
        );

      case AppRoutes.register:
        final args = settings.arguments;
        if (args is DriverRegistrationRouteArgs) {
          return _buildRoute(
            settings: settings,
            page: RegisterScreen(
              phone: args.phone,
              isResubmission: args.isResubmission,
              registrationId: args.registrationId,
            ),
          );
        }
        return _buildRoute(settings: settings, page: const RegisterScreen());

      case AppRoutes.accountStatus:
        AccountStatusKind kind = AccountStatusKind.underReview;
        String? phone;
        String? registrationId;
        final args = settings.arguments;
        if (args is AccountStatusRouteArgs) {
          kind = args.kind;
          registrationId = args.registrationId;
          phone = args.phone;
        } else if (args is AccountStatusKind) {
          kind = args;
        }
        return _buildRoute(
          settings: settings,
          page: AccountStatusScreen(
            kind: kind,
            phone: phone,
            registrationId: registrationId,
          ),
        );

      case AppRoutes.accountStatusPreview:
        return _buildRoute(
          settings: settings,
          page: const AccountStatusPreviewScreen(),
        );

      case AppRoutes.dispatcherOrders:
        return _buildRoute(
          settings: settings,
          page: const DispatcherOrdersScreen(),
        );

      case AppRoutes.dispatcherOperations:
        return _buildRoute(
          settings: settings,
          page: const DispatcherOperationsScreen(),
        );

      case AppRoutes.dispatcherDrivers:
        return _buildRoute(
          settings: settings,
          page: const DispatcherDriversScreen(),
        );

      case AppRoutes.dispatcherDriverPerformance:
        return _buildRoute(
          settings: settings,
          page: const DispatcherDriverPerformanceScreen(),
        );

      case AppRoutes.dispatcherMap:
        return _buildRoute(
          settings: settings,
          page: const DispatcherMapScreen(),
        );

      case AppRoutes.dispatcherSupport:
        return _buildRoute(
          settings: settings,
          page: const DispatcherSupportScreen(),
        );

      case AppRoutes.dispatcherSupportIssueDetails:
        final issue = settings.arguments is DispatcherIssueDetailEntity
            ? settings.arguments! as DispatcherIssueDetailEntity
            : null;
        return _buildRoute(
          settings: settings,
          page: DispatcherIssueDetailsScreen(issue: issue),
        );

      case AppRoutes.dispatcherReassignDriver || AppRoutes.reassignDriver:
        final issue = settings.arguments is DispatcherIssueDetailEntity
            ? settings.arguments! as DispatcherIssueDetailEntity
            : null;
        return _buildRoute(
          settings: settings,
          page: DispatcherReassignDriverScreen(issue: issue),
        );

      case AppRoutes.dispatcherProfile:
        final profile = settings.arguments is DispatcherProfileEntity
            ? settings.arguments! as DispatcherProfileEntity
            : null;
        return _buildRoute(
          settings: settings,
          page: DispatcherProfileScreen(profile: profile),
        );

      case AppRoutes.assignBox:
        final order = settings.arguments is AssignBoxOrderEntity
            ? settings.arguments! as AssignBoxOrderEntity
            : null;
        return _buildRoute(
          settings: settings,
          page: AssignBoxScreen(order: order),
        );

      case AppRoutes.dispatcherNotifications || AppRoutes.notifications:
        return _buildRoute(
          settings: settings,
          page: const DispatcherNotificationsScreen(),
        );

      case AppRoutes.dispatcherHome:
        return _buildRoute(
          settings: settings,
          page: const DispatcherHomeScreen(),
        );

      case AppRoutes.dispatcherDriverDetails:
        final driver = settings.arguments is DriverDetailsEntity
            ? settings.arguments! as DriverDetailsEntity
            : DriverDetailsFakeData.defaultDriver;
        return _buildRoute(
          settings: settings,
          page: DispatcherDriverDetailsScreen(driver: driver),
        );

      case AppRoutes.boxTracking:
        final box = settings.arguments is BoxTrackingEntity
            ? settings.arguments! as BoxTrackingEntity
            : BoxTrackingFakeData.defaultBox;
        return _buildRoute(
          settings: settings,
          page: DispatcherBoxTrackingScreen(box: box),
        );

      case AppRoutes.driverAssignedBoxes:
        final withoutShell = settings.arguments == false;
        return _buildRoute(
          settings: settings,
          page: withoutShell
              ? const DriverAssignedBoxesScreen()
              : const AppShellScreen(
                  role: UserRole.driver,
                  initialIndex: 0,
                ),
        );

      case AppRoutes.driverConfirmReceipt:
        final box = settings.arguments is DriverAssignedBoxEntity
            ? settings.arguments! as DriverAssignedBoxEntity
            : null;
        return _buildRoute(
          settings: settings,
          page: DriverConfirmReceiptScreen(box: box),
        );

      case AppRoutes.driverBoxesReceived:
        final boxes = settings.arguments is List<DriverReceivedBoxItemEntity>
            ? settings.arguments! as List<DriverReceivedBoxItemEntity>
            : null;
        return _buildRoute(
          settings: settings,
          page: DriverBoxesReceivedScreen(boxes: boxes),
        );

      case AppRoutes.driverProfile:
        final profile = settings.arguments is DriverProfileEntity
            ? settings.arguments! as DriverProfileEntity
            : null;
        return _buildRoute(
          settings: settings,
          page: DriverProfileScreen(profile: profile),
        );

      case AppRoutes.driverNotifications:
        final notifications =
            settings.arguments is List<DriverNotificationEntity>
                ? settings.arguments! as List<DriverNotificationEntity>
                : null;
        return _buildRoute(
          settings: settings,
          page: DriverNotificationsScreen(initialNotifications: notifications),
        );

      case AppRoutes.driverVehicleDetails:
        final vehicle = settings.arguments is DriverVehicleEntity
            ? settings.arguments! as DriverVehicleEntity
            : null;
        return _buildRoute(
          settings: settings,
          page: DriverVehicleDetailsScreen(vehicle: vehicle),
        );

      case AppRoutes.driverEditVehicleDetails:
        final vehicle = settings.arguments is DriverVehicleEntity
            ? settings.arguments! as DriverVehicleEntity
            : null;
        return _buildRoute(
          settings: settings,
          page: DriverEditVehicleDetailsScreen(vehicle: vehicle),
        );

      case AppRoutes.driverSupport:
        return _buildRoute(
          settings: settings,
          page: const DriverSupportScreen(),
        );

      default:
        return _buildRoute(settings: settings, page: const SplashScreen());
    }
  }

  static PageRouteBuilder<dynamic> _buildRoute({
    required RouteSettings settings,
    required Widget page,
  }) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(curvedAnimation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
}
