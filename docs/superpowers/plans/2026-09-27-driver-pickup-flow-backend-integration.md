# Driver Pickup Flow Backend Integration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace fake/local behavior in driver screens 06.02–06.05 with the complete backend pickup flow: manifest, barcode validation, condition-photo upload, pickup confirmation, resumable summary, and trip start.

**Architecture:** Preserve the existing `orders` and `confirm_receipt` UI and connect them through Feature-Based Clean Architecture. `orders` owns the pickup manifest; `confirm_receipt` owns barcode validation, photo upload, pickup confirmation, summary, and trip start. Every request follows `UI → Event → ViewModel → UseCase → Repository → RemoteDataSource → ApiServices`, while nullable DTOs map to non-null domain entities.

**Tech Stack:** Flutter, Dart 3, `flutter_bloc`, Dio/Retrofit, `json_serializable`, Injectable/GetIt, `image_picker`, `mobile_scanner`, existing `ApiResult`/`safeApiCall`, existing Core error widgets, existing `ShimmerWidget`.

**Spec:** Backend contracts supplied for screens 06.02, 06.03, 06.04, and 06.05; UI baseline in `docs/superpowers/specs/2026-09-15-driver-assigned-boxes-design.md`.

## Global Constraints

- Read and obey `rules/rules_backend.md`; do not bypass any Clean Architecture layer.
- Preserve the existing screens, widgets, theme, RTL/LTR behavior, localization, navigation, and app shell.
- Use `lib/core/errors/error_widgets/api_error_widget.dart` for an initial full-screen failure, `inline_api_error_widget.dart` for action/refresh failures while content remains, and `empty_state_widget.dart` for a successful empty manifest/summary.
- Initial screen loading must use screen-shaped shimmer built from `lib/core/widget/shimmer_widget.dart`; do not use `CircularProgressIndicator` for manifest or summary loading.
- Response DTO fields are nullable and defensive; request DTO fields match the backend contract exactly.
- Do not manually edit `.g.dart` or generated localization files.
- Do not delete fake-data files until every production UI reference has been removed and existing fixture-based tests have been migrated.
- Do not touch the unrelated dirty dispatcher work currently visible in the worktree.
- Do not add a location package without explicit approval. The backend requires real non-zero GPS coordinates for pickup confirmation and trip start; execution must first bind the `DriverPickupLocationProvider` interface in Task 1 to an approved production location source. Tests use a fake provider.
- Generate one idempotency key per logical confirm/start operation and reuse that key for retries of the same operation; generate a new key only for a new operation.
- Canonical pickup lifecycle is `PendingScan → BarcodeValidated → PhotoUploaded → PickedUp`; UI completion/filtering is based on `PickedUp`, not on legacy `isScanned`.

---

## File Structure

### Shared/Core

- Modify `lib/core/network/network_constants.dart` — pickup endpoint constants.
- Modify `lib/core/network/api_services.dart` — Retrofit declarations and headers/parts.
- Generated `lib/core/network/api_services.g.dart` — regenerated only.
- Create `lib/core/services/idempotency_key_factory.dart` — injectable UUID-compatible key creation without coupling presentation to generation details.
- Create `lib/core/services/driver_pickup_location_provider.dart` — location contract and immutable coordinate value.
- Modify `lib/core/di/di.dart` only if this repository continues to use manual registrations for new driver classes; otherwise regenerate Injectable registrations.

### Driver Orders / Manifest (06.02)

