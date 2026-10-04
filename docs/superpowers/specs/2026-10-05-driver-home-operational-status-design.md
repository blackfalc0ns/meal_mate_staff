# Driver Home Operational Status — Design Specification

**Date:** 2026-10-05  
**Project:** `D:\projects\meal_mate_delivery`  
**Scope:** Flutter driver application, Driver Home only  
**Backend contract:** “حالة تشغيل السائق — عقد API للموبايل”, approved 2026-10-04

## 1. Objective

Replace the fake, driver-controlled shift flow with a backend-controlled Driver Home flow. The delivery manager controls whether a driver is operational. The driver application only reads that decision, keeps listening for changes, and renders the correct Home state.

The implementation must preserve the existing visual identity and navigation. It must follow `rules/rules_backend.md`, use the existing Core networking and error infrastructure, and use shimmer placeholders for initial loading.

This work does not implement dispatcher shift controls and does not call the dispatcher `PATCH .../shift-status` endpoint.

## 2. Authoritative Behavior

`GET /api/v1/driver/home` is the sole source of display data. `shiftStatus` is the sole source of the top-level Home mode:

| `shiftStatus` | Rendered Home mode |
|---|---|
| `Active` | Active Home |
| `Inactive` | Inactive / disconnected Home |
| Missing, null, or unknown | Inactive / disconnected Home (safe fallback) |

`isAvailable` must never choose between Active and Inactive screens. Within an Active Home only:

- `isAvailable == true` and `currentDeliveryTask == null`: active and available.
- `isAvailable == false` or `currentDeliveryTask != null`: active and busy.

The old `Offline` value is not part of the contract and must not be checked.

The driver must have no Start Shift or End Shift action. Calls to `POST /api/v1/driver/shift/start` and `POST /api/v1/driver/shift/end` must be removed from driver flows.

## 3. Recommended Architecture

Use one unified Driver Home feature and one authoritative ViewModel instead of separate “start work” and “active home” state machines.

```text
DriverHomeScreen
  -> doIntent(Load/Refresh/Resume/Realtime events)
DriverHomeViewModel
  -> GetDriverHomeUseCase
DriverHomeRepository
  -> DriverHomeRemoteDataSource
DriverHomeRemoteDataSourceImpl
  -> ApiServices.getDriverHome()
  -> GET /api/v1/driver/home

DriverHub (existing shared connection)
  -> driver-status-updated notification
  -> ViewModel reload intent
  -> GET /api/v1/driver/home
  -> replace authoritative Home entity
```

The UI renders one of four bodies under the existing driver shell:

1. Initial load: `DriverHomeShimmer`.
2. No data + request failure: Core `ApiErrorWidget`.
3. Loaded Inactive state: inactive content.
4. Loaded Active state: active content, optionally accompanied by a refresh error.

This avoids navigation pushes between 05.01 and 05.02. State changes replace the body in place, so the bottom-navigation stack remains stable and repeated SignalR events cannot create duplicate routes.

## 4. Data Contract and Domain Model

### 4.1 Response DTO

Create a defensive `DriverHomeResponseDto` with nullable fields matching the contract’s camelCase keys exactly:

- `driverId`
- `driverName`
- `driverCode`
- `profileImageUrl`
- `shiftStatus`
- `isAvailable`
- `currentStatusText`
- `nextLocationText`
- `targetProgress`
- `currentDeliveryTask`
- `todaySummary`
- `dailyPerformance`
- `activeSession`
- `unreadNotificationsCount`

Create readable nested response DTOs for:

- target progress
- current delivery task
- today summary
- daily performance
- active session

All response DTO properties, including nested properties, are nullable. Generate JSON code using the project’s existing `json_serializable` approach. Never edit generated `.g.dart` files manually.

No response wrapper is introduced because the contract returns the Home object directly.

### 4.2 Domain entity

