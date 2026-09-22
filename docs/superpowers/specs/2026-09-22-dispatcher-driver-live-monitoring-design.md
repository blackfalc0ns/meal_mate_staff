# Dispatcher Driver Live Monitoring Design

## Purpose

Connect the existing dispatcher map tab to the real live-monitoring REST and SignalR contracts without redesigning its established interface. The screen must render a real Google Map, backend KPIs, backend driver cards, synchronized marker/card selection, and live driver movement with no production mock data or periodic polling.

## Scope

Included:

- `GET /api/v1/dispatcher/drivers/live-monitoring` as the full snapshot and source of truth.
- Google Maps markers, camera controls, fit-bounds, and card/marker synchronization.
- SignalR connection to `/hubs/dispatcher` and the events `driver-location-updated`, `driver-status-updated`, `driver-issue-updated`, and `box-assigned`.
- Initial screen-shaped shimmer, typed Core errors, successful-empty handling, retry, pull-to-refresh, reconnect indication, and state reconciliation.
- Efficient marker updates, timestamp ordering, lifecycle cleanup, dependency injection, and automated tests.

Excluded:

- Driver navigation or route drawing.
- Dispatcher device location and `myLocationEnabled`.
- Periodic polling.
- Editing backend-owned statuses or issues.
- Production access to staging simulation endpoints.
- Redesigning the current header, KPI row, controls, carousel, bottom navigation, or app shell.

## Confirmed Backend Contract

### Snapshot

- Endpoint: `GET /api/v1/dispatcher/drivers/live-monitoring`.
- Optional query values: `restaurantId` and `status`.
- Canonical status values: `InDelivery`, `Loading`, `Paused`, `AttentionRequired`.
- Authentication and language remain the responsibility of the existing interceptors.
- The successful response is a direct `{kpis, drivers}` payload.
- Response DTO fields are parsed defensively as nullable even when examples show values.

### SignalR

- Official hub path: `/hubs/dispatcher`.
- The access token is supplied through the SignalR client's access-token factory and reaches the WebSocket connection as `access_token`.
- The server derives the restaurant from `mm_restaurant_id` or `restaurant_id` claims and automatically joins `restaurant:{restaurantId}:dispatcher` on initial connection and reconnect.
- The client never invokes `JoinRestaurantDispatcherGroup`.
- `driver-location-updated` is the only location event.
- Events are ephemeral; `onreconnected` must trigger an immediate REST reconciliation.
- Events carry trusted ISO-8601 UTC timestamps. An event older than the last applied timestamp for the same driver/event category is ignored.
- Use the already-declared `signalr_netcore: ^1.4.4` dependency; do not add a second realtime package.
- Build the hub URL from the configured API environment, replacing the HTTP scheme with `ws`/`wss` and appending `/hubs/dispatcher`. Do not hardcode the staging or production host in feature code.

### Event application rules

- `driver-location-updated` updates latitude, longitude, heading, speed, timestamp, and non-null zone/distance fields. A null `locationZone`, `remainingDistanceKm`, or `remainingDistanceText` retains the last snapshot value.
- `driver-status-updated` updates the named driver's operational status, localized status data, issue fields, and the complete KPI object.
- `driver-issue-updated` updates issue information only when it is sufficient to do so safely, then requests one coalesced REST reconciliation because it does not carry the complete operational status/color payload.
- `box-assigned` requests one coalesced REST reconciliation because it does not carry the complete driver card, status, distance, and KPI payload.
- Reconnect requests a REST reconciliation before live processing is considered synchronized.
- Concurrent reconciliation triggers are coalesced so only one request is active, with at most one trailing refresh when another trigger arrives during the request.

## Architecture

Follow `rules/rules_backend.md` exactly:

```text
UI -> Event -> ViewModel -> UseCase -> Repository -> RemoteDataSource
   -> ApiServices -> REST

SignalR Client -> Repository stream -> UseCase -> ViewModel -> State -> UI
```

