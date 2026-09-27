# Driver Orders List Backend Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Screen 05.05 as the driver's production orders and delivery-task list, backed only by the authenticated active trip, with searchable/filterable route-ordered stops, delivery actions, SignalR updates, Core error states, screen-shaped shimmer, and measured list performance.

**Architecture:** Preserve Feature-Based Clean Architecture and the existing `lib/features/driver/orders` UI where it is reusable, but separate pickup-manifest semantics from delivery-manifest semantics. Data flows through `UI -> Event -> ViewModel -> UseCase -> Repository -> RemoteDataSource -> ApiServices`; REST is authoritative and SignalR patches fresh in-memory state. The ViewModel owns query state, request-generation suppression, realtime subscriptions, and immutable list patching; widgets never parse wire strings or call services directly.

**Tech Stack:** Flutter 3 / Dart 3.12, flutter_bloc, Dio, Retrofit, json_serializable, GetIt, Injectable annotations with existing manual registrations, signalr_netcore, url_launcher, flutter_test.

**Spec:** `D:/yahya/meal meat/newww/screen-05.05-driver-orders-list.md`

## Global Constraints

- Read and follow `rules/rules_backend.md` before every implementation task.
- Preserve the current visual identity, theme tokens, localization, shared bottom navigation, routes, and unrelated pickup/confirmation behavior.
- Keep the existing architecture flow; never call `ApiServices`, SignalR, or URL launchers from widgets.
- Use the existing injected `Dio`, token/language interceptors, `ApiResult`, `safeApiCall`, GetIt container, and `NetworkConstants.baseUrl`.
- Response DTO fields are nullable and defensive; request/query values follow the exact backend contract; never force-unwrap API data.
- Production code must contain zero mock orders, customers, addresses, phones, coordinates, counts, timestamps, or statuses.
- Initial loading uses a screen-shaped shimmer built with the existing `ShimmerWidget`.
- Initial REST failure uses `lib/core/errors/error_widgets/api_error_widget.dart`; action/realtime/refresh failures with usable in-memory content use `InlineApiErrorWidget`; successful empty responses use `EmptyStateWidget` or a feature wrapper around it.
- Preserve usable data during refresh, search, filter, SignalR reconnect, and action failures.
- Do not manually edit generated `*.g.dart` or generated localization files; regenerate them.
- Do not delete the existing pickup-manifest implementation while Screens 06.02-06.05 still consume it.
- Route order is always `sequenceNumber` ascending with `boxId` as a deterministic tie-breaker; search/filter must never silently reorder stops.
- Never expose a customer phone number in logs, analytics, exceptions, or SignalR diagnostics.
- Masked calling is preferred. Direct `tel:` calling is allowed only when the backend explicitly returns a callable number and product policy permits it.
- Do not add SQLite, Hive, SharedPreferences order persistence, offline queues, or background synchronization. If the app loses connectivity after content is loaded, retain the current in-memory state and show an inline Core error; a cold offline launch shows the full-page Core no-internet error.
- Performance budgets: one REST request per settled query, at most one active SignalR connection owner for this screen, no full-list rebuild for a single realtime stop update, search debounce 300 ms, and smooth scrolling for at least 100 stops on a mid-range Android device.
- Existing uncommitted user changes must be preserved; do not overwrite or reformat unrelated files.

---

## Backend Contract Gate

The currently integrated pickup response is insufficient for Screen 05.05. Before Flutter implementation, backend and mobile engineers must lock one authoritative contract. The recommended contract is a dedicated delivery endpoint so pickup fields and delivery fields cannot be confused:

```http
GET /api/v1/driver/orders
  ?statusFilter=All|InProgress|Delivered|Failed
  &search=<optional trimmed text>
```

If backend ownership requires retaining `GET /api/v1/driver/pickup/manifest`, it must return the complete delivery fields below after trip start and preserve the existing pickup consumers. Do not guess aliases or combine two responses client-side without an approved contract.

Required successful response:

