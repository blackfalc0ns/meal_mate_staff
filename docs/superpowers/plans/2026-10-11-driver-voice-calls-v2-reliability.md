# Driver Voice Calls v2 Reliability Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** إصلاح دورة حياة مكالمات الصوت في تطبيق المندوب بحيث تلتزم بعقد Backend v2، تمنع الأحداث والموارد القديمة من التأثير على مكالمة جديدة، وتثبت الاتصال والصوت فعليًا قبل عرض حالة Active أو بدء العداد.

**Architecture:** الحفاظ على الطبقات الحالية ViewModel → Repository → REST/SignalR/WebRTC/CallKit. سيكون `callId` و`lifecycleEpoch` و`negotiationGeneration` هوية العملية، وسيكون snapshot السيرفر هو المصدر النهائي للحالة والوقت. كل await أو callback سيُتحقق بعده من أن العملية ما زالت تملك نفس الموارد قبل تنفيذ side effects.

**Tech Stack:** Flutter/Dart، Dio/Retrofit، `signalr_netcore` الموجود، `flutter_webrtc`، `flutter_callkit_incoming`، Flutter Bloc/ViewModel، اختبارات unit/widget الحالية.

**Spec:** تعليمات `2026-10-11-mobile-driver-voice-calls-fixes.md` المرسلة في المحادثة، مع `docs/voice-calls-driver-amendments.md` و`docs/voice-call-driver-implementation-handoff-2026-10-10.md`.

## Global Constraints

- التنفيذ داخل تطبيق المندوب فقط وعلى branch `feature/voice-calls-v2`.
- لا تعديل Backend أو تطبيق العميل أو الاستضافة أو إضافة SignalR/networking library ثانية.
- الحفاظ على `protocolVersion=2` وأسماء REST/Hub/JSON الحالية.
- لا downgrade صامت لـ capability version، ولا تعطيل deadlines أو timeouts أو device validation.
- لا تسجيل Authorization أو token أو controlProof أو SDP أو ICE أو TURN credentials أو رقم الهاتف أو العنوان.
- تسجيل diagnostics آمن فقط: `callId`, `eventId`, `sequence`, `epoch`, `generation`, HTTP status، وسبب القرار.
- لا اعتبار `200 OK` أو اتصال SignalR أو اتصال peer من طرف واحد دليلًا على وجود صوت.
- الحفاظ على التغييرات الموجودة في working tree وعدم عمل refactor خارج نطاق المكالمات.
- قبل كل تعديل: فحص الاختبار الموجود وإعادة إنتاج السلوك؛ بعد كل تعديل: اختبار focused ثم regression.
- لا commit أو push ضمن التنفيذ إلا إذا طلب المستخدم ذلك صراحة.

## File Map

- Modify `lib/core/di/di.dart`: ترتيب تسجيل `ServerClock` قبل أول eager dependency التي تحل Dio/location coordinator.
- Modify `lib/features/driver/calling/data/repo/driver_calling_repository_impl.dart`: operation identity، دمج snapshot، cleanup scoped، reports، session/bind reconciliation.
- Modify `lib/features/driver/calling/data/realtime/driver_voice_call_signalr_client.dart`: sequence/dedupe لكل call، foreign-event filtering، bind/rebind، RTC envelope.
- Modify `lib/features/driver/calling/data/webrtc/driver_webrtc_manager.dart`: generation-scoped ICE/media lifecycle، permission، remote media، cleanup.
- Modify `lib/features/driver/calling/presentation/manager/driver_calling_view_model.dart` و`driver_calling_state.dart`: deadline polling، retry requestId، authoritative timer، stale UI cleanup.
- Modify location eligibility consumers/datasources only where current implementation violates fresh GPS/ACK/tripStopId contract.
- Modify `lib/features/driver/calling/presentation/screens/driver_active_call_screen.dart` و`data/callkit/driver_callkit_coordinator.dart`: native actions، localized labels، cancel/end routing.
- Modify existing response/request DTOs/mappers only when actual contract requires it; do not duplicate existing layers.
- Add/modify focused tests under `test/features/driver/calling/` and `test/core/di/` as needed.

---

### Task 1: Baseline, contract checks, and safe diagnostics

**Files:**
- Read: `AGENTS.md` files, `docs/voice-calls-driver-amendments.md`, `docs/voice-call-driver-implementation-handoff-2026-10-10.md`
- Modify: only if needed, existing test/diagnostic seams in calling files
- Test: existing calling test suites

