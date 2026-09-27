# Dispatcher Driver Status Details Backend Integration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the fake Screen 04.07 driver-details data inside `dispatcher_drivers_status` with the documented REST and SignalR contracts, keeping the current UI while adding typed errors, shape-matched shimmer loading, safe availability updates, and zero production mock data.

**Architecture:** Make `lib/features/dispatcher/dispatcher_drivers_status` the canonical owner of both the drivers-status list and its details screen. Extend its existing Clean Architecture flow (`UI -> Event -> ViewModel -> UseCase -> Repository -> RemoteDataSource -> ApiServices`) with an ID-scoped details query and availability command; reuse the existing dispatcher realtime connection instead of opening another hub. REST DTOs remain nullable, mappers produce domain-safe values without inventing business data, and presentation renders the current cards from a dedicated details ViewModel.

**Tech Stack:** Flutter, Dart 3.12, flutter_bloc, Dio, Retrofit, json_serializable, GetIt manual registrations, existing `ApiResult`/`safeApiCall`, `lib/core/errors`, `ShimmerWidget`, `signalr_netcore`, `url_launcher`, flutter_test.

**Spec:** `C:/Users/orignal store/.codex/attachments/772c2112-f128-4acb-93cb-9de763d04841/Pasted text.txt`

## Global Constraints

- Follow `rules/rules_backend.md`; do not call `ApiServices`, repositories, or launchers directly from widgets.
- Keep Screen 04.07 under `lib/features/dispatcher/dispatcher_drivers_status`; do not create another competing details feature.
- The authoritative REST contracts are `GET /api/v1/dispatcher/drivers/{driverId}` (with `/details` only as a backend-confirmed compatibility alias) and `PATCH /api/v1/dispatcher/drivers/{driverId}/availability`.
- Use the existing authenticated `Dio`, token/language interceptors, `ApiResult`, `safeApiCall`, and manual GetIt style in `lib/core/di/di.dart`.
- Use the existing dispatcher SignalR connection and consume only `driver-availability-updated`; do not create a second hub connection.
- Response DTO and nested fields are nullable. Never force-unwrap backend values and never manufacture phone, avatar, coordinates, rating, documents, vehicle data, timestamps, or metrics.
- Initial loading must use a screen-shaped shimmer composed from `ShimmerWidget`; never show fake entities or a full-page spinner.
- Initial failure with no details uses `ApiErrorWidget.fromTypedFailure`; refresh/action/realtime failures with usable content use `InlineApiErrorWidget` or one localized `CustomSnackbar` notice while retaining content.
- Missing phone disables Call and WhatsApp; missing avatar uses initials/placeholder; missing coordinates shows the documented no-location state; missing rating shows “new driver,” not `0.0`; missing document expiry maps to `Missing`.
- Availability is optimistic only while the request is in flight, is disabled during submission, rolls back on failure, and is finally reconciled from the PATCH response or matching SignalR event.
- Preserve the existing visual hierarchy, widgets, route name, Arabic/English behavior, RTL/LTR layout, contact launcher, and map navigation.
- Do not edit generated `*.g.dart`, `api_services.g.dart`, or generated localization Dart files manually.
- Preserve unrelated dirty-worktree changes, especially `docs/superpowers/plans/2026-09-27-driver-orders-list-backend-integration.md`.

## Planned File Structure

### Create

- `data/models/response/dispatcher_driver_details_response_dto.dart`
- `data/models/request/update_driver_availability_request_dto.dart`
- `data/models/response/update_driver_availability_response_dto.dart`
- `data/mapper/dispatcher_driver_details_mapper.dart`
- `domain/entities/update_driver_availability_request_entity.dart`
- `domain/entities/update_driver_availability_result_entity.dart`
- `domain/usecase/get_dispatcher_driver_details_usecase.dart`
- `domain/usecase/observe_dispatcher_driver_availability_usecase.dart`
- `presentation/manager/dispatcher_driver_details_event.dart`
- `presentation/manager/dispatcher_driver_details_state.dart`
- `presentation/manager/dispatcher_driver_details_view_model.dart`
- `presentation/widgets/dispatcher_driver_details_shimmer.dart`
- Focused tests under `test/features/dispatcher/dispatcher_drivers_status/`.

