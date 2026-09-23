# Dispatcher Operations Log Backend Integration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the fake Operations Log data and local-only interactions with a complete backend integration for searching, date/status filtering, isolated counters, numbered pagination, resilient loading/error states, and a typed `boxId` handoff to Box Tracking while preserving the existing screen design.

**Architecture:** Extend `dispatcher_operations` through the required UI → Event → ViewModel → UseCase → Repository → RemoteDataSource → `ApiServices` flow. Defensive nullable response DTOs map into non-JSON domain entities, and one immutable ViewModel state owns the current query, current response, request generation, debounce, and failures. Initial loads use a full screen-shaped shimmer; filter/page replacement loads preserve the controls and replace the card area with shimmer.

**Tech Stack:** Flutter, Dart, `flutter_bloc`, Dio, Retrofit, `json_serializable`, GetIt/Injectable, existing `ApiResult`/`safeApiCall`, `lib/core/errors`, `AppCachedNetworkImage`, and `lib/core/widget/shimmer_widget.dart`.

**Spec:** `D:/yahya/meal meat/dis_new/screen-04.10-operations-log.md`

## Global Constraints

- Follow `rules/rules_backend.md` exactly; do not bypass any Clean Architecture layer.
- Preserve the current Operations Log UI composition, theme, spacing, localization, RTL/LTR behavior, and existing widget names unless a focused backend-driven signature change is required.
- Use the canonical endpoint `GET /api/v1/dispatcher/operations/log`. Do not add both documented aliases to the client; if backend confirms `/api/v1/dispatcher/operations-log` instead, change the one constant before implementation.
- Do not send `restaurantId` by default. JWT determines the restaurant and the backend enforces `DeliveryManager` authorization.
- Reuse the existing `ApiServices`, injected Dio, `TokenInterceptor`, `LanguageInterceptor`, `safeApiCall`, `ApiResult`, `Failure`, GetIt/Injectable, and `lib/core/errors` widgets.
- Response DTO fields, nested objects, and lists are nullable and defensive. Do not force-unwrap API data.
- DTOs stay in Data; UI consumes only domain entities, ViewModel state, and events.
- Keep the API's `pageSize` at `10`, its default and the current visual requirement. Pagination is explicit Previous/Next replacement, not infinite scroll or list append.
- Changing status, search, date preset, or custom date range resets `pageNumber` to `1`.
- Counters are rendered exactly from the latest response and are never recomputed from the current page.
- Initial loading with no response uses `DispatcherOperationsShimmer`; never use `CircularProgressIndicator`.
- A query or page change uses card-area shimmer while retaining the screen chrome. A failed replacement keeps the prior usable response and shows a nonfatal error through the existing Snackbar/error presentation.
- Initial failure uses `ApiErrorWidget.fromTypedFailure`; successful `operations: []` uses `EmptyStateWidget`, never an error or `404` assumption.
- Reuse `AppCachedNetworkImage` for HTTP avatar URLs. Do not pass backend URLs to `AssetImage`.
- Do not trust `statusText`, `statusColor`, `statusIcon`, or `customer.labelText` for business decisions. Map stable API enum keys and let localized UI/theme determine labels, icons, and colors; retain server display text only as an optional fallback if useful.
- Remove `OperationsFakeData` from runtime after real data covers every state; the file may be deleted only after tests no longer import it.
- Do not manually edit `api_services.g.dart`, response `*.g.dart`, or `di.config.dart`; regenerate them with build_runner.
- Preserve unrelated dirty-worktree changes, especially current driver-performance, dispatcher-map, dispatcher-drivers, and core-error work.

## Locked Mapping Decisions

- `boxCode` is the displayed box code. Stop calling it `orderId` in the domain model.
- `boxId` is the stable navigation identifier and remains separate from `boxCode`.
- API `Completed`, `Failed`, and `Reassigned` map directly to typed enum values. Both `Cancelled` and `CancelledByRestaurant` map to `OperationStatus.cancelled`; unknown values map to `OperationStatus.unknown` and render safely instead of crashing.
- Completed/failed cards use `driver`; reassigned cards use `originalDriver` and `replacementDriver`; cancelled cards use `cancelledBy` and `cancelledByText`.
- Driver indicator color is a typed display hint (`green`, `orange`, `red`, `grey`, `unknown`), not an `isOnline` boolean.
- `customer.area` is preferred for the compact location line, falling back to `customer.addressText`.
- `timeText` is displayed because it is localized by `Accept-Language`; `occurredAtUtc` is retained as `DateTime?` for identity/debugging and deterministic client tests, not re-formatted while `timeText` is present.
- Search requests are debounced by `400ms`, trimmed before transmission, and stale responses are discarded using a request-generation counter.
- Date preset values are exactly `Today`, `Last7Days`, `Last30Days`, `Custom`, and `All`. `Custom` is invalid unless both UTC dates exist and `fromDateUtc <= toDateUtc`.
- Status values are exactly `All`, `Completed`, `Cancelled`, `Failed`, and `Reassigned`.
- Page navigation is disabled while a replacement request is active and uses backend `hasPreviousPage`/`hasNextPage` rather than locally guessing.
- Pressing a card emits its raw `boxId`. The Operations feature must not manufacture a fake `BoxTrackingEntity` or fake timeline.

