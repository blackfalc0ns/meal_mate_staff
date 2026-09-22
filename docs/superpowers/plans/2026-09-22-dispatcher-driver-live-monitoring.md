# Dispatcher Driver Live Monitoring Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Connect the existing dispatcher map tab to the real live-monitoring REST snapshot and SignalR contracts, replacing static fake data with Google Maps markers, live movement interpolation, card/marker bi-directional selection synchronization, screen-shaped shimmer, Core error handling, and robust lifecycle and reconnection management.

**Architecture:** UI -> Event -> ViewModel -> UseCase -> Repository -> RemoteDataSource -> ApiServices (REST) & SignalR Hub Client -> Repository Stream -> UseCases -> ViewModel -> State -> UI. Transport abstraction keeps `signalr_netcore` inside the data layer. Presentation owns GoogleMapController and animation controllers; ViewModel owns data, subscriptions, timestamp ordering, and reconciliation policy.

**Tech Stack:** Flutter/Dart, google_maps_flutter, signalr_netcore, flutter_bloc, Dio/Retrofit, json_serializable, get_it, ApiResult/safeApiCall, ShimmerWidget, ApiErrorWidget, EmptyStateWidget.

**Spec:** `docs/superpowers/specs/2026-09-22-dispatcher-driver-live-monitoring-design.md`

## Global Constraints

- Follow `rules/rules_backend.md` strictly.
- UI calls only `viewModel.doIntent(Event)`.
- Response DTO fields are nullable; UI and domain layers never import DTOs.
- Use one immutable `DispatcherMapState` with sentinel-based `copyWith`, sealed Events, `safeApiCall`, typed `Failure`, and constructor injection.
- Realtime events carry ISO-8601 UTC timestamps; discard out-of-order events per driver/category.
- No periodic polling timers. Reconciliations are event-driven (on reconnect, on issue update, on box assigned) and coalesced.
- GoogleMapController is owned and disposed in the presentation layer widget, never stored in the ViewModel or domain.
- Android and iOS Google Maps keys use environment configurations; no secret keys committed.
- Keep REST data visible during all transient network interruptions and reconnect attempts.
- Maintain existing visual roles, layout, headers, KPI row, controls, and bottom carousel without visual redesign.

---

## File Map

### Data Layer
- Create `lib/features/dispatcher/dispatcher_map/data/models/response/dispatcher_live_monitoring_response_dto.dart`
- Create `lib/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_driver_location_event_dto.dart`
- Create `lib/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_driver_status_event_dto.dart`
- Create `lib/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_driver_issue_event_dto.dart`
- Create `lib/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_box_assigned_event_dto.dart`
- Create `lib/features/dispatcher/dispatcher_map/data/data_source/dispatcher_map_hub_client.dart`
- Create `lib/features/dispatcher/dispatcher_map/data/data_source/dispatcher_map_hub_client_impl.dart`
- Create `lib/features/dispatcher/dispatcher_map/data/data_source/dispatcher_map_remote_data_source.dart`
- Create `lib/features/dispatcher/dispatcher_map/data/data_source/dispatcher_map_remote_data_source_impl.dart`
- Create `lib/features/dispatcher/dispatcher_map/data/mapper/dispatcher_map_mapper.dart`
- Create `lib/features/dispatcher/dispatcher_map/data/repo/dispatcher_map_repository_impl.dart`

### Domain Layer
- Create `lib/features/dispatcher/dispatcher_map/domain/entities/dispatcher_live_monitoring_entity.dart`
- Modify/Replace `lib/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_driver_marker_entity.dart` (or create `dispatcher_map_driver_entity.dart`)
- Modify `lib/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_driver_status.dart`
- Modify `lib/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_kpi_entity.dart`
- Create `lib/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_realtime_event.dart`
- Create `lib/features/dispatcher/dispatcher_map/domain/entities/dispatcher_hub_connection_status.dart`
- Create `lib/features/dispatcher/dispatcher_map/domain/repo/dispatcher_map_repository.dart`
- Create `lib/features/dispatcher/dispatcher_map/domain/usecase/get_dispatcher_live_monitoring_usecase.dart`
- Create `lib/features/dispatcher/dispatcher_map/domain/usecase/stream_dispatcher_realtime_events_usecase.dart`
- Create `lib/features/dispatcher/dispatcher_map/domain/usecase/stream_dispatcher_connection_status_usecase.dart`
- Create `lib/features/dispatcher/dispatcher_map/domain/usecase/connect_dispatcher_hub_usecase.dart`
- Create `lib/features/dispatcher/dispatcher_map/domain/usecase/disconnect_dispatcher_hub_usecase.dart`

