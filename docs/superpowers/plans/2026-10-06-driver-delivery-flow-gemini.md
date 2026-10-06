# Driver Delivery Flow — Gemini Implementation Plan

> **For agentic workers:** استخدم `superpowers:executing-plans` إن كانت متاحة، ونفّذ المهام بالترتيب مع تحديث مربعات الإنجاز. هذه خطة تنفيذ لجيمناي؛ لا تنفّذ تغييرات في الباك ولا تنشر التطبيق ضمنها.

**Goal:** ربط فلو السائق الحقيقي من بدء مسار التوصيل إلى الوصول وتصوير إثبات التسليم واعتماد تسليم العميل، ثم عرض النجاح وتحديد الخطوة التالية.

**Architecture:** الحفاظ على Feature-Based Clean Architecture الحالية. قراءة المحطات والملاحة عبر مكونات `driver/map` الموجودة، وكتابة أوامر الوصول ورفع الإثبات والتسليم عبر repository/usecases داخل `driver/active_delivery`. الشاشات تستخدم `doIntent(Event)` وتقرأ State واحدة immutable؛ لا تتصل بالشبكة أو repository مباشرة.

**Tech Stack:** Flutter، flutter_bloc، Injectable/GetIt، Dio/Retrofit، json_serializable/build_runner، image_picker، Google Maps الموجود بالمشروع، ونظام Shimmer وCore errors الموجودين.

**Spec:** تعليمات المستخدم المعتمدة في المحادثة بتاريخ 2026-10-06، ملفات الشاشات المذكورة أدناه، دليل الخريطة المرفق، وملخص `driver-screens-07-contract-implementation` المرسل من الباك. عند اختلاف أمثلة الشاشات القديمة مع العقد الحديث، العقد الحديث هو مصدر بيانات الـAPI.

## 1. اقرأ هذا أولاً — النطاق والقرارات الثابتة

- الشاشات الأساسية: **07.00 / 07.00B / 07.01 / 07.02**.
- 07.00: جاهز لبدء مسار التوصيل؛ الكود الحالي `DriverStartDeliveryRouteScreen`.
- 07.01: متابعة التوصيل أثناء الطريق؛ الكود الحالي `DriverActiveDeliveryTrackingScreen`.
- 07.02: تم الوصول وتأكيد التسليم؛ لا توجد شاشة مستقلة لها في ملفات الميزة التي تمت مراجعتها، ولذلك تُضاف.
- 07.00B: ذُكرت في ملخص الباك، ولم يوجد ملف مواصفات مستقل لها داخل مجلد الشاشات المتاح. لا تخترع لها تصميمًا أو تعتبرها مرادفًا مؤكدًا لشاشة أخرى. راجع مرجعها الفعلي لدى بدء التنفيذ. إلى أن يتوفر، يمكن إنجاز المكونات المشتركة، لكن لا تدّع اكتمال تغطيتها البصرية المستقلة.
- 03.01: مراجعة نقطة الدخول وحقول المحطة المشتركة فقط؛ لا إعادة تصميم لخريطة السائق.
- 07.06: تعديل ربط شاشة النجاح الموجودة فقط؛ هي جزء ضروري من نهاية فلو التسليم.
- **OTP يدخله السائق بعد أن يعطيه العميل الكود، وهو اختياري بالكامل.** لا يطلب التطبيق من العميل إدخاله على جهاز السائق.
- الصورة إجبارية. OTP الفارغ أو الجزئي لا يعطل التسليم؛ لا تعلن أن الكود تحقّق منه السيرفر.
- لا تنفيذ لتأخير التوصيل، `isDelayed`، التحويل التلقائي لـ07.03، أو سياسة/زر إعادة إرسال OTP.
- لا إضافة نوع بوكس افتراضي «عادي»؛ لا مصدر له في العقد الحالي.
- لا تعديل فلو فشل التسليم وإرجاع البوكس إلا لضمان عدم كسر التوافق الحالي.
- لا تغيير ألوان أو typography أو spacing أو localization أو bottom navigation بدون حاجة ربط فعلية.
- استخدم `rules/rules_backend.md` و`lib/core/errors` حرفيًا في قرارات المعمارية وعرض الأخطاء.
- استخدم Shimmer الموجود، ولا تضف package لمجرد تنفيذ التحميل.
- لا بيانات وهمية في المسار الإنتاجي، ولا success محلي قبل نجاح الباك.

## 2. الأدلة الحالية التي بُنيت عليها الخطة

### مراجع محلية

1. `D:/yahya/meal meat/driver/screen-07.00-start-delivery.md`.
2. `D:/yahya/meal meat/driver/screen-07.01-delivery-in-transit.md`.
3. `D:/yahya/meal meat/driver/screen-07.02-delivery-arrival-confirmation.md`.
4. `rules/rules_backend.md`.
5. دليل الخريطة: `C:/Users/orignal store/.codex/attachments/65e791e3-5663-44c3-a4ee-391cf784182e/Pasted text.txt`.
6. سياق الباك: `C:/Users/orignal store/.codex/attachments/d32e4ce7-d141-47da-9a25-d6b3ea2fc8bb/Pasted text.txt`؛ الرسائل غير المتعلقة بفلو السائق ليست متطلبات لهذه المهمة.

لا تعتمد على استمرار وجود attachment خارج المشروع أثناء التنفيذ: المعلومات اللازمة المؤكدة مُلخّصة هنا، والعقود غير المتاحة مذكورة بوضوح في مهمة التحقق.

### مشكلات مؤكدة في الكود

| الموضع | الوضع الحالي | التعديل المطلوب |
|---|---|---|
| `driver_start_delivery_route_screen.dart` | defaultTrip وهمية، والانتقال لا يمرر سياق التوصيلة | بيانات حقيقية وتمرير معرف المحطة/الرحلة |
| `driver_active_delivery_tracking_screen.dart` | fake repository؛ تأكيد الوصول يستدعي completeDelivery ثم ينتقل للنجاح دون انتظار | arrive-customer ثم 07.02 بعد نجاح الرد فقط |
| نفس الشاشة | `setActiveBoxesCount(1)` ثابت | إزالة العدد الثابت ومصالحة العدد الفعلي عبر الرحلات |
| `active_delivery_view_model.dart` | repository مباشرة وtry/catch وerrorMessage نصي | UseCases + ApiResult + Failure + doIntent |
| `active_delivery_state.dart` | trip إجبارية يملؤها fake default | حالة ابتدائية بدون بيانات مع loading/error/empty صريحين |
| `ActiveDeliveryRepository` القديم | أوامر بمعرف tripId ونتائج void | أوامر المحطة بمعرف boxId/stopId ونتائج typed |
| `DriverMapStopResponseDto/Entity` | لا boxId/tripId/customerNote/arrivedAtUtc | إضافة الحقول وتمريرها في mapper/copyWith |
| `driver_delivery_success_screen.dart` | fallback وهمي والعودة دائمًا لقائمة الصناديق | نتيجة تسليم حقيقية وقرار التالي من refresh حقيقي |
| `driver_tracking_summary_card.dart` | وقت افتراضي ثابت | وقت حقيقي أو إخفاء الحقل عند غيابه |
| `DriverLiveLocationCoordinator` | أحداث التسليم قد تقلل العدد بأكثر من مسار | لا تكرار للخصم؛ reconciliation من مصدر مجموع حقيقي |

كانت هناك تعديلات غير committed وقت المراجعة في:

```text
lib/core/app_shell/screens/app_shell_screen.dart
lib/features/driver/active_delivery/presentation/screens/driver_active_delivery_tracking_screen.dart
lib/features/driver/active_delivery/presentation/widgets/driver_tracking_map_view.dart
```

