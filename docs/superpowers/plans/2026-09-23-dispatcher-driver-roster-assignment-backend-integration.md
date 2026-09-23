# Dispatcher Driver Roster and Assignment Backend Integration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the fake Dispatcher Drivers roster with backend-driven By Area/All browsing, live counts and areas, safe assignment of a selected available driver to a real `boxId`, and filter-aware map handoff while preserving the existing UI.

**Architecture:** Keep roster retrieval and assignment orchestration inside `dispatcher_drivers` using UI → Event → ViewModel → UseCase → Repository → RemoteDataSource → shared `ApiServices`. A typed route argument distinguishes browse mode from assignment mode so a driver tap can never accidentally assign without a real box GUID. Nullable DTOs map to domain-safe entities; initial loads use screen-shaped shimmer and core error widgets, while view/area changes keep chrome visible and shimmer only the data region.

**Tech Stack:** Flutter, Dart, `flutter_bloc`, Dio, Retrofit, `json_serializable`, GetIt/Injectable, existing `ApiResult`/`safeApiCall`, `lib/core/errors`, `AppCachedNetworkImage`, `ShimmerWidget`, and existing routing/localization infrastructure.

**Spec:** `D:/yahya/meal meat/dis_new/screen-04.05-driver-roster-assignment.md`

## Global Constraints

- Follow `rules/rules_backend.md` exactly and preserve the feature-based Clean Architecture flow.
- Scope is `dispatcher_drivers`, the minimum `dispatcher_assign_box`/routing handoff needed to supply a real `boxId`, and the minimum map-route contract needed to carry an area filter. Do not modify unrelated Operations Log work currently in progress.
- Preserve the existing screen layout, theme, animations, spacing, localization, RTL/LTR behavior, and widget names unless backend data requires a focused signature change.
- Reuse the shared `ApiServices`, injected Dio, token/language interceptors, `ApiResult`, `safeApiCall`, `Failure`, GetIt/Injectable, and `lib/core/errors` widgets.
- Response DTO fields and nested values are nullable and defensive; never force-unwrap API data.
- UI must consume domain entities/state only. DTOs never enter domain or presentation.
- Do not manually add `Authorization` or `Accept-Language`; existing interceptors own both.
- Do not create a second Dio/Retrofit client or a new result/error abstraction.
- Initial roster load uses `DispatcherDriversShimmer`; view/area replacement uses roster-content shimmer. Never use a centered `CircularProgressIndicator` for page loading.
- Assignment uses an in-button/card blocking state and prevents duplicate taps. Existing data remains visible during assignment.
- Initial failure uses `ApiErrorWidget.fromTypedFailure`; replacement failure retains prior data and uses the existing Snackbar/inline error presentation; a successful empty list uses `EmptyStateWidget`.
- Use `AppCachedNetworkImage` for avatar URLs; do not pass HTTP URLs to `AssetImage`.
- Do not manually edit generated `api_services.g.dart`, DTO `*.g.dart`, or `di.config.dart`; run build_runner.
- Preserve all unrelated dirty-worktree changes.

## Locked Product and Client Decisions

- `DispatcherDriversMode.browse` is used from dashboard/profile/direct fleet browsing. Driver taps open details; no assignment API is available.
- `DispatcherDriversMode.assignment` is used only when launched with a non-empty GUID `boxId`. Tapping `+ اختيار` on an eligible driver calls `POST /api/v1/dispatcher/orders/{boxId}/assign` immediately, matching the supplied lifecycle.
- Route input is `DispatcherDriversRouteArgs(mode, boxId, initialView, initialAreaKey, initialAreaName)`. `boxId` is required and validated only in assignment mode.
- `driverId` is the backend GUID; `driverCode` is display-only. Existing entity field `id` must not continue mixing those meanings.
- `view` values are exactly `ByArea` and `All`.
- Until backend confirms a stable query contract, By Area requests use the server-returned area selection value consistently. The preferred production contract is `areaKey`; localized `name` must not be treated as a stable identifier across Arabic/English.
- In All mode, area chips are hidden even if the response still includes `areas` or `selectedArea`.
- Counts, section title, areas, eligibility, status text, and driver metrics come from the server response. The app does not recompute global counts from the currently returned driver subset.
- `isAvailableForSelection` is the final assignment gate. Typed status controls visual state but cannot override a false eligibility flag.
- List sorting by distance, rating, and active load is local and stable because all three numeric fields are already returned and the documented roster endpoint has no sort parameters.
- Vehicle-type filtering is not implemented from guessed data. It remains unavailable until the backend adds a stable vehicle field/filter contract.
- A roster request may include `boxId` in assignment mode and omits it in browse mode. This lets the backend calculate box-specific distance/eligibility if supported.
- Assignment notes default to the localized equivalent of `إسناد مباشر من قائمة السائقين`; the ViewModel sends the domain request, not a DTO created by UI.
- On assignment success, show the server message and invoke a typed completion callback. The production route returns to/refetches the Orders Queue; tests inject the callback and never depend on global navigation.
- A 409/conflict assignment failure keeps the roster open, re-fetches the current roster after presenting the error, and allows selection of another driver.
- Map navigation carries `areaKey` plus display `areaName`. The map must not pretend the filter is applied unless its backend/query layer can enforce or safely match that stable area key.

