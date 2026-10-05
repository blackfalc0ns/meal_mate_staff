# Driver Home Operational Status Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the fake driver-controlled shift flow with a backend-controlled Driver Home flow (`GET /api/v1/driver/home`) where the delivery manager controls operational status, listening for `driver-status-updated` via SignalR, rendering Active or Inactive mode in-place with shimmer and typed errors, and removing driver self-shift actions.

**Architecture:** Unified `DriverHome` feature using Feature-Based Clean Architecture. Single authoritative `DriverHomeViewModel` with `doIntent` handling load, retry, resume, and SignalR reloads with request coalescing. Shared singleton `DriverOrdersSignalRClient` on `EndPoints.driverHub` extended for `driver-status-updated` events. Tab 0 in `AppShellScreen` and `AppRoutes.driverHome` resolve to `DriverHomeScreen`, switching between `DriverActiveHomeView` and `DriverInactiveHomeView` without route pushes.

**Tech Stack:** Flutter, Dart, Retrofit/Dio, json_serializable, flutter_bloc, GetIt, SignalR, Core `ApiResult`/`safeApiCall`, Core `lib/core/errors`, Core `ShimmerWidget`, flutter_test.

**Spec:** `docs/superpowers/specs/2026-10-05-driver-home-operational-status-design.md`

## Global Constraints

- Follow `rules/rules_backend.md`; flow is UI → Event/doIntent → ViewModel → UseCase → Repository → RemoteDataSource → `ApiServices`.
- Use existing injected `Dio`, token interceptor, language interceptor; do not add new HTTP clients or packages.
- Add `EndPoints.driverHome = '/api/v1/driver/home'` and single `@GET` in `ApiServices`.
- Response DTO fields and nested DTO fields are nullable; domain nullability preserves meaningful absence.
- Mapper normalizes `Active` case-insensitively to `DriverShiftStatus.active`; null, `Inactive`, `Offline`, or unknown to `DriverShiftStatus.inactive`.
- Initial load uses `DriverHomeShimmer`; content-preserving refresh retains current content and never returns to full-screen shimmer.
- No-data failure uses Core `ApiErrorWidget.fromTypedFailure`; refresh failure uses `InlineApiErrorWidget`.
- SignalR listens to `driver-status-updated` on existing shared connection (`EndPoints.driverHub`) and triggers reload without patching local data.
- Driver has no Start Shift or End Shift actions; remove `StartDriverShiftUseCase`, `startShift` repository/datasource methods, and obsolete Start Work action buttons.
- Do not create a new git branch and do not create git commits.

## Review Focus

1. Missing or unknown `shiftStatus` in API response safely falls back to `DriverShiftStatus.inactive`.
2. `isAvailable` does not decide Active vs Inactive; within Active Home, `isAvailable == false` remains Active (busy mode).
3. Concurrent reload triggers (e.g. SignalR event arriving while initial fetch or lifecycle resume is in-flight) are coalesced so at most one follow-up fetch executes without dropped events.
4. Refresh failure when data already exists retains the existing Home content and displays `InlineApiErrorWidget` non-destructively.
5. SignalR reconnect (false-to-true transition) produces exactly one Home reload without race conditions.

---

## File Structure