**Interfaces:**
- Consumes: current repository, SignalR client, WebRTC manager, ViewModel and CallKit APIs.
- Produces: a written reproduction record keyed by callId/sequence/generation; no production behavior change unless a test proves a defect.

- [ ] **Step 1: Inspect current branch and preserve existing work.**
  - Run `git status --short --branch`.
  - Record existing modified files; do not reset, stash, checkout, or overwrite them.
  - Confirm the branch is `feature/voice-calls-v2`.

- [ ] **Step 2: Run focused baseline tests.**
  - Run:
    ```
    flutter test test/features/driver/calling/data/repo/driver_calling_repository_impl_test.dart
    flutter test test/features/driver/calling/data/realtime/driver_voice_call_signalr_client_test.dart
    flutter test test/features/driver/calling/data/webrtc/driver_webrtc_manager_test.dart
    flutter test test/features/driver/calling/presentation/manager/driver_calling_view_model_test.dart
    flutter test test/features/driver/calling/presentation/screens/driver_active_call_screen_test.dart
    ```
  - Record failures before code changes; distinguish pre-existing failures from regressions.

- [ ] **Step 3: Add only secret-safe diagnostics where the existing code has no visibility.**
  - Use structured fields limited to callId/eventId/sequence/epoch/generation/status/reason.
  - Explicitly redact URL query strings, headers, tokens, proofs, SDP, ICE and payload bodies.
  - Capture the first broken boundary for initiate → event → bind → offer/answer/ICE → reports → terminal.

- [ ] **Step 4: Verify the deployed contract before serializing new values.**
  - Confirm hub path `/hubs/voice-call-v2`, `access_token` SDK callback, bind argument order, event names, envelope casing, and capabilityVersion 2.
  - Confirm `/ice-servers` returns expiring credentials; consume returned URLs dynamically.
  - If an environment check is unavailable, record it as a blocker instead of hardcoding or weakening validation.

---

### Task 2: Fix DI bootstrap ordering

**Files:**
- Modify: `lib/core/di/di.dart:1047-1050` and `_buildDio:1176` (verify exact lines before editing)
- Test: existing DI/bootstrap tests or a new focused test under `test/core/di/`

**Interfaces:**
- Consumes: existing `ServerClock`, Dio, location coordinator, repository registrations.
- Produces: `configureDependencies` that resolves coordinator and calling repository without registered-type errors.

- [ ] **Step 1: Write a failing bootstrap test.**
  - Invoke the real `configureDependencies` setup in the test environment.
  - Resolve the location coordinator and driver calling repository.
  - Assert no registered-type exception and that the resolved `ServerClock` is the same dependency used by Dio/location consumers.

- [ ] **Step 2: Run the test and record the current failure.**
  - Run the focused test with `flutter test <test-path> -r expanded`.
  - Do not change registrations before confirming the failure.

- [ ] **Step 3: Register `ServerClock` before the first eager dependency that resolves Dio/location.**
  - Keep the current DI graph and scopes.
  - Change ordering only; do not replace the dependency architecture.

- [ ] **Step 4: Run bootstrap and calling regression tests.**
  - Expected: bootstrap resolves successfully; existing calling tests remain unchanged or pass.

---

### Task 3: Make initiate race-safe and snapshot-authoritative

**Files:**
- Modify: `lib/features/driver/calling/data/repo/driver_calling_repository_impl.dart:479-488` and `_handleSnapshot`
- Modify: existing initiate/snapshot DTO mapper only if fields are missing
- Test: `test/features/driver/calling/data/repo/driver_calling_repository_impl_test.dart`

**Interfaces:**
- Consumes: `initiate(tripStopId, clientRequestId)`, REST snapshot, SignalR lifecycle events.
- Produces: one operation token per call; one offer operation for the accepted call; merged snapshots ordered by callId/sequence.

- [ ] **Step 1: Add failing race tests.**
  - REST initiate remains pending while SignalR `Accepted` arrives, then `Ringing` arrives.
  - Assert state stays Accepted, offer is created once, and the late REST response cannot revert or cancel the active operation.
  - End/cancel during pending REST and assert completion cannot resurrect the call.

- [ ] **Step 2: Implement operation identity before the first await.**
  - Capture callId, lifecycleEpoch, and current resource generation before `await initiate`.
  - After every await, compare identity and return without side effects when stale.

- [ ] **Step 3: Merge REST and SignalR snapshots by callId and sequence.**
  - Reject foreign call IDs.
  - Reject lower/equal committed sequence for the same call.
  - Never let an old terminal response reopen a terminal call.

