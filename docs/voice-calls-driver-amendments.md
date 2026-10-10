# تعديلات Voice Calls v2 — تطبيق السواق فقط

طبّق هذه التعديلات على التنفيذ الحالي داخل ريبو السواق. لا تعِد تنفيذ الخطة القديمة. راجع الموجود وتجاوز البنود الصحيحة. حافظ على rules وlib/features/calling وApiServices وDI/Auth الحالية وsignalr_netcore الموجود.

## 1. بيانات العرض الجديدة

GET /api/v2/voice-calls/{callId}/display باستخدام JWT وAccept-Language: ar أو en؛ لا يحتاج voice-device headers.

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

- أضف DTO دفاعيًا وMapper/Entity وApiServices/DataSource/Repository/UseCase وViewModel fields/intents عند حاجة UI لهذه البيانات، بدون تكرار طبقات موجودة.
- هذا الرد يحتوي بيانات السواق نفسه والطلب، وليس اسم العميل أو صورته. لا تعرض driverName/driverImageUrl باعتبارهما العميل الذي تتصل به؛ حافظ على مصدر العميل الحالي المصرح به أو fallback مترجم.
- استخدم العنوان وorderCode/mealSummary/slotLabel/boxCount عند الحاجة، وحمّل display بعد initiate ومعرفة callId دون تأخير signaling/media.
- driverRole مترجم من الباك، stopStatus technical code، image URL نسبي يُحل بالـbase URL الحالي. غياب اسم/صورة ليس فشلًا.
- أعد التحميل عند تغيير اللغة وتجاهل responses لمكالمة/حساب/لغة قديمة. فشل display لا يلغي مكالمة قائمة.
- لا تستخدم live-tracking كبديل؛ ownership check غير مكتمل. لا رقم هاتف في display؛ reveal-phone يظل المسار الوحيد في العقد لكشفه بعد الشروط.

## 2. تحديث تسجيل FCM للسواق

POST /api/v1/driver/device-token أصبح يرجع 200:

```json
{"fcmDeviceTokenId":"<guid>"}
```

- حافظ على request الحالي؛ غيّر void/204-only إلى nullable DTO ثم mapper واستخدم registry ID الحقيقي في voice devices/register.
- إعادة نفس FCM token تعيد نفس ID؛ لا GUID عشوائي ولا raw token بدل ID.
- افصل القيم حسب الحساب، ونظّفها عند logout. iOS يحتاج FCM ID وapnsVoipToken معًا في register.
- لا تكرر voice register عند كل reconnect؛ نفس installation rotation يلغي الجلسة القديمة.

## 3. قيم الربط

- Base URL https://maelmate.runasp.net من configuration الحالية؛ Firebase project المتوقع mealmate-bd5b3.
- لا تضع Firebase service account أو APNs p8 أو Coturn SharedSecret في الريبو أو التطبيق.
- Hub /hubs/voice-call-v2؛ JWT access_token عبر SDK وproof داخل BindDeviceSession فقط.
- RTC envelope: messageId, callId, negotiationGeneration, senderDeviceSessionId, sentAtUtc, payload. Hub limit 400KB؛ SDP 65536/ICE 4096 UTF-8 bytes.
- استهلك ICE URLs/credentials/expiry كما تأتي؛ TTL default 3600 seconds ليس قيمة hardcoded. لا تعتمد على turns إذا إعداد TLS الفعلي غير جاهز؛ وثّق فشل البيئة واختبر relay باستخدام selected candidate pair.
- تعارض capabilityVersion ما زال موجودًا: العقد 2 والمثال 1؛ لا downgrade تلقائيًا عند 403.
- initiate يرسل tripStopId/clientRequestId فقط؛ لا أسماء أو صور أو أرقام أو user identity في body.

## 4. إصلاح التعافي

- 401: JWT refresh الموجود أولًا؛ 403: صنّف السبب وقارن snapshot/session قبل أي تسجيل جديد.
- لا تسجل الجهاز مجددًا أثناء مكالمة قائمة لإعادة control/ICE؛ قد تفقد ownership بسبب rotation.
- لا تعِد initiate بـrequestId جديد بعد timeout غامض؛ احتفظ بمعرف نفس العملية واقرأ active أولًا.
- لا تفترض أن renewal يعمل دائمًا بالخلفية أو أن push سيصل لجلسة انتهت؛ launch/resume وفحص الصلاحية قبل initiate هما نقاط التنفيذ المتاحة.
- لا تغير قواعد Hold/Resume/reveal أو تعدّ reject/cancel/failure كمحاولة مؤهلة بسبب هذه التعديلات.

## 5. مراجعة بعد التنفيذ

- اختبر FCM 200/ID، display nullable/relative URL/language/stale response، وعدم عرض اسم السواق باعتباره العميل.
- اختبر 401 refresh و403 بدون blind session rotation وinitiate retry بنفس requestId وaccount/logout cleanup.
- شغّل build_runner حيث يلزم ثم format/analyze/الاختبارات ذات الصلة.
- تحقق من no-store للرقم وعدم تسريب الأسرار/العنوان/الهاتف، وعدم نسخ عميل SignalR أو networking جديد.
- قدّم تقرير الملفات المعدلة والنتائج والـblockers والاختبارات التي تحتاج أجهزة حقيقية، بدون ادعاء إثبات الصوت من REST/tests.