```json
{
  "tripId": "7ea85f64-5717-4562-b3fc-2c963f66af10",
  "tripCode": "TRP-48-8752",
  "tripStatus": "InProgress",
  "tripStatusText": "خارج للتوصيل",
  "serverTimeUtc": "2026-09-27T08:10:00Z",
  "counts": {
    "total": 8,
    "inProgress": 2,
    "delivered": 5,
    "failed": 1
  },
  "stops": [
    {
      "tripStopId": "stop-guid",
      "boxId": "box-guid",
      "boxCode": "BX-458622",
      "sequenceNumber": 2,
      "customerName": "محمد علي",
      "deliveryZone": "السالمية",
      "formattedAddress": "السالمية - ق 12، شارع الخليج، م 45",
      "latitude": 29.3375,
      "longitude": 48.0758,
      "mealsCount": 4,
      "mealsSummary": "4 وجبات (غداء عائلي)",
      "deliveryTimeSlot": "09:30 ص",
      "status": "InProgress",
      "statusText": "قيد التوصيل الآن",
      "deliveredAtUtc": null,
      "failureReasonCategory": null,
      "failureReasonText": null,
      "isCurrentStop": true,
      "canCompleteDelivery": true,
      "canNavigate": true,
      "canCallCustomer": true,
      "maskedPhoneNumber": null
    }
  ]
}
```

Backend acceptance requirements:

- Counts are calculated over the full active trip, not only the filtered result.
- Search covers box code, customer name, delivery zone, and formatted address.
- `sequenceNumber`, `formattedAddress`, coordinates, `isCurrentStop`, and action capability flags are server-authoritative.
- No-active-trip is a documented successful empty response (recommended `200` with `tripId: null`, zero counts, and `stops: []`), not fabricated data.
- Stable statuses are documented: `Pending`, `InProgress`, `ArrivedAtCustomer`, `Delivered`, `Failed`, `ReassignmentRequested`; unknown future values remain possible.
- The call-proxy endpoint is confirmed as `GET /api/v1/driver/orders/{boxId}/call-proxy` with a short-lived callable URI/number and expiry, or replaced by one documented canonical route.
- SignalR hub `/hubs/driver` and exact event casing/payloads are verified for `box-delivered`, `delivery-failed`, `driver-arrived-at-customer`, `driver-requested-reassignment`, and `trip-in-transit`.
- SignalR payloads include `eventId` and `occurredAtUtc`; clients can deduplicate and reject stale events.
- Authorization scopes, restaurant/driver ownership checks, `401`, `403`, `404`, and conflict behavior are documented in Swagger.

Stop implementation after Task 1 if these backend requirements are not present in the checked-in Swagger or controller contract.

---

## Planned File Structure

### Create

- `lib/features/driver/orders/data/models/response/driver_delivery_manifest_response_dto.dart`
- `lib/features/driver/orders/data/models/response/driver_call_proxy_response_dto.dart`
- `lib/features/driver/orders/data/models/realtime/driver_orders_realtime_event_dto.dart`
- `lib/features/driver/orders/data/mapper/driver_delivery_manifest_mapper.dart`
- `lib/features/driver/orders/data/data_source/driver_orders_remote_data_source.dart`
- `lib/features/driver/orders/data/data_source/driver_orders_remote_data_source_impl.dart`
- `lib/features/driver/orders/data/realtime/driver_orders_realtime_client.dart`
- `lib/features/driver/orders/data/realtime/driver_orders_signalr_client.dart`
- `lib/features/driver/orders/data/repo/driver_orders_repository_impl.dart`
- `lib/features/driver/orders/domain/entities/driver_delivery_manifest_entity.dart`
- `lib/features/driver/orders/domain/entities/driver_delivery_stop_entity.dart`
- `lib/features/driver/orders/domain/entities/driver_delivery_status.dart`
- `lib/features/driver/orders/domain/entities/driver_orders_filter.dart`
- `lib/features/driver/orders/domain/entities/driver_orders_query_entity.dart`
- `lib/features/driver/orders/domain/entities/driver_orders_realtime_event.dart`
- `lib/features/driver/orders/domain/entities/driver_call_proxy_entity.dart`
- `lib/features/driver/orders/domain/repo/driver_orders_repository.dart`
- `lib/features/driver/orders/domain/usecase/get_driver_orders_usecase.dart`
- `lib/features/driver/orders/domain/usecase/get_driver_call_proxy_usecase.dart`
- `lib/features/driver/orders/domain/usecase/observe_driver_orders_updates_usecase.dart`
- `lib/features/driver/orders/domain/usecase/start_driver_orders_updates_usecase.dart`
- `lib/features/driver/orders/domain/usecase/stop_driver_orders_updates_usecase.dart`
- `lib/features/driver/orders/presentation/manager/driver_orders_event.dart`
- `lib/features/driver/orders/presentation/manager/driver_orders_state.dart`
- `lib/features/driver/orders/presentation/manager/driver_orders_view_model.dart`
- `lib/features/driver/orders/presentation/services/driver_order_action_launcher.dart`
- `lib/features/driver/orders/presentation/screens/driver_orders_screen.dart`
- `lib/features/driver/orders/presentation/widgets/driver_orders_shimmer.dart`
- `lib/features/driver/orders/presentation/widgets/driver_trip_banner.dart`
- `lib/features/driver/orders/presentation/widgets/driver_orders_search_bar.dart`
- `lib/features/driver/orders/presentation/widgets/driver_orders_filter_bar.dart`
- `lib/features/driver/orders/presentation/widgets/driver_order_card.dart`
- `lib/features/driver/orders/presentation/widgets/driver_order_status_badge.dart`
- `lib/features/driver/orders/presentation/widgets/driver_orders_empty_state.dart`
- Focused tests under `test/features/driver/orders/` matching each layer.