حافظ عليها واقرأ diff قبل تعديل هذه الملفات. لا تستخدم reset/checkout لاستبدال شغل المستخدم.

## 3. اختيار طريقة التنفيذ

الطريقة المعتمدة: **إعادة استخدام قراءة الخريطة الحالية مع إضافة أوامر التسليم داخل active_delivery**. هذا يحافظ على العقد الجديد للملاحة ويمنع تكرار DTOs وخدمة اتجاهات وGPS.

بدائل غير مختارة: نقل الفلو كله إلى feature جديدة يضاعف الملفات والتغييرات؛ وتوسيع fake repository القديمة لتخدم كل شيء يخلط الفشل/الإرجاع المؤجلين مع الربط الحقيقي. احتفظ بالـrepository القديمة فقط للمسارات خارج النطاق أو الاختبارات التي لا تزال تستخدمها، وأضف عقدًا مستقلًا واضحًا للكتابة الحقيقية دون كسرها.

## 4. عقد الباك — المؤكد وما يحتاج تحققًا

### 4.1 تحميل المحطة والملاحة

```http
GET /api/v1/driver/map/route
GET /api/v1/driver/map/route?focusedStopId=<stopId>
Authorization: Bearer <driver-token>
Accept-Language: ar أو en حسب اللغة الحالية
```

- لا ترسل driverId أو إحداثيات الجهاز في هذا GET.
- `stopId` هو معرف المحطة، و`boxId` alias لنفس القيمة، وليس DailyOrderId أو boxCode.
- `tripId` الموجود داخل المحطة هو رحلة هذه المحطة. القائمة قد تجمع رحلات متعددة.
- `customerNote` من عنوان اليوم، و`arrivedAtUtc` وقت أول وصول محفوظ؛ لا تستبدله بـDateTime.now.
- `customerPhone` في الخريطة فارغ عمدًا. حافظ على سياسة منع كشفه/الاتصال الحالية؛ لا تعتمد على مثال الشاشة القديم لإعادة زر الاتصال أو ربط calling جديد.
- `status`: Delivered / InTransit / Pending. الوصول يُعرف أيضًا من arrivedAtUtc؛ لا تنتظر ظهور status=Arrived في GET.
- الطريق الوحيد: `navigation.encodedPolyline` مع google_polyline5.
- لا ترسم routePolylineWaypoints كطريق، ولا خطًا مستقيمًا بين السائق والعميل كبديل مخفي.
- distanceMeters/durationSeconds مصدر المسافة والمدة؛ القيمة 0 سليمة، وnull ليست 0.
- `deliveryTimeSlot` نص عرض فقط، لا parsing ولا قرار تأخير.
- حالات navigation: Ready / Unavailable / Completed، وقد يكون الكائن null.
- أسباب Unavailable: driver_location_missing / driver_location_stale / driver_location_invalid / destination_location_missing / directions_unavailable.
- `canNavigate` ورابط السيرفر يتحكمان في الملاحة الخارجية؛ افتح الرابط كما هو دون بناء Directions URL جديد.
- 404 DriverTrip.NotFound → EmptyState.
- 404 DriverMap.StopNotFound → إعادة واحدة بدون focusedStopId، ثم تحديث الاختيار الحقيقي، دون loop.

### 4.2 الوصول

```http
POST /api/v1/driver/orders/{boxId}/arrive-customer
```

ملف 07.01 يعرض body بإحداثيات latitude/longitude. ملخص الباك يؤكد كتابة ArrivedAtUtc مرة واحدة وعودة isFirstArrival=false في التكرار؛ **تحقق من schema الفعلي قبل تثبيت DTO**، خصوصًا اختيارية الإحداثيات وأسماء بقية حقول الرد.

لا تغير العملية إلى deliver. لا تنتقل إلى 07.02 إلا بعد استجابة وصول ناجحة أو قراءة arriveAtUtc محفوظة تؤكد أن الوصول سبق تسجيله لنفس المحطة.

### 4.3 رفع الإثبات

المؤكد: `UploadFileCommandHandler` يسجل UploadFileRecord مع UploadedByUserId، والتسليم يقبل مفتاحًا لسجل يخص السائق الحالي وملف موجود من JPEG/PNG/WebP.

**غير متاح في الملخص:** HTTP path للرفع، اسم multipart part، كيفية تحديد مجلد `uploads/drivers/delivery/`، حد الحجم، وشكل Upload response. لا تخترعها، ولا تستخدم endpoint تسجيل السائق أو تصوير حالة البوكس أثناء pickup كبديل دون عقد يؤكد صلاحيته لتسليم العميل.

مهمة 0 تلزم الحصول على هذه القيم من Swagger/OpenAPI أو الدليل الكامل أو كود UploadsController الذي يقدمه فريق الباك. إن تعذر، أنجز بقية الفلو بـtest doubles، وسجّل أن تشغيل upload الحقيقي غير قابل للتحقق؛ لا تكتب مسارًا تخمينيًا ولا تدّع أن الفلو يعمل end-to-end.

### 4.4 التسليم

```http
POST /api/v1/driver/orders/{boxId}/deliver
Content-Type: application/json

{
  "proofPhotoStorageKey": "<storageKey returned by successful upload>",
  "latitude": 29.3801,
  "longitude": 47.9852
}
```

- المثال للشرح فقط؛ لا تستخدم هذه الإحداثيات أو key في التطبيق.
- proofPhotoStorageKey إجباري. لا ترسل local path أو url أو base64 مكانه.
- الإحداثيات: زوج أو كلاهما غائب؛ finite، latitude بين -90 و90، longitude بين -180 و180. لا تملأ missing GPS بصفر.
- الحقول المذكورة في وثيقة الشاشة القديمة: deliveryOtp/barcodeValue/handoverNotes اختيارية. لا تضف UI إضافية أو مسح barcode؛ لا ترسل حقلًا قبل تأكيد قبوله بالعقد الفعلي.
- حقول الرد المضافة حسب ملخص الباك: tripId، isTripCompleted، remainingStopsCount، driverId، isFirstDelivery، مع deliveredAtUtc الأصلي.
- remainingStopsCount خاص برحلة المحطة، والفاشل مستبعد. لا تستخدمه كعدد عالمي عبر كل الرحلات.
- التكرار يرجع وقت التسليم الأصلي والحالة الحالية دون تكرار counters/scan/push.
- نجاح isFirstDelivery=false نجاح حقيقي؛ لا تعرضه كخطأ.
- لا تفرض header idempotency جديدًا على arrive/deliver لمجرد أن trip-start يستخدم مفتاحًا؛ أضفه فقط إذا أثبته العقد.

### 4.5 OTP: التنفيذ المقبول الآن

حقل اختياري من 4 أرقام وفق مواصفات 07.02، يكتبه السائق. اقبل الأرقام العربية والإنجليزية وحوّلها لتمثيل موحد في State. لا autofocus مزعج، ولا request resend، ولا عداد صلاحية.

الباك المذكور **لا يقرأ deliveryOtp ولا يتحقق منه**. لذلك:

1. الحقل يظهر استجابة لطلب المستخدم، لكنه لا يصدر badge «تم التحقق» أو رسالة نجاح OTP.
2. أظهر نصًا واضحًا مناسبًا: «اختياري — التحقق من الرمز غير متاح حاليًا» مع نص السماح بالتسليم بالصورة.
3. في العقد الحالي احتفظ بالمدخل في الذاكرة فقط ولا تخزّنه دائمًا؛ لا تدّع أنه دليل محفوظ.
4. إن أكد schema قبول deliveryOtp، يمكن إرسال الكود الكامل فقط كحقل اختياري، مع استمرار عدم ادعاء التحقق. غير الكامل يُحذف من الطلب ولا يعطل التسليم.
5. إن لم يؤكد schema قبوله، لا ترسله. لا تختلق endpoint للتحقق.
6. أي تحقق OTP حقيقي مهمة باك منفصلة وخارج هذه الخطة.

