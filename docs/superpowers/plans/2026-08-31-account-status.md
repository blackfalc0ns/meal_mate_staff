# Account Status Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Figma-backed account status screens for accepted, rejected, more-information-required, and under-review account states.

**Architecture:** Add a focused `features/account_status` feature with a small domain enum/configuration model and presentation widgets. Wire it through app routing and localization while reusing the existing theme, spacing, button, and auth logo patterns.

**Tech Stack:** Flutter, Material, generated Flutter localization, existing app theme tokens, existing widget tests.

**Spec:** `docs/superpowers/specs/2026-08-31-account-status-design.md`

## Global Constraints

- No new packages.
- UI colors inside widgets must come from `context.colorScheme`.
- User-facing text must come from `context.localization`.
- Text styles must use `lib/config/theme/styles_manager.dart`.
- Spacing must use `lib/config/theme/spacing.dart`.
- Custom widgets must live in their own files.
- Direction must come from Flutter inherited directionality; no locale-code layout checks.
- Figma nodes `2023:5401`, `2023:5414`, `2023:5440`, and `1522:13201` are the source of truth.

---

### Task 1: Account Status Widget Tests

**Files:**
- Create: `test/account_status_screen_test.dart`

**Interfaces:**
- Consumes: planned `AccountStatusScreen`, `AccountStatusKind`, `AppTheme`, and `AppLocalizations`.
- Produces: failing tests that define the feature's public behavior.

- [ ] **Step 1: Write the failing tests**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';
import 'package:meal_mate_delivery/features/account_status/domain/account_status_kind.dart';
import 'package:meal_mate_delivery/features/account_status/presentation/screens/account_status_screen.dart';

