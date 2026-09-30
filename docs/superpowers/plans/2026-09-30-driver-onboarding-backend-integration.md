# Driver Onboarding and Approval Backend Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the mobile driver onboarding lifecycle from self-registration through authentication, review, resubmission, notifications, and safe access to approved driver features using the backend handoff contract.

**Architecture:** Extend the existing `register`, `auth`, `account_status`, `device_token`, and `driver_notifications` feature layers without replacing their Clean Architecture flow. Audit existing endpoint coverage first, then add missing driver-specific contracts and make status from the authenticated status API the sole authority for review UI and post-approval routing; FCM only triggers a status refresh. Reuse existing session, error, localization, routing, and shimmer infrastructure.

**Tech Stack:** Flutter/Dart, flutter_bloc ViewModels and sealed events, Retrofit/Dio, json_serializable, Injectable/GetIt, `ApiResult`/`safeApiCall`, flutter_local_notifications/FCM integration already in the app, Flutter localization, flutter_test.

**Spec:** `C:/Users/orignal store/.codex/attachments/23982dd1-65f0-4cb7-b26d-d986cedf0638/Pasted text.txt` (sections 1–13 and 15–16); `rules/rules_backend.md`.

## Global Constraints

- Follow `rules/rules_backend.md`: UI → Event → ViewModel → UseCase → Repository contract → Repository implementation → RemoteDataSource → existing `ApiServices`.
- Use existing `lib/core/errors`, `Failure`, `ApiResult`, `safeApiCall`, `ApiErrorWidget`, and `InlineApiErrorWidget`; do not create another error/result framework.
- Use existing `ShimmerWidget` from `lib/core/widget/shimmer_widget.dart` for loading placeholders; do not add a shimmer package or use indeterminate progress indicators as screen placeholders. Keep determinate upload progress.
- Preserve existing screens, design, localization, interceptors, secure session storage, DI, and unrelated working tree changes. Do not modify the active `driver_profile_screen.dart` changes as part of this plan.
- Use the full self-registration contract `POST /api/v1/auth/staff/driver-registration` consistently. Do not mix it with legacy `POST /api/v1/auth/drivers/register` DTOs or the legacy draft/submit route.
- Keep `userId`, `registrationId`, `driverProfileId`, and `restaurantId` separate. Keep `VerificationStatus`, `AccountStatus`, and profile/operational status separate. Treat every response field as nullable by default and support localized single-language responses.
- Registration success does not return a session. Do not assume a submitted or restaurant-approved registration can start work. Approved routing requires a fresh authenticated status/session check and real profile/operational APIs.
- Resubmission sends changed fields only; never include phone or unchanged document storage keys. Do not claim upload ownership is verified. Do not add unsupported phone-change, admin/restaurant APIs, notification paging/count APIs, or ready/online fields.
- The handoff explicitly reports unresolved backend gaps, especially rejected `canResubmit=true`, upload ownership, notification deduplication/retry, and legacy/full-contract differences. Preserve conservative client guards and record any backend-dependent acceptance as blocked by backend evidence, not as a fabricated mobile pass.
- Do not manually edit generated `*.g.dart`, `api_services.g.dart`, localization output, or `lib/core/di/di.config.dart`; generate them with project tools.

## Existing Code Map

- `lib/features/register/` already has full registration DTOs, catalogs, upload, submit, resubmit, ViewModel, and registration shimmer widgets. Audit and correct exact-contract mismatches instead of duplicating these layers.
- `lib/features/auth/` currently models staff auth; driver login/lookup/first-time-setup request and response contracts need auditing and driver-specific additions where needed.
- `lib/features/account_status/` has a status DTO/mapper/ViewModel/screen but currently accepts phone and registrationId, and its screen uses `CustomProgressIndicator` for initial loading.
- `lib/features/device_token/` has a token sync coordinator; registration currently attempts pre-login sync. Align it with the handoff requirement to register only with a real authenticated session.
- `lib/features/driver/driver_notifications/` currently has entities/fake data; authenticated driver inbox API/repository/use-case/ViewModel and read operation need implementing or adapting.
- `lib/core/services/notification_payload_parser.dart` handles some legacy registration event keys; audit keys, routing, cold-start buffering, and stale event behavior against the handoff.

## File Structure

### Likely Create (confirm after the audit task)