### Create
- `lib/features/driver/home/data/models/response/driver_home_response_dto.dart` — defensive DTO graph with nested target progress, delivery task, today summary, daily performance, and active session DTOs.
- `lib/features/driver/home/data/mapper/driver_home_mapper.dart` — mapping DTO to domain entities, normalizing shiftStatus.
- `lib/features/driver/home/data/datasources/driver_home_remote_datasource.dart` — remote datasource interface.
- `lib/features/driver/home/data/datasources/driver_home_remote_datasource_impl.dart` — remote datasource implementation calling `ApiServices`.
- `lib/features/driver/home/domain/entities/driver_home_entity.dart` — unified Home domain entity with `DriverShiftStatus` enum and nested entities.
- `lib/features/driver/home/domain/usecases/get_driver_home_usecase.dart` — domain usecase for getting Home overview.
- `lib/features/driver/home/presentation/manager/driver_home_event.dart` — sealed events (`DriverHomeLoadStarted`, `DriverHomeRefreshRequested`, `DriverHomeRetryRequested`, `DriverHomeLifecycleResumed`, `DriverHomeStatusUpdatedReceived`, `DriverHomeSignalRReconnected`).
- `lib/features/driver/home/presentation/manager/driver_home_state.dart` — immutable state with `copyWith`.
- `lib/features/driver/home/presentation/manager/driver_home_view_model.dart` — single authoritative ViewModel with coalescing and realtime listening.
- `lib/features/driver/home/presentation/widgets/driver_home_shimmer.dart` — skeleton loader using `ShimmerWidget`.
- `lib/features/driver/home/presentation/widgets/inactive_home/driver_inactive_home_view.dart` — read-only Inactive Home display.
- `lib/features/driver/home/presentation/widgets/active_home/driver_active_home_view.dart` — Active Home content bound to `DriverHomeEntity`.
- `lib/features/driver/home/presentation/screens/driver_home_screen.dart` — unified Home screen observing lifecycle and state.
- Tests under `test/features/driver/home/` matching each layer.

### Modify
- `lib/core/network/network_constants.dart` — add `EndPoints.driverHome`.
- `lib/core/network/api_services.dart` — add `@GET(EndPoints.driverHome)` method.
- `lib/features/driver/orders/domain/entities/driver_orders_realtime_event.dart` — add `DriverStatusUpdatedEvent`.
- `lib/features/driver/orders/data/models/realtime/driver_orders_realtime_event_dto.dart` — parse `driver-status-updated`.
- `lib/features/driver/orders/data/realtime/driver_orders_signalr_client.dart` — add `'driver-status-updated'` to `supportedEvents`.
- `lib/features/driver/home/domain/repositories/driver_home_repository.dart` — update contract to `getDriverHome()`.
- `lib/features/driver/home/data/repositories/driver_home_repository_impl.dart` — implement `getDriverHome()` with `safeApiCall`.
- `lib/core/app_shell/screens/app_shell_screen.dart` — set tab 0 to `DriverHomeScreen`.
- `lib/config/routing/routing_generator.dart` — route `AppRoutes.driverHome` and `AppRoutes.driverStartWork` to `DriverHomeScreen`.
- `lib/core/di/di.dart` — register `DriverHomeRemoteDataSource`, `DriverHomeRepository`, `GetDriverHomeUseCase`, `DriverHomeViewModel`; remove obsolete `StartDriverShiftUseCase`.
- `lib/core/l10n/app_en.arb` and `app_ar.arb` — add localization keys for manager-controlled status and inactive screen.

---

### Task 1: Defensive DTO and JSON Serialization

**Files:**
- Create: `lib/features/driver/home/data/models/response/driver_home_response_dto.dart`
- Test: `test/features/driver/home/data/models/driver_home_response_dto_test.dart`

**Interfaces:**
- Produces: `DriverHomeResponseDto`, `DriverHomeTargetProgressResponseDto`, `DriverHomeCurrentDeliveryTaskResponseDto`, `DriverHomeTodaySummaryResponseDto`, `DriverHomeDailyPerformanceResponseDto`, `DriverHomeActiveSessionResponseDto`.

- [ ] **Step 1: Write DTO parsing unit tests**
Test full Inactive response, Active available response, Active busy response with full delivery task fields, and tolerance for omitted/null fields.

- [ ] **Step 2: Run test to verify it fails**
Run: `flutter test test/features/driver/home/data/models/driver_home_response_dto_test.dart`

- [ ] **Step 3: Implement `DriverHomeResponseDto` and nested DTOs**
All fields nullable, matching camelCase backend contract exactly. Add `@JsonSerializable()`.

- [ ] **Step 4: Run build_runner to generate `.g.dart`**
Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 5: Run tests to verify they pass**
Run: `flutter test test/features/driver/home/data/models/driver_home_response_dto_test.dart`

---

### Task 2: Domain Entities and Mapper Normalization

**Files:**
- Create: `lib/features/driver/home/domain/entities/driver_home_entity.dart`
- Create: `lib/features/driver/home/data/mapper/driver_home_mapper.dart`
- Test: `test/features/driver/home/data/mapper/driver_home_mapper_test.dart`

