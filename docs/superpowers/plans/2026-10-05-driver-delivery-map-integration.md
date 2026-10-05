# Driver Delivery Map Integration Implementation Plan

> **For agentic workers:** استخدم `superpowers:executing-plans` لتنفيذ المهام بالتتابع وبنقاط مراجعة. يمكن استخدام `superpowers:subagent-driven-development` إذا طلب المستخدم التنفيذ عبر agents. تتبع الخطوات بعلامات `- [ ]`. هذه خطة تسليم لجيميناي؛ لا تنفذ تغييرات خارج نطاقها.

**Goal:** ربط صفحة خريطة السائق ببيانات حقيقية، مع موقع متحرك وطريق محسوب من الباك يتحدث كل 30 ثانية أثناء ظهور الصفحة، مع الحفاظ على التصميم واستخدام Core errors وshimmer.

**Architecture:** Feature-Based Clean Architecture الموجودة بالمشروع: UI → Event → Cubit/ViewModel → UseCase → Repository → RemoteDataSource → Retrofit ApiServices. الرد DTO → Mapper → Entity → immutable State → UI. بث الموقع يستخدم DriverLiveLocationCoordinator الحالي؛ طلب الطريق REST مستقل عن بث الموقع.

**Tech Stack:** Flutter/Dart، flutter_bloc، Dio، Retrofit، json_serializable، Injectable/GetIt، google_maps_flutter، geolocator، signalr_netcore، url_launcher، Core errors وShimmerWidget. أضف مكتبة محلية لفك Google polyline5 فقط إذا لا يوجد decoder مناسب؛ لا مكتبة حساب اتجاهات ولا مفتاح Directions بالموبايل.

**Spec:** [Backend contract snapshot](../specs/2026-10-05-driver-delivery-map-backend-contract.md). اقرأ هذا العقد كاملاً قبل التنفيذ، ومعه `rules/rules_backend.md` و`lib/core/errors/`.

## 1. القرارات المعتمدة والنطاق

- المستخدم أكد: الاتجاهات تتحسب على الباك وتصل جاهزة. مفاتيح Maps SDK الحالية على Android/iOS لعرض الخريطة تظل كما هي؛ الممنوع إضافة مفتاح Directions أو حساب الطريق من الموبايل.
- route endpoint ليس Stream: طلب GET أول الفتح، كل 30 ثانية أثناء الظهور، عند تغيير العميل، وعند الرجوع من الخلفية.
- موقع الدرايفر يتبث بالطريقة الحالية كل 4 ثوانٍ تقريباً، وتحريك marker يكون محلياً مع GPS، دون طلب طريق لكل نقطة.
- الطريق من موقع السائق إلى **العميل المختار فقط**. لا route optimization ولا خط يمر بكل المحطات.
- حالات عدم توفر الطريق لا تلغي البطاقات والعناوين. أرقام العميل وزر الاتصال لا يظهران نهائياً.
- الحفاظ على UI، الثيم، RTL، الكاروسيل، التنقل وbottom navigation. التغييرات البصرية فقط لما يحتاجه الربط: تحميل، تنبيهات، قياسات، زر ملاحة.
- لا تنفيذ backend، ولا ترقية provider سيرفري، ولا تعديل شاشات active_delivery التجريبية ضمن هذا النطاق.
- حالة المستند: الباك غير منشور وقت كتابة الدليل، وsmoke test الحقيقي غير منفذ. جهز التطبيق واختبر بعينات عقدية، ثم افصل نتيجة اختبارات التطبيق عن نتيجة اختبار السيرفر بعد النشر.
- لا تغيّر base URL العام لأن feature واحدة لم تُنشر؛ استخدم إعداد البيئة الحالي والتنسيق مع فريق الباك لبيئة الاختبار.

## 2. نتائج مراجعة الكود الحالية التي يجب إصلاحها

| المكان | الوضع الحالي | المطلوب |
|---|---|---|
| `lib/features/driver/map/presentation/screens/driver_map_screen.dart` | fallback إلى fake stops/location/route، اختيار index صفر، البيانات late final | تحميل حقيقي وState قابل للتحديث، اختيار focusedStop السيرفري، بلا fake fallback في الإنتاج |
| `driver_map_background.dart` | marker سائق ثابت وpolyline ثابت لكل المحطات | طبقات مشروطة، طريق مفكوك، marker حي مستقل، origin منفصل |
| `driver_map_stop_entity.dart` | إحداثيات non-null، badge محسوب محلياً | إحداثيات nullable، sequenceBadge/statusText/statusColor/isCurrent من العقد |
| `driver_map_stop_card.dart` | يحدد status حسب `sequenceNumber == 1` | الحالة من status/statusText/statusColor |
| `driver_map_screen.dart::_handleAddressPressed` | يبني Maps URL محلياً | فتح googleMapsUrl القادم من السيرفر حرفياً، حسب canNavigate |
| `lib/core/errors/api_exception_mapper.dart` | يقرأ أكواد الجذر فقط | دعم `extensions.code` مع استمرار دعم الشكل القديم |
| `lib/core/app_shell/screens/app_shell_screen.dart` | الماب داخل IndexedStack، تظل mounted عند ترك التاب | تمرير isActive والتوقف عند اختفاء التاب؛ dispose وحده لا يكفي |
| `lib/features/driver/tracking/presentation/manager/driver_live_location_coordinator.dart` | بث واحد موجود، لكن لا position stream عام ولا نجاح إرسال معلن | واجهة مراقبة محلية صغيرة للاستهلاك من الماب، بدون broadcaster جديد |
| `lib/features/driver/orders/domain/entities/driver_delivery_status.dart` | fromWire لا يعرف InTransit | map-local mapping لـ InTransit → inProgress، بلا تغيير دلالات features الأخرى |
| `lib/core/widget/shimmer_widget.dart` | skeleton ثابت بلا animation | إعادة استخدامه داخل shimmer متحرك محلي للماب، دون تغيير كل loaders بالمشروع |
| `lib/core/di/di.dart` | التسجيل الحالي manual GetIt رغم وجود annotations في features | annotations للطبقات الجديدة + تسجيلات runtime بأسلوب الملف الحالي، بلا تسجيل مزدوج |

## 3. التعليمات العامة لجيميناي

