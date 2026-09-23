# Dispatcher Driver Details Backend and Realtime Integration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the fake `DispatcherDriverDetailsScreen` with the three documented driver APIs, a live mini-map fed by the existing shared SignalR connection, resilient independent section states, external call/SMS/WhatsApp actions, and correct navigation to the map and Box Tracking screens.

**Architecture:** Follow the required feature-based Clean Architecture flow for the three REST resources: `UI -> Event -> ViewModel -> UseCase -> Repository -> RemoteDataSource -> ApiServices`. Load profile/KPIs, active boxes, and current location concurrently and keep their success/error/loading states independent so one endpoint cannot blank the whole page. Reuse and harden the existing singleton dispatcher SignalR infrastructure with reference-counted ownership; Driver Details filters shared events by its `driverId`, patches coordinates locally, and re-fetches authoritative boxes/details when status or assignment events require reconciliation.

**Tech Stack:** Flutter, Dart, `flutter_bloc`, Dio, Retrofit, `json_serializable`, GetIt/Injectable, existing `ApiResult`/`safeApiCall`, `lib/core/errors`, `CustomSnackbar`, `ShimmerWidget`, `google_maps_flutter`, `signalr_netcore`, and `url_launcher`.

**Spec:** `D:/yahya/meal meat/dis_new/screen-04.07-driver-details 11111111111111111111.md`

## Global Constraints

- Follow `rules/rules_backend.md` exactly. Preserve the existing UI and feature architecture; do not bypass ViewModel, UseCase, Repository, RemoteDataSource, mapper, or shared `ApiServices`.
- Use the existing injected Dio, token/language interceptors, `ApiResult`, `safeApiCall`, GetIt/Injectable, and `lib/core/errors`. Do not add another HTTP client.
- Use the existing shared Dispatcher SignalR connection and `EndPoints.dispatcherHub == '/hubs/dispatcher'`, which is one of the two server-supported aliases. Do not connect to both aliases and do not create a second Hub client.
- The route accepts a raw GUID `driverId`. It must not accept a prebuilt `DriverDetailsEntity` and must never fall back to `DriverDetailsFakeData`.
- Response DTO fields and nested fields are nullable/defensive. Never force unwrap backend values.
- DTOs stay in Data; presentation consumes domain entities, state, and events only.
- **Initial loading must use shape-matched shimmer. Never use a full-page `CircularProgressIndicator`, fake content, or an empty white screen.**
- Profile/KPIs/daily summary, Active Boxes, and Current Location each have independent loading, success, failure, retry, and refresh states.
- Keep already loaded sections visible while another section is loading or refreshing. Section refresh must not restore the full-page shimmer.
- Initial profile failure uses `ApiErrorWidget.fromTypedFailure` from `lib/core/errors`, because profile data is necessary for the screen identity/actions.
- Active-box and location failures use an inline typed error widget from `lib/core/errors` with a section retry action.
- Non-fatal refresh/realtime errors preserve loaded data and use `CustomSnackbar.showError` from `lib/core/widget/custom_snak_bar.dart` exactly once per failure notice.
- `CustomSnackbar.showError` is also used if Call, SMS, WhatsApp, or external map launching fails. No raw `ScaffoldMessenger` Snackbar or third-party toast may be introduced.
- There is no internal chat. Do not create chat screens, chat IDs, message endpoints, message repositories, or chat SignalR events.
- Add `url_launcher` once to `pubspec.yaml`; use it only behind a small presentation service so actions are unit-testable.
- The mini-map uses `google_maps_flutter`, renders the driver marker, optional destination marker, and the backend `routePolyline`. Do not call a Directions API.
- Treat `routePolyline` as the documented semicolon-delimited `lat,lng;lat,lng` format. Invalid points are ignored; fewer than two valid points means no route line.
- `latitude/longitude == null` is a valid Offline state, not an API error. Do not create `(0,0)` coordinates.
- Active-box empty response is a valid empty state with `200`, `totalCount: 0`, and `boxes: []`.
- Realtime location events patch only live coordinates/heading/speed/timestamp. They do not overwrite the REST address, destination, or route polyline because those fields are absent from the event.
- On `box-assigned` for the open driver, re-fetch Active Boxes and Details. On `driver-status-updated` for the open driver, patch status text and re-fetch Active Boxes/Details when status or active count changes.
- Because the supplied Hub contract lacks explicit delivered/unassigned events, reconciliation on status/count changes is the supported removal strategy; do not invent event names.
- Navigation from an active box uses its raw GUID `boxId` and opens `AppRoutes.boxTracking` with `BoxTrackingRouteArguments`.
- Open on Map uses a driver-focus route argument and navigates to the existing live map. Do not open an external map for this button.
- Do not manually edit generated `api_services.g.dart`, response `*.g.dart`, localization Dart files, or `di.config.dart`; regenerate them.
- Preserve unrelated dirty-worktree changes.

## Locked Backend Contracts