## Backend Sign-off Items

These do not change the mobile architecture, but production acceptance requires answers:

1. Confirm the single canonical path: `/api/v1/dispatcher/operations/log` versus `/api/v1/dispatcher/operations-log`.
2. Confirm whether status counters are mutually exclusive. The sample has `98 + 3 + 7 + 17 = 125` while `allCount = 128`.
3. Confirm `Today` boundaries use restaurant local time before conversion to UTC and define whether `toDateUtc` is inclusive.
4. Confirm all possible operation `type` and `cancelledBy` values, including whether plain `Cancelled` may be returned.
5. Confirm response/error nullability and the standard `{code, message, errors}` error envelope for `400`, `401`, and `403`.
6. Confirm Box Tracking exposes an ID-based route/loader. The current Box Tracking screen accepts a full fake-backed `BoxTrackingEntity`; this plan creates the typed `boxId` handoff but explicitly forbids showing fabricated tracking data.

---

### Task 1: Define the Operations Domain Contract

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_operations/domain/entities/operation_status.dart`
- Modify: `lib/features/dispatcher/dispatcher_operations/domain/entities/operation_item_entity.dart`
- Replace: `lib/features/dispatcher/dispatcher_operations/domain/entities/operations_filter_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_operations/domain/entities/operations_date_preset.dart`
- Create: `lib/features/dispatcher/dispatcher_operations/domain/entities/operations_indicator_color.dart`
- Create: `lib/features/dispatcher/dispatcher_operations/domain/entities/operations_driver_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_operations/domain/entities/operations_customer_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_operations/domain/entities/operations_counters_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_operations/domain/entities/operations_pagination_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_operations/domain/entities/operations_page_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_operations/domain/entities/operations_query_entity.dart`
- Test: `test/features/dispatcher/dispatcher_operations/domain/operations_entities_test.dart`

**Interfaces:**
- Produces: `OperationsQueryEntity` with API-safe status/date values, custom-range validation, immutable `copyWith`, and `resetToFirstPage()`.
- Produces: `OperationsPageEntity(counters, operations, pagination)` and render-ready operation/driver/customer entities.

- [ ] **Step 1: Write failing domain tests**

Cover exact API values, cancellation aliases, unknown enum fallbacks, custom date validation, page reset, and preservation/clearing of nullable dates.

```dart
expect(OperationStatus.cancelled.apiValue, 'Cancelled');
expect(OperationStatusX.fromApi('CancelledByRestaurant'), OperationStatus.cancelled);
expect(OperationStatusX.fromApi('future-value'), OperationStatus.unknown);
expect(OperationsDatePreset.last7Days.apiValue, 'Last7Days');
expect(
  const OperationsQueryEntity(
    datePreset: OperationsDatePreset.custom,
  ).isValid,
  isFalse,
);
expect(
  const OperationsQueryEntity(pageNumber: 4).resetToFirstPage().pageNumber,
  1,
);
```

- [ ] **Step 2: Run the focused test and verify failure**

Run: `flutter test test/features/dispatcher/dispatcher_operations/domain/operations_entities_test.dart`

Expected: FAIL because the new domain contracts do not exist.

- [ ] **Step 3: Implement the domain entities**

Use these aggregate shapes without Retrofit/JSON imports:

```dart
enum OperationStatus { all, completed, cancelled, failed, reassigned, unknown }

class OperationsQueryEntity {
  const OperationsQueryEntity({
    this.restaurantId,
    this.status = OperationStatus.all,
    this.search = '',
    this.datePreset = OperationsDatePreset.last7Days,
    this.fromDateUtc,
    this.toDateUtc,
    this.pageNumber = 1,
    this.pageSize = 10,
  });

  final String? restaurantId;
  final OperationStatus status;
  final String search;
  final OperationsDatePreset datePreset;
  final DateTime? fromDateUtc;
  final DateTime? toDateUtc;
  final int pageNumber;
  final int pageSize;
}

class OperationItemEntity {
  const OperationItemEntity({
    required this.id,
    required this.boxId,
    required this.boxCode,
    required this.status,
    required this.customer,
    required this.timeText,
    this.occurredAtUtc,
    this.driver,
    this.originalDriver,
    this.replacementDriver,
    this.cancelledBy,
    this.cancelledByText,
  });
  // Fields use the same names/types as the constructor.
}