REST DTOs stay in the data layer. The repository maps them into domain entities and wraps REST calls with `safeApiCall`. SignalR transport payloads are also data-layer DTOs and are mapped before presentation code sees them. The ViewModel owns subscriptions and reconciliation policy; widgets own only visual controllers and camera/scroll effects.

The realtime implementation sits inside the dispatcher-map feature because the contract is feature-specific. A narrow transport abstraction keeps the SignalR package out of the domain and presentation layers and makes connection behavior unit-testable.

## Realtime Stream Implementation Contract

The implementation must use the following concrete boundaries so the transport package does not leak into presentation code.

### Files and responsibilities

```text
lib/features/dispatcher/dispatcher_map/
  data/realtime/
    dispatcher_map_realtime_client.dart
    dispatcher_map_signalr_client.dart
    dispatcher_map_realtime_event_dto.dart
  data/mapper/
    dispatcher_map_realtime_mapper.dart
  domain/entities/
    dispatcher_map_realtime_event.dart
    dispatcher_map_connection_status.dart
  domain/usecase/
    observe_dispatcher_map_updates_usecase.dart
    start_dispatcher_map_updates_usecase.dart
    stop_dispatcher_map_updates_usecase.dart
```

- `DispatcherMapRealtimeClient` is the package-independent data contract.
- `DispatcherMapSignalRClient` is its only production implementation and is the only file allowed to import `signalr_netcore`.
- Realtime DTOs parse the raw `List<Object?>?` SignalR callback arguments defensively.
- The mapper converts realtime DTOs into a sealed domain event hierarchy.
- Start, stop, update stream, and connection-state stream are exposed to the ViewModel through use cases/repository methods; the ViewModel never receives a `HubConnection`.

### Required client interface

```dart
abstract interface class DispatcherMapRealtimeClient {
  Stream<DispatcherMapRealtimeEventDto> get events;
  Stream<DispatcherMapConnectionStatus> get connectionStatuses;

  Future<void> connect();
  Future<void> disconnect();
  Future<void> dispose();
}
```

The production client owns:

- One nullable `HubConnection`.
- One broadcast event controller.
- One broadcast connection-status controller.
- One in-flight connect future to deduplicate concurrent `connect()` calls.
- A disposed flag.
- Exactly one registered handler for each backend event.

The controllers are created once per client instance, are never recreated during reconnect, and close only in `dispose()`. `disconnect()` stops the transport but intentionally keeps the controllers reusable when the user returns to the tab.

### Domain event hierarchy

```dart
sealed class DispatcherMapRealtimeEvent {
  const DispatcherMapRealtimeEvent();
}

final class DriverLocationUpdated extends DispatcherMapRealtimeEvent { /* payload */ }
final class DriverStatusUpdated extends DispatcherMapRealtimeEvent { /* payload */ }
final class DriverIssueUpdated extends DispatcherMapRealtimeEvent { /* payload */ }
final class DriverBoxAssigned extends DispatcherMapRealtimeEvent { /* payload */ }
```

Each concrete event contains the backend fields from the approved contract and a parsed UTC timestamp. Malformed events are dropped and reported through debug-only sanitized logging; they must not terminate the stream. Unknown event names are never subscribed to.

### Handler registration

Register these exact method names once, before `start()`:

```text
driver-location-updated
driver-status-updated
driver-issue-updated
box-assigned
```

Each SignalR callback must:

1. Verify that the argument list contains a first item.
2. Accept a `Map<String, dynamic>` or convert a string-keyed `Map<Object?, Object?>` safely.
3. Parse the matching nullable DTO without force casts or `!` on backend values.
4. Require the identifiers and timestamp needed to apply that event safely.
5. Push a valid DTO to the event controller.
6. Catch parsing errors locally so one bad event does not close the hub or stream.

Handlers are removed before rebuilding or disposing the connection. Repeated `connect()` calls must not register them again.

### Authentication

The hub options use an asynchronous access-token factory that calls `TokenService.getToken()` for every initial connection or reconnect attempt. It must not capture a token once at client construction, because the REST refresh interceptor may rotate the token later.