### 4.6 أخطاء التسليم الموثقة

| code | السلوك |
|---|---|
| Orders.ProofPhotoRequired | إبقاء النموذج وطلب الصورة؛ لا deliver قبل upload ناجح |
| Orders.ProofPhotoNotFound | key غير صالح/الملف مفقود؛ إبطال key لهذه الصورة وإتاحة إعادة الرفع |
| Orders.ProofPhotoForbidden | لا إعادة تلقائية بنفس key؛ إبطال الربط، طلب صورة ورفع بحساب السائق الحالي |
| Orders.ProofPhotoInvalidType | رفض الإثبات؛ طلب التقاط بصيغة مدعومة |
| Orders.CoordinatesPairRequired | إصلاح الطلب ليحذف الزوج أو يرسله كاملًا؛ إبقاء الصورة |
| Orders.CoordinatesOutOfRange | لا إعادة نفس الزوج غير السليم؛ الحصول على زوج سليم أو حذفه إن يسمح العقد |
| Orders.DeliveryForbidden | تعطيل العملية لهذه المحطة وإعادة فحص الإسناد؛ لا نقل محلي لمسلّم |

اقرأ code من Failure.code / exception.backendErrorCode عبر mapper المركزي؛ لا تقارن نص title/detail. Arrival لسائق غير مسند يرجع 404 بحسب الملخص، فلا تعتبر كل 404 «تم الوصول» أو «لا رحلة».

## 5. فلو الحالات والانتقال

```text
نجاح تأكيد استلام الشحنة + نجاح start-trip الموجود
  -> 07.00: تحميل route الحقيقي واختيار محطة مؤهلة
  -> بدء مسار التوصيل
  -> 07.01: الخريطة الحية للمحطة نفسها
  -> تأكيد الوصول: await arrive-customer(boxId)
  -> 07.02: arrivedAtUtc الحقيقي + بيانات العميل
  -> فتح الكاميرا -> معاينة محلية -> upload -> storageKey
  -> تأكيد التسليم: await deliver(boxId, proofPhotoStorageKey)
  -> 07.06: نتيجة التسليم الفعلية مرة واحدة
  -> refresh للمحطات/الطلبات
       يوجد غير مسلّم -> 07.00 للمحطة التالية حسب اختيار السيرفر
       لا يوجد -> حالة انتهاء التوصيلات/مدخل الملخص الموجود
```

لا تستدع start-trip عند كل محطة. `DriverPickupSummaryViewModel` بالفعل ينفذه قبل الدخول إلى بدء المسار؛ حافظ على ذلك. انتقال 07.00 إلى 07.01 لا يحتاج command جديدًا مخترعًا.

قاعدة إعادة الفتح:

| قراءة السيرفر | القرار |
|---|---|
| محطة Delivered | لا تعرض نموذج submit قابلًا للتكرار؛ refresh ثم التالي أو نتيجة مؤكدة متاحة |
| arrivedAtUtc موجود والمحطة غير مسلمة | افتح 07.02 دون إعادة إرسال وصول تلقائي |
| InTransit بدون arrivedAtUtc | 07.00 أو 07.01 بحسب نقطة الدخول؛ لا تختلق وقت بدء محلي كحقيقة باك |
| Pending/unknown أو إسناد انتهى | لا تسمح بالوصول/التسليم؛ أعد القراءة واعرض الحالة المناسبة |
| 404 DriverTrip.NotFound | EmptyState للتوصيلات النشطة |
| خطأ اتصال | Core error، لا fake fallback |

إعادة فتح التطبيق تحفظ **حقيقة الوصول عبر السيرفر**؛ لا تعِد باستعادة صورة كاميرا محلية بعد process death. عند فقد الصورة المحلية يلتقط السائق صورة جديدة؛ يبقى وقت الوصول محفوظًا.

## 6. خريطة الملفات ومسؤولياتها

### تعديل ملفات موجودة

```text
lib/core/network/network_constants.dart                       أسماء endpoints المؤكدة
lib/core/network/api_services.dart                            Retrofit methods
lib/features/driver/map/data/models/response/driver_map_stop_response_dto.dart
lib/features/driver/map/data/mapper/driver_map_mapper.dart
lib/features/driver/map/domain/entities/driver_map_stop_entity.dart
lib/features/driver/active_delivery/presentation/manager/active_delivery_state.dart
lib/features/driver/active_delivery/presentation/manager/active_delivery_view_model.dart
lib/features/driver/active_delivery/presentation/screens/driver_start_delivery_route_screen.dart
lib/features/driver/active_delivery/presentation/screens/driver_active_delivery_tracking_screen.dart
lib/features/driver/active_delivery/presentation/screens/driver_delivery_success_screen.dart
lib/features/driver/active_delivery/presentation/widgets/start_route_customer_card.dart
lib/features/driver/active_delivery/presentation/widgets/start_route_map_preview.dart
lib/features/driver/active_delivery/presentation/widgets/driver_tracking_map_view.dart
lib/features/driver/active_delivery/presentation/widgets/driver_tracking_summary_card.dart
lib/features/driver/active_delivery/presentation/widgets/driver_tracking_bottom_actions.dart
lib/features/driver/confirm_receipt/presentation/screens/driver_boxes_received_screen.dart
lib/config/routing/app_routes.dart
lib/config/routing/routing_generator.dart
lib/features/driver/tracking/presentation/manager/driver_live_location_coordinator.dart
lib/core/l10n/app_ar.arb
lib/core/l10n/app_en.arb
```

راجع `driver/map/presentation` وأماكن دخول `driver/orders` لتوصيل route arguments؛ عدّل نقطة الدخول الفعلية فقط. `core/app_shell` لا يعدل إلا إذا ثبت أنه لازم لنفس الفلو، مع الحفاظ على diff المستخدم.

### ملفات جديدة مقترحة بأسماء ثابتة

```text
lib/config/routing/arguments/driver_active_delivery_route_arguments.dart
lib/features/driver/active_delivery/data/data_source/driver_delivery_remote_data_source.dart
lib/features/driver/active_delivery/data/data_source/driver_delivery_remote_data_source_impl.dart
lib/features/driver/active_delivery/data/repo/driver_delivery_repository_impl.dart
lib/features/driver/active_delivery/data/mapper/driver_delivery_mapper.dart
lib/features/driver/active_delivery/data/models/request/driver_arrival_request_dto.dart
lib/features/driver/active_delivery/data/models/request/driver_deliver_request_dto.dart
lib/features/driver/active_delivery/data/models/response/driver_arrival_response_dto.dart
lib/features/driver/active_delivery/data/models/response/driver_delivery_proof_upload_response_dto.dart
lib/features/driver/active_delivery/data/models/response/driver_deliver_response_dto.dart
lib/features/driver/active_delivery/domain/repo/driver_delivery_repository.dart
lib/features/driver/active_delivery/domain/entities/driver_arrival_request_entity.dart
lib/features/driver/active_delivery/domain/entities/driver_arrival_result_entity.dart
lib/features/driver/active_delivery/domain/entities/driver_deliver_request_entity.dart
lib/features/driver/active_delivery/domain/entities/driver_deliver_result_entity.dart
lib/features/driver/active_delivery/domain/entities/driver_delivery_proof_upload_entity.dart
lib/features/driver/active_delivery/domain/usecase/arrive_at_driver_customer_usecase.dart
lib/features/driver/active_delivery/domain/usecase/upload_driver_delivery_proof_usecase.dart
lib/features/driver/active_delivery/domain/usecase/deliver_driver_order_usecase.dart
lib/features/driver/active_delivery/presentation/manager/active_delivery_event.dart
lib/features/driver/active_delivery/presentation/services/driver_delivery_proof_camera.dart
lib/features/driver/active_delivery/presentation/screens/driver_delivery_arrival_confirmation_screen.dart
lib/features/driver/active_delivery/presentation/widgets/driver_delivery_arrival_banner.dart
lib/features/driver/active_delivery/presentation/widgets/driver_delivery_customer_details_card.dart
lib/features/driver/active_delivery/presentation/widgets/driver_delivery_optional_otp_section.dart
lib/features/driver/active_delivery/presentation/widgets/driver_delivery_proof_photo_section.dart
lib/features/driver/active_delivery/presentation/widgets/driver_active_delivery_shimmer.dart
```