```http
GET /api/v1/dispatcher/drivers/{driverId}/details
GET /api/v1/dispatcher/drivers/{driverId}/active-boxes
GET /api/v1/dispatcher/drivers/{driverId}/current-location
```

SignalR uses the existing client endpoint:

```text
/hubs/dispatcher
```

The screen consumes only these events:

```text
driver-location-updated
driver-status-updated
box-assigned
```

The supplied wire names must map exactly:

- `speedKmh -> speed`
- `recordedAtUtc -> timestamp`
- `activeBoxesCount -> activeBoxesCount`
- `assignedAtUtc -> timestamp`
- `boxCode -> boxCode`

## Locked User Experience

- On entry, start all three REST calls concurrently and acquire one shared realtime lease.
- The profile skeleton covers avatar/name/contact/status and KPI/daily-summary metrics.
- The boxes skeleton covers the section title and two box rows.
- The location skeleton covers the mini-map and address/status text.
- As each request finishes, replace only that section's shimmer.
- If profile fails initially, show the full typed error body; Retry retries profile and any section still missing.
- If boxes or location fail while profile succeeds, keep the screen usable and show their inline typed error states.
- Pull-to-refresh refetches all three endpoints without hiding successful content.
- SignalR disconnect/reconnect status may show the existing reconnect pattern; REST data remains visible.
- Offline location displays the documented Offline state and a location-only Retry button.
- No active boxes displays the localized empty copy from the spec.
- Missing avatar displays initials derived safely from `fullName`; if no usable name exists, show the existing person placeholder.
- Call opens `tel:<phoneNumber>`.
- The message button offers only SMS and WhatsApp external options. SMS uses `sms:<phoneNumber>`. WhatsApp uses digits-only international format with no leading `+`: `https://wa.me/<digits>` and `LaunchMode.externalApplication`.
- Disable Call/SMS/WhatsApp when the phone is null/blank; do not create malformed URIs.
- Each external-launch failure produces one `CustomSnackbar.showError`.
- Open on Map passes `driverId`; the live map selects/focuses that driver after its snapshot loads.
- Tapping a box passes the untouched backend `boxId`; never derive an ID from `boxCode`.

## File Structure

New Driver Details files are grouped by responsibility:

```text
dispatcher_driver_details/
├── data/
│   ├── data_source/
│   ├── mapper/
│   ├── models/response/
│   └── repo/
├── domain/
│   ├── entities/
│   ├── repo/
│   └── usecase/
└── presentation/
    ├── manager/
    ├── services/
    ├── screens/
    └── widgets/
```

Do not create request DTO folders because all three REST calls are GETs and there is no internal messaging request.

---

### Task 1: Define Backend-Aligned Driver Details Domain Models and Route Arguments

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_driver_details/domain/entities/driver_details_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_driver_details/domain/entities/driver_active_box_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/domain/entities/driver_profile_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/domain/entities/driver_kpis_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/domain/entities/driver_daily_summary_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/domain/entities/driver_current_location_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/domain/entities/driver_details_status.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/domain/entities/driver_location_point_entity.dart`
- Create: `lib/config/routing/arguments/dispatcher_driver_details_route_arguments.dart`
- Modify: `lib/config/routing/arguments/dispatcher_map_route_arguments.dart`
- Test: `test/features/dispatcher/dispatcher_driver_details/domain/driver_details_entities_test.dart`

**Interfaces:**
- Produces: independent domain aggregates for Details, Active Boxes, and Current Location; valid ID-only route arguments; optional driver-focus map argument.
- Consumers: DTO mappers, UseCases, ViewModel, widgets, and routing.

- [ ] **Step 1: Write failing domain tests**

Cover valid/invalid GUID route arguments, exact/unknown status mapping, separate raw `boxId` and `boxCode`, nullable phone/avatar/location/destination, immutable box/route lists, and driver-focus map arguments.

```dart
expect(
  const DispatcherDriverDetailsRouteArgs(driverId: '').isValid,
  isFalse,
);
expect(DriverDetailsStatusX.fromApi('Available'), DriverDetailsStatus.available);
expect(DriverDetailsStatusX.fromApi('new-value'), DriverDetailsStatus.unknown);
expect(
  const DispatcherMapRouteArgs(focusDriverId: driverId).focusDriverId,
  driverId,
);
```

```dart
const DispatcherDriverDetailsRouteArgs({required this.driverId});
```

- [ ] **Step 2: Run the focused test and verify failure**

Run: `flutter test test/features/dispatcher/dispatcher_driver_details/domain/driver_details_entities_test.dart`

Expected: FAIL because the current entity merges fake profile/location/boxes and omits backend IDs/codes/coordinates.

- [ ] **Step 3: Implement the three domain aggregates**

```dart
class DriverDetailsEntity {
  const DriverDetailsEntity({
    required this.driver,
    required this.kpis,
    required this.dailySummary,
  });
  final DriverProfileEntity driver;
  final DriverKpisEntity kpis;
  final DriverDailySummaryEntity dailySummary;
}
```

`DriverProfileEntity` contains `driverId`, `driverCode`, `fullName`, nullable `phoneNumber`/`avatarUrl`, typed `status`, `statusText`, `statusDotColor`, and `lastUpdatedText`.

`DriverActiveBoxEntity` contains `boxId`, `boxCode`, typed/string status data, `statusText`, `statusColor`, `customerName`, `scheduledTimeText`, and `deliveryAddress`. Remove UI asset/image fields not returned by this API.

`DriverCurrentLocationEntity` contains nullable current/destination coordinates, heading, speed, badge/time/address fields, and immutable parsed route points.

- [ ] **Step 4: Run the domain tests**

Run: `flutter test test/features/dispatcher/dispatcher_driver_details/domain/driver_details_entities_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit the domain contract**

