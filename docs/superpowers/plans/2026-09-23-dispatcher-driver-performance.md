# Dispatcher Driver Performance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the fake-data driver-performance screen with complete backend integration for overview, period filtering, local table sorting, and driver comparison while preserving the current UI and navigation behavior.

**Architecture:** Extend `dispatcher_driver_performance` through the required UI → Event → ViewModel → UseCase → Repository → RemoteDataSource → `ApiServices` flow, with nullable DTOs mapped into domain-safe entities. One immutable ViewModel state owns the selected tab/period and independent overview/comparison data, loading, and failures so switching tabs never destroys usable data. Initial and data-changing loads use screen-shaped shimmer; core error widgets handle failures.

**Tech Stack:** Flutter, Dart, `flutter_bloc`, Dio, Retrofit, `json_serializable`, GetIt/Injectable conventions, existing `ApiResult`/`safeApiCall`, `lib/core/errors`, and `lib/core/widget/shimmer_widget.dart`.

**Spec:** `D:/yahya/meal meat/dis_new/screen-04.09-driver-performance_____________________.md`

## Global Constraints

- Follow `rules/rules_backend.md` exactly and do not bypass any Clean Architecture layer.
- Scope is only `dispatcher_driver_performance` plus the minimum shared API/DI/routing/localization changes it requires; do not modify dispatcher support.
- Preserve the current UI composition, colors, spacing, theme, RTL/LTR behavior, and widget names unless a backend field requires a focused signature change.
- Response DTO fields, including nested fields and lists, are nullable and defensive; never use force unwrap for API data.
- UI imports domain entities/state only; DTOs never enter domain or presentation.
- Reuse the existing `ApiServices`, Dio interceptors, `safeApiCall`, `ApiResult`, `Failure`, GetIt, and core error widgets.
- Initial load with no usable data uses `DriverPerformanceShimmer`; never use a centered progress indicator.
- Failure with no usable active-tab data uses `ApiErrorWidget.fromTypedFailure`; refresh/tab failures with existing data use `InlineApiErrorWidget`; successful empty results use `EmptyStateWidget`.
- Keep old content visible during a failed refresh and retry only the operation that failed.
- Do not add a package or a second API client/state-management system.
- Do not manually edit generated `*.g.dart`; run build_runner.
- Preserve user changes in the dirty worktree, especially the unrelated dispatcher-map files.

## Locked Product Decisions

- Mobile sends `fromDate` and `toDate` as `yyyy-MM-dd`; both are required only when `period=Custom`.
- Mobile does not send `restaurantId`; the backend resolves and authorizes the restaurant from JWT.
- The comparison request omits `driverIds` by default, so the server returns all active drivers. Do not invent a driver-selector UI until a separate design is supplied.
- `driversTable` sorting is client-side because the documented overview endpoint has no `sortBy`/`sortDirection` parameters.
- The screen has no pagination because neither endpoint documents pagination. Do not invent page parameters.
- Domain logic uses stable enum keys (`status`, `avgDelayLevel`, distribution `key`); backend colors/text are display hints with safe theme fallbacks.
- A period change clears data from the previous period and shows content-shaped shimmer for the active tab, preventing stale-period values from being labeled as the new period.
- Initial screen load requests Overview only. Comparison loads lazily on first tab activation and is cached for the selected period.
- Returning from driver details does not refetch performance automatically; pull-to-refresh or period selection performs explicit reload.

## Backend Sign-off Items

These do not block coding against the sample contract, but must be confirmed before production sign-off:

1. `Custom` requires both dates, rejects `fromDate > toDate`, and documents the maximum allowed range.
2. Repeated query is the mobile canonical format if custom `driverIds` selection is introduced later.
3. Backend documents all error codes using `{code, message, errors}` and `Accept-Language: ar|en`.
4. Backend confirms full-list behavior and practical maximum size for `driversTable` and comparison `drivers`.
5. Backend enforces JWT restaurant ownership even if an external client supplies `restaurantId`.
6. Backend documents nullability for `avatarUrl`, dates, rating, and distance, and returns percentages as finite values in `0..100`.

