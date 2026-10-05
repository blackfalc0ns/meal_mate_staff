# Driver Home Contract Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the existing unified Flutter Driver Home accurately implement the approved `GET /api/v1/driver/home` contract and render correct inactive, active-available, and active-busy states without driver-controlled shift actions.

**Architecture:** Keep the existing `ApiServices -> RemoteDataSource -> Repository -> UseCase -> ViewModel -> State -> UI` flow. Correct the DTO/entity/mapper boundary first, then bind the existing Home widgets directly to contract-accurate entities, preserving the existing SignalR notification-and-refetch strategy, Core error widgets, and initial shimmer.

**Tech Stack:** Flutter, Dart, flutter_bloc/Cubit, Dio, Retrofit, json_serializable, Injectable/GetIt, SignalR, flutter_test.

**Spec:** `docs/superpowers/specs/2026-10-05-driver-home-operational-status-design.md`

## Global Constraints

- Work only in `D:\projects\meal_mate_delivery`; scope is the Flutter driver application’s Home feature, not backend or dispatcher shift controls.
- Read `rules/rules_backend.md` before implementation and preserve its mandatory architecture.
- `GET /api/v1/driver/home` is the sole display-data source; `shiftStatus` alone selects Active versus Inactive.
- `isAvailable` only selects available versus busy inside Active Home.
- Never restore `POST /api/v1/driver/shift/start`, `POST /api/v1/driver/shift/end`, Start Work, or End Work actions.
- Response DTO fields and nested fields remain nullable and defensive; never use force unwrap to hide API nullability.
- Use existing `ApiResult`, `safeApiCall`, Dio, Retrofit, token/language interceptors, Injectable/GetIt, and localization.
- Use `ApiErrorWidget` for failure with no Home data and `InlineApiErrorWidget` for refresh failure with retained Home data.
- Use `DriverHomeShimmer`, built from `lib/core/widget/shimmer_widget.dart`, only for initial loading with no data.
- Preserve existing loaded content during refresh, SignalR reload, reconnect reload, and lifecycle-resume reload.
- Do not add packages, create another API client, create another SignalR connection, or redesign unrelated UI.
- Do not manually edit generated `*.g.dart`, `api_services.g.dart`, localization generated Dart, or generated DI files.
- Preserve unrelated user changes. Inspect `git status --short` before every task and stage only task-owned paths.
- Follow TDD: failing focused test, verify failure, minimal implementation, verify pass, commit.

## Backend Contract Used by This Plan

The direct, unwrapped Home response uses these exact keys:

```text
driverId, driverName, driverCode, profileImageUrl,
shiftStatus, isAvailable, currentStatusText, nextLocationText,
targetProgress, currentDeliveryTask, todaySummary,
dailyPerformance, activeSession, unreadNotificationsCount
```

Nested contracts:

```text
targetProgress:
  completedCount, targetCount, remainingCount, progressPercentage,
  performanceLevel, summaryText, remainingText

currentDeliveryTask:
  boxId, boxCode, customerName, customerPhone, deliveryAddress,
  destinationLatitude, destinationLongitude, mealsCount, mealsSummary,
  deliveryTimeSlot, status, deliveryNotes

todaySummary:
  totalOrders, deliveredOrders, inDeliveryOrders, incompleteOrders

dailyPerformance:
  onTimeRatePercentage, distanceCoveredKm, averageDeliveryMinutes

activeSession:
  sessionId, startedAtUtc, workDurationText
```

---

### Task 1: Lock the Approved JSON Contract With Failing DTO Tests

**Files:**
- Modify: `test/features/driver/home/data/models/driver_home_response_dto_test.dart`
- Reference: `lib/features/driver/home/data/models/response/driver_home_response_dto.dart`

**Interfaces:**
- Consumes: `DriverHomeResponseDto.fromJson(Map<String, dynamic>)`.
- Produces: executable contract tests for every documented nested JSON key.

- [ ] **Step 1: Replace the invented Active-available fixture with the approved response shape**