```bash
git add lib/features/dispatcher/dispatcher_driver_details/domain/entities lib/config/routing/arguments test/features/dispatcher/dispatcher_driver_details/domain
git commit -m "feat: define driver details domain contracts"
```

### Task 2: Create Nullable REST DTOs and Defensive Mappers

**Files:**
- Create: `lib/features/dispatcher/dispatcher_driver_details/data/models/response/driver_details_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/data/models/response/driver_active_boxes_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/data/models/response/driver_current_location_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/data/mapper/driver_details_mapper.dart`
- Generated: corresponding `*.g.dart` files
- Test: `test/features/dispatcher/dispatcher_driver_details/data/driver_details_dto_mapper_test.dart`

**Interfaces:**
- Consumes: Task 1 entities.
- Produces: `toEntity()` mappings for all three REST responses and `parseRoutePolyline(String?)`.

- [ ] **Step 1: Write failing mapping tests**

Use all three supplied JSON examples. Add cases for missing nested profile/KPIs/summary, `boxes: null`, null box entries, unknown statuses/colors, numeric values arriving as int/double, null current coordinates, null destination, null/invalid polyline, partially invalid polyline, and valid semicolon-separated points.

```dart
final details = DriverDetailsResponseDto.fromJson(detailsJson).toEntity();
expect(details.driver.driverCode, 'DR-1025');
expect(details.kpis.activeBoxesCount, 2);

final location = DriverCurrentLocationResponseDto
    .fromJson(locationJson)
    .toEntity();
expect(location.routePoints, hasLength(2));
expect(location.routePoints.first.latitude, 29.3375);
```

- [ ] **Step 2: Run mapper tests and verify failure**

Run: `flutter test test/features/dispatcher/dispatcher_driver_details/data/driver_details_dto_mapper_test.dart`

Expected: FAIL because DTOs and mappers do not exist.

- [ ] **Step 3: Implement fully nullable DTO trees**

Use `@JsonSerializable(createToJson: false)`. All response fields and nested response objects are nullable. Do not put Flutter/map types in DTOs or Domain.

- [ ] **Step 4: Implement defensive mapping and polyline parsing**

Split the documented polyline by `;`, split each point by `,`, parse with `double.tryParse`, validate latitude `[-90, 90]`, longitude `[-180, 180]`, and discard invalid points. Preserve null coordinates as null. Convert `boxes: null` to an immutable empty list, without generating fake boxes.

- [ ] **Step 5: Generate and run tests**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/dispatcher/dispatcher_driver_details/data/driver_details_dto_mapper_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit REST mapping**

```bash
git add lib/features/dispatcher/dispatcher_driver_details/data/models lib/features/dispatcher/dispatcher_driver_details/data/mapper test/features/dispatcher/dispatcher_driver_details/data
git commit -m "feat: map driver details responses"
```

### Task 3: Wire the Three REST Endpoints Through Clean Architecture

**Files:**
- Modify: `lib/core/network/network_constants.dart`
- Modify: `lib/core/network/api_services.dart`
- Generated: `lib/core/network/api_services.g.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/data/data_source/driver_details_remote_data_source.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/data/data_source/driver_details_remote_data_source_impl.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/domain/repo/driver_details_repository.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/data/repo/driver_details_repository_impl.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/domain/usecase/get_driver_details_usecase.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/domain/usecase/get_driver_active_boxes_usecase.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/domain/usecase/get_driver_current_location_usecase.dart`
- Modify test: `test/core/network/api_services_test.dart`
- Test: `test/features/dispatcher/dispatcher_driver_details/data/driver_details_repository_test.dart`
- Test: `test/features/dispatcher/dispatcher_driver_details/domain/driver_details_usecases_test.dart`

**Interfaces:**
- Produces: three validated UseCases returning existing `ApiResult` wrappers.
- Consumes: Task 2 DTOs/mappers, shared `ApiServices`, and `safeApiCall`.

- [ ] **Step 1: Write failing Retrofit contract tests**

Assert exact GET method/path and GUID substitution for all three endpoints. Assert no feature code supplies auth/language headers manually.

```dart
expect(details.path, '/api/v1/dispatcher/drivers/$driverId/details');
expect(boxes.path, '/api/v1/dispatcher/drivers/$driverId/active-boxes');
expect(location.path, '/api/v1/dispatcher/drivers/$driverId/current-location');
```