## What Is Missing or Ambiguous in the Backend Contract

These items must be answered before production sign-off. Items 1–4 block the corresponding UI behavior; the executor must not invent values.

1. **Stable area query:** the sample sends `area=السالمية` but returns `areaKey=salmiya`. The API should accept `areaKey` (recommended) or explicitly guarantee localized `name` as the query value for both `ar` and `en`.
2. **Advanced vehicle filter:** the UI promises filtering by vehicle type, but the roster driver payload has no `vehicleType`/`vehicleTypeKey`, and the endpoint documents no filter query parameters.
3. **Filter/sort contract:** confirm whether rating, vehicle, distance, and load filtering/sorting are server-side. If server-side, document exact keys such as `minimumRating`, `vehicleType`, `sortBy`, and `sortDirection`. This plan keeps only numeric sorting local.
4. **Map area preservation:** `/drivers/live-monitoring` currently has no documented `area`/`areaKey` query. Add/confirm a stable area filter or confirm that every live-map driver returns the same stable `currentZoneKey` so filtering can be safely local.
5. **Pagination/scale:** roster has no `pageNumber`, `pageSize`, `totalItems`, or `hasNextPage`. Confirm that the endpoint intentionally returns the complete restaurant fleet and document the maximum expected driver count.
6. **Distance meaning:** define whether `distanceKm` is from the restaurant, the box delivery location, or another point, and whether passing `boxId` changes it.
7. **Counts semantics:** clarify whether `busyCount` includes `OnBreak` and whether `totalCount = availableCount + busyCount` must always hold.
8. **All-mode selection:** `selectedView=All` still returns `selectedArea=السالمية` and an area with `isSelected=true`. Confirm that clients must ignore these fields in All mode or return them as null/false.
9. **Status vocabulary:** document every possible `status`, `statusDotColor`, and eligibility combination. Unknown values must be expected without crashing clients.
10. **Assignment conflict rules:** document HTTP/error codes for already-assigned box, unavailable driver, driver capacity reached, invalid/foreign box, invalid/foreign driver, and concurrent assignments. Recommended: `409` for state conflicts and `403` for restaurant ownership violations.
11. **Idempotency:** confirm whether repeated identical POSTs are idempotent or support an idempotency key. Mobile will block duplicate taps but cannot prevent transport retries or concurrent devices.
12. **Notes contract:** state whether `notes` is optional, its maximum length, accepted characters, and whether a localized default is permitted.
13. **Authorization:** confirm both endpoints derive restaurant ownership from JWT and reject cross-restaurant `boxId`/`driverId`.
14. **Error envelope:** document localized `400`, `401`, `403`, `404`, `409`, `422`, and `500` bodies using the project's supported `{code, message, errors}` shape.
15. **Source box identity:** the upstream Assign Box/Order Queue contract must supply the real GUID `boxId`. The current `AssignBoxOrderEntity` only has `boxCode`, which cannot be used in the POST path.

---

### Task 1: Define Route Context, Query, Roster, and Assignment Domain Models

**Files:**
- Create: `lib/config/routing/arguments/dispatcher_drivers_route_arguments.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_view_mode.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_status.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_kpi_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_mode.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_area_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_query_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_roster_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_sort.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/domain/entities/assign_driver_request_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/domain/entities/driver_assignment_result_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_order_entity.dart`
- Test: `test/features/dispatcher/dispatcher_drivers/domain/dispatcher_drivers_entities_test.dart`

**Interfaces:**
- Produces: validated `DispatcherDriversRouteArgs` and `DispatcherDriversQueryEntity`.
- Produces: `DispatcherDriversRosterEntity`, typed driver/area/count entities, assignment request/result, and local sort enum.

- [ ] **Step 1: Write failing domain tests**

Cover exact API values, unknown status fallback, route-mode validation, query serialization values, eligibility, page-independent stable sorting, and distinct GUID/code fields.

```dart
expect(DispatcherDriverViewMode.byArea.apiValue, 'ByArea');
expect(DispatcherDriverViewMode.allDrivers.apiValue, 'All');
expect(
  DispatcherDriverStatusX.fromApi('OnBreak'),
  DispatcherDriverStatus.onBreak,
);
expect(
  const DispatcherDriversRouteArgs.assignment(boxId: '').isValid,
  isFalse,
);
expect(
  const DispatcherDriversRouteArgs.browse().isValid,
  isTrue,
);
```

- [ ] **Step 2: Run the test and verify failure**

