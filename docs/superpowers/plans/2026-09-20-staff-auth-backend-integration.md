# Staff Authentication and Driver Registration Backend Integration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace fake authentication, driver-registration, and application-status data with the documented backend while preserving every existing screen and visual design.

**Architecture:** Keep one shared `auth` feature for the APIs and business rules common to Driver and DeliveryManager, then use small role-specific coordinators in `driver_auth` and `dispatcher_auth` to decide navigation. Keep driver registration in `register`, registration status in `account_status`, and only generic networking, token, error, and dependency-injection infrastructure in `core`.

**Tech Stack:** Flutter, Dart, Dio, Retrofit, GetIt/Injectable, json_serializable, flutter_secure_storage, SharedPreferences, Flutter test.

**Spec:** `D:/yahya/meal meat/auth/README.md` and its linked screen specifications. Mandatory integration rules: `rules/rules_backend.md`.

## Global Constraints

- Do not redesign, restyle, rename, or move existing screens and widgets unless a backend binding strictly requires it.
- Preserve the existing theme, localization, navigation, shared widgets, and feature naming.
- Use the existing `Dio`, `ApiServices`, `ApiResult`, `safeApiCall`, failure mapping, interceptors, GetIt setup, `TokenService`, and `LanguageService`.
- Do not create a second Dio instance or a second API client.
- UI consumes entities, states, and events only; response/request DTOs never reach widgets or the domain layer.
- Response DTO fields are nullable by default; required request DTO fields remain required according to the API contract.
- Do not invent endpoints. Resolve missing contract details against backend documentation before implementing the affected operation.
- Keep fake data until every production use has been replaced and tested.
- Shared auth endpoints use `role: Driver` or `role: DeliveryManager`; driver-registration endpoints are Driver-only.
- Keep `core` free of feature business logic. Auth repositories/use cases belong in `features/auth`.

---

## Target Feature Boundaries

```text
lib/features/
├── auth/                    # Shared staff authentication
├── driver_auth/             # Driver-specific routing decisions
├── dispatcher_auth/         # DeliveryManager-specific routing decisions
├── register/                # Driver registration and resubmission
├── account_status/          # Driver application status
├── driver/                  # Authenticated driver application
└── dispatcher/              # Authenticated dispatcher application
```

Shared endpoints:

```text
POST /api/v1/auth/staff/lookup-phone
POST /api/v1/auth/staff/verify-first-time-otp
POST /api/v1/auth/staff/set-password
POST /api/v1/auth/staff/login
POST /api/v1/auth/staff/forgot-password
POST /api/v1/auth/staff/reset-password
POST /api/v1/auth/staff/resend-otp
```

Driver-only endpoints:

```text
GET  /api/v1/auth/staff/driver-registration/restaurants
POST /api/v1/auth/staff/driver-registration/upload
POST /api/v1/auth/staff/driver-registration
GET  /api/v1/auth/staff/driver-registration/status
POST /api/v1/auth/staff/driver-registration/{registrationId}/resubmit
```

---

### Task 1: Upgrade the Existing Core API Infrastructure

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/main.dart`
- Modify: `lib/core/network/api_services.dart`
- Modify: `lib/core/network/network_constants.dart`
- Modify: `lib/core/di/di.dart`
- Test: `test/core/network/api_services_test.dart`
- Test: `test/core/di/di_test.dart`

**Interfaces:**
- Consumes: existing `Dio`, `TokenInterceptor`, `LanguageInterceptor`, and `PrettyDioLogger` registrations.
- Produces: one injected `ApiServices` with all documented staff-auth and driver-registration methods.

- [ ] Add compatible `retrofit`, `json_annotation`, and `injectable` runtime packages, plus `build_runner`, `retrofit_generator`, `json_serializable`, and `injectable_generator` dev packages.
- [ ] Write tests proving `configureDependencies()` exposes one `Dio` and one `ApiServices`, and that both resolve to the same Dio graph.
- [ ] Run the focused tests and confirm they fail before the Retrofit/DI work.
- [ ] Convert the existing `ApiServices` in place to the project's Retrofit client; do not introduce feature-specific clients.
- [ ] Add named constants for every documented endpoint without duplicating the base URL in feature files.
- [ ] Change `main()` to call `WidgetsFlutterBinding.ensureInitialized()` and await `configureDependencies()` before `runApp`.
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`.
- [ ] Run focused tests, `flutter analyze`, and commit the infrastructure change.