- Modify `lib/features/driver/orders/domain/entities/driver_assigned_box_entity.dart` — backend-backed box fields.
- Modify `lib/features/driver/orders/domain/entities/driver_box_delivery_status.dart` — only pickup-relevant states.
- Modify `lib/features/driver/orders/domain/entities/driver_boxes_filter_type.dart` — `all`, `pendingScan`, `pickedUp` wire values.
- Create `lib/features/driver/orders/domain/entities/driver_pickup_manifest_entity.dart`.
- Create `lib/features/driver/orders/data/models/response/driver_pickup_manifest_response_dto.dart`.
- Create `lib/features/driver/orders/data/mapper/driver_pickup_manifest_mapper.dart`.
- Create `lib/features/driver/orders/data/data_source/driver_pickup_manifest_remote_data_source.dart`.
- Create `lib/features/driver/orders/data/data_source/driver_pickup_manifest_remote_data_source_impl.dart`.
- Create `lib/features/driver/orders/domain/repo/driver_pickup_manifest_repository.dart`.
- Create `lib/features/driver/orders/data/repo/driver_pickup_manifest_repository_impl.dart`.
- Create `lib/features/driver/orders/domain/usecase/get_driver_pickup_manifest_usecase.dart`.
- Create `lib/features/driver/orders/presentation/manager/driver_pickup_manifest_event.dart`.
- Create `lib/features/driver/orders/presentation/manager/driver_pickup_manifest_state.dart`.
- Create `lib/features/driver/orders/presentation/manager/driver_pickup_manifest_view_model.dart`.
- Create `lib/features/driver/orders/presentation/widgets/driver_assigned_boxes_shimmer.dart`.
- Modify existing `orders/presentation` screen/widgets to consume real entity values without redesign.

### Confirm Receipt / Summary (06.03–06.05)

- Create request DTO/entity pairs for barcode validation, pickup confirmation, and trip start.
- Create nullable response DTOs/entities for barcode validation, photo upload, pickup confirmation, pickup summary, and trip start.
- Create `driver_pickup_mapper.dart`, remote data source contract/implementation, repository contract/implementation, and five use cases.
- Create one `DriverPickupFlowViewModel` with one immutable state and sealed events for the sequential scan/photo/confirm workflow.
- Create one `DriverPickupSummaryViewModel` with one immutable state and sealed events for loading summary and starting trip.
- Create `driver_boxes_received_shimmer.dart`.
- Modify existing scanner, individual success, and summary screens rather than replacing their visual structure.

### Tests

- Add focused DTO/mapper, data-source, repository, use-case, view-model, widget, routing, and end-to-end flow tests under `test/features/driver/orders/` and `test/features/driver/confirm_receipt/`.
- Migrate or replace root-level `test/driver_assigned_boxes_screen_test.dart` and `test/driver_confirm_receipt_screen_test.dart` assertions that depend on fake transitions.

---

### Task 1: Cross-cutting location and idempotency contracts

**Files:**
- Create: `lib/core/services/driver_pickup_location_provider.dart`
- Create: `lib/core/services/idempotency_key_factory.dart`
- Test: `test/core/services/idempotency_key_factory_test.dart`
- Test: `test/support/fakes/fake_driver_pickup_location_provider.dart`

**Interfaces:**
- Produces: `DriverPickupCoordinates(latitude, longitude)` with validated finite/non-zero coordinates.
- Produces: `abstract interface class DriverPickupLocationProvider { Future<DriverPickupCoordinates> getCurrentCoordinates(); }`.
- Produces: `IdempotencyKeyFactory.create()` returning a new RFC-4122-shaped string.

- [ ] **Step 1: Write failing unit tests for coordinate validation and unique keys**

```dart
test('rejects zero coordinates', () {
  expect(
    () => DriverPickupCoordinates(latitude: 0, longitude: 0),
    throwsArgumentError,
  );
});

test('creates a different idempotency key for each new operation', () {
  final factory = IdempotencyKeyFactory();
  expect(factory.create(), isNot(factory.create()));
});
```

- [ ] **Step 2: Run the tests and confirm RED**

Run: `flutter test test/core/services/idempotency_key_factory_test.dart`

Expected: FAIL because the production types do not exist.

- [ ] **Step 3: Implement the contracts**