Run: `flutter test test/features/dispatcher/dispatcher_drivers/domain/dispatcher_drivers_entities_test.dart`

Expected: FAIL because the new domain contracts do not exist.

- [ ] **Step 3: Implement the route/query contracts**

```dart
enum DispatcherDriversMode { browse, assignment }

class DispatcherDriversRouteArgs {
  const DispatcherDriversRouteArgs.browse({
    this.initialView = DispatcherDriverViewMode.byArea,
    this.initialAreaKey,
    this.initialAreaName,
  })  : mode = DispatcherDriversMode.browse,
        boxId = null;

  const DispatcherDriversRouteArgs.assignment({
    required this.boxId,
    this.initialView = DispatcherDriverViewMode.byArea,
    this.initialAreaKey,
    this.initialAreaName,
  }) : mode = DispatcherDriversMode.assignment;

  final DispatcherDriversMode mode;
  final String? boxId;
  final DispatcherDriverViewMode initialView;
  final String? initialAreaKey;
  final String? initialAreaName;
}

class DispatcherDriversQueryEntity {
  const DispatcherDriversQueryEntity({
    this.view = DispatcherDriverViewMode.byArea,
    this.areaKey,
    this.areaName,
    this.boxId,
  });
  final DispatcherDriverViewMode view;
  final String? areaKey;
  final String? areaName;
  final String? boxId;
}
```

Validation requires a parseable non-empty GUID-like `boxId` in assignment mode and an area key/name in By Area mode after the first response establishes a selected area.

- [ ] **Step 4: Implement roster and assignment entities**

`DispatcherDriverEntity` fields are: `driverId`, `driverCode`, `fullName`, nullable `avatarUrl`, `rating`, typed `status`, optional `statusText`, typed dot color or safe key, `isAvailableForSelection`, `activeOrdersCount`, optional active text, `completedOrdersTodayCount`, optional completed text, `distanceKm`, optional distance text, `currentZoneName`, and optional future-safe `currentZoneKey`.

```dart
class DispatcherDriversRosterEntity {
  const DispatcherDriversRosterEntity({
    required this.counts,
    required this.selectedView,
    required this.selectedAreaKey,
    required this.selectedAreaName,
    required this.sectionTitle,
    required this.areas,
    required this.drivers,
  });
}

class AssignDriverRequestEntity {
  const AssignDriverRequestEntity({
    required this.boxId,
    required this.driverId,
    required this.notes,
  });
}
```

Add `boxId` to `AssignBoxOrderEntity` as a required stable ID; tests/fixtures must supply an explicit GUID instead of deriving it from `boxCode`.

- [ ] **Step 5: Run domain tests**

Run: `flutter test test/features/dispatcher/dispatcher_drivers/domain/dispatcher_drivers_entities_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit domain contracts**

```bash
git add lib/config/routing/arguments/dispatcher_drivers_route_arguments.dart lib/features/dispatcher/dispatcher_drivers/domain lib/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_order_entity.dart test/features/dispatcher/dispatcher_drivers/domain/dispatcher_drivers_entities_test.dart
git commit -m "feat: define driver roster domain contracts"
```

### Task 2: Create Defensive Roster and Assignment DTO Mapping

**Files:**
- Create: `lib/features/dispatcher/dispatcher_drivers/data/models/request/assign_driver_request_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/data/models/response/dispatcher_drivers_roster_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/data/models/response/driver_assignment_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/data/mapper/dispatcher_drivers_mapper.dart`
- Generated: corresponding `*.g.dart` files
- Test: `test/features/dispatcher/dispatcher_drivers/data/dispatcher_drivers_dto_mapper_test.dart`

**Interfaces:**
- Consumes: Task 1 domain entities.
- Produces: nullable roster/assignment response DTOs, required request DTO, and bidirectional domain/data mapping where needed.

- [ ] **Step 1: Write failing DTO and mapper tests**

Test both ByArea and All samples, all documented statuses, null nested counts/areas/drivers, missing strings, unknown enum/color values, null avatar/rating/distance, empty list success, assignment request JSON, valid assignment result, and invalid assignment timestamp.

```dart
final roster = DispatcherDriversRosterResponseDto.fromJson(json).toEntity();
expect(roster.counts.totalCount, 13);
expect(roster.drivers.first.driverId, '11111111-1111-1111-1111-111111111111');
expect(roster.drivers.first.driverCode, 'ID:D-1025');
expect(roster.drivers.first.isAvailableForSelection, isTrue);