- [ ] **Step 4: Ensure Accepted-before-Ringing is idempotent.**
  - Do not restart offer creation when Ringing arrives late.
  - Keep one offer and one negotiation generation for the operation.

- [ ] **Step 5: Run repository tests.**
  - Expected: race tests pass; existing initiate/end/reconnect tests remain green.

---

### Task 4: Scope sequence, foreign events, and SignalR session binding

**Files:**
- Modify: `lib/features/driver/calling/data/realtime/driver_voice_call_signalr_client.dart:210-215`, connect/rebind methods near current `connect`/`ensure`
- Modify: `driver_calling_repository_impl.dart:411-434` registration integration
- Test: `test/features/driver/calling/data/realtime/driver_voice_call_signalr_client_test.dart`

**Interfaces:**
- Consumes: lifecycle envelope `eventId, protocolVersion, callId, sequence, eventType, occurredAtUtc, sentAtUtc, expiresAtUtc?, payload`; `BindDeviceSession(deviceSessionId, controlProof)`.
- Produces: per-call committed sequence/event dedupe, bound session ID, and authenticated rebind behavior.

- [ ] **Step 1: Add failing event-order tests.**
  - Deliver A sequence 8, B sequence 1, B sequence 2, then a replay of A.
  - Assert B sequence 2 is accepted, A terminal does not terminate B, and replay does not repeat resources.
  - Deliver a foreign call event and assert no state mutation or WebRTC side effect.

- [ ] **Step 2: Replace global sequence state with per-call state.**
  - Store committed sequence and event IDs keyed by callId.
  - Filter callId before any callback side effect.
  - Preserve terminal immutability per call.

- [ ] **Step 3: Make binding explicit and session-safe.**
  - Persist `boundSessionId`, compare it with secure storage, and require connected + bound before RTC sends.
  - On session change, bind the new session and stop using the old proof.
  - Do not rotate session during an active call merely to retry a control request; reconcile authoritative state first.

- [ ] **Step 4: Rebind after reconnect and token refresh.**
  - Let SDK access-token callback handle JWT.
  - Rebind only when the session/proof is valid and the app is executing.
  - Redact connection URLs and authentication data from diagnostics.

- [ ] **Step 5: Run SignalR tests.**
  - Expected: exact bind arguments, per-call ordering, foreign filtering, replay dedupe, and reconnect behavior pass.

---

### Task 5: Make cleanup and WebRTC lifecycle generation-scoped

**Files:**
- Modify: `lib/features/driver/calling/data/repo/driver_calling_repository_impl.dart:258-294, 723-736`
- Modify: `lib/features/driver/calling/data/webrtc/driver_webrtc_manager.dart:69`
- Test: `test/features/driver/calling/data/webrtc/driver_webrtc_manager_test.dart`, repository tests

**Interfaces:**
- Consumes: call/generation-scoped resource handles for peer connection, microphone, ICE queue, timers, and native UI.
- Produces: cleanup(A) that closes A resources only; terminal state that clears active UI/heartbeat/timer exactly once.

- [ ] **Step 1: Add failing cleanup interleaving tests.**
  - Start A, start B, finish cleanup A after B has started.
  - Assert B peer/mic/timer remain usable.
  - Start then end while cleanup is pending; assert no new peer is created after terminal.
  - Set active=null and assert UI/heartbeat/timer are stopped.

- [ ] **Step 2: Capture an operation token before the first cleanup await.**
  - After each await, verify the token still owns the resource being cleaned.
  - Use idempotent close/stop guards so repeated terminal events do not double-close.

- [ ] **Step 3: Separate resource ownership by callId and negotiation generation.**
  - ICE queue, peer connection, media tracks, timers, and native call UUID must not be global across calls.
  - Delete a queue only when its own call/generation reaches terminal.

- [ ] **Step 4: Make WebRTC manager cleanup explicit.**
  - Stop microphone tracks and close peer connection for the selected operation only.
  - Ignore stale callbacks after close.
  - Do not create a new peer or send ICE after terminal.

- [ ] **Step 5: Run cleanup and repository regression tests.**
  - Expected: no cross-call resource loss and no post-terminal WebRTC side effects.

---

### Task 6: Complete ICE, media reports, and authoritative duration