- [ ] **Step 2: Add constants and Retrofit declarations**

```dart
static const String dispatcherDriverDetails =
    '/api/v1/dispatcher/drivers/{driverId}/details';
static const String dispatcherDriverActiveBoxes =
    '/api/v1/dispatcher/drivers/{driverId}/active-boxes';
static const String dispatcherDriverCurrentLocation =
    '/api/v1/dispatcher/drivers/{driverId}/current-location';
```

Declare one Retrofit GET method per response DTO with `@Path('driverId')`.

- [ ] **Step 3: Write failing repository and UseCase tests**

Cover success mapping, independent Dio failures through `safeApiCall`, valid empty/offline `200` responses, and local rejection of blank/non-GUID driver IDs without repository calls.

- [ ] **Step 4: Implement DataSource, Repository, and UseCases**

```dart
abstract interface class DriverDetailsRepository {
  Future<ApiResult<DriverDetailsEntity>> getDetails(String driverId);
  Future<ApiResult<List<DriverActiveBoxEntity>>> getActiveBoxes(String driverId);
  Future<ApiResult<DriverCurrentLocationEntity>> getCurrentLocation(String driverId);
}
```

Keep `totalCount` in an `DriverActiveBoxesEntity` aggregate if the UI must display the backend count independently; otherwise derive count from the authoritative mapped list and assert consistency in mapper tests. Repository implementation wraps each remote call separately in `safeApiCall`. Each UseCase validates and trims the same GUID.

- [ ] **Step 5: Generate and run focused tests**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/core/network/api_services_test.dart
flutter test test/features/dispatcher/dispatcher_driver_details/data/driver_details_repository_test.dart
flutter test test/features/dispatcher/dispatcher_driver_details/domain/driver_details_usecases_test.dart
```

Expected: all PASS.

- [ ] **Step 6: Commit the REST pipeline**

```bash
git add lib/core/network lib/features/dispatcher/dispatcher_driver_details/data lib/features/dispatcher/dispatcher_driver_details/domain/repo lib/features/dispatcher/dispatcher_driver_details/domain/usecase test/core/network/api_services_test.dart test/features/dispatcher/dispatcher_driver_details
git commit -m "feat: connect driver details APIs"
```

### Task 4: Align and Safely Share the Existing SignalR Client

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_driver_location_event_dto.dart`
- Modify: `lib/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_driver_status_event_dto.dart`
- Modify: `lib/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_box_assigned_event_dto.dart`
- Modify: `lib/features/dispatcher/dispatcher_map/data/mapper/dispatcher_map_realtime_mapper.dart`
- Modify: `lib/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_realtime_event.dart`
- Modify: `lib/features/dispatcher/dispatcher_map/data/realtime/dispatcher_map_realtime_client.dart`
- Modify: `lib/features/dispatcher/dispatcher_map/data/realtime/dispatcher_map_signalr_client.dart`
- Modify: map start/stop UseCases and ViewModel only as required for lease ownership
- Test: `test/features/dispatcher/dispatcher_map/data/realtime/dispatcher_map_signalr_client_test.dart`
- Test: `test/features/dispatcher/dispatcher_map/data/mapper/dispatcher_map_realtime_mapper_test.dart`
- Test: `test/features/dispatcher/dispatcher_map/presentation/manager/dispatcher_map_view_model_test.dart`

**Interfaces:**
- Produces: one shared Hub connection with balanced `acquire(ownerId)` / `release(ownerId)` semantics and backend-aligned event fields.
- Consumers: existing Map screen and Driver Details ViewModel.

- [ ] **Step 1: Write failing wire-contract tests**

Assert JSON parsing for `speedKmh`, `recordedAtUtc`, `activeBoxesCount`, `boxCode`, and `assignedAtUtc`. Assert both Map and Driver Details owners can acquire the connection, releasing one owner does not disconnect, duplicate acquire is idempotent, and releasing the last owner disconnects.

```dart
await client.acquire('dispatcher-map');
await client.acquire('driver-details:$driverId');
await client.release('driver-details:$driverId');
expect(fakeHub.stopCalls, 0);
await client.release('dispatcher-map');
expect(fakeHub.stopCalls, 1);
```

- [ ] **Step 2: Align event DTO field names**

Use explicit `@JsonKey` aliases where the existing domain terminology differs:

```dart
@JsonKey(name: 'speedKmh') final double? speed;
@JsonKey(name: 'recordedAtUtc') final String? timestamp;
final int? activeBoxesCount;
final String? boxCode;
@JsonKey(name: 'assignedAtUtc') final String? timestamp;
```

Extend `DriverStatusUpdated` with `activeBoxesCount` and `DriverBoxAssigned` with `boxCode` without breaking existing Map consumers.

- [ ] **Step 3: Add reference-counted ownership**

The shared client stores a `Set<String>` of owners. First acquire connects, subsequent unique owners reuse the same connection, release removes only that owner, and only the last release disconnects. Unexpected Hub disconnect/reconnect behavior remains managed by the existing client. `dispose()` is reserved for app/service teardown and clears owners.

