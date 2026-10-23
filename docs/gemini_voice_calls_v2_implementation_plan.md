# Voice Calls v2 — Implementation Plan for Gemini

> انسخ هذا الملف كاملًا إلى Gemini داخل مشروع `meal_mate_delivery`. نفّذ المهام بالترتيب، ولا تغيّر عقد الباك أو تعيد بناء المعمارية الحالية.

## الهدف

إكمال دعم Voice Calls v2 في تطبيق المندوب بحيث:

1. يتم تفاوض WebRTC بالـ `callId` و`generation` الصحيحين.
2. يتم فك رسائل SignalR v2 ذات الـ envelope nested.
3. تستمر المكالمة الطويلة عبر Heartbeat كل 10 ثوانٍ.
4. لا تنتهي المكالمة بسبب timeout قديم بعد قبولها.
5. يمكن إعادة محاولة تقارير connecting/connected، مع منع عروض WebRTC المتوازية.
6. يبدأ عداد المكالمة بناءً على `Active` و`connectedAtUtc` من snapshot الرسمي فقط.

## قيود ثابتة

- عدّل مشروع Flutter فقط؛ لا تعدّل الباك أو تطبيق العميل الآخر أو إعدادات الاستضافة.
- حافظ على Flutter/WebRTC/SignalR/CallKit والمعمارية الحالية.
- لا تغيّر أسماء أحداث SignalR أو حالات المكالمة.
- الإرسال إلى الباك يبقى 4 arguments:

```dart
[callId, payload, messageId, generation]
```

- استقبال v2 يأتي كعنصر واحد داخل `arguments`:

```json
{
  "messageId": "uuid",
  "callId": "uuid",
  "negotiationGeneration": 0,
  "senderDeviceSessionId": "uuid",
  "sentAtUtc": "2026-10-10T07:30:00Z",
  "payload": { "type": "answer", "sdp": "..." }
}
```

- لا تطبع JWT أو `controlProof` أو TURN credentials أو SDP كاملًا في logs.
- استخدم UUID v4 حقيقيًا للـ `messageId`.
- أي رسائل UI جديدة يجب أن تضاف إلى موارد العربية والإنجليزية، ولا تضف نصوصًا ثابتة داخل widgets.

---

## خريطة الملفات

### ملفات التعديل

- `lib/features/driver/calling/data/webrtc/driver_webrtc_manager.dart`
- `lib/features/driver/calling/data/realtime/driver_voice_call_signalr_client.dart`
- `lib/features/driver/calling/data/models/realtime/voice_call_rtc_payload_dto.dart`
- `lib/features/driver/calling/data/repo/driver_calling_repository_impl.dart`
- `lib/features/driver/calling/data/callkit/driver_callkit_coordinator.dart`

### ملفات الاختبار

- `test/features/driver/calling/data/realtime/driver_voice_call_signalr_client_test.dart`
- أنشئ اختبارات مناسبة لـ WebRTC/Repository إذا كان الحقن الحالي يسمح بذلك؛ إن لم يسمح، أضف أصغر abstraction قابلة للحقن بدل استخدام platform WebRTC مباشرة في الاختبار.

---

## Task 1 — إصلاح lifecycle الخاص بـ WebRTC

### المشكلة الحالية

`startOfferSession` يضع `_currentCallId` قبل `cleanup()`, بينما `cleanup()` يمسح `_currentCallId`. لذلك قد يتم رفض answer أو ICE الصحيح باعتباره تابعًا لمكالمة أخرى.

### التنفيذ

في `startOfferSession` اجعل الترتيب قبل إنشاء `PeerConnection` حرفيًا:

```dart
await cleanup();
_currentCallId = callId;
_currentGeneration = generation;
_hasRemoteDescription = false;
_queuedRemoteCandidates.clear();
initializeSubscriptions();
```