### Modify

- `lib/core/network/network_constants.dart`
- `lib/core/network/api_services.dart`
- `lib/core/di/di.dart`
- `lib/config/routing/app_routes.dart`
- `lib/config/routing/routing_generator.dart`
- Driver bottom-navigation destination that currently opens `DriverAssignedBoxesScreen`.
- `lib/core/l10n/app_ar.arb`
- `lib/core/l10n/app_en.arb`
- Generated Retrofit, JSON, and localization files through generators only.

---

### Task 1: Lock the Backend and Wire Contracts

**Files:**
- Inspect: backend Swagger/controller contract for driver orders, call proxy, and `/hubs/driver`
- Create: `docs/contracts/driver-orders-list-contract.md` only if the backend contract is not already checked in
- Test: a contract fixture under `test/features/driver/orders/fixtures/driver_delivery_manifest.json`

**Interfaces:**
- Consumes: the Backend Contract Gate in this plan.
- Produces: one approved REST list route, one call-proxy route, stable status/query values, exact SignalR hub/event payloads, and a representative JSON fixture.

- [ ] **Step 1: Compare Swagger with the required contract**

Record each required route, query, response field, status, capability flag, error code, and realtime payload as present or missing. Do not start DTO work while required fields are absent.

- [ ] **Step 2: Verify ownership and empty-state behavior**

Using an authenticated Driver token in a non-production environment, verify that the endpoint returns only the caller's active trip and that a driver with no active trip receives the documented empty success response.

- [ ] **Step 3: Capture a sanitized contract fixture**

Save a response with at least one `InProgress`, one `Delivered`, one `Failed`, and one unknown status. Replace names, phone data, coordinates, and IDs with synthetic values before committing.

- [ ] **Step 4: Add a contract-gate test**

Write a test that loads the fixture and asserts the exact top-level keys `tripId`, `tripCode`, `tripStatus`, `counts`, and `stops`, plus the stop keys required by the Backend Contract Gate.

- [ ] **Step 5: Run the contract test**

Run: `flutter test test/features/driver/orders/data/driver_orders_contract_test.dart`

Expected: PASS only after the fixture matches the approved backend response.

- [ ] **Step 6: Commit**

```bash
git add docs/contracts test/features/driver/orders/fixtures test/features/driver/orders/data/driver_orders_contract_test.dart
git commit -m "test: lock driver orders delivery contract"
```

---

### Task 2: Model Delivery DTOs, Entities, Statuses, and Queries

**Files:**
- Create the delivery response DTO, call-proxy DTO, domain entities, enums, query entity, and mapper listed above.
- Test: `test/features/driver/orders/data/driver_delivery_manifest_dto_mapper_test.dart`
- Test: `test/features/driver/orders/domain/driver_orders_entities_test.dart`

**Interfaces:**
- `DriverOrdersQueryEntity(search, filter)` with default `search: ''`, `filter: DriverOrdersFilter.all`.
- `DriverOrdersFilter.wireValue`: `All`, `InProgress`, `Delivered`, `Failed`.
- `DriverDeliveryStatus`: `pending`, `inProgress`, `arrivedAtCustomer`, `delivered`, `failed`, `reassignmentRequested`, `unknown`.
- `DriverDeliveryManifestEntity` owns trip metadata, full-trip counts, and immutable `List<DriverDeliveryStopEntity>`.