1. اقرأ قواعد الريبو وAGENTS.md إن وجد؛ البحث السابق لم يُظهر ملفاً داخل المشروع، فأعد التحقق قبل التنفيذ.
2. اقرأ العقد المستقل، هذه الخطة، rules_backend بالكامل، ثم core networking/errors/DI والـ references أدناه.
3. افحص `git status --short` واحفظ تغييرات المستخدم. لا تستبدل ملفات غير مرتبطة ولا تعمل reset.
4. نفذ المهام بالتتابع؛ اختبر السلوك الجديد قبل/بعد تعديله. لا تتوقف بعد إضافة endpoint؛ الربط لا يكتمل إلا بوصوله إلى UI.
5. لا تعدل ملفات `.g.dart` يدوياً. أعد التوليد بـ build_runner، وراجع diff الناتج.
6. لا Dio جديد، لا HttpClient منفصل، لا refresh-token flow داخل الماب، ولا API call في screen.
7. لا force unwrap لإخفاء nulls. استخدم copyWith يدعم **مسح** القيم nullable فعلياً، وليس `value ?? oldValue` فقط.
8. لا تعتبر unavailableReason خطأ API؛ هي حالة أعمال داخل 200.
9. لا تستنتج نجاح إرسال الموقع من isStreaming؛ ده بدء بث فقط، وليس ACK.
10. أخيراً سلّم قائمة الملفات، الاختبارات المنفذة ونتائجها، وما لم يتأكد على السيرفر. لا تقل إن السيرفر جاهز بناء على mock.

### ملفات مرجعية موجودة

- `lib/features/driver/home/data/data_source/driver_home_remote_data_source_impl.dart`
- `lib/features/driver/home/data/repo/driver_home_repository_impl.dart`
- `lib/features/driver/home/presentation/manager/driver_home_view_model.dart`
- `lib/features/driver/home/presentation/manager/driver_home_state.dart`
- `lib/features/dispatcher/dispatcher_map/presentation/screens/dispatcher_map_screen.dart` لنمط isActive/lifecycle/ownership.
- `lib/core/network/api_results.dart` و`lib/core/network/failures.dart`.
- `lib/core/errors/api_exception.dart` و`api_exception_mapper.dart`.
- `lib/core/errors/error_widgets/api_error_widget.dart` و`inline_api_error_widget.dart` و`empty_state_widget.dart`.
- `lib/core/services/token_interceptor.dart` و`language_interceptor.dart`.
- `lib/core/widget/shimmer_widget.dart` و`lib/features/driver/home/presentation/widgets/driver_home_shimmer.dart`.
- `lib/features/driver/tracking/data/services/driver_location_service.dart`.
- `lib/features/driver/orders/data/realtime/driver_orders_realtime_client.dart`.

## 4. خريطة الملفات والمسؤوليات

الجذر المختصر في باقي الخطة: `lib/features/driver/map/`.

### إنشاء ملفات الميزة

| المسار نسبة لجذر الميزة | المسؤولية |
|---|---|
| `data/models/response/driver_map_route_response_dto.dart` | root DTO + JSON serialization |
| `data/models/response/driver_map_stop_response_dto.dart` | بطاقة stop DTO |
| `data/models/response/driver_map_navigation_response_dto.dart` | navigation DTO |
| `data/models/response/driver_map_location_response_dto.dart` | origin/destination/legacy waypoint DTO |
| `data/data_source/driver_map_remote_data_source.dart` | عقد المصدر |
| `data/data_source/driver_map_remote_data_source_impl.dart` | التفويض إلى ApiServices |
| `data/mapper/driver_map_mapper.dart` | DTO → entities وتحويل حالة الماب |
| `data/repo/driver_map_repository_impl.dart` | safeApiCall والت mapping |
| `domain/entities/driver_map_route_entity.dart` | لقطة الرد وبطاقاته والرحلة |
| `domain/entities/driver_map_navigation_entity.dart` | الملاحة وحالاتها |
| `domain/entities/driver_map_location_entity.dart` | نقطة مصنفة وحداثتها |
| `domain/entities/driver_map_route_status.dart` | enum Ready/Unavailable/Completed/unknown |
| `domain/entities/driver_map_unavailable_reason.dart` | enum للأسباب الخمسة + unknown |
| `domain/repo/driver_map_repository.dart` | عقد Repository |
| `domain/usecase/get_driver_map_route_usecase.dart` | طلب المسار عبر Repository |
| `presentation/manager/driver_map_event.dart` | sealed intents |
| `presentation/manager/driver_map_state.dart` | immutable state وcopyWith |
| `presentation/manager/driver_map_view_model.dart` | requests، freshness، polling، location subscription |
| `presentation/widgets/driver_map_shimmer.dart` | skeleton متحرك لأول تحميل |
| `presentation/widgets/driver_map_navigation_panel.dart` | قياسات/زر ملاحة وحالات unavailable |
| `presentation/widgets/driver_map_polyline_decoder.dart` | adapter لمكتبة فك polyline5، يمنع crash من بيانات معطوبة |
| `presentation/widgets/driver_map_camera_controller.dart` | bounds والكاميرا مع interface قابل للاختبار |
| `presentation/widgets/driver_map_navigation_launcher.dart` | url_launcher adapter واختبار فتح الرابط |

لا تنشئ request DTO لأن GET ليس له body. استخدم `data/data_source/` للملفات الحقيقية حسب rules_backend؛ وجود fake file القديم تحت `datasources/` لا يبرر نقله ضمن refactor جانبي.

### تعديل الملفات الموجودة

- جميع widgets اللازمة تحت `lib/features/driver/map/presentation/` والـ stop entity الموجود.
- `lib/core/network/network_constants.dart` و`api_services.dart` وgenerated Retrofit عبر generator.
- `lib/core/di/di.dart`.
- `lib/core/errors/api_exception_mapper.dart`.
- `lib/core/app_shell/screens/app_shell_screen.dart`.
- `lib/config/routing/routing_generator.dart` فقط لو يحتاج provider/route lifecycle wiring.
- `lib/features/driver/tracking/presentation/manager/driver_live_location_coordinator.dart`.
- إنشاء `lib/features/driver/tracking/domain/entities/driver_live_location_sample.dart` لواجهة snapshot عامة دون Geolocator في domain.
- `lib/core/l10n/app_ar.arb` و`app_en.arb`؛ التوليد بـ flutter gen-l10n.
- `pubspec.yaml` و`pubspec.lock` فقط لمكتبة decoder محلية إن احتجت.

## 5. عقد البيانات الذي تنفذه

### الطلب

```http
GET /api/v1/driver/map/route
GET /api/v1/driver/map/route?focusedStopId=<GUID>
Authorization: Bearer <driver-token>
Accept-Language: ar|en
```

الهيدرات تأتي من interceptors الحالية. لا ترسل driverId أو lat/lng أو أي body. NetworkConstants.baseUrl الحالي هو host فقط؛ endpoint يجب أن يحتوي `/api/v1/`، لا تكررها ولا تحذفها.

### DTOs: كل fields nullable/defensive

