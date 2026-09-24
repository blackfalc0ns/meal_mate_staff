# FCM Device Token Integration Design

**Date:** 2026-09-24

**Status:** Proposed for implementation planning

## Purpose

Integrate Firebase Cloud Messaging for drivers and delivery managers so the application can register and deactivate device tokens, receive foreground/background/terminated notifications, and route supported payloads to the correct existing screen. The integration must follow `rules/rules_backend.md`, reuse the project's networking and error infrastructure, and must not make authentication or driver registration fail because push-token synchronization failed.

## Source Contract

This design treats `fcm-token-integration-guide (1).md`, supplied on 2026-09-24, as the authoritative backend contract:

- Driver upsert: `POST /api/v1/driver/device-token`.
- Pre-login driver upsert passes `registrationId`; authenticated driver upsert relies on the driver JWT and may omit IDs.
- Driver deactivate: `DELETE /api/v1/driver/device-token?token={FCM_TOKEN}`.
- Delivery-manager upsert: `PUT /api/v1/restaurants/device-tokens` with JWT.
- Delivery-manager deactivate: `DELETE /api/v1/restaurants/device-tokens?token={FCM_TOKEN}` with JWT.
- Successful commands return `204 No Content`; `200 OK` is tolerated for backward compatibility.
- Errors use RFC 7807 ProblemDetails and flow through the existing `ApiExceptionMapper`, `Failure`, `ApiResult`, and `safeApiCall` infrastructure.
- Device-token registration is idempotent and the backend transfers ownership on account changes.
- Platform values emitted by the app are exactly `Android` and `iOS`.
- Android channel ID is exactly `mealmate_alerts_channel` with high importance.

The development test-push endpoint is not integrated into production application code. It remains a Postman/cURL diagnostic endpoint.

## Scope

### Included

- Firebase initialization before `runApp` using the generated `firebase_options.dart`.
- Android high-importance notification-channel creation.
- Notification permission request and permission-state handling.
- FCM token acquisition and refresh observation.
- Driver pre-login token upsert after successful new registration.
- Authenticated driver and delivery-manager token upsert after login and restored sessions.
- Best-effort token deactivation before authenticated logout clears the JWT.
- Foreground notification display through local notifications.
- Background and terminated notification-tap handling.
- Typed parsing, validation, deduplication, and routing of documented payloads.
- Unit, repository, lifecycle, routing, auth integration, registration integration, and widget/bootstrap tests.

### Excluded

- Replacing the fake/local notification-list screens with a notification-history backend.
- Adding a WebRTC calling feature or incoming-call screen.
- Implementing delivery screens that do not currently exist.
- Calling the development-only test-push endpoint from the shipped app.
- Backend implementation or Firebase Admin configuration.
- Web, Windows, Linux, and macOS push support in this mobile integration.

## Architecture

Firebase lifecycle concerns live in a core adapter, while backend token management lives in a feature-based Clean Architecture slice:

```text
FirebaseMessaging / FlutterLocalNotifications
                    |
                    v
        PushNotificationCoordinator
          |                    |
          v                    v
DeviceTokenUseCases     NotificationPayloadParser
          |                    |
          v                    v
DeviceTokenRepository   NotificationRouter
          |                    |
          v                    v
RemoteDataSource         AppNavigatorService
          |                    |
          v                    v
ApiServices              Existing app routes
```

`PushNotificationCoordinator` orchestrates SDK events but never performs raw HTTP. `DeviceTokenRepository` contains no Firebase imports. `NotificationRouter` contains no SDK or networking code. These boundaries allow each concern to be tested independently.

## File and Responsibility Boundaries

### Core platform adapters

- `lib/core/services/push_messaging_gateway.dart`: an app-owned interface for permissions, token retrieval, refresh/tap/foreground streams, and initial messages.
- `lib/core/services/firebase_push_messaging_gateway.dart`: Firebase Messaging implementation of that interface.
- `lib/core/services/local_notification_service.dart`: initializes the Android channel and displays foreground notifications. Platform-specific plugin calls remain behind this service.
- `lib/core/services/push_notification_coordinator.dart`: starts listeners once, selects current identity context, synchronizes tokens, forwards messages to the parser/router, and disposes subscriptions in tests.

The project keeps using `DeviceIdService`. It does not add `device_info_plus`: the existing generated-and-persisted identifier is stable for this app installation, avoids restricted hardware identifiers, and already fits the backend's `deviceId` contract.

### Device-token feature

- Request DTO: `token`, `platform`, `deviceId`, and optional `registrationId`.
- Remote data source: delegates only to the relevant Retrofit endpoint.
- Repository implementation: wraps remote calls in `safeApiCall<void>`.
- Repository contract and use cases: expose driver/restaurant upsert and deactivate operations without leaking Retrofit or Firebase types.
- Sync-context entity: represents `driverPreLogin`, `driverAuthenticated`, or `deliveryManagerAuthenticated`, including only the identifier data required for that mode.