class OperationsPageEntity {
  const OperationsPageEntity({
    required this.counters,
    required this.operations,
    required this.pagination,
  });
}
```

`OperationsDriverEntity` contains `id`, `name`, nullable `avatarUrl`, and typed `indicatorColor`. `OperationsCustomerEntity` contains `id`, `name`, `area`, and `addressText`. Counters contain all five documented counts. Pagination contains all six documented fields. Use value equality manually or the project's current entity convention; do not add a dependency.

- [ ] **Step 4: Run domain tests**

Run: `flutter test test/features/dispatcher/dispatcher_operations/domain/operations_entities_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit the domain contract**

```bash
git add lib/features/dispatcher/dispatcher_operations/domain/entities test/features/dispatcher/dispatcher_operations/domain/operations_entities_test.dart
git commit -m "feat: define operations log domain contract"
```

### Task 2: Add Defensive DTOs and Mapping

**Files:**
- Create: `lib/features/dispatcher/dispatcher_operations/data/models/response/operations_log_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_operations/data/mapper/operations_log_mapper.dart`
- Generated: `lib/features/dispatcher/dispatcher_operations/data/models/response/operations_log_response_dto.g.dart`
- Test: `test/features/dispatcher/dispatcher_operations/data/operations_log_dto_mapper_test.dart`

**Interfaces:**
- Consumes: Task 1 domain entities.
- Produces: `OperationsLogResponseDto.fromJson(Map<String, dynamic>)` and `OperationsLogResponseDto.toEntity()`.

- [ ] **Step 1: Write failing payload and mapper tests**

Test Completed, Failed, Reassigned, and Cancelled payloads; null/omitted nested objects; null lists; invalid dates; unknown `type`/color strings; and a successful empty response.

```dart
final entity = OperationsLogResponseDto.fromJson(payload).toEntity();
expect(entity.counters.allCount, 128);
expect(entity.operations.first.boxCode, '#BX-10256');
expect(entity.operations.first.occurredAtUtc, isA<DateTime>());
expect(entity.pagination.hasNextPage, isTrue);

final empty = OperationsLogResponseDto.fromJson({
  'operations': <Object?>[],
  'pagination': {'totalItems': 0, 'totalPages': 0},
}).toEntity();
expect(empty.operations, isEmpty);
expect(empty.pagination.totalItems, 0);
```

- [ ] **Step 2: Run the DTO/mapper test and verify failure**

Run: `flutter test test/features/dispatcher/dispatcher_operations/data/operations_log_dto_mapper_test.dart`

Expected: FAIL because DTOs and mapper are missing.

- [ ] **Step 3: Implement one nullable DTO tree**

Use `@JsonSerializable(createToJson: false)` for:

```dart
OperationsLogResponseDto
OperationsCountersResponseDto
OperationResponseDto
OperationDriverResponseDto
OperationCustomerResponseDto
OperationsPaginationResponseDto
```

Every field is nullable, including `List<OperationResponseDto>? operations`. Keep these related DTOs in one response file so the contract is easy to audit. Do not edit generated code manually.

- [ ] **Step 4: Implement safe mapping rules**

Map null lists to immutable empty lists; null counts/page values to safe nonnegative defaults; invalid `occurredAtUtc` to `null`; blank `area` to `addressText`; and enum strings through safe `fromApi` methods. Preserve missing drivers as `null` so the card can render its fallback rather than a fake driver.

```dart
extension OperationsLogResponseDtoMapper on OperationsLogResponseDto {
  OperationsPageEntity toEntity() => OperationsPageEntity(
    counters: counters?.toEntity() ?? const OperationsCountersEntity(),
    operations: operations
            ?.map((item) => item.toEntity())
            .toList(growable: false) ??
        const <OperationItemEntity>[],
    pagination: pagination?.toEntity() ??
        const OperationsPaginationEntity(),
  );
}
```

- [ ] **Step 5: Generate and run mapper tests**

Run: `dart run build_runner build --delete-conflicting-outputs`

Then: `flutter test test/features/dispatcher/dispatcher_operations/data/operations_log_dto_mapper_test.dart`

Expected: generation succeeds and test PASSes.

- [ ] **Step 6: Commit DTOs and mapper**

```bash
git add lib/features/dispatcher/dispatcher_operations/data test/features/dispatcher/dispatcher_operations/data/operations_log_dto_mapper_test.dart
git commit -m "feat: map operations log API response"
```

### Task 3: Wire Retrofit, Data Source, Repository, and Use Case

