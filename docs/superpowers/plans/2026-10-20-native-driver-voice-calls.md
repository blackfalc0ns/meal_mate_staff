# Native Driver Voice Calls — Implementation Plan

> **For agentic workers:** Use executing-plans to implement this plan task-by-task after design acceptance. Checkboxes track independently reviewable deliverables. This document defines intended work; it is not evidence of implemented or device-verified behavior.

**Goal:** Keep driver-originated voice calls independent of the Flutter UI, with native system integration, correct permissions, audible ringback, audio routing, proximity behavior, recovery, and deterministic termination on Android and iOS.

**Architecture:** Flutter retains delivery workflows and presentation. A typed platform bridge connects it to one native call coordinator per platform. Each coordinator owns call REST operations, SignalR, WebRTC, device-session ownership, call timers, ringback, and system-call integration. A call never has simultaneous Dart and native owners.

**Stack:** Existing Flutter application; Kotlin/Coroutines/Core-Telecom on Android; Swift/CallKit/AVAudioSession on iOS; native WebRTC and compatible SignalR implementations selected and pinned after interoperability verification. No new Compose or XML call screen.

## Scope and assumptions

- One outgoing audio call at a time, initiated by a driver from the visible application.
- Background and locked-screen continuity are requirements. Android recent-task dismissal is a device-tested target, not a survival guarantee. Process death, force-stop, shutdown, and iOS user termination are not supported continuity guarantees.
- Incoming customer-to-driver calls, PushKit, native incoming FCM routing, and incoming system UI are a separate feature. However, if the existing server registration contract requires an APNs VoIP token even for outgoing iOS devices, satisfy that prerequisite or obtain an explicit backend contract change before iOS rollout.
- Native ownership is the selected target, not a claim that full native migration is necessary merely to support background audio.
- Local native means independent of the Flutter engine, not independent of the application OS process.
- Preserve delivery contact hold/resume/reveal-phone business rules. They are not audio hold operations.

## Verified starting points

- `lib/features/driver/calling/data/webrtc/driver_webrtc_manager.dart`: Dart-controlled audio acquisition, offer/answer/ICE, mute and speaker. Disconnected/failed connection states currently log events without a complete recovery policy.
- `lib/features/driver/calling/data/realtime/driver_voice_call_signalr_client.dart`: SignalR authentication, binding, reconnect, event identity and generation logic.
- `lib/features/driver/calling/data/repo/driver_calling_repository_impl.dart`: call REST orchestration, registration, heartbeat, authoritative snapshots, reports, and CallKit integration. Native mute events currently route to `toggleMute(true)` without preserving an unmute value.
- `lib/features/driver/calling/presentation/manager/driver_calling_view_model.dart`: delivery preflight, initiation, UI state, duration and deadline timers. Some 409 recovery paths infer ended after unsuccessful state retrieval. Initiation errors clear request identity even when the server outcome may be ambiguous.
- `lib/features/driver/calling/data/callkit/driver_callkit_coordinator.dart`: outgoing plugin integration and ringtone configuration, no explicit outgoing ringback player.
- `android/app/src/main/AndroidManifest.xml`: microphone and microphone foreground-service permissions exist; native call service is not declared here. Audit the merged manifest as plugins may contribute components.
- `ios/Runner/Info.plist`: no microphone usage description; background modes currently include location/fetch/remote-notification, not audio.
- `ios/Runner/AppDelegate.swift`: Flutter implicit-engine registration; native coordinator must outlive engine attachment.
- Android has two source MainActivity packages; resolve manifest namespace and actual built activity before editing. Do not rename the application ID as part of this feature.
- No `ios/Podfile` was found during review. Determine whether this checkout uses Swift Package Manager or needs CocoaPods configuration; absence of that file alone is not an iOS build diagnosis.
- Existing unrelated working change: `lib/core/network/network_constants.dart`; preserve it and read runtime configuration rather than overwriting it.

## Ownership map

