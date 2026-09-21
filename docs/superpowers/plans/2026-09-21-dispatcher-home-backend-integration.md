# Dispatcher Home Backend Integration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the dispatcher home fake data with the documented overview and live-location APIs, while preserving the existing UI, using the shared error widgets and the existing shimmer primitive.

**Architecture:** Keep the existing clean flow: Retrofit `ApiServices` -> dispatcher-home remote data source -> repository with `safeApiCall` and DTO mappers -> use cases -> one immutable Cubit state -> existing widgets. Treat dashboard overview as required screen data and live locations as an independently retryable Google Maps section so a map failure never removes usable overview data. This phase is REST-only; SignalR is explicitly excluded.

**Tech Stack:** Flutter, Dart 3, Dio, Retrofit, json_serializable, flutter_bloc, get_it/injectable annotations, `ApiResult`, `safeApiCall`, Core error widgets, existing `ShimmerWidget`, `google_maps_flutter`.

**Spec:** `D:/yahya/meal meat/dis/screen-04.01-dispatcher-dashboard.md` (also supplied as `C:/Users/orignal store/.codex/attachments/a66b0c69-9409-48c8-b52c-2243bb4fdf48/pasted-text.txt`)

## Global Constraints

- Preserve the existing dispatcher-home visual design, localization, RTL/LTR behavior, shell navigation, and routes.
- Follow `rules/rules_backend.md`; UI never consumes DTOs and never calls `ApiServices`, a repository, or a use case directly.
- Response DTO fields are nullable and defensive; do not force-unwrap API data.
- Reuse `ApiErrorWidget`, `InlineApiErrorWidget`, `EmptyStateWidget`, and `lib/core/widget/shimmer_widget.dart`; do not create competing generic error/loading frameworks.
- Do not add a shimmer dependency: the project already has `ShimmerWidget` and the backend rules prohibit automatic package additions.
- Do not implement SignalR, WebSockets, or polling in this phase.
- Use `google_maps_flutter` for the embedded interactive map.
- Never commit or place the supplied Google Maps key in Dart source. Load it from ignored Android/iOS configuration and restrict the rotated key to the app identifiers before release.
- Do not modify generated `.g.dart` files manually.
- Preserve the user's unrelated in-progress auth changes shown by `git status`.

## Confirmed Contract Decisions

- Both REST responses are bare JSON exactly as documented, without a response wrapper.
- Values are displayed exactly as returned; the app does not recompute the supplied counts or completion percentage.
- Driver locations come from `GET /api/v1/dispatcher/drivers/live-locations` when the screen loads or refreshes.
- Google Maps is the approved provider.
- SignalR is not part of this implementation.

---

### Task 1: Lock the REST JSON Contract with DTO and Mapper Tests

**Files:**
- Create: `test/features/dispatcher/dispatcher_home/data/dispatcher_home_mapper_test.dart`
- Create: `lib/features/dispatcher/dispatcher_home/data/models/response/dispatcher_dashboard_overview_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_home/data/models/response/dispatcher_live_driver_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_home/data/mapper/dispatcher_home_mapper.dart`
- Create: `lib/features/dispatcher/dispatcher_home/domain/entities/dispatcher_home_overview_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_home/domain/entities/dispatcher_home_alert_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_home/domain/entities/dispatcher_home_area_summary_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_home/domain/entities/dispatcher_home_kpi_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_home/domain/entities/dispatcher_home_map_driver_pin_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_home/domain/entities/dispatcher_home_operations_status_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_home/domain/entities/dispatcher_home_top_driver_entity.dart`

**Interfaces:**
- Produces: `DispatcherDashboardOverviewResponseDto.fromJson`, `DispatcherLiveDriverResponseDto.fromJson`, `DispatcherDashboardOverviewResponseDto.toEntity()`, `DispatcherLiveDriverResponseDto.toEntity()`.
- Produces: `DispatcherHomeOverviewEntity` containing restaurant, greeting, KPI values, operations status, top drivers, regions, and active-issues summary.

- [ ] **Step 1: Write failing mapper tests using the exact supplied JSON keys**

Cover decimal `87.5`, nullable avatars, unknown driver statuses, `percentageChange`, localized issue summaries, live coordinates, plate number, phone, active order, and timestamp. Assert defaults for absent nullable fields and map unknown status to an explicit `unknown` domain value rather than throwing.