- [ ] **Step 1: Write failing full and sparse DTO tests**

Parse the Task 1 fixture and a sparse response. Assert nullable fields stay nullable at the DTO boundary, numeric coordinates accept JSON numbers, lists may be absent, and malformed dates do not throw.

- [ ] **Step 2: Write failing mapper and enum tests**

Assert case-insensitive known status mapping, unknown status to `unknown`, non-negative counts, stable sequence sorting, null phone/coordinates preservation, and no fabricated address or customer values.

- [ ] **Step 3: Run RED tests**

Run: `flutter test test/features/driver/orders/data/driver_delivery_manifest_dto_mapper_test.dart test/features/driver/orders/domain/driver_orders_entities_test.dart`

Expected: compilation failures for missing delivery models.

- [ ] **Step 4: Implement JSON-serializable nullable DTOs**

Use `@JsonSerializable(createToJson: false)`. Do not modify the existing pickup DTO to pretend pickup and delivery are the same wire model.

- [ ] **Step 5: Implement domain-safe entities and mapper**

Keep operationally meaningful absence nullable. Add derived getters only for UI decisions: `hasCoordinates`, `isProblem`, `isCompleted`, and `canShowPrimaryActions`.

- [ ] **Step 6: Generate and run GREEN tests**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/driver/orders/data/driver_delivery_manifest_dto_mapper_test.dart test/features/driver/orders/domain/driver_orders_entities_test.dart
```

- [ ] **Step 7: Commit**

```bash
git add lib/features/driver/orders/data/models lib/features/driver/orders/data/mapper lib/features/driver/orders/domain test/features/driver/orders
git commit -m "feat: model driver delivery orders"
```

---

### Task 3: Add REST APIs Through Clean Architecture

**Files:**
- Modify: `lib/core/network/network_constants.dart`
- Modify: `lib/core/network/api_services.dart`
- Create: remote data source, repository contract/implementation, `get_driver_orders_usecase.dart`, and `get_driver_call_proxy_usecase.dart`.
- Test: `test/features/driver/orders/data/driver_orders_remote_data_source_test.dart`
- Test: `test/features/driver/orders/data/driver_orders_repository_test.dart`
- Test: `test/features/driver/orders/domain/driver_orders_usecases_test.dart`

**Interfaces:**
- `ApiServices.getDriverOrders({String statusFilter, String? search})`.
- `ApiServices.getDriverCallProxy(String boxId)`.
- `GetDriverOrdersUseCase.call(DriverOrdersQueryEntity query) -> Future<ApiResult<DriverDeliveryManifestEntity>>`.
- `GetDriverCallProxyUseCase.call(String boxId) -> Future<ApiResult<DriverCallProxyEntity>>`.

- [ ] **Step 1: Write failing forwarding tests**

Verify exact path/query values, trimmed search omission when empty, `boxId` path forwarding, RepositoryImpl-only DTO mapping, and `safeApiCall` error conversion.

- [ ] **Step 2: Run RED tests**

Run: `flutter test test/features/driver/orders/data/driver_orders_remote_data_source_test.dart test/features/driver/orders/data/driver_orders_repository_test.dart test/features/driver/orders/domain/driver_orders_usecases_test.dart`

- [ ] **Step 3: Add endpoint constants and Retrofit declarations**

Use only the Task 1 approved paths. Do not implement fallback-on-404 or probe multiple routes in production.

- [ ] **Step 4: Implement DataSource -> Repository -> UseCase**

The remote data source forwards only. RepositoryImpl owns `safeApiCall` and DTO-to-domain mapping. Use cases expose domain entities only.

- [ ] **Step 5: Generate and test**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/driver/orders/data/driver_orders_remote_data_source_test.dart test/features/driver/orders/data/driver_orders_repository_test.dart test/features/driver/orders/domain/driver_orders_usecases_test.dart
```

- [ ] **Step 6: Commit**

```bash
git add lib/core/network lib/features/driver/orders test/features/driver/orders
git commit -m "feat: integrate driver orders rest api"
```

---

### Task 4: Implement Authenticated SignalR and Deterministic Event Mapping