| Concern | Target owner |
|---|---|
| Delivery eligibility, location refresh, contact workflow | Flutter business layer, before native start |
| Call initiation and uncertain-initiation reconciliation | Native coordinator |
| Voice session registration/binding and call HTTP headers | Native voice session manager |
| Authentication refresh | Shared account session authority accessible natively without Dart |
| SignalR and WebRTC, reconnect and ICE | Native coordinator and focused adapters |
| Heartbeat, reports, ringing deadline | Native coordinator |
| Server call state and sequence | Backend authoritative; native reconciles |
| Actual media state, audio route, mute and interruptions | Native audio/media and OS integration |
| Notification / CallKit | Native platform adapter |
| Call UI and delivery navigation | Flutter |
| Elapsed time | Render from native/server timestamps; Flutter ticker is presentation only |

## File map (new files are proposed)

Create a local plugin at `packages/driver_voice_engine/`, registered by the app. Keep platform classes under that plugin so `MainActivity` and `AppDelegate` remain thin integration points.

- `pigeons/driver_voice_api.dart`: versioned typed messages and bridge definition; generate Dart/Kotlin/Swift bindings together.
- `lib/driver_voice_engine.dart`: Flutter-facing interface.
- `lib/src/native_driver_voice_engine.dart`: generated bridge adapter and snapshot/event subscription handling.
- Android plugin package `com.mealmate.driver_voice_engine`: `DriverVoiceEnginePlugin.kt`, `VoiceCallService.kt`, `NativeCallCoordinator.kt`, `VoiceApiClient.kt`, `VoiceSignalRClient.kt`, `VoiceSessionManager.kt`, `NativeWebRtcSession.kt`, `TelecomCallAdapter.kt`, `RingbackPlayer.kt`, `ProximityController.kt`, `VoiceCallStore.kt`.
- iOS plugin sources: `DriverVoiceEnginePlugin.swift`, `NativeCallCoordinator.swift`, `VoiceAPIClient.swift`, `VoiceSignalRClient.swift`, `VoiceSessionManager.swift`, `NativeWebRTCSession.swift`, `CallKitAdapter.swift`, `CallAudioController.swift`, `RingbackPlayer.swift`, `ProximityController.swift`, `VoiceCallStore.swift`.
- Add native unit tests beside each platform implementation and Dart bridge tests under the plugin.
- Modify current calling repository/ViewModel/screen, app dependency injection, localization files, `pubspec.yaml`, platform configuration, and login/logout integration.
- Add one licensed, bundled ringback asset to the plugin with equivalent availability on both platforms.

## Phase 0 — Protocol, dependency, and device feasibility gates

- [ ] Read applicable repository instructions and existing voice contracts before implementation. Record current endpoint paths, headers, status/sequence rules, session expiry, heartbeat interval, offer ownership, generation semantics, and timeout behavior from actual contracts.
- [ ] Capture the current DTO wire shapes as fixtures with synthetic data. Native and Dart decoders must accept the same representative fixtures.
- [ ] Resolve capabilityVersion disagreement documented in existing amendments with backend evidence; do not silently downgrade after 403.
- [ ] Confirm the precise meaning of server Ringing: delivery to a provider is not proof that the customer device is audibly ringing. Define the driver label and local ringback accordingly.
- [ ] Verify supported native SignalR clients against negotiate, transport, JWT factory, hub method names, acknowledgments, reconnect and binding. Do not replace SignalR with a raw WebSocket implementation.
- [ ] Pin native WebRTC dependencies, compare codecs/SDP/candidate serialization with the existing customer app, and confirm native packaging does not introduce duplicate WebRTC binaries.
- [ ] Confirm iOS auth refresh can work without callbacks into Dart, and that server device registration can be satisfied. These are release blockers for an independent native engine.
- [ ] Establish baseline Android builds and iOS build mechanism. Record minimum and target OS versions from resolved builds, not guessed constants.
- [ ] Run a two-way audio proof on a real Android and a real iPhone through the actual backend, including backgrounding and screen lock. Verify signaling and audio together before expanding migration.

**Exit:** chosen dependencies build on supported targets and exchange real audio with the existing customer implementation. Failure keeps the existing engine available; no production switch or deletion.