- Driver auth request/response DTOs and domain request/result entities under `lib/features/auth/data/` and `lib/features/auth/domain/` for login, phone lookup, first-time setup, resend OTP, verify OTP, forgot password, and reset password where existing contracts do not match.
- Driver notification DTOs, mapper, remote data source, repository contract/implementation, use cases, and ViewModel/state/events under `lib/features/driver/driver_notifications/`.
- Focused shimmer widgets for account status and driver notification inbox if no screen-shaped shimmer already exists.
- Focused tests under `test/features/auth/`, `test/features/register/`, `test/features/account_status/`, `test/features/device_token/`, `test/features/driver/driver_notifications/`, and `test/core/services/`.

### Likely Modify (confirm after audit)

- `lib/core/network/network_constants.dart`, `lib/core/network/api_services.dart` — add only confirmed missing driver endpoints and exact route/body/query contracts.
- `lib/features/register/data/models/`, `lib/features/register/data/mapper/driver_registration_mapper.dart`, request/entity files, repository/data source — full registration fields, independent `restaurantId: null`, upload file limits/keys, date mapping, response without tokens, and changed-fields-only resubmit.
- `lib/features/register/presentation/manager/driver_registration_view_model.dart` and registration screens — avoid auto-selecting a restaurant for independent registration; prevent duplicate create retries after ambiguous timeout; preserve uploaded key only after successful upload.
- `lib/features/auth/data/`, `lib/features/auth/domain/`, and existing auth ViewModel/events/state/screens — driver-specific payloads and session response handling without regressing staff auth.
- `lib/features/account_status/data/models/response/driver_registration_status_response_dto.dart`, mapper/entity, ViewModel/state, screen/widgets — complete nullable status contract, separate review stages, status guard, authenticated status refresh, retry/pull-to-refresh/foreground refresh, and shimmer.
- `lib/features/device_token/` and `lib/core/services/push_notification_coordinator.dart` — authenticated registration after login/setup, token refresh, deactivation before logout, and no pre-login protected request.
- `lib/features/driver/driver_notifications/` — array response (latest 50), notification read, local count of loaded unread items, event-triggered status fetch, and existing UI integration.
- `lib/core/services/notification_payload_parser.dart`, notification tap/deep-link handlers, route arguments, and pending-auth navigation coordinator — event keys, registrationId extraction, cold start, login deferral, and server-authoritative refresh.
- `lib/features/home/` or existing app-shell route guards only where required to ensure fresh approved status/profile and backend operational state gate access.
- `lib/core/l10n/app_ar.arb`, `lib/core/l10n/app_en.arb` — only missing localized messages/status labels.

---

### Task 1: Audit current contracts and establish backend acceptance gates

**Files:**
- Read: `rules/rules_backend.md`
- Read: `C:/Users/orignal store/.codex/attachments/23982dd1-65f0-4cb7-b26d-d986cedf0638/Pasted text.txt`
- Inspect: the Existing Code Map above and corresponding tests.
- Create: `docs/superpowers/plans/2026-09-30-driver-onboarding-backend-contract-audit.md` only if execution requires a separate contract matrix artifact.
- Test: focused existing registration/auth/status/device-token/notification tests discovered during audit.

**Interfaces:**
- Produces: a checked endpoint matrix with each item marked `already correct`, `mobile change`, or `backend confirmation required`; a list of exact files to adjust in Tasks 2–8.

- [ ] Compare every endpoint used by the app with handoff sections 5–12, including HTTP verb, route, auth, direct-array/direct-object response shape, request field names, query names, 204 handling, and ID meaning.
- [ ] Confirm the active self-registration path is `/api/v1/auth/staff/driver-registration`; identify and quarantine any runtime usage of the legacy register/draft-submission contract.
- [ ] Inspect status DTO and mapper for `fullNameAr`, `fullNameEn`, `requestedByRole`, `restaurantApprovalStatus`, `adminApprovalStatus`, notes, rejection reason, nullable restaurant, string/numeric enum compatibility, and status-vs-stage mapping.
- [ ] Inspect current token-sync coordinator and notification parser/handlers for protected pre-login calls, registrationId preservation, event names, pending navigation, and status refresh behavior.
- [ ] Write down backend evidence still needed: exact resubmit response type, protected status query/identity rules, 204 behavior, actual notification payload/deep link, and deployed environment version. Do not silently treat the handoff as proof that deployment matches local backend.
- [ ] Run only the existing focused tests needed to characterize current behavior; record results in the endpoint matrix.

### Task 2: Correct self-registration contract, independent flow, and upload semantics

**Files:**
- Modify only contract gaps found in Task 1, likely `lib/features/register/data/models/request/driver_registration_request_dto.dart`, its `.g.dart` via generator, response DTO/mapper, registration repository/data source, draft entity, ViewModel, and `register_screen.dart`.
- Test: `test/features/register/data/driver_registration_dto_and_mapper_test.dart`, `test/features/register/presentation/driver_registration_view_model_test.dart`, and upload widget/view-model tests as applicable.