Expose a unified `DriverHomeEntity` to Presentation. It contains driver identity, operational status, availability, display text, nullable operational sections, and the unread-notification count.

Use a domain enum such as `DriverShiftStatus.active` and `DriverShiftStatus.inactive`. The mapper normalizes the raw string case-insensitively. Only `Active` becomes `active`; null, `Inactive`, `Offline`, or any unknown value becomes `inactive`. This implements the contract’s safe fallback without leaking raw strings into widgets.

Operational child entities remain nullable where absence has business meaning. In particular, the six operational fields may all be null for Inactive and may individually be null for Active. The mapper must not fabricate an order, location, session, or metrics from empty defaults.

Identity fields are contractually present, but the DTO remains defensive. The mapper may use safe non-crashing display fallbacks for missing identity text while preserving nullable `profileImageUrl`.

### 4.3 Current delivery task

The domain task must support the complete contract:

- `boxId`
- `boxCode`
- `customerName`
- `customerPhone`
- `deliveryAddress`
- `destinationLatitude`
- `destinationLongitude`
- `mealsCount`
- `mealsSummary`
- `deliveryTimeSlot`
- `status`
- `deliveryNotes`

Existing Home entities should be reused or extended where their meaning matches. Obsolete presentation-only fake entities are removed only after every consumer has migrated.

## 5. Backend Integration Flow

Follow the mandatory project chain:

```text
UI
-> DriverHomeEvent through doIntent
-> private DriverHomeViewModel handler
-> GetDriverHomeUseCase
-> DriverHomeRepository
-> DriverHomeRepositoryImpl
-> DriverHomeRemoteDataSource
-> DriverHomeRemoteDataSourceImpl
-> ApiServices
-> Backend
```

The response returns as:

```text
DriverHomeResponseDto
-> mapper
-> DriverHomeEntity
-> ApiResult<DriverHomeEntity>
-> immutable DriverHomeState
-> UI
```

Implementation constraints:

- Add `EndPoints.driverHome = '/api/v1/driver/home'`.
- Add one Retrofit `@GET` method to the existing `ApiServices`.
- Reuse the existing Dio, token interceptor, language interceptor, `safeApiCall`, `ApiResult`, `Failure`, GetIt, and Injectable infrastructure.
- Do not add a package, Dio client, API client, generic result type, or generic base ViewModel.
- Use constructor injection and generated Injectable bindings; do not manually edit generated DI or Retrofit files.
- Replace the fake source only after the real path is fully connected. Do not leave fake and remote sources competing at runtime.

## 6. Presentation State and Events

Use one immutable `DriverHomeState` with `copyWith`. It should contain only required state, including:

- initial/loading indicator
- refresh indicator if visually needed
- success/loaded indicator
- `DriverHomeEntity? home`
- `Failure? failure`
- optional error message if consistent with project state conventions
- realtime connection readiness only if the UI or tests require it

Use a sealed `DriverHomeEvent` hierarchy and a single public `doIntent` entry point. Required intents:

- initial Home load
- explicit retry
- lifecycle resume refresh
- driver-status-updated notification
- SignalR reconnected notification

The ViewModel’s API handlers are private. System callbacks dispatch events; they do not call use cases or repositories directly.

Concurrent reload triggers must be coalesced. If a request is already running, mark that another reload is pending and execute at most one follow-up load after the current request completes. This prevents event storms without losing the latest server state.

When refreshing with existing data:

- keep existing content visible;
- do not return to the full-screen shimmer;
- replace the entity only after a successful response;
- retain existing content when refresh fails.

## 7. Screen Composition

### 7.1 Unified screen

`DriverHomeScreen` owns the ViewModel, lifecycle observation, initial intent, and top-level state rendering. It becomes tab index 0 in `AppShellScreen`.

The shell remains responsible for the shared bottom navigation. Home content must not introduce a second bottom navigation bar. Existing standalone route behavior should be consolidated so `AppRoutes.driverHome` leads to the authoritative Home surface rather than a permanently Active screen.