```dart
test('maps overview JSON without losing backend values', () {
  final dto = DispatcherDashboardOverviewResponseDto.fromJson(overviewJson);
  final entity = dto.toEntity();

  expect(entity.restaurant.id, '0a40e4ff-72c7-4754-94e3-50b5f505b730');
  expect(entity.operationsStatus.completionRate, 87.5);
  expect(entity.topDrivers.first.completedDeliveriesToday, 14);
  expect(entity.regions.first.percentageChange, 14.5);
  expect(entity.activeIssues.items.last.driverId, 'drv-209');
});

test('maps every documented live driver status', () {
  expect(mapStatus('EnRouteToCustomer'), DispatcherHomePinStatus.enRouteToCustomer);
  expect(mapStatus('InDelivery'), DispatcherHomePinStatus.inDelivery);
  expect(mapStatus('OnBreak'), DispatcherHomePinStatus.onBreak);
  expect(mapStatus('Available'), DispatcherHomePinStatus.available);
  expect(mapStatus('FutureStatus'), DispatcherHomePinStatus.unknown);
});
```

- [ ] **Step 2: Run the mapper test and verify RED**

Run: `flutter test test/features/dispatcher/dispatcher_home/data/dispatcher_home_mapper_test.dart`

Expected: FAIL because the DTOs, aggregate entity, and mapper do not exist.

- [ ] **Step 3: Implement nullable DTOs and focused domain entities**

Keep backend strings in DTOs, then normalize in the mapper. Change `completionRate` from `int` to `double`; retain `percentageChange`; add `completedDeliveriesToday`; replace hard-coded region-name color enum coupling with a presentation-safe index/accent strategy; and model full issue details. Live driver domain data must retain latitude, longitude, heading, speed, phone, plate, order/address, and `updatedAtUtc`.

- [ ] **Step 4: Run mapper tests and verify GREEN**

Run: `flutter test test/features/dispatcher/dispatcher_home/data/dispatcher_home_mapper_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit the contract layer**

```bash
git add lib/features/dispatcher/dispatcher_home/data lib/features/dispatcher/dispatcher_home/domain test/features/dispatcher/dispatcher_home/data
git commit -m "feat: model dispatcher dashboard contracts"
```

### Task 2: Add Both REST Endpoints Through the Full Data and Domain Flow

**Files:**
- Modify: `lib/core/network/network_constants.dart`
- Modify: `lib/core/network/api_services.dart`
- Create: `lib/features/dispatcher/dispatcher_home/data/data_source/dispatcher_home_remote_data_source.dart`
- Create: `lib/features/dispatcher/dispatcher_home/data/data_source/dispatcher_home_remote_data_source_impl.dart`
- Create: `lib/features/dispatcher/dispatcher_home/data/repo/dispatcher_home_repository_impl.dart`
- Create: `lib/features/dispatcher/dispatcher_home/domain/repo/dispatcher_home_repository.dart`
- Create: `lib/features/dispatcher/dispatcher_home/domain/usecase/get_dispatcher_home_overview_usecase.dart`
- Create: `lib/features/dispatcher/dispatcher_home/domain/usecase/get_dispatcher_live_drivers_usecase.dart`
- Create: `test/features/dispatcher/dispatcher_home/data/dispatcher_home_repository_impl_test.dart`

**Interfaces:**
- Produces: `Future<ApiResult<DispatcherHomeOverviewEntity>> getOverview()`.
- Produces: `Future<ApiResult<List<DispatcherHomeMapDriverPinEntity>>> getLiveDrivers()`.

- [ ] **Step 1: Write failing repository tests**

Test successful DTO-to-entity mapping for each request and a thrown `DioException` becoming `ApiErrorResult` through `safeApiCall`. Mock only the remote-data-source boundary.

- [ ] **Step 2: Run repository tests and verify RED**

Run: `flutter test test/features/dispatcher/dispatcher_home/data/dispatcher_home_repository_impl_test.dart`

Expected: FAIL because the repository pipeline does not exist.

- [ ] **Step 3: Add endpoint constants and Retrofit declarations**

```dart
static const String dispatcherDashboardOverview =
    '/api/v1/dispatcher/dashboard/overview';
static const String dispatcherLiveLocations =
    '/api/v1/dispatcher/drivers/live-locations';