## Phase 1 — State machine and bridge contract

- [ ] Define commands: `getCapabilities`, `getCurrentCall`, `startOutgoing`, `setMuted`, `selectAudioRoute`, `hangUp`, and account-session synchronization/revocation. The call service cannot require a Flutter event listener to execute commands from system surfaces.
- [ ] `startOutgoing` accepts `tripStopId`, stable `clientRequestId`, and sanitized display metadata. Its network initiation body remains exactly the backend contract; do not add display data to that body.
- [ ] Commands return a typed success/error and acknowledged state; distinguish permissionDenied, permanentlyDenied, busy, unauthenticated, preparationFailed, transportUnavailable, ambiguousInitiation, and serverRejected.
- [ ] Snapshot fields include schemaVersion, engineInstanceId, localRevision, operationId, optional callId, tripStopId, serverSequence, generation, serverStatus, mediaState, connectedAtUtc, deadlineAtUtc, muted, audioRoute, availableRoutes, interruptionState, terminationReason, and serverEndPending.
- [ ] Server sequence and local revision are separate: media/mute/route can change without a new server event. Subscribe then request a snapshot and discard older revisions from the same engine instance; resync on engine instance change.
- [ ] Use one serialized coordinator queue/actor per platform. Guard every completion using operation identity, call ID and negotiation generation. Terminal state blocks late media callbacks and stale REST completions.
- [ ] Keep reconnecting/ending/preparing as presentation or media states; do not invent backend status values.
- [ ] Write state tests for duplicate events, reversed responses, end-during-start, old-generation ICE, terminal-then-active, engine detach/attach, and repeated hangup.

**Exit:** both platform reducers and Dart adapter agree on fixtures and race behavior without using real audio.

## Phase 2 — Permission and preflight

- [ ] Set a preflight guard before requesting permission to prevent concurrent prompts and double taps. Check permission without creating a voice call.
- [ ] On first call tap, explain microphone use when needed, request OS permission, proceed only on grant, and show Settings navigation only when appropriate for persistent denial.
- [ ] Add localized iOS microphone purpose text. Audit runtime Android microphone, notification and applicable Bluetooth permissions; notification denial is not automatically microphone denial.
- [ ] Perform delivery eligibility and fresh-location preflight in Flutter. If eligibility or location refresh fails, no voice initiate request is sent.
- [ ] Native start repeats critical readiness checks, confirms no existing call, validates native auth/session and binds signaling. Failure to bind must fail preparation explicitly, not silently proceed.
- [ ] Preserve clientRequestId until the start outcome is resolved. On a transport timeout, reconcile active/snapshot and retry only with the same identity according to backend idempotency rules.
- [ ] If cancellation happens before a late initiation response reveals the server call ID, cancel that identified call under the original operation, without replacing any newer session.

**Exit:** denial sends zero initiate requests; rapid taps create at most one call; ambiguous HTTP outcomes cannot create duplicate ringing sessions.

## Phase 3 — Native networking and account ownership

- [ ] Make access/refresh credentials available through a secure platform account session store. Do not persist tokens in plain plugin preferences, event logs, notification extras or fixtures.
- [ ] Account refresh must be single-flight across Flutter and native networking. Integrate native call refresh with the account authority; if the current authority is Dart-only, implement a coordinated native authority and adapt Flutter to it before claiming engine independence.
- [ ] Preserve existing voice session IDs, proof/header rules and account scoping. Refresh JWT on 401 according to the existing contract. Classify 403 rather than blindly rotating device registration.
- [ ] Do not rotate voice-device ownership during an active call. Reconnect means reauthenticate and rebind the same valid voice session, then reconcile.
- [ ] Decode and enforce signaling envelope IDs, sequence, sender session, generation and size limits. Queue early ICE until the correct remote description is set; bound queues and remove them on termination.
- [ ] Keep TURN credentials transient and honor server expiry. Never embed TURN shared secrets or APNs private keys.
- [ ] Make heartbeat cadence, ringing expiry, reconnect retry bounds and report retry rules match verified server contracts. Prevent concurrent heartbeat requests and cancel all retries on operation change.
- [ ] On logout/account switch, stop local capture immediately, attempt bounded call termination, clear voice session ownership, revoke as supported, and prevent callbacks from the previous account.