- Missing/empty token: emit `unauthorized`, do not call `start()`, and let the existing authentication flow handle session expiry.
- Hub `401/403`: emit `unauthorized`, stop reconnect attempts, and never log the token or authenticated URL.
- The feature never appends a restaurant ID to the group name or invokes a group method.

### Connection state machine

Use these app-level states:

```dart
enum DispatcherMapConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  unauthorized,
}
```

Allowed transitions:

| Current | Trigger | Next | Action |
|---|---|---|---|
| disconnected | active tab after snapshot | connecting | Build/register/start once |
| connecting | start succeeds | connected | Begin consuming events |
| connecting | recoverable failure | reconnecting | Keep snapshot, allow configured retry |
| connected | transport reconnecting | reconnecting | Keep snapshot, show compact indicator |
| reconnecting | transport reconnected | connected | Dispatch exactly one REST reconciliation |
| any non-disposed | tab inactive/background/logout | disconnected | Stop hub and cancel ViewModel event subscription |
| any | missing/invalid token | unauthorized | Stop hub and route through existing auth policy |

Use the package's automatic reconnect support with delays equivalent to `2s, 5s, 10s, 30s`; after the last delay, remain disconnected and expose manual retry through the screen. There must never be an application polling timer.

### Connect algorithm

`connect()` is idempotent and must follow this order:

1. Return immediately when disposed, already connected, or already connecting.
2. Reuse the current in-flight connect future when another caller invokes `connect()` concurrently.
3. Read the latest token through the access-token factory.
4. Create the `HubConnection` only when none exists or the previous one was permanently disposed.
5. Attach server-event and connection-lifecycle handlers once.
6. Emit `connecting`.
7. Await `HubConnection.start()`.
8. Emit `connected` only after start succeeds.
9. On recoverable failure, emit `reconnecting`/`disconnected` according to whether automatic reconnect remains active.
10. Clear the in-flight future in `finally`.

REST success is required before the first connection so an incoming event always has a known snapshot to update. If the initial REST load fails, SignalR does not start; Retry repeats REST and then connects.

### Disconnect and dispose algorithms

`disconnect()`:

1. Return if already disconnected or disposed.
2. Await `HubConnection.stop()` once.
3. Emit `disconnected`.
4. Keep the hub object and broadcast controllers available for a later tab reactivation.

`dispose()`:

1. Mark disposed so no later callback can emit.
2. Remove the four server-event handlers and lifecycle callbacks.
3. Stop the hub if needed.
4. Close both broadcast controllers exactly once.
5. Clear connection and in-flight references.

### ViewModel stream ownership

The ViewModel owns two nullable subscriptions: realtime events and connection statuses. `_startRealtime()` must subscribe before calling `connect()` so no connection-state transition is missed. Starting twice first checks the existing subscriptions and cannot create duplicates.

Every domain realtime event is converted into an internal `DispatcherMapEvent` and passed through `doIntent`; the subscription callback must not mutate state directly. `_stopRealtime()` awaits cancellation of both subscriptions and then calls the stop use case. `close()` calls the permanent dispose path rather than fire-and-forget cleanup.

### Tab and application lifecycle wiring

`AppShellScreen` currently uses an `IndexedStack`, so inactive tabs remain mounted and `dispose()` does not run when the user changes tabs. The implementation must therefore make activity explicit:

- Add `isActive` to `DispatcherMapScreen`, defaulting to `true` for the standalone route.
- Construct the shell map page with `isActive: activeIndex == 2`.
- In `didUpdateWidget`, dispatch `DispatcherMapTabActivatedEvent` or `DispatcherMapTabDeactivatedEvent` only when the value changes.
- The screen implements `WidgetsBindingObserver` and dispatches paused/resumed lifecycle events.
- Reconnect only when both `isActive == true` and the app lifecycle is resumed.
- Deactivation/backgrounding stops the stream but preserves the successful snapshot.
- Reactivation/resume first reconciles REST, then reconnects SignalR. Concurrent activation and resume signals are coalesced.

The standalone route starts active, follows app lifecycle, and permanently disposes its internally created ViewModel when popped. An externally injected ViewModel is not closed by the screen.

### Reconciliation coordinator