```

Declare `@GET` methods returning the exact DTO shapes. Rely on the existing token and language interceptors; do not manually add authorization or `Accept-Language` in the feature.

- [ ] **Step 4: Implement data source, repository, and use cases**

The data source delegates only to `ApiServices`. The repository wraps each operation independently in `safeApiCall`, maps DTOs to domain entities, and returns `ApiResult`. Each use case forwards one repository operation.

- [ ] **Step 5: Run repository tests and verify GREEN**

Run: `flutter test test/features/dispatcher/dispatcher_home/data/dispatcher_home_repository_impl_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit the REST pipeline**

```bash
git add lib/core/network lib/features/dispatcher/dispatcher_home test/features/dispatcher/dispatcher_home/data
git commit -m "feat: add dispatcher home REST pipeline"
```

### Task 3: Orchestrate Required and Partial Data in One ViewModel

**Files:**
- Create: `lib/features/dispatcher/dispatcher_home/presentation/manager/dispatcher_home_event.dart`
- Create: `lib/features/dispatcher/dispatcher_home/presentation/manager/dispatcher_home_state.dart`
- Create: `lib/features/dispatcher/dispatcher_home/presentation/manager/dispatcher_home_view_model.dart`
- Create: `test/features/dispatcher/dispatcher_home/presentation/manager/dispatcher_home_view_model_test.dart`

**Interfaces:**
- Consumes: `GetDispatcherHomeOverviewUseCase`, `GetDispatcherLiveDriversUseCase`.
- Produces events: `DispatcherHomeLoadEvent`, `DispatcherHomeRetryOverviewEvent`, `DispatcherHomeRetryLiveDriversEvent`, `DispatcherHomeRefreshEvent`.
- Produces state fields: `overview`, `liveDrivers`, `isOverviewLoading`, `isLiveDriversLoading`, `overviewFailure`, `liveDriversFailure`, `hasLoadedOnce`.

- [ ] **Step 1: Write failing state-transition tests**

Assert: initial load requests both resources; overview failure with no overview creates a screen-level error; location failure with overview keeps content and exposes only `liveDriversFailure`; refresh keeps stale content visible; retries call only the failed operation; success clears only the matching failure.

- [ ] **Step 2: Run ViewModel tests and verify RED**

Run: `flutter test test/features/dispatcher/dispatcher_home/presentation/manager/dispatcher_home_view_model_test.dart`

Expected: FAIL because manager files do not exist.

- [ ] **Step 3: Implement immutable state, sealed events, and `doIntent`**

Use private handlers. Do not let an older live-location result overwrite a newer one; if requests can overlap, track a monotonically increasing request id in the ViewModel. Keep prior entities during refresh failures.

- [ ] **Step 4: Run ViewModel tests and verify GREEN**

Run: `flutter test test/features/dispatcher/dispatcher_home/presentation/manager/dispatcher_home_view_model_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit state orchestration**

```bash
git add lib/features/dispatcher/dispatcher_home/presentation/manager test/features/dispatcher/dispatcher_home/presentation/manager
git commit -m "feat: manage dispatcher home state"
```

### Task 4: Register Dependencies and Regenerate Code

**Files:**
- Modify: `lib/core/di/di.dart`
- Generated: `lib/core/network/api_services.g.dart`
- Generated: DTO `.g.dart` files under `lib/features/dispatcher/dispatcher_home/data/models/response/`
- Test: `test/features/dispatcher/dispatcher_home/dispatcher_home_di_test.dart`

**Interfaces:**
- Produces: resolvable `DispatcherHomeViewModel` and all underlying dependencies from `getIt`.

- [ ] **Step 1: Write a failing DI resolution test**

```dart
test('resolves DispatcherHomeViewModel from getIt', () async {
  await configureDependencies();
  expect(getIt<DispatcherHomeViewModel>(), isA<DispatcherHomeViewModel>());
});
```

- [ ] **Step 2: Run the DI test and verify RED**

Run: `flutter test test/features/dispatcher/dispatcher_home/dispatcher_home_di_test.dart`

Expected: FAIL because dispatcher-home registrations are absent.

- [ ] **Step 3: Add explicit registrations following the repository's current DI style**

Register data source and repository as lazy singletons, and use cases/ViewModel as factories. Do not migrate unrelated manual DI to generated injectable configuration.

- [ ] **Step 4: Generate Retrofit and JSON code**

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: generation succeeds without conflicts.

- [ ] **Step 5: Run the DI test and verify GREEN**

Run: `flutter test test/features/dispatcher/dispatcher_home/dispatcher_home_di_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit generated integration code**