### Presentation Layer
- Create `lib/features/dispatcher/dispatcher_map/presentation/manager/dispatcher_map_event.dart`
- Create `lib/features/dispatcher/dispatcher_map/presentation/manager/dispatcher_map_state.dart`
- Create `lib/features/dispatcher/dispatcher_map/presentation/manager/dispatcher_map_view_model.dart`
- Create `lib/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_shimmer.dart`
- Create `lib/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_reconnect_banner.dart`
- Create `lib/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_driver_marker_factory.dart`
- Modify `lib/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_background.dart`
- Modify `lib/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_driver_card.dart`
- Modify `lib/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_drivers_carousel.dart`
- Modify `lib/features/dispatcher/dispatcher_map/presentation/screens/dispatcher_map_screen.dart`

### Core & Integration
- Modify `pubspec.yaml` (add `signalr_netcore: ^1.4.4`)
- Modify `lib/core/network/network_constants.dart` (add endpoints)
- Modify `lib/core/network/api_services.dart` (add Retrofit method)
- Modify `lib/core/di/di.dart` (register data source, hub client, repository, use cases, view model)
- Modify `lib/core/app_shell/screens/app_shell_screen.dart` (pass `isActive` to `DispatcherMapScreen`)
- Modify `lib/core/l10n/app_en.arb` and `lib/core/l10n/app_ar.arb` (add localization keys for reconnect banner & empty states)

---

## Task 1: Package setup, Network constants, and Response/Realtime DTOs

**Files:**
- Modify: `pubspec.yaml:58-60`
- Modify: `lib/core/network/network_constants.dart:40-47`
- Modify: `lib/core/network/api_services.dart:130-140`
- Create: `lib/features/dispatcher/dispatcher_map/data/models/response/dispatcher_live_monitoring_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_driver_location_event_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_driver_status_event_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_driver_issue_event_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_box_assigned_event_dto.dart`
- Test: `test/features/dispatcher/dispatcher_map/data/models/dispatcher_map_dto_test.dart`

**Interfaces:**
- Produces: `DispatcherLiveMonitoringResponseDto`, `DispatcherDriverLocationEventDto`, `DispatcherDriverStatusEventDto`, `DispatcherDriverIssueEventDto`, `DispatcherBoxAssignedEventDto`.
- Consumes: `NetworkConstants`, `EndPoints`.

- [ ] **Step 1: Write failing DTO parsing unit tests**
  - Verify deserialization of complete JSON fixture, missing fields, nulls, invalid coordinates, unknown status strings, and ISO timestamp parsing.
- [ ] **Step 2: Run test to verify it fails**
  - Run: `flutter test test/features/dispatcher/dispatcher_map/data/models/dispatcher_map_dto_test.dart`
  - Expected: FAIL with missing classes.
- [ ] **Step 3: Add `signalr_netcore: ^1.4.4` to `pubspec.yaml` and run `flutter pub get`**
- [ ] **Step 4: Add endpoints and DTO classes**
  - In `lib/core/network/network_constants.dart`, add `dispatcherLiveMonitoring` and `dispatcherHub`.
  - In `lib/core/network/api_services.dart`, add `@GET(EndPoints.dispatcherLiveMonitoring)` with optional `restaurantId` and `status` queries.
  - Implement DTO classes with `@JsonSerializable(createToJson: false)` defensively with nullable fields.
- [ ] **Step 5: Run `dart run build_runner build --delete-conflicting-outputs`**
- [ ] **Step 6: Run test to verify it passes**
  - Run: `flutter test test/features/dispatcher/dispatcher_map/data/models/dispatcher_map_dto_test.dart`
  - Expected: PASS