**Files:**
- Create realtime DTO/client/domain/use-case files listed above.
- Test: `test/features/driver/orders/data/driver_orders_realtime_mapper_test.dart`
- Test: `test/features/driver/orders/data/driver_orders_signalr_client_test.dart`

**Interfaces:**
- `DriverOrdersRealtimeClient.start()`, `stop()`, and broadcast `Stream<DriverOrdersRealtimeEvent> get events`.
- Domain events: `DriverOrderDelivered`, `DriverDeliveryFailed`, `DriverArrivedAtCustomer`, `DriverReassignmentRequested`, and `DriverTripInTransit`.
- Every event exposes `eventId`, target ID, `occurredAtUtc`, and typed status-specific data.

- [ ] **Step 1: Write failing payload-mapping tests**

Cover the five exact backend event names, nullable defensive fields, unknown status, malformed payload rejection without stream termination, and timestamp parsing.

- [ ] **Step 2: Write lifecycle tests**

Assert bearer token factory usage, one connection for repeated `start()`, handlers registered once, exponential reconnect capped at 30 seconds, clean handler removal on `stop()`, and no reconnect after explicit disposal.

- [ ] **Step 3: Run RED tests**

Run: `flutter test test/features/driver/orders/data/driver_orders_realtime_mapper_test.dart test/features/driver/orders/data/driver_orders_signalr_client_test.dart`

- [ ] **Step 4: Implement the client**

Resolve the hub URL from `NetworkConstants.baseUrl`, reuse `TokenService`, never log token/payload PII, deduplicate recent `eventId` values with a bounded 200-entry set, and expose domain events through the repository.

- [ ] **Step 5: Run tests and commit**

```bash
flutter test test/features/driver/orders/data/driver_orders_realtime_mapper_test.dart test/features/driver/orders/data/driver_orders_signalr_client_test.dart
git add lib/features/driver/orders/data/realtime lib/features/driver/orders/data/models/realtime lib/features/driver/orders/domain test/features/driver/orders/data
git commit -m "feat: stream driver order updates"
```

---

### Task 5: Build the Orders ViewModel With Search, Filters, Refresh, and Realtime Patching

**Files:**
- Create: `driver_orders_event.dart`, `driver_orders_state.dart`, `driver_orders_view_model.dart`.
- Test: `test/features/driver/orders/presentation/driver_orders_view_model_test.dart`

**Interfaces:**
- Events: `LoadDriverOrdersEvent`, `RefreshDriverOrdersEvent`, `SearchDriverOrdersEvent`, `SelectDriverOrdersFilterEvent`, `ResetDriverOrdersQueryEvent`, `StartDriverOrdersRealtimeEvent`, `StopDriverOrdersRealtimeEvent`, `DriverOrdersRealtimeReceivedEvent`.
- State: `manifest`, `query`, `isInitialLoading`, `isRefreshing`, `isQueryLoading`, `failure`, `actionFailure`, `isRealtimeConnected`, `lastAppliedEventAtUtc`, and `hasLoadedOnce`.

- [ ] **Step 1: Write load/query race tests**

Cover initial success, initial Core failure, refresh retaining already loaded in-memory content, 300 ms debounced search, duplicate query suppression, filter values, reset, and stale-response rejection with a request-generation integer.

- [ ] **Step 2: Write realtime reducer tests**

Assert one event patches only its target stop, counts change correctly once, ordering remains stable, stale/duplicate events are ignored, a trip event updates banner state, and unknown box/trip events trigger one throttled refresh instead of inserting partial fake records.

- [ ] **Step 3: Run RED test**

Run: `flutter test test/features/driver/orders/presentation/driver_orders_view_model_test.dart`

- [ ] **Step 4: Implement immutable State and sealed Events**

Use unmodifiable lists/maps. Maintain an internal `Map<String, int>` index by `boxId` so a realtime update copies and replaces one list element without a linear search on every event.

- [ ] **Step 5: Implement lifecycle and cancellation safety**

Own and cancel debounce timer and stream subscription in `close()`. Start realtime after first usable manifest, stop it on disposal, and never emit after close.

- [ ] **Step 6: Run tests and commit**

```bash
flutter test test/features/driver/orders/presentation/driver_orders_view_model_test.dart
git add lib/features/driver/orders/presentation/manager test/features/driver/orders/presentation
git commit -m "feat: manage driver orders state"
```