**Interfaces:**
- Produces:
  - `enum DriverShiftStatus { active, inactive }`
  - `DriverHomeEntity`, `DriverHomeTargetProgressEntity`, `DriverHomeCurrentDeliveryTaskEntity`, `DriverHomeTodaySummaryEntity`, `DriverHomeDailyPerformanceEntity`, `DriverHomeActiveSessionEntity`
  - `DriverHomeResponseDtoMapper.toEntity()`

- [ ] **Step 1: Write mapper unit tests**
Test normalization: `"Active"` -> `active`, `"active"` -> `active`, `"ACTIVE"` -> `active`, `"Inactive"` -> `inactive`, `"Offline"` -> `inactive`, `null` -> `inactive`, unknown string -> `inactive`. Test that null operational sections remain null. Test fallback text for missing driver identity.

- [ ] **Step 2: Run test to verify it fails**
Run: `flutter test test/features/driver/home/data/mapper/driver_home_mapper_test.dart`

- [ ] **Step 3: Implement Domain Entities and `DriverHomeMapper`**
Clean domain entities without JSON annotations. Mapper handles normalization and non-crashing defaults.

- [ ] **Step 4: Run tests to verify they pass**
Run: `flutter test test/features/driver/home/data/mapper/driver_home_mapper_test.dart`

---

### Task 3: Network Endpoint, Remote Data Source, and Repository Implementation

**Files:**
- Modify: `lib/core/network/network_constants.dart`
- Modify: `lib/core/network/api_services.dart`
- Create: `lib/features/driver/home/data/datasources/driver_home_remote_datasource.dart`
- Create: `lib/features/driver/home/data/datasources/driver_home_remote_datasource_impl.dart`
- Modify: `lib/features/driver/home/domain/repositories/driver_home_repository.dart`
- Modify: `lib/features/driver/home/data/repositories/driver_home_repository_impl.dart`
- Create: `lib/features/driver/home/domain/usecases/get_driver_home_usecase.dart`
- Test: `test/features/driver/home/data/repositories/driver_home_repository_impl_test.dart`

**Interfaces:**
- Consumes: `ApiServices.getDriverHome()`, `safeApiCall`
- Produces: `DriverHomeRepository.getDriverHome() -> Future<ApiResult<DriverHomeEntity>>`, `GetDriverHomeUseCase`

- [ ] **Step 1: Write repository unit tests**
Test success returns `ApiResult.success(entity)`, test Dio failure returns `ApiResult.failure(failure)`.

- [ ] **Step 2: Run test to verify it fails**
Run: `flutter test test/features/driver/home/data/repositories/driver_home_repository_impl_test.dart`

- [ ] **Step 3: Implement endpoint constant, Retrofit method, RemoteDataSource, Repository, and UseCase**
Add `EndPoints.driverHome = '/api/v1/driver/home'`. Add `@GET(EndPoints.driverHome) Future<DriverHomeResponseDto> getDriverHome();`. Implement `DriverHomeRemoteDataSourceImpl` and `DriverHomeRepositoryImpl` using `safeApiCall`. Implement `GetDriverHomeUseCase`.

- [ ] **Step 4: Run build_runner for Retrofit**
Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 5: Run repository tests to verify they pass**
Run: `flutter test test/features/driver/home/data/repositories/driver_home_repository_impl_test.dart`

---

### Task 4: Realtime Event Extension (`driver-status-updated`)

**Files:**
- Modify: `lib/features/driver/orders/domain/entities/driver_orders_realtime_event.dart`
- Modify: `lib/features/driver/orders/data/models/realtime/driver_orders_realtime_event_dto.dart`
- Modify: `lib/features/driver/orders/data/realtime/driver_orders_signalr_client.dart`
- Test: `test/features/driver/orders/data/driver_orders_signalr_status_updated_test.dart`

**Interfaces:**
- Produces: `DriverStatusUpdatedEvent`, `'driver-status-updated'` in `DriverOrdersSignalRClient.supportedEvents`