```bash
git add lib/core/di/di.dart lib/core/network/api_services.g.dart lib/features/dispatcher/dispatcher_home/data/models test/features/dispatcher/dispatcher_home/dispatcher_home_di_test.dart
git commit -m "chore: register dispatcher home dependencies"
```

### Task 5: Add Home-Specific Shimmer Composition and Shared Error Rendering

**Files:**
- Create: `lib/features/dispatcher/dispatcher_home/presentation/widgets/dispatcher_home_shimmer.dart`
- Modify: `lib/features/dispatcher/dispatcher_home/presentation/screens/dispatcher_home_screen.dart`
- Modify: `test/dispatcher_home_screen_test.dart`

**Interfaces:**
- Consumes: the existing `ShimmerWidget` primitive.
- Produces: a skeleton matching header, four KPIs, actions, map, analytics cards, regions, and alert geometry.

- [ ] **Step 1: Write failing widget tests for loading and global errors**

Inject a controllable `DispatcherHomeViewModel`. Assert initial loading renders `DispatcherHomeShimmer` and no fake values. Assert overview failure with no data renders `ApiErrorWidget`, and retry dispatches `DispatcherHomeRetryOverviewEvent`.

- [ ] **Step 2: Run the focused widget tests and verify RED**

Run: `flutter test test/dispatcher_home_screen_test.dart`

Expected: FAIL because the screen still renders fake constructor defaults.

- [ ] **Step 3: Build the shimmer from the shared primitive**

Use `ShimmerWidget` rectangles/circles with the existing spacing and radii. Do not add a package. If true animated shimmer is later required, improve the shared primitive once for the whole app rather than embedding an animation implementation in this feature.

- [ ] **Step 4: Convert the screen to own or accept a ViewModel**

Follow the existing `AccountStatusScreen` pattern: accept an optional ViewModel for tests, otherwise resolve it from `getIt`, dispatch `DispatcherHomeLoadEvent` once in `initState`, close only internally owned instances, and provide it with `BlocProvider.value`.

- [ ] **Step 5: Render global states using Core widgets**

Use `ApiErrorWidget(exception: state.overviewFailure!.exception, onRetry: ...)` because the current Core widget has no `fromTypedFailure` constructor. Do not duplicate error-type switching. A successful-but-null required overview uses `EmptyStateWidget`; refresh failures with existing overview retain content.

- [ ] **Step 6: Run widget tests and verify GREEN**

Run: `flutter test test/dispatcher_home_screen_test.dart`

Expected: PASS for loading, retry, error, Arabic, and English cases.

- [ ] **Step 7: Commit state-aware screen rendering**

```bash
git add lib/features/dispatcher/dispatcher_home/presentation test/dispatcher_home_screen_test.dart
git commit -m "feat: render dispatcher home loading and errors"
```