- لا تحذف فحص `callId` أو `generation` من `_handleRemoteAnswer` و`_handleRemoteCandidate`.
- ارفض generation الأقدم من الجيل الحالي.
- لا تطبق رسالة من generation مختلف على `PeerConnection` الحالي.
- تأكد أن callbacks القديمة لا تستخدم `callId` الجديد بعد cleanup؛ التقط callId/generation محليًا أو افحصهما قبل الإرسال.
- اجعل `cleanup()` يلغي subscriptions ويغلق الموارد، لكن لا تستدعِه بعد تعيين هوية الجلسة الجديدة.

### الاختبارات

- جلسة قديمة ثم جلسة جديدة: بعد cleanup يبقى `currentCallId` للجلسة الجديدة.
- answer بمكالمة أخرى يُرفض.
- answer بنفس `callId` وgeneration الحالي يُقبل.
- candidate قديم يُرفض، وcandidate صحيح يُقبل أو يُخزن حتى وصول remote description.

---

## Task 2 — فك SignalR v2 envelope

### المشكلة الحالية

الكود الحالي يدعم positional 4 arguments، لكنه عند استقبال عنصر واحد يقرأ `sdp/type/candidate` من مستوى envelope بدل `envelope.payload`.

### التنفيذ

أضف helper داخلي مشترك، مثل:

```dart
({String callId, String messageId, int generation, Map<String, dynamic> payload})?
    _decodeRtcEnvelope(List<Object?>? args)
```

قواعد helper:

1. إذا كان `args` فارغًا، أرجع `null`.
2. إذا كان `args.length == 1`:
   - حوّل العنصر إلى Map، مع دعم Map وJSON string.
   - اقرأ `callId`, `messageId`, `negotiationGeneration` من المستوى الأعلى.
   - اقرأ `payload` من المستوى الأعلى، وتأكد أنه Map.
3. يمكن إبقاء دعم positional القديم عندما تكون `args.length >= 4` للتوافق، لكنه لا يغني عن v2.
4. إذا كان `callId` أو `messageId` ناقصًا، أو `payload` غير موجود، سجّل تشخيصًا مختصرًا ولا تصدر DTO.

في `_handleRtcOffer` و`_handleRtcAnswer`:

- اقرأ `type` و`sdp` من `decoded.payload`.
- مرر `generation` من `negotiationGeneration` إلى DTO.
- ارفض payload بلا SDP صالح.

في `_handleRtcIce`:

- اقرأ `candidate`, `sdpMid`, `sdpMLineIndex`, `usernameFragment` من `decoded.payload`.
- مرر callId/messageId/generation من envelope.
- ارفض candidate الفارغ أو envelope الناقص.

لا تغيّر دوال الإرسال `sendOffer`, `sendAnswer`, `sendIceCandidate`.

### الاختبارات

أضف اختبارات تستخدم:

```dart
arguments = [
  {
    'messageId': 'msg-1',
    'callId': 'call-1',
    'negotiationGeneration': 3,
    'payload': {'type': 'answer', 'sdp': 'v=0\\r\\n'},
  }
];
```

غطِّ:

- answer envelope كـ Map.
- offer envelope كـ JSON string إن كان مدعومًا.
- ICE envelope بكل حقوله.
- envelope ناقص callId أو messageId أو payload: لا DTO ولا crash.
- positional legacy ما زال يعمل.
- الإرسال ما زال 4 arguments وبـ UUID messageId.

---

## Task 3 — Heartbeat مملوك لدورة المكالمة

### التنفيذ في Repository

في `DriverCallingRepositoryImpl` أضف:

- `Timer? _heartbeatTimer;`
- `String? _heartbeatCallId;`
- `bool _heartbeatRequestInFlight = false;`

أضف methods داخلية واضحة:

```dart
void _startHeartbeatForSnapshot(VoiceCallSnapshotEntity snapshot)
void _stopHeartbeat()
Future<void> _heartbeatTick(String callId)
```

القواعد:

- شغّل heartbeat فقط للحالات `accepted`, `connecting`, `active`.
- الفترة `Duration(seconds: 10)`.
- Timer واحد فقط؛ snapshot مكرر لا ينشئ Timer جديدًا.
- كل tick يتحقق أن `callId == _activeCallId` وأن snapshot ما زال غير terminal.
- إذا كان طلب heartbeat قائمًا، تخطَّ tick الحالي حتى لا تتداخل الطلبات.
- فشل الشبكة يسجل diagnostic ويترك Timer يعمل للمحاولة التالية.
- لا تعلن `Active` أو نجاحًا وهميًا بسبب heartbeat.
- أوقف Timer عند أي terminal state، `cleanupCall`, cancel/end الناجح، revoke/dispose/logout بحسب مسار الخدمة الحالي.
- بعد reconnect والمصالحة، أعد تشغيل Timer من snapshot الرسمي فقط.
- لا تمسح أو تبدل الجهاز تلقائيًا بسبب 403/409 أثناء مكالمة قائمة؛ اجلب snapshot الرسمي واتبع حالته.

### الاختبارات

استخدم fake clock أو Timer abstraction قابلة للحقن للتحقق من:

- tick كل 10 ثوانٍ.
- عدم تداخل طلبين.
- snapshot مكرر لا ينشئ Timer ثانيًا.
- cleanup يوقف التكرار.
- callback قديم لا يرسل heartbeat لمكالمة جديدة.

---

## Task 4 — مواءمة CallKit مع deadline والحالات الرسمية

### التعديلات

عدّل `DriverCallKitCoordinator.startOutgoingCall` ليستقبل مدة مشتقة من deadline، مثل:

```dart
required Duration ringTimeout
```

ولا تستخدم `duration: 30000` ثابتة.

في `initiateCall`:

1. احسب `ringTimeout` من `snapshot.deadlineAtUtc` مع مراعاة فرق ساعة الجهاز والسيرفر إن كان هناك time sync موجود.
2. لا تمرر مدة سالبة؛ إن كان deadline منتهيًا تعامل معه كـ timeout رسمي.
3. احتفظ بمعرّف المكالمة المرتبط بالـ timeout.

في التعامل مع `CallEventActionCallTimeout`:

- ميّزه عن الإغلاق اليدوي.
- اجلب snapshot أولًا.
- إذا أصبحت الحالة `accepted`, `connecting`, أو `active` فلا ترسل `end` بسبب timeout الرنين القديم.
- إذا بقيت `created` أو `ringing`، نفّذ cancel/end حسب العقد الحالي.

في `DriverCallKitCoordinator`:

- اربط suppression بـ `callId` بدل boolean عام إن كان ذلك يمنع مكالمة جديدة من استقبال event قديم.
- لا تستدعِ `setCallConnected` إلا بعد تحقق الاتصال الفعلي والحالة الرسمية المناسبة.
- ألغِ أي مؤقت تطبيق بعد القبول.
- أبقِ الإغلاق البرمجي idempotent ولا تكرر طلب end.

### الاختبارات

- deadline بعيد: لا timeout مبكر.
- deadline منتهٍ: يعالج كـ timeout حقيقي.
- timeout يصل بعد Accepted: لا يرسل end.
- إغلاق المستخدم أثناء Active: يرسل end مرة واحدة.
- إغلاق برمجي: لا يعيد event إضافي طلب end.

---

## Task 5 — Retry لتقارير الاتصال ومنع عروض WebRTC المكررة

### تقارير connecting/connected

استبدل sets الحالية التي تسجل المفتاح قبل نجاح الطلب بفصل واضح بين:

- `_connectingInFlight`
- `_reportedConnecting`
- `_connectedInFlight`
- `_reportedConnected`

القواعد:

- إذا كان المفتاح في successfully reported، لا تعِد الطلب.
- إذا كان in-flight، لا تبدأ طلبًا موازيًا.
- أضف المفتاح إلى successfully reported بعد `ApiSuccessResult` فقط.
- أزل المفتاح من in-flight في `finally` دائمًا.
- في فشل الشبكة، نفّذ retry محدودًا ومربوطًا بـ `callId:generation`، أو أعد المحاولة عند snapshot/reconnect؛ لا تعتبر التقرير ناجحًا.
- ألغِ retries عند terminal/cleanup.

### حارس WebRTC

أضف حارسًا مثل:

```dart
String? _webRtcOfferInFlightKey;
final Set<String> _startedWebRtcOfferKeys = {};
```

في `_triggerWebRtcOffer`:

- كوّن المفتاح `'$callId:$_currentGeneration'`.
- إذا كان in-flight أو بدأ بالفعل، تجاهل Accepted snapshot المكرر وreconnect.
- لا تنظف جلسة سليمة بسبب snapshot مكرر.
- حرر الحارس في failure قبل اكتمال الجلسة، وامسحه في terminal/cleanup.
- لا تجعل ICE connected وحده يساوي Active.
- يبدأ عداد الواجهة فقط عند snapshot رسمي `Active` مع `connectedAtUtc`.

### الاختبارات

- فشل connecting أول مرة ثم نجاح المحاولة التالية.
- snapshot Accepted مكرر لا يبدأ Offer ثانيًا.
- reconnect لا يبدأ PeerConnection موازيًا.
- ICE وPeerConnection callbacks لا يرسلان connected مرتين.
- cleanup يسمح بمكالمة جديدة نظيفة.

---

## Task 6 — تحديث الاختبارات والتحقق النهائي

شغّل بالترتيب:

```powershell
flutter analyze
flutter test test/features/driver/calling/data/realtime/driver_voice_call_signalr_client_test.dart
flutter test test/features/driver/calling
```

أصلح أي فشل قبل الانتقال.

### تحقق يدوي بجهازين

نفّذ تجربة بجهازين حقيقيين، مع نسخة العميل التي تدعم استقبال نفس envelope:

1. بدء مكالمة وقبولها.
2. التأكد من وصول صوت الطرفين.
3. اختبار الميكروفون والسماعة وmute/speaker.
4. التأكد أن العداد يبدأ بعد `Active` فقط.
5. إبقاء المكالمة أكثر من 90 ثانية للتأكد من Heartbeat الطرفين.
6. إغلاق المندوب.
7. إغلاق العميل.
8. عدم الرد حتى deadline.
9. التأكد من تطابق الحالة الرسمية للطرفين.
10. اختبار العربية والإنجليزية وتبديل اللغة أثناء الخطأ إن تغيرت رسائل UI.

## معايير القبول النهائية

- لا يتم رفض answer/ICE صحيح بسبب cleanup أو callId/generation خاطئ.
- envelope v2 يعمل في offer/answer/ICE، مع بقاء إرسال 4 arguments.
- Heartbeat واحد فقط كل 10 ثوانٍ للحالات المسموح بها، ويتوقف في النهاية.
- timeout قديم لا ينهي مكالمة Accepted/Active.
- تقارير الاتصال قابلة لإعادة المحاولة ولا تتكرر بالتوازي.
- Accepted/reconnect لا ينشئ Offers متوازية.
- العداد يعتمد على Active و`connectedAtUtc` من الباك.
- `flutter analyze` واختبارات calling تمر بنجاح.
- تم توثيق أي اختبار جهاز لم يمكن تنفيذه بسبب غياب أجهزة أو Flutter SDK.

## التقرير المطلوب بعد التنفيذ

أرسل تقريرًا يتضمن:

1. الملفات التي عُدّلت.
2. كل مشكلة تم إصلاحها وربطها بالـ Task أعلاه.
3. أوامر الاختبار ونتائجها الفعلية.
4. اختبارات الأجهزة التي نُفذت فعلًا فقط.
5. أي فجوة متبقية أو اعتماد على تطبيق العميل الآخر.