| الكائن | الحقول والأنواع |
|---|---|
| root | String? tripId, tripCode؛ double? driverLatitude, driverLongitude؛ int? totalStopsCount, completedStopsCount؛ DriverMapStopResponseDto? focusedStop؛ List<DriverMapStopResponseDto>? stops؛ List<DriverMapLocationResponseDto>? routePolylineWaypoints؛ DriverMapNavigationResponseDto? navigation |
| stop | String? stopId, sequenceBadge, boxCode, customerName, customerPhone, addressShort, fullAddress, mealsSummary, deliveryTimeSlot, status, statusText, statusColor؛ int? sequenceNumber, mealsCount؛ bool? isCurrent؛ double? latitude, longitude |
| location | double? latitude, longitude, heading؛ String? label, source؛ DateTime? recordedAtUtc؛ bool? isStale |
| navigation | String? destinationStopId, routeStatus, unavailableReason, encodedPolyline, polylineEncoding, googleMapsUrl؛ DriverMapLocationResponseDto? origin, destination؛ int? distanceMeters, durationSeconds؛ DateTime? estimatedArrivalAtUtc, calculatedAtUtc؛ bool? canNavigate |

الحسابات المالية غير موجودة هنا. استخدم generated serialization والتحويل من num للإحداثيات؛ اتبع قواعد المشروع للتواريخ الدفاعية، ولا تسمح لتاريخ malformed أن يمسح البطاقات كلها.

### Domain mapping

- حافظ على ترتيب `stops` القادم كما هو؛ لا sort محلياً ولا filtering حسب tripId.
- إهمل entry بلا stopId صالح/غير فارغ بدل اختراع ID؛ لا ترسل sample `stop_1` للباك.
- `focusedStop` يحدد الاختيار الابتدائي؛ تحقق إنه موجود بالقائمة. fallback دفاعي لـ isCurrent ثم أول بطاقة، بدون إعادة ترتيب.
- `sequenceBadge` نص سيرفري؛ لا تستخدم sequenceNumber/totalStops لإعادة حسابه، لأن الرقم المحلي داخل رحلة والإجمالي عبر عدة رحلات.
- `InTransit` → DriverDeliveryStatus.inProgress، `Pending` → pending، `Delivered` → delivered، unknown → unknown. عالج ذلك في mapper الماب.
- `statusText` اعرضه كما هو؛ عند غيابه فقط استخدم ترجمة الحالة المعروفة. لا تستنتج الحالة من ترتيب المحطة.
- الألوان عبر whitelist gray/green/orange إلى ألوان الثيم الحالية؛ unknown لون محايد.
- customerPhone تجاهله عند mapping، واجعل entity إن احتفظ بالحقل للتوافق يعيده فارغاً حتى لو السيرفر أرسل رقماً.
- fullAddress → formattedAddress؛ fallback إلى addressShort فقط إن fullAddress فارغ. لا عنوان مخترع.
- latitude/longitude تظل nullable؛ coordinates missing لا تصبح 0 أو sample location.
- imageAsset من AppAssets.driverKpiBox محلياً؛ هذا presentation asset وليس field من الباك.
- legacy driverLatitude/driverLongitude وroutePolylineWaypoints لا تحدد origin ولا الطريق.
- navigation nullable طبيعي؛ enum unknown لا يسبب crash ولا يفعّل الطريق.
- origin.source = shift_start يعرض كآخر موقع معروف دائماً، حتى لو isStale غير متوقع من mock.
- navigation timestamps UTC داخلياً؛ display باستخدام toLocal وIntl/MaterialLocalizations الموجودة بالمشروع حسب المتاح، بدون تثبيت Cairo أو الكويت في الكود.

### مصفوفة القرار

| الحالة | الطريق والقياسات | النقاط والتنبيه | الملاحة الخارجية |
|---|---|---|---|
| Ready | polyline5 فقط + non-null قياسات | origin + destination، marker الجهاز مستقلاً | حسب canNavigate والرابط الموجود |
| driver_location_missing | مخفيان | وجهة + تنبيه تفعيل/انتظار الموقع | متاحة إن canNavigate=true |
| driver_location_stale | مخفيان | آخر origin معروف + وقت التسجيل إن موجود + الوجهة | متاحة إن canNavigate=true |
| driver_location_invalid | مخفيان | لا origin مزيف، الوجهة باقية | متاحة إن canNavigate=true |
| destination_location_missing | مخفيان | أصل صالح إن موجود، العنوان والبطاقات باقية | مخفية |
| directions_unavailable | مخفيان | الأصل والوجهة مع تنبيه عدم توفر الطريق | متاحة إن canNavigate=true |
| Completed | مخفيان | بطاقة مسلّمة ونقاط سليمة إن موجودة | مخفية |
| navigation=null | طبقة الملاحة مخفية | البطاقات والعناوين فقط؛ لا إحياء الطريق السابق | مخفية |
| unknown/malformed route | لا طريق ولا قياسات fabricated | بطاقات باقية + رسالة محلية عامة | لا تفتح إلا رابط سليم وcanNavigate=true والمحطة غير مسلّمة |

canNavigate هو مفتاح الزر وليس Ready؛ وجود وجهة لا يكفي لبناء رابط محلياً. `0` مسافة/مدة قيمة فعلية اعرضها؛ null يخفي السطر.

## 6. State وEvents وواجهات المكونات

الـ domain entities لا تستورد Flutter/LatLng/DTO/Dio. تحويل الإحداثيات إلى LatLng في presentation فقط.

### signatures أساسية

```dart
// ApiServices
@GET(EndPoints.driverMapRoute)
Future<DriverMapRouteResponseDto> getDriverMapRoute(
  @Query('focusedStopId') String? focusedStopId,
);

// RemoteDataSource
Future<DriverMapRouteResponseDto> getDriverMapRoute({String? focusedStopId});

// Repository + UseCase.call
Future<ApiResult<DriverMapRouteEntity>> getDriverMapRoute({String? focusedStopId});
Future<ApiResult<DriverMapRouteEntity>> call({String? focusedStopId});

// UI driver intent surface
Future<void> doIntent(DriverMapEvent event);
```

### State fields

```text
DriverMapRouteEntity? route
String? selectedStopId
DriverMapNavigationEntity? visibleNavigation
DriverLiveLocationSample? liveLocation
Failure? failure
bool isLoading = false
bool isRefreshing = false
bool isEmpty = false
bool isActive = false
bool isForeground = true
```

route يحتفظ بالبطاقات والرحلة المستلمة؛ UI الملاحة يقرأ visibleNavigation فقط. عند تغيير البطاقة امسح visibleNavigation فوراً؛ لا ترجع إلى route.navigation لأن ده ممكن يكون طريق العميل السابق. selectedStopId يعكس اختيار المستخدم قبل وصول الرد. لا تعرض tripCode القديم كأنه خاص بالبطاقة الجديدة أثناء التحميل.