- [ ] **Step 7: Commit**
  - `git commit -m "feat(dispatcher-map): add DTOs and network endpoint for live monitoring"`

---

## Task 2: Domain Entities and Mappers

**Files:**
- Modify/Create: `lib/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_driver_status.dart`
- Modify: `lib/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_kpi_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_driver_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_map/domain/entities/dispatcher_live_monitoring_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_realtime_event.dart`
- Create: `lib/features/dispatcher/dispatcher_map/domain/entities/dispatcher_hub_connection_status.dart`
- Create: `lib/features/dispatcher/dispatcher_map/data/mapper/dispatcher_map_mapper.dart`
- Test: `test/features/dispatcher/dispatcher_map/data/mapper/dispatcher_map_mapper_test.dart`

**Interfaces:**
- Produces: `DispatcherMapDriverEntity`, `DispatcherLiveMonitoringEntity`, `DispatcherMapRealtimeEvent` (subclasses `LocationUpdatedEvent`, `StatusUpdatedEvent`, `IssueUpdatedEvent`, `BoxAssignedEvent`), `DispatcherHubConnectionStatus`.
- Consumes: DTOs from Task 1.

- [ ] **Step 1: Write failing mapper unit tests**
  - Test mapping of snapshot DTO to `DispatcherLiveMonitoringEntity`.
  - Test mapping of unknown status string to `DispatcherMapDriverStatus.unknown`.
  - Test mapping of null coordinates keeping the driver in the list with `hasValidCoordinates == false`.
  - Test mapping of realtime event DTOs to domain event classes.
- [ ] **Step 2: Run test to verify it fails**
  - Run: `flutter test test/features/dispatcher/dispatcher_map/data/mapper/dispatcher_map_mapper_test.dart`
  - Expected: FAIL with missing classes.
- [ ] **Step 3: Implement domain entities and pure mapper extensions**
  - Update `DispatcherMapDriverStatus`: `inDelivery`, `loading`, `paused`, `attentionRequired`, `unknown`.
  - Implement `DispatcherMapDriverEntity` with identity, position, operational state, card data, and helper getters (`hasValidCoordinates`, `latLng`).
  - Implement sealed `DispatcherMapRealtimeEvent` hierarchy.
  - Implement mapper extensions in `dispatcher_map_mapper.dart`.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `flutter test test/features/dispatcher/dispatcher_map/data/mapper/dispatcher_map_mapper_test.dart`
  - Expected: PASS
- [ ] **Step 5: Commit**
  - `git commit -m "feat(dispatcher-map): add domain entities and mappers for live monitoring"`

---

## Task 3: SignalR Hub Client Transport Abstraction & Remote Data Source

**Files:**
- Create: `lib/features/dispatcher/dispatcher_map/data/data_source/dispatcher_map_hub_client.dart`
- Create: `lib/features/dispatcher/dispatcher_map/data/data_source/dispatcher_map_hub_client_impl.dart`
- Create: `lib/features/dispatcher/dispatcher_map/data/data_source/dispatcher_map_remote_data_source.dart`
- Create: `lib/features/dispatcher/dispatcher_map/data/data_source/dispatcher_map_remote_data_source_impl.dart`
- Test: `test/features/dispatcher/dispatcher_map/data/data_source/dispatcher_map_hub_client_test.dart`
- Test: `test/features/dispatcher/dispatcher_map/data/data_source/dispatcher_map_remote_data_source_test.dart`

**Interfaces:**
- Produces: `DispatcherMapHubClient`, `DispatcherMapRemoteDataSource`.
- Consumes: `ApiServices`, `TokenService`, `NetworkConstants`, `signalr_netcore`.

- [ ] **Step 1: Write failing hub client and remote data source tests**
  - Test connection state stream: disconnected -> connecting -> connected -> reconnecting.
  - Test event routing: `driver-location-updated`, `driver-status-updated`, `driver-issue-updated`, `box-assigned`.
  - Test idempotent `connect()` and `disconnect()`: no duplicate handlers or unhandled re-connects.
  - Test access token factory passing the token from `TokenService.getToken()`.
  - Test `getLiveMonitoring()` delegating to `ApiServices`.