**Files:**
- Modify: `lib/core/network/network_constants.dart`
- Modify: `lib/core/network/api_services.dart`
- Generated: `lib/core/network/api_services.g.dart`
- Create: `lib/features/dispatcher/dispatcher_operations/data/data_source/operations_log_remote_data_source.dart`
- Create: `lib/features/dispatcher/dispatcher_operations/data/data_source/operations_log_remote_data_source_impl.dart`
- Create: `lib/features/dispatcher/dispatcher_operations/domain/repo/operations_log_repository.dart`
- Create: `lib/features/dispatcher/dispatcher_operations/data/repo/operations_log_repository_impl.dart`
- Create: `lib/features/dispatcher/dispatcher_operations/domain/usecase/get_operations_log_usecase.dart`
- Modify test: `test/core/network/api_services_test.dart`
- Test: `test/features/dispatcher/dispatcher_operations/data/operations_log_repository_test.dart`
- Test: `test/features/dispatcher/dispatcher_operations/domain/get_operations_log_usecase_test.dart`

**Interfaces:**
- Produces: `ApiServices.getDispatcherOperationsLog(...)`.
- Produces: `GetOperationsLogUseCase.call(OperationsQueryEntity) -> Future<ApiResult<OperationsPageEntity>>`.

- [ ] **Step 1: Write failing Retrofit contract test**

Assert method, path, and exact query keys/values, including omission of null custom dates and restaurant ID.

```dart
expect(request.method, 'GET');
expect(request.path, '/api/v1/dispatcher/operations/log');
expect(request.queryParameters, containsPair('status', 'Reassigned'));
expect(request.queryParameters, containsPair('datePreset', 'Last7Days'));
expect(request.queryParameters, containsPair('pageNumber', 2));
expect(request.queryParameters, containsPair('pageSize', 10));
expect(request.queryParameters.containsKey('restaurantId'), isFalse);
```

- [ ] **Step 2: Add endpoint constant and Retrofit declaration**

```dart
static const String dispatcherOperationsLog =
    '/api/v1/dispatcher/operations/log';
```

```dart
@GET(EndPoints.dispatcherOperationsLog)
Future<OperationsLogResponseDto> getDispatcherOperationsLog({
  @Query('restaurantId') String? restaurantId,
  @Query('status') String? status,
  @Query('search') String? search,
  @Query('datePreset') String? datePreset,
  @Query('fromDateUtc') String? fromDateUtc,
  @Query('toDateUtc') String? toDateUtc,
  @Query('pageNumber') int? pageNumber,
  @Query('pageSize') int? pageSize,
});
```

Do not manually add auth or language headers; existing interceptors own them.

- [ ] **Step 3: Write failing repository/use-case tests**

Verify query forwarding, `safeApiCall` success mapping, Dio failure conversion into typed `ApiErrorResult`, and local rejection of invalid custom ranges without calling the repository.

```dart
final result = await useCase(
  const OperationsQueryEntity(datePreset: OperationsDatePreset.custom),
);
expect(result, isA<ApiErrorResult<OperationsPageEntity>>());
verifyNever(() => repository.getOperations(any()));
```

- [ ] **Step 4: Implement DataSource, Repository, and UseCase**

```dart
abstract interface class OperationsLogRemoteDataSource {
  Future<OperationsLogResponseDto> getOperations(
    OperationsQueryEntity query,
  );
}

abstract interface class OperationsLogRepository {
  Future<ApiResult<OperationsPageEntity>> getOperations(
    OperationsQueryEntity query,
  );
}
```

Annotate the implementation bindings using the existing feature convention. The RemoteDataSource serializes UTC dates with `toUtc().toIso8601String()` and sends `null` for blank search so Retrofit omits it. The repository wraps exactly one data-source/mapping call in `safeApiCall`. The UseCase returns a `validationError` `Failure` for invalid page values, page size outside `1..50`, or invalid custom ranges.

- [ ] **Step 5: Generate and run network/domain tests**

Run: `dart run build_runner build --delete-conflicting-outputs`

Run:

```bash
flutter test test/core/network/api_services_test.dart
flutter test test/features/dispatcher/dispatcher_operations/data/operations_log_repository_test.dart
flutter test test/features/dispatcher/dispatcher_operations/domain/get_operations_log_usecase_test.dart
```

Expected: all PASS.

- [ ] **Step 6: Commit the backend pipeline**

```bash
git add lib/core/network lib/features/dispatcher/dispatcher_operations/data lib/features/dispatcher/dispatcher_operations/domain/repo lib/features/dispatcher/dispatcher_operations/domain/usecase test/core/network/api_services_test.dart test/features/dispatcher/dispatcher_operations
git commit -m "feat: connect operations log endpoint"
```

### Task 4: Implement Deterministic ViewModel State and Events

**Files:**
- Create: `lib/features/dispatcher/dispatcher_operations/presentation/manager/operations_event.dart`
- Create: `lib/features/dispatcher/dispatcher_operations/presentation/manager/operations_state.dart`
- Create: `lib/features/dispatcher/dispatcher_operations/presentation/manager/operations_view_model.dart`
- Test: `test/features/dispatcher/dispatcher_operations/presentation/manager/operations_view_model_test.dart`

**Interfaces:**
- Consumes: `GetOperationsLogUseCase` and Task 1 query/page entities.
- Produces: injectable `OperationsViewModel`, `OperationsState`, and sealed intent events.

