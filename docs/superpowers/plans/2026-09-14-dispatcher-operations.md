# Dispatcher Operations Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Dispatcher Operations Screen (`10.10 - Operations Log` from Figma Node `1825:9909`) under `lib/features/dispatcher/operations/` and add its navigation entry point in `DispatcherProfileScreen`.

**Architecture:** Clean architecture feature module (`domain` with entities and fake data, `presentation` with screen and isolated single-widget components). Adheres strictly to `rules/ui_rules.md` (one widget per file, buildContext rules, colors via `context.colorScheme`, localization via `context.localization`, spacing tokens, styles manager).

**Tech Stack:** Flutter / Dart, `flutter_localizations`, `CustomAppBar`, `AppRoutes`.

**Spec:** `docs/superpowers/specs/2026-09-14-operations-log-design.md`

## Global Constraints

- Modify only requested files; do not create unnecessary files.
- Exactly one widget class per file in `presentation/widgets/`. No private widget classes (`_Card`, `_Item`, etc.).
- Obtain UI colors only from `color = context.colorScheme;`. Never use `Colors.*`, `Color(...)`, or `AppColors` directly in widgets.
- Obtain user-facing text only from `locale = context.localization;`. Never hardcode user-facing strings.
- Obtain styles only from `styles_manager.dart`.
- Obtain spacing and radii only from `Spacing.*` in `lib/config/theme/spacing.dart`.
- Directional layouts: use `EdgeInsetsDirectional`, `AlignmentDirectional`. Never reverse children manually for RTL/LTR.

---

### Task 1: Localization Keys & Routing Setup

**Files:**
- Modify: `lib/core/l10n/app_ar.arb`
- Modify: `lib/core/l10n/app_en.arb`
- Modify: `lib/config/routing/app_routes.dart`
- Modify: `lib/config/routing/routing_generator.dart`

**Interfaces:**
- Produces: Localization keys on `AppLocalizations` (`operationsTitle`, `operationsSearchPlaceholder`, `operationsLast7Days`, `operationsFilter`, `operationsTabAll`, `operationsTabCompleted`, `operationsTabCancelled`, `operationsTabFailed`, `operationsTabReassigned`, `operationsCustomerPrefix`, `operationsCancelledByRestaurant`, `operationsPrevPage`, `operationsNextPage`, `profileOperationsSubtitle`) and route `AppRoutes.dispatcherOperations`.

- [x] **Step 1: Add localization keys to `lib/core/l10n/app_ar.arb` and `lib/core/l10n/app_en.arb`**
- [x] **Step 2: Generate localizations using `flutter gen-l10n`**
- [x] **Step 3: Add `dispatcherOperations` route to `lib/config/routing/app_routes.dart` and `routing_generator.dart`**
- [x] **Step 4: Verify `flutter analyze` passes**
- [x] **Step 5: Commit changes**

---

### Task 2: Domain Layer (Entities & Fake Data)

**Files:**
- Create: `lib/features/dispatcher/operations/domain/entities/operation_status.dart`
- Create: `lib/features/dispatcher/operations/domain/entities/operation_item_entity.dart`
- Create: `lib/features/dispatcher/operations/domain/entities/operations_filter_entity.dart`
- Create: `lib/features/dispatcher/operations/domain/fake_data/operations_fake_data.dart`

**Interfaces:**
- Produces: `OperationStatus` enum (`completed`, `cancelled`, `failed`, `reassigned`), `OperationItemEntity`, `OperationsFilterEntity`, `OperationsFakeData.sampleOperations`.

- [x] **Step 1: Create `operation_status.dart`**
- [x] **Step 2: Create `operation_item_entity.dart`**
- [x] **Step 3: Create `operations_filter_entity.dart`**
- [x] **Step 4: Create `operations_fake_data.dart` with samples from Figma Node 1825:9909**
- [x] **Step 5: Verify `flutter analyze`**
- [x] **Step 6: Commit changes**

---

### Task 3: Presentation Widgets (1 Widget Per File)

**Files:**
- Create: `lib/features/dispatcher/operations/presentation/widgets/operations_app_bar.dart`
- Create: `lib/features/dispatcher/operations/presentation/widgets/operations_search_filter_bar.dart`
- Create: `lib/features/dispatcher/operations/presentation/widgets/operations_status_tab_item.dart`
- Create: `lib/features/dispatcher/operations/presentation/widgets/operations_status_tabs.dart`
- Create: `lib/features/dispatcher/operations/presentation/widgets/operations_driver_info.dart`
- Create: `lib/features/dispatcher/operations/presentation/widgets/operations_reassigned_info.dart`
- Create: `lib/features/dispatcher/operations/presentation/widgets/operations_cancelled_info.dart`
- Create: `lib/features/dispatcher/operations/presentation/widgets/operations_customer_info.dart`
- Create: `lib/features/dispatcher/operations/presentation/widgets/operations_status_badge.dart`
- Create: `lib/features/dispatcher/operations/presentation/widgets/operations_card.dart`
- Create: `lib/features/dispatcher/operations/presentation/widgets/operations_pagination_bar.dart`

**Interfaces:**
- Produces: High-fidelity, modular Flutter widgets respecting `rules/ui_rules.md`.

- [x] **Step 1: Implement `operations_app_bar.dart` (Back button, title, filter button)**
- [x] **Step 2: Implement `operations_search_filter_bar.dart` (Search box & date filter)**
- [x] **Step 3: Implement `operations_status_tab_item.dart` and `operations_status_tabs.dart`**
- [x] **Step 4: Implement card sub-widgets (`operations_driver_info.dart`, `operations_reassigned_info.dart`, `operations_cancelled_info.dart`, `operations_customer_info.dart`, `operations_status_badge.dart`)**
- [x] **Step 5: Implement `operations_card.dart` combining the sub-widgets**
- [x] **Step 6: Implement `operations_pagination_bar.dart`**
- [x] **Step 7: Verify `flutter analyze`**
- [x] **Step 8: Commit changes**

---

### Task 4: Screen & Profile Entry Point Integration

**Files:**
- Create: `lib/features/dispatcher/operations/presentation/screens/dispatcher_operations_screen.dart`
- Create: `lib/features/dispatcher/profile/presentation/widgets/dispatcher_profile_operations_card.dart`
- Modify: `lib/features/dispatcher/profile/presentation/screens/dispatcher_profile_screen.dart`
- Modify: `lib/config/routing/routing_generator.dart` (connect screen to route)

- [x] **Step 1: Implement `DispatcherOperationsScreen` composing the presentation widgets**
- [x] **Step 2: Implement `DispatcherProfileOperationsCard` with icon, title, subtitle, chevron**
- [x] **Step 3: Add `DispatcherProfileOperationsCard` into `DispatcherProfileScreen`**
- [x] **Step 4: Link `RoutingGenerator` to `DispatcherOperationsScreen`**
- [x] **Step 5: Verify `flutter analyze`**
- [x] **Step 6: Commit changes**

---

### Task 5: Testing & Verification

**Files:**
- Create: `test/features/dispatcher/operations/dispatcher_operations_screen_test.dart`

- [x] **Step 1: Write widget test verifying screen rendering, search, status tabs, and card list**
- [x] **Step 2: Run all tests with `flutter test`**
- [x] **Step 3: Run `flutter analyze`**
- [x] **Step 4: Commit changes**