---

### Task 1: Define the Performance Domain Model and Query Contract

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_distribution_category.dart`
- Modify: `lib/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_distribution_item_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_kpi_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_record_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_podium_entry_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_period.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_query_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_delay_level.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_driver_status.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_kpis_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_distribution_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_sort_field.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_overview_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_comparison_entity.dart`
- Test: `test/features/dispatcher/dispatcher_driver_performance/domain/driver_performance_entities_test.dart`

**Interfaces:**
- Produces: `DriverPerformanceQueryEntity(period, fromDate, toDate, driverIds)` with `toApiQueries`-ready domain values but no Dio/Retrofit dependency.
- Produces: `DriverPerformanceOverviewEntity` containing period metadata, KPI values, distribution, podium, and table rows.
- Produces: `DriverPerformanceComparisonEntity` containing period metadata and comparison-driver metrics.

- [ ] **Step 1: Write failing domain tests**

Cover exact period API values, unknown status/delay/distribution fallbacks, query validation, and immutable local sorting without mutating server data.

```dart
expect(DriverPerformancePeriod.last7Days.apiValue, 'Last7Days');
expect(DriverPerformanceDelayLevelX.fromApi('future'), DriverPerformanceDelayLevel.unknown);
expect(
  const DriverPerformanceQueryEntity(period: DriverPerformancePeriod.custom)
      .isValid,
  isFalse,
);
```

Table rows retain numeric values (`int`/`double`) plus optional server display text; do not store counts as strings. Include `driverId`, `driverCode`, `fullName`, `avatarUrl`, typed status, `statusDotColorKey`, delivered/failed counts and rates, delay minutes/text/level, and rating.

- [ ] **Step 2: Run the focused test and verify failure**

Run: `flutter test test/features/dispatcher/dispatcher_driver_performance/domain/driver_performance_entities_test.dart`

Expected: FAIL because the new domain contracts do not exist.

- [ ] **Step 3: Implement domain contracts**

Use these aggregate signatures:

```dart
class DriverPerformanceOverviewEntity {
  final DriverPerformancePeriod period;
  final String periodText;
  final String dateRangeText;
  final DateTime? fromDate;
  final DateTime? toDate;
  final DriverPerformanceKpisEntity kpis;
  final DriverPerformanceDistributionEntity distribution;
  final List<DriverPodiumEntryEntity> topDrivers;
  final List<DriverPerformanceRecordEntity> driversTable;
}

class DriverPerformanceComparisonEntity {
  final DriverPerformancePeriod period;
  final String periodText;
  final String dateRangeText;
  final DateTime? fromDate;
  final DateTime? toDate;
  final List<DriverComparisonRecordEntity> drivers;
}
```

Add `unknown` enum members and safe `fromApi` extensions. For distribution, map `Delayed` to the existing UI's late category without renaming the current visual semantics. Define `DriverComparisonRecordEntity` in `driver_performance_comparison_entity.dart`, because it is owned only by that aggregate; define `DriverPerformanceKpisEntity`, `DriverPerformanceDistributionEntity`, and `DriverPerformanceSortField` in the explicit files listed above.

- [ ] **Step 4: Run domain tests**

Run: `flutter test test/features/dispatcher/dispatcher_driver_performance/domain/driver_performance_entities_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit domain contracts**

```bash
git add lib/features/dispatcher/dispatcher_driver_performance/domain/entities test/features/dispatcher/dispatcher_driver_performance/domain/driver_performance_entities_test.dart
git commit -m "feat: define driver performance domain contracts"
```

### Task 2: Create Defensive Response DTOs and Mappers

**Files:**
- Create: `lib/features/dispatcher/dispatcher_driver_performance/data/models/response/driver_performance_overview_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/data/models/response/driver_performance_comparison_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/data/mapper/driver_performance_mapper.dart`
- Generated: matching `*.g.dart` files
- Test: `test/features/dispatcher/dispatcher_driver_performance/data/driver_performance_dto_mapper_test.dart`