Use a fixture containing exactly:

```dart
final json = <String, dynamic>{
  'driverId': 'drv-123',
  'driverName': 'أحمد إبراهيم',
  'driverCode': 'DRV-1256',
  'profileImageUrl': null,
  'shiftStatus': 'Active',
  'isAvailable': true,
  'currentStatusText': 'متصل ومتاح لاستلام الطلبات',
  'nextLocationText': null,
  'targetProgress': {
    'completedCount': 0,
    'targetCount': 8,
    'remainingCount': 8,
    'progressPercentage': 0.0,
    'performanceLevel': 'جيد',
    'summaryText': 'أتممت 0 من إجمالي 8 طلبات',
    'remainingText': 'تبقى 8 طلبات لإتمام الهدف',
  },
  'currentDeliveryTask': null,
  'todaySummary': {
    'totalOrders': 8,
    'deliveredOrders': 0,
    'inDeliveryOrders': 0,
    'incompleteOrders': 0,
  },
  'dailyPerformance': {
    'onTimeRatePercentage': 100.0,
    'distanceCoveredKm': 0.0,
    'averageDeliveryMinutes': 0.0,
  },
  'activeSession': {
    'sessionId': 'session-001',
    'startedAtUtc': '2026-10-03T15:00:00Z',
    'workDurationText': '1 س 0 د',
  },
  'unreadNotificationsCount': 3,
};
```

Assert every nested property using the exact future Dart names from Task 2: `completedCount`, `targetCount`, `remainingCount`, `progressPercentage`, `performanceLevel`, `summaryText`, `remainingText`, `totalOrders`, `deliveredOrders`, `inDeliveryOrders`, `incompleteOrders`, `onTimeRatePercentage`, `distanceCoveredKm`, `averageDeliveryMinutes`, `sessionId`, and `workDurationText`.

- [ ] **Step 2: Keep and strengthen the Inactive response test**

Assert all six operational fields are present as decoded null values and identity remains decoded. Keep `unreadNotificationsCount == 0` as valid Inactive data, not an error.

- [ ] **Step 3: Keep the full busy-task fixture and add numeric coercion coverage**

The busy fixture must assert all task fields. Add one separate test where integer-looking numeric values are supplied for `progressPercentage`, `distanceCoveredKm`, `averageDeliveryMinutes`, latitude, and longitude; decoding must produce `double` without throwing.

Use JSON converters in Task 2 rather than changing the fixture to hide numeric variance.

- [ ] **Step 4: Run the DTO test and verify it fails for the old invented field names**

Run:

```powershell
flutter test test/features/driver/home/data/models/driver_home_response_dto_test.dart
```

Expected: compile failures for missing approved DTO properties or assertion failures because the old DTO ignores approved keys.

- [ ] **Step 5: Commit the red contract tests**

```powershell
git add -- test/features/driver/home/data/models/driver_home_response_dto_test.dart
git commit -m "test: lock driver home API contract"
```

---

### Task 2: Correct the Home DTOs and Generated Serialization

**Files:**
- Modify: `lib/features/driver/home/data/models/response/driver_home_response_dto.dart`
- Regenerate: `lib/features/driver/home/data/models/response/driver_home_response_dto.g.dart`
- Modify only if no equivalent exists: `lib/core/network/json_converters.dart`
- Test: `test/features/driver/home/data/models/driver_home_response_dto_test.dart`

**Interfaces:**
- Consumes: exact JSON keys in the Backend Contract section.
- Produces: nullable `DriverHomeResponseDto` and nested DTO properties with exact contract names.

- [ ] **Step 1: Search for an existing nullable numeric converter**

Run:

```powershell
rg -n "fromJson.*num|num.*toDouble|Nullable.*Double|double.tryParse" lib/core lib/features -g "*.dart"
```

Reuse an existing converter if present. If none exists, add a focused top-level converter in the DTO file:

```dart
double? _nullableDoubleFromJson(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}
```