- [ ] **Step 4: Migrate Map start/stop to a stable owner ID**

Map uses `dispatcher-map` consistently. Driver Details will use `driver-details:<driverId>`. Do not leave old unowned `connect()/disconnect()` calls that can terminate another screen's subscription.

- [ ] **Step 5: Generate and run realtime regressions**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/dispatcher/dispatcher_map/data/realtime/dispatcher_map_signalr_client_test.dart
flutter test test/features/dispatcher/dispatcher_map/data/mapper/dispatcher_map_realtime_mapper_test.dart
flutter test test/features/dispatcher/dispatcher_map/presentation/manager/dispatcher_map_view_model_test.dart
```

Expected: all PASS, including existing Map behaviors.

- [ ] **Step 6: Commit shared realtime hardening**

```bash
git add lib/features/dispatcher/dispatcher_map test/features/dispatcher/dispatcher_map
git commit -m "fix: share dispatcher realtime connection safely"
```

### Task 5: Add Driver Details Realtime UseCases and ViewModel State Machine

**Files:**
- Create: `lib/features/dispatcher/dispatcher_driver_details/domain/usecase/observe_driver_details_updates_usecase.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/domain/usecase/acquire_driver_details_realtime_usecase.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/domain/usecase/release_driver_details_realtime_usecase.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/presentation/manager/driver_details_event.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/presentation/manager/driver_details_state.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/presentation/manager/driver_details_view_model.dart`
- Test: `test/features/dispatcher/dispatcher_driver_details/presentation/manager/driver_details_view_model_test.dart`

**Interfaces:**
- Consumes: Tasks 3-4 REST/realtime contracts and constructor `driverId`.
- Produces: independent section states, filtered live updates, coalesced reconciliation, and lifecycle-safe realtime ownership.

- [ ] **Step 1: Write failing state-machine tests**

Cover concurrent initial loads, partial success, profile failure, section retry, pull refresh, stale response suppression, filtering events for other drivers, valid location patch, invalid coordinate rejection, status patch, active count change refetch, matching `box-assigned` refetch, coalescing event bursts into one follow-up refetch, reconnect reconciliation, app pause/resume, and balanced acquire/release on close.

```dart
final loadFuture = viewModel.doIntent(const LoadDriverDetailsEvent());
expect(viewModel.state.isProfileLoading, isTrue);
expect(viewModel.state.isBoxesLoading, isTrue);
expect(viewModel.state.isLocationLoading, isTrue);

await viewModel.doIntent(
  RealtimeDriverDetailsEventReceived(
    DriverLocationUpdated(
      driverId: otherDriverId,
      latitude: 29.0,
      longitude: 48.0,
      timestamp: now,
    ),
  ),
);
expect(viewModel.state.location, unchangedLocation);
```

- [ ] **Step 2: Run tests and verify failure**

Run: `flutter test test/features/dispatcher/dispatcher_driver_details/presentation/manager/driver_details_view_model_test.dart`

Expected: FAIL because the ViewModel and UseCases do not exist.

- [ ] **Step 3: Define explicit events and state**

Events include load/retry/refresh, retry-profile, retry-boxes, retry-location, realtime received, connection-status received, lifecycle resumed/paused, and internal reconciliation completion.

State includes separate `details`, `activeBoxes`, `location`; loading flags for each section; initial and non-fatal failures for each; realtime connection status; refresh/reconciliation flags; and a monotonic `noticeId` with `noticeFailure` for one-shot `CustomSnackbar` errors.

- [ ] **Step 4: Implement concurrent loads and partial states**

Start the three UseCases without awaiting one before the next. Each completion updates only its section if its request generation is current. Profile initial failure blocks identity/action UI; box/location errors remain inline. Pull-to-refresh preserves all current data.

- [ ] **Step 5: Implement realtime filtering and reconciliation**

Subscribe once after load begins, filter every event by exact `driverId`, and acquire owner `driver-details:<driverId>`. Apply location events locally after coordinate/timestamp validation. For matching status/assignment events, coalesce bursts: if reconciliation is running, set `reconcileAgain`; run at most one additional pass afterward. Re-fetch Details and Active Boxes, not Current Location, because the event already contains the latest coordinates.

- [ ] **Step 6: Implement lifecycle cleanup**

Cancel stream subscriptions and release the exact owner on `close`. On app pause, release; on resume, re-acquire and reconcile all three endpoints. Never call global `disposeRealtime()` from the screen.

- [ ] **Step 7: Run ViewModel tests**

Run: `flutter test test/features/dispatcher/dispatcher_driver_details/presentation/manager/driver_details_view_model_test.dart`

Expected: PASS.

- [ ] **Step 8: Commit realtime state management**

```bash
git add lib/features/dispatcher/dispatcher_driver_details/domain/usecase lib/features/dispatcher/dispatcher_driver_details/presentation/manager test/features/dispatcher/dispatcher_driver_details/presentation/manager
git commit -m "feat: manage live driver details state"
```

### Task 6: Build Mandatory Section-Matched Shimmers and Resilient Widgets

**Files:**
- Create: `lib/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_shimmer.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_profile_shimmer.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_location_shimmer.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_boxes_shimmer.dart`
- Modify: existing `driver_details_*` presentation widgets to consume backend entities
- Modify: `lib/core/l10n/app_ar.arb`
- Modify: `lib/core/l10n/app_en.arb`
- Generated: localization Dart files
- Test: `test/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_loading_and_empty_states_test.dart`

**Interfaces:**
- Consumes: shared `ShimmerWidget`, Task 1 domain entities, and `lib/core/errors` inline widgets.
- Produces: mandatory initial/section shimmer plus empty/offline/null-safe rendering.

- [ ] **Step 1: Write failing widget tests**

Assert the initial shimmer mirrors profile, four KPIs, location/map, two box rows, daily summary, and actions. Assert section shimmers disappear independently. Test empty boxes copy, offline location with Retry, missing avatar initials, missing phone disabled actions, unknown status/color fallback, zero metrics, long Arabic/English strings, and 320x640 no-overflow.

- [ ] **Step 2: Run tests and verify failure**

Run: `flutter test test/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_loading_and_empty_states_test.dart`

Expected: FAIL because the feature currently renders a complete fake entity and has no section loading/error states.

- [ ] **Step 3: Implement the shimmers with `ShimmerWidget`**

Use shared spacing/radii and match the actual cards. `DriverDetailsShimmer` composes the three section shimmers and KPI/daily placeholders. Do not render business text or fake entities during loading.

- [ ] **Step 4: Adapt existing widgets defensively**

Use `AppCachedNetworkImage` when avatar URL exists and initials/placeholder otherwise. Keep backend display strings for labels/status. Use typed status/color fallbacks for styling. Render inline typed errors with retry callbacks and valid empty/offline states rather than generic exceptions.

- [ ] **Step 5: Add/update localization keys**

Add exact Arabic/English text for no active boxes, offline/unavailable location, retry location, SMS/WhatsApp choice, unable to call, unable to open SMS, unable to open WhatsApp, and invalid phone. Rename old internal-chat-facing text to external message wording.

- [ ] **Step 6: Generate localization and run tests**

```bash
flutter gen-l10n
flutter test test/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_loading_and_empty_states_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit loading/empty UI**