```dart
class DriverPickupCoordinates {
  DriverPickupCoordinates({required this.latitude, required this.longitude}) {
    final valid = latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        !(latitude == 0 && longitude == 0);
    if (!valid) throw ArgumentError('Invalid pickup coordinates');
  }

  final double latitude;
  final double longitude;
}

abstract interface class DriverPickupLocationProvider {
  Future<DriverPickupCoordinates> getCurrentCoordinates();
}
```

Implement `IdempotencyKeyFactory` with `Random.secure()` and RFC-4122 formatting so no new package is required. Do not use timestamps alone.

- [ ] **Step 4: Add a deterministic fake location provider for tests**

The fake returns `29.3375, 48.0280` and can be configured to throw `LocationServiceException` from `lib/core/errors/location_exception.dart`.

- [ ] **Step 5: Bind an approved production location implementation**

Before continuing to UI wiring, confirm and use the project-approved GPS source. If no source is approved, stop only this binding step and report that confirm/start cannot be production-safe; do not insert hardcoded coordinates or silently add a package.

- [ ] **Step 6: Run tests and commit**

Run: `flutter test test/core/services/idempotency_key_factory_test.dart`

Commit: `feat: add driver pickup operation services`

---

### Task 2: Manifest domain model, DTO, and mapper

**Files:**
- Modify: `lib/features/driver/orders/domain/entities/driver_assigned_box_entity.dart`
- Modify: `lib/features/driver/orders/domain/entities/driver_box_delivery_status.dart`
- Modify: `lib/features/driver/orders/domain/entities/driver_boxes_filter_type.dart`
- Create: `lib/features/driver/orders/domain/entities/driver_pickup_manifest_entity.dart`
- Create: `lib/features/driver/orders/data/models/response/driver_pickup_manifest_response_dto.dart`
- Create: `lib/features/driver/orders/data/mapper/driver_pickup_manifest_mapper.dart`
- Test: `test/features/driver/orders/data/driver_pickup_manifest_dto_mapper_test.dart`

**Interfaces:**
- Produces: `DriverPickupManifestEntity` with trip metadata, all counters, completion flags, and `List<DriverAssignedBoxEntity>`.
- Produces: `DriverBoxesFilterType.wireValue` values `All`, `PendingScan`, and `PickedUp`.
- Preserves legacy backend aliases in DTO only; domain exposes canonical pickup terms.

- [ ] **Step 1: Write failing DTO parsing tests using the exact 06.02 JSON**

Assert nullable parsing for missing fields and exact parsing for `conditionPhotoStorageKey`, `pickedUpBoxesCount`, and `allBoxesPickedUp`.

- [ ] **Step 2: Write failing mapper tests**

```dart
expect(entity.totalBoxesCount, 8);
expect(entity.pickedUpBoxesCount, 1);
expect(entity.boxes.first.status, DriverBoxDeliveryStatus.pendingScan);
expect(entity.boxes.last.status, DriverBoxDeliveryStatus.pickedUp);
expect(entity.boxes.last.isPickedUp, isTrue);
```

Require mapper fallbacks: empty strings, zero non-negative counts, `PendingScan` for unknown status, empty list for null boxes, and `pickedUpBoxesCount ?? scannedBoxesCount ?? 0` compatibility.

- [ ] **Step 3: Run the test and confirm RED**

Run: `flutter test test/features/driver/orders/data/driver_pickup_manifest_dto_mapper_test.dart`

- [ ] **Step 4: Implement nullable DTOs with `json_serializable`**

The box DTO must include every actual key: `boxId`, `boxCode`, `customerName`, `deliveryZone`, `mealsCount`, `mealsSummary`, `deliveryTimeSlot`, `scanStatus`, `scanStatusText`, `isScanned`, `scannedAtUtc`, and `conditionPhotoStorageKey`.

- [ ] **Step 5: Implement canonical entities and mapper**

Replace UI-only `orderCode/isLoaded` assumptions with backend fields. If widgets still require `orderCode`, derive it in presentation from `boxCode`; do not fabricate another backend identifier.