The ViewModel owns `_isReconciling` and `_reconcileAgain` flags:

1. If reconciliation is requested while idle, set `_isReconciling`, fetch REST, apply the newest successful snapshot, then clear the flag.
2. If requested while active, set `_reconcileAgain = true` and return without starting another request.
3. After the active request finishes, run one trailing reconciliation when `_reconcileAgain` was set, then clear it.
4. Request generations prevent a response started earlier from overwriting a later user refresh.
5. Issue, assignment, reactivation, app resume, and `onreconnected` all use this coordinator.

### Event ordering and merge rules

- Track `lastLocationAtByDriver` and `lastStatusAtByDriver` separately.
- Ignore an event when its timestamp is strictly older than the stored timestamp in its category.
- Equal timestamps are idempotent: applying the same event twice must not change state twice.
- Unknown driver location/status events are ignored and schedule one reconciliation; they never create incomplete driver entities.
- Location events retain old zone/distance fields individually when the corresponding incoming field is null.
- Status events replace the supplied complete KPI object atomically with the driver status update.
- Issue and assignment events do not guess missing card/status fields; they schedule reconciliation.
- A REST snapshot replaces the authoritative driver/KPI collection but preserves the current selected ID if it still exists; otherwise select the first driver with valid coordinates, then the first driver, otherwise null.

### Rapid location update policy

Maintain one pending newest location event per driver. Flush pending changes at most once per 100 milliseconds; a newer event replaces an older pending event for the same driver. This bounds state emissions to ten per second per active burst without adding network polling. Marker animation interpolates for 250 milliseconds toward the latest accepted target and retargets from the currently rendered point if a newer update arrives.

## Domain Model

`DispatcherLiveMonitoringEntity` contains `DispatcherMapKpiEntity` and an immutable list of `DispatcherMapDriverEntity` objects.

Each driver entity keeps:

- IDs and display identity: driver ID/code/name, phone, plate, avatar, box and optional trip ID.
- Position: nullable latitude/longitude, heading, speed and last position timestamp.
- Operational state: typed `DispatcherMapDriverStatus`, backend status text/colors, issue flag/description and last status timestamp.
- Card data: zone and nullable remaining distance/value text.

Unknown statuses map to `unknown`; they never crash parsing. Invalid or absent coordinates keep a driver in the carousel but exclude it from Google Map markers and fit-bounds calculations.

## State Management

Use an immutable `DispatcherMapState` with sentinel-based `copyWith` and these concerns:

- Current monitoring snapshot and selected driver ID.
- Initial, refresh, and reconciliation loading flags.
- Optional typed `Failure`.
- Realtime connection status: disconnected, connecting, connected, reconnecting.
- `hasLoadedOnce`, last successful synchronization time, and whether live data is synchronized.

Events include initial load, refresh, retry, tab activation/deactivation, driver selection, each mapped realtime update, connection-state change, reconnect, and internal reconciliation completion.

Initial load uses a request generation number so stale REST responses cannot overwrite a newer refresh. Location/status timestamps are tracked independently per driver so a late location event does not block a newer status event or vice versa.

## Lifecycle

- Activating the map tab starts initial REST loading. After a successful snapshot, the ViewModel starts SignalR.
- A standalone routed map screen follows the same lifecycle from creation to disposal.
- Deactivating the map tab cancels the event subscription and stops the hub connection while preserving the last state in memory.
- Returning to the tab performs a REST reconciliation and then resumes SignalR.
- App backgrounding stops the connection; app resume reconciles REST and reconnects when the tab is active.
- Logout, ViewModel `close()`, or permanent screen disposal cancels subscriptions, removes handlers, stops the hub, and releases timers.
- `connect()` and `disconnect()` are idempotent. A connection cannot register duplicate handlers.
- Automatic reconnect uses bounded backoff. Existing data remains visible throughout reconnect attempts.

## Google Map and UI Integration

Replace `DispatcherMapBackground`'s static asset implementation with a Google Map while preserving the public visual role of the widget. The Google Map controller is owned and disposed by the screen/map widget, not the ViewModel.