```bash
git add lib/features/dispatcher/dispatcher_driver_details/presentation/widgets lib/core/l10n test/features/dispatcher/dispatcher_driver_details/presentation/widgets
git commit -m "feat: add driver details loading states"
```

### Task 7: Implement the Mini-Map and Backend Polyline

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_location_card.dart`
- Create: `lib/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_mini_map.dart`
- Test: `test/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_mini_map_test.dart`

**Interfaces:**
- Consumes: `DriverCurrentLocationEntity.routePoints` and current/destination coordinates.
- Produces: non-interactive mini-map with driver/destination markers, backend route polyline, safe bounds, and live marker updates.

- [ ] **Step 1: Write failing mini-map tests**

Use `GoogleMapsFlutterPlatform` test doubles or isolate marker/polyline construction into pure helpers. Test driver-only map, driver plus destination, route with two/many points, no polyline with fewer than two points, no map when offline, and updated marker after a realtime location state change.

- [ ] **Step 2: Run tests and verify failure**

Run: `flutter test test/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_mini_map_test.dart`

Expected: FAIL because the current location card is not backed by map coordinates/polyline.

- [ ] **Step 3: Implement pure map presentation helpers**

Convert domain points to `LatLng` in presentation only. Build stable IDs for driver marker, destination marker, and route polyline. Fit camera bounds across all available points with safe padding; use a fixed zoom when only one marker exists.

- [ ] **Step 4: Implement the mini-map widget**

Use `GoogleMap` with unnecessary gestures/controls disabled, preserve the existing visual card, and update marker/polyline sets when state changes. Do not issue network directions requests and do not move Google Maps types into Domain/Data.

- [ ] **Step 5: Run mini-map tests**

Run: `flutter test test/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_mini_map_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit mini-map behavior**

```bash
git add lib/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_location_card.dart lib/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_mini_map.dart test/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_mini_map_test.dart
git commit -m "feat: render live driver mini map"
```

### Task 8: Implement External Call, SMS, and WhatsApp Actions

**Files:**
- Modify: `pubspec.yaml`
- Modify generated lockfile: `pubspec.lock`
- Create: `lib/features/dispatcher/dispatcher_driver_details/presentation/services/driver_contact_launcher.dart`
- Modify: `lib/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_action_buttons.dart`
- Test: `test/features/dispatcher/dispatcher_driver_details/presentation/services/driver_contact_launcher_test.dart`
- Test: `test/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_action_buttons_test.dart`

**Interfaces:**
- Produces: injectable/testable `DriverContactLauncher` for `tel:`, `sms:`, and external WhatsApp URIs.
- Consumes: nullable backend `phoneNumber`; no internal chat service.

- [ ] **Step 1: Write failing URI/action tests**

