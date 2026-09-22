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