### Task 2: Define Shared Authentication Domain Contracts

**Files:**
- Modify: `lib/features/auth/domain/user_role.dart`
- Create: `lib/features/auth/domain/entities/auth_session_entity.dart`
- Create: `lib/features/auth/domain/entities/auth_user_entity.dart`
- Create: `lib/features/auth/domain/entities/phone_lookup_request_entity.dart`
- Create: `lib/features/auth/domain/entities/phone_lookup_result_entity.dart`
- Create: request entities for OTP, password setup, login, forgot/reset password, and resend OTP under `lib/features/auth/domain/entities/`
- Create: `lib/features/auth/domain/repo/auth_repository.dart`
- Create: auth use cases under `lib/features/auth/domain/usecase/`
- Test: `test/features/auth/domain/`

**Interfaces:**
- Consumes: the existing role selected by the UI.
- Produces: `AuthRepository` methods returning `Future<ApiResult<...>>`, and role mapping with API values `Driver` and `DeliveryManager`.

- [ ] Write tests for role-to-API mapping and every use case delegation.
- [ ] Define one role model shared by both flows; preserve existing `UserRole` usages where possible instead of adding competing enums.
- [ ] Define `PhoneLookupResultEntity` with the routing information returned by the backend: role, phone, existence/setup state, staff status, application status, registration ID, and approval state.
- [ ] Define `AuthSessionEntity` with access token, refresh token, role, user identity, phone, and expiry data supported by the contract.
- [ ] Define request entities for all shared operations so widgets never construct DTOs.
- [ ] Define `AuthRepository` and the nine use cases: lookup, verify first-time OTP, set password, login, forgot password, reset password, resend OTP, restore session, and logout.
- [ ] Run domain tests and commit.

### Task 3: Implement Shared Authentication Data Layer

**Files:**
- Create: `lib/features/auth/data/models/request/*.dart`
- Create: `lib/features/auth/data/models/response/*.dart`
- Create: `lib/features/auth/data/mapper/auth_request_mapper.dart`
- Create: `lib/features/auth/data/mapper/auth_response_mapper.dart`
- Create: `lib/features/auth/data/mapper/staff_role_mapper.dart`
- Create: `lib/features/auth/data/data_source/auth_remote_data_source.dart`
- Create: `lib/features/auth/data/data_source/auth_remote_data_source_impl.dart`
- Create: `lib/features/auth/data/repo/auth_repository_impl.dart`
- Modify: `lib/core/di/di.dart`
- Test: `test/features/auth/data/`

**Interfaces:**
- Consumes: auth request entities and shared `ApiServices`.
- Produces: defensive response DTOs mapped to domain entities and returned through `ApiResult`.

- [ ] Write DTO parsing tests for complete responses, missing properties, explicit nulls, and nested null values.
- [ ] Write mapper tests for every request and response, including exact role strings.
- [ ] Implement required request DTO fields according to the documented request bodies.
- [ ] Implement nullable response DTO fields and generated JSON serialization; never force-unwrap API values.
- [ ] Implement the remote-data-source contract and implementation as thin `ApiServices` delegates.
- [ ] Implement `AuthRepositoryImpl` using `safeApiCall` and mappers.
- [ ] Register data source, repository, and use cases with the existing GetIt setup.
- [ ] Generate code, run data tests, and commit.

### Task 4: Complete Session Storage, Refresh, and Logout

**Files:**
- Modify: `lib/core/services/token_service.dart`
- Modify: `lib/core/services/token_interceptor.dart`
- Modify: `lib/core/services/auth_refresh_service.dart`
- Modify: `lib/core/di/di.dart`
- Test: `test/core/services/token_service_test.dart`
- Test: `test/core/services/auth_refresh_service_test.dart`
- Test: `test/core/services/token_interceptor_test.dart`

**Interfaces:**
- Consumes: authenticated response tokens and the existing secure/local storage instances.
- Produces: persisted/restored sessions, one refresh attempt per expired request, and a deterministic signed-out state after refresh failure.

