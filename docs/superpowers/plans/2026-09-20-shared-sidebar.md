# Shared App Sidebar in Core Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the shared navigation sidebar (`AppSidebar`) in `lib/core/app_shell/` based on Figma Node `3038:11112`, providing full support for both Driver (`UserRole.driver`) and Dispatcher (`UserRole.operations`) roles with strict compliance to [`rules/ui_rules.md`](file:///d:/projects/meal_mate_delivery/rules/ui_rules.md).

**Architecture:** A clean modular architecture under `lib/core/app_shell/` divided into domain entities (`SidebarItemEntity`, `SidebarUserEntity`), role-based fake data (`SidebarFakeData`), and presentation widgets strictly divided one-widget-per-file (Container, Header, Status Chip, Nav Item Tile, Nav List, Driver Status Card, Logout Button, Version Footer). The sidebar mounts directly in `Scaffold.drawer` inside `AppShellScreen` or can be used stand-alone.

**Tech Stack:** Flutter / Dart, `flutter_localizations`, SVG rendering, Material 3 theming with `Theme.of(context).colorScheme`.

**Spec:** [`docs/superpowers/specs/2026-09-20-shared-sidebar-design.md`](file:///d:/projects/meal_mate_delivery/docs/superpowers/specs/2026-09-20-shared-sidebar-design.md)

## Global Constraints

- One widget per file (all public classes, no private `_Widget` classes).
- Always declare `final color = context.colorScheme;` and `final locale = context.localization;` when used.
- Never hardcode colors, strings, or spacing values. Use `Spacing.*`, `color.*`, `styles_manager.dart`.
- Directional layout support (inherited RTL/LTR without locale checks).
- Full localization keys in `app_ar.arb` and `app_en.arb`.
- Fake data source with clean entities.
- Zero analysis issues (`flutter analyze` passes cleanly).

---

### Task 1: Add Localization Strings

**Files:**
- Modify: `lib/core/l10n/app_ar.arb`
- Modify: `lib/core/l10n/app_en.arb`

**Interfaces:**
- Produces: `locale.sidebarStatusOnline`, `locale.sidebarHome`, `locale.sidebarOrders`, `locale.sidebarMap`, `locale.sidebarAnalytics`, `locale.sidebarOperationsLog`, `locale.sidebarNotifications`, `locale.sidebarHelpSupport`, `locale.sidebarSettings`, `locale.sidebarSafetySecurity`, `locale.sidebarDriverStatusTitle`, `locale.sidebarDriverOffDuty`, `locale.sidebarDriverOnDuty`, `locale.sidebarDriverStatusSubtitle`, `locale.sidebarLogout`, `locale.sidebarAppVersion(version)`.

- [ ] **Step 1: Update `app_ar.arb` and `app_en.arb`**
Add the new sidebar localization keys with translations and descriptions.

- [ ] **Step 2: Run `flutter gen-l10n`**
Run `flutter gen-l10n` in terminal to regenerate localization files.

- [ ] **Step 3: Verify generation**
Verify that `AppLocalizations` has all new getter methods without errors.

- [ ] **Step 4: Commit**
```bash
git add lib/core/l10n/
git commit -m "feat(l10n): add localization keys for shared app sidebar"
```

---

### Task 2: Create Domain Entities & Fake Data

**Files:**
- Create: `lib/core/app_shell/domain/entities/sidebar_item_entity.dart`
- Create: `lib/core/app_shell/domain/entities/sidebar_user_entity.dart`
- Create: `lib/core/app_shell/domain/fake_data/sidebar_fake_data.dart`
- Create: `test/core/app_shell/domain/sidebar_entities_test.dart`

**Interfaces:**
- Produces:
  - `SidebarItemEntity`
  - `SidebarUserEntity`
  - `SidebarFakeData.getDefaultUser(role)`
  - `SidebarFakeData.getDefaultItems(role, activeId)`

- [ ] **Step 1: Write failing unit test**
Write test in `test/core/app_shell/domain/sidebar_entities_test.dart` asserting entity instantiation, property integrity, and default items generation for driver and operations roles.

- [ ] **Step 2: Run test to verify failure**
Run: `flutter test test/core/app_shell/domain/sidebar_entities_test.dart`
Expected: Compilation failure (classes not yet defined).

- [ ] **Step 3: Implement entities and fake data**
Create `sidebar_item_entity.dart`, `sidebar_user_entity.dart`, and `sidebar_fake_data.dart`.

- [ ] **Step 4: Run test to verify pass**
Run: `flutter test test/core/app_shell/domain/sidebar_entities_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**
```bash
git add lib/core/app_shell/domain/ test/core/app_shell/domain/
git commit -m "feat(core): add sidebar domain entities and fake data"
```

---

### Task 3: Create User Header, Status Chip, Notification Badge & Version Footer

**Files:**
- Create: `lib/core/app_shell/widgets/sidebar/sidebar_user_status_chip.dart`
- Create: `lib/core/app_shell/widgets/sidebar/sidebar_user_header.dart`
- Create: `lib/core/app_shell/widgets/sidebar/sidebar_notification_badge.dart`
- Create: `lib/core/app_shell/widgets/sidebar/sidebar_version_footer.dart`
- Create: `test/core/app_shell/widgets/sidebar_header_widgets_test.dart`

**Interfaces:**
- Produces:
  - `SidebarUserStatusChip({Key? key, required bool isOnline, String? label})`
  - `SidebarUserHeader({Key? key, required SidebarUserEntity user})`
  - `SidebarNotificationBadge({Key? key, required int count})`
  - `SidebarVersionFooter({Key? key, required String version})`

- [ ] **Step 1: Write widget test for header, status chip, badge, and footer**
Create `test/core/app_shell/widgets/sidebar_header_widgets_test.dart`.

- [ ] **Step 2: Run test to verify failure**
Run: `flutter test test/core/app_shell/widgets/sidebar_header_widgets_test.dart`
Expected: FAIL (widgets not yet created).

- [ ] **Step 3: Implement the four atomic widgets**
Implement each widget in its own file adhering strictly to [`rules/ui_rules.md`](file:///d:/projects/meal_mate_delivery/rules/ui_rules.md).

- [ ] **Step 4: Run test to verify pass**
Run: `flutter test test/core/app_shell/widgets/sidebar_header_widgets_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**
```bash
git add lib/core/app_shell/widgets/sidebar/ test/core/app_shell/widgets/
git commit -m "feat(core): add sidebar user header, status chip, badge, and footer widgets"
```

---

### Task 4: Create Navigation Item Tile & Navigation List

**Files:**
- Create: `lib/core/app_shell/widgets/sidebar/sidebar_nav_item_tile.dart`
- Create: `lib/core/app_shell/widgets/sidebar/sidebar_nav_list.dart`
- Create: `test/core/app_shell/widgets/sidebar_nav_item_test.dart`

**Interfaces:**
- Produces:
  - `SidebarNavItemTile({Key? key, required SidebarItemEntity item, VoidCallback? onTap})`
  - `SidebarNavList({Key? key, required List<SidebarItemEntity> items, ValueChanged<SidebarItemEntity>? onItemTap})`

- [ ] **Step 1: Write widget test for nav item tile and list**
Verify active styling (accent start line, container tint, bold primary text) vs inactive styling (trailing chevron, optional badge, transparent background) and item tap interaction.

- [ ] **Step 2: Run test to verify failure**
Run: `flutter test test/core/app_shell/widgets/sidebar_nav_item_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement `SidebarNavItemTile` and `SidebarNavList`**
Implement widgets in separate files respecting exact Figma specs and directionality.

- [ ] **Step 4: Run test to verify pass**
Run: `flutter test test/core/app_shell/widgets/sidebar_nav_item_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**
```bash
git add lib/core/app_shell/widgets/sidebar/ test/core/app_shell/widgets/
git commit -m "feat(core): add sidebar nav item tile and list widgets"
```

---

### Task 5: Create Driver Status Card & Logout Button

**Files:**
- Create: `lib/core/app_shell/widgets/sidebar/sidebar_driver_status_card.dart`
- Create: `lib/core/app_shell/widgets/sidebar/sidebar_logout_button.dart`
- Create: `test/core/app_shell/widgets/sidebar_bottom_widgets_test.dart`

**Interfaces:**
- Produces:
  - `SidebarDriverStatusCard({Key? key, required SidebarUserEntity user})`
  - `SidebarLogoutButton({Key? key, VoidCallback? onLogout})`

- [ ] **Step 1: Write widget test for driver status card and logout button**
Test rendering of driver status card with car illustration, online/offline status text, and logout button tap.

- [ ] **Step 2: Run test to verify failure**
Run: `flutter test test/core/app_shell/widgets/sidebar_bottom_widgets_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement `SidebarDriverStatusCard` and `SidebarLogoutButton`**
Use `assets/images/driver/driver_sidebar_car.png` for the illustration, and format the outline button matching Figma node `3038:11112`.

- [ ] **Step 4: Run test to verify pass**
Run: `flutter test test/core/app_shell/widgets/sidebar_bottom_widgets_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**
```bash
git add lib/core/app_shell/widgets/sidebar/ test/core/app_shell/widgets/
git commit -m "feat(core): add sidebar driver status card and logout button"
```

---

### Task 6: Create Main `AppSidebar` Container & Connect to `AppShellScreen`

**Files:**
- Create: `lib/core/app_shell/widgets/sidebar/app_sidebar.dart`
- Modify: `lib/core/app_shell/screens/app_shell_screen.dart`
- Create: `test/core/app_shell/widgets/app_sidebar_test.dart`

**Interfaces:**
- Produces:
  - `AppSidebar({Key? key, UserRole role = UserRole.operations, SidebarUserEntity? user, List<SidebarItemEntity>? items, ValueChanged<SidebarItemEntity>? onItemSelected, VoidCallback? onLogout})`

- [ ] **Step 1: Write widget test for `AppSidebar`**
Test that `AppSidebar` renders correctly for both `UserRole.driver` (showing status card, 9 items) and `UserRole.operations` (showing dispatcher items, no driver status card), and responds to item selection and logout.

- [ ] **Step 2: Run test to verify failure**
Run: `flutter test test/core/app_shell/widgets/app_sidebar_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement `AppSidebar` and attach to `AppShellScreen`**
Create `app_sidebar.dart` composing the modular child widgets inside a `Drawer`.
In `AppShellScreen`, add `drawer: AppSidebar(role: widget.role, onItemSelected: ...)` to `Scaffold`.

- [ ] **Step 4: Run test to verify pass**
Run: `flutter test test/core/app_shell/widgets/app_sidebar_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**
```bash
git add lib/core/app_shell/ test/core/app_shell/
git commit -m "feat(core): assemble AppSidebar and integrate into AppShellScreen"
```

---

### Task 7: Full Verification & Code Quality Validation

**Files:**
- All touched files

- [ ] **Step 1: Run `flutter analyze`**
Ensure zero errors, warnings, or lints.

- [ ] **Step 2: Run all tests**
Run: `flutter test`
Ensure all tests across the repository pass without regressions.

- [ ] **Step 3: Final Commit**
```bash
git commit --allow-empty -m "chore: verify tests and analyzer for shared app sidebar"
```