- [ ] **Step 1: Write failing state-machine tests**

Cover initial load; status/date/custom range/search reset to page 1; 400ms search debounce; previous/next; no request beyond backend bounds; retry; initial versus nonfatal failure; keeping prior response during replacement; and stale response suppression.

```dart
expect(viewModel.state.isInitialLoading, isTrue);

await viewModel.doIntent(
  const ChangeOperationsStatusEvent(OperationStatus.failed),
);
expect(viewModel.state.query.pageNumber, 1);

fakeAsync((async) {
  viewModel.doIntent(const ChangeOperationsSearchEvent(' BX-10 '));
  async.elapse(const Duration(milliseconds: 399));
  verifyNever(() => useCase(any()));
  async.elapse(const Duration(milliseconds: 1));
  verify(() => useCase(any())).called(1);
});
```

- [ ] **Step 2: Define events and immutable state**

Use these events:

```dart
LoadOperationsEvent
RetryOperationsEvent
RefreshOperationsEvent
ChangeOperationsStatusEvent
ChangeOperationsSearchEvent
ClearOperationsSearchEvent
ChangeOperationsDatePresetEvent
ChangeOperationsCustomDateRangeEvent
GoToPreviousOperationsPageEvent
GoToNextOperationsPageEvent
```

State fields:

```dart
OperationsPageEntity? response;
OperationsQueryEntity query;
bool isInitialLoading;
bool isReplacementLoading;
Failure? initialFailure;
Failure? nonFatalFailure;
int noticeId;
bool hasLoadedOnce;
```

Add derived getters for `operations`, `counters`, `pagination`, `hasOperations`, `canGoPrevious`, and `canGoNext`. Use a private sentinel in `copyWith` so failures/response can be explicitly cleared.

- [ ] **Step 3: Implement ViewModel orchestration**

Annotate with `@injectable`. Inject `GetOperationsLogUseCase` and an optional `searchDebounceDuration` for tests. Use `_requestGeneration` to ignore out-of-order results and a `Timer` for search. All filter changes call `_fetchReplacement(query.resetToFirstPage())`; page buttons call the same replacement method with `pageNumber ± 1`. Do not append pages.

On failure:

- no response: set `initialFailure` and stop initial shimmer;
- existing response: retain response/query shown before the failed request, set `nonFatalFailure`, increment `noticeId`, and stop replacement shimmer;
- retry after initial failure reissues page 1;
- retry after nonfatal failure retries the attempted query, not a different filter.

- [ ] **Step 4: Run ViewModel tests**

Run: `flutter test test/features/dispatcher/dispatcher_operations/presentation/manager/operations_view_model_test.dart`

Expected: PASS with no pending debounce timers.

- [ ] **Step 5: Commit state management**

```bash
git add lib/features/dispatcher/dispatcher_operations/presentation/manager test/features/dispatcher/dispatcher_operations/presentation/manager/operations_view_model_test.dart
git commit -m "feat: manage operations log state"
```

### Task 5: Implement Date Filtering and Loading/Empty/Error Widgets

**Files:**
- Create: `lib/features/dispatcher/dispatcher_operations/presentation/widgets/operations_date_filter_sheet.dart`
- Create: `lib/features/dispatcher/dispatcher_operations/presentation/widgets/dispatcher_operations_shimmer.dart`
- Create: `lib/features/dispatcher/dispatcher_operations/presentation/widgets/operations_cards_shimmer.dart`
- Create: `lib/features/dispatcher/dispatcher_operations/presentation/widgets/operations_empty_state.dart`
- Modify: `lib/features/dispatcher/dispatcher_operations/presentation/widgets/operations_search_filter_bar.dart`
- Test: `test/features/dispatcher/dispatcher_operations/presentation/widgets/operations_state_widgets_test.dart`

**Interfaces:**
- Consumes: `OperationsDatePreset`, current optional UTC dates, and callbacks.
- Produces: a date sheet used by both top Filter and date-preset controls, full initial shimmer, card replacement shimmer, and successful-empty state.

- [ ] **Step 1: Write failing widget tests**

Verify the date sheet exposes all five presets, shows a date-range picker only for Custom, converts selected local day bounds to UTC, and never applies an inverted range. Verify shimmer composition uses `ShimmerWidget` and empty state uses the shared `EmptyStateWidget`.

```dart
expect(find.text('آخر 7 أيام'), findsOneWidget);
expect(find.text('آخر 30 يوماً'), findsOneWidget);
expect(find.byType(ShimmerWidget), findsWidgets);
expect(find.byType(CircularProgressIndicator), findsNothing);
expect(find.byType(EmptyStateWidget), findsOneWidget);
```

- [ ] **Step 2: Build the date filter sheet**

Follow the interaction pattern of `dispatcher_support_date_filter_sheet.dart`, but use only the Operations presets. Expose:

```dart
static Future<void> show(
  BuildContext context, {
  required OperationsDatePreset selectedPreset,
  required DateTime? initialCustomFrom,
  required DateTime? initialCustomTo,
  required ValueChanged<OperationsDatePreset> onPresetSelected,
  required void Function(DateTime fromUtc, DateTime toUtc)
      onCustomRangeSelected,
});
```

Both the app-bar Filter action and date chip open this sheet because the supplied contract defines no other advanced filter dimensions.

- [ ] **Step 3: Build screen-shaped shimmer and empty state**

`DispatcherOperationsShimmer` mirrors search/date bar, five status chips, three operation cards, and pagination. `OperationsCardsShimmer` mirrors three cards only for query/page replacement. Reuse `ShimmerWidget`, spacing tokens, and current card radii. `OperationsEmptyState` wraps `EmptyStateWidget` with localized title/description and a refresh callback.

- [ ] **Step 4: Make the search/date bar controlled**

Accept `isEnabled`, selected preset label, search clear callback, and date callback. Do not keep date state inside the widget. Disable query-changing controls while replacement loading to prevent duplicate page/filter requests.

- [ ] **Step 5: Run widget tests**

Run: `flutter test test/features/dispatcher/dispatcher_operations/presentation/widgets/operations_state_widgets_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit state widgets**

```bash
git add lib/features/dispatcher/dispatcher_operations/presentation/widgets test/features/dispatcher/dispatcher_operations/presentation/widgets/operations_state_widgets_test.dart
git commit -m "feat: add operations filters and shimmer states"
```

### Task 6: Adapt Cards, Counters, Pagination, and Network Avatars

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_operations/presentation/widgets/operations_card.dart`
- Modify: `lib/features/dispatcher/dispatcher_operations/presentation/widgets/operations_driver_info.dart`
- Modify: `lib/features/dispatcher/dispatcher_operations/presentation/widgets/operations_reassigned_info.dart`
- Modify: `lib/features/dispatcher/dispatcher_operations/presentation/widgets/operations_cancelled_info.dart`
- Modify: `lib/features/dispatcher/dispatcher_operations/presentation/widgets/operations_customer_info.dart`
- Modify: `lib/features/dispatcher/dispatcher_operations/presentation/widgets/operations_status_badge.dart`
- Modify: `lib/features/dispatcher/dispatcher_operations/presentation/widgets/operations_status_tabs.dart`
- Modify: `lib/features/dispatcher/dispatcher_operations/presentation/widgets/operations_pagination_bar.dart`
- Test: `test/features/dispatcher/dispatcher_operations/presentation/widgets/operations_backend_widgets_test.dart`

**Interfaces:**
- Consumes: the new render-ready domain entities and backend-derived counters/pagination.
- Produces: callback `ValueChanged<OperationItemEntity>? onTap` with no navigation knowledge inside the card.

- [ ] **Step 1: Write failing card/pagination tests**

Cover all four documented card types, null avatars/drivers, unknown operation fallback, backend counts, backend page values, and disabled buttons during replacement loading.

```dart
expect(find.text('#BX-10256'), findsOneWidget);
expect(find.text('يوسف خالد'), findsOneWidget);
expect(find.text('شهد المطيري'), findsOneWidget);
expect(find.byType(AppCachedNetworkImage), findsWidgets);
expect(find.text('1 من 15'), findsOneWidget);
```

- [ ] **Step 2: Replace asset-only avatar rendering**

Use `AppCachedNetworkImage` inside the existing circular clipping. Blank/null URLs render the existing person icon fallback. Apply typed indicator colors through theme colors: green → primary/success semantic, orange → tertiary, red → error, grey/unknown → onSurfaceVariant. Do not interpret indicator color as online presence.

- [ ] **Step 3: Bind each card variant to the correct data**

- completed/failed: `driver`, `boxCode`, customer, `timeText`;
- reassigned: `originalDriver` and `replacementDriver`, plus customer/time/status;
- cancelled: storefront icon, `cancelledByText`, and `boxCode`;
- unknown/malformed: generic safe icon/text and no crash.

Keep status label/icon/color localized and theme-driven from typed `OperationStatus`. Do not display raw enum strings.

- [ ] **Step 4: Bind counters and pagination**

Change `OperationsStatusTabs` to accept `OperationsCountersEntity`, selected `OperationStatus`, and callback. Change pagination to accept the backend pagination entity plus `isLoading`; button enablement requires the corresponding backend boolean and `!isLoading`.

- [ ] **Step 5: Run focused widget tests**