**Exit:** a token refresh and SignalR reconnect succeed during a background call without Dart participation, duplicate registration or ownership loss.

## Phase 4 — Android implementation

- [ ] Resolve the actual `MainActivity` class from namespace/manifest and merged manifest. Preserve the app's existing application ID and unrelated location service.
- [ ] Host the coordinator in a foreground `VoiceCallService`, not in the Activity or Flutter plugin attachment. Bind/unbind UI without stopping an active call.
- [ ] Integrate Core-Telecom `CallsManager` for outgoing call lifecycle, callbacks, mute and endpoints. Declare MANAGE_OWN_CALLS and phone-call foreground service prerequisites; include microphone type/permission where actual service microphone access and target OS require them. Verify merged declarations against the chosen SDK rather than copying a permission list blindly.
- [ ] Begin the user-initiated microphone service from the visible Activity after permission grant. Meet foreground promotion and call notification timing rules; do not use BOOT_COMPLETED to restore live calls.
- [ ] Post CallStyle notification with safe customer label, call state, chronometer where available, return-to-call PendingIntent and end/mute actions. Actions execute in native code without bootstrapping Flutter. Reject stale call IDs.
- [ ] Use Telecom endpoints as the source of audio route state. Do not concurrently call manual Bluetooth SCO/communication-device routing from the old Flutter WebRTC helper.
- [ ] Implement native WebRTC peer connection and audio session ownership. Report local transport connection separately from confirmed backend Active and RTP observations.
- [ ] Apply supported proximity screen-off behavior only for earpiece calling; check sensor capability. Release proximity/wake resources on route changes, termination and initialization failures. A missing sensor leaves audio usable.
- [ ] Task dismissal must not intentionally end the service; test the actual service behavior and OEM restrictions. Never claim a service survives process death or force-stop.
- [ ] After process death/relaunch, reconcile server state; persisted metadata does not recreate a live peer connection or automatically justify microphone capture.

**Exit:** audio continues with UI detached, Home and screen lock; notification controls work without Dart; tested task-dismissal behavior is recorded for each device.

## Phase 5 — iOS implementation

- [ ] Own the coordinator at process/plugin subsystem lifetime, independent of a Flutter scene or engine. Follow current implicit-engine registration in AppDelegate.
- [ ] Integrate one CXProvider and CXCallController. Map backend call identity to one stable native UUID. Implement start/end/mute/reset callbacks once; do not leave the old plugin registering a second provider for migrated calls.
- [ ] Add microphone usage description and background audio capability. Check signing/entitlements and dependency integration on macOS; add VoIP-specific capability only for the actual supported feature and contract requirements.
- [ ] Configure AVAudioSession for two-way voice with the selected WebRTC audio device integration. Observe CallKit didActivate/didDeactivate; configure before activation and start/stop device audio with system callbacks, not independent competing setActive calls.
- [ ] Implement native SignalR and HTTP/token refresh while the legitimate call audio session is running. Do not assume arbitrary background timers or sockets can run indefinitely when no active audio call exists.
- [ ] Handle audio interruptions, media-services reset, route changes and Bluetooth through one audio controller. Reflect actual mute/route in Flutter. Do not automatically resume capture after every interruption without checking call ownership and OS permission to resume.
- [ ] Enable UIDevice proximity monitoring only when appropriate for the active earpiece call, verify device support, and disable on end/route change. Use system behavior rather than a black Flutter overlay.
- [ ] Report outgoing connection and termination to CallKit with appropriate reasons. Handle provider reset locally even if server cleanup must be retried later.
- [ ] Device-test lock button behavior with available accessibility/settings combinations; pressing lock may act as an end-call action. Respect the OS action rather than promising to override it.
- [ ] If the app is terminated, do not claim media survival. On launch reconcile stale system/server state without replaying start commands.