**Files:**
- Modify: `lib/features/driver/calling/data/webrtc/driver_webrtc_manager.dart`
- Modify: `lib/features/driver/calling/data/realtime/driver_voice_call_signalr_client.dart`
- Modify: `lib/features/driver/calling/data/repo/driver_calling_repository_impl.dart`
- Modify: `lib/features/driver/calling/presentation/manager/driver_calling_view_model.dart`
- Reuse: existing `report_voice_connecting_usecase.dart`, `report_voice_connected_usecase.dart`
- Test: WebRTC/repository/ViewModel calling tests

**Interfaces:**
- Consumes: dynamic ICE server response, remote descriptions/candidates, real media events, `connectedAtUtc`.
- Produces: connecting report during genuine setup, connected report after actual media, Active timer aligned to ServerClock.

- [ ] **Step 1: Add failing media-state tests.**
  - Assert early ICE is queued per call/generation and sent only after bind.
  - Assert local peer connected without remote media does not produce Active/timer.
  - Assert connected report is deduplicated per call/generation.
  - Assert denied microphone and failed ICE lookup end clearly without empty-server offer creation.

- [ ] **Step 2: Implement ICE queue and generation checks.**
  - Queue candidates before remote description, apply after answer, ignore stale generations.
  - Do not send empty end-of-candidates.
  - Enforce SDP ≤ 65,536 UTF-8 bytes and ICE candidate ≤ 4,096 bytes before sending.

- [ ] **Step 3: Require real media setup.**
  - Check microphone permission.
  - Create/add audio track before offer.
  - Record remote audio-track arrival and verify inbound/outbound RTP counters through getStats on physical devices.
  - Consume returned STUN/TURN URLs and expiry; do not hardcode TURN hosts or shared secrets.

- [ ] **Step 4: Send connecting/connected reports with idempotency.**
  - Send connecting when peer genuinely enters setup.
  - Send connected only after actual media connection.
  - Inspect failures and never convert a failed report into local Active.

- [ ] **Step 5: Start duration only from authoritative Active snapshot.**
  - Use snapshot `connectedAtUtc` and ServerClock offset plus monotonic elapsed time.
  - Stop timer on terminal or active=null.
  - Never start timer on Accept, local ICE connected, or REST connected.

- [ ] **Step 6: Run focused media tests and document physical-device-only checks.**
  - Unit tests prove ordering and guards.
  - Physical devices/networks prove two-way audio, RTP, and TURN relay; REST 200 cannot prove these.

---

### Task 7: Fix deadline polling, retry IDs, and eligibility/location gates

**Files:**
- Modify: `lib/features/driver/calling/presentation/manager/driver_calling_view_model.dart:172-198, 243-263, 451`
- Modify: `lib/features/driver/calling/presentation/manager/driver_calling_state.dart:92`
- Modify: current location coordinator/datasource and voice eligibility consumer only where tests identify stale GPS behavior
- Test: ViewModel and eligibility/location tests

**Interfaces:**
- Consumes: server `deadlineAtUtc`, eligibility `canInitiate/reasonCode`, driver-owned fresh location and ACK.
- Produces: bounded deadline reconciliation, correct retry semantics, and no initiate before eligibility.

- [ ] **Step 1: Add failing polling/retry tests.**
  - Repeated expired Ringing responses issue one bounded request at a time.
  - Accepted state stops ring timeout checks.
  - Ended call retried in the same VM gets a new requestId.
  - Ambiguous timeout reconciles active/snapshot before reusing the original requestId.
  - No initiate occurs with stale GPS, null/wrong tripStopId, or rejected ACK.

- [ ] **Step 2: Implement bounded deadline reconciliation.**
  - Use server deadline, not a fixed local timeout.
  - Permit one in-flight request and bounded delay.
  - Never invent Missed solely from a local timer; reconcile server state.

- [ ] **Step 3: Fix nullable requestId copy semantics.**
  - Distinguish “leave requestId unchanged” from “clear requestId”.
  - Reuse the same ID only for the same unresolved attempt.
  - Generate a new ID only after terminal state starts an independent attempt.

- [ ] **Step 4: Gate initiation on fresh eligibility.**
  - Read real GPS, verify correct tripStopId, wait for ACK, then recompute eligibility once.
  - Preserve privacy/location policies and show translated reasonCode.
  - Do not loop or initiate before readiness.

- [ ] **Step 5: Run ViewModel and eligibility tests.**
  - Expected: bounded request count, correct IDs, no stale eligibility, and no timer after terminal.

---

### Task 8: Correct native actions, localization, and terminal reconciliation