### Modify

- Existing details entities/widgets/screen inside `dispatcher_drivers_status`.
- Existing status remote data source, repository, toggle use case, and realtime boundary.
- `lib/core/network/network_constants.dart`, `lib/core/network/api_services.dart`, and `lib/core/di/di.dart`.
- `lib/config/routing/routing_generator.dart` only if constructor injection requires route-factory resolution.
- `lib/core/l10n/app_ar.arb` and `lib/core/l10n/app_en.arb`.

### Remove only after replacement tests pass

- `dispatcher_driver_details_fake_data.dart` and all production imports.
- Orphan/duplicate Screen 04.07 code under `dispatcher_driver_details` only after `rg` proves it has no remaining route, DI, test, or production consumer. Keep shared `DriverContactLauncher` by moving it to `dispatcher_drivers_status/presentation/services/` or a neutral core service before deleting anything.

---

### Task 1: Lock the Screen 04.07 Wire Contract

**Files:** Create the three DTO files above; modify `api_services.dart` only after tests describe the exact JSON.

**Interfaces:** `DispatcherDriverDetailsResponseDto`, `UpdateDriverAvailabilityRequestDto`, and `UpdateDriverAvailabilityResponseDto` mirror the supplied `driver`, `today`, `vehicle`, `currentLocation`, `performance`, and `documents` objects.