أعد استخدام Camera service موجودة إن وُجدت بدل إنشاء الثانية؛ الاسم المقترح adapter اختبار واضح لـImagePicker، ولا يستدعي شبكة. لا تُنشئ ملفات request فارغة للـupload؛ File/bytes تتحول إلى multipart في data layer وفق العقد.

الـActiveDeliveryTripEntity القديمة يمكن أن تبقى لمسارات الفشل/الإرجاع. الفلو الحقيقي يستخدم DriverMapRouteEntity وDriverMapStopEntity مباشرة ككيانات domain، ولا يحوّل unknown fields إلى قيم وهمية لإرضاء trip القديمة.

## 7. الواجهات المشتركة المقترحة

هذه أسماء داخل التطبيق وليست ادعاءً بأسماء حقول endpoint غير المتاحة. طابق DTO مع schema الحقيقي ثم اربطه بهذه الواجهات.

```dart
// domain/repo/driver_delivery_repository.dart
abstract interface class DriverDeliveryRepository {
  Future<ApiResult<DriverArrivalResultEntity>> arriveAtCustomer({
    required String boxId,
    required DriverArrivalRequestEntity request,
  });
  Future<ApiResult<DriverDeliveryProofUploadEntity>> uploadProof({
    required String localPath,
  });
  Future<ApiResult<DriverDeliverResultEntity>> deliverOrder({
    required String boxId,
    required DriverDeliverRequestEntity request,
  });
}

// request entities: plain Dart, no Dio/JSON/File dependency
class DriverArrivalRequestEntity {
  const DriverArrivalRequestEntity({this.latitude, this.longitude});
  final double? latitude;
  final double? longitude;
}

class DriverDeliverRequestEntity {
  const DriverDeliverRequestEntity({
    required this.proofPhotoStorageKey,
    this.latitude,
    this.longitude,
    this.deliveryOtp,
  });
  final String proofPhotoStorageKey;
  final double? latitude;
  final double? longitude;
  final String? deliveryOtp;
}
```

نتيجة الوصول: boxId، DateTime arrivedAtUtc، bool? isFirstArrival؛ لا تصنع timestamp إذا الرد ناقص. نتيجة upload: String storageKey غير فارغة؛ url ليس بديلًا عنها. نتيجة التسليم: boxId وDateTime deliveredAtUtc، String? tripId، bool? isTripCompleted، int? remainingStopsCount، bool? isFirstDelivery، String? driverId. nullable counters تحفظ أن السيرفر قد لا يكون محدثًا؛ لا تستخدم false/0 كحقائق بديلة.

إذا رد وصول/تسليم ناجح ناقص timestamp المطلوب: أعد القراءة/المصالحة قبل إعلان تفاصيل النتيجة، ولا تزعم أن العملية فشلت حتمًا ولا تعِد الإرسال آليًا. إذا تعذر التحقق اعرض خطأ العقد inline مع خيار «تحديث الحالة» بدل fake success.

UseCases الثلاثة تستقبل نفس arguments وتعيد نفس ApiResult. RepositoryImpl يستخدم `safeApiCall` ويحول DTO → Entity. RemoteDataSourceImpl يحمل `@Injectable(as: DriverDeliveryRemoteDataSource)`، وRepositoryImpl يحمل annotation بنمط المشروع، وUseCases/ViewModel `@injectable`.

## 8. المهام التنفيذية بالترتيب

### Task 0 — تثبيت الأدلة والعقد قبل كتابة الشبكة

**Files:** اقرأ القواعد والمراجع و`api_services.dart` و`network_constants.dart` وDI وroute generator؛ أنشئ `docs/mobile/driver-delivery-flow-contract-checklist.md` كسجل تحقق فقط.

- [ ] اقرأ AGENTS.md إن وجد عند التنفيذ، والقواعد كاملة؛ سجّل git status/diff وحافظ على العمل السابق.
- [ ] راجع ملفات الشاشات 07.00/07.01/07.02، واطلب مرجع 07.00B الفعلي فقط إذا لم يكن في المشروع أو الملفات المتاحة.
- [ ] سجّل path/method/body/response/status codes للوصول والتسليم من عقد الباك الكامل.
- [ ] سجّل upload path وmultipart part والمجلد وطريقة تمريره وحد الحجم واسم storageKey في الرد، ومتطلبات المصادقة.
- [ ] تحقق هل deliveryOtp مقبول في schema؛ ميّز قبول الحقل عن التحقق منه، ولا تضف resend.
- [ ] حدّد route الملخص الفعلي المقابل لـ05.03 إن وجد. لا تنشئ route وهميًا؛ إن لم يوجد يستخدم الفلو مدخل قائمة/حالة انتهاء التوصيلات الموجود، ويذكر أن شاشة ملخص العمل خارج النطاق.
- [ ] تحقق من البيئة التي نُشرت عليها تعديلات الباك. الملخص يقول NOT deployed؛ لا تغيّر base URL ولا تبدأ API باك محلي قد يطبق migration على DB مشتركة.

**قبول:** لا يوجد endpoint تخميني، والفروق بين العقد الحديث ووثائق UI القديمة مكتوبة. يمكن كتابة unit/widget tests بدون نشر، لكن لا يمكن إعلان smoke حقيقي بدون بيئة تدعم العقد.

### Task 1 — إضافة بيانات المحطة الضرورية

**Files:** DTO/Entity/Mapper الخريطة؛ `test/features/driver/map/data/driver_map_dto_mapper_test.dart`.

- [ ] أضف اختبارًا يفشل للحقول boxId/tripId/customerNote/arrivedAtUtc والتكرار في copyWith.
- [ ] أضف الحقول nullable في response DTO باستخدام json_serializable.
- [ ] أضف boxId/tripId/customerNote/DateTime? arrivedAtUtc لكيان المحطة مع copyWith ودعم clear للقيم nullable.
- [ ] اجعل fallback لـboxId من stopId مسموحًا فقط لأن العقد يؤكد alias؛ لا تستخدم boxCode أو orderId.
- [ ] tripId من المحطة أولًا. توافق السيرفر القديم مع top-level tripId مسموح فقط للمحطة المركزة نفسها عند تأكد الانتماء، لا توزعه على جميع stops متعددة الرحلات.
- [ ] parse UTC بـDateTime.tryParse(...).toUtc؛ invalid/null → null دون crash؛ المحتوى المفقود لا يخلق بيانات عميل.
- [ ] أبق customerPhone فارغًا كما mapper الحالي؛ customerNote لا تختصرها برمجيًا.
- [ ] شغّل generation ثم اختبار mapper.