- [ ] **Step 1: Write realtime event parser test**
Test that `DriverOrdersRealtimeEventDto.fromPayload('driver-status-updated', ...)` parses into `DriverStatusUpdatedEvent`. Test that `DriverOrdersSignalRClient.supportedEvents` contains `'driver-status-updated'`.

- [ ] **Step 2: Run test to verify it fails**
Run: `flutter test test/features/driver/orders/data/driver_orders_signalr_status_updated_test.dart`

- [ ] **Step 3: Implement `DriverStatusUpdatedEvent`, parsing, and client registration**
Add `DriverStatusUpdatedEvent` to `driver_orders_realtime_event.dart`. Update parser in `driver_orders_realtime_event_dto.dart`. Add `'driver-status-updated'` to `supportedEvents` in `driver_orders_signalr_client.dart`.

- [ ] **Step 4: Run tests to verify they pass**
Run: `flutter test test/features/driver/orders/data/driver_orders_signalr_status_updated_test.dart`

---

### Task 5: Presentation ViewModel and State Management

**Files:**
- Create: `lib/features/driver/home/presentation/manager/driver_home_state.dart`
- Create: `lib/features/driver/home/presentation/manager/driver_home_event.dart`
- Create: `lib/features/driver/home/presentation/manager/driver_home_view_model.dart`
- Test: `test/features/driver/home/presentation/manager/driver_home_view_model_test.dart`

**Interfaces:**
- Consumes: `GetDriverHomeUseCase`, `DriverOrdersRealtimeClient`
- Produces: `DriverHomeViewModel.doIntent(DriverHomeEvent)`

- [ ] **Step 1: Write ViewModel unit tests**
Test:
1. Initial load success for Inactive.
2. Initial load success for Active available.
3. Active busy remains Active when `isAvailable == false`.
4. Initial load failure stores typed Failure.
5. Retry reloads only Home.
6. Refresh failure retains existing entity.
7. `DriverStatusUpdatedEvent` triggers Home reload but does not apply payload values.
8. Reconnect and resume trigger Home reload.
9. Simultaneous triggers are coalesced and latest refresh is not lost.
10. Stream subscriptions are cancelled on close.

- [ ] **Step 2: Run test to verify it fails**
Run: `flutter test test/features/driver/home/presentation/manager/driver_home_view_model_test.dart`

- [ ] **Step 3: Implement `DriverHomeState`, `DriverHomeEvent`, and `DriverHomeViewModel`**
Implement single `doIntent`, private handlers, request coalescing flag (`_hasPendingReload`), content-preserving refresh, realtime and connection-status subscriptions.

- [ ] **Step 4: Run tests to verify they pass**
Run: `flutter test test/features/driver/home/presentation/manager/driver_home_view_model_test.dart`

---

### Task 6: UI Components — Shimmer, Inactive View, and Active View

**Files:**
- Create: `lib/features/driver/home/presentation/widgets/driver_home_shimmer.dart`
- Create: `lib/features/driver/home/presentation/widgets/inactive_home/driver_inactive_home_view.dart`
- Create: `lib/features/driver/home/presentation/widgets/active_home/driver_active_home_view.dart`
- Modify: `lib/core/l10n/app_en.arb`
- Modify: `lib/core/l10n/app_ar.arb`
- Test: `test/features/driver/home/presentation/widgets/driver_home_views_test.dart`

**Interfaces:**
- Consumes: `DriverHomeEntity`, `ShimmerWidget`
- Produces: `DriverHomeShimmer`, `DriverInactiveHomeView`, `DriverActiveHomeView`

- [ ] **Step 1: Add localization keys and generate l10n**
Add `driverInactiveControlledByManager` in English and Arabic. Run `flutter gen-l10n`.

- [ ] **Step 2: Write widget tests for Inactive and Active views**
Test Inactive view renders identity, status, manager controlled explanation, and no Start Work button or notification count. Test Active view renders header, status, task card only when task exists.

- [ ] **Step 3: Run widget tests to verify they fail**
Run: `flutter test test/features/driver/home/presentation/widgets/driver_home_views_test.dart`