**Interfaces:**
- Consumes: Task 1 entities.
- Produces: `DriverPerformanceOverviewResponseDto.toEntity()` and `DriverPerformanceComparisonResponseDto.toEntity()`.

- [ ] **Step 1: Write failing JSON/mapping tests**

Test the complete documented overview/comparison payloads plus missing nested objects, null lists, unknown enum strings, invalid dates, null avatar, null ratings/distances, and empty-data `200` payloads.

```dart
final entity = DriverPerformanceOverviewResponseDto.fromJson(json).toEntity();
expect(entity.kpis.totalBoxes, 128);
expect(entity.distribution.segments.first.category,
    DriverPerformanceDistributionCategory.onTime);
expect(entity.driversTable.first.delayLevel,
    DriverPerformanceDelayLevel.good);
```

- [ ] **Step 2: Run the focused test and verify failure**

Run: `flutter test test/features/dispatcher/dispatcher_driver_performance/data/driver_performance_dto_mapper_test.dart`

Expected: FAIL because DTOs and mappers are missing.

- [ ] **Step 3: Implement nullable DTO trees**

Use `@JsonSerializable()` and nullable fields for all response properties. Keep nested DTOs in the response file that owns them unless reused by both responses; shared driver identity mapping may live in the mapper without creating a generic abstraction.

Mapper rules:

- null list → empty immutable list;
- malformed date → null;
- null numeric metric → zero only where zero is a valid empty-state value;
- null rating/distance remains nullable when absence is meaningful;
- unknown colors use theme-level fallback later, not hardcoded parsing here;
- no force unwrap.

- [ ] **Step 4: Generate serializers**

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: generated DTO serializers compile without conflicts.

- [ ] **Step 5: Run mapper tests and focused analysis**

Run: `flutter test test/features/dispatcher/dispatcher_driver_performance/data/driver_performance_dto_mapper_test.dart`

Run: `flutter analyze lib/features/dispatcher/dispatcher_driver_performance/data lib/features/dispatcher/dispatcher_driver_performance/domain`

Expected: PASS with no analyzer findings introduced by these files.

- [ ] **Step 6: Commit DTOs and mapping**

```bash
git add lib/features/dispatcher/dispatcher_driver_performance/data test/features/dispatcher/dispatcher_driver_performance/data/driver_performance_dto_mapper_test.dart
git commit -m "feat: map driver performance API responses"
```

### Task 3: Add Retrofit Endpoints, Data Source, Repository, and Use Cases

**Files:**
- Modify: `lib/core/network/network_constants.dart`
- Modify: `lib/core/network/api_services.dart`
- Generated: `lib/core/network/api_services.g.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/data/data_source/driver_performance_remote_data_source.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/data/data_source/driver_performance_remote_data_source_impl.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/domain/repo/driver_performance_repository.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/data/repo/driver_performance_repository_impl.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/domain/usecase/get_driver_performance_overview_usecase.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/domain/usecase/get_driver_performance_comparison_usecase.dart`
- Test: `test/core/network/api_services_test.dart`
- Test: `test/features/dispatcher/dispatcher_driver_performance/data/driver_performance_repository_test.dart`
- Test: `test/features/dispatcher/dispatcher_driver_performance/domain/driver_performance_usecases_test.dart`

**Interfaces:**
- Produces: `Future<ApiResult<DriverPerformanceOverviewEntity>> getOverview(DriverPerformanceQueryEntity query)`.
- Produces: `Future<ApiResult<DriverPerformanceComparisonEntity>> getComparison(DriverPerformanceQueryEntity query)`.

- [ ] **Step 1: Write failing endpoint/repository/use-case tests**

Assert exact paths and query keys. The API interface should expose:

```dart
@GET(EndPoints.dispatcherPerformanceOverview)
Future<DriverPerformanceOverviewResponseDto> getDriverPerformanceOverview({
  @Query('period') String? period,
  @Query('fromDate') String? fromDate,
  @Query('toDate') String? toDate,
});

@GET(EndPoints.dispatcherPerformanceComparison)
Future<DriverPerformanceComparisonResponseDto> getDriverPerformanceComparison({
  @Query('period') String? period,
  @Query('driverIds') List<String>? driverIds,
  @Query('fromDate') String? fromDate,
  @Query('toDate') String? toDate,
});
```