### 7.2 Inactive content

Transform the current Start Work surface into read-only inactive content:

- display real `driverName`, `driverCode`, and `profileImageUrl` when present;
- display `currentStatusText`, expected as “غير متصل”;
- explain that activation is controlled by the delivery manager;
- keep the approved illustration and existing visual language where applicable;
- do not show operational sections whose values are null;
- do not show a notification count badge;
- do not request location permission;
- do not expose tappable status cards, Start Work buttons, swipes, or callbacks.

Delete obsolete Start Work action widgets and requirement/metric UI only when they have no remaining consumer.

### 7.3 Active content

Preserve the current active Home design and bind it to the unified entity:

- header identity and unread count;
- `currentStatusText`;
- `nextLocationText` when non-null;
- target progress when non-null;
- current-delivery card only when `currentDeliveryTask` exists;
- today summary when non-null;
- daily performance when non-null;
- active-session information when the existing UI has an appropriate surface.

An Active driver without a current task is a valid available state. Missing optional operational sections are omitted, not treated as errors.

Location permission and live-location behavior may start only when the Active data demonstrates that delivery tracking is required. They must not be started merely because the Home screen opened.

## 8. Loading and Error UX

### 8.1 Loading

Create `DriverHomeShimmer` using the existing `lib/core/widget/shimmer_widget.dart`. It should approximate the stable Home layout without embedding fake text or business data.

- Show it only for the initial load when `home == null`.
- Do not show a spinner or blank page in place of the shimmer.
- Do not replace loaded content with shimmer during refresh, SignalR reload, reconnect, or resume.

### 8.2 Errors

Use `lib/core/errors` exactly as required by `rules/rules_backend.md`:

- failure with `home == null`: `ApiErrorWidget.fromTypedFailure`, with Retry dispatching only the Home retry event;
- refresh failure with `home != null`: keep content and show `InlineApiErrorWidget` in a non-destructive location;
- do not duplicate checks for timeout, offline, unauthorized, forbidden, or server errors in the feature;
- do not show raw Dio/backend exceptions;
- do not turn valid nullable operational sections into errors;
- do not use `EmptyStateWidget` for Inactive, because Inactive is valid Home data, not an empty result.

## 9. SignalR and Lifecycle

Reuse the existing authenticated DriverHub connection at `EndPoints.driverHub` rather than creating a second connection to the same hub.

Extend the existing realtime event model/parser/client to recognize `driver-status-updated` with its documented payload. The payload is notification metadata only; Presentation must not patch displayed Home data from it.

On notification:

1. dispatch the realtime reload event;
2. call `GET /api/v1/driver/home` through the normal architecture;
3. render the returned entity.

On a false-to-true SignalR connection transition, dispatch one reconnect reload. `connection-established` confirms readiness but must not set operational status.

The DriverHub connection must remain alive while a valid driver session exists, including on Inactive Home. It must not be owned solely by live-location tracking and must not stop because `isAvailable == false` or because Home renders Inactive.

The existing connection currently serves orders and location behavior. Ownership must therefore avoid one screen stopping a shared connection while another consumer still needs it. The implementation plan must either centralize connection lifetime at the authenticated driver shell/session or introduce safe acquire/release semantics around the existing singleton. A duplicate SignalR client is not permitted.

When the application resumes, `DriverHomeScreen` dispatches a resume refresh. When the screen/ViewModel is disposed, cancel stream subscriptions and lifecycle observers without disposing the application-scoped shared client.

## 10. Navigation and Removal of Self-Shift Management