void main() {
  Widget buildSubject(AccountStatusKind kind) {
    return MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: AccountStatusScreen(kind: kind),
    );
  }

  testWidgets('renders accepted status actions', (tester) async {
    await tester.pumpWidget(buildSubject(AccountStatusKind.accepted));

    expect(find.text('Your account has been accepted!'), findsOneWidget);
    expect(find.text('Your account was activated successfully\nYou can start working now'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Start work'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Back to login'), findsOneWidget);
  });

  testWidgets('renders rejected status reasons', (tester) async {
    await tester.pumpWidget(buildSubject(AccountStatusKind.rejected));

    expect(find.text('Application rejected'), findsOneWidget);
    expect(find.text('Rejection reason'), findsOneWidget);
    expect(find.text('Civil ID does not match the submitted data'), findsOneWidget);
    expect(find.text('Driving license validity date has expired'), findsOneWidget);
    expect(find.text('Vehicle registration photo is unclear'), findsOneWidget);
  });

  testWidgets('renders more information required reasons', (tester) async {
    await tester.pumpWidget(buildSubject(AccountStatusKind.moreInformationRequired));

    expect(find.text('Data changes required'), findsOneWidget);
    expect(find.text('Reason for requested changes'), findsOneWidget);
    expect(find.text('Driving license is unclear'), findsOneWidget);
    expect(find.text('Vehicle registration is expired'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Edit and resend'), findsOneWidget);
  });

  testWidgets('renders under review dashboard status', (tester) async {
    await tester.pumpWidget(buildSubject(AccountStatusKind.underReview));

    expect(find.text('Account status'), findsOneWidget);
    expect(find.text('We are checking your data and documents'), findsOneWidget);
    expect(find.text('Your account is under review'), findsOneWidget);
    expect(find.text('Need help?'), findsOneWidget);
    expect(find.text('Get help'), findsOneWidget);
    expect(find.text('We appreciate your patience, and promise you a successful and safe delivery experience\nwith MealMate'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/account_status_screen_test.dart`

Expected: FAIL because `features/account_status` imports do not exist.

### Task 2: Assets, Localization, and Theme Tokens

**Files:**
- Modify: `lib/core/constants/assets.dart`
- Modify: `lib/core/l10n/app_en.arb`
- Modify: `lib/core/l10n/app_ar.arb`
- Generated: `lib/core/l10n/translations/app_localizations.dart`
- Generated: `lib/core/l10n/translations/app_localizations_en.dart`
- Generated: `lib/core/l10n/translations/app_localizations_ar.dart`
- Modify: `lib/config/theme/colors.dart`
- Modify: `lib/config/theme/app_theme.dart`
- Modify: `lib/config/theme/spacing.dart`

**Interfaces:**
- Produces: `AppAssets.accountStatusAccepted`, `AppAssets.accountStatusRejected`, `AppAssets.accountStatusMoreInfo`, `AppAssets.accountStatusUnderReview`.
- Produces: localization getters beginning with `accountStatus`.

- [ ] **Step 1: Export Figma images**

Use the Figma connector to download the image nodes:
- `2023:5413` to `assets/images/auth/account_status_accepted.png`
- `2023:5439` to `assets/images/auth/account_status_rejected.png`
- `2023:5462` to `assets/images/auth/account_status_more_info.png`
- `1522:13277` to `assets/images/auth/account_status_under_review.png`

- [ ] **Step 2: Add asset constants**

Add constants to `AppAssets` for the four exported PNG paths.

- [ ] **Step 3: Add localization keys**

Add English and Arabic keys for titles, body text, action text, section labels, and reason items listed in the spec.

- [ ] **Step 4: Regenerate localizations**

Run: `flutter gen-l10n`

- [ ] **Step 5: Add theme and spacing tokens**

Add account-status-specific spacing constants that match Figma verified dimensions. Add any required color constants to `AppColors`, then expose them through the `ColorScheme` slots already used by status semantics.

### Task 3: Domain Model

**Files:**
- Create: `lib/features/account_status/domain/account_status_kind.dart`
- Create: `lib/features/account_status/domain/account_status_reason_tone.dart`
- Create: `lib/features/account_status/domain/account_status_data.dart`

**Interfaces:**
- Produces: `enum AccountStatusKind { underReview, moreInformationRequired, rejected, accepted }`
- Produces: `enum AccountStatusReasonTone { warning, error }`
- Produces: immutable `AccountStatusData`.

- [ ] **Step 1: Implement minimal domain types**

Create the enums and data class needed by the screen configuration.

- [ ] **Step 2: Run tests**

Run: `flutter test test/account_status_screen_test.dart`

Expected: FAIL because presentation files do not exist yet.

### Task 4: Presentation Widgets and Screen

**Files:**
- Create: `lib/features/account_status/presentation/screens/account_status_screen.dart`
- Create: `lib/features/account_status/presentation/widgets/account_status_action_buttons.dart`
- Create: `lib/features/account_status/presentation/widgets/account_status_header.dart`
- Create: `lib/features/account_status/presentation/widgets/account_status_illustration.dart`
- Create: `lib/features/account_status/presentation/widgets/account_status_reason_panel.dart`
- Create: `lib/features/account_status/presentation/widgets/account_status_result_content.dart`
- Create: `lib/features/account_status/presentation/widgets/account_under_review_card.dart`
- Create: `lib/features/account_status/presentation/widgets/account_status_help_card.dart`
- Create: `lib/features/account_status/presentation/widgets/account_status_trust_note.dart`

**Interfaces:**
- Consumes: localization getters and `AccountStatusKind`.
- Produces: `AccountStatusScreen({required AccountStatusKind kind, VoidCallback? onPrimaryPressed, VoidCallback? onSecondaryPressed, VoidCallback? onHelpPressed})`.

- [ ] **Step 1: Implement screen and widgets**

Use `Scaffold`, `SafeArea`, `SingleChildScrollView`, existing `AuthHeaderLogo.compact`, existing `AppButton`, theme colors, spacing constants, and localized text only.

- [ ] **Step 2: Run tests**

Run: `flutter test test/account_status_screen_test.dart`

Expected: PASS.

### Task 5: Routing

**Files:**
- Modify: `lib/config/routing/app_routes.dart`
- Modify: `lib/config/routing/routing_generator.dart`
- Create: `test/account_status_route_test.dart`

**Interfaces:**
- Consumes: `AccountStatusKind`.
- Produces: `AppRoutes.accountStatus`.

- [ ] **Step 1: Write route test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/account_status/domain/account_status_kind.dart';

void main() {
  testWidgets('account status route defaults to under review', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        onGenerateRoute: RouteGenerator.getRoute,
        initialRoute: AppRoutes.accountStatus,
      ),
    );

    expect(find.text('Your account is under review'), findsOneWidget);
  });

  testWidgets('account status route accepts a status kind argument', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        onGenerateRoute: RouteGenerator.getRoute,
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.accountStatus,
                  arguments: AccountStatusKind.accepted,
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Your account has been accepted!'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run route test to verify it fails**

Run: `flutter test test/account_status_route_test.dart`

Expected: FAIL because route is not wired.

- [ ] **Step 3: Implement route**

Add `AppRoutes.accountStatus = '/account-status'`; import account status types in `routing_generator.dart`; map route arguments to `AccountStatusKind` with fallback to `underReview`.

- [ ] **Step 4: Run route test**

Run: `flutter test test/account_status_route_test.dart`

Expected: PASS.

### Task 6: Final Verification

**Files:**
- All feature files from prior tasks.

**Interfaces:**
- Consumes: complete account status feature.
- Produces: verified implementation.

- [ ] **Step 1: Format changed Dart files**

Run: `dart format lib test`

- [ ] **Step 2: Analyze**

Run: `flutter analyze`

- [ ] **Step 3: Run relevant tests**

Run: `flutter test test/account_status_screen_test.dart test/account_status_route_test.dart`

- [ ] **Step 4: Review diff**

Run: `git diff --stat` and inspect changed files to make sure unrelated user edits were not reverted.
