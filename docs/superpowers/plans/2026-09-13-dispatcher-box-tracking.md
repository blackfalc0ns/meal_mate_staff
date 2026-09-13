# Dispatcher Box Tracking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Dispatcher Box Tracking Screen (`10.08 - Box Tracking` from Figma Node `1825:9412`) under `lib/features/dispatcher/box_tracking/` to allow dispatchers to track active order progress, view assigned driver info, inspect order details, and report issues.

**Architecture:** Clean architecture feature module (`domain` with entities and fake data, `presentation` with screen and isolated single-widget components). Adheres strictly to `rules/ui_rules.md` (one widget per file, buildContext rules, colors via `context.colorScheme`, localization via `context.localization`, spacing tokens, styles manager).

**Tech Stack:** Flutter / Dart, `flutter_localizations`, `flutter_svg`, `CustomAppBar`, `AppButton`.

**Spec:** `docs/superpowers/specs/2026-09-13-dispatcher-box-tracking-design.md`

## Global Constraints

- Modify only requested files; do not create unnecessary files.
- Exactly one widget class per file in `presentation/widgets/`. No private widget classes (`_Card`, `_Item`, etc.).
- Obtain UI colors only from `color = context.colorScheme;`. Never use `Colors.*`, `Color(...)`, or `AppColors` directly in widgets.
- Obtain user-facing text only from `locale = context.localization;`. Never hardcode user-facing strings.
- Obtain styles only from `styles_manager.dart`.
- Obtain spacing and radii only from `Spacing.*` in `lib/config/theme/spacing.dart`.
- Directional layouts: use `EdgeInsetsDirectional`, `AlignmentDirectional`. Never reverse children manually for RTL/LTR.

---

### Task 1: Localization & Routing

**Files:**
- Modify: `lib/core/l10n/app_ar.arb`
- Modify: `lib/core/l10n/app_en.arb`
- Modify: `lib/config/routing/app_routes.dart`
- Modify: `lib/config/routing/routing_generator.dart`

**Interfaces:**
- Produces: Localization getters on `AppLocalizations` (`boxTrackingTitle`, `boxTrackingStatusOnTheWay`, etc.) and `AppRoutes.boxTracking`.

- [ ] **Step 1: Add localization keys to `lib/core/l10n/app_ar.arb` and `lib/core/l10n/app_en.arb`**

Add keys:
`boxTrackingTitle`, `boxTrackingCustomerLabel`, `boxTrackingStatusOnTheWay`, `boxTrackingStatusReady`, `boxTrackingStatusPickedUp`, `boxTrackingStatusDelivered`, `boxTrackingTimelineTitle`, `boxTrackingLiveTrack`, `boxTrackingSendMessage`, `boxTrackingCall`, `boxTrackingDetailsTitle`, `boxTrackingPlanType`, `boxTrackingOrderDate`, `boxTrackingMealCount`, `boxTrackingCustomerNotes`, `boxTrackingReportIssue`.

- [ ] **Step 2: Generate localizations**

Run: `flutter gen-l10n`
Expected: Localization files updated with no errors.

- [ ] **Step 3: Add `boxTracking` route to `lib/config/routing/app_routes.dart` and `routing_generator.dart`**

Add `static const String boxTracking = '/box-tracking';` to `AppRoutes`.
Add case in `RoutingGenerator.generateRoute` routing to placeholder or future `DispatcherBoxTrackingScreen`.

- [ ] **Step 4: Verify analyzer**

Run: `flutter analyze`
Expected: 0 issues.

- [ ] **Step 5: Commit**

Run:
```bash
git add lib/core/l10n/ lib/config/routing/
git commit -m "feat(l10n): add box tracking strings and route"
```

---

### Task 2: Domain Layer (Entities & Fake Data)