- Replace `DriverStartWorkScreen` as the hardcoded driver tab-zero page with `DriverHomeScreen`.
- Make direct Home routes resolve to the unified Home screen.
- Remove navigation that pushes Active Home after a local start action.
- Remove `StartDriverShiftUseCase`, `startShift` repository/data-source methods, action callbacks, and their DI registrations after confirming no remaining references.
- Search globally for driver `shift/start`, `shift/end`, `startShift`, Start Work buttons, End Work actions, and raw `Offline` checks.
- Do not remove display-only shift summary functionality unless it is directly tied to a self-ending flow and has no independent consumer.

## 11. Localization and Visual Constraints

All new user-facing strings must be added to the existing ARB/localization system in Arabic and English. No hardcoded screen strings are introduced.

Reuse existing theme colors, typography, spacing constants, directional padding, cached-network-image handling, and shared widgets. Backend integration must not redesign colors, spacing, typography, icons, or navigation.

## 12. Testing Strategy

Use test-driven implementation. Required coverage:

### Data

- DTO decoding for full Inactive response.
- DTO decoding for Active available response.
- DTO decoding for Active busy response and every task field.
- DTO tolerance for omitted/null fields.
- mapper normalization of `Active`, case variants, `Inactive`, null, `Offline`, and unknown values.
- repository success mapping through `safeApiCall`.
- repository typed failure propagation.

### Domain and ViewModel

- initial load success for Inactive.
- initial load success for Active available.
- Active busy remains Active when `isAvailable == false`.
- initial load failure stores typed Failure.
- retry reloads only Home.
- refresh failure retains existing entity.
- driver-status-updated triggers Home reload but does not apply payload values.
- reconnect and resume trigger Home reload.
- simultaneous triggers are coalesced and the latest refresh is not lost.
- stream subscriptions are cancelled on close.

### Realtime

- parser recognizes the exact `driver-status-updated` name and documented fields.
- event handler registration includes the new event.
- token-authenticated shared connection remains usable in Inactive mode.
- reconnect signal produces exactly one Home reload per transition.
- no `JoinDriverGroup` call is required.

### Widgets and navigation

- initial load renders `DriverHomeShimmer`.
- no-data failure renders Core `ApiErrorWidget`; Retry dispatches the correct intent.
- refresh failure keeps content and renders Core `InlineApiErrorWidget`.
- Inactive renders identity/status and no Start Work action or notification badge.
- Active available renders Active Home without an order card.
- Active busy renders the current-order card.
- unknown/missing `shiftStatus` renders Inactive.
- app shell tab zero uses unified Home.
- lifecycle resume dispatches refresh and cleans up its observer.
- Arabic RTL and English LTR smoke tests remain valid.

### Acceptance/integration scenarios

Mirror the backend handoff scenarios:

1. Inactive login shows disconnected Home.
2. Dispatcher activation sends an event; app reloads Home and shows Active.
3. Missed offline event is recovered by reconnect/resume Home fetch.
4. Assigned order keeps Home Active with `isAvailable == false` and shows the task.
5. Dispatcher deactivation after work completion moves the app to Inactive while SignalR stays ready.
6. No Start/End Shift action or obsolete `Offline` check remains.

## 13. Verification and Delivery

Implementation is complete only after:

1. generated JSON, Retrofit, and Injectable files are regenerated;
2. changed Dart files are formatted;
3. focused Driver Home and realtime tests pass;
4. the full Flutter test suite is run, with unrelated pre-existing failures documented;
5. `flutter analyze` has no new implementation-caused issues;
6. global searches confirm no driver self-shift calls and no raw `Offline` routing checks remain;
7. the six backend acceptance scenarios are exercised against the integration environment.

The implementation must preserve the user’s unrelated working-tree changes and must not manually modify generated files.

## 14. Explicit Non-Goals

- Implementing dispatcher shift-status controls.
- Changing backend behavior or error codes.
- Redesigning Home UI.
- Adding a second SignalR connection or another networking/state package.
- Using the realtime payload as authoritative display state.
- Caching Home as a replacement for the required server refresh policy.
- Reworking unrelated orders, map, support, profile, or delivery flows.