```dart
test('keeps persisted arrival and delivery identifiers', () {
  final stop = DriverMapStopResponseDto.fromJson({
    'stopId': 'stop-a', 'boxId': 'stop-a', 'tripId': 'trip-a',
    'customerNote': 'اتركه عند البوابة',
    'arrivedAtUtc': '2026-10-06T08:35:00Z',
  }).toEntity(totalStopsCount: 2);
  expect(stop.boxId, 'stop-a');
  expect(stop.tripId, 'trip-a');
  expect(stop.customerNote, 'اتركه عند البوابة');
  expect(stop.arrivedAtUtc, DateTime.utc(2026, 10, 6, 8, 35));
});
```

**قبول:** fixtures القديمة تعمل، new fields محفوظة، ولا تسرّب رقم هاتف أو وقت وصول مصطنع.

### Task 2 — أوامر الوصول/الرفع/التسليم بكل طبقاتها

**Files:** الملفات الجديدة data/domain في §6، Core ApiServices وEndPoints؛ اختبارات جديدة تحت `test/features/driver/active_delivery/data/` و`domain/`.

- [ ] اكتب DTO parsing/request serialization tests: رد ناقص، key فارغة، timestamps invalid، حذف optional null، زوج الإحداثيات، وعدم تسريب localPath.
- [ ] أنشئ request/result entities وnullable response DTOs وmapper حسب §7 والعقد الموثق في Task 0.
- [ ] استخدم `@JsonSerializable(includeIfNull: false)` للـrequests الاختيارية؛ لا ترسل latitude وحدها.
- [ ] أضف EndPoints للوصول والتسليم بالمسارات المؤكدة، وupload بالمسار المتحقق فقط.
- [ ] أضف Retrofit methods؛ File/multipart داخل data layer فقط، باستخدام Dio والـinterceptors الموجودين.
- [ ] أنشئ RemoteDataSource contract/impl ثم Repository contract/impl ثم UseCases.
- [ ] تحقق من ownership في الباك؛ التطبيق لا يدعي أنه يستطيع فحص UploadFileRecord محليًا.
- [ ] عند قراءة ملف الإثبات من السيرفر، استخدم مسار authenticated موجود. لا Image.network anonymous على uploads/drivers/delivery ولا token في URL؛ المعاينة الأساسية محلية.
- [ ] لا تسجل token/OTP/صورة/key في debug output. لا تحفظ bearer ضمن route arguments.
- [ ] أنشئ اختبارات repository: success mapping وtyped failures، وعدم تحويل كل الفشل إلى String.

```dart
// ApiServices: imports والـEndPoints تضاف بالطريقة القائمة في المشروع.
@POST(EndPoints.driverArriveCustomer)
Future<DriverArrivalResponseDto> arriveAtDriverCustomer(
  @Path('boxId') String boxId,
  @Body() DriverArrivalRequestDto request,
);

@POST(EndPoints.driverDeliverOrder)
Future<DriverDeliverResponseDto> deliverDriverOrder(
  @Path('boxId') String boxId,
  @Body() DriverDeliverRequestDto request,
);

// Repository impl body، مع mapper في driver_delivery_mapper.dart
return safeApiCall(() async {
  final dto = await _remoteDataSource.deliverOrder(
    boxId: boxId,
    request: request.toDto(),
  );
  return dto.toEntity();
});
```

**قبول:** كل endpoint يمر بكل الطبقات، generation يسجل DI، ولا calls من الشاشة/VM إلى ApiServices.

### Task 3 — State وEvents وإدارة العملية

**Files:** `active_delivery_event.dart` وState/ViewModel؛ `test/features/driver/active_delivery/presentation/manager/active_delivery_view_model_test.dart`.

**State:** route nullable، selectedStopId nullable، arrivalResult nullable، deliveryResult nullable، localPhotoPath nullable، photoRevision int، uploadedPhotoRevision int?، proofStorageKey nullable، otpInput String، isInitialLoading/isRefreshing/isArriving/isUploading/isDelivering، loadFailure/arrivalFailure/uploadFailure/deliveryFailure من Failure، isEmpty، navigationRevision int. لا تطلب trip fake لتهيئة Cubit.

**Events:** LoadActiveDeliveryEvent(stopId?)، RefreshActiveDeliveryEvent، StartActiveDeliveryRouteEvent، ConfirmCustomerArrivalEvent، DeliveryProofSelectedEvent(localPath)، RetryDeliveryProofUploadEvent، OptionalDeliveryOtpChangedEvent(value)، ConfirmCustomerDeliveryEvent، ReconcileActiveDeliveryEvent، ClearActiveDeliveryNavigationEvent، ActiveDeliveryPausedEvent، ActiveDeliveryResumedEvent.

`StartActiveDeliveryRouteEvent` قرار انتقال داخل التطبيق بعد التحقق من eligibility، وليس endpoint جديدًا.

- [ ] اكتب tests تمنع الوصول/التسليم بلا valid stopId، وتمنع deliver بلا uploaded proof.
- [ ] inject GetDriverMapRouteUseCase وUseCases الثلاثة؛ expose doIntent فقط لأفعال UI، والـhandlers private.
- [ ] load/refresh لا يمسحان المحتوى عند refresh failure؛ latest-request generation تمنع رد محطة قديمة من استبدال الجديدة.
- [ ] ضع busy guard قبل أول await، وأعد جميع busy flags في نهاية المسار/الفشل دون emit بعد close.
- [ ] pin boxId+tripId+photoRevision في بداية كل عملية. لا تستخدم selectedStop الحالي بعد await لتطبيق نتيجة قديمة.
- [ ] عند الانتقال لمحطة مختلفة امسح arrivalResult/deliveryResult/localPhotoPath/proofStorageKey/OTP وأخطاء العملية السابقة، وزِد generation وphotoRevision. لا تعِد استخدام إثبات محطة A في B حتى إن الملف يخص السائق نفسه؛ ownership لا يعني ربط الصورة بمحطة بعينها.
- [ ] إذا اختار السائق صورة جديدة: زِد photoRevision، امسح storageKey وuploadedPhotoRevision فورًا، ولا يقبل upload السابق key للصورة الجديدة.
- [ ] تسليم لا يُسمح به إلا إذا key غير فارغة وuploadedPhotoRevision == photoRevision ووقت الوصول الحقيقي مثبت والمحطة مؤهلة.
- [ ] لا تمنع التسليم بسبب otpInput فارغ أو ناقص.
- [ ] عند Timeout للوصول: reconcile → إن ظهر arrivedAtUtc افتح 07.02، وإلا إتاحة retry لنفس boxId.
- [ ] عند Timeout للتسليم: لا تعرض نجاحًا؛ reconcile ثم retry بنفس key والمحطة إذا بقيت غير مسلمة. لا تعاود upload تلقائيًا لمجرد timeout deliver.
- [ ] success deliver محفوظ قبل refresh التالي؛ فشل refresh لا يعيد المستخدم لنموذج التسليم ولا يمحو النتيجة المؤكدة.
- [ ] navigationRevision يزداد مرة لنتيجة جديدة؛ listener يستهلكه مرة واحدة. REST والـSignalR لنفس المحطة لا ينتجان انتقالين.

