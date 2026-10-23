# Driver authentication refresh

Implemented against the direct `/api/v1/auth/refresh` response. Replacement access and refresh tokens (and expiries) are committed as one secure-storage JSON record. Legacy token keys remain readable for existing installations.

One `AuthRefreshService` owns rotation across Dio, Dart SignalR clients and Android voice HTTP/SignalR through `mealmate/auth_session`. Native Android never rotates refresh credentials independently. The main Flutter engine explicitly activates the bridge so a background FCM engine cannot steal refresh ownership.

Proactive expiry checks use JWT `exp` or the server-provided UTC expiry at the two-minute threshold. Requests, native heartbeat/signaling, periodic checks and app resume trigger expiry checks. Native SignalR reconnect reconciles the existing call and binds the existing voice device session. A healthy connection is not deliberately restarted on token rotation.

401 and initiate 409 `calls.auth_refresh_required` replay once. A late 401 from an old access token reuses the already rotated token. Transient failures use a 15-second cooldown and preserve credentials; an unexpired token can still carry heartbeat traffic after a failed proactive refresh. An expired token waits for successful renewal.

Only definitive refresh errors (`auth.invalid_refresh_token`, `auth.account_suspended`, `auth.account_closed`, `family.password_setup_required`) clear the session. Missing renewal credentials on a locally authenticated session also require login. Local media, timers, heartbeat, service and notification are cleaned before credentials are cleared and login is shown, without waiting for server close. Password-setup errors return through login to obtain the verification credential required by the existing setup screen.

Initiation keeps its client request ID across ambiguous failures. Android retries a lost HTTP initiation response with the same request body/key; subsequent retries reconcile `/voice-calls/active`. Native initiation receives the already owned device session/proof instead of registering a second device.

## Files changed for this task

- `lib/core/services/auth_refresh_service.dart`
- `lib/core/services/token_interceptor.dart`
- `lib/core/services/token_service.dart`
- `lib/core/services/auth_session_lifecycle.dart` (new)
- `lib/core/di/di.dart`
- `lib/main.dart`
- `lib/features/driver/orders/data/realtime/driver_orders_signalr_client.dart`
- `lib/features/dispatcher/dispatcher_map/data/realtime/dispatcher_map_signalr_client.dart`
- `lib/features/driver/calling/data/realtime/driver_voice_call_signalr_client.dart`
- `lib/features/driver/calling/data/repo/driver_calling_repository_impl.dart`
- `lib/features/driver/calling/presentation/manager/driver_calling_view_model.dart`
- Android voice engine: `VoiceApiClient.kt`, `VoiceAuthBridge.kt` (new), `VoiceCallStore.kt`, `VoiceSignalRClient.kt`, `NativeCallCoordinator.kt`, `DriverVoiceEnginePlugin.kt`
- Dart tests: `auth_refresh_service_test.dart`, `token_interceptor_test.dart`, `shared_auth_flow_test.dart` (new), `auth_session_lifecycle_test.dart` (new)
- Android tests: `VoiceApiClientTest.kt` (new), `VoiceCallStoreTest.kt`, `NativeCallCoordinatorTest.kt`

## Validation and device checks

Validation: 134 Flutter/auth/calling tests and 24 SignalR tests passed, plus 29 Android unit tests. Targeted static analysis and whitespace checks are run for changed sources.

Automated tests cover proactive renewal, concurrent 401 single flight, exact 409 replay with stable device proof/key, bounded repeated 401, transient network recovery, terminal error cleanup ordering, logout races, app resume after expiry, and native lost-initiation-response replay. Existing calling tests run alongside these checks.

Real-device validation remains required: a call lasting over 10 minutes across multiple rotations with audible two-way audio, background/screen-off transitions, network loss/reconnect, definitive refresh failure while audio is active, and server reconciliation/notification cleanup. HTTP/unit tests cannot establish audio continuity. Android implementation is compiled and unit tested; no iOS runtime validation is claimed.

Android delegates renewal to the live main Flutter engine, including while its UI is backgrounded. If the OS destroys that engine, the native layer does not independently rotate an old refresh token; server recovery deadlines still apply. Recovery timeouts and missed-call qualification remain server decisions; no local attempt count is invented.