- [ ] **Step 6: Generate, test, and commit**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/driver/orders/data/driver_pickup_manifest_dto_mapper_test.dart
```

Commit: `feat: model driver pickup manifest`

---

### Task 3: Manifest API through use case

**Files:**
- Modify: `lib/core/network/network_constants.dart`
- Modify: `lib/core/network/api_services.dart`
- Create: `lib/features/driver/orders/data/data_source/driver_pickup_manifest_remote_data_source.dart`
- Create: `lib/features/driver/orders/data/data_source/driver_pickup_manifest_remote_data_source_impl.dart`
- Create: `lib/features/driver/orders/domain/repo/driver_pickup_manifest_repository.dart`
- Create: `lib/features/driver/orders/data/repo/driver_pickup_manifest_repository_impl.dart`
- Create: `lib/features/driver/orders/domain/usecase/get_driver_pickup_manifest_usecase.dart`
- Test: `test/features/driver/orders/data/driver_pickup_manifest_data_source_test.dart`
- Test: `test/features/driver/orders/data/driver_pickup_manifest_repository_test.dart`
- Test: `test/features/driver/orders/domain/get_driver_pickup_manifest_usecase_test.dart`

**Interfaces:**
- `ApiServices.getDriverPickupManifest(@Query('statusFilter') String statusFilter)`.
- `GetDriverPickupManifestUseCase.call(DriverBoxesFilterType filter) → Future<ApiResult<DriverPickupManifestEntity>>`.

- [ ] **Step 1: Write failing forwarding tests**

Verify `PickedUp` reaches ApiServices unchanged, repository wraps the call with `safeApiCall`, and DTO mapping occurs only in RepositoryImpl.

- [ ] **Step 2: Run focused tests and confirm RED**

Run: `flutter test test/features/driver/orders/data test/features/driver/orders/domain`

- [ ] **Step 3: Add endpoint constant and Retrofit method**

```dart
static const String driverPickupManifest =
    '/api/v1/driver/pickup/manifest';