- Selecting a card updates ViewModel selection and animates the map to valid coordinates.
- Selecting a marker updates ViewModel selection and scrolls the carousel to the matching card.
- Programmatic synchronization is guarded to avoid card/marker feedback loops.
- Fit-bounds includes only valid coordinates, applies padding for the top overlay and bottom carousel, and handles zero or one marker safely.
- Custom marker bitmaps use a cache keyed by driver identity plus appearance-affecting fields. Location-only events reuse the bitmap.
- Failed avatar loading produces a deterministic fallback marker.
- Smooth movement interpolates from the rendered coordinate to the newest coordinate. A new event replaces the target without queueing every intermediate frame.

The screen uses focused rebuild boundaries (`BlocSelector` or equivalent selectors), stable driver keys, and `RepaintBoundary` around expensive card/marker rendering. Camera state and map controller are never recreated by realtime state emissions.

## Loading, Empty, and Error States

- Initial loading with no snapshot shows `DispatcherMapShimmer`, composed from the existing Core `ShimmerWidget` and shaped like the header, KPI row, map, controls, and driver cards.
- Initial failure with no snapshot shows the existing `ApiErrorWidget` and retry action.
- A successful response with no drivers shows `EmptyStateWidget`; KPIs may still render if useful to the established layout.
- Refresh or reconciliation retains the current map/cards and shows only a small non-blocking progress state.
- Refresh failure retains data and uses `InlineApiErrorWidget` with retry.
- SignalR interruption retains data and shows a compact reconnecting/offline indicator; it never replaces the screen with a full error.

## Performance and Correctness

- No polling timers.
- Maintain drivers in an ID-keyed structure internally so an event changes one driver rather than rebuilding business state by repeated linear searches.
- Coalesce rapid updates per driver and render only the newest target position within a short frame-friendly window.
- Reject invalid coordinates and out-of-order timestamps.
- Do not regenerate marker icons for position-only updates.
- Do not fit bounds again after every event; fit only initially and on an explicit control action.
- Do not log JWTs or full authenticated hub URLs.
- Keep REST data visible during all transient network operations.

## Google Maps Configuration

Use the installed `google_maps_flutter` dependency. Android and iOS keys must be supplied through the project's environment/build configuration and restricted in Google Cloud by application ID/bundle ID and enabled API. Placeholder or production secrets must not be committed.

Location permissions are not added for this screen because it displays remote driver coordinates and does not request the dispatcher's device location.

## Testing

Tests cover:

- Defensive REST and realtime DTO parsing, unknown enums, null fields, invalid coordinates, and mapper fallbacks.
- Repository success and `safeApiCall` failures.
- Hub authentication callback, handler registration, event parsing, connection states, reconnect, idempotent connect/disconnect, and cleanup.
- ViewModel initial load, retry, refresh retention, event application, timestamp ordering, null-field retention, KPI updates, reconciliation coalescing, tab/app lifecycle and close.
- Shimmer, full error, inline error, empty state, populated content, RTL/LTR, long localized text, and reconnect presentation.
- Marker/card selection synchronization and camera commands through a testable map-controller adapter rather than a native map in widget tests.
- Dependency resolution and regression coverage for the app shell and standalone route.

Staging simulation endpoints may be used for manual QA only. They are not called by production application code.

## Acceptance Criteria

- The map tab contains no production reads of `DispatcherMapFakeData` or the static map asset.
- KPIs, cards, coordinates, statuses, zones and distances originate from REST/SignalR only.
- Exactly one location handler is active and each server event is applied at most once.
- Markers move smoothly without resetting camera position or rebuilding the entire screen.
- Marker and card selection remain synchronized in both directions.
- Initial loading uses `ShimmerWidget`; typed Core error and empty widgets are reused.
- Existing content remains visible during refresh, reconnect and non-initial errors.
- Reconnect, issue updates and box assignments reconcile safely without periodic polling or request storms.
- Leaving the tab, backgrounding the app, logout and ViewModel disposal do not leak connections, handlers, streams, controllers or timers.
- Generated code, focused tests, full test suite and static analysis pass.
