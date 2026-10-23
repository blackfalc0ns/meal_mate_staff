# Voice Calls v2 - Driver App Complete Plan

## Latest backend clarification — overrides older display/source guidance

This section is authoritative for the new display endpoint and clarified integration values. No separate backend attachment is required to implement these items.

### Call display data

- Use `GET /api/v2/voice-calls/{callId}/display` with JWT and `Accept-Language: ar|en`. Voice-device headers are not required.
- Only call participants are authorized. Other callers receive generic 404; do not interpret it as permission to try another endpoint.
- Response JSON fields:

```json
{
  "callId": "<uuid>",
  "tripStopId": "<uuid>",
  "driverName": "<string>",
  "driverImageUrl": "<relative URL or null>",
  "driverRole": "<localized string>",
  "vehicleType": "<string>",
  "plateNumber": "<string>",
  "deliveryAddress": "<string>",
  "deliveryZone": "<string>",
  "orderCode": "<string>",
  "mealSummary": "<string>",
  "slotLabel": "<string>",
  "boxCount": 1,
  "stopStatus": "PickedUp"
}
```

- Add a defensive nullable response DTO, mapper, display entity, existing ApiServices method, remote-data-source/repository method, display use case, and ViewModel intent/state fields according to this repository's conventions.
- Fetch after the current callId is known. Do not delay native incoming-call reporting/ringing while waiting for display HTTP. Initially show localized generic copy and update safely when display arrives.
- Reject late display responses if callId/account/language changed or the call ended. Display failure must not end a working call or prevent answering.
- driverRole is already localized by backend; do not translate that returned string again. driverName, deliveryZone and mealSummary use server bilingual fallback.
- driverImageUrl is relative: resolve against the existing configured base URL using URI resolution. Null/missing image uses the existing placeholder. Do not log address or cache private display data across accounts.
- deliveryAddress falls back to deliveryZone on old records. No active driver assignment can yield empty driverName and null image; retain a generic localized fallback.
- stopStatus is a technical code, not display copy. No phone number is returned.
- On language change, request display again with the new Accept-Language and guard against old-language responses.
- Do not use live-tracking as fallback for call display: backend explicitly reports that its ownership check is not yet fixed. Use the participant-authorized display endpoint.
- Tests: complete/missing/null DTO fields, relative image resolution, generic fallback, 404/timeout without disrupting media, late call/account/language responses, language refresh, and no telephone exposure.

### Confirmed mobile integration values

- Backend base URL: `https://maelmate.runasp.net`; reuse repository configuration, never hardcode it in feature classes. User reports deployment is complete; verify v2 availability as an integration check rather than assume the older document's unpublished status still applies.
- FCM registration: `POST /api/v1/driver/device-token` now returns HTTP 200 with `{"fcmDeviceTokenId":"<guid>"}`. Replace any void/204-only response contract with a DTO and map/persist the owned registry ID appropriately. Preserve the existing request body contract.
- Re-registering the same FCM token returns the same registry ID, so an ambiguous token-registration response can be recovered using the same token. Voice devices/register is separate and rotates the voice session; do not repeat it with every reconnect.
- Firebase project expected by backend: `mealmate-bd5b3` for both apps. Check existing mobile Firebase configuration before changing anything; never add service-account JSON or server signing keys to either app.
- iOS requires both FCM registry ID for cleanup and PushKit apnsVoipToken for incoming. Pass both in devices/register; there is no separate voice-token endpoint.
- SignalR JWT query parameter accepted by backend is `access_token`; let the SDK access-token callback manage authentication and redact URLs. controlProof is only a BindDeviceSession argument. RTC envelope includes messageId, callId, negotiationGeneration, senderDeviceSessionId, sentAtUtc, payload. Backend hub receive limit is 400 KB; SDP/candidate limits still apply independently.
- ICE credentials default TTL is 3600 seconds; honor actual expiresAtUtc/ttlSeconds. URLs may include STUN, TURN UDP/TCP and TURN TLS TCP. Default TURN ports are 3478 and 5349; consume actual returned URLs, not these defaults as hardcoded client configuration.
- The new reply still shows capabilityVersion=1 in an example while the v2 contract requires 2. This is not resolved by the reply: keep 2 as the contract implementation value and document verification with backend if registration/capability fails. Do not silently downgrade on 403.

### Correction to auth/session recovery instructions

- Earlier shorthand “401/403 register then retry” must not be followed indiscriminately. 401 uses existing JWT refresh first; 403 can mean a foreign account, non-winning device, revoked session or permission denial. Reconcile authoritative state and classify the cause before any registration.
- Never rotate an active call's device session just to retry answer/end/ICE; rotation invalidates old control ownership. Recover only when supported by authoritative state, otherwise cleanly surface the failure.
- Register renewal is automatic when application execution is available, not a guaranteed always-running background timer. An expired voice route may prevent push delivery; do not promise an expired session will be renewed by an incoming push.