- [ ] **Step 2: Replace invented nested DTO fields with exact contract fields**

The target-progress DTO must be:

```dart
@JsonSerializable()
class DriverHomeTargetProgressResponseDto {
  const DriverHomeTargetProgressResponseDto({
    this.completedCount,
    this.targetCount,
    this.remainingCount,
    this.progressPercentage,
    this.performanceLevel,
    this.summaryText,
    this.remainingText,
  });

  final int? completedCount;
  final int? targetCount;
  final int? remainingCount;
  @JsonKey(fromJson: _nullableDoubleFromJson)
  final double? progressPercentage;
  final String? performanceLevel;
  final String? summaryText;
  final String? remainingText;
}
```

Define summary, performance, and session DTOs with these properties only:

```dart
class DriverHomeTodaySummaryResponseDto {
  final int? totalOrders;
  final int? deliveredOrders;
  final int? inDeliveryOrders;
  final int? incompleteOrders;
}

class DriverHomeDailyPerformanceResponseDto {
  final double? onTimeRatePercentage;
  final double? distanceCoveredKm;
  final double? averageDeliveryMinutes;
}

class DriverHomeActiveSessionResponseDto {
  final String? sessionId;
  final String? startedAtUtc;
  final String? workDurationText;
}
```

Apply the numeric converter to all documented `double?` fields that may arrive as integers.

- [ ] **Step 3: Keep delivery-task DTO fields exact and nullable**

Do not rename or remove the existing documented task fields. Apply defensive numeric decoding to destination coordinates.

- [ ] **Step 4: Regenerate JSON code**

Run:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Expected: generation succeeds; do not edit the generated file manually.

- [ ] **Step 5: Run DTO tests**

```powershell
flutter test test/features/driver/home/data/models/driver_home_response_dto_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit DTO correction**

```powershell
git add -- lib/features/driver/home/data/models/response/driver_home_response_dto.dart lib/features/driver/home/data/models/response/driver_home_response_dto.g.dart test/features/driver/home/data/models/driver_home_response_dto_test.dart
git commit -m "fix: align driver home DTOs with backend contract"
```

---

### Task 3: Correct Domain Entities and Mapper Semantics

**Files:**
- Modify: `lib/features/driver/home/domain/entities/driver_home_entity.dart`
- Modify: `lib/features/driver/home/data/mapper/driver_home_mapper.dart`
- Modify: `test/features/driver/home/data/mapper/driver_home_mapper_test.dart`
- Modify as compilation requires: Home test fixtures under `test/features/driver/home/`

**Interfaces:**
- Consumes: corrected DTOs from Task 2.
- Produces: contract-accurate `DriverHomeEntity` nested entities for Presentation.

- [ ] **Step 1: Write failing mapper assertions for every approved field**

Construct DTOs with non-zero, distinctive values so accidental cross-wiring is visible:

```dart
const targetDto = DriverHomeTargetProgressResponseDto(
  completedCount: 5,
  targetCount: 8,
  remainingCount: 3,
  progressPercentage: 62.5,
  performanceLevel: 'جيد',
  summaryText: 'أتممت 5 طلبات من الهدف اليومي',
  remainingText: 'تبقى 3 طلبات للوصول للهدف',
);
```

Add similar assertions for summary `(8, 5, 2, 1)`, performance `(92.0, 32.4, 18.0)`, and session values.

- [ ] **Step 2: Run mapper tests and verify they fail**

```powershell
flutter test test/features/driver/home/data/mapper/driver_home_mapper_test.dart
```

Expected: compile or assertion failure against the old invented entity fields.

- [ ] **Step 3: Replace the nested domain entities with contract-accurate immutable types**

Use these exact interfaces:

```dart
class DriverHomeTargetProgressEntity {
  final int completedCount;
  final int targetCount;
  final int remainingCount;
  final double progressPercentage;
  final String performanceLevel;
  final String summaryText;
  final String remainingText;
}

