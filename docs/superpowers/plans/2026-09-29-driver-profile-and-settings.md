# Driver Profile & Settings Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor existing settings functionality into `DriverSettingsScreen` and implement the authentic Driver Profile & Support screen matching Figma node `1275-4107`.

**Architecture:** Keep all code inside `lib/features/driver/driver_profile/`. The existing screen is renamed to `DriverSettingsScreen` with dedicated route `AppRoutes.driverSettings`. The new `DriverProfileScreen` serves as the 5th tab on `AppShellScreen` and composes individual widgets matching Figma node 1275-4107, strictly following `rules/ui_rules.md`.

**Tech Stack:** Flutter, Dart, Material 3, AppTheme, Localization (ARB).

**Spec:** `docs/superpowers/specs/2026-09-29-driver-profile-and-settings-design.md`

## Global Constraints
- Follow `rules/ui_rules.md` strictly:
  - `final color = context.colorScheme;` and `final locale = context.localization;` in build methods.
  - Never use hardcoded colors (`Colors.*` or `Color(...)`), always use `color.*` and semantic extensions.
  - Never use hardcoded text, always use `locale.*`.
  - Never guess spacing, use `Spacing.*` from `lib/config/theme/spacing.dart`.
  - Never create private widget classes (`_Header`, `_Card`, etc.). Keep exactly one widget class per file.
  - Support both RTL and LTR using directional APIs (`EdgeInsetsDirectional`, `AlignmentDirectional`).
  - No new feature folders outside `lib/features/driver/driver_profile/`.

---

### Task 1: Rename Existing Profile Screen to Driver Settings Screen
**Files:**
- Create: `lib/features/driver/driver_profile/presentation/screens/driver_settings_screen.dart`
- Delete/Replace: `lib/features/driver/driver_profile/presentation/screens/driver_profile_screen.dart` (will be recreated in Task 5)

- [ ] Rename `DriverProfileScreen` to `DriverSettingsScreen`.
- [ ] Ensure all constructor parameters and handlers remain intact.

---

### Task 2: Update AppRoutes and Routing Generator
**Files:**
- Modify: `lib/config/routing/app_routes.dart`
- Modify: `lib/config/routing/routing_generator.dart`

- [ ] Add `static const String driverSettings = '/driver-settings';` to `AppRoutes`.
- [ ] In `routing_generator.dart`, handle `AppRoutes.driverSettings` by returning `DriverSettingsScreen`.

---

### Task 3: Update Settings Screen Test
**Files:**
- Create/Rename: `test/driver_settings_screen_test.dart`

- [ ] Test `DriverSettingsScreen` in RTL Arabic and LTR English.
- [ ] Verify test passes with `flutter test test/driver_settings_screen_test.dart`.

---

### Task 4: Implement Profile Sub-Widgets (One Per File)
**Files:**
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_profile_header.dart`
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_profile_hero_card.dart`
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_profile_vehicle_card.dart`
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_profile_contact_card.dart`
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_profile_ticket_card.dart`
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_profile_quick_action_item.dart`
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_profile_quick_actions_row.dart`
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_profile_policy_banner.dart`

- [ ] Create `DriverProfileHeader` using `CustomAppBar.logo`.
- [ ] Create `DriverProfileHeroCard` with dark navy container, avatar, status dot, rating, and 4 driver metrics.
- [ ] Create `DriverProfileVehicleCard` with vehicle info and active chip.
- [ ] Create `DriverProfileContactCard` with headset icon and callback.
- [ ] Create `DriverProfileTicketCard` with ticket details and "View all" action.
- [ ] Create `DriverProfileQuickActionItem` and `DriverProfileQuickActionsRow` for Language, Settings, and Logout.
- [ ] Create `DriverProfilePolicyBanner` with checkmark icon and highlighted text.

---

### Task 5: Implement DriverProfileScreen
**Files:**
- Create: `lib/features/driver/driver_profile/presentation/screens/driver_profile_screen.dart`

- [ ] Compose all Task 4 widgets in a single scrollable view.
- [ ] Hook up callbacks for:
  - Settings tap -> `context.pushNamed(AppRoutes.driverSettings)`
  - Logout tap -> Show confirmation dialog
  - Support tap / View all -> `context.pushNamed(AppRoutes.driverSupport)` / `driverSupportTickets`
  - Notification tap -> `context.pushNamed(AppRoutes.driverNotifications)`

---

### Task 6: Write DriverProfileScreen Tests & Update AppShellScreen
**Files:**
- Create: `test/driver_profile_screen_test.dart`
- Verify: `lib/core/app_shell/screens/app_shell_screen.dart`

- [ ] Ensure `AppShellScreen` points to the new `DriverProfileScreen`.
- [ ] Write unit and widget tests covering all components and interactions.

---

### Task 7: Verification and Quality Checks
- [ ] Run `flutter test test/driver_settings_screen_test.dart test/driver_profile_screen_test.dart`.
- [ ] Run `flutter analyze`.