- [ ] Write tests proving sensitive tokens use `FlutterSecureStorage` and only non-sensitive preferences use `SharedPreferences`.
- [ ] Write concurrency tests proving simultaneous 401 responses share one refresh operation.
- [ ] Implement atomic save, read, and clear operations for the supported token/session fields.
- [ ] Implement refresh using the documented refresh contract already represented by `EndPoints.refresh`.
- [ ] Retry the original request once after successful refresh and prevent recursive refresh loops.
- [ ] Clear the session and expose an unauthorized outcome when refresh fails.
- [ ] Run service tests and commit.

### Task 5: Add Shared Auth ViewModel and Bind Existing Screens

**Files:**
- Create: `lib/features/auth/presentation/manager/auth_event.dart`
- Create: `lib/features/auth/presentation/manager/auth_state.dart`
- Create: `lib/features/auth/presentation/manager/auth_view_model.dart`
- Modify: existing screens in `lib/features/auth/presentation/screens/`
- Preserve: existing widgets in `lib/features/auth/presentation/widgets/`
- Test: `test/features/auth/presentation/auth_view_model_test.dart`
- Modify/Test: existing `test/auth_flow_widget_test.dart` and related auth widget tests.

**Interfaces:**
- Consumes: shared auth use cases and request entities.
- Produces: loading, lookup success, OTP sent/verified, password set/reset, authenticated, and failure states.

- [ ] Write state-transition tests for every auth operation and duplicate-submit prevention.
- [ ] Define explicit events for lookup, OTP verification/resend, set password, login, forgot/reset password, session restoration, and logout.
- [ ] Implement state with selected role, phone, lookup result, session, failure, and OTP resend timing.
- [ ] Bind current text fields and buttons to the ViewModel without changing layout, typography, colors, spacing, or widgets.
- [ ] Disable submitting actions while their request is active and preserve form values on failure.
- [ ] Map failures through the existing localized error layer; keep `try/catch` out of widgets.
- [ ] Replace production uses of `AuthFakeData` only after their real equivalents pass tests.
- [ ] Run ViewModel and widget tests, capture a before/after visual sanity check, and commit.

### Task 6: Implement Role-Specific Auth Coordinators

**Files:**
- Create: `lib/features/driver_auth/domain/driver_auth_destination.dart`
- Create: `lib/features/driver_auth/domain/resolve_driver_auth_destination.dart`
- Create: `lib/features/driver_auth/presentation/manager/driver_auth_coordinator.dart`
- Create: `lib/features/dispatcher_auth/domain/dispatcher_auth_destination.dart`
- Create: `lib/features/dispatcher_auth/domain/resolve_dispatcher_auth_destination.dart`
- Create: `lib/features/dispatcher_auth/presentation/manager/dispatcher_auth_coordinator.dart`
- Test: `test/features/driver_auth/resolve_driver_auth_destination_test.dart`
- Test: `test/features/dispatcher_auth/resolve_dispatcher_auth_destination_test.dart`

**Interfaces:**
- Consumes: `PhoneLookupResultEntity` from shared auth.
- Produces: typed navigation destinations without performing network calls.

- [ ] Write table-driven driver tests for registration, Submitted, NeedsChanges, Rejected, Approved/first-time, active/password, and authenticated-home destinations.
- [ ] Write dispatcher tests for first-time OTP, password login, authenticated home, and missing-account error.
- [ ] Implement pure destination resolvers.
- [ ] Implement thin coordinators that translate destinations into route commands.
- [ ] Ensure DeliveryManager can never enter driver registration or account-status routes.
- [ ] Run coordinator tests and commit.

### Task 7: Make Routing Carry Typed Auth Context

**Files:**
- Modify: `lib/config/routing/app_routes.dart`
- Modify: `lib/config/routing/routing_generator.dart`
- Create: `lib/config/routing/arguments/auth_route_arguments.dart`
- Test: `test/auth_route_flow_test.dart`
- Modify: existing route tests affected by the new typed arguments.

**Interfaces:**
- Consumes: typed role, phone, OTP purpose, registration ID/mode, and account-status context.
- Produces: correct existing screen for each coordinator destination.