copyWith يدعم clearRoute، clearSelectedStopId، clearVisibleNavigation، clearLiveLocation، clearFailure. عند رد navigation=null يجب مسح visibleNavigation فعلاً. lists immutable.

### Events

```dart
sealed class DriverMapEvent { const DriverMapEvent(); }
final class DriverMapActivated extends DriverMapEvent { const DriverMapActivated(); }
final class DriverMapDeactivated extends DriverMapEvent { const DriverMapDeactivated(); }
final class DriverMapAppResumed extends DriverMapEvent { const DriverMapAppResumed(); }
final class DriverMapAppPaused extends DriverMapEvent { const DriverMapAppPaused(); }
final class DriverMapRefreshRequested extends DriverMapEvent { const DriverMapRefreshRequested(); }
final class DriverMapRetryRequested extends DriverMapEvent { const DriverMapRetryRequested(); }
final class DriverMapStopSelected extends DriverMapEvent {
  const DriverMapStopSelected(this.stopId);
  final String stopId;
}
```

poll tick وGPS callbacks يستخدمان private handlers في ViewModel؛ لا API من widget. screen يرسل intents ويملك camera/PageController فقط.

### واجهة tracking المطلوبة

أضف إلى coordinator الحالي، مع الحفاظ على الاستخدامات القديمة:

```dart
DriverLiveLocationSample? get latestLocation;
Stream<DriverLiveLocationSample> get positions;
DriverLiveLocationSample? get lastSuccessfullySentLocation;
Future<bool> sendCurrentLocationNow();
```

DriverLiveLocationSample immutable: latitude, longitude, DateTime recordedAtUtc، double? heading. تمثل GPS fix ولا route origin. الـ bool من sendCurrentLocationNow = انتهت محاولة هذا الإرسال بنجاح/ACK حسب بروتوكول client الحالي؛ لا مجرد isStreaming.

positions تبث مع GPS fixes الصحيحة وليس كل route response. lastSuccessfullySentLocation يتغير بعد نجاح SignalR أو REST فقط. لا expose الـ controller ولا _sendTick للـ UI. لا تبدأ GPS subscription ثانية بالماب. عند عدم وجود عمل نشط لا تزوّر activeBoxCount لكي تنجح المحاولة.

## 7. Task 1 — دعم extensions.code في Core errors

**Files:** Modify `lib/core/errors/api_exception_mapper.dart`؛ Test `test/core/errors/api_exception_mapper_test.dart` (وسع الموجود إن وجد).

**Consumes:** ProblemDetails JSON.
**Produces:** `failure.exception.backendErrorCode` صحيح للحالتين؛ ServerFailure.code يظل يمرره.

- [ ] أضف اختبار response 404 بنفس title/detail العامين وبـ extensions.code=DriverMap.StopNotFound؛ assert backendErrorCode مطابق.
- [ ] أضف اختبار DriverTrip.NotFound واختبار root code القديم وextensions ليست Map.
- [ ] شغل الاختبارات وتأكد أن nested code case يفشل قبل التعديل.
- [ ] عدل `_extractBackendErrorCode` ليقرأ extensions.code أولاً ثم يحافظ على fallback الجذر الحالي، مثل:

```dart
if (data is Map) {
  final extensions = data['extensions'];
  if (extensions is Map) {
    final code = extensions['code'];
    if (code is String && code.trim().isNotEmpty) return code.trim();
  }
  // Keep the existing root-level extraction loop after this block.
}
```

- [ ] اختبر عدم تحويل non-map/empty code لخطأ جديد وعدم تغيير status/message classification.
- [ ] شغل `flutter test test/core/errors/api_exception_mapper_test.dart`.
- [ ] راجع diff؛ لو تستخدم commits اجمع فقط الملفات المرتبطة بعنوان `fix: preserve nested backend problem codes`.

## 8. Task 2 — DTOs وDomain وMapper

**Files:** DTOs/entities/mapper من جدول الملفات + modify existing stop entity.
**Tests:** `test/features/driver/map/data/driver_map_dto_mapper_test.dart`؛ fixtures تحت `test/features/driver/map/fixtures/`.

**Produces:** root entity مع navigation nullable، stop coordinates nullable، الحقول السيرفرية الجديدة.

- [ ] أنشئ fixtures ready/unavailable/completed/navigation_null من العقد. مثال polyline في العقد توضيحي وخارج الكويت؛ لا تعتمد عليه كاختبار رسم حقيقي بالكويت. استخدم مسار synthetic محلي سليم لاختبارات algorithm فقط، وsmoke الحقيقي من الباك بعد النشر.
- [ ] اكتب assertions للحفاظ على ترتيب بطاقتين من رحلتين، badge نصي، InTransit mapping، الهاتف متجاهل، unknown status، إحداثيات null، 0 distance، timestamps UTC وnavigation null.
- [ ] شغل الاختبار وافحص فشل يثبت عدم وجود الربط قبل التنفيذ.
- [ ] أنشئ @JsonSerializable DTOs بالحقول المذكورة، وentities مستقلة عن Flutter وmapper defensive.
- [ ] مثال mapper لحالة status:

```dart
DriverDeliveryStatus mapDriverMapStopStatus(String? value) => switch (value) {
  'InTransit' => DriverDeliveryStatus.inProgress,
  'Pending' => DriverDeliveryStatus.pending,
  'Delivered' => DriverDeliveryStatus.delivered,
  _ => DriverDeliveryStatus.unknown,
};
```

- [ ] حافظ على API compatibility لـ entity قدر الإمكان بإضافة defaults مناسبة للحقول الجديدة؛ ابحث عن كل constructor usage في lib/test قبل تغييره.
- [ ] لا تضف imageAsset إلى response DTO ولا تخترع server fields.
- [ ] شغل build_runner ثم اختبار DTO/mapper. راجع generated diff.

## 9. Task 3 — endpoint وطبقات Clean Architecture وDI

**Files:** network constants/services، map remote/repo/usecase، di.dart.
**Tests:** `test/features/driver/map/data/driver_map_remote_data_source_test.dart` و`driver_map_repository_test.dart`.

- [ ] اكتب اختبار intercepts Dio adapter request: method GET، المسار `/api/v1/driver/map/route`، focusedStopId absent عند null وموجود عند الاختيار، لا driverId/body/lat/lng.
- [ ] اختبار Repository success يعيد ApiSuccessResult<Entity>، و404 nested code يعيد ApiErrorResult<...> ويحافظ على typed Failure.
- [ ] أضف `EndPoints.driverMapRoute = '/api/v1/driver/map/route'` وRetrofit signature المذكورة.
- [ ] remote implementation يفوض فقط إلى `_apiServices.getDriverMapRoute(focusedStopId)`.
- [ ] repository يستخدم safeApiCall مرة واحدة:

```dart
return safeApiCall(() async {
  final dto = await _remoteDataSource.getDriverMapRoute(
    focusedStopId: focusedStopId,
  );
  return dto.toEntity();
});
```

- [ ] UseCase يفوض إلى Repository، لا mapping/UI logic فيه.
- [ ] annotations: @Injectable(as: DriverMapRemoteDataSource)، @LazySingleton(as: DriverMapRepository)، @injectable usecase/viewmodel.
- [ ] سجل remote/repo lazySingleton وusecase/viewmodel factory في configureDependencies بالأسلوب الفعلي الحالي. لا تستدعي injectable init إضافي يجعل registration مكرر.
- [ ] استخدم shared ApiServices/shared Dio؛ headers/401 handled بواسطة interceptors الموجودة.
- [ ] أعد التوليد وشغل الاختبارات. تأكد طلب 404 العام من endpoint غير منشور لا يتحول تلقائياً إلى empty؛ فقط DriverTrip.NotFound الصحيح يفعل ذلك.

## 10. Task 4 — واجهة مراقبة tracking وإرسال الموقع الأول

**Files:** tracking coordinator وlive sample entity.
**Tests:** `test/features/driver/tracking/driver_live_location_coordinator_test.dart`.

**Consumes:** DriverLocationService + DriverOrdersRealtimeClient + REST fallback الموجودة.
**Produces:** positions/latestLocation/lastSuccessfullySentLocation/sendCurrentLocationNow.

- [ ] اختبارات بfake services لنجاح SignalR، SignalR failure ثم REST success، فشل الاثنين، no permission/no GPS، عدم وجود active work.
- [ ] اختبر أن محاولتين متزامنتين تنتظران نفس in-flight send ولا تنشئان بثين أو GPS subscriptions مزدوجة.
- [ ] حول مسار tick الداخلي ليعيد نتيجة إرسال قابلة للانتظار. احتفظ بالـ future الجاري بدلاً من اعتبار `_isSending` نتيجة نجاح.
- [ ] sendCurrentLocationNow يتحقق من سياسة العمل الحالية؛ إن كان tracking بدأ، يطلب tick فوري أو ينتظر الجاري. إذا احتاج startTracking، تجنب إرسال tick ثاني زائد بعد أول tick الذي يجريه startTracking بالفعل.
- [ ] انشر GPS sample على positions عند كل fix صحيح، وأضف آخر نجاح فقط بعد اكتمال transport الحالي بلا exception/رد فشل معروف. لا تعتبر map=null ACK failure تلقائياً؛ client الحالي يسمح null للـ invoke الناجح، فحافظ على بروتوكوله.
- [ ] حافظ على stopTracking لأسباب tracking_not_required، وعدم تعديل business rules للـ active boxes أو lifecycle الشامل خارج الضرورة.
- [ ] إضافة stream controller قابلة للغلق في coordinator.dispose فقط؛ الماب لا يملك singleton ولا يغلقه.
- [ ] شغل tracking tests وتأكد استمرار loop القديم بفاصل 4 ثوانٍ.

**فتح الماب بدون قدرة بث:** حاول أول إرسال ولكن لا تترك skeleton معلّقاً على GPS indefinitely. اجعل انتظار bootstrap محدوداً بفترة 5 ثوانٍ كحد انتظار للصفحة، ثم اطلب route أياً كانت نتيجة الموقع لتظهر البطاقات والتنبيه. حد انتظار الصفحة لا يلغي shared broadcaster؛ بعده التحديث التالي خلال 30 ثانية يلتقط نجاح البث. هذه معالجة محلية للـ bootstrap وليست تعديلًا في endpoint.

## 11. Task 5 — State وViewModel وتزامن الطلبات

**Files:** الثلاثة manager files.
**Tests:** `test/features/driver/map/presentation/driver_map_view_model_test.dart`.

**Constructor dependencies:** GetDriverMapRouteUseCase وDriverLiveLocationCoordinator؛ polling interval default 30 seconds وbootstrap wait limit 5 seconds، يمكن حقن قيم قصيرة/clock fake للاختبار. لا GetIt داخل Cubit.

### سياسة request freshness

private int `_requestGeneration`، bool `_closed` أو isClosed، bool `_foreground`، bool `_active`، Timer? `_pollTimer`. إنشاء أي طلب مقصود جديد يزيد generation؛ deactivation/pause/close تزيده أيضاً لرفض الرد الجاري. لا اعتماد على stopId وحده لأنه لا يمنع A→B→A race.

```dart
final requestGeneration = ++_requestGeneration;
final requestedStopId = state.selectedStopId;
final result = await _getDriverMapRouteUseCase(
  focusedStopId: requestedStopId,
);
if (isClosed || !_active || !_foreground ||
    requestGeneration != _requestGeneration) return;
// Handle current result only.
```

الطلب الأول selection=null؛ السيرفر يختار. بعد نجاح الرد ثبت selectedStopId على البطاقة السيرفرية. لو navigation.destinationStopId لا يطابق selectedStopId لا ترسمه ولا تفعّل ملاحة العميل الخطأ؛ البطاقات السليمة ممكن تبقى.

### خطوات التنفيذ