**Exit:** two-way audio survives normal backgrounding and screen lock under tested settings; CallKit mute/end and route changes work; no dependence on Dart for an established call.

## Phase 6 — Ringback and connection truth

- [ ] Bundle a licensed ringback asset; no network download. Native player obeys the selected communication route and call audio session.
- [ ] Start only for the verified server state representing ringing. Created/preparing does not assert that the customer device rang.
- [ ] Stop on Accepted, connecting handoff, rejection, timeout, cancellation, failure, end, interruption or operation change. Stop is idempotent and cannot restart from a late ringing event.
- [ ] If a supported future protocol supplies remote early media, suppress local ringback; do not play both.
- [ ] Ringback is playback only and is not intentionally inserted into the transmitted microphone track. Verify acoustic echo behavior on speaker.
- [ ] Send reports based on their server-defined meaning; peer connected is not proof the user can hear audio. Use selected candidate pair and increasing RTP counters for diagnostic evidence, with human two-way audio verification on devices.

**Exit:** caller hears ringback through selected route; client acceptance stops it before conversation audio; no tone survives a terminal path or overlaps another call.

## Phase 7 — Recovery and termination

- [ ] Treat transient media disconnection separately from permanent failure. Show reconnecting, attempt supported recovery within a documented contract-aligned bound, and preserve a functioning media connection when signaling alone reconnects.
- [ ] ICE restart requires supported generation/offer ownership rules. If unsupported by the server/customer contract, terminate cleanly after the bound instead of fabricating a restart protocol.
- [ ] Rebind then retrieve authoritative call state on signaling reconnect. Reconcile on foreground resume and expired ringing deadline; a failed fetch is unknown, not confirmed ended.
- [ ] On local end, stop ringback and microphone immediately; send cancel for Created/Ringing and end for Accepted/Connecting/Active, reconciling 409 races with the server.
- [ ] Track serverEndPending separately from local media ended. Persist only minimal account-bound reconciliation metadata; use contract-safe bounded retries and never report success from a failed snapshot request.
- [ ] Cleanup once: invalidate operation, cancel timers, release tracks/peer, stop tone, stop signaling subscriptions for that call, close system UI, release proximity/audio resources and stop idle service. Each callback verifies identity before touching a newer call.
- [ ] Programmatic CallKit/Telecom closure cannot trigger a duplicate server end. Native mute preserves the boolean value; end commands are idempotent.

**Exit:** simultaneous remote/local hangup, failed HTTP end, duplicate events and network loss cannot leave a microphone, tone, service or stale call UI alive.

## Phase 8 — Flutter migration and presentation

- [ ] Register the local plugin and implement a DriverVoiceEngine abstraction behind existing calling domain interfaces.
- [ ] Keep delivery eligibility/location/contact business behavior in the existing layers. Adapt the calling repository so native-owned endpoints and session operations have no active Dart duplicates.
- [ ] Replace ViewModel media/heartbeat/deadline ownership with native snapshot subscription. Compute displayed duration from connectedAtUtc with synchronized time; UI ticker can stop without changing the call.
- [ ] Display preparing, dialing/ringing, accepted/connecting, connected, reconnecting and terminal outcomes with localized text. Distinguish actual confirmed mute/route from a pending requested change.
- [ ] Keep existing visual identity. Add return-to-call bar above existing navigation while a native call exists; returning opens the same call, never initiates another.
- [ ] Preserve authorized customer name source. Existing display endpoint contains driver/order fields and must not accidentally label the driver as the customer.
- [ ] Restore UI by current snapshot after navigation, engine recreation or notification opening. Screen disposal detaches presentation only.
- [ ] Remove production fallback UI that advances a fake call timer or changes only local mute/speaker indicators without a real coordinator.

**Exit:** the UI can be destroyed and recreated during one native call without renegotiation, duplicate initiate, state reset, or audio interruption caused by screen ownership.

## Phase 9 — Tests and acceptance

Use a synthetic shared contract fixture suite and real-device interoperability tests, not just mocked REST success.