```dart
// شروط داخل ActiveDeliveryState؛ selectedStop getter يحل من route.
bool get canDeliver {
  final stop = selectedStop;
  return !isArriving && !isUploading && !isDelivering &&
      stop != null && stop.status == DriverDeliveryStatus.inProgress &&
      (arrivalResult != null || stop.arrivedAtUtc != null) &&
      (proofStorageKey?.trim().isNotEmpty ?? false) &&
      uploadedPhotoRevision == photoRevision;
}

// فروع ApiResult، لا throw إلى UI ولا e.toString كنظام أخطاء.
switch (result) {
  case ApiSuccessResult(:final data):
    emit(state.copyWith(deliveryResult: data, isDelivering: false));
  case ApiErrorResult(:final failure):
    emit(state.copyWith(deliveryFailure: failure, isDelivering: false));
}
```

**قبول:** اختبار وصول ناجح لا يستدعي deliver، repeated click ينتج call واحدة، retry يكرر العملية الصحيحة، late upload لا يلوث إثبات محطة أخرى.

### Task 4 — ربط 07.00 و07.00B ونقاط الدخول

**Files:** شاشة البداية/widgets، `driver_boxes_received_screen.dart`، route arguments/routes/generator؛ اختبارات شاشة البداية والـrouting.

- [ ] أنشئ DriverActiveDeliveryRouteArguments يحمل stopId/tripId اختياريين، ونتيجة التسليم المؤكدة اختيارية لنقطة النجاح؛ لا يحتاج fake trip.
- [ ] نقطة pickup تمرر tripId الحقيقي بعد نجاح startTripResult. لا تعتمد على object قديم لإثبات إسناد جديد.
- [ ] الدخول من خريطة/قائمة تمرر stopId الحقيقي للمحطة المختارة. بدون arguments يجلب السيرفر focusedStop الحقيقي.
- [ ] بعد load: InTransit هو المؤهل للفلو؛ Pending/unknown لا ينفذ وصول/تسليم. إذا السيرفر اختار Delivered، اطلب الاختيار الحالي/المحطات غير المسلمة ولا تفتح submit عليها.
- [ ] اعرض Shimmer أثناء التحميل الأول، Core error للفشل بلا بيانات، EmptyState عندما لا توجد توصيلات.
- [ ] استخدم بيانات العميل/الوجبات/ملاحظاته والملاحة الحقيقية. أخفِ المسافة/ETA عند null، وأزل الوقت الثابت ونوع البوكس الافتراضي.
- [ ] زر البداية يرسل StartActiveDeliveryRouteEvent، ثم يفتح 07.01 بسياق المحطة نفسه بعد eligibility؛ لا يستدعي start-trip مرة ثانية.
- [ ] طبّق 07.00B على المكونات والعقد نفسيهما بعد قراءة مرجعها الحقيقي؛ وثّق الفصل بينهما في سجل التحقق. إن لم يوجد المرجع، لا تضف صفحة تخمينية ولا تضع علامة اكتمال لهذه الجزئية.

**قبول:** عدم وجود arguments لا يعرض عميلًا وهميًا؛ اختبار navigation يتأكد أن stopId لم يضِع؛ بداية محطة ثانية لا تستدعي trip-start.

### Task 5 — ربط 07.01 بالملاحة الحقيقية والوصول

**Files:** شاشة tracking/widgets وخدمات الخريطة القائمة؛ اختبار `driver_active_delivery_tracking_screen_test.dart`.

- [ ] أزل إنشاء ActiveDeliveryFakeRepositoryImpl/defaultTrip من المسار الحقيقي وwatchDriverLocation fake.
- [ ] أعد استخدام decoder/camera/navigation-launcher من feature map؛ لا تنسخ implementation جديدًا لخدمة الاتجاهات.
- [ ] GPS من DriverLiveLocationCoordinator.positions/latestLocation. لا stream GPS ثانية، ولا dispose للـsingleton عند مغادرة الشاشة.
- [ ] marker الجهاز الحي لا يجعل route origin القديم حيًا؛ اترك وصف last known/stale حسب بيانات السيرفر.
- [ ] bootstrap يرسل الموقع بالحالة القائمة ثم يحمل route دون انتظار غير محدود. Route poll كل 30 ثانية أثناء foreground، ومع resume/refresh/change stop، وليس لكل GPS sample.
- [ ] إن Route=Unavailable/null، اعرض العنوان/العميل والمحطة؛ أخفِ polyline/ETA غير المتاحين، ولا تستبدل الشاشة كلها بخطأ API.
- [ ] لا ترسم route إلا إذا navigation.destinationStopId يطابق selectedStopId والاستجابة أحدث generation.
- [ ] زر الوصول: doIntent(ConfirmCustomerArrivalEvent). احذف تمامًا completeDelivery من هذا الزر والانتقال الحالي للنجاح.
- [ ] ابق المحتوى أثناء isArriving واعرض feedback تحميل داخل مساحة الزر، مع تعطيل الضغط. بعد نجاح الوصول فقط انتقل 07.02.
- [ ] قاعدة 500م في وثيقة UI: إذا كلا موقع الجهاز الحالي والوجهة صالحان، اعرض confirmation قبل إرسال الوصول عند تجاوز 500م باستخدام الأداة الجغرافية الموجودة. الحساب هنا للتنبيه فقط، لا لتوليد ETA/مسار ولا لفرض شرط باك جديد. إن الموقع غير متاح، لا تخترع المسافة.
- [ ] لا تشغيل تلقائي لتأخير، ولا شارة «في الوقت المحدد» مبنية على تخمين.
- [ ] الإيقاف في background يوقف polling المرئي فقط؛ لا توقف tracking المطلوب للشفت.

**قبول:** test يشاهد arrive مرة واحدة وdeliver صفر، ولا تنقل الشبكة الفاشلة إلى 07.02/07.06؛ unavailable route يحافظ على العميل والعنوان.

### Task 6 — إنشاء 07.02: OTP الاختياري وصورة الإثبات

**Files:** الشاشة الجديدة/widgets وcamera adapter وARB؛ `test/features/driver/active_delivery/presentation/screens/driver_delivery_arrival_confirmation_screen_test.dart`.

- [ ] أضف route `AppRoutes.driverDeliveryArrivalConfirmation` واربطه بالـarguments الصحيحة. direct entry يعيد load والتحقق من arrivedAtUtc.
- [ ] Arrival banner من وصول مثبت، ووقت معروض بتحويل UTC إلى timezone العرض الحالي في التطبيق، مع الاحتفاظ بـUTC في domain.
- [ ] Customer card: الاسم، العنوان، boxCode، mealsCount/summary، note؛ لا حقول هاتف أو box type مصطنعة.
- [ ] OTP section وفق §4.5: السائق يدخل 4 digits اختياريين؛ يحذفها دون عرقلة، ولا resend/verified badge.
- [ ] زر الكاميرا يستدعي adapter بـImageSource.camera؛ cancellation لا خطأ، denial يعرض رسالة محلية مناسبة دون محو بيانات الطلب.
- [ ] صورة ملتقطة تنتقل إلى DeliveryProofSelectedEvent(localPath)، وتعرض thumbnail محليًا فورًا.
- [ ] upload يبدأ بعد الالتقاط، ويميز «التُقطت» عن «رُفعت». علامة إثبات جاهز تظهر بعد key ناجحة فقط.
- [ ] أثناء upload اعرض Shimmer في منطقة الإثبات مع بقاء المعاينة/العميل؛ لا يُتاح deliver أو تغيير المحطة أثناء submit.
- [ ] إعادة الالتقاط تمسح key فورًا؛ لو upload قديم لا يمكن إلغاؤه، تجاهل نتيجته بـrevision check.
- [ ] فشل upload → InlineApiErrorWidget عند منطقة الصورة، retry يرفع الصورة الحالية فقط؛ لا يعيد arrive.
- [ ] زر تسليم مفعل وفق canDeliver. يمكن رؤية الصورة فور التقاطها، لكن تأكيد التسليم لا يصل API قبل رفعها؛ هذا لا يجعل OTP شرطًا.
- [ ] عند الضغط await deliver؛ محتوى الصفحة لا يختفي، والتكرار محجوب؛ النجاح فقط ينقل 07.06.
- [ ] لا تحذف الملف المحلي قبل انتهاء الرفع/التسليم. تنظف ملفات مملوكة لهذه الميزة فقط بعد نجاح مؤكد/استبدال آمن، دون حذف صور المستخدم الأصلية.