Run: `flutter test test/features/dispatcher/dispatcher_operations/presentation/widgets/operations_backend_widgets_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit backend-driven widgets**

```bash
git add lib/features/dispatcher/dispatcher_operations/presentation/widgets test/features/dispatcher/dispatcher_operations/presentation/widgets/operations_backend_widgets_test.dart
git commit -m "feat: render operations API data"
```

### Task 7: Connect the Screen, Core Errors, and Box-ID Handoff

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_operations/presentation/screens/dispatcher_operations_screen.dart`
- Modify only if required by the confirmed ID-based contract: `lib/config/routing/routing_generator.dart`
- Modify only if required by the confirmed ID-based contract: `lib/features/dispatcher/dispatcher_box_tracking/presentation/screens/dispatcher_box_tracking_screen.dart`
- Test: `test/features/dispatcher/dispatcher_operations/presentation/dispatcher_operations_backend_test.dart`

**Interfaces:**
- Consumes: `OperationsViewModel`, state widgets, and operation widgets.
- Produces: injectable/testable screen and `ValueChanged<String>? onOpenBoxTracking` handoff.

- [ ] **Step 1: Write failing screen integration tests**

Inject a fake ViewModel/use case and cover:

- first frame triggers one load;
- initial loading renders `DispatcherOperationsShimmer`;
- initial typed failure renders `ApiErrorWidget.fromTypedFailure` and retry;
- successful empty response renders `OperationsEmptyState`;
- loaded response renders API counters/cards/page;
- status/date/search/page actions dispatch exact events;
- replacement loading shows `OperationsCardsShimmer` without erasing header/filters;
- nonfatal failure retains data and shows the existing error Snackbar;
- tapping a card calls `onOpenBoxTracking` exactly once with raw `boxId`.

```dart
await tester.tap(find.text('#BX-10256'));
expect(openedBoxId, '3fa85f64-5717-4562-b3fc-2c963f66afa2');
```

- [ ] **Step 2: Replace local fake state with injected ViewModel**

Follow the ownership pattern in `DispatcherSupportScreen`:

```dart
class DispatcherOperationsScreen extends StatefulWidget {
  const DispatcherOperationsScreen({
    super.key,
    this.viewModel,
    this.onOpenBoxTracking,
  });

  final OperationsViewModel? viewModel;
  final ValueChanged<String>? onOpenBoxTracking;
}
```

Resolve `getIt<OperationsViewModel>()` only when no test ViewModel is supplied; close only internally owned ViewModels. Keep one `TextEditingController` synchronized with state and dispose it. Wrap UI with `BlocProvider.value`, `BlocListener` for nonfatal errors, and `BlocBuilder` for state rendering.

- [ ] **Step 3: Use the existing core error system**

For no-data failure:

```dart
ApiErrorWidget.fromTypedFailure(
  failure: state.initialFailure!,
  onRetry: () => viewModel.doIntent(const RetryOperationsEvent()),
)
```

For replacement failure, retain prior content and call the existing `CustomSnackbar.showError` with `failure.errorMessage`. Do not add feature-specific exception parsing and do not modify `lib/core/errors` unless a failing test proves a shared widget defect; current uncommitted core-error changes belong to the user and must be preserved.

- [ ] **Step 4: Wire query and pagination events**

Remove `_allOperations`, `_filteredOperations`, fake counts, local date toggling, and local page mutation. Search/status/date/page callbacks dispatch ViewModel events. Pull-to-refresh dispatches `RefreshOperationsEvent` and keeps the selected query.

- [ ] **Step 5: Implement the honest Box Tracking handoff**

Use the injected callback in tests/hosted use. For the production default, navigate only through an ID-based Box Tracking contract confirmed by Backend Sign-off item 6, for example:

```dart
void _openBoxTracking(OperationItemEntity item) {
  final callback = widget.onOpenBoxTracking;
  if (callback != null) {
    callback(item.boxId);
    return;
  }
  Navigator.of(context).pushNamed(
    AppRoutes.boxTracking,
    arguments: item.boxId,
  );
}
```

Update `routing_generator.dart`/`DispatcherBoxTrackingScreen` only when they can load real tracking data by that ID. If the Box Tracking feature still accepts only a full `BoxTrackingEntity`, keep the callback seam and record the route integration as blocked in the implementation handoff; never substitute `BoxTrackingFakeData.defaultBox` or construct a partially fake entity.

- [ ] **Step 6: Run screen tests**

Run: `flutter test test/features/dispatcher/dispatcher_operations/presentation/dispatcher_operations_backend_test.dart`

Expected: PASS. The navigation test uses the injected callback and proves the correct `boxId` handoff without fake tracking data.

- [ ] **Step 7: Commit the connected screen**

```bash
git add lib/features/dispatcher/dispatcher_operations/presentation/screens lib/config/routing/routing_generator.dart lib/features/dispatcher/dispatcher_box_tracking/presentation/screens/dispatcher_box_tracking_screen.dart test/features/dispatcher/dispatcher_operations/presentation/dispatcher_operations_backend_test.dart
git commit -m "feat: connect operations log screen"
```