- [ ] Write route tests covering all Driver and DeliveryManager lookup outcomes.
- [ ] Define typed arguments instead of unstructured maps for new auth flow data.
- [ ] Remove production route dependencies on `AuthFakeData`.
- [ ] Preserve existing route names unless a missing screen requires a new route.
- [ ] Route successful Driver authentication to the Driver shell and successful DeliveryManager authentication to the Dispatcher shell.
- [ ] Run route tests and commit.

### Task 8: Define Driver Registration Domain and Data Layers

**Files:**
- Modify/reuse: `lib/features/register/domain/register_personal_data.dart`
- Modify/reuse: `lib/features/register/domain/register_vehicle_data.dart`
- Modify/reuse: `lib/features/register/domain/register_document.dart`
- Modify/reuse: `lib/features/register/domain/register_review_data.dart`
- Create: additional focused entities under `lib/features/register/domain/entities/`
- Create: `lib/features/register/domain/repo/driver_registration_repository.dart`
- Create: driver-registration use cases under `lib/features/register/domain/usecase/`
- Create: data source, DTO, mapper, and repository implementation under `lib/features/register/data/`
- Modify: `lib/core/di/di.dart`
- Test: `test/features/register/data/` and `test/features/register/domain/`

**Interfaces:**
- Consumes: personal/vehicle data, restaurant ID, dates, local files, and uploaded storage keys.
- Produces: restaurants, uploaded-document results, submitted registration results, and resubmission results through domain entities.

- [ ] Write tests for restaurant parsing, upload responses, submission serialization, and nullable backend responses.
- [ ] Reuse current registration domain models where they represent the contract; add focused models rather than rewriting the feature.
- [ ] Define a registration draft that preserves all wizard values and upload results between steps.
- [ ] Implement restaurant, multipart upload, submit, and resubmit API methods through shared `ApiServices`.
- [ ] Ensure final requests contain returned `storageKey` values, never local device paths.
- [ ] Implement repository methods through `safeApiCall` and register dependencies.
- [ ] Generate code, run tests, and commit.

### Task 9: Bind the Existing Registration Wizard to Real State

**Files:**
- Create: `lib/features/register/presentation/manager/driver_registration_event.dart`
- Create: `lib/features/register/presentation/manager/driver_registration_state.dart`
- Create: `lib/features/register/presentation/manager/driver_registration_view_model.dart`
- Modify: `lib/features/register/presentation/screens/register_screen.dart`
- Modify: existing registration step/review screens only where data callbacks are required.
- Preserve: existing registration widgets and design.
- Test: `test/features/register/presentation/driver_registration_view_model_test.dart`
- Modify: existing registration widget tests.

**Interfaces:**
- Consumes: registration use cases and all wizard input.
- Produces: persistent draft, per-document upload state, review data, submission state, and registration ID.

- [ ] Write tests for restaurant loading, step persistence, individual upload success/failure/retry, missing-required-document validation, and final submission.
- [ ] Move wizard business state out of `_RegisterScreenState` into the ViewModel while keeping UI-only state local where appropriate.
- [ ] Load restaurants for the current restaurant selector.
- [ ] Save every step into the draft and keep values when navigating backward.
- [ ] Track each upload independently and allow retry without re-uploading successful documents.
- [ ] Render the review screen from the real draft instead of `RegisterFakeData`.
- [ ] On successful submission, navigate to `AccountStatusKind.underReview`; remove the current fake transition to accepted.
- [ ] Run registration tests, visual sanity checks, and commit.

### Task 10: Integrate Driver Application Status

**Files:**
- Create: `lib/features/account_status/data/data_source/account_status_remote_data_source.dart`
- Create: `lib/features/account_status/data/data_source/account_status_remote_data_source_impl.dart`
- Create: `lib/features/account_status/data/models/response/driver_registration_status_response_dto.dart`
- Create: `lib/features/account_status/data/mapper/account_status_mapper.dart`
- Create: `lib/features/account_status/data/repo/account_status_repository_impl.dart`
- Create: `lib/features/account_status/domain/entities/driver_registration_status_entity.dart`
- Create: `lib/features/account_status/domain/repo/account_status_repository.dart`
- Create: `lib/features/account_status/domain/usecase/get_account_status_usecase.dart`
- Create: manager files under `lib/features/account_status/presentation/manager/`
- Modify: existing account-status screens/widgets only to consume state/entity data.
- Test: `test/features/account_status/`