@GET(EndPoints.driverPickupManifest)
Future<DriverPickupManifestResponseDto> getDriverPickupManifest(
  @Query('statusFilter') String statusFilter,
);
```

- [ ] **Step 4: Implement DataSource → Repository → UseCase**

Use `@Injectable(as: ...)`, constructor injection, `safeApiCall`, and DTO mapper. Do not catch Dio errors in the data source.

- [ ] **Step 5: Generate, run tests, and commit**

Run build_runner, the three focused tests, then `flutter analyze` for touched files.

Commit: `feat: integrate driver pickup manifest api`

---

### Task 4: Manifest ViewModel, shimmer, errors, empty state, and real filtering

**Files:**
- Create: `lib/features/driver/orders/presentation/manager/driver_pickup_manifest_event.dart`
- Create: `lib/features/driver/orders/presentation/manager/driver_pickup_manifest_state.dart`
- Create: `lib/features/driver/orders/presentation/manager/driver_pickup_manifest_view_model.dart`
- Create: `lib/features/driver/orders/presentation/widgets/driver_assigned_boxes_shimmer.dart`
- Modify: `lib/features/driver/orders/presentation/screens/driver_assigned_boxes_screen.dart`
- Modify: `lib/features/driver/orders/presentation/widgets/driver_boxes_stats_banner.dart`, `driver_boxes_filter_bar.dart`, `driver_boxes_filter_tab_item.dart`, `driver_assigned_box_card.dart`, `driver_box_action_section.dart`, `driver_box_icon_badge.dart`, `driver_box_ids_section.dart`, `driver_box_meals_and_area_section.dart`, and `driver_box_status_pill.dart` to render canonical backend fields/counts and pickup terminology.
- Test: `test/features/driver/orders/presentation/driver_pickup_manifest_view_model_test.dart`
- Test: `test/features/driver/orders/presentation/driver_assigned_boxes_backend_test.dart`

**Interfaces:**
- Events: `LoadDriverPickupManifestEvent`, `RefreshDriverPickupManifestEvent`, `SelectDriverBoxesFilterEvent`, `RetryDriverPickupManifestEvent`.
- State fields: `manifest`, `selectedFilter`, `isInitialLoading`, `isRefreshLoading`, `isFilterLoading`, `failure`, `hasLoadedOnce`.

- [ ] **Step 1: Write ViewModel tests**

Cover initial load, filter loading, stale-request suppression, refresh failure retaining existing manifest, retry, and empty success.

- [ ] **Step 2: Write widget tests for the state decision table**

Assert:

```text
initial loading + no data → DriverAssignedBoxesShimmer
failure + no data → ApiErrorWidget with retry intent
success + empty boxes → EmptyStateWidget
filter loading → list-shaped shimmer, not full-page spinner
refresh failure + existing data → existing cards + InlineApiErrorWidget
content → backend counters and backend boxes
```

- [ ] **Step 3: Run tests and confirm RED**

Run: `flutter test test/features/driver/orders/presentation`

- [ ] **Step 4: Implement immutable State, sealed Event, and ViewModel**

Follow the request-generation pattern used by `DispatcherOrdersViewModel`; route every UI action through `doIntent`.

- [ ] **Step 5: Build screen-shaped shimmer**

Mirror title, stats card, three filter pills, and four box cards using `ShimmerWidget`. Keep it responsive at 320×640 and do not hardcode colors.

- [ ] **Step 6: Connect the existing screen**

Keep optional injected `viewModel` for tests. Remove production fallback to `DriverAssignedBoxesFakeData`. Stats use `totalBoxesCount/pickedUpBoxesCount`; filters use backend query values and keep previous content visible on refresh failure.

- [ ] **Step 7: Run tests and commit**

Commit: `feat: connect assigned boxes screen to manifest`

---

### Task 5: Barcode, photo, confirmation, summary, and start-trip models

**Files:**
- Create request models under `lib/features/driver/confirm_receipt/data/models/request/`.
- Create response models under `lib/features/driver/confirm_receipt/data/models/response/`.
- Create domain entities under `lib/features/driver/confirm_receipt/domain/entities/`.
- Create: `lib/features/driver/confirm_receipt/data/mapper/driver_pickup_mapper.dart`
- Test: `test/features/driver/confirm_receipt/data/driver_pickup_dto_mapper_test.dart`

**Interfaces:**
- `ValidateDriverBarcodeRequestEntity(barcodeValue)`.
- `ConfirmDriverPickupRequestEntity(validationToken, conditionPhotoStorageKey, latitude, longitude)`.
- `StartDriverTripRequestEntity(latitude, longitude)`.
- Entities: `DriverBarcodeValidationEntity`, `DriverConditionPhotoUploadEntity`, `DriverPickupConfirmationEntity`, `DriverPickupSummaryEntity`, `DriverTripStartEntity`.

- [ ] **Step 1: Write exact JSON contract tests**

Use the supplied backend samples, including `validationToken`, `expiresAtUtc`, `nextAction`, modern and legacy counters, summary boxes, and start-trip response.

- [ ] **Step 2: Write mapper fallback tests**

Require canonical `allBoxesPickedUp`, safe dates, empty list fallback, and no force unwraps.

- [ ] **Step 3: Run and confirm RED**

Run: `flutter test test/features/driver/confirm_receipt/data/driver_pickup_dto_mapper_test.dart`

- [ ] **Step 4: Implement request/response DTOs, entities, and mapper**

Use `@JsonSerializable(createFactory: false)` for request DTOs and `createToJson: false` for response DTOs. Keep backend messages available in entities but do not use them as control flow.

- [ ] **Step 5: Generate, test, and commit**

Commit: `feat: model secure driver pickup flow`

---

### Task 6: Complete secure pickup APIs through use cases

**Files:**
- Modify: `lib/core/network/network_constants.dart`
- Modify: `lib/core/network/api_services.dart`
- Create DataSource, Repository, and UseCase files under `lib/features/driver/confirm_receipt/`.
- Test corresponding data/repository/use-case files.

**Interfaces:**
- `validateDriverPickupBarcode(request)` → barcode validation.
- `uploadDriverBoxConditionPhoto(boxId, file, validationToken)` → photo upload.
- `confirmDriverBoxPickup(boxId, idempotencyKey, request)` → confirmation.
- `getDriverPickupSummary(tripId)` → resumable summary.
- `startDriverTrip(tripId, idempotencyKey, request)` → trip start.

- [ ] **Step 1: Write failing forwarding and header tests**

Verify multipart part names are exactly `file` and `validationToken`; headers use exactly `Idempotency-Key`; path parameters and JSON bodies match the docs.

- [ ] **Step 2: Run tests and confirm RED**

Run: `flutter test test/features/driver/confirm_receipt/data test/features/driver/confirm_receipt/domain`

- [ ] **Step 3: Add constants and Retrofit declarations**

```dart
@MultiPart()
@POST('/api/v1/driver/pickup/boxes/{boxId}/condition-photo')
Future<DriverConditionPhotoUploadResponseDto> uploadDriverBoxConditionPhoto(
  @Path('boxId') String boxId,
  @Part(name: 'file') File file,
  @Part(name: 'validationToken') String validationToken,
);