Only stage the two cross-feature files if they were legitimately changed after Box Tracking contract confirmation.

### Task 8: Regenerate, Remove Runtime Fake Data, and Verify the Feature

**Files:**
- Delete when no imports remain: `lib/features/dispatcher/dispatcher_operations/domain/fake_data/operations_fake_data.dart`
- Generated: `lib/core/network/api_services.g.dart`
- Generated: `lib/core/di/di.config.dart`
- Generated: Operations response DTO `*.g.dart`
- Existing regression test: `test/features/dispatcher/dispatcher_operations/dispatcher_operations_screen_test.dart`

**Interfaces:**
- Consumes: all previous tasks.
- Produces: generated bindings, no runtime fake dependency, formatted/analyzed/tested integration.

- [ ] **Step 1: Search for stale fake/old-field usage**

Run:

```bash
rg -n "OperationsFakeData|orderId|isDriverOnline|dateRangeLabel|_filteredOperations|_allOperations" lib/features/dispatcher/dispatcher_operations test/features/dispatcher/dispatcher_operations
```

Expected: no runtime references. Test fixture references must be migrated to explicit domain fixtures.

- [ ] **Step 2: Delete fake data and update old screen tests**

Delete `operations_fake_data.dart` only after Step 1 confirms it is unused. Update the existing screen test to inject a deterministic ViewModel/use case; do not make it hit the network or GetIt global state.

- [ ] **Step 3: Regenerate all generated code**

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: Retrofit, JSON, and Injectable generation succeeds with no conflicting outputs. Inspect the diff to ensure generated changes relate only to this feature and existing pending annotations.

- [ ] **Step 4: Format only touched source/test files**

Run `dart format` with the explicit list of Operations Log, network declaration, and Operations tests changed in Tasks 1–7. Do not bulk-format unrelated dirty files.

- [ ] **Step 5: Run focused Operations Log suite**

Run:

```bash
flutter test test/features/dispatcher/dispatcher_operations
flutter test test/core/network/api_services_test.dart
```

Expected: all PASS.

- [ ] **Step 6: Run static analysis**

Run: `flutter analyze`

Expected: no new errors or warnings from Operations Log. Record unrelated pre-existing failures separately with file and message; do not fix unrelated features.

- [ ] **Step 7: Run dispatcher regression tests**

Run the existing dispatcher tests whose shared API/DI/routing surfaces were touched, at minimum:

```bash
flutter test test/dispatcher_orders_screen_test.dart
flutter test test/dispatcher_map_screen_test.dart
flutter test test/features/dispatcher/dispatcher_support
flutter test test/features/dispatcher/dispatcher_driver_performance
```

Expected: all PASS, or any pre-existing failure is documented with evidence that it reproduces without Operations changes.

- [ ] **Step 8: Manual acceptance against the contract**

Using a valid `DeliveryManager` token in Arabic and English, verify:

1. Default request is `All + Last7Days + page 1 + pageSize 10`.
2. Initial load is a screen-shaped shimmer.
3. Search matches box/driver/customer and resets page 1 after 400ms.
4. Each status chip sends its exact API value; counters remain isolated.
5. Today/7/30/All and Custom send correct date queries.
6. Previous/Next respect backend booleans and update page indicator.
7. Completed, failed, reassigned, and cancelled cards render correctly with null-avatar fallback.
8. Empty 200 response shows empty state.
9. Offline, timeout, 401/403, 400, and 500 use `lib/core/errors` presentation and retry behavior.
10. A card passes its actual `boxId`; no fake tracking record appears.

- [ ] **Step 9: Final diff audit and commit**

Run:

```bash
git status --short
git diff --check
git diff --stat
```

Confirm no unrelated dirty files were staged and no generated file was hand-edited.

```bash
git add lib/core/network lib/core/di/di.config.dart lib/features/dispatcher/dispatcher_operations test/core/network/api_services_test.dart test/features/dispatcher/dispatcher_operations
git commit -m "test: verify operations log backend integration"
```

If Box Tracking ID routing was separately confirmed and changed, stage only those exact routing/tracking files with this commit or a dedicated scoped commit.

## Definition of Done

- No runtime import or use of `OperationsFakeData` remains.
- One canonical Operations endpoint is generated through the shared Retrofit client.
- DTOs are nullable/defensive and never leak into domain/presentation.
- All queries reset and serialize exactly as documented.
- Counters come from backend and stay isolated from active status.
- Initial and replacement loading use shimmer, with no progress spinner.
- Initial errors, nonfatal errors, empty success, retry, and stale requests behave deterministically through existing core error infrastructure.
- Network avatars and null fallbacks render without `AssetImage` URL failures.
- Pagination follows backend metadata and never appends/duplicates records.
- Card taps hand off the exact `boxId` without manufacturing fake tracking data.
- Focused tests, API tests, analysis, and relevant dispatcher regressions pass.