- [ ] Write a full parsing test using the exact supplied JSON and a sparse parsing test with every object/field omitted or null.
- [ ] Assert numeric fields accept JSON `num`, document arrays tolerate null entries, and no response constructor has a required backend field.
- [ ] Write request serialization tests proving `isAvailable` is required and blank/null `reason` is omitted.
- [ ] Run `flutter test test/features/dispatcher/dispatcher_drivers_status/data/dispatcher_driver_details_dto_test.dart` and confirm RED.
- [ ] Implement nullable `@JsonSerializable` DTOs; use `createToJson: false` for responses and `includeIfNull: false` for the PATCH request.
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`, rerun the focused test, and commit `test: lock dispatcher driver details contract`.

---

### Task 2: Make the Existing Details Domain Model Null-Safe and Truthful

**Files:** Modify `dispatcher_driver_details_entity.dart`, vehicle/location/performance/document entities, and create the details mapper.

**Interfaces:** Keep widget-facing names where practical, but model absence explicitly: `phoneNumber`, `avatarUrl`, `rating`, coordinates, location timestamp, vehicle fields, and document expiry may be nullable. Add enums/extensions for operational and document states with an `unknown`/`missing` fallback.

- [ ] Write mapper tests for all documented status values (`Available`, `Valid`, `ExpiringSoon`, `Expired`, `Missing`) plus unknown casing/value.
- [ ] Assert null rating stays null, null coordinates stay null, absent expiry becomes `missing`, negative counts clamp to zero, and backend URL/storage keys are not replaced with fake assets.
- [ ] Add `copyWith` support needed for availability/realtime patches without `??` preventing an intentional nullable update.
- [ ] Run the mapper tests RED, implement the smallest mapper/entity changes, rerun GREEN, and commit `feat: model dispatcher driver details`.

---

### Task 3: Extend the Existing Clean Architecture Boundary

**Files:** Modify status remote data source/repository; add the get-details use case; update toggle request/result entities and use case; modify network constants and `ApiServices`.

**Interfaces:**

```dart
Future<DispatcherDriverDetailsResponseDto> getDriverDetails(String driverId);
Future<UpdateDriverAvailabilityResponseDto> updateDriverAvailability(
  String driverId,
  UpdateDriverAvailabilityRequestDto request,
);
Future<ApiResult<DispatcherDriverDetailsEntity>> getDriverDetails(String driverId);
Future<ApiResult<UpdateDriverAvailabilityResultEntity>> updateDriverAvailability(
  UpdateDriverAvailabilityRequestEntity request,
);
```

- [ ] Write remote-data-source tests verifying raw GUID path forwarding and exact PATCH body.
- [ ] Write repository tests proving DTO-to-entity mapping and typed `Failure` conversion through `safeApiCall` for 400/401/403/404/409/429/500, timeout, and no internet.
- [ ] Write use-case forwarding tests; reject blank `driverId` before a network call with the project’s validation failure convention.
- [ ] Add one canonical Retrofit details method. Resolve the currently duplicated `dispatcher_driver_details` API ownership instead of retaining two methods for the same URL/response contract.
- [ ] Generate Retrofit/JSON code, run focused data/domain tests, and commit `feat: integrate dispatcher driver details api`.

---

### Task 4: Add the Details ViewModel State Machine

**Files:** Create details event/state/ViewModel files under `dispatcher_drivers_status/presentation/manager`.

**Interfaces:** Events: `started(driverId)`, `refreshed`, `availabilityChanged(value, reason?)`, `realtimeAvailabilityReceived(update)`, `retryRequested`. State retains `details`, `failure`, `inlineFailure`, `isInitialLoading`, `isRefreshing`, and `isUpdatingAvailability`.

- [ ] Test first load success/failure, retry, refresh retaining content, duplicate-start suppression, and stale response rejection after driver ID changes/disposal.
- [ ] Test optimistic toggle, double-tap suppression, authoritative success reconciliation, rollback on failure, and an out-of-order realtime event winning only when its `updatedAtUtc` is newer.
- [ ] Ensure one action failure emits one consumable UI notice rather than replaying on every rebuild.
- [ ] Implement with injected use cases only; no GetIt lookup inside the ViewModel.
- [ ] Run `flutter test test/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_driver_details_view_model_test.dart` and commit `feat: manage dispatcher driver details state`.

---

### Task 5: Reuse the Dispatcher Realtime Connection

**Files:** Extend the existing dispatcher realtime DTO/mapper/repository boundary and create `ObserveDispatcherDriverAvailabilityUseCase` only if the status feature does not already expose an equivalent stream.

**Interfaces:** Filter `driver-availability-updated` by the open `driverId`; map `isAvailable`, `operationalStatus`, `hasActiveAssignments`, and `updatedAtUtc` into the same availability result entity used by PATCH.

- [ ] Write event parser tests for map/string payloads, sparse payloads, malformed GUIDs, and unrelated driver IDs.
- [ ] Write lifecycle tests proving the details screen acquires/releases one owner without stopping the shared connection while another dispatcher surface is using it.
- [ ] Patch only availability/status fields; never overwrite profile, metrics, vehicle, documents, or location from an event that does not carry them.
- [ ] Run focused realtime tests and commit `feat: sync dispatcher driver availability`.

---

### Task 6: Build Shape-Matched Shimmer and Harden Every UI State

**Files:** Create `dispatcher_driver_details_shimmer.dart`; modify the existing profile, metrics, contact, vehicle, location, performance, and document widgets.

**Interfaces:** The shimmer mirrors avatar/name/status, four metric tiles, contact/vehicle/location/performance/document cards, and bottom actions using `ShimmerWidget` and existing spacing/radius tokens.

- [ ] Write widget tests for initial shimmer, full typed error/retry, content-preserving inline failure, missing phone/avatar/location/rating/documents, long Arabic/English text, 200% text scale, and 320x640 no-overflow.
- [ ] Assert initial loading contains no fake driver/business text and no `CircularProgressIndicator` as the page body.
- [ ] Render `ApiErrorWidget.fromTypedFailure` only when no usable details exist; use `InlineApiErrorWidget` while retained details remain visible.
- [ ] Disable Call/WhatsApp without a valid phone; use initials/placeholder without fake image URLs; hide the mini-map/coordinates when location is absent; localize all fallbacks.
- [ ] Use flexible wrapping/ellipsis and logical RTL-safe alignment; preserve 48x48 action targets and semantic labels that do not rely on color alone.
- [ ] Run focused widget tests and commit `feat: harden dispatcher driver details ui`.

---

### Task 7: Connect Screen, Routing, Actions, and Dependency Injection

**Files:** Modify `dispatcher_driver_status_details_screen.dart`, routing generator, manual DI, localization ARBs, and contact service location/imports.

- [ ] Replace local mutable `_details` and `initialDetails` production fallback with `BlocProvider`/`BlocBuilder` driven by the ID-scoped ViewModel; retain explicit test seams only where necessary.
- [ ] Dispatch initial load once, support pull-to-refresh without reverting to full shimmer, and dispose realtime subscription/lease safely.
- [ ] Keep `DriverContactLauncher`; validate URI creation and show one localized `CustomSnackbar.showError` on failed Call/WhatsApp launch.
- [ ] Keep “Open on Map” internal navigation with `DispatcherMapRouteArgs(focusDriverId: driverId)` and never substitute coordinates or a fake ID.
- [ ] Register remote source/repository/use cases/ViewModel using current manual GetIt style, with `registerFactoryParam<DispatcherDriverDetailsViewModel, String, void>`.
- [ ] Generate localization, add DI resolution and route tests, run them, and commit `feat: connect dispatcher driver details screen`.

---

### Task 8: Remove Mock/Duplicate Ownership and Run Full Verification

**Files:** Remove fake data and only proven-orphan duplicate details files; update imports/tests.

- [ ] Convert the legacy screen test from fake production data to explicit domain fixtures and mocked use cases/ViewModel.
- [ ] Run `rg -n "DispatcherDriverDetailsFakeData|AssetsFake|initialDetails" lib/features/dispatcher/dispatcher_drivers_status` and require zero production matches.
- [ ] Run `rg -n "DispatcherDriverDetailsScreen|DriverDetailsViewModel|DriverDetailsRepository" lib test` before removing the separate feature; delete/move files only when every consumer has migrated.
- [ ] Run `dart format` on changed Dart files, `flutter gen-l10n`, `dart run build_runner build --delete-conflicting-outputs`, focused tests, `flutter analyze`, then the full `flutter test` suite.
- [ ] Manually verify Arabic/English, RTL/LTR, 320x640 and 430x932, 200% text scale, loading, every Core error family, retry, refresh, absent optional data, rapid availability taps, PATCH rollback, realtime update, call/WhatsApp failure, map navigation, app pause/resume, and back navigation.
- [ ] Commit `test: verify dispatcher driver details integration`.

## Final Acceptance Criteria

- Opening `AppRoutes.dispatcherDriverDetails` with a raw GUID loads Screen 04.07 from the authenticated backend and never from fake data.
- The current `dispatcher_drivers_status` cards and route remain visually intact; only data/state wiring and null-safe rendering change.
- Initial load is a shape-matched shimmer; typed Core errors and retry behavior are selected according to whether usable content exists.
- Every response passes DTO -> mapper -> entity -> `ApiResult` -> use case -> ViewModel -> UI with no DTO leakage.
- Availability updates are race-safe, reversible on failure, and synchronized through the shared dispatcher SignalR connection.
- Missing backend values produce truthful disabled/empty states, not invented values or assets.
- Contact/map actions are ID/URI safe, localized, testable, and failure-aware.
- No duplicate Screen 04.07 backend owner, fake production source, second Dio, or second dispatcher hub connection remains.
- Focused tests, analyzer, and the full test suite pass, with unrelated pre-existing failures documented rather than hidden.