Test formatted international numbers, spaces/dashes removal, WhatsApp `+` removal, blank/null phone rejection, `canLaunchUrl == false`, launch exception, action-sheet SMS choice, WhatsApp choice, and one callback result per tap.

```dart
expect(
  launcher.whatsAppUri('+965 50 123 4567').toString(),
  'https://wa.me/965501234567',
);
expect(launcher.smsUri('+965501234567').scheme, 'sms');
expect(launcher.phoneUri('+965501234567').scheme, 'tel');
```

- [ ] **Step 2: Add `url_launcher`**

Run: `flutter pub add url_launcher`

Expected: `pubspec.yaml` and `pubspec.lock` update without changing unrelated dependencies.

- [ ] **Step 3: Implement the launcher abstraction**

Wrap `canLaunchUrl`/`launchUrl`, return a typed success/failure value or boolean that presentation can handle, and use `LaunchMode.externalApplication` for WhatsApp. Do not call `url_launcher` directly inside domain, repository, or ViewModel.

- [ ] **Step 4: Implement external messaging choice UI**

Tapping the message button opens the project's shared bottom-sheet/action UI with SMS and WhatsApp choices. There is no internal chat option. Failure callbacks are handled by the screen listener with `CustomSnackbar.showError`.

- [ ] **Step 5: Run action tests**

```bash
flutter test test/features/dispatcher/dispatcher_driver_details/presentation/services/driver_contact_launcher_test.dart
flutter test test/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_action_buttons_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit external contact actions**

```bash
git add pubspec.yaml pubspec.lock lib/features/dispatcher/dispatcher_driver_details/presentation/services lib/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_action_buttons.dart test/features/dispatcher/dispatcher_driver_details/presentation
git commit -m "feat: add driver external contact actions"
```

### Task 9: Connect Screen State, Snackbar Feedback, and ID-Based Routing

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_driver_details/presentation/screens/dispatcher_driver_details_screen.dart`
- Modify: `lib/config/routing/routing_generator.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers/presentation/screens/dispatcher_drivers_screen.dart`
- Modify: `lib/features/dispatcher/dispatcher_driver_performance/presentation/screens/dispatcher_driver_performance_screen.dart`
- Modify: `lib/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_driver_bottom_sheet.dart`
- Modify: `lib/features/dispatcher/dispatcher_map/presentation/screens/dispatcher_map_screen.dart`
- Modify: every caller returned by `rg -n "AppRoutes.dispatcherDriverDetails" lib`
- Modify: `test/features/dispatcher/dispatcher_driver_details/dispatcher_driver_details_screen_test.dart`
- Create: `test/config/routing/dispatcher_driver_details_route_test.dart`
- Modify/create: map focus routing tests

**Interfaces:**
- Consumes: `DispatcherDriverDetailsRouteArgs`, `DispatcherMapRouteArgs`, Driver Details ViewModel, shared error widgets, `CustomSnackbar`, contact launcher, and Box Tracking route args.
- Produces: backend-driven Driver Details screen and correct navigation handoffs.

- [ ] **Step 1: Rewrite screen tests against ViewModel states**

Replace `DriverDetailsFakeData` with explicit backend-domain fixtures/mocked dependencies. Assert mandatory initial shimmer, independent section completion, full profile error, inline boxes/location errors, refresh preserving data, one Snackbar per non-fatal failure, empty/offline states, live location rendering, call/messaging launch failure Snackbar, and no overflow at 320x640.

- [ ] **Step 2: Write routing tests**

Assert Driver Details accepts only a valid `driverId`, rejects missing/invalid arguments with existing invalid-route UI, has no fake fallback, passes `focusDriverId` to Map, and passes raw `boxId` to `BoxTrackingRouteArguments`.

- [ ] **Step 3: Convert the screen to ViewModel-driven rendering**

The constructor accepts `driverId` and optional test seams only. Provide/inject one ViewModel, dispatch initial load once, observe app lifecycle, and render shimmer/error/content by section. Use `RefreshIndicator` without clearing successful data.

- [ ] **Step 4: Wire all feedback through the required Snackbar**

Use only:

```dart
CustomSnackbar.showError(
  context: context,
  message: failure.errorMessage,
);
```

for non-fatal API and external launch failures. Do not show connection churn as repeated toasts; use the existing reconnect visual pattern and only notify on actionable failures.

- [ ] **Step 5: Correct the box navigation bug**

Remove the current `box.boxId.replaceAll('#', '')`. Backend `boxId` is already a GUID. Navigate with:

```dart
BoxTrackingRouteArguments(boxId: box.boxId)
```

- [ ] **Step 6: Implement focused Map navigation**

Navigate with `DispatcherMapRouteArgs(focusDriverId: driverId)`. Update Map routing/screen/ViewModel initialization so the requested driver becomes selected and the camera focuses it after snapshot load; if the driver is absent or coordinates are invalid, keep the map usable and show a single non-fatal `CustomSnackbar.showError`.

- [ ] **Step 7: Migrate all Driver Details callers**

