# Driver Assigned Boxes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Driver Assigned Boxes Screen (Figma node `2397:6942`, `06.02 - Assigned Boxes`) with fake data, adhering strictly to `rules/ui_rules.md`.

**Architecture:** Domain entities for boxes and filter types, fake data source with initial loaded/unloaded boxes, modular presentation widgets (1 widget per file), Arabic and English localization strings, route integration, and widget tests.

**Tech Stack:** Flutter, Dart, `flutter_svg`, `flutter_localizations`, ARB files.

**Spec:** [docs/superpowers/specs/2026-09-15-driver-assigned-boxes-design.md](file:///d:/projects/meal_mate_delivery/docs/superpowers/specs/2026-09-15-driver-assigned-boxes-design.md)

## Global Constraints
- Strictly comply with [`rules/ui_rules.md`](file:///d:/projects/meal_mate_delivery/rules/ui_rules.md).
- One widget per file (all public classes, no private `_Widget` classes).
- Zero hardcoded colors, strings, or dimensions. Use `context.colorScheme`, `context.localization`, `Spacing.*`, and `styles_manager.dart`.
- No locale checks for text direction (rely on inherited `Directionality`).

---

### Task 1: Domain Entities and Fake Data

**Files:**
- Create: `lib/features/driver/orders/domain/entities/driver_boxes_filter_type.dart`
- Create: `lib/features/driver/orders/domain/entities/driver_assigned_box_entity.dart`
- Create: `lib/features/driver/orders/domain/fake_data/driver_assigned_boxes_fake_data.dart`

- [ ] **Step 1: Create filter type enum**
- [ ] **Step 2: Create box entity model**
- [ ] **Step 3: Create fake data matching Figma specs (32 meals, 8 boxes)**

---

### Task 2: Localization Strings & Route Constants

**Files:**
- Modify: `lib/core/l10n/app_ar.arb`
- Modify: `lib/core/l10n/app_en.arb`
- Modify: `lib/config/routing/app_routes.dart`
- Modify: `lib/config/routing/routing_generator.dart`

- [ ] **Step 1: Add Arabic localization keys for driver boxes**
- [ ] **Step 2: Add English localization keys for driver boxes**
- [ ] **Step 3: Run `flutter gen-l10n`**
- [ ] **Step 4: Register `AppRoutes.driverAssignedBoxes` in `AppRoutes` and `RouteGenerator`**

---

### Task 3: Header & Banner Presentation Widgets

**Files:**
- Create: `lib/features/driver/orders/presentation/widgets/driver_boxes_header_logo.dart`
- Create: `lib/features/driver/orders/presentation/widgets/driver_boxes_delivery_mode_chip.dart`
- Create: `lib/features/driver/orders/presentation/widgets/driver_boxes_title_bar.dart`
- Create: `lib/features/driver/orders/presentation/widgets/driver_boxes_stats_banner.dart`

- [ ] **Step 1: Implement `DriverBoxesHeaderLogo`**
- [ ] **Step 2: Implement `DriverBoxesDeliveryModeChip`**
- [ ] **Step 3: Implement `DriverBoxesTitleBar`**
- [ ] **Step 4: Implement `DriverBoxesStatsBanner`**

---

### Task 4: Filter Bar Presentation Widgets

**Files:**
- Create: `lib/features/driver/orders/presentation/widgets/driver_boxes_filter_tab_item.dart`
- Create: `lib/features/driver/orders/presentation/widgets/driver_boxes_filter_action_button.dart`
- Create: `lib/features/driver/orders/presentation/widgets/driver_boxes_filter_bar.dart`

- [ ] **Step 1: Implement `DriverBoxesFilterTabItem`**
- [ ] **Step 2: Implement `DriverBoxesFilterActionButton`**
- [ ] **Step 3: Implement `DriverBoxesFilterBar`**

---

### Task 5: Box Card & Sub-Components

**Files:**
- Create: `lib/features/driver/orders/presentation/widgets/driver_box_icon_badge.dart`
- Create: `lib/features/driver/orders/presentation/widgets/driver_box_ids_section.dart`
- Create: `lib/features/driver/orders/presentation/widgets/driver_box_meals_and_area_section.dart`
- Create: `lib/features/driver/orders/presentation/widgets/driver_box_status_pill.dart`
- Create: `lib/features/driver/orders/presentation/widgets/driver_box_action_section.dart`
- Create: `lib/features/driver/orders/presentation/widgets/driver_assigned_box_card.dart`

- [ ] **Step 1: Implement `DriverBoxIconBadge`**
- [ ] **Step 2: Implement `DriverBoxIdsSection`**
- [ ] **Step 3: Implement `DriverBoxMealsAndAreaSection`**
- [ ] **Step 4: Implement `DriverBoxStatusPill`**
- [ ] **Step 5: Implement `DriverBoxActionSection`**
- [ ] **Step 6: Implement `DriverAssignedBoxCard`**

---

### Task 6: Assemble Screen & App Shell Integration

**Files:**
- Create: `lib/features/driver/orders/presentation/screens/driver_assigned_boxes_screen.dart`
- Modify: `lib/core/app_shell/screens/app_shell_screen.dart`
- Test: `test/features/driver/orders/driver_assigned_boxes_screen_test.dart`

- [ ] **Step 1: Assemble `DriverAssignedBoxesScreen` with `ListView.separated`**
- [ ] **Step 2: Connect with `AppShellScreen` when role is driver or directly accessible**
- [ ] **Step 3: Write comprehensive widget test for rendering and filter interaction**
- [ ] **Step 4: Run `flutter test` and `flutter analyze`**