| Scenario | Required result |
|---|---|
| First permission grant / deny / persistent denial | Start only after grant; zero server call on refusal |
| Double tap / timeout after server accepted initiate | One operation, stable request ID, reconcile outcome |
| Ringing / reject / no answer / cancel | Correct tone lifetime and terminal cleanup |
| Answer then media connects | No tone overlap; truthful states and duration |
| Early ICE / duplicate events / old generation | Applied once to correct session or rejected |
| Home / app navigation / lock screen | Established call continues under supported OS behavior |
| Android task dismissal | Observed result recorded per tested device; no survival guarantee |
| iOS termination / Android force-stop / process kill | No fictional continuation; reconcile after relaunch |
| Speaker / earpiece / Bluetooth / wired headset | Actual route matches system and Flutter state |
| Near/far sensor and speaker switch while near | Screen behavior follows supported route; resources released |
| Cellular interruption / system mute / headset end | Native and Flutter state agree; no duplicate callbacks |
| Wi-Fi to data / short outage / TURN relay-only | Recovery or bounded clean end; real audio checked |
| JWT expiry / SignalR reconnect / voice session invalid | Safe refresh/rebind or explicit failure without blind rotation |
| End while offline / 409 plus failed fetch | Immediate local privacy cleanup; server state stays pending/unknown |
| Logout/account switch / old callback arrives | Old call and identity cannot affect the next account |
| Terminal call then second outgoing call | No stale tones, timers, events, routes or service state |

- [ ] Flutter: analyze, relevant existing tests, bridge/ViewModel tests, navigation restoration tests, and release Android build.
- [ ] Android: native unit tests, instrumentation for service/notification actions and activity detach; actual supported-OS device matrix including recent target-SDK restrictions and at least one restrictive OEM.
- [ ] iOS on a Mac: native unit tests, simulator build for compilation, signed physical-device build, background/CallKit/audio tests on real iPhones. This Windows checkout cannot certify iOS audio or signing.
- [ ] Diagnostics log call identity, generation and transitions without JWT, proof, SDP, ICE credentials, phone or sensitive address payloads. Record RTP statistics without exposing secrets.
- [ ] Acceptance record lists device/OS/build, backend version, selected candidate type, action sequence and actual two-way-audio result. Mark unavailable device checks as unverified.

## Phase 10 — Cutover and deletion

- [ ] Maintain one build/session selection of legacy or native engine during rollout. Never fail over mid-call by starting the other engine.
- [ ] Switch each platform only after its acceptance gates pass. A new-call rollback is allowed after prior session resources are fully released.
- [ ] Delete old Dart WebRTC, heartbeat, signaling and CallKit runtime ownership only after confirming references and other feature usage. Retain shared business DTOs and delivery APIs where still needed.
- [ ] Remove flutter_webrtc/flutter_callkit_incoming dependencies only if no remaining supported flow uses them; remove duplicate native WebRTC linkage and plugin providers.
- [ ] Repeat relevant build, contract and device tests after deletion. Produce a final changed-file report, tested-device evidence and explicit remaining limitations.

## Implementation order

Protocol/dependency gates → bridge/state reducer → permission/preflight and native auth foundation → Android native call proof → iOS native call proof → complete media/signaling/recovery on both → ringback/audio/proximity/system controls → Flutter cutover → device acceptance → legacy deletion.

No delivery estimate is asserted until the native SignalR/WebRTC compatibility, iOS build tooling, device registration prerequisites and account refresh ownership are proven.

## Official platform references

- Android Core-Telecom: https://developer.android.com/develop/connectivity/telecom/voip-app/telecom
- Android foreground-service types: https://developer.android.com/develop/background-work/services/fgs/service-types
- Android background service-start restrictions: https://developer.android.com/develop/background-work/services/fgs/restrictions-bg-start
- Apple CallKit audio activation: https://developer.apple.com/documentation/callkit/cxproviderdelegate/provider(_:didactivate:)
- Apple background modes: https://developer.apple.com/documentation/xcode/configuring-background-execution-modes
- Apple proximity monitoring: https://developer.apple.com/documentation/uikit/uidevice/isproximitymonitoringenabled