---

### Task 6: Build Screen 05.05 UI, Shimmer, Core Errors, and Empty States

**Files:**
- Create the screen and widgets listed in Planned File Structure.
- Modify driver bottom-navigation routing to open `DriverOrdersScreen` for the Orders tab.
- Test: `test/features/driver/orders/presentation/driver_orders_screen_test.dart`
- Test: `test/features/driver/orders/presentation/driver_orders_shimmer_test.dart`

**Interfaces:**
- Widgets consume domain entities and callbacks only.
- `DriverOrdersScreen({DriverOrdersViewModel? viewModel, DriverOrderActionLauncher? actionLauncher})` retains injectable test seams.

- [ ] **Step 1: Write the state decision-table widget tests**

Assert:

```text
initial loading -> DriverOrdersShimmer
initial failure -> ApiErrorWidget with retry
success + no active trip -> no-active-trip EmptyStateWidget wrapper
query success + zero matches -> no-results state with reset button
refresh/action failure + content -> cards retained + InlineApiErrorWidget
content -> trip banner, counts, route-ordered virtualized cards
```

- [ ] **Step 2: Write semantic card tests**

Assert sequence `2/8`, box code, status text/time, customer, formatted address, meal summary, slot, problem reason, current-stop actions, and disabled call/navigation when capability data is false or missing.

- [ ] **Step 3: Write shimmer tests**

The shimmer mirrors app title, trip banner, search field, four filter chips, and four order cards. It uses `ShimmerWidget`, theme colors, and responsive constraints at 320x640 and 430x932.

- [ ] **Step 4: Run RED tests**

Run: `flutter test test/features/driver/orders/presentation/driver_orders_screen_test.dart test/features/driver/orders/presentation/driver_orders_shimmer_test.dart`

- [ ] **Step 5: Implement UI with virtualized scrolling**

Use one `CustomScrollView` with slivers or one `ListView.builder`; do not place all cards in a `SingleChildScrollView` with spread children. Give each card `ValueKey(stop.tripStopId)`, isolate repaint-heavy pulsing status with `RepaintBoundary`, and avoid intrinsic measurement in rows.

- [ ] **Step 6: Wire Core error/empty widgets and shimmer**

Import from `lib/core/errors`. The no-results reset dispatches `ResetDriverOrdersQueryEvent`; no state creates sample orders.

- [ ] **Step 7: Run tests and commit**

```bash
flutter test test/features/driver/orders/presentation/driver_orders_screen_test.dart test/features/driver/orders/presentation/driver_orders_shimmer_test.dart
git add lib/features/driver/orders/presentation lib/config/routing test/features/driver/orders/presentation
git commit -m "feat: build driver orders list screen"
```

---

### Task 7: Implement Call, Navigation, Completion, and Issue Actions

**Files:**
- Create: `lib/features/driver/orders/presentation/services/driver_order_action_launcher.dart`
- Modify: `driver_orders_screen.dart`, `driver_order_card.dart`, routing arguments as required.
- Test: `test/features/driver/orders/presentation/driver_order_actions_test.dart`
- Test: `test/config/routing/driver_orders_routes_test.dart`

**Interfaces:**
- `DriverOrderActionLauncher.openNavigation(DriverDeliveryStopEntity stop)`.
- `DriverOrderActionLauncher.callCustomer(DriverDeliveryStopEntity stop)` requests proxy data through the ViewModel/use case before launching.
- Routes carry stable `boxId`/`tripStopId`, not whole stale mutable manifests.

- [ ] **Step 1: Write failing action tests**

Assert call proxy is requested once, expired/missing proxy responses show an inline typed failure, coordinates are URI encoded, unavailable external apps return failure, and disabled capabilities never invoke a launcher.

- [ ] **Step 2: Write route tests**

Assert `فتح المسار` reaches the existing 05.04 route when available, `إتمام التسليم` reaches the 07.02 confirmation route with IDs, and problem details reach the existing support/problem route. If a target route is not implemented, add a typed route argument and explicit temporary unavailable state; never route to an unrelated screen.

- [ ] **Step 3: Run RED tests**

Run: `flutter test test/features/driver/orders/presentation/driver_order_actions_test.dart test/config/routing/driver_orders_routes_test.dart`