No presentation screen or ViewModel is created for device-token commands because synchronization is application lifecycle work and has no standalone UI.

### Notification payload and routing

The parser converts `Map<String, dynamic>` into typed immutable domain payloads. It accepts both canonical and legacy aliases where the contract documents both:

- `driver.box.assigned` / `box-assigned`
- `driver.trip.assigned` / `trip-assigned`
- `driver.trip.kitchen_ready` / `kitchen-ready`

Registration events use their canonical names from the new guide. Unknown events and payloads missing required identifiers become an `UnsupportedNotificationPayload`; they are ignored safely and recorded only with non-sensitive diagnostic metadata. Full FCM tokens, call tokens, JWTs, and complete message bodies must never be logged.

Routing rules:

| Event | Route behavior |
|---|---|
| `driver.registration.restaurant_approved` | Account-status screen with under-review status and `registrationId` |
| `driver.registration.restaurant_changes_requested` | Account-status needs-changes flow with `registrationId` |
| `driver.registration.admin_confirmed` | Account-status approved screen with `registrationId` |
| `driver.registration.admin_rejected` | Account-status rejected screen with `registrationId` |
| `driver.box.assigned` / `box-assigned` | Driver assigned-box details only when an existing route can accept `boxId`; otherwise driver assigned-box list |
| `driver.trip.assigned` / `trip-assigned` | Existing driver assigned-box/manifest entry point, carrying `tripId` when supported |
| `driver.trip.kitchen_ready` / `kitchen-ready` | Existing driver pickup/assigned-box entry point, carrying `tripId` when supported |
| `dispatcher.batch.ready` | Dispatcher orders queue |
| `driver.registration.submitted` | Dispatcher-facing registration destination only if that screen exists at implementation time; otherwise dispatcher home |
| `incoming_call` | Parse and classify only; do not navigate until the calling feature exists |

The implementation plan must inspect each target constructor before defining route arguments. It must not fabricate domain entities from a push payload merely to satisfy an existing screen constructor. A safe list/home fallback is preferred when the payload lacks the data required by a details screen.

## Lifecycle and Data Flow

### Application startup

1. Flutter bindings initialize.
2. Firebase initializes with `DefaultFirebaseOptions.currentPlatform` on Android/iOS.
3. dependency injection initializes.
4. the local notification channel initializes.
5. `runApp` mounts `MaterialApp` with `AppNavigatorService.navigatorKey`.
6. after the first frame, the coordinator requests notification permission and installs listeners exactly once.
7. `getInitialMessage()` is read once and routed only after the navigator is ready.
8. if a saved authenticated session exists, the current token is synchronized for the saved role. If no valid association context exists, the token is retained locally but is not sent to an endpoint.

Permission denial is not an API error and does not show a global error screen. The app continues normally and may retry only after an explicit future user action or a later startup where the OS permits prompting.

### Driver registration

After `SubmitDriverRegistrationUseCase` succeeds, the returned `DriverRegistrationResultEntity.registrationId` is passed to a best-effort driver token synchronization. Navigation to the account-status screen happens regardless of synchronization success. Resubmission does not create a new association unless the backend returns a different registration ID; the existing registration context remains authoritative.

### Login and restored session

The auth repository continues to save the session as it does today. After a successful login result reaches the auth orchestration layer, the current FCM token is upserted according to `AuthSessionEntity.role`. Restored sessions trigger the same synchronization. The role mapping is explicit: `UserRole.driver` uses the driver endpoint; the delivery-manager/operations role uses the restaurant endpoint; unsupported roles do not fall through to a restaurant call.

### Token refresh

The refresh listener retrieves the latest current context at event time instead of capturing the role/registration ID passed during initial setup. This prevents a stale pre-login registration context from being reused after login or account switching. Concurrent refreshes for the same token/context are coalesced in memory.

### Logout

Logout orchestration reads the current FCM token and saved role while the JWT is still available, then attempts the matching deactivate use case. It always proceeds to the existing local session cleanup even if FCM token retrieval or backend deactivation fails. The app must not call `FirebaseMessaging.deleteToken()` during normal logout because the same installation may immediately sign in as another user and the backend already supports ownership transfer.

## Retry and Persistence Policy

FCM synchronization is best-effort and never blocks the primary user flow. To avoid silently losing an association after a transient failure, the app persists a minimal pending-sync record in `SharedPreferences` containing:

- operation (`upsert` only),
- role/context type,
- optional `registrationId`,
- token hash or the token only if needed to replay the exact operation,
- attempt timestamp.