**Interfaces:**
- Consumes: driver phone or the exact identifier required by the confirmed status endpoint.
- Produces: domain status with registration ID, status/stage, badge/title/subtitle, notes/reason, approval statuses, `canResubmit`, and `isApproved`.

- [ ] Write mapper tests for `Submitted`, `NeedsChanges`, `Rejected`, and `Approved`.
- [ ] Map them respectively to `underReview`, `moreInformationRequired`, `rejected`, and `accepted`.
- [ ] Implement status loading and localized failure/retry states.
- [ ] Replace hard-coded fake reasons/content with domain values while retaining localized fallback labels where the API omits presentation copy.
- [ ] Preserve all existing status layouts and illustrations.
- [ ] Run account-status tests and commit.

### Task 11: Implement Resubmission and Approved-Account Activation

**Files:**
- Modify: register ViewModel/domain/data files from Tasks 8-9.
- Modify: account-status ViewModel/screens from Task 10.
- Modify: driver auth coordinator from Task 6.
- Test: `test/features/register/resubmit_driver_registration_test.dart`
- Test: `test/features/account_status/account_activation_flow_test.dart`

**Interfaces:**
- Consumes: `registrationId`, current registration data, changed fields/files, and approved-account lookup result.
- Produces: resubmitted `Submitted` status or OTP/password activation flow.

- [ ] Confirm the backend source for pre-filling the previous registration. Do not invent a details endpoint; if none exists, document and agree on a temporary local-draft strategy before coding prefill.
- [ ] Write tests proving unchanged uploaded storage keys are retained and only modified documents are uploaded again.
- [ ] Open the existing registration wizard in an explicit resubmission mode for NeedsChanges/Rejected.
- [ ] Call the documented `{registrationId}/resubmit` endpoint and route success back to under review.
- [ ] For Approved, make “Start Working” perform lookup, first-time OTP, set password, save session, then open the Driver application.
- [ ] Ensure no approved user reaches the app shell before authentication succeeds.
- [ ] Run flow tests and commit.

### Task 12: Add Startup Auth Gate and Complete Cleanup

**Files:**
- Modify: `lib/features/auth/presentation/screens/splash_screen.dart`
- Modify: `lib/config/routing/routing_generator.dart`
- Modify: `lib/features/auth/data/auth_fake_data.dart` only if unused content can be removed safely.
- Modify: `lib/features/register/data/register_fake_data.dart` only if unused content can be removed safely.
- Test: `test/startup_auth_gate_test.dart`
- Test: existing auth/register/status regression suites.

**Interfaces:**
- Consumes: restored session, saved role, and any explicitly persisted pending-registration context.
- Produces: Driver home, Dispatcher home, account status, or unauthenticated role/login flow.

- [ ] Write startup tests for valid Driver session, valid DeliveryManager session, pending Driver application, missing session, expired access token with successful refresh, and failed refresh.
- [ ] Implement deterministic splash routing without showing protected UI before session restoration completes.
- [ ] Remove only fake-data paths whose production replacements are covered by tests.
- [ ] Search for DTO imports in presentation/domain and direct network calls in widgets; remove every violation.
- [ ] Run code generation and formatting.
- [ ] Run `flutter analyze` and the full `flutter test` suite.
- [ ] Manually smoke-test Driver first-time setup, normal login, registration, four application statuses, resubmission, Dispatcher first-time/normal login, forgot/reset password, offline errors, and expired-token behavior.
- [ ] Commit the final cleanup.

---

## Acceptance Criteria

- Driver and DeliveryManager share one auth data/domain implementation and send the correct role value.
- Driver and Dispatcher routing decisions remain isolated in their own coordinator features.
- DeliveryManager can never enter Driver registration or application-status flows.
- Existing screen design remains visually unchanged.
- Driver registration uses real restaurants, uploads, storage keys, submission, status, and resubmission APIs.
- Successful registration routes to Under Review, never directly to Accepted.
- Approved Driver activation completes OTP/password setup before entering the Driver app.
- Tokens are stored securely, refreshed once when appropriate, and cleared after unrecoverable unauthorized responses.
- No DTO reaches UI/domain, no widget performs a network call, and no second Dio/API client exists.
- `flutter analyze` and the full `flutter test` suite pass.