**Files:**
- Create: `lib/features/dispatcher/box_tracking/domain/entities/box_tracking_driver_entity.dart`
- Create: `lib/features/dispatcher/box_tracking/domain/entities/box_tracking_step_entity.dart`
- Create: `lib/features/dispatcher/box_tracking/domain/entities/box_tracking_entity.dart`
- Create: `lib/features/dispatcher/box_tracking/domain/fake_data/box_tracking_fake_data.dart`
- Test: `test/features/dispatcher/box_tracking/domain/box_tracking_entity_test.dart`

**Interfaces:**
- Produces: `BoxTrackingEntity`, `BoxTrackingDriverEntity`, `BoxTrackingStepEntity`, `BoxTrackingStatus`, `BoxTrackingFakeData.defaultBox`.

- [ ] **Step 1: Write unit test for `BoxTrackingEntity` and `BoxTrackingFakeData`**

Test default fake data properties, step counts, active step detection, and driver data.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/dispatcher/box_tracking/domain/box_tracking_entity_test.dart`
Expected: Compilation failure (entities not yet created).

- [ ] **Step 3: Implement entities and fake data**

Create:
- `box_tracking_driver_entity.dart`: `id`, `name`, `phone`, `isOnline`.
- `box_tracking_step_entity.dart`: `title`, `time`, `isCompleted`, `isActive`.
- `box_tracking_entity.dart`: `boxId`, `customerName`, `deliveryAddress`, `deliveryTime`, `status`, `driver`, `planType`, `orderDate`, `mealCount`, `customerNotes`, `steps`.
- `box_tracking_fake_data.dart`: realistic Figma data matching node `1825:9412`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/dispatcher/box_tracking/domain/box_tracking_entity_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

Run:
```bash
git add lib/features/dispatcher/box_tracking/domain/ test/features/dispatcher/box_tracking/
git commit -m "feat(domain): add box tracking entities and fake data"
```

---

### Task 3: Header & Details UI Components

**Files:**
- Create: `lib/features/dispatcher/box_tracking/presentation/widgets/box_tracking_app_bar.dart`
- Create: `lib/features/dispatcher/box_tracking/presentation/widgets/box_tracking_header_card.dart`
- Create: `lib/features/dispatcher/box_tracking/presentation/widgets/box_tracking_details_row.dart`
- Create: `lib/features/dispatcher/box_tracking/presentation/widgets/box_tracking_details_card.dart`

**Interfaces:**
- Consumes: `BoxTrackingEntity`, `CustomAppBar`, `Spacing.*`, `color.*`, `locale.*`.
- Produces: Isolated single-widget components adhering to `rules/ui_rules.md`.

- [ ] **Step 1: Implement `BoxTrackingAppBar`**

Wraps `CustomAppBar` with `title: locale.boxTrackingTitle`, `showBackButton: true`, `centerTitle: true`, and options action.

- [ ] **Step 2: Implement `BoxTrackingHeaderCard`**

Renders Box ID `#BX-10256`, status badge (`في الطريق`), customer name, destination address, scheduled delivery time, and 3D box graphic (`AppAssets.driverBox3d`).

- [ ] **Step 3: Implement `BoxTrackingDetailsRow`**

Helper component in its own file rendering an icon, label (`color.onSurfaceVariant`), and value (`color.onSurface`).

- [ ] **Step 4: Implement `BoxTrackingDetailsCard`**

Container card composing `BoxTrackingDetailsRow` items for Plan Type, Order Date, Meal Count, and Customer Notes.

- [ ] **Step 5: Verify analyzer**

Run: `flutter analyze`
Expected: 0 issues.

- [ ] **Step 6: Commit**

Run:
```bash
git add lib/features/dispatcher/box_tracking/presentation/widgets/box_tracking_app_bar.dart lib/features/dispatcher/box_tracking/presentation/widgets/box_tracking_header_card.dart lib/features/dispatcher/box_tracking/presentation/widgets/box_tracking_details_row.dart lib/features/dispatcher/box_tracking/presentation/widgets/box_tracking_details_card.dart
git commit -m "feat(widgets): add box tracking header and details widgets"
```