- [ ] **Step 4: Implement launchers and navigation**

Use `url_launcher` with encoded `geo:`/HTTPS maps fallbacks selected by platform conventions. Do not construct `tel:` from private customer data; use only authoritative proxy output.

- [ ] **Step 5: Refresh after child-flow completion**

When delivery or issue screens return a successful result, dispatch one refresh. Do not mutate a card to delivered merely because navigation completed.

- [ ] **Step 6: Run tests and commit**

```bash
flutter test test/features/driver/orders/presentation/driver_order_actions_test.dart test/config/routing/driver_orders_routes_test.dart
git add lib/features/driver/orders lib/config/routing test
git commit -m "feat: connect driver order actions"
```

---

### Task 8: Register Dependencies and Add Localization

**Files:**
- Modify: `lib/core/di/di.dart`
- Modify: `lib/core/l10n/app_ar.arb`
- Modify: `lib/core/l10n/app_en.arb`
- Generated localization files.
- Test: `test/features/driver/orders/driver_orders_di_test.dart`
- Test: `test/features/driver/orders/presentation/driver_orders_localization_test.dart`

**Interfaces:**
- One lazy singleton database, local data source, remote data source, repository, and realtime client.
- Factory ViewModel and use cases using the repository/realtime abstractions.

- [ ] **Step 1: Write DI resolution test**

Assert `getIt<DriverOrdersViewModel>()` resolves and that two ViewModels share the singleton repository/client without either constructing Dio directly.

- [ ] **Step 2: Add Arabic and English keys**

Include screen title, trip status labels, search hint, four filters/count labels, status fallbacks, no-active-trip, no-results/reset, no-internet behavior, call/navigation/complete/problem actions, proxy/map failures, and accessibility labels. Do not rely on backend text as the only localized UX.

- [ ] **Step 3: Register dependencies using current manual GetIt style**

Respect disposal order: ViewModel subscription first, realtime client second, database last. Do not migrate the whole project to generated DI.

- [ ] **Step 4: Generate and test**

```bash
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/driver/orders/driver_orders_di_test.dart test/features/driver/orders/presentation/driver_orders_localization_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/core/di lib/core/l10n lib/features/driver/orders test/features/driver/orders
git commit -m "feat: wire and localize driver orders"
```

---

### Task 9: Accessibility, Security, and Privacy Regression Coverage

**Files:**
- Modify order widgets only where tests reveal missing semantics/focus behavior.
- Test: `test/features/driver/orders/presentation/driver_orders_accessibility_test.dart`
- Test: `test/features/driver/orders/data/driver_orders_privacy_test.dart`

**Interfaces:**
- No new public API; validates shipping constraints.

- [ ] **Step 1: Write accessibility tests**

Assert 48x48 minimum action targets, semantic labels containing box/status/customer context, logical focus order in RTL/LTR, text scaling at 200%, and adequate disabled-state differentiation without relying on color alone.

- [ ] **Step 2: Write privacy tests**

Assert direct phone numbers are absent from diagnostic strings, no order data is persisted by this feature, and SignalR logs redact payloads/tokens.

- [ ] **Step 3: Run tests and fix only verified failures**

Run: `flutter test test/features/driver/orders/presentation/driver_orders_accessibility_test.dart test/features/driver/orders/data/driver_orders_privacy_test.dart`

- [ ] **Step 4: Commit**

```bash
git add lib/features/driver/orders test/features/driver/orders
git commit -m "test: protect driver orders accessibility and privacy"
```

---

### Task 10: Performance Verification and Optimization

**Files:**
- Test: `test/features/driver/orders/presentation/driver_orders_performance_test.dart`
- Add: `integration_test/driver_orders_scroll_performance_test.dart` if integration tests are enabled in the execution environment.
- Modify only proven hotspots in screen/ViewModel code.

**Interfaces:**
- Performance budgets from Global Constraints are acceptance criteria.

- [ ] **Step 1: Add a 100-stop build test**

Pump 100 domain stops and assert only viewport-visible cards are built, search filtering occurs once after 300 ms, and a single realtime event changes only the targeted card's key/content.

- [ ] **Step 2: Add request-count tests**

Rapidly type five search updates inside 300 ms and assert one use-case call. Re-select the current filter and assert zero network calls. Trigger reconnect notifications repeatedly and assert a single active connection/start call.