Because an FCM token is a credential-like identifier, the replay token is stored in `FlutterSecureStorage`; `SharedPreferences` stores only non-sensitive context. Pending upserts retry on the next startup, successful login/restore, or token refresh. HTTP `400`, `403`, and `404` are terminal for that exact pending context; network, timeout, `401` after refresh exhaustion, `429`, and `5xx` remain retryable. No unbounded timer or background polling is introduced.

Failed deactivation is not persisted after local logout because replaying it later may occur under a different user's JWT. Backend ownership-transfer semantics prevent cross-account delivery when the next user registers the device token.

## Error Handling

- All endpoint calls return `ApiResult<void>` through `safeApiCall`.
- RFC 7807 bodies are mapped by the existing error stack; FCM code does not invent a parallel exception hierarchy.
- Sync failures may be exposed as diagnostics/state for tests, but do not display `ApiErrorWidget` during startup, login, registration, refresh, or logout.
- Firebase/plugin exceptions are converted to the existing typed error representation at the coordinator boundary when they need reporting; otherwise they are contained and recorded without secrets.
- A malformed push payload cannot crash startup or navigation.
- A duplicate notification tap is ignored using the FCM message ID; when absent, a short-lived deterministic fingerprint of event key and business identifier is used.

## Foreground, Background, and Terminated Behavior

- Foreground: show one local notification on `mealmate_alerts_channel`; tapping its encoded payload goes through the same parser/router as FCM taps.
- Background: the OS displays the backend `notification` payload; `onMessageOpenedApp` routes the tap.
- Terminated: `getInitialMessage()` routes the launch message after navigator readiness.
- A top-level `@pragma('vm:entry-point')` background handler is registered before `runApp`. It initializes Firebase if necessary and performs no navigation. Because the backend always sends a `notification` payload, the OS owns background display and the app must not generate a duplicate local notification there.

## Platform Configuration

### Android

- Add notification runtime permission for Android 13+.
- Declare/default the channel ID `mealmate_alerts_channel` in Android metadata where required by Firebase.
- Create the channel with high importance and default sound.
- Keep the existing Google Services configuration.

### iOS

- Enable push notification and background remote-notification capabilities in the Runner project.
- Add required background mode configuration.
- Request alert, badge, and sound permission.
- Treat APNs token availability as an SDK concern; retry FCM token acquisition on later lifecycle triggers if it is initially unavailable.

## Dependency Injection and Bootstrap

The existing manual GetIt configuration remains authoritative. New data sources, repository, use cases, gateway, local notification service, router, and coordinator are registered there. Tests can replace the gateway and local notification interfaces without initializing Firebase plugins.

`MaterialApp` must receive `navigatorKey: AppNavigatorService.navigatorKey`. The existing temporary hard-coded `initialRoute: AppRoutes.driverStartDeliveryRoute` is a separate defect: implementation must restore use of the constructor's `initialRoute` so cold-start notification routing begins from the normal auth gate.

## Testing Strategy

- DTO serialization tests verify exact field names and omission/inclusion of `registrationId`.
- API contract tests verify HTTP verbs, paths, query parameters, empty `204` handling, and Authorization interceptor behavior.
- Repository tests verify `safeApiCall<void>` success and ProblemDetails-to-`Failure` propagation.
- Parser tests cover every canonical event, every documented alias, missing required fields, unknown events, and sensitive incoming-call data.
- Router tests verify route names/arguments and safe fallbacks.
- Coordinator tests use fake messaging/local-notification adapters to cover permission states, initial messages, foreground messages, refreshes, listener idempotency, deduplication, role changes, and retries.
- Auth tests verify login/restore synchronization and deactivate-before-clear logout order, including failure-tolerant logout.
- Registration tests verify pre-login sync uses the returned registration ID and does not change successful navigation when sync fails.
- Bootstrap/widget tests verify Firebase-independent app construction, navigator-key wiring, and normal initial-route behavior.
- Android/iOS configuration is verified through file assertions where practical and a manual device checklist for permission, foreground, background, terminated, token refresh, and account switching.

## Acceptance Criteria

- Driver registration success upserts the FCM token using `registrationId` without requiring a JWT.
- Authenticated driver and delivery-manager login/restore upsert the correct endpoint with the existing device ID and official platform casing.
- Token refresh uses the current identity context, not stale initialization arguments.
- Logout attempts the correct deactivation endpoint before clearing credentials and still completes on failure.
- `204 No Content` succeeds without response-body decoding.
- Foreground, background-tap, and terminated-tap paths route a supported notification at most once.
- Android uses the exact high-priority channel ID required by the backend.
- Errors use existing `ApiResult`/`Failure` infrastructure and do not block primary flows.
- No token, JWT, call token, or sensitive notification payload is printed or persisted insecurely.
- Unsupported/malformed notifications fail safely.
- No existing notification-list UI or unrelated feature is redesigned.