**قبول:** سيناريو OTP فارغ + صورة مرفوعة يسلم؛ OTP كامل بدون صورة لا يسلم؛ صورة غير مرفوعة لا تسلم؛ upload retry يحتفظ بوقت الوصول والنموذج.

### Task 7 — النجاح والمحطة التالية ومصالحة tracking/realtime

**Files:** شاشة النجاح، نقاط تحديث map/orders/home، coordinator وrealtime implementation إذا يلزم؛ tests للـnavigation والعدادات.

- [ ] شاشة النجاح تستقبل snapshot العميل وDriverDeliverResultEntity من عملية مؤكدة، ولا defaultTrip ولا deliver جديد عند فتحها.
- [ ] اعرض DeliveredAtUtc الأصلي. isFirstDelivery=false لا يولد رسالة فشل أو خصمًا محليًا آخر.
- [ ] `remainingStopsCount` و`isTripCompleted` للرحلة المعنية فقط. لا تستنتج انتهاء الشفت منهما.
- [ ] بعد التسليم حدّث route/orders من السيرفر، واستخرج next stop من ترتيب/اختيار السيرفر؛ لا sort جديد محليًا بين رحلات مختلفة.
- [ ] إذا توجد محطات غير مسلمة في رحلة أخرى، انتقل للتالية واستمر tracking حتى لو isTripCompleted=true للرحلة السابقة.
- [ ] إن refresh فشل، أبق نجاح التسليم وأظهر retry refresh، لا تسمح بإعادة submit ولا تعرض رحلة مكتملة عالميًا بدون دليل.
- [ ] لا تستعمل `totalStopsCount - completedStopsCount` كعدد مؤهل نهائي إذا Failed/unknown غير مميزين في القائمة. للمصالحة استخدم مصدر الطلبات الذي يصنف الحالات، أو eligible InTransit/Pending المؤكدة؛ لا تحسب delivered/failed.
- [ ] أزل setActiveBoxesCount(1). اجعل مصدرًا واحدًا مسؤولًا عن العدد الحقيقي عبر الرحلات. لا يخصم coordinator على REST ثم على حدثين لنفس boxId.
- [ ] عند وصول DriverOrderDeliveredEvent/DriverDeliveryCompletedEvent لنفس المحطة: debounce refresh أو dedupe بالهوية/eventId؛ لا جمع خصمين ولا تطبيق remainingBoxesCount كعدد عالمي دون عقد يثبت أنه عالمي.
- [ ] إشعار العميل يصدر من الباك عند أول وصول؛ الموبايل لا يرسل push بديلًا ولا يفترض فشل arrive بسبب غياب push.
- [ ] افحص mapping `DriverArrivedAtCustomerEvent` الموجود؛ استخدم الحدث لتحديث/إعادة قراءة arrivedAtUtc لا لتلفيق timestamp. REST نجاح كافٍ؛ انقطاع SignalR لا يعطل التسليم.
- [ ] إذا انتهت جميع التوصيلات، اعرض مدخل إنهاء التوصيلات/الملخص المتاح. إنهاء trip ليس إنهاء shift تلقائيًا.

**قبول:** رحلة A مكتملة وB نشطة → tracking مستمر؛ REST+حدثان لنفس التسليم → لا تكرار نجاح ولا خصم مضاعف؛ refresh failure لا يمحو التسليم.

### Task 8 — Core errors وShimmer والتوافق البصري

**Files:** widgets الجديدة وState bindings؛ Core errors تُعاد استخدامها، لا تعدّلها إلا إذا نقص دعم code مثبت ومختبر.

- [ ] initial loading بلا محتوى: DriverActiveDeliveryShimmer باستخدام `lib/core/widget/shimmer_widget.dart` ونمط animation الموجود في DriverMapShimmer.
- [ ] Shimmer يحاكي المساحات الموجودة في الشاشة، ويتوقف/يصبح ثابتًا عند disableAnimations. لا skeleton تفاعلي.
- [ ] failure بلا بيانات: `ApiErrorWidget.fromTypedFailure`.
- [ ] خطأ عملية/refresh مع محتوى: `InlineApiErrorWidget` في الموضع المناسب؛ لا replace للنموذج.
- [ ] empty نجاح أو DriverTrip.NotFound الموثق: `EmptyStateWidget`؛ لا Failure مصطنع.
- [ ] Loading عملية: مساحة الزر feedback/disabled؛ Loading صورة: shimmer في قسمها فقط. لا full-screen shimmer يحجب صورة/OTP موجودين.
- [ ] retry يكرر Intent العملية المتعثرة فقط.
- [ ] no internet/timeout/unauthorized/forbidden تتبع Core typed errors والـauth interceptor الموجود؛ لا network client/token refresh جديد.
- [ ] أضف النصوص للـARB بالعربية والإنجليزية، RTL وkeyboard numeric وتسميات أزرار الكاميرا/إعادة الالتقاط متاحة لقارئ الشاشة.

```dart
// داخل BlocBuilder باستخدام State الحالية، لا generic wrapper جديد.
if (state.isInitialLoading && state.route == null) {
  return const DriverActiveDeliveryShimmer();
}
final failure = state.loadFailure;
if (failure != null && state.route == null) {
  return ApiErrorWidget.fromTypedFailure(
    failure,
    onRetry: () => viewModel.doIntent(const RefreshActiveDeliveryEvent()),
  );
}
if (state.isEmpty) return const EmptyStateWidget();
// بقية build تستخدم route وsection failures الموجودة دون محو المحتوى.
```

**قبول:** RTL/English يعملان؛ loading لا يظهر كفشل، refresh failure لا يخفي الشاشة، ولا spinner عام بدل shimmer تحميل البيانات.

## 9. قائمة الاختبارات المطلوبة ومعنى كل اختبار

أنشئ fixtures اصطناعية للاختبارات فقط؛ لا تضع token أو صورة أو بيانات عميل فعلية في test source.

| مجموعة | حالات محددة يجب تغطيتها |
|---|---|
| Map DTO/Mapper | الحقول الجديدة؛ timestamps null/invalid؛ old DTO؛ boxId alias؛ tripId متعدد؛ عدم كشف customerPhone |
| Request serialization | key فقط؛ حذف null؛ زوج GPS/finite/range؛ OTP فارغ/جزئي محذوف؛ لا localPath في body |
| Repository | response → entity؛ typed network/business Failure؛ upload key فارغة لا نجاح جاهز |
| ViewModel وصول | busy قبل await؛ duplicate tap؛ timeout reconciliation؛ stored arrival؛ forbidden/404 لا success |
| ViewModel صورة | key فقط بعد upload؛ retake يمسح key؛ late response revision ignored؛ cancel لا Failure |
| ViewModel تسليم | proof required؛ OTP فارغ لا gate؛ GPS missing pair؛ repeat response نجاح؛ wrong stop response ignored |
| Tracking widgets | ready/unavailable/null navigation؛ latest destination؛ arrival لا deliver؛ لا default ETA |
| Arrival widgets | camera preview/upload failure/retry؛ optional OTP؛ deliver disabled أثناء upload؛ inline errors |
| Navigation | 07.00→07.01 بنفس stop؛ 07.01→07.02 بعد وصول؛ 07.02→07.06 بعد تسليم؛ no double navigation |
| Persistence/recovery | close/reopen يعرض arrivedAtUtc الأصلي؛ صورة محلية مفقودة تطلب التقاطًا جديدًا؛ Delivered direct entry ممنوع submit |
| Multiple trips | completed A لا يوقف B؛ remainingStopsCount لا global؛ duplicated events لا double decrement |
| Regression | map/orders/confirm_receipt/tracking/failure/return لا تنكسر بسبب تغيير VM/route arguments |