Roster, performance, and map bottom sheet pass `DispatcherDriverDetailsRouteArgs(driverId: driverId)`. No caller constructs a `DriverDetailsEntity` or uses fake details.

- [ ] **Step 8: Run screen/routing/navigation tests**

```bash
flutter test test/features/dispatcher/dispatcher_driver_details/dispatcher_driver_details_screen_test.dart
flutter test test/config/routing/dispatcher_driver_details_route_test.dart
flutter test test/features/dispatcher/dispatcher_map
```

Expected: PASS.

- [ ] **Step 9: Commit the connected screen**

```bash
git add lib/features/dispatcher/dispatcher_driver_details lib/features/dispatcher/dispatcher_drivers lib/features/dispatcher/dispatcher_driver_performance lib/features/dispatcher/dispatcher_map lib/config/routing test/features/dispatcher test/config/routing
git commit -m "feat: connect live driver details screen"
```

### Task 10: Remove Fake Runtime Data and Run Full Verification

**Files:**
- Delete after proving unused: `lib/features/dispatcher/dispatcher_driver_details/domain/fake_data/driver_details_fake_data.dart`
- Modify: tests importing the fake fixture; replace with explicit test builders
- Generated: Retrofit, JSON, DI, and localization files

**Interfaces:**
- Produces: zero fake runtime dependency and a verified REST/realtime integration.

- [ ] **Step 1: Prove fake data and old entity routing are unused**

Run:

```bash
rg -n "DriverDetailsFakeData|defaultDriver|DriverDetailsEntity.*arguments|settings.arguments is DriverDetailsEntity" lib
```

Expected: no production references outside the fake file before deletion.

- [ ] **Step 2: Delete fake data and update test fixtures**

Tests construct explicit entities locally or through test-only builders. Never move fake fixtures back into production code.

- [ ] **Step 3: Regenerate and format**

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
dart format lib/features/dispatcher/dispatcher_driver_details lib/features/dispatcher/dispatcher_map lib/config/routing test/features/dispatcher/dispatcher_driver_details
```

- [ ] **Step 4: Run static analysis and relevant tests**

```bash
flutter analyze
flutter test test/features/dispatcher/dispatcher_driver_details
flutter test test/features/dispatcher/dispatcher_map
flutter test test/core/network/api_services_test.dart
flutter test test/config/routing
```

Expected: no new analyzer errors and all relevant tests PASS.

- [ ] **Step 5: Manual acceptance verification**

Verify Arabic RTL and English LTR, throttled initial loading with visible section shimmer, partial endpoint failures, pull refresh, SignalR live marker movement, reconnect reconciliation, empty boxes, offline driver, destination absent, invalid/missing polyline, missing avatar/phone, call/SMS/WhatsApp, map focus, Box Tracking navigation, lifecycle pause/resume, and 320px width.

- [ ] **Step 6: Audit prohibited implementations and required integrations**

```bash
rg -n "DriverDetailsFakeData|CircularProgressIndicator|Internal Chat|messages$|Timer.periodic" lib/features/dispatcher/dispatcher_driver_details
rg -n "DriverDetailsShimmer|ShimmerWidget|ApiErrorWidget|InlineApiErrorWidget|CustomSnackbar.showError" lib/features/dispatcher/dispatcher_driver_details
rg -n "HubConnectionBuilder" lib/features/dispatcher/dispatcher_driver_details
```

Expected: no fake/internal-chat/polling/new-Hub matches; shimmer, typed errors, and custom Snackbar are present.

- [ ] **Step 7: Commit cleanup**

```bash
git add lib test pubspec.yaml pubspec.lock
git commit -m "test: verify driver details integration"
```

## Definition of Done

- The screen route requires a valid backend GUID `driverId` and never accepts fake/prebuilt screen data.
- All three documented REST endpoints are connected through the required Clean Architecture layers.
- Initial and per-section loading use mandatory shape-matched shimmer.
- Profile failures use `lib/core/errors`; section failures are inline; non-fatal failures use `lib/core/widget/custom_snak_bar.dart`.
- Loaded sections remain visible during other loads, refresh, reconciliation, and reconnect.
- The mini-map renders current/destination markers and the backend polyline without a Directions API.
- Offline, no-destination, no-avatar, zero-performance, and empty-box states follow the backend contract.
- Exactly one shared SignalR connection is used through `/hubs/dispatcher` with safe multi-screen ownership.
- Realtime event wire fields match the backend contract, events are filtered by `driverId`, and stale/invalid location events are ignored.
- Active boxes/details re-fetch is coalesced on relevant status/assignment events.
- There is no internal chat implementation.
- Call, SMS, and WhatsApp use `url_launcher`; failures use `CustomSnackbar.showError`.
- Open on Map focuses the selected driver, and active boxes open Box Tracking using raw GUID `boxId`.
- Production code contains no `DriverDetailsFakeData` reference.
- Generated files are regenerated, not edited manually.
- Focused tests, Map regressions, routing tests, and `flutter analyze` pass.