---

### Task 4: Timeline, Driver & Bottom Action Components

**Files:**
- Create: `lib/features/dispatcher/box_tracking/presentation/widgets/box_tracking_timeline_step_item.dart`
- Create: `lib/features/dispatcher/box_tracking/presentation/widgets/box_tracking_timeline_card.dart`
- Create: `lib/features/dispatcher/box_tracking/presentation/widgets/box_tracking_driver_card.dart`
- Create: `lib/features/dispatcher/box_tracking/presentation/widgets/box_tracking_report_issue_button.dart`

**Interfaces:**
- Consumes: `BoxTrackingStepEntity`, `BoxTrackingDriverEntity`, `AppButton`, `AppAssets`.
- Produces: Delivery timeline, driver interaction card, and report issue action.

- [ ] **Step 1: Implement `BoxTrackingTimelineStepItem`**

Renders a step with checkmark icon for completed, highlighted circle for active, muted circle for pending, dashed/solid connecting line, title, and timestamp.

- [ ] **Step 2: Implement `BoxTrackingTimelineCard`**

Card rendering `locale.boxTrackingTimelineTitle` and iterating through `steps` using `BoxTrackingTimelineStepItem`.

- [ ] **Step 3: Implement `BoxTrackingDriverCard`**

Card showing driver avatar, name, ID, online badge, and 3 buttons using `AppButton` (`Live Track` filled, `Message` outlined, `Call` outlined).

- [ ] **Step 4: Implement `BoxTrackingReportIssueButton`**

Outlined button with `color.error`, warning icon, and text `locale.boxTrackingReportIssue`.

- [ ] **Step 5: Verify analyzer**

Run: `flutter analyze`
Expected: 0 issues.

- [ ] **Step 6: Commit**

Run:
```bash
git add lib/features/dispatcher/box_tracking/presentation/widgets/
git commit -m "feat(widgets): add box tracking timeline, driver card, and action button"
```

---

### Task 5: Screen Assembly & Comprehensive Testing

**Files:**
- Create: `lib/features/dispatcher/box_tracking/presentation/screens/dispatcher_box_tracking_screen.dart`
- Modify: `lib/config/routing/routing_generator.dart` (wire screen to route)
- Test: `test/features/dispatcher/box_tracking/dispatcher_box_tracking_screen_test.dart`

**Interfaces:**
- Produces: `DispatcherBoxTrackingScreen`.

- [ ] **Step 1: Assemble `DispatcherBoxTrackingScreen`**

Compose all cards inside a scrollable view with padding, `appBar: BoxTrackingAppBar`, and bottom report issue button.

- [ ] **Step 2: Connect screen in `routing_generator.dart`**

Import `DispatcherBoxTrackingScreen` and return it on `AppRoutes.boxTracking`.

- [ ] **Step 3: Write comprehensive widget test suite in `dispatcher_box_tracking_screen_test.dart`**

Tests:
1. Renders all cards and components in RTL Arabic.
2. Renders properly in English locale.
3. Triggers callbacks (onBack, onMore, onLiveTracking, onSendMessage, onCall, onReportIssue).
4. Renders without overflow on narrow viewport (360x720).
5. Renders without overflow on extra small viewport (320x640).

- [ ] **Step 4: Run test suite**

Run: `flutter test test/features/dispatcher/box_tracking/`
Expected: All tests pass.

- [ ] **Step 5: Run full project analyzer**

Run: `flutter analyze`
Expected: 0 issues.

- [ ] **Step 6: Final Commit**

Run:
```bash
git add lib/features/dispatcher/box_tracking/ test/features/dispatcher/box_tracking/ lib/config/routing/
git commit -m "feat(box_tracking): assemble box tracking screen and add widget tests"
```