- [ ] **Step 2: Run test to verify it fails**
  - Run: `flutter test test/features/dispatcher/dispatcher_map/data/data_source/dispatcher_map_hub_client_test.dart`
  - Expected: FAIL with missing interfaces.
- [ ] **Step 3: Implement `DispatcherMapHubClient` and `DispatcherMapRemoteDataSource`**
  - Wrap `signalr_netcore` in `DispatcherMapHubClientImpl`.
  - Use broadcast stream controllers for events and connection status.
  - On reconnect (`onreconnected`), emit reconnection signal for reconciliation.
  - Build `DispatcherMapRemoteDataSourceImpl` implementing snapshot calls and streaming hub events.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `flutter test test/features/dispatcher/dispatcher_map/data/data_source/dispatcher_map_hub_client_test.dart test/features/dispatcher/dispatcher_map/data/data_source/dispatcher_map_remote_data_source_test.dart`
  - Expected: PASS
- [ ] **Step 5: Commit**
  - `git commit -m "feat(dispatcher-map): implement SignalR hub client transport and remote data source"`

---

## Task 4: Repository and Use Cases

**Files:**
- Create: `lib/features/dispatcher/dispatcher_map/domain/repo/dispatcher_map_repository.dart`
- Create: `lib/features/dispatcher/dispatcher_map/data/repo/dispatcher_map_repository_impl.dart`
- Create: `lib/features/dispatcher/dispatcher_map/domain/usecase/get_dispatcher_live_monitoring_usecase.dart`
- Create: `lib/features/dispatcher/dispatcher_map/domain/usecase/stream_dispatcher_realtime_events_usecase.dart`
- Create: `lib/features/dispatcher/dispatcher_map/domain/usecase/stream_dispatcher_connection_status_usecase.dart`
- Create: `lib/features/dispatcher/dispatcher_map/domain/usecase/connect_dispatcher_hub_usecase.dart`
- Create: `lib/features/dispatcher/dispatcher_map/domain/usecase/disconnect_dispatcher_hub_usecase.dart`
- Test: `test/features/dispatcher/dispatcher_map/data/repo/dispatcher_map_repository_impl_test.dart`
- Test: `test/features/dispatcher/dispatcher_map/domain/usecase/dispatcher_map_usecases_test.dart`

**Interfaces:**
- Produces: `DispatcherMapRepository`, use case classes.
- Consumes: `DispatcherMapRemoteDataSource`, `safeApiCall`, `ApiResult`, domain entities.

- [ ] **Step 1: Write failing repository and use case tests**
  - Test snapshot success returning `ApiResult.success(DispatcherLiveMonitoringEntity)`.
  - Test snapshot Dio exception handled via `safeApiCall` returning `ApiResult.failure(Failure)`.
  - Test event stream mapping DTOs to domain events.
  - Test connect/disconnect delegation.
- [ ] **Step 2: Run test to verify it fails**
  - Run: `flutter test test/features/dispatcher/dispatcher_map/data/repo/dispatcher_map_repository_impl_test.dart`
  - Expected: FAIL.
- [ ] **Step 3: Implement Repository and Use Cases**
  - In `DispatcherMapRepositoryImpl`, wrap `remoteDataSource.getLiveMonitoring()` with `safeApiCall` and map to `DispatcherLiveMonitoringEntity`.
  - Map `remoteDataSource.realtimeEvents` to `Stream<DispatcherMapRealtimeEvent>`.
  - Implement single-responsibility use cases.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `flutter test test/features/dispatcher/dispatcher_map/data/repo/dispatcher_map_repository_impl_test.dart test/features/dispatcher/dispatcher_map/domain/usecase/dispatcher_map_usecases_test.dart`
  - Expected: PASS
- [ ] **Step 5: Commit**
  - `git commit -m "feat(dispatcher-map): implement repository and use cases for live monitoring"`

---

## Task 5: ViewModel, State Management, and Realtime Reconciliation Policy

**Files:**
- Create: `lib/features/dispatcher/dispatcher_map/presentation/manager/dispatcher_map_event.dart`
- Create: `lib/features/dispatcher/dispatcher_map/presentation/manager/dispatcher_map_state.dart`
- Create: `lib/features/dispatcher/dispatcher_map/presentation/manager/dispatcher_map_view_model.dart`
- Test: `test/features/dispatcher/dispatcher_map/presentation/manager/dispatcher_map_view_model_test.dart`