expect(
  const AssignDriverRequestEntity(
    boxId: 'a1111111-1111-1111-1111-111111111111',
    driverId: '11111111-1111-1111-1111-111111111111',
    notes: 'إسناد مباشر من قائمة السائقين',
  ).toDto().toJson(),
  containsPair('driverId', '11111111-1111-1111-1111-111111111111'),
);
```

- [ ] **Step 2: Run mapper tests and verify failure**

Run: `flutter test test/features/dispatcher/dispatcher_drivers/data/dispatcher_drivers_dto_mapper_test.dart`

Expected: FAIL because DTOs/mappers are absent.

- [ ] **Step 3: Implement nullable response DTO trees**

Use `@JsonSerializable(createToJson: false)` for roster root, counts, area, driver, and assignment response. All response fields are nullable. Use ordinary `@JsonSerializable()` for `AssignDriverRequestDto` with required `driverId` and `notes` matching the confirmed request contract.

- [ ] **Step 4: Implement safe mapping**

Map null lists to immutable empty lists, counts to nonnegative values, unknown status to `unknown`, missing IDs/codes to empty display-safe values, invalid timestamp to null, and eligibility default to false. Do not infer eligibility from status when the server omits it. Prefer server numeric values for sorting and retain optional server display strings only for presentation fallback.

- [ ] **Step 5: Generate and run tests**

Run: `dart run build_runner build --delete-conflicting-outputs`

Then: `flutter test test/features/dispatcher/dispatcher_drivers/data/dispatcher_drivers_dto_mapper_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit DTO mapping**

```bash
git add lib/features/dispatcher/dispatcher_drivers/data/models lib/features/dispatcher/dispatcher_drivers/data/mapper test/features/dispatcher/dispatcher_drivers/data/dispatcher_drivers_dto_mapper_test.dart
git commit -m "feat: map driver roster API payloads"
```

### Task 3: Wire Both Endpoints Through Clean Architecture

**Files:**
- Modify: `lib/core/network/network_constants.dart`
- Modify: `lib/core/network/api_services.dart`
- Generated: `lib/core/network/api_services.g.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/data/data_source/dispatcher_drivers_remote_data_source.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/data/data_source/dispatcher_drivers_remote_data_source_impl.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/domain/repo/dispatcher_drivers_repository.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/data/repo/dispatcher_drivers_repository_impl.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/domain/usecase/get_dispatcher_drivers_roster_usecase.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/domain/usecase/assign_driver_to_box_usecase.dart`
- Modify test: `test/core/network/api_services_test.dart`
- Test: `test/features/dispatcher/dispatcher_drivers/data/dispatcher_drivers_repository_test.dart`
- Test: `test/features/dispatcher/dispatcher_drivers/domain/dispatcher_drivers_usecases_test.dart`

**Interfaces:**
- Produces: `ApiServices.getDispatcherDriversRoster(...)` and `ApiServices.assignDriverToBox(...)`.
- Produces: `GetDispatcherDriversRosterUseCase` and `AssignDriverToBoxUseCase`, both returning existing `ApiResult` types.

- [ ] **Step 1: Write failing Retrofit request tests**

Assert exact paths, methods, query omission, path substitution, and JSON body.

```dart
expect(rosterRequest.method, 'GET');
expect(rosterRequest.path, '/api/v1/dispatcher/drivers/roster');
expect(rosterRequest.queryParameters['view'], 'ByArea');
expect(rosterRequest.queryParameters['boxId'], boxId);

expect(assignRequest.method, 'POST');
expect(assignRequest.path, '/api/v1/dispatcher/orders/$boxId/assign');
expect(assignRequest.body['driverId'], driverId);
```

- [ ] **Step 2: Add endpoint constants and Retrofit methods**

```dart
static const String dispatcherDriversRoster =
    '/api/v1/dispatcher/drivers/roster';
static const String dispatcherAssignOrder =
    '/api/v1/dispatcher/orders/{boxId}/assign';
```

```dart
@GET(EndPoints.dispatcherDriversRoster)
Future<DispatcherDriversRosterResponseDto> getDispatcherDriversRoster({
  @Query('view') required String view,
  @Query('area') String? area,
  @Query('boxId') String? boxId,
});

@POST(EndPoints.dispatcherAssignOrder)
Future<DriverAssignmentResponseDto> assignDriverToBox(
  @Path('boxId') String boxId,
  @Body() AssignDriverRequestDto request,
);
```

If backend resolves Missing Item 1 with `areaKey`, rename only the Retrofit query to the exact confirmed key and update its test before generation.

- [ ] **Step 3: Write failing repository/use-case tests**

Cover successful mapping, Dio errors through `safeApiCall`, browse-mode omission of box ID, assignment-mode forwarding, invalid By Area query, missing/invalid IDs, and blank notes according to the confirmed limit.

- [ ] **Step 4: Implement DataSource and Repository**

```dart
abstract interface class DispatcherDriversRemoteDataSource {
  Future<DispatcherDriversRosterResponseDto> getRoster(
    DispatcherDriversQueryEntity query,
  );
  Future<DriverAssignmentResponseDto> assignDriver(
    AssignDriverRequestEntity request,
  );
}

abstract interface class DispatcherDriversRepository {
  Future<ApiResult<DispatcherDriversRosterEntity>> getRoster(
    DispatcherDriversQueryEntity query,
  );
  Future<ApiResult<DriverAssignmentResultEntity>> assignDriver(
    AssignDriverRequestEntity request,
  );
}
```