**Interfaces:**
- Produces: full registration request with nullable `restaurantId`, the exact keys/dates, and `DriverRegistrationResultEntity` that does not imply an authenticated session.
- Consumes: existing catalog and upload use cases; exact handoff section 6.

- [ ] Add focused tests first for independent registration serializing `restaurantId: null`, required bilingual names and document keys, exact upload `storageKey` use, and registration success containing no session tokens.
- [ ] Remove the ViewModel fallback that silently selects `state.restaurants.first` when no restaurant is selected; preserve explicit linked-restaurant selection, while independent mode sends JSON null.
- [ ] Verify file size before multipart upload using a client-side maximum below 15 MiB to leave multipart overhead; reject empty files and keep `storageKey` unset until upload succeeds.
- [ ] Verify request uses `vehicleLicenseExpiry` and `licenseExpiry`; map response detail fields with their explicit UTC suffixes, never by positional or guessed mapping.
- [ ] Keep `profileImageStorageKey` optional at create only as specified, but make missing profile image visible as a known final-approval requirement; do not claim approval eligibility prematurely.
- [ ] On ambiguous submit timeout, do not automatically submit a second create request; route the user to login/status recovery and explain the lookup path using existing localized error UI.
- [ ] Run focused DTO/mapper/ViewModel tests and confirm they cover linked and independent flows.

### Task 3: Add/align driver authentication and secure first-time setup

**Files:**
- Modify/create only what the Task 1 audit finds necessary under `lib/features/auth/data/{models,mapper,data_source,repo}`, `lib/features/auth/domain/{entities,repo,usecase}`, `lib/features/auth/presentation/manager`, and auth screens.
- Modify `lib/core/network/network_constants.dart` and `api_services.dart` for confirmed missing driver routes.
- Test: focused driver auth DTO/mapper/repository/ViewModel/session tests.

**Interfaces:**
- Produces: typed driver operations for `lookupPhone(phone)`, `login(phone, password[, email])`, `firstTimeSetup(phone, otpCode, password)`, `resendOtp(destination, channel, purpose)`, `verifyOtp(destination, purpose, code)`, `forgotPassword(phone)`, and `resetPassword(phone, otpCode, newPassword)`.
- Session-producing login/setup returns the existing domain session abstraction and uses the existing secure token/session persistence.

- [ ] Add contract tests asserting exact JSON names and response root shape for each driver endpoint; lookup 404 remains a typed failure, not `exists=false` fabricated by the client.
- [ ] Add driver-specific request/response DTOs instead of reusing staff DTOs when field names or response contracts differ; all response properties remain nullable.
- [ ] Map first-time setup from `phone`, `otpCode`, `password`; do not send `otp`, `newPassword`, or `confirmPassword` to that route.
- [ ] Ensure first-time setup persists `userId` and tokens from top-level session response using current secure session storage, then reloads registration status; do not trust lookup `fullName`, restaurant, or status as final data.
- [ ] Use login with phone and password, omit stale email unless user selected email login; distinguish a valid pre-approval session from operational authorization.
- [ ] Do not automatically resend OTP after lookup says setup is required; expose a rate-aware resend action and do not consume setup OTP through generic verify before first-time setup.
- [ ] Keep passwords/OTP out of logs, errors, review screens, persisted draft, and equality/debug representations except the existing approved in-memory submission path.
- [ ] Run focused auth tests plus existing staff auth regression tests.

### Task 4: Make authenticated registration status authoritative and render it with shimmer/errors

**Files:**
- Modify `lib/features/account_status/data/models/response/driver_registration_status_response_dto.dart`, generated DTO, mapper, entity, repository/data source/use case only for gaps.
- Modify `lib/features/account_status/presentation/manager/account_status_{event,state,view_model}.dart`, screen, and status widgets.
- Create a status shimmer widget if none exists.
- Modify localization ARBs only for missing states/messages.
- Test: status mapper, ViewModel, and screen tests under `test/features/account_status/`.

**Interfaces:**
- Status reads require the authenticated session and optional `registrationId` only where confirmed by backend; phone alone is never treated as authorization.
- Produces: immutable status entity containing independent overall status, restaurant review status, admin review status, requested-by role, bilingual display names when available, and nullable notes/reason.