**Interfaces:**
- Produces: `DispatcherMapViewModel`, `DispatcherMapState`, `DispatcherMapEvent`.
- Consumes: Use cases from Task 4.

- [ ] **Step 1: Write comprehensive failing ViewModel unit tests**
  - Initial load emits loading, then success with initial snapshot; starts SignalR hub.
  - Initial load failure emits typed failure without replacing existing data.
  - Driver selection event updates `selectedDriverId`.
  - Location event: updates latitude/longitude/heading/speed/timestamp, preserves non-null zone/distance; rejects out-of-order timestamps; rejects invalid coordinates.
  - Status event: updates operational status, localized texts, colors, issue fields, and entire KPI entity; rejects out-of-order timestamp.
  - Issue event: updates issue fields safely and triggers a coalesced reconciliation.
  - Box assigned event: triggers a coalesced reconciliation.
  - Reconnection event: triggers a coalesced reconciliation.
  - Coalescing: concurrent reconciliation requests result in at most 1 active request + 1 trailing request.
  - Tab deactivation stops hub; tab activation triggers REST reconciliation and resumes hub.
  - App backgrounding stops hub; app resume triggers REST reconciliation and resumes hub if active.
  - ViewModel `close()` cancels subscriptions and disconnects hub cleanly.
- [ ] **Step 2: Run test to verify it fails**
  - Run: `flutter test test/features/dispatcher/dispatcher_map/presentation/manager/dispatcher_map_view_model_test.dart`
  - Expected: FAIL.
- [ ] **Step 3: Implement `DispatcherMapState`, `DispatcherMapEvent`, and `DispatcherMapViewModel`**
  - State uses sentinel-based `copyWith` (`const Object()`).
  - Internal Map<String, DispatcherMapDriverEntity> by driver ID for O(1) update efficiency.
  - Per-driver timestamp maps for independent location and status ordering.
  - Generation counters for REST requests.
  - Coalescing lock boolean and trailing flag for reconciliations.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `flutter test test/features/dispatcher/dispatcher_map/presentation/manager/dispatcher_map_view_model_test.dart`
  - Expected: PASS
- [ ] **Step 5: Commit**
  - `git commit -m "feat(dispatcher-map): implement ViewModel with timestamp ordering and coalesced reconciliation"`

---

## Task 6: Custom Marker Bitmap Factory with Caching and Fallbacks

**Files:**
- Create: `lib/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_driver_marker_factory.dart`
- Modify: `lib/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_marker_item.dart`
- Test: `test/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_driver_marker_factory_test.dart`

**Interfaces:**
- Produces: `DispatcherMapMarkerBitmapFactory.create(BuildContext, DispatcherMapDriverEntity, {required bool isSelected})`.
- Consumes: `DispatcherMapDriverEntity`, `BitmapDescriptor`, `RepaintBoundary`.

- [ ] **Step 1: Write failing marker bitmap factory and marker item tests**
  - Test cache key generation: `id|boxId|status|isSelected|avatarUrl`.
  - Test fallback to default marker or colored asset when avatar resolution fails.
  - Test marker item renders all statuses (`inDelivery`, `loading`, `paused`, `attentionRequired`, `unknown`).
- [ ] **Step 2: Run test to verify it fails**
  - Run: `flutter test test/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_driver_marker_factory_test.dart`
  - Expected: FAIL.
- [ ] **Step 3: Implement `DispatcherMapMarkerBitmapFactory` and update `DispatcherMapMarkerItem`**
  - Support `AppCachedNetworkImage` with fallback placeholder for remote avatars.
  - Convert widget to `BitmapDescriptor` using offscreen `OverlayEntry` and `RenderRepaintBoundary.toImage()`.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `flutter test test/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_driver_marker_factory_test.dart`
  - Expected: PASS
- [ ] **Step 5: Commit**
  - `git commit -m "feat(dispatcher-map): implement custom marker bitmap factory with caching and fallbacks"`

---