Do not add `restaurantId` because JWT provides it. Verify that non-custom periods omit dates and custom dates serialize as `yyyy-MM-dd`. Verify `safeApiCall` maps Dio failures into typed `Failure` including backend error code.

- [ ] **Step 2: Run focused tests and verify failure**

Run: `flutter test test/core/network/api_services_test.dart test/features/dispatcher/dispatcher_driver_performance/data/driver_performance_repository_test.dart test/features/dispatcher/dispatcher_driver_performance/domain/driver_performance_usecases_test.dart`

Expected: FAIL because endpoints and layers are absent.

- [ ] **Step 3: Implement endpoints and complete data flow**

Add constants:

```dart
static const dispatcherPerformanceOverview =
    '/api/v1/dispatcher/performance/overview';
static const dispatcherPerformanceComparison =
    '/api/v1/dispatcher/performance/comparison';
```

Remote data source only translates query values and calls `ApiServices`. Repository implementations wrap calls in `safeApiCall` and map DTO → entity. Use cases validate custom dates before invoking the repository; invalid local queries return `ApiErrorResult(failure: Failure.fromException(ApiException(errorType: ApiErrorType.validationError, message: 'Invalid custom date range')))`, using the existing core error types rather than throwing into UI.

- [ ] **Step 4: Regenerate Retrofit**

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: generated methods encode `driverIds` as repeated queries according to Retrofit/Dio output verified by `api_services_test.dart`.

- [ ] **Step 5: Run data-flow tests**

Run: `flutter test test/core/network/api_services_test.dart test/features/dispatcher/dispatcher_driver_performance/data/driver_performance_repository_test.dart test/features/dispatcher/dispatcher_driver_performance/domain/driver_performance_usecases_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit backend pipeline**

```bash
git add lib/core/network lib/features/dispatcher/dispatcher_driver_performance/data lib/features/dispatcher/dispatcher_driver_performance/domain/repo lib/features/dispatcher/dispatcher_driver_performance/domain/usecase test/core/network/api_services_test.dart test/features/dispatcher/dispatcher_driver_performance/data test/features/dispatcher/dispatcher_driver_performance/domain/driver_performance_usecases_test.dart
git commit -m "feat: integrate driver performance endpoints"
```

### Task 4: Implement ViewModel, Events, and Independent Tab State

**Files:**
- Create: `lib/features/dispatcher/dispatcher_driver_performance/presentation/manager/driver_performance_event.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/presentation/manager/driver_performance_state.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/presentation/manager/driver_performance_view_model.dart`
- Test: `test/features/dispatcher/dispatcher_driver_performance/presentation/manager/driver_performance_view_model_test.dart`

**Interfaces:**
- Consumes: both use cases from Task 3.
- Produces: one immutable state with period/tab selection, overview/comparison caches, local sort, and operation-specific failures.

- [ ] **Step 1: Write failing ViewModel tests**

Cover:

- initial Overview request only;
- lazy Comparison load on first comparison-tab selection;
- cached tab switch with no duplicate request;
- period change clearing old-period data and loading the active tab;
- custom date validation and request;
- retrying only the active failed request;
- pull-to-refresh retaining data until success;
- refresh failure preserving content and exposing inline failure;
- stale request generation ignored after rapid period changes;
- local sort ascending/descending for delivered, delay, failures, and rating;
- successful empty overview/comparison distinguished from failure.

```dart
expect(state.selectedPeriod, DriverPerformancePeriod.last7Days);
expect(state.isOverviewInitialLoading, isTrue);
expect(state.comparison, isNull);
expect(state.overviewFailure, isNull);
```

- [ ] **Step 2: Run the focused test and verify failure**

Run: `flutter test test/features/dispatcher/dispatcher_driver_performance/presentation/manager/driver_performance_view_model_test.dart`

Expected: FAIL because the manager layer is absent.

- [ ] **Step 3: Implement events and immutable state**

Events:

```dart
LoadDriverPerformanceOverviewEvent
SelectDriverPerformanceTabEvent(tab)
SelectDriverPerformancePeriodEvent(period)
SelectDriverPerformanceCustomRangeEvent(fromDate, toDate)
RefreshDriverPerformanceEvent
RetryDriverPerformanceEvent
SortDriverPerformanceTableEvent(field)
```

State fields must include:

```dart
final DriverPerformanceTabType selectedTab;
final DriverPerformanceQueryEntity query;
final DriverPerformanceOverviewEntity? overview;
final DriverPerformanceComparisonEntity? comparison;
final bool isOverviewInitialLoading;
final bool isComparisonInitialLoading;
final bool isRefreshing;
final Failure? overviewFailure;
final Failure? comparisonFailure;
final Failure? refreshFailure;
final DriverPerformanceSortField sortField;
final bool sortAscending;
final bool hasLoadedOverview;
final bool hasLoadedComparison;
```

Use a request-generation integer per endpoint so an older Overview response cannot overwrite a newer period and an older Comparison response cannot overwrite its newer period.

- [ ] **Step 4: Run ViewModel tests**

Run: `flutter test test/features/dispatcher/dispatcher_driver_performance/presentation/manager/driver_performance_view_model_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit state management**