- [ ] Write tests for every named status and separate review state; include independent registration where restaurant approval may be `Approved` while overall status remains `UnderReview`.
- [ ] Extend parsing to tolerate a single localized `fullName` plus either optional language-specific name; do not require both languages or infer status from `title`, `badge`, or `subtitle`.
- [ ] Map API `status` to review screen state; treat API `stage` as display-stage aid only, and never confuse it with FCM's reviewer stage.
- [ ] Guard resubmit with `canResubmit && status != Approved && status != Rejected`; preserve this guard while backend currently reports rejected as resubmittable.
- [ ] Replace initial `CustomProgressIndicator` placeholder with an account-status screen-shaped shimmer built on `ShimmerWidget`; use `ApiErrorWidget` from `lib/core/errors` for full-screen initial failures and `InlineApiErrorWidget` for refresh failures while retaining existing content.
- [ ] Add pull-to-refresh and lifecycle/foreground refresh; polling may be added only while the review screen is visible and must be slow, cancellable, and stop on dispose or terminal status.
- [ ] On 401 use existing session refresh/restore behavior before retry; keep 403 as authorization/account-state feedback, not a cue to change registrationId.
- [ ] Re-run focused status mapping, state, screen, and navigation tests.

### Task 5: Implement sparse resubmission with field-level change tracking

**Files:**
- Modify `lib/features/register/domain/entities/driver_resubmit_entity.dart`, request DTO, mapper, ViewModel, form initialization and submission screens as required.
- Test: `test/features/register/resubmit_driver_registration_test.dart`, resubmit DTO serialization, and targeted widget tests.

**Interfaces:**
- Produces: request serialization omitting unchanged/null fields while retaining explicit `false` for `isVehicleOwned`.
- Phone is display-only and cannot be sent in the resubmit body.

- [ ] Add tests for no-change disabling, one changed scalar producing exactly one key, one newly uploaded file producing only its new storage key, `isVehicleOwned: false` being serialized, and phone never being serialized.
- [ ] Populate form from current registration details/status using source-language bilingual data only when backend supports it; add `X-Bilingual: true` only on the exact edit request that needs both source values and after confirming interceptor/header compatibility.
- [ ] Track original values and edited values separately; serialize only changed scalar fields. Do not serialize null/empty as a clear operation because backend omission/null means retain the old value.
- [ ] Track uploaded documents separately from existing storage keys; never resend old keys on an unrelated edit because a key is treated as a new document submission and may restart restaurant review.
- [ ] Keep phone immutable in the correction form; map `Driver.PhoneChangeRequiresVerification` to a localized field-level explanation.
- [ ] Disable submit until a field differs or a new document upload succeeds; map `Resubmit.EmptyChanges` to inline validation.
- [ ] On success render the returned response, clear stale reviewer notes, then reload authoritative status; handle 409 `ALREADY_APPROVED`, `ALREADY_REJECTED`, and `INVALID_TRANSITION` by refreshing status and closing stale edit state.
- [ ] Verify resubmit has no password field and add a regression assertion against accidental password serialization.

### Task 6: Register FCM only with a session and implement driver inbox APIs

**Files:**
- Modify device-token data source/repository/use cases/coordinator and login/setup/logout hooks.
- Modify/create driver notification DTOs, mapper, data source, repository contract/implementation, use cases, event/state/ViewModel, screen/widgets, and API methods/constants.
- Test: device token sync tests, notification parsing/repository/ViewModel/screen tests.

**Interfaces:**
- Inbox returns at most 50 `DriverNotificationEntity` items from a direct JSON array; mark-read is `PUT /api/v1/driver/notifications/{notificationId}/read` with no body.
- Device token upsert/deactivate handle successful 204 responses without attempting JSON decoding.

- [ ] Add tests proving registration create does not make an unauthenticated protected device-token request; after login or first-time setup, register the actual FCM token with platform and optional registrationId.
- [ ] Register again on FCM token refresh; during logout deactivate while the bearer session is still valid, then clear local token context; notification permission denial must not block status or inbox.
- [ ] Add defensive nullable notification DTO for the exact array item fields; map only present values and sort/present as returned (newest first per contract), without inventing pagination or unread total.
- [ ] Implement loading/failure/read state through existing `Failure` and `ApiResult`; use a screen-shaped `ShimmerWidget` placeholder, `ApiErrorWidget` for initial failure, and inline errors for refresh/read retry.
- [ ] Count unread only among the loaded items; mark an item read locally only after API success or revert it on failure.
- [ ] Verify API 204 methods use `Future<void>`/appropriate Retrofit handling and never parse an empty body as DTO JSON.
- [ ] Run notification and token-sync focused tests, including session absent/present, duplicate refresh, read failure, and direct-array parsing.

### Task 7: Reconcile FCM events, deep links, and pending navigation

**Files:**
- Modify `lib/core/services/notification_payload_parser.dart`, existing FCM foreground/background/tap handlers, route definitions/arguments, auth completion coordination, and notification list integration.
- Test: `test/core/services/notification_payload_parser_test.dart`, pending navigation tests, notification integration tests.