@POST('/api/v1/driver/pickup/boxes/{boxId}/confirm')
Future<DriverPickupConfirmationResponseDto> confirmDriverBoxPickup(
  @Path('boxId') String boxId,
  @Header('Idempotency-Key') String idempotencyKey,
  @Body() ConfirmDriverPickupRequestDto request,
);
```

Use these canonical routes from the supplied final contract:

```dart
@GET('/api/v1/driver/trips/{tripId}/pickup-summary')
Future<DriverPickupSummaryResponseDto> getDriverPickupSummary(
  @Path('tripId') String tripId,
);

@POST('/api/v1/driver/trips/{tripId}/start')
Future<DriverTripStartResponseDto> startDriverTrip(
  @Path('tripId') String tripId,
  @Header('Idempotency-Key') String idempotencyKey,
  @Body() StartDriverTripRequestDto request,
);
```

If the checked-in backend Swagger contradicts these paths, stop before code generation and obtain the controller's single authoritative route; never implement both alternatives or fallback-on-404 behavior.

- [ ] **Step 4: Implement clean layers**

RepositoryImpl alone owns `safeApiCall` and DTO→entity mapping. Keep files focused: one use case per operation.

- [ ] **Step 5: Generate, test, and commit**

Commit: `feat: integrate secure driver pickup apis`

---

### Task 7: Sequential pickup ViewModel and action error behavior

**Files:**
- Create: `lib/features/driver/confirm_receipt/presentation/manager/driver_pickup_flow_event.dart`
- Create: `lib/features/driver/confirm_receipt/presentation/manager/driver_pickup_flow_state.dart`
- Create: `lib/features/driver/confirm_receipt/presentation/manager/driver_pickup_flow_view_model.dart`
- Test: `test/features/driver/confirm_receipt/presentation/driver_pickup_flow_view_model_test.dart`

**Interfaces:**
- Events: barcode detected/manual submit, photo selected, upload photo, confirm pickup, retry failed stage, reset scan.
- State keeps `stage`, validated box, validation token/expiry, local photo path, uploaded storage key, confirmation, per-action loading, and `Failure?`.

- [ ] **Step 1: Write state-machine tests**

Cover:

```text
barcode success → BarcodeValidated
invalid barcode → remain scanner + Failure
photo upload success → PhotoUploaded
expired token → clear token and require rescan
confirm retry → same idempotency key
confirmation ShowBoxSuccess → individual success route signal
confirmation ShowPickupSummary → summary route signal
```

- [ ] **Step 2: Run and confirm RED**

Run: `flutter test test/features/driver/confirm_receipt/presentation/driver_pickup_flow_view_model_test.dart`

- [ ] **Step 3: Implement one immutable State and sealed Event set**

Do not parse backend strings in widgets. Normalize `nextAction` in the mapper/entity and expose derived getters such as `canContinueToPhoto`, `canConfirmPickup`, and `requiresRescan`.

- [ ] **Step 4: Implement private handlers**

Acquire location immediately before confirm, generate/store the idempotency key once, and preserve it on retry. Map location exceptions into existing typed `Failure` behavior.

- [ ] **Step 5: Run tests and commit**

Commit: `feat: orchestrate driver pickup workflow`

---

### Task 8: Connect scanner and camera UI to the pickup ViewModel

**Files:**
- Modify: `lib/features/driver/confirm_receipt/presentation/screens/driver_confirm_receipt_screen.dart`
- Modify scanner/manual/photo widgets only where callback signatures require values/loading/errors.
- Modify: `lib/config/routing/routing_generator.dart`
- Test: `test/features/driver/confirm_receipt/presentation/driver_confirm_receipt_backend_test.dart`
- Test: `test/config/routing/driver_pickup_routes_test.dart`

**Interfaces:**
- Scanner passes actual `Barcode.rawValue`; manual entry passes trimmed user input.
- UI never marks QR scanned until validate API succeeds.
- Confirm button triggers upload first when needed, then confirm; it never calls ApiServices directly.

- [ ] **Step 1: Write widget tests**

Assert action loading disables duplicate taps, validation errors use `InlineApiErrorWidget`, image upload errors preserve the captured image and offer retry, expired-token errors return to scan, and navigation follows `nextAction`.

- [ ] **Step 2: Run and confirm RED**

Run: `flutter test test/features/driver/confirm_receipt/presentation/driver_confirm_receipt_backend_test.dart`

- [ ] **Step 3: Replace local booleans with ViewModel state**

Keep camera ownership/disposal in the screen. Keep image picking/file preparation outside widgets where possible. Do not show a full-screen error for validate/upload/confirm failures because usable UI remains.

- [ ] **Step 4: Implement route results**

For `ShowBoxSuccess`, navigate to `driverBoxReceivedSuccess` with backend-derived entity, then return to assigned boxes and refresh manifest. For `ShowPickupSummary`, replace the scanner route with `driverBoxesReceived` carrying `tripId`.

- [ ] **Step 5: Run tests and commit**

Commit: `feat: connect barcode and photo pickup screens`

---

### Task 9: Resumable summary, shimmer, and start-trip flow

**Files:**
- Create summary manager files under `confirm_receipt/presentation/manager/`.
- Create: `lib/features/driver/confirm_receipt/presentation/widgets/driver_boxes_received_shimmer.dart`
- Modify: `lib/features/driver/confirm_receipt/presentation/screens/driver_boxes_received_screen.dart`
- Modify received summary widgets to accept backend counters/items.
- Create: `lib/config/routing/arguments/driver_confirm_receipt_route_arguments.dart`
- Create: `lib/config/routing/arguments/driver_pickup_summary_route_arguments.dart`
- Modify: `lib/config/routing/routing_generator.dart`
- Test: `test/features/driver/confirm_receipt/presentation/driver_pickup_summary_view_model_test.dart`
- Test: `test/features/driver/confirm_receipt/presentation/driver_boxes_received_backend_test.dart`

**Interfaces:**
- Events: `LoadDriverPickupSummaryEvent(tripId)`, `RetryDriverPickupSummaryEvent`, `StartDriverTripEvent`.
- State fields: summary, initial/action loading, failure, start result, persistent start idempotency key.

- [ ] **Step 1: Write ViewModel and widget tests**

Cover initial shimmer, `ApiErrorWidget` retry, empty summary, `canStartTrip == false`, action error with content retained, start retry with same key, and successful navigation.

- [ ] **Step 2: Run and confirm RED**

Run: `flutter test test/features/driver/confirm_receipt/presentation/driver_*summary* test/features/driver/confirm_receipt/presentation/driver_boxes_received_backend_test.dart`

- [ ] **Step 3: Implement summary ViewModel**

Load by `tripId`, acquire location only when start is tapped, call start use case, and keep content visible on failures.

- [ ] **Step 4: Implement summary shimmer and bind real data**

Shimmer mirrors success banner, three counters, five received rows, safety card, and action. UI uses `assignedBoxesCount`, `validatedBoxesCount`, `receivedBoxesCount`, backend box code/customer/status, and `canStartTrip`.

- [ ] **Step 5: Navigate after successful start**

Use the existing route expected by the product flow (`AppRoutes.driverStartDeliveryRoute`/active home decision already used by this repo) and clear pickup screens from the stack. Do not navigate merely because the button was tapped.

- [ ] **Step 6: Run tests and commit**

Commit: `feat: connect pickup summary and trip start`

---

### Task 10: Localization, DI, regression cleanup, and full verification

**Files:**
- Modify: `lib/core/l10n/app_ar.arb`
- Modify: `lib/core/l10n/app_en.arb`
- Generated localization files — regenerate only.
- Modify: `lib/core/di/di.dart` only according to the repo's active registration convention.
- Modify/migrate existing driver tests.
- Remove production references to fake data; retain fixture files only if tests still intentionally use them.

**Interfaces:**
- No new public behavior; consolidates generated wiring and regression coverage.

- [ ] **Step 1: Add localized copy for loading/empty/action states**

Include pickup-specific empty state, retry labels already reusable from Core, photo uploading, pickup confirming, starting trip, token-expired guidance, and received/pending labels. Do not display backend messages as the only localized UX.

- [ ] **Step 2: Regenerate code**

Run:

```bash
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
dart format lib test
```

- [ ] **Step 3: Run focused driver suites**

Run:

```bash
flutter test test/features/driver/orders
flutter test test/features/driver/confirm_receipt
flutter test test/driver_assigned_boxes_screen_test.dart
flutter test test/driver_confirm_receipt_screen_test.dart
```

Expected: all PASS; no fake production transitions remain.

- [ ] **Step 4: Run static and full regression verification**

Run:

```bash
flutter analyze
flutter test
```

Expected: no new analyzer errors and all tests pass. If unrelated pre-existing failures exist, record exact test names/output and prove focused pickup suites pass.

- [ ] **Step 5: Manual QA checklist**

Verify Arabic and English, RTL/LTR, 320×640 and standard phone sizes, camera permission denial, invalid/other-driver barcode, manual barcode entry, expired token after five minutes, photo type/size failure, confirm double-tap, app resume on summary, start-trip double-tap, no active trip, offline initial load, and offline action retry.

- [ ] **Step 6: Commit final integration**

Commit: `test: verify driver pickup flow integration`

---

## Final Acceptance Criteria

- Production screens 06.02–06.05 contain no fake pickup data or local fake status mutations.
- Manifest filters send exactly `All`, `PendingScan`, or `PickedUp`.
- A box becomes complete only after barcode validation, condition-photo upload, and successful confirm.
- `validationToken`, `conditionPhotoStorageKey`, GPS coordinates, and `Idempotency-Key` are transmitted exactly as contracted.
- Confirm/start retries reuse the operation's original idempotency key.
- `ShowBoxSuccess` and `ShowPickupSummary` drive navigation; widgets do not infer completion from local counters.
- Summary can be reconstructed after process death from `GET .../pickup-summary`.
- Initial loads use shimmer; Core typed error widgets and empty state are reused correctly.
- Generated Retrofit/JSON/localization/DI code is current, analyzer is clean for the change, and focused/full tests pass.