### Task 6: Bind All Overview Values and Make Widgets Network-Safe

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_home/presentation/screens/dispatcher_home_screen.dart`
- Modify: `lib/features/dispatcher/dispatcher_home/presentation/widgets/dispatcher_home_header.dart`
- Modify: `lib/features/dispatcher/dispatcher_home/presentation/widgets/dispatcher_home_kpi_row.dart`
- Modify: `lib/features/dispatcher/dispatcher_home/presentation/widgets/dispatcher_home_operations_card.dart`
- Modify: `lib/features/dispatcher/dispatcher_home/presentation/widgets/dispatcher_home_drivers_card.dart`
- Modify: `lib/features/dispatcher/dispatcher_home/presentation/widgets/dispatcher_home_areas_card.dart`
- Modify: `lib/features/dispatcher/dispatcher_home/presentation/widgets/dispatcher_home_alert_banner.dart`
- Create: `lib/core/widget/app_network_image.dart` only if no equivalent reusable asset/network image widget is found during execution.
- Modify: `test/dispatcher_home_screen_test.dart`

**Interfaces:**
- Consumes: `DispatcherHomeOverviewEntity`.
- Produces: existing visual widgets populated from API entities, with localized UI labels and backend-provided content values.

- [ ] **Step 1: Add failing content-binding tests**

Assert restaurant/greeting, all KPI numbers, decimal completion rate formatting, top-driver fields, region count/trend/percentage, and alert visibility. Assert alert is hidden when `activeIssues.count == 0` rather than showing a fake banner.

- [ ] **Step 2: Run focused tests and verify RED**

Run: `flutter test test/dispatcher_home_screen_test.dart`

- [ ] **Step 3: Remove fake data from runtime screen construction**

Keep quick-action labels/icons and status labels localized/presentation-owned. Bind backend restaurant/greeting/numbers/names/ratings. Format completion percentage intentionally (`87.5%`, or integer when mathematically whole). Do not carry backend labels into fields that should come from app localization.

- [ ] **Step 4: Support remote avatar URLs with deterministic fallback**

Existing widgets call `Image.asset` for API avatar URLs and will fail. Reuse an existing shared image widget if found; otherwise create a small `AppNetworkImage` that selects asset vs HTTP(S), adds `errorBuilder`, and renders the current driver placeholder.

- [ ] **Step 5: Make regions backend-driven**

Remove the four-name enum dependency. Use list position or a generic accent token cycle, retain `trend` plus `percentageChange`, and cap the compact home row to the intended number of cards without discarding the full entity list from state.

- [ ] **Step 6: Run widget tests and verify GREEN**

Run: `flutter test test/dispatcher_home_screen_test.dart`

Expected: PASS with API-backed entities and no fake defaults.

- [ ] **Step 7: Commit overview binding**

```bash
git add lib/features/dispatcher/dispatcher_home lib/core/widget test/dispatcher_home_screen_test.dart
git commit -m "feat: bind dispatcher dashboard overview"
```

### Task 7: Configure Google Maps Securely

**Files:**
- Modify: `pubspec.yaml`
- Modify: `.gitignore`
- Modify: `android/app/build.gradle.kts`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `ios/Runner/AppDelegate.swift`
- Modify: `ios/Runner/Info.plist`
- Create locally, never commit: Android/iOS secret configuration containing `MAPS_API_KEY`.

**Interfaces:**
- Produces: an initialized `GoogleMap` implementation on Android and iOS without exposing the key in Dart or version control.
- Uses Android application id `com.example.meal_mate_delivery` and iOS bundle id `com.example.mealMateDelivery` unless those placeholder ids are replaced before key restriction.

- [ ] **Step 1: Add the approved map dependency**

Run: `flutter pub add google_maps_flutter`

Review the resulting `pubspec.yaml` and `pubspec.lock`; do not add any second map package.

- [ ] **Step 2: Add ignored platform secret inputs**

Configure Android Gradle to read `MAPS_API_KEY` from `local.properties` and expose it only as a manifest placeholder. Configure iOS to read the key from an ignored xcconfig/Info.plist build setting, then call `GMSServices.provideAPIKey` from `AppDelegate.swift`. Add only example variable names—not the real key—to committed documentation.

- [ ] **Step 3: Register the Android metadata placeholder**

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${MAPS_API_KEY}" />
```

- [ ] **Step 4: Validate platform configuration without printing the key**

Run: `flutter pub get`

Run: `flutter build apk --debug`

On a macOS/iOS-capable environment, also run: `flutter build ios --no-codesign`.

- [ ] **Step 5: Commit only safe configuration**

```bash
git add pubspec.yaml pubspec.lock .gitignore android ios
git commit -m "chore: configure Google Maps securely"
```