- [ ] اكتب tests باستخدام Repository fake/usecase حقيقي وCompleter لاستجابات مرتبة عكسياً، دون mocking تفاصيل Cubit الداخلية.
- [ ] نفذ immutable State بالحقول وclear flags المحددة؛ اختبر null clearing.
- [ ] doIntent dispatch → private handlers. activation idempotent: لا مؤقتين ولا bootstrap مكرر.
- [ ] أول activation: skeleton لو بلا route، انتظار محاولة إرسال الموقع المحدودة، GET بدون focus إن أول فتح، ثم تشغيل polling إذا الصفحة ما زالت فعالة.
- [ ] tab activation بعد الرجوع: تحديث فوراً ثم مؤقت واحد. retain cards السابقة، وامسح الطريق/القياسات/رابط الملاحة السابق حتى رد حديث عند العودة لتجنب عرض snapshot قديم كأنه حي.
- [ ] polling: تحديث كل 30 ثانية فقط إذا active + foreground. إذا يوجد refresh جارٍ لا تراكم poll requests؛ تخطى tick أو coalesce واحد. selection request يستبدل منطقيًا الطلب الجاري فوراً ويزيد generation.
- [ ] اختيار stop جديد موجود: selectedStopId جديد، clearVisibleNavigation=true، isRefreshing=true، failure cleared، ثم GET فوراً. اختيار نفس stop لا يكرر الطلب.
- [ ] لا تنتظر طلب العميل السابق كي تبدأ العميل الجديد؛ ارفض نتيجته القديمة بالgeneration. cancellation transport اختيارية، ليست شرطاً ولا تضف Dio إلى domain من أجلها.
- [ ] أثناء refresh دوري لنفس المحطة يمكن الاحتفاظ بالطريق الأخير أثناء انتظار الرد، لكن عند فشل هذا التحديث امسح الملاحة والقياسات والرابط لتجنب أرقام قديمة، مع بقاء البطاقات وinline error.
- [ ] success: route/data جديدة؛ selection يرتبط بـ focusedStop الصحيح؛ visibleNavigation فقط للوجهة المطابقة. routeCompleted/null/unavailable تمسح الطريق السابق.
- [ ] 404 DriverTrip.NotFound: امسح route والملاحة والاختيار والفشل، isEmpty=true، وأبق polling أثناء الظهور كي تظهر assignments جديدة.
- [ ] 404 DriverMap.StopNotFound: fallback GET واحد بدون focusedStopId ضمن نفس عملية الطلب الحالية؛ invalidate previous navigation فوراً. لو المستخدم غير البطاقة أثناء fallback ارفض الرد. لا recursive retry بلا حد.
- [ ] 404 errors.common.not_found أو 404 بلا code: typed failure عادي، لا empty ولا StopNotFound fallback.
- [ ] 401: shared interceptor بالفعل يعيد الطلب مرة؛ لا تعيد refresh يدويًا. لو وصل 401 بعده استخدم Failure/session behavior العام.
- [ ] 5xx/timeout/no network: failure مخزنة؛ cards باقية إن موجودة؛ لا full-screen replacement عند وجود بطاقات.
- [ ] GPS positions: تحديث liveLocation فقط، لا GET لكل sample ولا تغيير navigation.origin snapshot. منع نفس قيم الموقع من rebuild عام لكل الشاشة بواسطة BlocSelector.
- [ ] close/deactivate/pause: إلغاء poll timer فوراً + invalidation؛ subscriptions المحلية cleanup بلا إيقاف singleton tracking.
- [ ] شغل manager tests بعد كل مجموعة سلوك.

### حالات tests الأساسية

1. بلا focus أولاً ثم تثبيت اختيار السيرفر وإن كان index غير صفر.
2. select B يرسل stopId B ويمسح الملاحة فوراً مع بقاء cards.
3. A slow → B fast ثم وصول A لا يغيّر state.
4. A→B→A: رد A الأول لا يقبل رغم تطابق stopId.
5. 404 StopNotFound يعمل fallback واحد بلا focus؛ fallback ثانٍ فاشل لا loop.
6. 404 TripNotFound يصبح empty؛ generic 404 يبقى failure.
7. nav=null/Completed بعد Ready لا يحتفظ بالطريق ولا الزر.
8. GPS ticks تحرك الموقع دون زيادة عدد GET.
9. polling عند الثانية 30، لا polling في inactive/background/after close.
10. slow refresh لا يولد polling backlog.
11. mismatch destinationStopId لا يعرض طريق أو رابط.
12. إغلاق أثناء bootstrap/GET لا emit بعد close.

## 12. Task 6 — decoder، camera، markers والملاحة

**Files:** decoder/camera/launcher الجديدة + driver_map_background.dart.
**Tests:** `test/features/driver/map/presentation/driver_map_polyline_decoder_test.dart`، `driver_map_camera_controller_test.dart`، `driver_map_navigation_launcher_test.dart`.

- [ ] افحص pubspec.lock والمكتبات الحالية لـ local polyline5 decoder. parser dispatcher الحالي ليس دليلاً إنه Google encoded polyline؛ لا تعيد استخدام parser تنسيق مختلف.
- [ ] عند الحاجة اختر package محلية متوافقة مع SDK وتحقق من توثيقها الرسمي وقت التنفيذ. استخدم local decode فقط؛ لا networking، لا API key، لا route fetching method.
- [ ] adapter interface: `List<LatLng> decode(String encodedPolyline)`؛ catches malformed decode ويرجع []، ويستخدم فقط عندما Ready + encoding google_polyline5 + nonempty string.
- [ ] اختبار معيار معروف `_p~iF~ps|U_ulLnnqC_mqNvxq\u0060@` ينتج (38.5,-120.2)، (40.7,-120.95)، (43.252,-126.453) بدقة 1e-5. هذه نقاط algorithm test فقط لا render بالكويت.
- [ ] malformed/empty/unknown encoding لا crash ولا خط بديل مستقيم. لا ترفض route algorithm نفسه لأنه خارج الكويت في fixture؛ صلاحية رسم endpoints في التطبيق منفصلة.
- [ ] الكاميرا تجمع decoded route + origin + destination الصالحة. empty: neutral Kuwait viewport **للعرض فقط** بلا fake marker/data؛ single point: zoom معقول؛ duplicate points: لا zero-size bounds exception؛ multiple points: fitBounds.
- [ ] حساب bounds محلياً بدون استدعاء provider. تطبيق padding يحترم ارتفاع البطاقات/الكاروسيل/SafeArea، ويمرر إعادة fit بعد map created/layout جاهز.
- [ ] fit عند رد route جديد/اختيار وجهة، لا عند كل GPS tick. recenter يصوب على liveLocation إذا صالحة وحديثة، وإلا origin المعروف مع التسمية المناسبة، وإلا bounds/viewport.
- [ ] marker liveDriver مستقل عن marker routeOrigin؛ مع heading صالح تدور أيقونة اتجاه إن مستخدمة، ولاتعتبر default pin اتجاهي إن مش اتجاهي.
- [ ] لا تعتبر cached liveLocation حية للأبد: عند انقطاع GPS اعرض وقت آخر fix، وعند تجاوز 120 ثانية لا تعرضها كـ «موقعك الحالي». recordedAtUtc المحلي يصف fix الجهاز فقط؛ تصنيف navigation.origin وقرار الطريق يظلان من السيرفر. لا تستخدم local freshness لإعادة حساب المسافة أو الطريق.
- [ ] origin.isStale أو source shift_start يعرض «آخر موقع معروف» وrecordedAtUtc إن موجود؛ لا time مخترع لبداية الشفت.
- [ ] stop markers فقط عند إحداثيات صالحة موجودة؛ destination من navigation لا من sample. باقي stops قابلة للنقر لاختيار بطاقتها.
- [ ] GoogleMap myLocation layer لا ينشئ marker إضافي يختلط بالmarker الذي نديره؛ حافظ على settings الملائمة للتصميم.
- [ ] transitions سلسة وخفيفة للmarker، بدون camera animation على كل tick؛ don't rebuild all cards كل sample.
- [ ] launcher يفتح Uri.parse للرابط السيرفري كما هو بـ LaunchMode.externalApplication. لا template ولا query rewriting، ومنع launch لو selected id لا يطابق navigation id أو canNavigate=false أو Completed.
- [ ] إذا launchUrl أعاد false أو exception اعرض feedback محلي متوافق مع الـ UI الحالي؛ لا crash ولا fake API failure ولا إعادة بناء الرابط.
- [ ] tests تؤكد نفس URL حرفياً بما فيه percent encoding، وcanNavigate=true مع Unavailable ما زال يتيح الملاحة.