**Files:**
- Modify: `lib/features/driver/calling/presentation/screens/driver_active_call_screen.dart`
- Modify: `lib/features/driver/calling/data/callkit/driver_callkit_coordinator.dart`
- Modify: ViewModel/repository terminal handling
- Modify: existing `ar`/`en` localization resources
- Test: screen, CallKit, ViewModel terminal tests

**Interfaces:**
- Consumes: authoritative status enum and terminal events.
- Produces: correct cancel/end endpoint routing, one-time native cleanup, localized Ringing/Connecting/Customer/GPS labels.

- [ ] **Step 1: Add failing action-routing tests.**
  - Created/Ringing → `/cancel`.
  - Accepted/Connecting/Active → `/end`.
  - Terminal → local idempotent cleanup only.
  - Failed API result does not pop as if successful.
  - Programmatic CallKit close does not initiate another end request.

- [ ] **Step 2: Implement status-specific hangup routing.**
  - Check API result and show recoverable error when needed.
  - On 409, fetch snapshot and reconcile.
  - Stop media/native UI/route only after success or confirmed terminal snapshot.

- [ ] **Step 3: Reconcile remote terminal and reconnect.**
  - Verify callId and sequence before closing.
  - On foreground resume/reconnect/missed event, fetch active/current snapshot.
  - Terminal or absent call closes stale UI exactly once.
  - Stop heartbeat/timer/media with scoped cleanup.

- [ ] **Step 4: Move product copy to localization resources.**
  - Add translated labels using existing ar/en resource conventions.
  - Keep technical API/status identifiers untranslated.
  - Include Android 14 full-screen/notification/microphone permissions and iOS microphone privacy/VoIP prerequisites in verification records; do not add secrets or server credentials.

- [ ] **Step 5: Run native/UI regression tests.**
  - Expected: action routing, repeated native events, Arabic → English → Arabic, background/locked-screen behavior pass where platform permits.

---

### Task 9: Full verification and release evidence

**Files:**
- Modify: none unless a verified defect remains
- Create: `docs/superpowers/plans/2026-10-11-driver-voice-calls-v2-verification-report.md` only after implementation, if requested
- Test: all relevant calling suites and physical-device matrix

**Interfaces:**
- Consumes: all completed tasks and deployed backend environment.
- Produces: reproducible test evidence and explicit blockers.

- [ ] **Step 1: Run generated-code and static checks if applicable.**
  - Run `dart run build_runner build --delete-conflicting-outputs` only if DTO/Retrofit generation changed.
  - Run `dart format` on touched Dart files.
  - Run `flutter analyze`.
  - Run all focused calling tests, then `flutter test`.

- [ ] **Step 2: Execute physical-device matrix.**
  - Two customer/driver devices; foreground, background, terminated.
  - Initiate → incoming → Accept → offer/answer/ICE → audible two-way audio → authoritative Active timer → hangup.
  - Unanswered cancel, remote reject, either-party end, server deadline expiry.
  - Wi-Fi → mobile switch, reconnect, token/session refresh, microphone denied, cleanup during createOffer.
  - Two networks with forced TURN; confirm selected relay candidate and RTP counters.
  - Arabic/English RTL/LTR, mute, speaker, Bluetooth, lock screen, native end.

- [ ] **Step 3: Verify security and state invariants.**
  - No secret-sensitive logs.
  - No duplicate initiate or stale request IDs.
  - No technical failure unlocks phone reveal or qualifies Hold.
  - No stale UI/media/timer after terminal.
  - No session rotation during active call without authoritative recovery.

- [ ] **Step 4: Report results honestly.**
  - Include files changed, commands, pass/fail output, call IDs and terminal sequences (without secrets), physical-device-only checks, and environment blockers.
  - Do not claim audio from HTTP 200, SignalR connected, or local peer connected alone.

## Self-Review Checklist

- [ ] DI ordering covered.
- [ ] Initiate/REST-vs-SignalR race covered.
- [ ] Per-call sequence and foreign events covered.
- [ ] Scoped cleanup and WebRTC generation covered.
- [ ] Session binding/reconnect/proof rules covered.
- [ ] ICE/media/reporting/authoritative timer covered.
- [ ] Deadline polling/retry requestId covered.
- [ ] Fresh eligibility/location/ACK covered.
- [ ] Native actions/localization/terminal cleanup covered.
- [ ] Static, unit, integration, and physical-device verification covered.
- [ ] No backend/customer/hosting changes allowed.
 