- [ ] **Step 3: Profile scroll frames**

Run the integration test in profile mode and inspect Flutter DevTools frame chart. Acceptance: no repeated build/layout shader work caused by the screen, no sustained frames over 16.7 ms at 60 Hz, and no list-wide rebuild when one stop changes.

- [ ] **Step 4: Apply evidence-based optimizations only**

Allowed fixes include const widgets, narrower Bloc selectors, cached formatter output, map-indexed event patching, `RepaintBoundary`, and reduced animation scope. Do not add speculative memoization or isolates without a measured bottleneck.

- [ ] **Step 5: Run performance tests and commit**

```bash
flutter test test/features/driver/orders/presentation/driver_orders_performance_test.dart
git add lib/features/driver/orders test/features/driver/orders integration_test
git commit -m "perf: verify driver orders list performance"
```

---

### Task 11: Full Verification and Production Cleanup

**Files:**
- Modify tests or production references revealed by verification only.
- Remove production fake-order references only after all real paths pass.

**Interfaces:**
- No new behavior; proves the complete feature.

- [ ] **Step 1: Regenerate and format**

```bash
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
dart format lib test integration_test
```

- [ ] **Step 2: Run focused suites**

```bash
flutter test test/features/driver/orders
flutter test test/config/routing/driver_orders_routes_test.dart
```

Expected: all PASS.

- [ ] **Step 3: Run pickup regressions**

```bash
flutter test test/features/driver/orders/data/driver_pickup_manifest_dto_mapper_test.dart
flutter test test/features/driver/orders/presentation/driver_assigned_boxes_backend_test.dart
flutter test test/features/driver/confirm_receipt
```

Expected: Screens 06.02-06.05 continue to work unchanged.

- [ ] **Step 4: Run static and full regression verification**

```bash
flutter analyze
flutter test
```

Expected: no new analyzer errors and all tests pass. Record exact unrelated pre-existing failures without hiding them.

- [ ] **Step 5: Run manual QA matrix**

Verify Arabic/English, RTL/LTR, 320x640 and 430x932, 200% text scale, active trip, no trip, all four filters, no results/reset, rapid search, pull-to-refresh, cold airplane-mode Core error, connection loss with already loaded content retained in memory, reconnect, duplicate/out-of-order SignalR events, call proxy success/failure, no maps app, missing coordinates, delivered timestamp, failed reason, route preservation, and app resume.

- [ ] **Step 6: Confirm zero production mock data**

Run:

```bash
rg -n "Fake|fake|mock|BX-458|TRP-48|أحمد فيصل|محمد علي" lib/features/driver/orders
```

Expected: no production fixture/customer/order data. Test fixtures may remain under `test/`.

- [ ] **Step 7: Commit final verification**

```bash
git add lib test integration_test
git commit -m "test: verify driver orders list integration"
```

---

## Final Acceptance Criteria

- The Orders bottom-navigation tab opens Screen 05.05 and never displays pickup-only or fake data as delivery orders.
- The active trip and all stop cards come from the authenticated backend; this feature does not persist order data locally.
- Cards are sorted by server `sequenceNumber` and retain that order through search, filters, refresh, and realtime updates.
- Search covers box code, customer name, zone, and formatted address with a 300 ms debounce and stale-response protection.
- Counts represent the full active trip and remain correct after REST and deduplicated SignalR updates.
- Initial loading uses a screen-shaped shimmer; Core full-page, inline, and empty error widgets are used according to the state decision table.
- A cold launch without internet uses the Core no-internet error; losing connectivity after load retains only the current in-memory content with an inline error.
- Call proxy and external navigation are capability-gated, URI-safe, and failure-aware.
- Delivery completion/problem navigation passes stable IDs and refreshes only after authoritative child-flow success.
- Exactly one screen-owned SignalR connection/subscription lifecycle is active; handlers, timers, and subscriptions are disposed.
- A single realtime stop update does not rebuild or reorder the entire list.
- The 100-stop performance budgets and manual scroll profile pass on the documented mid-range test device.
- Production contains zero mock orders and no direct customer phone values in logs or local storage.
- Generated code is current, focused tests pass, pickup regressions pass, `flutter analyze` reports no new errors, and the full test suite passes or has explicitly documented unrelated pre-existing failures.