## 13. Task 7 — UI وربط شاشة الماب والـ shimmer

**Files:** driver_map_screen.dart، background، stop/active order/carousel widgets، shimmer/navigation panel، arb files.
**Tests:** `test/features/driver/map/presentation/driver_map_screen_test.dart` و`driver_map_shimmer_test.dart`.

- [ ] widget tests بحقن ViewModel/camera/launcher وmap test double أو MapsPlatform fake؛ لا platform Google Maps channel حقيقي في unit/widget tests.
- [ ] أزل fallback الإنتاجي إلى DriverMapFakeDataSource؛ عينات الاختبارات تبقى في test fixtures. constructor initialStops/initialRoutePoints لا يستبدل API في runtime؛ راجع كل usages قبل إزالته أو تحويله إلى injected test seam واضح.
- [ ] screen يحصل على ViewModel عبر GetIt عند عدم حقنه، owns instance ويغلق ما يملكه فقط. BlocProvider.value للinjected instances، lifecycle ownership واضحة.
- [ ] PageController لا يبنى على fake count. عند أول نجاح اضبط البطاقة على selectedStopId القادم؛ مع كل reload حافظ على الاختيار بالID لا index.
- [ ] إذا عدد/ترتيب المحطات تغير، أعد حساب modulo/target page بأمان. zero stops لا `%0` ولا index error؛ one stop بلا prev/next غير مفيدين.
- [ ] UI البداية: DriverMapShimmer بنفس مواقع وحجوم البطاقة العلوية والكروت السفلية، وخلفية محايدة. لا CircularProgressIndicator بديل عن shimmer المطلوب.
- [ ] reuse Core ShimmerWidget للأشكال، وأضف shimmer animated overlay محلي باستخدام ShaderMask/AnimationController في driver_map_shimmer.dart؛ لا dependency shimmer جديدة ولا تغيير Core loaders كلها. احترم reduce-motion/disableAnimations وTickerMode.
- [ ] أول تحميل فقط full skeleton؛ selection/refresh يحافظ على cards ويعرض shimmer صغير مكان قياسات الملاحة/زرها أثناء انتظار الرد، بلا flash لشاشة كاملة ولا أسماء تجريبية.
- [ ] رندر الحالات بهذا الترتيب:

```text
isLoading && route == null → DriverMapShimmer
failure != null && لا بطاقات قابلة للعرض → ApiErrorWidget.fromTypedFailure
isEmpty أو نجاح stops فارغة → EmptyStateWidget
بطاقات موجودة → content
  + failure إن موجود → InlineApiErrorWidget في مساحة لا تغطي controls
  + unavailableReason → تنبيه أعمال مترجم، وليس ApiErrorWidget
```

- [ ] retry يرسل DriverMapRetryRequested ويعيد العملية المطلوبة للبطاقة الحالية فقط؛ لا refresh global home/orders.
- [ ] statusText/statusColor/sequenceBadge من Entity؛ أزل `sequenceNumber==1` كشرط status؛ لا تغيير layout الكارت.
- [ ] navigation panel يعرض distanceMeters/1000، durationSeconds/60 بصياغة عربية/إنجليزية صحيحة، estimatedArrivalAtUtc.toLocal مع «الوصول التقديري». 0 يبقى 0 وnull يخفي السطر.
- [ ] canNavigate=false: **إخفاء** زر الملاحة، بما في ذلك address-arrow لو هو trigger الحالي، مع استمرار عرض نص العنوان الكامل.
- [ ] لا customerPhone في Text/semantics/tooltip/infoWindow ولا call callbacks فعالين. @Deprecated callbacks يمكن إبقاؤها للتوافق دون استدعاء.
- [ ] أضف localization keys للأسباب الخمسة، no active deliveries، estimated arrival، last known location، navigation action، launch failure، refreshing عند الحاجة. لا hardcoded UI strings.
- [ ] اختبر Arabic RTL وEnglish، أسماء وعناوين طويلة، شاشة صغيرة، text scale كبير، الوضعين في الثيم الحالي، tap targets وlabels للـ recenter/navigation/carousel.
- [ ] استخدم BlocSelector لعزل map/liveLocation عن بناء البطاقات، وBlocListener فقط لتأثيرات موجودة فعلاً مثل camera fit، لا آلية أخطاء جديدة بلا داعٍ.
- [ ] لا success snackbar على كل refresh ولا GPS tick.
- [ ] شغل `flutter gen-l10n` ثم widget tests.

## 14. Task 8 — tab visibility وapp lifecycle وroute visibility

**Files:** app_shell_screen.dart، driver_map_screen.dart، routing_generator.dart إذا احتاج wiring.
**Tests:** `test/features/driver/map/presentation/driver_map_visibility_test.dart`.

- [ ] أضف `bool isActive = true` لـ DriverMapScreen.
- [ ] في default driver pages استبدل `const DriverMapScreen()` بـ `DriverMapScreen(isActive: activeIndex == 2)`، على نفس نمط dispatcher map.
- [ ] init/didUpdateWidget يرسلان Activated/Deactivated عند transitions فقط؛ لا polling بمجرد كون widget mounted داخل IndexedStack.
- [ ] WidgetsBindingObserver يرسل pause عند inactive/paused/hidden حسب SDK الحالي؛ resume يتصرف فقط إن tab active والroute ظاهرة.
- [ ] route standalone يبدأ active افتراضياً ويغلق timer/subscriptions في dispose.
- [ ] إذا route أخرى تغطي الماب بينما tab active، استخدم RouteAware مع observer الموجود أو أضف scoped observer minimal. افحص navigation setup أولاً؛ لا global navigation refactor.
- [ ] effective visibility = tab active + foreground + route exposed. توحيد القرار يمنع duplicate resume loads بين didPopNext وapp resumed.
- [ ] ترك الماب يوقف **route polling فقط**؛ broadcaster لازم يكمل طالما عمل السائق نشط وفق policy الحالية.
- [ ] اختبر map→home→map: لا GET أثناء home، GET فوري واحد عند العودة، timer واحد؛ background→foreground: نفس النتيجة؛ covering route يخفي polling حتى الرجوع.
- [ ] إلغاء/تجاهل in-flight response بعد deactivation؛ لا mutation لحالة جديدة من رحلة غادرناها.