## Goal
تنفيذ بدء وإدارة المكالمات داخل `lib/features/calling` في ريبو السواق مع الحفاظ على structure الحالية.

## Contract
- Base `/api/v2/voice-calls`; JWT Bearer، UTC/UUID/camelCase.
- Register/revoke مثل العميل، capabilityVersion=2؛ خزّن deviceSessionId/controlProof/expiresAtUtc.
- Eligibility: `GET /eligibility/{tripStopId}` = canInitiate, reasonCode, distanceMeters?, locationAgeSeconds?, canHold, canRetry, canRevealPhone, contactCaseId?.
- Initiate: `POST /initiate` body tripStopId, clientRequestId؛ retry الغامض يستخدم نفس UUID. Cancel/end، active/call/history/events، ICE، connecting/connected، heartbeat.
- Contact: `GET /api/v2/delivery-contact/{tripStopId}/case`; POST hold body notes, firstAttemptCallId؛ POST resume؛ POST reveal-phone body clientRequestId, reason, acknowledgedPrivacyWarning=true. PhoneGrant grantId, expiresAtUtc, customerPhone, contactCaseId، no-store.
- Snapshot statuses Created/Ringing/Accepted/Connecting/Active/Rejected/Cancelled/Missed/Failed/Ended؛ headers control/ICE = JWT + voice session + proof.

## Steps
1. اقرأ قواعد UI/Backend، راجع calling وdelivery/route وtripStopId وApiServices/Auth/refresh/push/native، وثبّت conventions. استخدم signalr_netcore الموجود ولا تضف SignalR ثانية.
2. أضف نسخة متوافقة من flutter_webrtc وflutter_callkit_incoming فقط؛ حافظ على Dio/Retrofit/Firebase/secure storage/DI.
3. أنشئ nullable DTOs/requests/mappers/entities/repositories/data sources/use cases وViewModel/State/Events لكل endpoints أعلاه.
4. سجّل FCM وخذ fcmDeviceTokenId الحقيقي، وسجّل الجهاز بinstallation ثابت. جدّد JWT والـvoice session عند launch/resume/before expiry، واعمل bind جديد؛ 401/403 register ثم retry مرة. Logout revoke/clear/stop.
5. لا تظهر زر الاتصال إلا بعد eligibility.canInitiate؛ اعرض reasonCode مترجمًا. initiate بـtripStopId وclientRequestId؛ timeout = reconcile active ثم نفس id مرة واحدة، لا UUID جديد.
6. SignalR `/hubs/voice-call-v2`: bind قبل SendOffer/Answer/ICE؛ events وmessageId/generation وeventId/sequence/dedupe؛ rebind/reconcile بعد reconnect.
7. بعد initiate اعرض outgoing UI بـflutter_callkit_incoming. بعد customer answer اجلب ICE، أنشئ WebRTC Offer generation 0، أرسله، طبّق Answer/ICE المبكر، connecting ثم connected بعد media الحقيقي، heartbeat، mute/speaker/end، cleanup terminal.
8. بعد كل terminal اقرأ case. Hold فقط canHold وبعد qualifying Missed حقيقي؛ أرسل notes وfirstAttemptCallId. Resume صريح بعد cooldown/location التي يقررها السيرفر. المحاولة الثانية initiate جديد. reveal-phone فقط canRevealPhone وبسبب وموافقة؛ افتح dialer فورًا بلا حفظ/Log للرقم.
9. حافظ على UI الحالية، استخدم error widgets، اعرض reason codes، وامنع double taps. لا تغيّر بيانات التوصيل عند فشل المكالمة جزئيًا.

## Security, failures, review
- لا raw FCM token/GUID بدل fcmDeviceTokenId؛ لا proof في URL/log/body؛ لا secrets/phone/SDP/ICE/TURN logs.
- لا تعدّ reject/cancel/technical failure/missing ringing-ack كمحاولة مؤهلة؛ لا تكشف الرقم قبل شروط السيرفر؛ لا Hold بدل بلاغ غير موجود.
- اختبر eligibility، idempotent initiate، 204، transitions، sequence/dedupe، session/JWT، bind/reconnect، Hold/Resume/reveal/expiry/logout.
- شغّل format/analyze/tests، ثم أجهزة حقيقية background/terminated، صوت ثنائي الاتجاه، TURN عبر شبكتين، network loss وsession rotation.
- بعد التنفيذ راجع كل بند هنا: لا fake eligibility/phone، لا duplicate initiate، لا stale UI، ولا raw DTOs في UI.