- [ ] **Step 4: Implement `DriverHomeShimmer`, `DriverInactiveHomeView`, and `DriverActiveHomeView`**
Preserve design system, colors, typography, directional layout.

- [ ] **Step 5: Run widget tests to verify they pass**
Run: `flutter test test/features/driver/home/presentation/widgets/driver_home_views_test.dart`

---

### Task 7: Unified `DriverHomeScreen` and Shell Integration

**Files:**
- Create: `lib/features/driver/home/presentation/screens/driver_home_screen.dart`
- Modify: `lib/core/app_shell/screens/app_shell_screen.dart`
- Modify: `lib/config/routing/routing_generator.dart`
- Test: `test/features/driver/home/presentation/screens/driver_home_screen_test.dart`

**Interfaces:**
- Produces: `DriverHomeScreen` rendering 4 states (shimmer, Core ApiErrorWidget, Inactive, Active) with lifecycle observer.

- [ ] **Step 1: Write screen widget tests**
Test 4 states:
1. `home == null && isLoading` renders `DriverHomeShimmer`.
2. `home == null && failure != null` renders `ApiErrorWidget.fromTypedFailure`; Retry dispatches retry intent.
3. `home != null && inactive` renders `DriverInactiveHomeView`.
4. `home != null && active` renders `DriverActiveHomeView`.
5. Refresh failure renders `InlineApiErrorWidget` non-destructively.
6. Lifecycle resume dispatches resume intent.

- [ ] **Step 2: Run test to verify it fails**
Run: `flutter test test/features/driver/home/presentation/screens/driver_home_screen_test.dart`

- [ ] **Step 3: Implement `DriverHomeScreen` and update navigation**
Wire lifecycle resume in `WidgetsBindingObserver`. In `AppShellScreen`, make tab 0 `DriverHomeScreen`. In `routing_generator.dart`, route `AppRoutes.driverHome` and `AppRoutes.driverStartWork` to `DriverHomeScreen`.

- [ ] **Step 4: Run tests to verify they pass**
Run: `flutter test test/features/driver/home/presentation/screens/driver_home_screen_test.dart`

---

### Task 8: DI Registration and Removal of Driver Self-Shift

**Files:**
- Modify: `lib/core/di/di.dart`
- Delete/Clean up: obsolete `StartDriverShiftUseCase`, `startShift` methods, unused fake datasource methods.
- Test: `test/features/driver/home/di_and_cleanup_test.dart`

- [ ] **Step 1: Update DI in `lib/core/di/di.dart`**
Register `DriverHomeRemoteDataSource`, `DriverHomeRepository`, `GetDriverHomeUseCase`, and `DriverHomeViewModel`. Remove `StartDriverShiftUseCase` and `DriverStartWorkViewModel` registrations.

- [ ] **Step 2: Remove obsolete startShift references across the codebase**
Confirm no calls to `startShift`, `shift/start`, `shift/end`, Start Work buttons remain.

- [ ] **Step 3: Run build_runner and check code analysis**
Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter analyze`

- [ ] **Step 4: Run all Driver Home and realtime tests**
Run: `flutter test test/features/driver/home/`

---

### Task 9: Verification and Acceptance Scenarios

**Files:**
- Test: `test/features/driver/home/driver_home_acceptance_test.dart`

- [ ] **Step 1: Implement end-to-end acceptance tests**
Cover the 6 spec scenarios:
1. Inactive login shows disconnected Home.
2. Dispatcher activation sends event; app reloads Home and shows Active.
3. Missed offline event recovered by reconnect/resume fetch.
4. Assigned order keeps Home Active with `isAvailable == false` and shows task.
5. Dispatcher deactivation moves app to Inactive while SignalR stays ready.
6. No Start/End Shift action or obsolete `Offline` check remains.

- [ ] **Step 2: Run acceptance tests**
Run: `flutter test test/features/driver/home/driver_home_acceptance_test.dart`

- [ ] **Step 3: Run full Flutter test suite and verify no regressions**
Run: `flutter test`
Document any pre-existing unrelated test failures.

- [ ] **Step 4: Format code and verify working tree**
Run: `dart format lib test`
Verify: NO commits created, NO new branches created, git working tree holds only required changes.