**Interfaces:**
- Produces: parsed notification intent with event key and nullable registrationId; event never becomes an authoritative status object.
- Pending intent is consumed after successful authentication and cleared after success, logout, or unrecoverable 403.

- [ ] Add fixture-based parsing tests for every handoff event key: submitted, independent_submitted, resubmitted, restaurant_approved, restaurant_changes_requested, restaurant_rejected, admin_approved, admin_changes_requested, and admin_rejected.
- [ ] Keep compatibility aliases only for payload keys verified in local app/backend fixtures; do not treat absent optional payload fields as malformed events.
- [ ] Parse `/driver/status?registrationId=...` as an internal route intent, not a URL to open and not proof of access to that registration.
- [ ] For foreground, background, and cold-start taps, route to login if needed while storing pending registration intent; after login/setup fetch status from server before navigating to a status-derived screen.
- [ ] Ignore event status/stage as an authority; use event key only to prompt a fetch. Prevent delayed event/tap from replacing a newer approved state with stale review state.
- [ ] On 403 show no-access feedback and clear inaccessible pending intent; do not retry with another ID. On missing registrationId, route to inbox/status entry with a safe localized message.
- [ ] Verify multiple legitimate resubmission cycles are not deduplicated permanently by event key plus registrationId.

### Task 8: Gate operational access on fresh backend state, localization, and contract acceptance

**Files:**
- Modify app-shell/driver-route guards and existing driver auth coordinator only where needed.
- Modify localization ARBs and generated output through localization generator.
- Add/modify end-to-end contract tests under the feature test folders; use integration tests only against configured backend environment when credentials/fixtures are available.

**Interfaces:**
- Produces: approved route only after fresh authenticated status and existing account/profile/operational API checks succeed.
- No local `ready=true`, push-driven approval, or restaurant-only approval transition exists.

- [ ] Add routing tests: Submitted/UnderReview/NeedsChanges/Rejected never enter operational home; restaurant approval alone never enters operational home; Approved triggers fresh status/session/profile and existing backend readiness checks.
- [ ] Treat absent `driverProfileId`, missing profile, suspended/closed account, unavailable required documents, or operational API denial as non-ready; preserve the application's existing safe fallback route and typed error UI.
- [ ] Do not add `accountStatus` to driver profile DTO when the endpoint does not return it; use the actual existing session/account API source.
- [ ] Add ProblemDetails handling tests for phone-change, empty-resubmit, invalid stored document, conflicts, 401, 403, 404, 413, 429 with `Retry-After`, 422, and 5xx using existing typed error facilities and localized display mapping.
- [ ] Run generator commands for changed Retrofit/JSON/DI/localization files; do not hand-edit generated output.
- [ ] Run focused tests for each changed feature, existing registration/auth/account-status/device-token/notification regression suites, `flutter analyze`, and `git diff --check`; record exact commands and results.
- [ ] Execute the handoff acceptance scenarios on the configured backend/device environment: linked registration, independent registration, upload failures/size, first-time setup for restaurant-created account, pre-approval login/status, separate restaurant/admin review, approved/rejected resubmit guards, sparse changes and changed files, FCM refresh/logout, all app states/deep links, 204, 401/403, and submit timeout recovery.
- [ ] Produce a release handoff matrix that separates mobile work complete, verified on backend environment, and remaining backend gaps; include actual environment/build identifiers and never claim unresolved upload ownership or notification delivery guarantees.

## Acceptance Checklist

- [ ] Registration supports linked and independent routes with exact request fields, secure in-memory password flow, real uploaded storage keys, and no success/session inference.
- [ ] Driver login and first-time setup match exact wire contracts, persist session securely, and permit authenticated review access before approval.
- [ ] Status screen uses authenticated backend status, separates restaurant and admin reviews, handles current rejected-resubmit contradiction conservatively, and shows shimmer on initial loading.
- [ ] Resubmission sends only changed fields/new documents, excludes phone and password, and handles empty/final/conflict outcomes with fresh status.
- [ ] FCM registration occurs only after session exists; inbox supports direct array/latest 50/read and local loaded unread count.
- [ ] Registration notifications refresh status after foreground/background/cold-start navigation and never authorize access by payload alone.
- [ ] Existing `lib/core/errors` and typed failures are used throughout; all new initial loading placeholders use shared `ShimmerWidget`.
- [ ] Operational access follows fresh server status, profile, account, and existing availability decisions.
- [ ] Known backend gaps are explicitly reported with evidence and are not claimed as mobile fixes.