```bash
git add lib/features/dispatcher/dispatcher_driver_performance/presentation/manager test/features/dispatcher/dispatcher_driver_performance/presentation/manager/driver_performance_view_model_test.dart
git commit -m "feat: manage driver performance screen state"
```

### Task 5: Build Period Selection and Screen-Shaped Shimmer

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_date_filter_chip.dart`
- Modify: `lib/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_header.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_period_sheet.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_overview_shimmer.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_comparison_shimmer.dart`
- Modify: `lib/core/l10n/app_ar.arb`
- Modify: `lib/core/l10n/app_en.arb`
- Generated: `lib/core/l10n/translations/*`
- Test: `test/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_period_and_shimmer_test.dart`

**Interfaces:**
- Consumes: selected period/date range and callbacks that dispatch Task 4 events.
- Produces: preset/custom selection without making network calls from widgets.

- [ ] **Step 1: Write failing widget tests**

Test dynamic chip label, all six period choices, custom date-range confirmation/cancellation, no event for cancelled picker, RTL/LTR rendering, and shimmer structure for five KPIs, table rows, donut/legend, podium, and comparison cards.

- [ ] **Step 2: Run the focused test and verify failure**

Run: `flutter test test/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_period_and_shimmer_test.dart`

Expected: FAIL because period sheet/shimmers are missing and chip text is static.

- [ ] **Step 3: Implement period sheet and dynamic header**

Use the existing bottom-sheet conventions. Selecting `Custom` opens `showDateRangePicker`; convert the local selected calendar dates to `yyyy-MM-dd` at the remote-data-source boundary. Do not send time components. The chip displays backend `periodText` after success and localized enum label while loading.

- [ ] **Step 4: Implement shimmers using the shared widget**

Build both files exclusively from `ShimmerWidget` plus layout containers. Overview shimmer mirrors the segmented tab content: five KPI blocks, performance-table header/rows, distribution card, and podium. Comparison shimmer mirrors horizontally scrollable driver comparison columns and metric rows.

- [ ] **Step 5: Generate localization and run tests**

Run the configured localization generation command (`flutter gen-l10n` if no wrapper exists).

Run: `flutter test test/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_period_and_shimmer_test.dart`

Expected: PASS with no overflow.

- [ ] **Step 6: Commit filtering and shimmer UI**

```bash
git add lib/features/dispatcher/dispatcher_driver_performance/presentation/widgets lib/core/l10n test/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_period_and_shimmer_test.dart
git commit -m "feat: add performance period filter and shimmer states"
```

### Task 6: Connect Overview UI, Sorting, Empty/Error States, and Driver Navigation Boundary

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_driver_performance/presentation/screens/dispatcher_driver_performance_screen.dart`
- Modify: `lib/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_kpi_list.dart`
- Modify: `lib/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_table_card.dart`
- Modify: `lib/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_table_header.dart`
- Modify: `lib/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_driver_row.dart`
- Modify: `lib/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_distribution_card.dart`
- Modify: `lib/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_legend_row.dart`
- Modify: `lib/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_top_rated_card.dart`
- Modify: `lib/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_podium_column.dart`
- Test: `test/features/dispatcher/dispatcher_driver_performance/presentation/driver_performance_overview_backend_test.dart`

**Interfaces:**
- Consumes: `DriverPerformanceViewModel`, with an optional injected instance and optional `ValueChanged<String> onOpenDriverDetails` for tests/integration boundary.
- Produces: live Overview rendering and emits only `driverId` when a table row is tapped.

- [ ] **Step 1: Write failing Overview screen tests**

Assert:

- initial load dispatches once and renders `DriverPerformanceOverviewShimmer`;
- initial failure renders `ApiErrorWidget.fromTypedFailure` with correct retry;
- successful empty data renders `EmptyStateWidget`;
- all five KPI values and server display texts render from the entity;
- distribution and podium tolerate empty/partial lists;
- avatar null/error uses existing cached-image fallback;
- tapping sortable columns dispatches the exact sort field and toggles direction;
- tapping a driver row invokes `onOpenDriverDetails(driverId)`;
- refresh failure keeps cards visible and renders `InlineApiErrorWidget`;
- pull-to-refresh dispatches only refresh.

- [ ] **Step 2: Run the focused test and verify failure**

Run: `flutter test test/features/dispatcher/dispatcher_driver_performance/presentation/driver_performance_overview_backend_test.dart`

Expected: FAIL because the screen still imports fake data.

- [ ] **Step 3: Connect ViewModel ownership and global state rendering**

Resolve the ViewModel from GetIt unless injected, load once in `initState`, and close only an internally created instance. Render active-tab state according to the global error rules. Wrap content in `RefreshIndicator` with `AlwaysScrollableScrollPhysics`.

- [ ] **Step 4: Adapt existing Overview widgets without redesign**

Move formatting decisions to widgets/localization, keeping numeric domain values. Use typed status/delay/distribution keys for theme colors, with backend color strings only as optional hints. Make column headers interactive and show a small sort-direction indicator without changing table layout.

- [ ] **Step 5: Implement the driver-details boundary safely**

The performance feature outputs `driverId` only. Default navigation may call `AppRoutes.dispatcherDriverDetails` only after that route accepts a typed `driverId` argument. If 04.07 still expects `DriverDetailsEntity`, keep the callback injectable and record the route integration as an external dependency; do not pass a fake entity or silently open the default fake driver.

- [ ] **Step 6: Run Overview tests**

Run: `flutter test test/features/dispatcher/dispatcher_driver_performance/presentation/driver_performance_overview_backend_test.dart`

Expected: PASS in Arabic RTL and English LTR.

- [ ] **Step 7: Commit Overview integration**

```bash
git add lib/features/dispatcher/dispatcher_driver_performance/presentation/screens lib/features/dispatcher/dispatcher_driver_performance/presentation/widgets test/features/dispatcher/dispatcher_driver_performance/presentation/driver_performance_overview_backend_test.dart
git commit -m "feat: connect driver performance overview"
```

### Task 7: Build and Connect the Comparison Tab

**Files:**
- Create: `lib/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_comparison_content.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_comparison_driver_header.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_comparison_metric_row.dart`
- Modify: `lib/features/dispatcher/dispatcher_driver_performance/presentation/screens/dispatcher_driver_performance_screen.dart`
- Modify: `lib/core/l10n/app_ar.arb`
- Modify: `lib/core/l10n/app_en.arb`
- Generated: `lib/core/l10n/translations/*`
- Test: `test/features/dispatcher/dispatcher_driver_performance/presentation/driver_performance_comparison_backend_test.dart`

**Interfaces:**
- Consumes: `DriverPerformanceComparisonEntity` and all Task 4 comparison states.
- Produces: side-by-side, horizontally scrollable comparison for every driver returned by the endpoint.

- [ ] **Step 1: Write failing comparison tests**

Assert lazy load on tab entry, no second request on cached re-entry, comparison shimmer, full-page comparison error/retry, empty state, all documented metrics, null rating/distance fallback, period consistency, refresh behavior, and horizontal layout without narrow-screen overflow.

- [ ] **Step 2: Run the focused test and verify failure**

Run: `flutter test test/features/dispatcher/dispatcher_driver_performance/presentation/driver_performance_comparison_backend_test.dart`

Expected: FAIL because the tab currently continues to show Overview.

- [ ] **Step 3: Implement comparison content**

Render fixed metric labels and horizontally scrollable driver columns. Include exactly the backend metrics:

```text
totalAssigned
deliveredCount + deliveredPercentage
onTimePercentage
avgDelayMinutes + delay level
rating
failedCount + failedPercentage
totalDistanceKm
```

Use cached network images and typed delay-level colors. Keep server order and do not locally rank comparison drivers.

- [ ] **Step 4: Wire comparison state into the screen**

The segmented tab dispatches `SelectDriverPerformanceTabEvent`. The Comparison branch independently chooses shimmer/error/empty/content. Period changes while Comparison is active load Comparison only; returning to Overview loads it if absent for that period.

- [ ] **Step 5: Generate localization and run tests**

Run localization generation.

Run: `flutter test test/features/dispatcher/dispatcher_driver_performance/presentation/driver_performance_comparison_backend_test.dart`

Expected: PASS in RTL/LTR.

- [ ] **Step 6: Commit Comparison UI**

```bash
git add lib/features/dispatcher/dispatcher_driver_performance/presentation lib/core/l10n test/features/dispatcher/dispatcher_driver_performance/presentation/driver_performance_comparison_backend_test.dart
git commit -m "feat: add driver performance comparison tab"
```

### Task 8: Register Dependencies and Verify Route/API Composition

**Files:**
- Modify: `lib/core/di/di.dart`
- Modify: `lib/config/routing/routing_generator.dart` only if the performance screen requires ViewModel injection or 04.07 has a ready typed-ID route contract
- Test: `test/core/di/di_test.dart`
- Test: `test/features/dispatcher/dispatcher_driver_performance/driver_performance_navigation_test.dart`

**Interfaces:**
- Consumes: repository/data source/use cases/ViewModel from Tasks 3–4.
- Produces: resolvable `DriverPerformanceViewModel` and safe `driverId` navigation boundary.

- [ ] **Step 1: Write failing DI/navigation tests**

Assert registrations resolve one repository backed by the performance remote data source, factory use cases, and a fresh ViewModel per request. Assert driver-row navigation carries the exact backend `driverId` and never a fake detail entity.

- [ ] **Step 2: Run focused tests and verify failure**

Run: `flutter test test/core/di/di_test.dart test/features/dispatcher/dispatcher_driver_performance/driver_performance_navigation_test.dart`

Expected: FAIL because dependencies are not registered and current row taps are unconnected.

- [ ] **Step 3: Register feature dependencies**

Follow the existing manual GetIt pattern in `di.dart`: lazy singleton remote data source/repository; factory use cases/ViewModel. Do not duplicate Dio or `ApiServices`.

- [ ] **Step 4: Finalize the 04.07 navigation boundary**

If `dispatcherDriverDetails` has been migrated to typed `driverId` arguments, connect the default callback and test the route. Otherwise leave an explicit callback requirement in the performance screen constructor and do not modify 04.07 in this plan; its backend contract is outside this feature.

- [ ] **Step 5: Run DI/navigation tests**

Run: `flutter test test/core/di/di_test.dart test/features/dispatcher/dispatcher_driver_performance/driver_performance_navigation_test.dart`

Expected: PASS; if 04.07 is not ready, the navigation test covers the emitted callback ID rather than destination rendering.

- [ ] **Step 6: Commit composition changes**

```bash
git add lib/core/di/di.dart lib/config/routing/routing_generator.dart test/core/di/di_test.dart test/features/dispatcher/dispatcher_driver_performance/driver_performance_navigation_test.dart
git commit -m "feat: register driver performance dependencies"
```

### Task 9: Remove Runtime Fake Data and Complete Regression Verification

**Files:**
- Delete after zero-reference verification: `lib/features/dispatcher/dispatcher_driver_performance/domain/fake_data/driver_performance_fake_data.dart`
- Modify: `test/features/dispatcher/dispatcher_driver_performance/dispatcher_driver_performance_screen_test.dart`
- Verify: all files changed in Tasks 1–8

**Interfaces:**
- Produces: no production fake-data dependency and a fully verified backend-connected performance feature.

- [ ] **Step 1: Verify no runtime fake-data imports remain**

Run: `rg -n "DriverPerformanceFakeData|driver_performance_fake_data" lib test`

Expected: no matches under production presentation/data/domain code. Tests should use dedicated fixtures/builders rather than the production fake-data class.

- [ ] **Step 2: Replace obsolete screen tests**

Update the original static UI test to inject a controlled ViewModel/use cases. Preserve RTL/LTR and no-overflow assertions, but remove expectations tied to hardcoded fake names/counts.

- [ ] **Step 3: Regenerate, format, and analyze**

Run: `dart run build_runner build --delete-conflicting-outputs`

Run: `dart format lib/features/dispatcher/dispatcher_driver_performance lib/core/network lib/core/di/di.dart test/features/dispatcher/dispatcher_driver_performance test/core/network/api_services_test.dart test/core/di/di_test.dart`

Run: `flutter analyze`

Expected: generated code is current and no new analyzer issues exist.

- [ ] **Step 4: Run focused regressions**

Run: `flutter test test/features/dispatcher/dispatcher_driver_performance`

Run: `flutter test test/core/network/api_services_test.dart test/core/errors test/core/di/di_test.dart`

Expected: PASS.

- [ ] **Step 5: Run the complete suite**

Run: `flutter test`

Expected: PASS. If an unrelated pre-existing failure appears, record its exact test/output and prove it is unrelated; do not weaken tests.

- [ ] **Step 6: Manually verify high-risk states**

Verify on Arabic RTL and English LTR phone-size viewports:

1. Initial Overview shimmer → data.
2. Initial Overview error → correct retry.
3. Empty Overview.
4. Every preset and custom period.
5. Rapid period changes do not show stale responses.
6. Local table sorting and row tap emits correct `driverId`.
7. Donut with empty, partial, and unknown segments.
8. Podium with zero, one, two, and three drivers.
9. Lazy Comparison shimmer/error/empty/data.
10. Comparison with many drivers scrolls horizontally without overflow.
11. Refresh failure preserves current content and shows inline error.

- [ ] **Step 7: Commit cleanup and verification**

```bash
git add lib/features/dispatcher/dispatcher_driver_performance test/features/dispatcher/dispatcher_driver_performance
git commit -m "test: verify driver performance backend integration"
```

## Definition of Done

- Overview and Comparison use the two documented endpoints through every required Clean Architecture layer.
- No production performance widget imports `DriverPerformanceFakeData` or a DTO.
- Period presets and custom date ranges send correct values; the restaurant comes from JWT.
- Initial loading uses shape-matched shimmer; screen, inline, and empty states use the existing core widgets correctly.
- Overview renders all five KPIs, table, distribution, and up to three podium entries from backend entities.
- Table sorting is local, deterministic, and does not mutate the original entity list.
- Comparison lazy-loads all active drivers and renders every documented metric side by side.
- Refresh/tab errors preserve usable content and retry only the failed operation.
- Unknown/null backend values do not crash the UI and use safe visual fallbacks.
- Driver-row selection emits the exact backend `driverId`; no fake driver details are opened.
- DTO, mapper, repository, use-case, ViewModel, widget, API, DI, RTL/LTR, and full regression tests pass.