## Mobile prerequisites that must be confirmed before implementation
- Confirm one accepted `capabilityVersion` (handoff example 1 versus v2 contract 2) and use it consistently in driver registration.
- Confirm staging `baseUrl`, `VoiceCalls__V2Enabled=true`, driver JWT flow, and a real assigned driver/tripStopId; 503 is an environment blocker.
- Confirm driver FCM registration returns the owned `fcmDeviceTokenId` GUID with HTTP 200; raw Firebase tokens and random GUIDs are invalid.
- Confirm APNs VoIP registration for the driver app if iOS is supported, including the exact DriverBundleId VoIP topic/environment; private APNs credentials stay server-side.
- Confirm SignalR hub path, access-token callback, event names, argument order, envelope casing, and exact status/reason codes before implementing serializers/reducers.
- Confirm `ice-servers` returns temporary STUN/TURN URLs and credentials with expiry; never put Coturn SharedSecret in the app. Consume the returned URLs dynamically.
- Confirm staging Coturn TLS setting does not advertise unusable `turns:` URLs; prove relay with getStats/selected candidate on two networks.
- Confirm server-authoritative ring deadline, 20-second qualifying-ring policy, setup lease, heartbeat cadence, 120-second retry cooldown, 3-km contact radius, and terminal cleanup behavior.
- Confirm real assigned driver/customer test accounts and physical-device acceptance; REST/Postman cannot prove Push, native UI, or audio.

## Backend handoff addendum (mandatory details)
- Initiation is allowed only for the assigned driver, an InProgress trip, and a PickedUp stop. Query eligibility before rendering/enabling the call button; do not infer permission from an order screen.
- A qualifying missed attempt requires actual customer ringing acknowledgment and the configured ringing policy (default 20 seconds). Reject, cancel, technical failure, missing/expired receipt, or insufficient ringing do not count. Keep the stop PickedUp during Hold; other stops may continue.
- Hold body is real driver notes plus the qualifying `firstAttemptCallId`; it is not a new id. Resume is explicit and requires server cooldown (default 120 seconds) plus fresh driver-owned location inside contact radius (default 3 km). Time passing alone is insufficient.
- A second qualifying miss must happen after resume. Only then may `canRevealPhone` become true. Reveal request uses an independent clientRequestId, real reason, and `acknowledgedPrivacyWarning:true`; response is Cache-Control no-store and short-lived. Open the system dialer; there is no server telephone call endpoint.
- Android push is data-only high priority with `data.type` and JSON-string `data.envelope`; iOS incoming uses direct APNs VoIP HTTP/2, priority 10, `apns-push-type: voip`, exact app `.voip` topic. Terminal/answered cleanup is background FCM/APNs with at most 60-second retention. Provider acceptance is not ringing acknowledgment.
- Lifecycle envelope is `eventId, protocolVersion, callId, sequence, eventType, occurredAtUtc, sentAtUtc, expiresAtUtc?, payload`; apply envelope dedupe and payload snapshot sequence separately. Incoming whose terminal payload/deadline is expired must never show UI.
- SignalR methods must be exactly `BindDeviceSession`, `SendOffer(callId,{type:"offer",sdp},messageId,generation)`, `SendAnswer`, and `SendIceCandidate(callId,{candidate,sdpMid?,sdpMLineIndex?,usernameFragment?},messageId,generation)`. Bind before Send; messageId UUID; generation >=0; non-empty candidate; SDP <=65,536 bytes and ICE <=4,096 bytes. Only owned, unrevoked, unexpired winning sessions may signal.
- Driver creates Offer only after customer answer. Queue ICE before remote description, ignore stale generations, and never send empty end-of-candidates. Heartbeat does not extend setup deadline; each peer has independent liveness. Use getStats/selected relay candidate to prove TURN/media.
- Device registration consumes the real FCM registry GUID returned by the token endpoint; raw Firebase token or random GUID is invalid. Re-registering an installation rotates and invalidates the old session/proof; proof is one-time and must be stored securely.
- On reconnect rebind, call active/snapshot/events reconciliation, dedupe committed event IDs, and stop native UI/media on terminal state. Do not blindly retry non-idempotent cancel/end/hold/resume/reveal after 409.
- Handle ProblemDetails without assuming a code: 400 validation, 401 refresh, 403 permission/session, 404 unavailable, 409 state conflict, 422 domain, 429 wait metadata, 503 disabled. Never log tokens, proofs, phone, SDP, ICE, TURN, or provider payloads.
- Release gate requires Android/iOS foreground/background/terminated, two customer devices, answer/reject/cancel/end, session/token rotation, network loss/reconnect, two-way audio, forced TURN across separate networks, mute/speaker/Bluetooth, Arabic/English RTL/LTR/accessibility, and proof that technical failures do not unlock phone reveal.