class DriverHomeTodaySummaryEntity {
  final int totalOrders;
  final int deliveredOrders;
  final int inDeliveryOrders;
  final int incompleteOrders;
}

class DriverHomeDailyPerformanceEntity {
  final double onTimeRatePercentage;
  final double distanceCoveredKm;
  final double averageDeliveryMinutes;
}

class DriverHomeActiveSessionEntity {
  final String sessionId;
  final DateTime? startedAtUtc;
  final String workDurationText;
}
```

Retain `DriverShiftStatus.active/inactive`, `isBusy`, and `isAvailableAndIdle`. Keep operational objects nullable at the parent entity.

- [ ] **Step 4: Map fields one-to-one without invented derivation**

Examples:

```dart
completedCount: completedCount ?? 0,
targetCount: targetCount ?? 0,
remainingCount: remainingCount ?? 0,
progressPercentage: progressPercentage ?? 0.0,
```

Parse `startedAtUtc` safely with `DateTime.tryParse(... )?.toUtc()`. Do not use `!`. Do not turn a missing operational object into a zero-filled object; only map when the nested DTO itself exists.

- [ ] **Step 5: Preserve safe shift-status routing**

Keep only normalized `active` as Active. Null, empty, `Inactive`, old `Offline`, or unknown values map to Inactive. Add explicit mapper tests for all these inputs.

- [ ] **Step 6: Update compilation fixtures without weakening assertions**

Update all `DriverHomeTargetProgressEntity`, `DriverHomeTodaySummaryEntity`, `DriverHomeDailyPerformanceEntity`, and `DriverHomeActiveSessionEntity` constructions under `test/features/driver/home/` to the new exact interfaces.

- [ ] **Step 7: Run data/domain tests**

```powershell
flutter test test/features/driver/home/data test/features/driver/home/domain
```

Expected: PASS.

- [ ] **Step 8: Commit entity and mapper correction**

```powershell
git add -- lib/features/driver/home/domain/entities/driver_home_entity.dart lib/features/driver/home/data/mapper/driver_home_mapper.dart test/features/driver/home
git commit -m "fix: map driver home metrics without field substitution"
```

---

### Task 4: Bind Goal, Summary, Performance, and Session UI to Correct Values

**Files:**
- Modify: `lib/features/driver/home/presentation/widgets/active_home/driver_daily_goal_card.dart`
- Modify: `lib/features/driver/home/presentation/widgets/active_home/driver_daily_summary_section.dart`
- Modify: `lib/features/driver/home/presentation/widgets/active_home/driver_daily_performance_section.dart`
- Modify: `lib/features/driver/home/presentation/widgets/active_home/driver_active_home_view.dart`
- Create: `lib/features/driver/home/presentation/widgets/active_home/driver_active_session_card.dart`
- Modify: `lib/core/l10n/app_ar.arb`
- Modify: `lib/core/l10n/app_en.arb`
- Regenerate through project localization command/config: generated localization Dart files
- Test: `test/features/driver/home/presentation/widgets/driver_home_views_test.dart`

**Interfaces:**
- Consumes: Task 3 exact nested entities.
- Produces: accurate visual values without conversion through obsolete presentation entities.

- [ ] **Step 1: Add failing widget tests using distinctive values**

Build an Active entity containing:

```dart
targetProgress: DriverHomeTargetProgressEntity(
  completedCount: 5,
  targetCount: 8,
  remainingCount: 3,
  progressPercentage: 62.5,
  performanceLevel: 'جيد',
  summaryText: 'أتممت 5 طلبات من الهدف اليومي',
  remainingText: 'تبقى 3 طلبات للوصول للهدف',
),
todaySummary: DriverHomeTodaySummaryEntity(
  totalOrders: 8,
  deliveredOrders: 5,
  inDeliveryOrders: 2,
  incompleteOrders: 1,
),
dailyPerformance: DriverHomeDailyPerformanceEntity(
  onTimeRatePercentage: 92,
  distanceCoveredKm: 32.4,
  averageDeliveryMinutes: 18,
),
activeSession: DriverHomeActiveSessionEntity(
  sessionId: 'session-1',
  startedAtUtc: DateTime.utc(2026, 10, 5, 6),
  workDurationText: '3 س 20 د',
),
```

Assert the UI shows `5`, `8`, `3`, `62.5` semantics, `92%`, `32.4`, `18`, and `3 س 20 د` in their correct sections. Assert it does not show `92%` as average delivery time or `5.0` as on-time rate.

- [ ] **Step 2: Run widget test and verify incorrect mapping fails**

```powershell
flutter test test/features/driver/home/presentation/widgets/driver_home_views_test.dart
```

Expected: compile or assertion failure from old UI adapters.

- [ ] **Step 3: Make existing widgets consume the corrected Home entities directly**

Remove these incorrect derivations from `DriverActiveHomeView`:

```dart
completedTripsCount - totalDeliveredBoxesCount
onTimeDeliveryRate -> averageDeliveryTime
deliveredOrdersCount -> distanceCovered
customerRating -> onTimeRate
```

Pass the corrected target, summary, and performance entities directly. If legacy `driver_daily_summary_entity.dart` and `driver_daily_performance_entity.dart` become unused after this step, delete them only after `rg` confirms no consumers.

- [ ] **Step 4: Render target progress from backend text and counts**

`DriverDailyGoalCard` must use:

- `completedCount / targetCount` for the count;
- `progressPercentage` clamped to `0..100` for progress;
- `performanceLevel` for the badge;
- `summaryText` and `remainingText` for copy;
- `targetCount` for segment count, with a reasonable existing-layout guard if the backend returns zero.

- [ ] **Step 5: Render summary and performance with correct localization**

Summary labels map exactly:

```text
totalOrders -> Total Orders
deliveredOrders -> Delivered
inDeliveryOrders -> In Delivery
incompleteOrders -> Incomplete
```

Performance labels map exactly:

```text
onTimeRatePercentage -> On-Time Rate (% formatting)
distanceCoveredKm -> Distance Covered (km formatting)
averageDeliveryMinutes -> Average Delivery Time (minutes formatting)
```

Format values in Presentation only; preserve numeric types in Domain.

- [ ] **Step 6: Add the active-session card**

Create a small read-only card consistent with existing Home styling. It displays localized “Work duration” and the server-provided `workDurationText`. Show a localized start-time label only when `startedAtUtc != null`; format it using an existing date/time helper if one exists, otherwise show only `workDurationText` to avoid introducing a new formatting subsystem.

Never add an End Work control.

- [ ] **Step 7: Add Arabic and English localization keys**

Add only missing keys for work duration/start time and any new empty-active copy. Reuse existing Home summary/performance keys where their semantics match. Regenerate localization through the project’s configured Flutter generation command; do not edit generated localization Dart manually.

- [ ] **Step 8: Run widget tests in both locales**

```powershell
flutter test test/features/driver/home/presentation/widgets/driver_home_views_test.dart
```

Expected: PASS for Arabic fixtures; add one English smoke test for metric labels and session label.

- [ ] **Step 9: Commit correct Home metrics UI**

```powershell
git add -- lib/features/driver/home/presentation/widgets/active_home lib/core/l10n/app_ar.arb lib/core/l10n/app_en.arb test/features/driver/home/presentation/widgets/driver_home_views_test.dart
git commit -m "fix: render driver home metrics from approved fields"
```

---

### Task 5: Complete Active Available and Active Busy Behavior

**Files:**
- Modify: `lib/features/driver/home/presentation/widgets/active_home/driver_active_home_view.dart`
- Modify: `lib/features/driver/home/presentation/widgets/active_home/driver_current_order_card.dart`
- Modify: `lib/features/driver/home/presentation/widgets/active_home/driver_home_map_card.dart`
- Create: `lib/features/driver/home/presentation/widgets/active_home/driver_available_waiting_card.dart`
- Modify: `lib/features/driver/home/presentation/screens/driver_home_screen.dart`
- Modify as needed: `lib/config/routing/arguments/*` only if an existing target route requires typed arguments
- Test: `test/features/driver/home/presentation/widgets/driver_home_views_test.dart`
- Test: `test/features/driver/home/presentation/screens/driver_home_screen_test.dart`

**Interfaces:**
- Consumes: `DriverHomeEntity.isAvailableAndIdle`, `isBusy`, and nullable current task.
- Produces: deliberate idle/busy layouts and working default actions.

- [ ] **Step 1: Add failing tests for the two Active modes**

For Active available with no task, assert:

- current status, target, summary, performance, and session remain visible when provided;
- current-order card is absent;
- delivery-route map preview and task-specific issue banner are absent;
- a localized available/awaiting-assignment message is visible.

For Active busy with a task, assert:

- map preview, order card, and issue banner are visible;
- order card shows `mealsSummary` when non-empty rather than rebuilding a conflicting label;
- order code, customer, address, and time slot are visible.

- [ ] **Step 2: Run focused tests and verify they fail**

```powershell
flutter test test/features/driver/home/presentation/widgets/driver_home_views_test.dart
```

- [ ] **Step 3: Split the Active layout conditionally without a new state machine**

Use the entity helpers:

```dart
if (home.isAvailableAndIdle) ...[
  DriverAvailableWaitingCard(statusText: home.currentStatusText),
] else if (task != null) ...[
  DriverHomeMapCard(...),
  DriverCurrentOrderCard(...),
  DriverIssuesHelpBanner(...),
]
```

Create `DriverAvailableWaitingCard` in its own file under `widgets/active_home/`. It accepts the resolved status text, uses localization/theme/spacing, and remains read-only.

- [ ] **Step 4: Pass the complete task entity to the order card**

Stop converting the backend task to the obsolete `DriverCurrentOrderEntity`. Change the card interface to:

```dart
final DriverHomeCurrentDeliveryTaskEntity task;
```

Render the contract values. Phone, status, notes, and coordinates need not all appear on the compact card, but they must remain available to details/navigation and must not be discarded by an intermediate entity.

- [ ] **Step 5: Give Home actions safe default navigation**

Preserve injectable test callbacks, but when callbacks are null:

- map/recenter action opens the existing driver map route;
- issue action opens the existing driver report-issue route only when a current task exists;
- order-details action navigates to the existing task/delivery detail flow only if its required route arguments can be constructed from the current contract entity.

Before coding the last action, inspect the target route argument type. If the route requires fields the Home contract does not provide, do not invent them; route to the existing assigned-boxes or map surface that can refetch authoritative details, and document that choice in the commit.

- [ ] **Step 6: Keep the Home map honest**

Do not label the existing asset preview as a fully interactive live map. Wire its tap/recenter affordance to the existing driver map feature. Embedding a new live-map engine or new backend route endpoint is outside this plan.

- [ ] **Step 7: Run Home widget and screen tests**

```powershell
flutter test test/features/driver/home/presentation/widgets/driver_home_views_test.dart test/features/driver/home/presentation/screens/driver_home_screen_test.dart
```

Expected: PASS.

- [ ] **Step 8: Commit Active-mode completion**

```powershell
git add -- lib/features/driver/home/presentation test/features/driver/home/presentation
git commit -m "feat: complete available and busy driver home states"
```

---

### Task 6: Preserve Loading, Core Errors, Refresh, and Realtime Semantics

**Files:**
- Modify only if a test exposes a defect: `lib/features/driver/home/presentation/manager/driver_home_view_model.dart`
- Modify only if a test exposes a defect: `lib/features/driver/home/presentation/screens/driver_home_screen.dart`
- Modify: `test/features/driver/home/presentation/manager/driver_home_view_model_test.dart`
- Modify: `test/features/driver/home/presentation/screens/driver_home_screen_test.dart`
- Modify: `test/features/driver/home/driver_home_acceptance_test.dart`
- Reference: `lib/core/errors/error_widgets/api_error_widget.dart`
- Reference: `lib/core/errors/error_widgets/inline_api_error_widget.dart`
- Reference: `lib/features/driver/home/presentation/widgets/driver_home_shimmer.dart`

**Interfaces:**
- Consumes: existing events and ViewModel fetch coalescing.
- Produces: regression protection for required error/loading/reload behavior.

- [ ] **Step 1: Add or verify initial-loading tests**

Assert `isLoading == true && home == null` renders exactly one `DriverHomeShimmer` and no content/error widget.

- [ ] **Step 2: Add or verify Core error tests**

Assert:

```text
failure + home == null -> ApiErrorWidget
failure + home != null -> InlineApiErrorWidget + retained Home view
```

Tap Retry and assert only `DriverHomeRetryRequested` is dispatched. Do not add feature-level timeout/offline/403 switching.

- [ ] **Step 3: Add ViewModel tests for contract-critical reload triggers**

Use a queued fake repository/use case and assert:

- `DriverHomeStatusUpdatedReceived` refetches Home and ignores event payload values;
- false-to-true connection transition refetches once;
- lifecycle resume refetches;
- a refresh failure retains the previous `home` entity;
- two triggers during one in-flight request produce at most one follow-up request;
- closing the ViewModel cancels subscriptions without disposing the shared SignalR client.

- [ ] **Step 4: Verify inactive SignalR behavior**

In the acceptance test, start from Inactive, emit `DriverStatusUpdatedEvent`, make the next Home response Active, and assert the state becomes Active. This proves the listener remains useful while the driver is disconnected operationally.

- [ ] **Step 5: Run focused state and acceptance tests**

```powershell
flutter test test/features/driver/home/presentation/manager/driver_home_view_model_test.dart test/features/driver/home/presentation/screens/driver_home_screen_test.dart test/features/driver/home/driver_home_acceptance_test.dart
```

Expected: PASS. Change production code only for test-proven defects.

- [ ] **Step 6: Commit regression coverage**

```powershell
git add -- lib/features/driver/home/presentation/manager lib/features/driver/home/presentation/screens test/features/driver/home
git commit -m "test: protect driver home loading errors and reloads"
```

---

### Task 7: Remove Obsolete Types and Self-Shift Remnants

**Files:**
- Delete only when unreferenced: `lib/features/driver/home/domain/entities/driver_current_order_entity.dart`
- Delete only when unreferenced: `lib/features/driver/home/domain/entities/driver_daily_summary_entity.dart`
- Delete only when unreferenced: `lib/features/driver/home/domain/entities/driver_daily_performance_entity.dart`
- Modify as found by search: driver Home tests/imports
- Do not remove: display-only routes unrelated to self-shift management

**Interfaces:**
- Consumes: Task 4/5 migration away from legacy adapter entities.
- Produces: one authoritative Home entity graph and no self-shift calls.

- [ ] **Step 1: Search before deletion**

```powershell
rg -n "DriverCurrentOrderEntity|DriverDailySummaryEntity|DriverDailyPerformanceEntity|startShift|StartDriverShift|shift/start|shift/end|driverStartWork|End Work|إنهاء العمل|بدء العمل|shiftStatus\s*==\s*['\"]Offline" lib test -g "*.dart"
```

- [ ] **Step 2: Delete only legacy entity files with zero remaining consumers**

If a type is still used by another feature, keep it and remove only Home’s adapter usage. Do not broaden refactoring outside Home.

- [ ] **Step 3: Keep route compatibility intentionally**

`AppRoutes.driverStartWork` may remain as a legacy alias resolving to `DriverHomeScreen` if deep links or tests use it. It must not resolve to a self-shift screen or expose a Start Work action.

- [ ] **Step 4: Verify no forbidden driver self-shift code remains**

Run the search again. Expected:

- no driver invocation of start/end shift;
- no Start/End Work button;
- no raw `Offline` routing condition;
- only legitimate localization/history/docs references may remain.

- [ ] **Step 5: Run the full Home suite**

```powershell
flutter test test/features/driver/home
```

Expected: PASS.

- [ ] **Step 6: Commit cleanup**

```powershell
git add -A -- lib/features/driver/home test/features/driver/home
git commit -m "refactor: remove obsolete driver home adapters"
```

---

### Task 8: Generate, Analyze, and Verify the Complete Feature

**Files:**
- Generated by tools: JSON/Retrofit/Injectable/localization outputs affected by prior tasks
- No manual product changes unless verification reveals an implementation-caused defect

**Interfaces:**
- Consumes: Tasks 1–7.
- Produces: verified, handoff-ready Driver Home implementation.

- [ ] **Step 1: Confirm the worktree and inspect task-owned diff**

```powershell
git status --short
git diff --check
git diff --stat
```

Do not stage or revert unrelated user files.

- [ ] **Step 2: Regenerate all required code**

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Run the project’s configured localization generation if ARB changes are not generated automatically by the build.

- [ ] **Step 3: Format only changed Dart files**

Use `dart format` on the exact changed Dart paths. Do not bulk-format unrelated project files.

- [ ] **Step 4: Run the focused Home suite**

```powershell
flutter test test/features/driver/home
```

Expected: all Home tests PASS.

- [ ] **Step 5: Run realtime regression tests**

```powershell
flutter test test/features/driver/tracking/driver_live_location_test.dart
```

Expected: PASS, confirming shared DriverHub parsing/connection behavior was not broken.

- [ ] **Step 6: Run the full test suite**

```powershell
flutter test
```

Expected: PASS. If unrelated pre-existing failures exist, record their exact test names and prove focused Home/realtime tests still pass; do not hide or silently ignore them.

- [ ] **Step 7: Run static analysis**

```powershell
flutter analyze
```

Expected: no new errors or warnings caused by this implementation.

- [ ] **Step 8: Perform final forbidden-code and contract searches**

```powershell
rg -n "targetPercentage|targetText|completedBoxes|totalBoxes|completedTripsCount|collectedCashAmount|onTimeDeliveryRate|customerRating|acceptanceRate|shiftId|durationMinutes" lib/features/driver/home test/features/driver/home -g "*.dart"
rg -n "shift/start|shift/end|startShift|StartDriverShift|إنهاء العمل|بدء العمل" lib/features/driver/home test/features/driver/home -g "*.dart"
```

Expected: no obsolete contract fields and no self-shift flow remain.

- [ ] **Step 9: Execute the six acceptance scenarios against integration**

1. Inactive login renders disconnected Home, no notification badge, and no shift action.
2. Dispatcher activation event causes a Home refetch and Active rendering.
3. Missed event is recovered after reconnect or app resume.
4. Active available renders no current-task card and no task-specific issue action.
5. Active busy with `isAvailable == false` stays Active and renders the current task.
6. Dispatcher deactivation after task completion returns to Inactive while realtime remains connected.

- [ ] **Step 10: Commit verification-only generated updates, if any**

```powershell
git add -- lib/features/driver/home/data/models/response/driver_home_response_dto.g.dart lib/core/l10n/translations/app_localizations.dart lib/core/l10n/translations/app_localizations_ar.dart lib/core/l10n/translations/app_localizations_en.dart
git commit -m "chore: regenerate driver home integration code"
```

Skip this commit if generation produced no uncommitted changes.

## Completion Report Required From Gemini

Gemini must finish with:

- commits created, in order;
- exact production files created/modified/deleted;
- exact tests and analyzer commands run with outcomes;
- confirmation that Core `ApiErrorWidget` and `InlineApiErrorWidget` remain in use;
- confirmation that initial loading uses `DriverHomeShimmer`;
- confirmation that `shiftStatus` alone chooses Active/Inactive;
- confirmation that no Start/End Shift driver flow remains;
- confirmation that no obsolete invented Home contract field remains;
- any integration-environment scenario that could not be executed and the external reason.