### Task 8: Bind Live Locations to an Interactive Google Map

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_home/presentation/widgets/dispatcher_home_map_card.dart`
- Create: `lib/features/dispatcher/dispatcher_home/presentation/widgets/dispatcher_home_driver_marker.dart`
- Create: `lib/features/dispatcher/dispatcher_home/presentation/widgets/dispatcher_home_driver_sheet.dart`
- Create: `lib/features/dispatcher/dispatcher_home/presentation/widgets/dispatcher_home_map_shimmer.dart`
- Modify: `lib/features/dispatcher/dispatcher_home/presentation/screens/dispatcher_home_screen.dart`
- Modify: `test/dispatcher_home_screen_test.dart`

**Interfaces:**
- Consumes: `liveDrivers`, `isLiveDriversLoading`, `liveDriversFailure`.
- Produces: an interactive `GoogleMap` with location loading, partial error retry, empty state, custom driver markers, camera fitting, and driver details.

- [ ] **Step 1: Write failing tests for location section states**

Assert: overview content remains visible while locations load; location failure shows `InlineApiErrorWidget`; location retry dispatches only `DispatcherHomeRetryLiveDriversEvent`; an empty list shows a localized compact empty state; all four backend statuses produce markers; tapping a marker opens the driver sheet.

- [ ] **Step 2: Run tests and verify RED**

Run: `flutter test test/dispatcher_home_screen_test.dart`

- [ ] **Step 3: Replace the static image with `GoogleMap`**

Create markers from backend `latitude`/`longitude`, display `plateNumber`, and map the four documented statuses to green, orange/red, gray, and blue marker treatments. Keep unknown statuses renderable with a neutral fallback. Disable unnecessary map controls inside the compact card while retaining gestures and the existing recenter action.

- [ ] **Step 4: Fit the camera to available drivers**

For one driver, center with a sensible Kuwait-city zoom. For multiple drivers, calculate `LatLngBounds` and call `animateCamera(CameraUpdate.newLatLngBounds(...))` only after map creation. For an empty list, use the default Kuwait camera target and show the empty-state overlay.

- [ ] **Step 5: Add the driver bottom sheet**

Marker taps open a bottom sheet showing avatar, full name, localized status, plate, phone, speed, active order, and customer address. Hide nullable order/address rows when absent. Keep phone calling disabled or presentation-only until the project defines a call-launching dependency.

- [ ] **Step 6: Add partial loading/error/empty rendering**

Use the map shimmer only for this section, `InlineApiErrorWidget` for a failed location request when overview exists, and a compact `EmptyStateWidget` treatment for a successful empty list. Never replace the whole dashboard for this failure.

- [ ] **Step 7: Run widget tests and verify GREEN**

Run: `flutter test test/dispatcher_home_screen_test.dart`

- [ ] **Step 8: Commit Google Maps location binding**

```bash
git add lib/features/dispatcher/dispatcher_home/presentation test/dispatcher_home_screen_test.dart
git commit -m "feat: show dispatcher drivers on Google Maps"
```

### Task 9: Navigation Gaps and Final Verification

**Files:**
- Modify only after destination requirements exist: `lib/config/routing/app_routes.dart`
- Modify only after destination requirements exist: `lib/config/routing/routing_generator.dart`
- Modify: relevant dispatcher-home widget tests.

**Interfaces:**
- Existing supported destinations: orders, support/issues, map, drivers, operations, notifications.
- Missing exact destinations from the spec: dedicated quick assign (`04.03`), reports (`04.06`), and regions breakdown (`04.07`).

- [ ] **Step 1: Keep supported navigation wired to existing routes**

Do not invent screens. Document temporary route mapping if product accepts orders/support/operations as the current destinations.

- [ ] **Step 2: Add routes only when the three missing destination screens are separately specified**

Treat those screens as separate features/plans, not hidden scope inside home backend integration.

- [ ] **Step 3: Format only changed Dart files**

Run: `dart format <changed Dart paths>`

- [ ] **Step 4: Regenerate code from a clean current source state**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 5: Run the focused suite**

Run: `flutter test test/features/dispatcher/dispatcher_home test/dispatcher_home_screen_test.dart`

Expected: all focused tests pass.

- [ ] **Step 6: Run regression tests and analyzer**

Run: `flutter test`

Run: `flutter analyze`

Expected: no failures or newly introduced analyzer issues. Report pre-existing failures separately with exact output.

- [ ] **Step 7: Review the final diff against the spec and backend rules**

Verify no fake data remains in runtime home flow, no API-derived force unwraps exist, no DTO reaches presentation, retry events target only failed operations, and unrelated auth work is untouched.

## Deferred, Explicitly Out of Scope

- SignalR, WebSockets, background refresh, or automatic polling.
- Full-screen driver bottom sheet actions unless their navigation/action contracts are supplied.
- Dedicated `04.03`, `04.06`, and `04.07` screen implementation.
- Notification unread count/status because neither documented REST response contains it.
- Background location behavior and push notifications.