RemoteDataSource owns entity-to-request-DTO conversion at the API boundary. Repository wraps each remote call/mapping in one `safeApiCall`; no feature-specific `try/catch`.

- [ ] **Step 5: Implement validation UseCases**

Roster rejects By Area without a confirmed area query value after initialization. Assignment rejects blank/non-GUID box or driver IDs and notes exceeding the backend-confirmed maximum through an `ApiErrorResult` with `ApiErrorType.validationError`, without calling the repository.

- [ ] **Step 6: Generate and run focused tests**

Run: `dart run build_runner build --delete-conflicting-outputs`

Run:

```bash
flutter test test/core/network/api_services_test.dart
flutter test test/features/dispatcher/dispatcher_drivers/data/dispatcher_drivers_repository_test.dart
flutter test test/features/dispatcher/dispatcher_drivers/domain/dispatcher_drivers_usecases_test.dart
```

Expected: all PASS.

- [ ] **Step 7: Commit network pipeline**

```bash
git add lib/core/network lib/features/dispatcher/dispatcher_drivers/data lib/features/dispatcher/dispatcher_drivers/domain/repo lib/features/dispatcher/dispatcher_drivers/domain/usecase test/core/network/api_services_test.dart test/features/dispatcher/dispatcher_drivers
git commit -m "feat: connect driver roster and assignment APIs"
```

### Task 4: Build Roster and Assignment ViewModel State

**Files:**
- Create: `lib/features/dispatcher/dispatcher_drivers/presentation/manager/dispatcher_drivers_event.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/presentation/manager/dispatcher_drivers_state.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/presentation/manager/dispatcher_drivers_view_model.dart`
- Test: `test/features/dispatcher/dispatcher_drivers/presentation/manager/dispatcher_drivers_view_model_test.dart`

**Interfaces:**
- Consumes: route args and both Task 3 UseCases.
- Produces: one injectable `DispatcherDriversViewModel` coordinating roster replacement, local sorting, and assignment.

- [ ] **Step 1: Write failing state-machine tests**

Cover initial query construction, first load, ByArea/All switching, server-selected initial area, area replacement, stale-response suppression, local sort cycles, retry, empty success, initial/nonfatal failure, assignment eligibility, browse-mode rejection, duplicate-submit guard, success, and 409-triggered refresh.

```dart
await vm.doIntent(const ChangeDispatcherDriversViewEvent(
  DispatcherDriverViewMode.allDrivers,
));
expect(vm.state.query.view, DispatcherDriverViewMode.allDrivers);
expect(vm.state.query.areaKey, isNull);

await vm.doIntent(AssignRosterDriverEvent(availableDriver));
verify(() => assignUseCase(any())).called(1);
expect(vm.state.assigningDriverId, availableDriver.driverId);
```

- [ ] **Step 2: Define events and immutable state**

Events:

```dart
LoadDispatcherDriversEvent
RetryDispatcherDriversEvent
RefreshDispatcherDriversEvent
ChangeDispatcherDriversViewEvent
ChangeDispatcherDriversAreaEvent
ChangeDispatcherDriversSortEvent
SelectRosterDriverEvent
AssignRosterDriverEvent
ClearDispatcherDriversNoticeEvent
```

State fields include route args, query, nullable roster, selected sort, initial/replacement loading flags, nullable `assigningDriverId`, initial/nonfatal/assignment failures, optional assignment result, `noticeId`, and `hasLoadedOnce`.

- [ ] **Step 3: Implement deterministic roster loading**

Use `_requestGeneration` so slow area/view responses cannot overwrite the latest selection. First load uses route initial area if provided; otherwise make the contract-default By Area request only if backend confirms a default area is allowed. If not, use a separate initial `view=ByArea` request with no area only when backend explicitly supports it. All-mode request clears area query but retains the last selected area in private/UI state for restoring By Area.

- [ ] **Step 4: Implement local stable sorting**

Sort a copied list, never mutate `roster.drivers`. Supported orders are distance ascending, rating descending, and active-load ascending; ties preserve backend order via original index. Sorting never triggers the API.

- [ ] **Step 5: Implement selection/assignment behavior**

In browse mode, emit selected driver intent for the screen callback/navigation without invoking assignment. In assignment mode, reject `isAvailableForSelection == false`, set only that card's loading state, call assignment once, and emit the server result. On typed conflict failure, retain failure, clear loading, then refresh the active roster after the UI has received the failure notice.

- [ ] **Step 6: Run ViewModel tests**

Run: `flutter test test/features/dispatcher/dispatcher_drivers/presentation/manager/dispatcher_drivers_view_model_test.dart`

Expected: PASS with no duplicate assignment calls or stale response emissions.

- [ ] **Step 7: Commit state management**