لكل مهمة business logic: اكتب test السلوك، شغّله ليثبت المشكلة، نفّذ الحد الأدنى ثم شغّله. لا تختبر تفاصيل widget داخلية لا علاقة لها بالعقد.

مثال لاختبار الحماية من تكرار confirm:

```dart
// fake usecase يحتجز future عبر Completer حتى نحاكي الضغط مرتين.
final first = viewModel.doIntent(const ConfirmCustomerDeliveryEvent());
final second = viewModel.doIntent(const ConfirmCustomerDeliveryEvent());
await Future<void>.delayed(Duration.zero);
expect(deliverCallCount, 1);
// أكمل future بنجاح وأكد navigation واحدة وtimestamp الأصلي.
```

وحد API tests تثبت JSON المتفق عليه؛ لا تعتمد فقط على mocks مكتوبة بنفس تنفيذ التطبيق، ولا تستدع deliver حقيقي على طلب عميل ضمن unit tests.

## 10. أوامر التحقق عند التنفيذ

من جذر المشروع، على البيئة التي فيها Flutter/Dart:

```powershell
git status --short
git diff -- lib/features/driver/active_delivery lib/core/app_shell
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
dart format lib/features/driver/active_delivery lib/features/driver/map lib/config/routing
flutter test test/features/driver/active_delivery
flutter test test/features/driver/map
flutter test test/features/driver/confirm_receipt
flutter test test/features/driver/orders
flutter test test/features/driver/tracking
flutter analyze
git diff --check
```

نسق ملفات Core/ARB/coordinator المعدلة فقط أيضًا، ولا تشغّل formatting شامل يسبب diff خارج النطاق. generated *.g.dart وDI وlocalizations تنتج بالأدوات فقط؛ راجع output بحثًا عن تغييرات غير مرتبطة.

إذا فشل اختبار قديم، راجع baseline/diff ولا تفترض أنه غير متعلق ولا تغيّر expectation لتمرير regression. وثّق أي فشل خارجي مع دليل. لا تعلن analyzer/tests passed بدون output فعلي.

## 11. Smoke test على بيئة تدعم العقد

التنفيذ المحلي واختبار mocks لا يثبتان أن السيرفر العام منشور. بعد تحقق النشر/توفير بيئة اختبار، استخدم سائقًا ومحطات اختبار معروفة ومصرحًا بها:

1. أكد استلام الشحنة ثم start-trip، وافتح 07.00 بعميل حقيقي لا default.
2. انتقل 07.01 وتحقق من تطابق وجهة الخريطة مع stopId.
3. أكد الوصول مرة، وسجّل arrivedAtUtc من الرد؛ كرر التحقق وتأكد أنه ثابت ولا يتكرر إشعار العميل.
4. أغلق التطبيق وافتح نفس المحطة: تعود 07.02 بنفس وقت الوصول.
5. اترك OTP فارغًا، والتقط صورة، وانتظر upload key؛ أكد التسليم.
6. تحقق من deliveredAtUtc وtripId والعدادات ومن تحديث قائمة الطلبات.
7. أعد سيناريو timeout/retry على بيئة الاختبار: لا تسليم أو success مضاعف.
8. رحلة أخرى نشطة: لا ينقطع tracking عند اكتمال الرحلة الأولى.
9. جرّب إثبات سائق آخر/صيغة غير مسموحة على بيانات اختبار: يظهر خطأ inline ولا نجاح.
10. تحقق من privacy server بإذن بيئة الاختبار: anonymous قراءة الإثبات مرفوضة؛ لا تعرض هذه الصور عبر public URL داخل التطبيق.

لا تفتح API باك محليًا ولا تطبق migrations ولا تنشر الباك من أجل هذا smoke. إذا لم تتوفر البيئة، سلّم العمل بوصف «تم التحقق بـunit/widget فقط؛ smoke ينتظر بيئة العقد».

## 12. تعريف الاكتمال لجيمناي

- [ ] 07.00/07.01/07.02 لا تعتمد على fake في المسار الحقيقي.
- [ ] 07.00B مطابقة لمرجعها الحقيقي، أو مذكورة بصراحة كجزئية غير قابلة للتأكيد بسبب غياب المرجع.
- [ ] confirm arrival لا يستدعي deliver ولا ينتقل للنجاح.
- [ ] arrival server timestamp يستعاد بعد إعادة الفتح ولا push من الموبايل.
- [ ] صورة إلزامية، storageKey من upload ناجح وبنفس photo revision والمحطة.
- [ ] OTP بواسطة السائق، اختياري، لا resend ولا ادعاء تحقق غير موجود.
- [ ] نجاح التسليم ينتظر REST مؤكد/مصالحة مؤكدة ولا counters optimistic.
- [ ] التكرار والتزامن وفقد الرد لا يولدون عمليات/انتقالات مضاعفة.
- [ ] نتائج رحلة واحدة لا تنهي رحلات أخرى أو الشفت.
- [ ] Core errors وShimmer مستخدمان دون custom error infrastructure.
- [ ] لا وقت/عميل/نوع بوكس/مسار/ETA/هاتف مصطنع.
- [ ] tests/generation/analyzer مكتملة مع ذكر النتائج الفعلية.
- [ ] التغييرات السابقة للمستخدم محفوظة، ولا نشر ولا تعديل باك ضمن المهمة.

### رسالة تسليم جيمناي المطلوبة

اذكر الملفات المتغيرة، وفلو التشغيل الفعلي، ونتائج الاختبارات، وأي اختلاف مثبت في عقد السيرفر، وحالة 07.00B والـupload والـOTP. افصل «منفذ ومختبر محليًا» عن «متحقق على API حقيقي». لا تكتب «كل شيء مكتمل» إذا upload path لم يتحقق أو السيرفر لا يدعم العقد.

## 13. نص جاهز لتكليف جيمناي

> نفّذ هذه الخطة بالترتيب داخل مشروع Flutter الحالي. اقرأ أولًا rules/rules_backend.md وlib/core/errors والخطة كاملة، وحافظ على git diff الموجود. النطاق 07.00/07.00B/07.01/07.02 مع ربط خريطة 03.01 ونهاية النجاح 07.06 فقط بالقدر اللازم. استخدم Feature-Based Clean Architecture، ApiResult/safeApiCall/Retrofit/Injectable، doIntent وState immutable، وShimmer الموجود. السائق يدخل OTP اختياريًا؛ لا تحقق وهمي ولا resend، ولا تأخير. الصورة إلزامية ويجب رفعها والحصول على storageKey قبل deliver. لا تخترع upload endpoint ولا تصميم 07.00B عند غياب المرجع، ولا تحول arrival إلى delivery. أكمل ما يمكن التحقق منه، وحدد أي مانع في العقد بدقة، وشغّل الاختبارات وgeneration/analyzer قبل التسليم. لا تعدّل أو تشغّل أو تنشر الباك، ولا تنشر التطبيق.