## 15. Task 9 — التحقق والتسليم

### أوامر التنفيذ

نفذ من جذر المشروع. أمر واحد في كل خطوة، واقرأ النتائج بدلاً من اعتبار توليد الملفات نجاحاً تلقائياً.

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter test test/core/errors/api_exception_mapper_test.dart
flutter test test/features/driver/tracking/driver_live_location_coordinator_test.dart
flutter test test/features/driver/map
flutter analyze
git diff --check
git status --short
```

شغل أيضاً اختبارات driver home/orders القائمة المرتبطة بـ coordinator/status parsing وapp shell إذا عدلت shared wiring. إن كانت هناك failures سابقة سجلها بدليل baseline؛ لا تقل إن كل الاختبارات نجحت إذا لم تنجح.

### قائمة القبول الوظيفية

- [ ] GET path/query الصحيحان؛ no driverId/location body؛ auth/language عبر Core.
- [ ] لا fake data في مسار production driver map.
- [ ] stops متعددة الرحلات بترتيب السيرفر والbadge الصحيح، والاختيار الأول سيرفري.
- [ ] Ready يرسم طريق encodedPolyline وحده، بلا routePolylineWaypoints polyline.
- [ ] مسار العميل القديم يختفي فور اختيار الجديد؛ race tests كلها ناجحة.
- [ ] Ready→Unavailable/Completed/null يمسح route والقياسات المطلوبة فعلياً.
- [ ] marker حي لا ينشئ GET مع كل fix، وorigin يبقى snapshot حتى الرد التالي.
- [ ] 30 ثانية فقط أثناء الظهور؛ لا مؤقت مستمر في hidden IndexedStack أو الخلفية.
- [ ] إرسال أول موقع يُنتظر عند الإمكان، وفشل GPS لا يمنع تحميل البطاقات.
- [ ] maps URL القادم كما هو، canNavigate=true يعمل حتى بدون طريق Ready، false يخفي الزر.
- [ ] Full API error وinline error وempty من lib/core/errors، unavailable ليس network failure.
- [ ] shimmer متحرك لأول تحميل؛ بطاقات ثابتة أثناء refresh/selection.
- [ ] لا أرقام هاتف أو زر اتصال مهما جاء في response.
- [ ] لا مفاتيح Directions ولا local distance/time calculations؛ الوحدة فقط تتحول محلياً.
- [ ] لا تعديلات يدوية في generated files ولا registrations مكررة.
- [ ] تطبيق localization/theme/accessibility لا يغير الهوية الحالية.

### Manual QA بعد إعلان نشر الباك

1. سائق صالح بلا رحلات: empty عبر DriverTrip.NotFound.
2. سائق برحلة فعلية وGPS حديث: تحقق أن الخط يتبع الشوارع، المسافة/المدة معقولتان والوجهة تخص العميل المختار.
3. إيقاف الموقع لأكثر من 120 ثانية: لا طريق، آخر موقع معروف، البطاقات باقية والملاحة الخارجية متاحة عند وجود الوجهة.
4. منع صلاحية الموقع قبل الفتح ثم السماح: البطاقات تظهر أولاً، والطريق يعود مع تحديث لاحق دون loop سريع.
5. اختيار محطة بلا إحداثيات: العنوان موجود والزر مخفي، بلا marker عند (0,0).
6. محطة مسلّمة: Completed، لا طريق ولا زر ملاحة.
7. تغيير البطاقات بسرعة ومع شبكة بطيئة: لا طريق عميل سابق ولا اختيار يرجع وحده.
8. ترك التاب دقيقة: route GET count لا يزيد؛ broadcaster مستمر وفق active work.
9. عودة التطبيق: تحديث واحد مباشر واستئناف 30 ثانية.
10. Google Maps launch على Android وiOS بنفس الرابط؛ لا تثبيت origin قديم.
11. فصل الشبكة مع cards موجودة: inline retry والبطاقات باقية؛ إعادة الشبكة تستعيد الطريق.
12. navigation=null mock: cards فقط بلا crash ولا طريق متبقٍ.
13. Accept-Language=en: statusText والlabels الإنجليزية تظهر من السيرفر.

### ما يظل مسؤولية الباك وليس blocker لتنفيذ كود الموبايل

- تأكيد نشر العقد على بيئة اختبار ثم production.
- تفعيل مزود الاتجاهات والفوترة والـ quota، وRoutes adapter إن legacy provider غير متاح.
- smoke test للprovider الفعلي؛ حالة directions_unavailable ليست دليلاً أن ربط الموبايل فاشل.
- أصل live-location streaming guide المشار إليه غير مرفق مستقلاً في هذه الخطة؛ لا تخترع ACK fields أو تغير البروتوكول القائم. إذا نجاح البث يتطلب حقلاً غير ظاهر في الكود الحالي فنسّق عقده مع الباك قبل افتراضه.

## 16. رسالة تنفيذ جاهزة لجيميناي

```text
نفذ خطة docs/superpowers/plans/2026-10-05-driver-delivery-map-integration.md كاملة بالتتابع.
اقرأ أولاً العقد المرتبط تحت docs/superpowers/specs/، وrules/rules_backend.md وlib/core/errors.
حافظ على تصميم صفحة الماب ومعمارية المشروع. استخدم Retrofit → RemoteDataSource → Repository
→ UseCase → ViewModel/Event/State → UI، وDTO → Mapper → Entity، وsafeApiCall/ApiResult.
الطريق يحسب على الباك، يتحدث كل 30 ثانية أثناء ظهور الصفحة فقط؛ GPS يتبث بالـ coordinator الحالي.
استخدم shimmer متحرك لأول تحميل؛ لا تخفي البطاقات عند التحديث أو فشل الملاحة.
لا تكتب local directions ولا fake fallback ولا Maps URL template ولا زر اتصال عميل.
انتبه إلى extensions.code وIndexedStack وlate responses وnavigation nullable وInTransit mapping.
نفذ اختبارات السلوك وأعد توليد الملفات ولا تعدل generated code يدوياً.
في النهاية سلّم الملفات المتغيرة ونتائج الأوامر وحالة اختبار السيرفر منفصلة عن mock tests.
لا تعتبر تنفيذ endpoint وحده اكتمالاً للربط.
```