```bash
git add lib/features/dispatcher/dispatcher_drivers/presentation/manager test/features/dispatcher/dispatcher_drivers/presentation/manager/dispatcher_drivers_view_model_test.dart
git commit -m "feat: manage driver roster and assignment state"
```

### Task 5: Add Shimmer, Empty, Error, Sort, and Network Avatar Presentation

**Files:**
- Create: `lib/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_shimmer.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_content_shimmer.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_empty_state.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_sort_sheet.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_avatar_with_status.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_area_chip.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_area_chips.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_card.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_card_top_row.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_card_metrics_row.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_content_list.dart`
- Test: `test/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_backend_widgets_test.dart`

**Interfaces:**
- Consumes: new domain entities/state.
- Produces: screen-shaped loading, content replacement loading, empty state, three-option sort sheet, and assignment-aware cards.

- [ ] **Step 1: Write failing widget tests**

Verify full/content shimmer uses `ShimmerWidget`, successful empty uses `EmptyStateWidget`, area chips show server names/counts, HTTP avatars use `AppCachedNetworkImage`, three sorts are selectable, unavailable buttons are disabled, and only the submitted driver's button is loading/disabled.

```dart
expect(find.byType(ShimmerWidget), findsWidgets);
expect(find.byType(CircularProgressIndicator), findsNothing);
expect(find.text('السالمية'), findsOneWidget);
expect(find.text('8'), findsWidgets);
expect(find.byType(AppCachedNetworkImage), findsOneWidget);
```

- [ ] **Step 2: Implement loading and empty widgets**

`DispatcherDriversShimmer` mirrors the view switcher, area chips, KPI card, section header, three driver cards, and map button. `DispatcherDriversContentShimmer` mirrors KPI/list cards while view/area data is replacing. Both reuse `ShimmerWidget` and existing spacing/radii. Empty state wraps shared `EmptyStateWidget` with refresh.

- [ ] **Step 3: Bind server area/count data**

Area widgets accept `List<DispatcherDriverAreaEntity>` and select by stable key when available. Show `driverCount` on each chip without deriving it from the returned driver list. Hide the entire bar in All mode at the screen level.

- [ ] **Step 4: Bind driver cards and images**

Render `driverCode`, `fullName`, numeric rating, typed status, active/completed metrics, and server distance text with numeric fallback. Use `AppCachedNetworkImage` in circular shape with the current person fallback. Button enablement is exactly `isAvailableForSelection && !isAssigning`; browse mode may label the action as details/select according to existing localization, while assignment mode uses `+ اختيار`.

- [ ] **Step 5: Implement the sort sheet**

The existing Sort button opens a three-option bottom sheet: nearest distance, highest rating, and least active load. It returns `DispatcherDriverSort`; it has no vehicle option and no guessed backend queries.

- [ ] **Step 6: Run widget tests**

Run: `flutter test test/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_backend_widgets_test.dart`

Expected: PASS.

- [ ] **Step 7: Commit presentation widgets**

```bash
git add lib/features/dispatcher/dispatcher_drivers/presentation/widgets test/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_backend_widgets_test.dart
git commit -m "feat: render backend driver roster states"
```

### Task 6: Connect the Screen, Assignment Success Flow, and Core Errors

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_drivers/presentation/screens/dispatcher_drivers_screen.dart`
- Modify: `lib/config/routing/routing_generator.dart`
- Modify: `lib/features/dispatcher/dispatcher_assign_box/presentation/screens/assign_box_screen.dart`
- Modify: `lib/features/dispatcher/dispatcher_assign_box/domain/fake_data/assign_box_fake_data.dart`
- Test: `test/features/dispatcher/dispatcher_drivers/presentation/dispatcher_drivers_backend_test.dart`
- Modify test: `test/dispatcher_drivers_screen_test.dart`
- Modify test: `test/assign_box_screen_test.dart`

**Interfaces:**
- Consumes: Tasks 1–5.
- Produces: injectable/testable roster screen, typed route parsing, and real `boxId` propagation from Assign Box.

- [ ] **Step 1: Write failing screen integration tests**

Cover initial shimmer/load, initial typed error/retry, ByArea/All requests, area chips hidden in All, replacement shimmer, nonfatal failure with retained roster, empty response, sorting, browse callback, unavailable driver no-op, assignment call/loading/success, and conflict refresh.

```dart
await tester.tap(find.text('كل السائقين'));
verify(() => getRosterUseCase(
  const DispatcherDriversQueryEntity(
    view: DispatcherDriverViewMode.allDrivers,
  ),
)).called(1);
expect(find.byType(DispatcherDriversAreaChips), findsNothing);
```

- [ ] **Step 2: Make the screen ViewModel-driven**

```dart
class DispatcherDriversScreen extends StatefulWidget {
  const DispatcherDriversScreen({
    super.key,
    this.args = const DispatcherDriversRouteArgs.browse(),
    this.viewModel,
    this.onBrowseDriver,
    this.onAssignmentCompleted,
    this.onBack,
    this.onViewOnMap,
  });
}
```

Resolve/close an internally owned injected ViewModel using the established Support/Performance pattern. Remove all `DispatcherDriversFakeData` runtime access, local filtering, local area/view state, and local boolean sorting.

- [ ] **Step 3: Use core errors and shimmer by state**

No roster plus loading → full shimmer. No roster plus failure → `ApiErrorWidget.fromTypedFailure`. Existing roster plus replacement loading → content shimmer. Existing roster plus nonfatal/assignment failure → retain roster and show existing localized error Snackbar. Empty 200 → empty state.

- [ ] **Step 4: Handle assignment success once**

Use `BlocListener.listenWhen` keyed by a monotonically increasing success/notice ID. Show the backend `message`, invoke `onAssignmentCompleted(result)` when injected, and for production return to Orders Queue with a route operation that creates/refetches its current backend state. Do not call both callback and default navigation.

- [ ] **Step 5: Parse typed route arguments and propagate box ID**

`routing_generator.dart` accepts only `DispatcherDriversRouteArgs`, defaulting to browse mode for dashboard access. `AssignBoxScreen._onViewAllDrivers` pushes:

```dart
DispatcherDriversRouteArgs.assignment(boxId: order.boxId)
```

Update fake fixtures with explicit GUIDs for tests only. Never derive `boxId` by stripping `#BX-` from `boxCode`.

