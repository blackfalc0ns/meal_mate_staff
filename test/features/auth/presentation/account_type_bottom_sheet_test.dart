import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/inline_api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/staff_role_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';
import 'package:meal_mate_delivery/features/auth/presentation/widgets/account_type_bottom_sheet.dart';
import 'package:meal_mate_delivery/features/auth/presentation/widgets/registration_role_card.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  const mockRoles = [
    StaffRoleEntity(
      code: 'driver',
      name: 'Driver',
      nameAr: 'سائق',
      nameEn: 'Driver',
      description: 'استقبال الطلبات وتوصيلها',
      descriptionAr: 'استقبال الطلبات وتوصيلها',
      descriptionEn: 'Receive and deliver',
      iconKey: 'delivery_dining',
      allowsSelfRegistration: true,
      displayOrder: 1,
    ),
    StaffRoleEntity(
      code: 'delivery_manager',
      name: 'Operations Representative',
      nameAr: 'مندوب عمليات',
      nameEn: 'Operations Representative',
      description: 'إدارة أسطول السائقين والطلبات',
      descriptionAr: 'إدارة أسطول السائقين والطلبات',
      descriptionEn: 'Manage fleet and orders',
      iconKey: 'local_shipping',
      allowsSelfRegistration: false,
      displayOrder: 2,
    ),
  ];

  testWidgets('renders dynamic roles passed from API', (tester) async {
    UserRole? selected;
    bool confirmed = false;

    await tester.pumpWidget(
      buildTestApp(
        AccountTypeBottomSheet(
          selectedRole: UserRole.driver,
          roles: mockRoles,
          onRoleChanged: (r) => selected = r,
          onConfirm: () => confirmed = true,
        ),
      ),
    );

    expect(find.byType(RegistrationRoleCard), findsNWidgets(2));
    expect(find.text('سائق'), findsOneWidget);
    expect(find.text('مندوب عمليات'), findsOneWidget);
    expect(find.text('استقبال الطلبات وتوصيلها'), findsOneWidget);

    // Tap second card
    await tester.tap(find.text('مندوب عمليات'));
    expect(selected, UserRole.operations);

    // Tap confirm
    await tester.tap(find.text('تأكيد'));
    expect(confirmed, isTrue);
  });

  testWidgets('renders loading state when isLoading is true and roles empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        AccountTypeBottomSheet(
          selectedRole: UserRole.driver,
          isLoading: true,
          roles: const [],
          onRoleChanged: (_) {},
          onConfirm: () {},
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders InlineApiErrorWidget on failure with retry', (
    tester,
  ) async {
    bool retried = false;

    await tester.pumpWidget(
      buildTestApp(
        AccountTypeBottomSheet(
          selectedRole: UserRole.driver,
          roles: const [],
          failure: ServerFailure(
            errorMessage: 'فشل الاتصال بالخادم',
            exception: const ApiException(
              errorType: ApiErrorType.noInternetConnection,
              message: 'فشل الاتصال بالخادم',
            ),
          ),
          onRetry: () => retried = true,
          onRoleChanged: (_) {},
          onConfirm: () {},
        ),
      ),
    );

    expect(find.byType(InlineApiErrorWidget), findsOneWidget);
    expect(find.text('فشل الاتصال بالخادم'), findsOneWidget);

    // Tap retry
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('renders fallback default roles when roles list is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        AccountTypeBottomSheet(
          selectedRole: UserRole.driver,
          roles: const [],
          onRoleChanged: (_) {},
          onConfirm: () {},
        ),
      ),
    );

    expect(find.byType(RegistrationRoleCard), findsNWidgets(2));
    expect(find.text('سائق'), findsOneWidget);
    expect(find.text('مندوب عمليات'), findsOneWidget);
  });
}