## Task 7: Google Map Background, Smooth Driver Movement & Camera Controls

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_background.dart`
- Modify: `lib/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_controls.dart`
- Test: `test/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_background_test.dart`

**Interfaces:**
- Produces: `DispatcherMapBackground` (rendering real `GoogleMap`), `DispatcherMapControls` (connected to zoom in, zoom out, fit-bounds).
- Consumes: `GoogleMap`, `DispatcherMapDriverEntity`, `DispatcherMapMarkerBitmapFactory`.

- [ ] **Step 1: Write failing widget tests for Google Map background and controls**
  - Test Google Map renders with markers for valid drivers.
  - Test drivers with null/invalid coordinates are excluded from markers.
  - Test tapping marker invokes `onSelectDriver(driver)`.
  - Test zoom in, zoom out, and fit-bounds controls invoke callbacks.
- [ ] **Step 2: Run test to verify it fails**
  - Run: `flutter test test/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_background_test.dart`
  - Expected: FAIL.
- [ ] **Step 3: Implement Google Map in `DispatcherMapBackground`**
  - Remove static image asset `AppAssets.dispatcherMapStaticBackground`.
  - Manage markers with smooth coordinate interpolation (animating marker from previous LatLng to target LatLng using a frame-friendly Ticker or fast animation).
  - Reuse cached `BitmapDescriptor` for location-only updates.
  - Implement `fitBounds` with safe padding for header/KPI bar and bottom carousel. Safe for 0, 1, or N markers.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `flutter test test/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_background_test.dart`
  - Expected: PASS
- [ ] **Step 5: Commit**
  - `git commit -m "feat(dispatcher-map): implement Google Map with smooth marker movement and controls"`

---

## Task 8: Shimmer, Reconnect Banner, Driver Card & Carousel Updates

**Files:**
- Create: `lib/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_shimmer.dart`
- Create: `lib/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_reconnect_banner.dart`
- Modify: `lib/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_driver_card.dart`
- Modify: `lib/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_drivers_carousel.dart`
- Modify: `lib/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_kpi_bar.dart`
- Modify: `lib/core/l10n/app_en.arb` and `lib/core/l10n/app_ar.arb`
- Test: `test/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_widgets_test.dart`

**Interfaces:**
- Produces: `DispatcherMapShimmer`, `DispatcherMapReconnectBanner`.
- Updates: `DispatcherMapDriverCard`, `DispatcherMapDriversCarousel`, `DispatcherMapKpiBar`.

- [ ] **Step 1: Write failing widget tests**
  - Test shimmer matches screen shape (header, KPI bar, controls, carousel).
  - Test reconnect banner appears during `reconnecting` or `disconnected` state when data exists.
  - Test driver card renders network avatar safely, unknown status, zone, and remaining distance.
  - Test carousel auto-scrolls to selected card without feedback loop.
- [ ] **Step 2: Run test to verify it fails**
  - Run: `flutter test test/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_widgets_test.dart`
  - Expected: FAIL.
- [ ] **Step 3: Implement widgets and ARB localization strings**
  - Add `mapReconnecting`, `mapOfflineReconnecting`, `mapNoDriversOnline` to ARB files and run `flutter gen-l10n`.
  - Build `DispatcherMapShimmer` using Core `ShimmerWidget`.
  - Build `DispatcherMapReconnectBanner`.
  - Update `DispatcherMapDriverCard` to use `AppCachedNetworkImage` and handle all statuses.
  - Update `DispatcherMapDriversCarousel` with `ScrollController` and animated item scroll.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `flutter test test/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_widgets_test.dart`
  - Expected: PASS
- [ ] **Step 5: Commit**
  - `git commit -m "feat(dispatcher-map): add shimmer, reconnect banner, and updated driver cards"`

---

## Task 9: Dependency Injection & Screen Integration

**Files:**
- Modify: `lib/core/di/di.dart`
- Modify: `lib/features/dispatcher/dispatcher_map/presentation/screens/dispatcher_map_screen.dart`
- Modify: `lib/core/app_shell/screens/app_shell_screen.dart`
- Test: `test/core/di/di_test.dart`
- Test: `test/dispatcher_map_screen_test.dart`

**Interfaces:**
- Connects: DI registration of live monitoring flow, `DispatcherMapScreen` with `DispatcherMapViewModel`, and `AppShellScreen` tab activation.

- [ ] **Step 1: Update DI test and widget test with mock ViewModel**
  - Update `test/core/di/di_test.dart` to verify `DispatcherMapHubClient`, `DispatcherMapRemoteDataSource`, `DispatcherMapRepository`, use cases, and `DispatcherMapViewModel` resolve from GetIt.
  - Update `test/dispatcher_map_screen_test.dart` to test:
    - Shimmer while initial snapshot loads.
    - `ApiErrorWidget` on initial failure + retry action.
    - `EmptyStateWidget` on empty drivers response.
    - Populated map screen with Google Map, KPI bar, controls, and bottom carousel.
    - Card selection animating map camera.
    - Marker selection scrolling carousel to card.
    - Reconnect indicator visible on network drop.
    - RTL and LTR support.
    - Narrow viewport (360x720) without overflow.
- [ ] **Step 2: Run tests to verify they fail**
  - Run: `flutter test test/core/di/di_test.dart test/dispatcher_map_screen_test.dart`
  - Expected: FAIL.
- [ ] **Step 3: Implement DI registration and screen integration**
  - In `lib/core/di/di.dart`, register hub client, remote data source, repository, use cases, and factory ViewModel.
  - In `DispatcherMapScreen`:
    - Add `isActive` parameter (default `true`).
    - Add `WidgetsBindingObserver` for app resume/pause lifecycle.
    - Wrap with `BlocBuilder` / `BlocSelector` for focused rebuilds.
    - Connect selection callbacks between map and carousel with guard flags to prevent feedback loops.
    - Remove all references to `DispatcherMapFakeData`.
  - In `AppShellScreen`, pass `isActive: activeIndex == 2` to `DispatcherMapScreen`.
- [ ] **Step 4: Run tests to verify they pass**
  - Run: `flutter test test/core/di/di_test.dart test/dispatcher_map_screen_test.dart`
  - Expected: PASS
- [ ] **Step 5: Commit**
  - `git commit -m "feat(dispatcher-map): complete screen integration, DI, and lifecycle wiring"`

---

## Task 10: Verification, Full Test Suite, and Static Analysis

**Files:**
- Codebase-wide verification.

- [ ] **Step 1: Verify zero production references to `DispatcherMapFakeData`**
  - Run grep to ensure no production code in `lib/` imports or reads `dispatcher_map_fake_data.dart`.
- [ ] **Step 2: Run code generation**
  - Run: `dart run build_runner build --delete-conflicting-outputs`
- [ ] **Step 3: Run localization generation**
  - Run: `flutter gen-l10n`
- [ ] **Step 4: Format code**
  - Run: `dart format lib test`
- [ ] **Step 5: Run full test suite**
  - Run: `flutter test`
  - Expected: All tests pass (0 failures).
- [ ] **Step 6: Run Flutter analyze**
  - Run: `flutter analyze`
  - Expected: 0 errors, 0 warnings.
- [ ] **Step 7: Final commit**
  - `git commit -m "test(dispatcher-map): verify full test suite and clean static analysis"`

---

## Acceptance Criteria Verification Checklist

- [ ] Map tab contains no production reads of `DispatcherMapFakeData` or static map asset.
- [ ] KPIs, cards, coordinates, statuses, zones and distances originate from REST/SignalR only.
- [ ] Exactly one location handler is active and each server event is applied at most once.
- [ ] Markers move smoothly without resetting camera position or rebuilding the entire screen.
- [ ] Marker and card selection remain synchronized in both directions without feedback loops.
- [ ] Initial loading uses `ShimmerWidget`; typed Core error and empty widgets are reused.
- [ ] Existing content remains visible during refresh, reconnect, and non-initial errors.
- [ ] Reconnect, issue updates, and box assignments reconcile safely without periodic polling or request storms.
- [ ] Leaving the tab, backgrounding the app, logout, and ViewModel disposal do not leak connections, handlers, streams, controllers, or timers.
- [ ] Generated code, focused tests, full test suite, and static analysis pass.