- [ ] **Step 6: Run screen/regression tests**

Run:

```bash
flutter test test/features/dispatcher/dispatcher_drivers/presentation/dispatcher_drivers_backend_test.dart
flutter test test/dispatcher_drivers_screen_test.dart
flutter test test/assign_box_screen_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit connected workflow**

```bash
git add lib/features/dispatcher/dispatcher_drivers/presentation/screens/dispatcher_drivers_screen.dart lib/config/routing/routing_generator.dart lib/features/dispatcher/dispatcher_assign_box test/features/dispatcher/dispatcher_drivers/presentation/dispatcher_drivers_backend_test.dart test/dispatcher_drivers_screen_test.dart test/assign_box_screen_test.dart
git commit -m "feat: connect driver roster assignment flow"
```

### Task 7: Add Filter-Aware Live Map Handoff Without Faking Support

**Files:**
- Create: `lib/config/routing/arguments/dispatcher_map_route_arguments.dart`
- Modify: `lib/config/routing/routing_generator.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers/presentation/screens/dispatcher_drivers_screen.dart`
- Modify only after backend confirms Missing Item 4: `lib/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_query_entity.dart`
- Modify only after backend confirms Missing Item 4: `lib/features/dispatcher/dispatcher_map/presentation/manager/dispatcher_map_view_model.dart`
- Modify only after backend confirms Missing Item 4: `lib/features/dispatcher/dispatcher_map/presentation/screens/dispatcher_map_screen.dart`
- Test: `test/features/dispatcher/dispatcher_drivers/presentation/dispatcher_drivers_map_handoff_test.dart`

**Interfaces:**
- Produces: `DispatcherMapRouteArgs(areaKey, areaName)` and a truthful map-filter handoff.

- [ ] **Step 1: Write failing handoff test**

```dart
await tester.tap(find.text('عرض السائقين على الخريطة'));
expect(capturedArgs.areaKey, 'salmiya');
expect(capturedArgs.areaName, 'السالمية');
```

Also verify All mode passes no area filter.

- [ ] **Step 2: Define and pass typed map arguments**

```dart
class DispatcherMapRouteArgs {
  const DispatcherMapRouteArgs({this.areaKey, this.areaName});
  final String? areaKey;
  final String? areaName;
}
```

The roster screen passes selected area only in By Area mode. Tests may inject `onViewOnMap(args)` instead of real navigation.

- [ ] **Step 3: Apply the map filter only against a confirmed contract**

If backend adds `areaKey`, extend the map query/API and ViewModel with that stable key. If backend guarantees `currentZoneKey` on every live driver, filter locally by exact stable key while retaining backend KPI semantics explicitly documented for the filtered set. If neither is confirmed, route to the map unfiltered and present a nonfatal notice that the area filter is unavailable; do not compare localized names or claim preservation.

- [ ] **Step 4: Run handoff and map regression tests**

Run:

```bash
flutter test test/features/dispatcher/dispatcher_drivers/presentation/dispatcher_drivers_map_handoff_test.dart
flutter test test/dispatcher_map_screen_test.dart
flutter test test/features/dispatcher/dispatcher_map
```

Expected: PASS; the test asserts whether filtering is applied or explicitly unavailable according to the confirmed contract.

- [ ] **Step 5: Commit map handoff**

```bash
git add lib/config/routing/arguments/dispatcher_map_route_arguments.dart lib/config/routing/routing_generator.dart lib/features/dispatcher/dispatcher_drivers/presentation/screens/dispatcher_drivers_screen.dart test/features/dispatcher/dispatcher_drivers/presentation/dispatcher_drivers_map_handoff_test.dart
git commit -m "feat: pass roster area to live map"
```

Stage map feature files only when the backend contract supports them and they were actually changed.

### Task 8: Remove Runtime Fake Data, Regenerate, and Verify End to End

**Files:**
- Delete when unused: `lib/features/dispatcher/dispatcher_drivers/domain/fake_data/dispatcher_drivers_fake_data.dart`
- Generated: roster/request/assignment `*.g.dart`, `api_services.g.dart`, and `di.config.dart`
- Existing/new tests from Tasks 1–7

**Interfaces:**
- Consumes: all earlier tasks.
- Produces: generated DI/network bindings and a verified fake-free roster workflow.

- [ ] **Step 1: Find stale fake and old-field usage**

Run:

```bash
rg -n "DispatcherDriversFakeData|\.id\b|\.name\b|currentOrdersCount|_filteredDrivers|_selectedArea|_sortByDistance" lib/features/dispatcher/dispatcher_drivers test/dispatcher_drivers_screen_test.dart test/features/dispatcher/dispatcher_drivers
```

Review every match. Runtime code must use the new IDs/names/state; tests use explicit fixtures.

- [ ] **Step 2: Delete roster fake data only after zero runtime imports**

Remove `dispatcher_drivers_fake_data.dart`. Keep `AssignBoxFakeData` only for the still-fake parent screen fixtures, updated with an explicit test `boxId`; do not use it inside the roster.

- [ ] **Step 3: Regenerate source**

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: JSON, Retrofit, and Injectable generation succeeds. Inspect generated diffs and preserve concurrent Operations Log generation.

- [ ] **Step 4: Format only touched files**

Run `dart format` over the explicit roster, route-argument, minimum assign-box, and test files changed by this plan. Do not bulk-format the dirty repository.

- [ ] **Step 5: Run focused test suite**

```bash
flutter test test/features/dispatcher/dispatcher_drivers
flutter test test/dispatcher_drivers_screen_test.dart
flutter test test/assign_box_screen_test.dart
flutter test test/core/network/api_services_test.dart
```

Expected: all PASS.

- [ ] **Step 6: Run analysis and relevant regressions**

```bash
flutter analyze
flutter test test/dispatcher_map_screen_test.dart
flutter test test/dispatcher_orders_screen_test.dart
flutter test test/features/dispatcher/dispatcher_support
```

Expected: no new roster/assignment errors or warnings and no regressions in shared routes/API/driver models. Document unrelated pre-existing failures without editing their features.

- [ ] **Step 7: Manual acceptance**

With valid Arabic and English `DeliveryManager` sessions:

1. Browse entry loads By Area without a box ID and cannot assign.
2. Assignment entry sends the real GUID `boxId` in roster GET and POST.
3. Initial and view/area replacement loading use the correct shimmer shapes.
4. By Area chips use backend areas/counts; All hides chips.
5. KPI and section title use backend values.
6. All statuses, null avatar, unknown status, and empty driver list render safely.
7. Distance/rating/load sorting is stable and does not refetch.
8. Unavailable drivers cannot submit; available driver submits exactly once.
9. Successful POST displays server message and returns/refetches Orders Queue.
10. Conflict/offline/timeout/401/403/500 use core errors and allow recovery.
11. Map receives area filter only when supported; All opens unfiltered map.
12. Switching locale keeps queries stable and only changes display text.

- [ ] **Step 8: Final diff audit and commit**

```bash
git status --short
git diff --check
git diff --stat
```

Confirm no Operations Log or unrelated dirty files are staged.

```bash
git add lib/core/network lib/core/di/di.config.dart lib/config/routing/arguments lib/config/routing/routing_generator.dart lib/features/dispatcher/dispatcher_drivers lib/features/dispatcher/dispatcher_assign_box test/core/network/api_services_test.dart test/features/dispatcher/dispatcher_drivers test/dispatcher_drivers_screen_test.dart test/assign_box_screen_test.dart
git commit -m "test: verify driver roster assignment integration"
```

## Definition of Done

- Roster runtime has no `DispatcherDriversFakeData` dependency.
- Browse and assignment modes are typed and cannot be confused.
- A real GUID `boxId` flows from the source order to GET and POST; `boxCode` is display-only.
- Both endpoints use shared Retrofit/Dio and full Clean Architecture layers.
- Nullable DTOs map safely and never leak to UI.
- By Area/All, server areas/counts/title, local sorting, eligibility, and network avatars work in Arabic and English.
- Initial/replacement loading uses shimmer and all error/empty states use existing core infrastructure.
- Assignment is duplicate-safe, conflict-aware, and returns to a refreshed queue on success.
- Area-aware map handoff is truthful and never fakes unsupported filtering.
- Focused tests, shared API tests, analysis, and relevant dispatcher regressions pass.
