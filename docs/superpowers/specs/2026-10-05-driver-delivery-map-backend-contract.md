# Driver Delivery Map — Backend Contract Snapshot

نسخة من الدليل الذي أرسله المستخدم. حالة النشر المذكورة أدناه هي حالة المستند، وليست تحققًا حيًا من السيرفر.
توضيح معتمد من المستخدم: حساب الاتجاهات على الباك فقط؛ مفاتيح Maps SDK اللازمة لعرض الخريطة في الموبايل تظل كما هي.

صفحة خريطة توصيل السائق (شاشة 03.01) — الدليل التفصيلي الكامل لمبرمج الموبايل
التاريخ: 2026-10-05 (آخر تحديث لنفس اليوم) الفئة: تطبيق السائق (Flutter) الحالة: الباك إند مُنفّذ محليًا ومختبر بالاختبارات (unit + API contract خضراء)، ولم يُنشر على السيرفر العام بعد. لا تربط الشاشة في الإنتاج قبل الإعلان عن النشر. اختبار السموك على بيئة حقيقية بمحطة فعلية لم يُنفّذ بعد (انظر قسم 15). هذا الدليل هو المرجع الوحيد الكامل للربط: كل الحقول، كل الحالات، كل القرارات الواجهة، وقائمة فحص التسليم.

فهرس الدليل
الفكرة الأساسية وأربع قواعد ثابتة
الطلب: العنوان، الهيدرات، المعاملات
رموز الأخطاء (401 / 404) وأهم تحذير عن النصوص
قاموس الحقول الكامل للاستجابة
قاموس القيم السريع (كل القيم الممكنة في مكان واحد)
جدول الحالات + مصفوفة قرار الواجهة + مصفوفة الـ null
تسلسل الشاشة خطوة بخطوة (فتح، تحديث، تغيير بطاقة، عودة للتطبيق)
الرسم على الخريطة: فك الترميز، الـ camera، الـ markers، الوحدات
زر الملاحة الخارجي
مصفوفة الأخطاء وفشل الشبكة
أمثلة JSON كاملة (أمثلة توثيق فقط)
ممنوعات صارمة (اقرأها قبل البدء)
قائمة فحص QA قبل التسليم
ما لا يوجد في هذا العقد
جاهزية السيرفر والمطلوب قبل النشر
مراجع ذات صلة
1) الفكرة الأساسية وأربع قواعد ثابتة
طلب واحد يرجع كل بيانات الصفحة: بطاقات المحطات، موقع السائق الحالي، وجهة العميل المختار، ومسار شوارع حقيقي (من خدمة اتجاهات فعلية على السيرفر) مع المسافة والمدة ووقت وصول تقديري ورابط ملاحة خارجي.

بداية المسار = موقع السائق الحالي (أحدث نقطة تتبع سليمة على السيرفر)، ونهايته = العميل المختار فقط. السيرفر هو من يحسب المسار من مزود خرائط — الموبايل لا يحسب ولا يقدّر أي مسافة أو وقت.

القواعد الأربع التي تحكم كل قرار في الربط
لا مفتاح خرائط في الموبايل إطلاقًا. فك الـ polyline والرسم بمكتبة محلية، وزر الملاحة يفتح رابطًا جاهزًا من السيرفر كما هو.
رقم هاتف العميل غير موجود في هذه الصفحة مقصودًا. كل حقول customerPhone ترجع نصًا فارغًا دائمًا — لا تبنِ زر اتصال بالعميل، ولا تعرضه ولو ظهر نصًا.
الصفحة لا تسقط أبدًا بسبب عدم جاهزية المسار. الحالات غير الجاهزة ترجع HTTP 200 مع البطاقات والعنوان كاملة — تعرض اللي جاهز وتخفي اللي مش جاهز.
حقل routePolylineWaypoints القديم ليس طريقًا. هو نقاط محطات العملاء فقط (للتوافق مع النسخ القديمة). الطريق الحقيقي الوحيد هو navigation.encodedPolyline.
2) الطلب: العنوان، الهيدرات، المعاملات
الطلب الأساسي (أول فتح للشاشة)
GET /api/v1/driver/map/route
Authorization: Bearer <driver-token>
Accept-Language: ar
عند بطاقة مختارة (تغيير المحطة)
GET /api/v1/driver/map/route?focusedStopId=<stop-id>
الهيدرات
الهيدر	القيمة	الأثر
Authorization	Bearer <توكن السائق>	إجباري. بدون توكن = 401
Accept-Language	ar أو en	يحدد لغة الحقول المترجمة مسبقًا: statusText على البطاقات، origin.label («موقعك الحالي» / "Your location")، ووصف الوجهة عند غياب اسم العميل («وجهة التوصيل» / "Delivery destination")
المعاملات (query parameters)
المعامل	النوع	متى ترسله
focusedStopId	GUID	عند تغيير البطاقة المختارة فقط. بدونها السيرفر يختار تلقائيًا: أول محطة InTransit (PickedUp)، وإلا أول Pending، وإلا أول محطة
driverId	GUID	تطبيق السائق لا يرسله أبدًا — هوية السائق تأتي من التوكن. معامل موجود فقط لصلاحيات لوحات الإدارة
ملاحظات مهمة عن الطلب
لا تُرسل إحداثيات الجهاز في هذا الطلب. موقع الجهاز يُبث أصلًا بالطريقة الحالية (SignalR/REST) — انظر [دليل البث الحي](driver-live-location-streaming-api.md). السيرفر يقرأ أحدث نقطة تتبع مخزنة عنه لبناء المسار.
أولّد الطلب بعد أول بث موقع ناجح عند فتح الشاشة (تفصيل التسلسل في قسم 7). لو طلبت الخريطة قبل ما يوصل للسيرفر أي إصلاح موقع، ستحصل على driver_location_missing — وهذا طبيعي ومعالج في الحلقة.
لا تطلب المسار عند كل إرسال GPS (كل 3–5 ثوانٍ). إيقاع التحديث المطلوب منك في قسم 7.
نتيجة الطلب دائمًا لقطة لحظية: السيرفر يعيد استخدام مسار ناجح مخزّن لمدة 30 ثانية لنفس (السائق + المحطة + نفس الإحداثيات بالكامل). حركة السائق قد تولّد حسابًا جديدًا — لهذا لا يُعتمد على الـ cache وحده ولا يُستغرق بإيقاع أسرع من 30 ثانية.
3) رموز الأخطاء (401 / 404) — وأهم تحذير في الدليل كله
جميع الأخطاء تأتي بصيغة ProblemDetails:

{
  "title": "غير موجود",
  "status": 404,
  "extensions": { "code": "DriverMap.StopNotFound" }
}
⚠️ التحذير الأهم: افرّع على extensions.code فقط — لا تفرّع على نص title أو detail
رسائل أكواد الخريطة (DriverMap.StopNotFound وDriverTrip.NotFound) غير معرّفة في ملفات الترجمة حاليًا، لذا نص detail الذي سيصلك عام وموحد («تعذر إكمال الطلب. يرجى المحاولة مرة أخرى.») في كل الحالات — الكود في extensions.code هو المعرّف الثابت الوحيد اللي تقدر تبني عليه منطق الواجهة.

HTTP	extensions.code	السبب	المطلوب من الموبايل
401	— (بدون توكن/توكن منتهٍ)	غير مصدّق	مرّر لسيل تحديث التوكن المعتمد في التطبيق ثم أعد الطلب
404	DriverTrip.NotFound	لا توجد رحلات نشطة أو لا توجد محطات	اعرض حالة «لا توجد توصيلات نشطة» (empty state) — وليس خطأ
404	DriverMap.StopNotFound	focusedStopId المُرسل ليس من محطات هذا السائق النشطة (معرّف قديم، محطة أُلغيت، أو محطة سائق آخر)	تجاهل المعرّف المُرسل وأعد الطلب بدون focusedStopId ليرجع للاختيار التلقائي، ثم حدّث البطاقات
404	errors.common.not_found	التوكن ليس لحساب سائق (لا يوجد DriverProfile مرتبط)	نفس مسار الخطأ العام في التطبيق — ليس حالة صفحة خريطة
حالة «محطة مسلّمة» أو «مسار غير جاهز» ليست خطأ — ترجع 200 مع navigation بحالتها (قسم 6).
أخطاء 5xx وتعطل الشبكة: مصفوفة التعامل في قسم 10.
4) قاموس الحقول الكامل للاستجابة
4.1 الحقول العليا
الحقل	النوع	المعنى
tripId	GUID	معرّف رحلة المحطة المختارة (البطاقة الحالية) — قد يكون رحلة أقدم لو اخترت بطاقة منها. عند عدم الإرسال يطابق رحلة المحطة المختارة تلقائيًا
tripCode	نص	كود الرحلة نفسها (مثل "TRP-1256")
driverLatitude / driverLongitude	double؟	حقول توافق قديمة — أحدث نقطة تتبع أو بداية الشفت بدون أي تصنيف صلاحية. لا تستخدمها لتحديد بداية المسار؛ المصدر الصحيح هو navigation.origin
totalStopsCount	int	عدد كل المحطات عبر كل الرحلات النشطة
completedStopsCount	int	عدد المحطات المسلّمة منها
focusedStop	بطاقة	البطاقة المختارة — نسخة من عنصر داخل stops قيمته isCurrent = true
stops	مصفوفة بطاقات	كل المحطات عبر كل الرحلات النشطة، مرتبة: رحلات الأحدث أولًا ثم ترتيب المحطة داخل الرحلة — هذا ترتيب الكاروسيل، لا تغيّره محليًا
routePolylineWaypoints	مصفوفة نقاط	نقاط محطات فقط — ليس طريقًا. موجودة للتوافق؛ لا ترسمها كخط طريق (القاعدة 4)
navigation	كائن؟	حمولة الملاحة الكاملة (4.4). قد تكون null — انظر تحتها
4.2 بطاقة المحطة (عناصر stops وfocusedStop)
الحقل	النوع	المعنى
stopId	GUID	معرّف المحطة — هذا ما ترسله في focusedStopId
sequenceBadge	نص	نص الترتيب المعروض مثل "1/3" (موضعها/الإجمالي عبر كل الرحلات)
sequenceNumber	int	رقم التسلسل داخل الرحلة
boxCode	نص	كود الصندوق (مثل "#BX-1256")
customerName	نص	اسم العميل — قد يكون "" (لا تخترع اسمًا)
customerPhone	نص	دائمًا "" — القاعدة 2
addressShort	نص	اسم المنطقة فقط (مثل "السالمية")
fullAddress	نص	العنوان الكامل المخزّن، وإن غاب فاسم المنطقة كاحتياطي — لا يخترع السيرفر عنوانًا أبدًا
mealsCount	int	عدد الوجبات/الصناديق
mealsSummary	نص	ملخص مترجم للوجبات
deliveryTimeSlot	نص	فترة التسليم كما خُزنت (مثل "09:20 ص")
status	نص	القيمة الآلية: "Delivered" / "InTransit" / "Pending"
statusText	نص	الترجمة الجاهزة للعرض (مثل «خارج التوصيل») — تتغير مع Accept-Language
statusColor	نص	لغة التصميم: "gray" للمسلّم، "green" لقيد التوصيل، "orange" للمعلّق
isCurrent	bool	true لعنصر واحد فقط = البطاقة المختارة حاليًا
latitude / longitude	double؟	إحداثيات المحطة — قد تكون null (محطة بلا إحداثيات = لن تظهر وجهة على الخريطة ولا ملاحة لها)
4.3 عنصر نقطة الموقع (navigation.origin وnavigation.destination)
الحقل	النوع	المعنى
latitude / longitude	double	إحداثيات النقطة (مضمونة صحيحة داخل الكويت وقت البناء)
label	نص	ما يُعرض على الـ marker: للسائق «موقعك الحالي»، وللوجهة اسم العميل أو «وجهة التوصيل»
source	نص	"tracking" = نقطة تتبع حية، "shift_start" = إحداثيات بداية الشفت (ليست موقعًا حيًا أبدًا)، "trip_stop" = وجهة العميل (ثابتة على الوجهات فقط)
recordedAtUtc	تاريخ؟	وقت تسجيل النقطة — null لـ shift_start وللوجهات
isStale	bool	true = النقطة ليست حية (تتبع أقدم من 120 ثانية، أو بداية شفت) — اعرضها كـ «آخر موقع معروف» مع recordedAtUtc
heading	double؟	اتجاه الحركة بالدرجات من آخر بث — null لما لا يملكه
4.4 كائن navigation
الحقل	النوع	المعنى
destinationStopId	GUID؟	معرّف المحطة الوجهة = focusedStop.stopId. استخدمه للتحقق من حداثة الرد قبل الرسم (قسم 7.3)
origin	نقطة؟	بداية المسار — موقع السائق المصنّف (قد تكون null حسب الحالة)
destination	نقطة؟	وجهة العميل المختار (قد تكون null عند غياب إحداثياتها)
routeStatus	نص	"Ready" / "Unavailable" / "Completed"
unavailableReason	نص؟	سبب عدم الجاهزية — null في Ready وCompleted، وإحدى القيم في قسم 5 غير ذلك
encodedPolyline	نص؟	مسار شوارع حقيقي مشفّر بخوارزمية Google polyline5 — الطريق الوحيد
polylineEncoding	نص	ثابت "google_polyline5" دائمًا
distanceMeters	long؟	المسافة بالمتر (قد تكون 0 لرحلة بطول صفري — قيمة صحيحة)
durationSeconds	long؟	المدة بالثواني
estimatedArrivalAtUtc	تاريخ؟	وصول تقديري = calculatedAtUtc + durationSeconds. تقدير من مزود الطريق لحظة الحساب — ليس وعدًا ولا يعكس حركة مرور حية
calculatedAtUtc	تاريخ؟	وقت حساب المسار على السيرفر. مع الـ cache يأتي من وقت الحساب الأصلي ولا يُعاد توليده
googleMapsUrl	نص؟	رابط ملاحة جاهز للوجهة فقط (بدون تثبيت نقطة بداية) — افتحه كما هو
canNavigate	bool	هل يجوز فتح الملاحة الخارجية — هذا مفتاح إظهار/تعطيل الزر، وليس routeStatus
5) قاموس القيم السريع
الحقل	كل القيم الممكنة
navigation.routeStatus	Ready — Unavailable — Completed
navigation.unavailableReason	driver_location_missing — driver_location_stale — driver_location_invalid — destination_location_missing — directions_unavailable
navigation.origin.source	tracking — shift_start
navigation.destination.source	trip_stop (دائمًا)
navigation.polylineEncoding	google_polyline5 (ثابت)
stops[].status	Delivered — InTransit — Pending
stops[].statusColor	gray — green — orange
أكواد 404	DriverTrip.NotFound — DriverMap.StopNotFound — errors.common.not_found
6) جدول الحالات + مصفوفة قرار الواجهة
6.1 جدول الحالات (ماذا يرجع السيرفر)
الحالة التشغيلية	routeStatus	unavailableReason	أولوية التقييم
موقع حديث + وجهة سليمة + طريق فعلي من المزود	Ready	null	الأخيرة
لا توجد أي نقطة تتبع ولا شفت بإحداثيات	Unavailable	driver_location_missing	3
أحدث نقطة تتبع أقدم من 120 ثانية	Unavailable	driver_location_stale	4
لا تتبع لكن الشفت الحالي فيه إحداثيات بداية	Unavailable	driver_location_stale (وorigin.source = "shift_start" وisStale = true — حتى لو الشفت جديد)	4
الإحداثيات (0,0) أو خارج الكويت أو وقت التسجيل في المستقبل بأكثر من 30 ثانية	Unavailable	driver_location_invalid	3
المحطة المختارة بلا إحداثيات سليمة	Unavailable	destination_location_missing	2
المزود فشل / رجّع ردًا تقديريًا (fallback) / بيانات ناقصة	Unavailable	directions_unavailable	5
المحطة المختارة مسلّمة	Completed	null	1 (تعلو على كل شيء)
ترتيب أولوية التقييم على السيرفر: مسلّمة ← الوجهة ← الموقع ← الحداثة ← المزود. لو تحققت حالتان في نفس الوقت، unavailableReason يرجع الأعلى أولوية فقط.

6.2 مصفوفة الـ null (ماذا يكون null بالضبط في كل حالة)
الحالة	origin	destination	encodedPolyline + المسافة/المدة/الوصول/calculatedAtUtc	googleMapsUrl	canNavigate
Ready	موجودة حية	موجودة	قيم فعلية	موجود	true
driver_location_missing	null	موجودة	null	موجود	true
driver_location_stale (تتبع)	موجودة (isStale = true + recordedAtUtc)	موجودة	null	موجود	true
driver_location_stale (بداية شفت)	موجودة (source = "shift_start")	موجودة	null	موجود	true
driver_location_invalid	null	موجودة	null	موجود	true
destination_location_missing	موجودة إن كانت سليمة	null	null	null	false
directions_unavailable	موجودة	موجودة	null	موجود	true
Completed	موجودة إن كانت سليمة	موجودة إن كانت سليمة	null	null	false
القاعدة المستخلصة: canNavigate = true لعميل غير مسلّم له إحداثيات سليمة حتى لو الموقع مفقود أو المسار غير جاهز — تطبيق الخرائط الخارجي يحدد موقع الجهاز بنفسه. الوجهة null أو محطة مسلّمة = لا ملاحة.

6.3 مصفوفة قرار الواجهة (ماذا تعرض فعليًا)
الحالة	خريطة و markers	الطريق	البطاقة العلوية	الأزرار/الشريط
Ready	marker السائق من origin + marker العميل من destination	ارسم encodedPolyline مفكوكًا	طبيعية	زر الملاحة مفعّل + المسافة/المدة/الوصول التقديري ظاهرة
driver_location_missing	marker العميل فقط	لا	طبيعية	شريط/تنبيه «شغّل تحديد الموقع» + زر الملاحة مفعّل
driver_location_stale	marker السائق كـ «آخر موقع معروف» (شفاف/أيقونة مختلفة) + وقت recordedAtUtc	لا	طبيعية	تنبيه «الموقع قديم — تأكد من تشغيل GPS» + زر ملاحة مفعّل
driver_location_invalid	marker السائق فقط (لا موقع مرسوم)	لا	طبيعية	تنبيه عام + زر ملاحة مفعّل
destination_location_missing	marker السائق فقط	لا	طبيعية (العنوان ظاهر)	زر الملاحة مخفي أو معطّل
directions_unavailable	النقطتان	لا	طبيعية	زر ملاحة مفعّل؛ أخفِ المسافة/المدة (لا تعرض أصفارًا أو شرطات)
Completed	حسب المتاح	لا	بطاقة «تم التسليم» (statusText جاهزة)	لا زر ملاحة
قاعدة عامة: حالة navigation لا تمس البطاقات إطلاقًا — البطاقات والعنوان معروضان في كل الحالات.

7) تسلسل الشاشة خطوة بخطوة
7.1 عند فتح الشاشة
تأكد من تفعيل خدمة الموقع.
ابث موقع الجهاز فورًا بالطريقة الحالية (نفس بروتوكول دليل البث الحي — لا تغيير) ثم اطلب الخريطة. الترتيب مهم: السيرفر يقرأ آخر نقطة مخزنة، فالطلب قبل أول بث يعطي driver_location_missing طبيعيًا.
ارسم البطاقات من stops فورًا (هي جاهزة دائمًا)، ثم طبّق حالة navigation على طبقة الخريطة (قسم 6.3).
ابدأ مؤقت التحديث (7.2).
7.2 حلقة التحديث (30 ثانية)
أعد طلب الخريطة كل 30 ثانية — وأثناء ظهور الشاشة فقط. أوقف المؤقت تمامًا عند الخروج من الشاشة (dispose) وأعده عند الدخول.
محاولات أبسر من 30 ثانية لا فائدة منها: السيرفر يخزّن المسار الناجح 30 ثانية.
بث الموقع مستمر بمكانه كل 3–5 ثوانٍ أثناء وجود عمل نشط — لا تربط بين إيقاع البث وإيقاع طلب الخريطة إطلاقًا.
عودة التطبيق من الخلفية = عدّها فتح شاشة (اطلب فورًا ثم استأنف المؤقت).
7.3 عند تغيير البطاقة (أهم مسار)
أرسل فورًا: GET ...?focusedStopId=<stopId البطاقة الجديدة>.
أخفِ خط الطريق القديم لحظة الإرسال — لا تُبقه معروضًا ولو ثانية فوق وجهة جديدة.
البطاقات تبقى معروضة كما هي أثناء الانتظار (لا شاشة تحميل كاملة).
الردوص المتأخرة تُرمى: احتفظ بآخر focusedStopId أُرسل (أو عدّاد طلبات تصاعدي). أي رد يصل لا يطابقه — تجاهله كليًا حتى لو سليم. تحقق إضافي: navigation.destinationStopId يجب أن يساوي البطاقة الحالية قبل الرسم.
لاحظ أن tripId/tripCode في الرد قد يتغيّران لرحلة البطاقة المختارة (حتى لو رحلة أقدم) بينما stops تبقى مجمعة من كل الرحلات — هذا سلوك مقصود، لا تعتبره خطأ.
7.4 الحلقة مع حالة الموقع
لو رجع الطلب بـ driver_location_missing أو driver_location_stale:

اعرض التنبيه المناسب (قسم 6.3) — هذه ليست حالة خطأ.
بعد نجاح أول بث موقع تالٍ، أعد طلب الخريطة مرة واحدة (أو انتظر موعد الـ 30 ثانية القادم — كفاية).
لا تعيد الطلب بنفسك في حلقة ضيقة (retry سريع) — لا يحسّن شيئًا ويستهلك.
8) الرسم على الخريطة
8.1 فك encodedPolyline (google_polyline5)
الترميز هو خوارزمية Google Encoded Polyline بدقة 1e-5 (ترميز varint مع فرقيات دلتا بين النقاط) — نفس الترميز المعياري في خرائط Google.
استخدم حزمة فك جاهزة ومحافظة من مكتبة التطبيق — لا تكتب الفك يدويًا. الناتج قائمة إحداثيات (lat, lng) تمثل مسار الشوارع.
افكك فقط عندما routeStatus == "Ready" وencodedPolyline غير null. أي حالة أخرى = لا يوجد طريق يُفك أصلًا.
لا تعرض خطًا مستقيمًا بين origin وdestination كأنه طريق عند غياب الـ polyline — هذا تزييف بيانات. غياب الطريق يعني عدم رسمه.
8.2 الـ camera fit
السيرفر لا يرسل bounds — احسبها محليًا:

اجمع نقاط الـ polyline المفكوكة + origin + destination.
خذ أصغر مستطيل يحويهم كله.
أضف padding: مساحة أعلى للبطاقة العلوية (تقريبًا 25–35% من ارتفاع الشاشة حسب تصميمك) وأسفل لشريط الزر (15–20%). القيم استرشادية — اضبطها على التصميم النهائي.
أعد الحساب مع كل رد جديد فقط (ليس مع كل حركة marker).
8.3 الـ markers
marker الجهاز (المتحرك): حرّكه محليًا مع كل نقطة بث (كل 3–5 ثوانٍ) بسلاسة — لا يحتاج طلب خريطة. استخدم heading لتدوير أيقونة السائق إن كان موجودًا.
نقطة بداية الطريق (origin): ثابتة في مكانها حتى الرد القادم — لا تخلط بينها وبين marker الجهاز المتحرك. المسافة بينهما مؤشر طبيعي على مرور الوقت منذ آخر تحديث مسار.
marker الوجهة (destination): من destination.latitude/longitude مع label (اسم العميل أو «وجهة التوصيل»). النقر عليه يكفي لعرض بطاقة العنوان — لا يوجد أي اتصال منه.
destination/origin ليستا جزءًا من خط الطريق — marker منفصلان فوقه.
8.4 عرض الأرقام (تحويل الوحدات على الموبايل)
المسافة: distanceMeters بالمتر → اعرض كم (مثال: 5200 → «5.2 كم»).
المدة: durationSeconds بالثواني → اعرض دقائق (480 → «8 دقائق»).
estimatedArrivalAtUtc: وقت UTC — حوّله لتوقيت الجهاز للعرض، واعرضه كتقدير («الوصول التقديري») وليس كالتزام.
عند null في أي رقم: أخفِ السطر كله — لا تعرض «0 كم» أو «—» على أنه قياس.
9) زر الملاحة الخارجي
الشرط: canNavigate == true — وليس routeStatus == "Ready". موقّع بالجذر في قسم 6.2.
التنفيذ: افتح navigation.googleMapsUrl خارجيًا (url launcher خارج التطبيق) كما هو حرفيًا.
لا تعيد بناء الرابط ولا تعدّله ولا تخزّن قالبًا له في التطبيق — السيرفر بناه للوجهة الصحيحة بصيغة invariant، وأي بناء محلي يعرضك لفواصل عشرية عربية أو وجهة قديمة.
الرابط يفتح تطبيق خرائط Google (أندرويد/iOS/متصفح) في وضع الملاحة نحو الوجهة، وسيستخدم التطبيق موقع الجهاز كبداية تلقائيًا — لهذا السيرفر لا يثبّت origin قديمًا في الرابط.
عند canNavigate == false: أخفِ الزر (لا تعطّله فقط) في حالتي destination_location_missing وCompleted.
10) مصفوفة الأخطاء وفشل الشبكة
الحدث	ماذا تفعل
401	سيل تحديث التوكن المعتمد في التطبيق ثم إعادة الطلب مرة واحدة
404 DriverTrip.NotFound	empty state «لا توجد توصيلات نشطة» — لا رسالة خطأ حمراء
404 DriverMap.StopNotFound	أعد الطلب بدون focusedStopId وحدّث البطاقات من الرد
5xx / timeout / لا شبكة	أبقِ البطاقات الحالية معروضة + مؤشر retry (زر أو pull-to-refresh حسب التصميم)
في كل حالات الفشل أعلاه	لا تُبقِ خط الطريق القديم معروضًا إذا سبق أن غيّرت البطاقة — الطريق القديم لوجهة قديمة أخطر من غياب الطريق
navigation = null في رد 200	سيرفر أقدم من هذه الميزة: اعرض البطاقات والعناوين فقط، وأخفِ طبقة الملاحة بالكامل — لا تنهار
مبدأ عام: فشل طبقة الملاحة لا يمس أبدًا طبقة البطاقات، والعكس: تغيير البطاقة لا يلغي بيانات الموقع.

11) أمثلة JSON (أمثلة توثيق فقط)
⚠️ القيم التالية أمثلة توثيق فقط — مأخوذة من بيانات اختبارات محلية لتوضيح الشكل، وليست نداءً على السيرفر المنشور ولا بيانات إنتاج.

11.1 رد كامل بحالة Ready (بطاقتان من رحلتين)
{
  "tripId": "3f6b1c2e-1111-4a2b-9c3d-000000000001",
  "tripCode": "TRP-1256",
  "driverLatitude": 29.3375,
  "driverLongitude": 48.028,
  "totalStopsCount": 2,
  "completedStopsCount": 0,
  "focusedStop": {
    "stopId": "9a7c1d2e-3333-4a2b-9c3d-000000000003",
    "sequenceBadge": "1/2",
    "sequenceNumber": 1,
    "boxCode": "#BX-1256",
    "customerName": "محمد علي",
    "customerPhone": "",
    "addressShort": "السالمية",
    "fullAddress": "شارع الخليج، السالمية",
    "mealsCount": 3,
    "mealsSummary": "3 وجبات",
    "deliveryTimeSlot": "09:20 ص",
    "status": "InTransit",
    "statusText": "خارج التوصيل",
    "statusColor": "green",
    "isCurrent": true,
    "latitude": 29.338,
    "longitude": 48.023
  },
  "stops": [
    {
      "stopId": "9a7c1d2e-3333-4a2b-9c3d-000000000003",
      "sequenceBadge": "1/2",
      "sequenceNumber": 1,
      "boxCode": "#BX-1256",
      "customerName": "محمد علي",
      "customerPhone": "",
      "addressShort": "السالمية",
      "fullAddress": "شارع الخليج، السالمية",
      "mealsCount": 3,
      "mealsSummary": "3 وجبات",
      "deliveryTimeSlot": "09:20 ص",
      "status": "InTransit",
      "statusText": "خارج التوصيل",
      "statusColor": "green",
      "isCurrent": true,
      "latitude": 29.338,
      "longitude": 48.023
    },
    {
      "stopId": "4b2e5f6a-4444-4a2b-9c3d-000000000004",
      "sequenceBadge": "2/2",
      "sequenceNumber": 1,
      "boxCode": "#BX-4665",
      "customerName": "مهند أحمد",
      "customerPhone": "",
      "addressShort": "الروضة",
      "fullAddress": "الروضة",
      "mealsCount": 2,
      "mealsSummary": "وجبتان",
      "deliveryTimeSlot": "09:30-10:30 ص",
      "status": "Pending",
      "statusText": "في الطريق للعميل",
      "statusColor": "orange",
      "isCurrent": false,
      "latitude": 29.339,
      "longitude": 48.024
    }
  ],
  "routePolylineWaypoints": [
    { "latitude": 29.3375, "longitude": 48.028 },
    { "latitude": 29.338, "longitude": 48.023 },
    { "latitude": 29.339, "longitude": 48.024 }
  ],
  "navigation": {
    "destinationStopId": "9a7c1d2e-3333-4a2b-9c3d-000000000003",
    "origin": {
      "latitude": 29.3375,
      "longitude": 48.028,
      "label": "موقعك الحالي",
      "source": "tracking",
      "recordedAtUtc": "2026-10-05T07:59:50Z",
      "isStale": false,
      "heading": 90.0
    },
    "destination": {
      "latitude": 29.338,
      "longitude": 48.023,
      "label": "محمد علي",
      "source": "trip_stop",
      "recordedAtUtc": null,
      "isStale": false,
      "heading": null
    },
    "routeStatus": "Ready",
    "unavailableReason": null,
    "encodedPolyline": "_p~iF~ps|U_ulLnnqC",
    "polylineEncoding": "google_polyline5",
    "distanceMeters": 5200,
    "durationSeconds": 480,
    "estimatedArrivalAtUtc": "2026-10-05T08:08:00Z",
    "calculatedAtUtc": "2026-10-05T08:00:00Z",
    "googleMapsUrl": "https://www.google.com/maps/dir/?api=1&destination=29.338%2C48.023&travelmode=driving&dir_action=navigate",
    "canNavigate": true
  }
}
11.2 Unavailable بسبب تتبع قديم (الصفحة 200 والبطاقات كاملة)
{
  "navigation": {
    "destinationStopId": "9a7c1d2e-3333-4a2b-9c3d-000000000003",
    "origin": {
      "latitude": 29.3375,
      "longitude": 48.028,
      "label": "موقعك الحالي",
      "source": "tracking",
      "recordedAtUtc": "2026-10-05T07:55:00Z",
      "isStale": true,
      "heading": 90.0
    },
    "destination": {
      "latitude": 29.338,
      "longitude": 48.023,
      "label": "محمد علي",
      "source": "trip_stop",
      "recordedAtUtc": null,
      "isStale": false,
      "heading": null
    },
    "routeStatus": "Unavailable",
    "unavailableReason": "driver_location_stale",
    "encodedPolyline": null,
    "polylineEncoding": "google_polyline5",
    "distanceMeters": null,
    "durationSeconds": null,
    "estimatedArrivalAtUtc": null,
    "calculatedAtUtc": null,
    "googleMapsUrl": "https://www.google.com/maps/dir/?api=1&destination=29.338%2C48.023&travelmode=driving&dir_action=navigate",
    "canNavigate": true
  }
}
11.3 Unavailable ببداية شفت فقط (لا تتبع إطلاقًا)
{
  "navigation": {
    "destinationStopId": "9a7c1d2e-3333-4a2b-9c3d-000000000003",
    "origin": {
      "latitude": 29.3,
      "longitude": 48.0,
      "label": "موقعك الحالي",
      "source": "shift_start",
      "recordedAtUtc": null,
      "isStale": true,
      "heading": null
    },
    "destination": {
      "latitude": 29.338,
      "longitude": 48.023,
      "label": "وجهة التوصيل",
      "source": "trip_stop",
      "recordedAtUtc": null,
      "isStale": false,
      "heading": null
    },
    "routeStatus": "Unavailable",
    "unavailableReason": "driver_location_stale",
    "encodedPolyline": null,
    "polylineEncoding": "google_polyline5",
    "distanceMeters": null,
    "durationSeconds": null,
    "estimatedArrivalAtUtc": null,
    "calculatedAtUtc": null,
    "googleMapsUrl": "https://www.google.com/maps/dir/?api=1&destination=29.338%2C48.023&travelmode=driving&dir_action=navigate",
    "canNavigate": true
  }
}
11.4 Completed لمحطة مسلّمة
{
  "navigation": {
    "destinationStopId": "9a7c1d2e-3333-4a2b-9c3d-000000000003",
    "origin": {
      "latitude": 29.3375,
      "longitude": 48.028,
      "label": "موقعك الحالي",
      "source": "tracking",
      "recordedAtUtc": "2026-10-05T07:59:50Z",
      "isStale": false,
      "heading": 90.0
    },
    "destination": {
      "latitude": 29.338,
      "longitude": 48.023,
      "label": "محمد علي",
      "source": "trip_stop",
      "recordedAtUtc": null,
      "isStale": false,
      "heading": null
    },
    "routeStatus": "Completed",
    "unavailableReason": null,
    "encodedPolyline": null,
    "polylineEncoding": "google_polyline5",
    "distanceMeters": null,
    "durationSeconds": null,
    "estimatedArrivalAtUtc": null,
    "calculatedAtUtc": null,
    "googleMapsUrl": null,
    "canNavigate": false
  }
}
11.5 خطأ 404 لمعرّف محطة ليس من محطات السائق
{
  "title": "غير موجود",
  "status": 404,
  "extensions": { "code": "DriverMap.StopNotFound" }
}
تذكير: نص detail في هذه الحالة عام وليس وصفًا محددًا — القرار على extensions.code (قسم 3).

12) ممنوعات صارمة (اقرأها قبل البدء)
ممنوع رسم routePolylineWaypoints كخط طريق — هي نقاط محطات فقط.
ممنوع رسم خط مستقيم بين النقطتين واعتباره طريقًا عند غياب encodedPolyline.
ممنوع زر اتصال بالعميل من أي حقل في هذه الشاشة (customerPhone دائمًا فارغ).
ممنوع إرسال driverId من تطبيق السائق أو إرسال إحداثيات الجهاز في هذا الطلب.
ممنوع طلب الخريطة عند كل بث GPS (إيقاع الطلب: 30 ثانية وأحداث الشاشة فقط).
ممنوع إعادة بناء googleMapsUrl محليًا أو تعديله — يُفتح كما هو.
ممنوع تخزين مسار/مسافة/مدة محسوبة محليًا أو تثبيت قيم ثابتة — كل الأرقام من السيرفر.
ممنوع عرض رد خريطة قديم بعد تغيير البطاقة (تحقق من destinationStopId / آخر معرّف مُرسل).
ممنوع اعتبار shift_start موقعًا حيًا — source = "shift_start" معناه «آخر موقع معروف» دائمًا.
ممنوع التفرّع على نصوص رسائل الخطأ — التفرّع على extensions.code فقط.
13) قائمة فحص QA قبل تسليم الربط
نفّذ كل سيناريو وتأكد من النتيجة:

[ ] فتح الشاشة بدون توكن صالح → يمر بسيل تحديث التوكن ثم يعيد الطلب (401).
[ ] سائق بلا رحلات نشطة → 404 DriverTrip.NotFound → شاشة «لا توجد توصيلات نشطة» (ليست خطأ أحمر).
[ ] Ready: الطريق المفكوك يُرسم فوق الشوارع، والمسافة/المدة/الوصول صحيحة التحويل (م/ث → كم/دقيقة).
[ ] إيقاف خدمة الموقع والانتظار > 120 ثانية → يتحول إلى driver_location_stale مع «آخر موقع» ووقت التحديث، والطريق يختفي، والبطاقات باقية.
[ ] منع الموقع كليًا قبل الفتح → driver_location_missing مع تنبيه التشغيل، ثم يعمل تلقائيًا بعد أول بث ناجح.
[ ] بطاقة محطة مسلّمة → Completed، لا زر ملاحة، لا طريق.
[ ] تغيير البطاقة → focusedStopId يُرسل، tripId/tripCode يتحول لرحلة البطاقة، الطريق القديم يختفي فورًا، والبطاقات تبقى مجمعة من كل الرحلات.
[ ] رد بطيء يصل بعد تغيير البطاقة → يُتجاهل (لا يُرسم).
[ ] خروج من الشاشة → مؤقت الـ 30 ثانية يتوقف فعليًا (تحقق من عداد الطلبات في الـ log المحلي).
[ ] زر الملاحة يفتح خرائط Google بالوجهة الصحيحة على أندرويد وiOS (اختبر الاثنين).
[ ] لا يظهر أي رقم هاتف في أي حالة على الشاشة.
[ ] فصل الشبكة أثناء الطلب → البطاقات تبقى + retry، ولا طريق قديم معروض لوجهة جديدة.
[ ] رد navigation = null (محاكاة سيرفر قديم أو mock محلي) → الشاشة تعمل بالبطاقات فقط دون انهيار.
[ ] Accept-Language = en → statusText وorigin.label ووصف الوجهة بالإنجليزية.
14) ما لا يوجد في هذا العقد (حتى لا تبحث عنه)
لا زر اتصال بالعميل ولا أي أداة اتصال في بيانات هذه الصفحة.
لا bounds في الاستجابة — تُحسب محليًا من الـ polyline والنقطتين.
لا دعم حركة مرور حية — المدة تقدير من مزود الطريق وقت الحساب.
لا تعليمات انعطاف داخل التطبيق — الإرشاد الصوتي/خطوة-بخطوة من تطبيق الخرائط عبر زر الملاحة.
لا إرسال origin من الموبايل في هذا الطلب — السيرفر يستخدم أحدث نقطة تتبع بُثّت بالطريقة الحالية.
لا تحسين لترتيب رحلة كاملة متعددة المحطات — المسار دائمًا «السائق ← العميل المختار» فقط.
15) جاهزية السيرفر وما هو مطلوب قبل النشر
منفّذ ومختبر محليًا (اختبارات unit + API contract خضراء): كل الحالات أعلاه، فك/رسم polyline5 على الموبايل فقط، cache سيرفري 30 ثانية للطريق الناجح فقط، حماية المحطات الأجنبية (404)، وعدم كشف الهاتف.

مطلوب خارجيًا قبل إعلان الطريق الحقيقي (خارج الكود):

تفعيل Directions API على مشروع Google Cloud القائم المستخدم من السيرفر — الخدمة الحالية Legacy، والمشاريع الجديدة لا يمكنها تفعيلها؛ يجب التأكد من الـ console.
الفوترة (billing) مفعّلة على المشروع، ومفتاح server المقيد بـ IP السيرفر موجود (GOOGLE_MAPS_SERVER_API_KEY أو GoogleMaps:ApiKey) — لا يُكتب المفتاح في أي ملف موبايل أو مستند.
كفاية الـ quota لنداءات الاتجاهات (استهلاك متوقع: نداء لكل تغيير وجهة، مع cache 30 ثانية).
اختبار سموك على بيئة اختبار بسائق مسموح ومحطة فعلية: التحقق أن encodedPolyline يحتوي طريق شوارع حقيقيًا والمسافة/المدة معقولة — لم يُنفّذ بعد.
Blocker مسجّل: إذا تبيّن أن المشروع القائم لا يتيح Directions API (Legacy)، لن يظهر طريق شوارع حتى ترقية الـ adapter السيرفري إلى Routes API خلف نفس الواجهة الداخلية — مهمة منفصلة على السيرفر، ولا تحتاج أي تغيير في عقد الموبايل هذا. قبل ذلك سترى directions_unavailable مع عمل بقية الصفحة طبيعيًا.

توقيت النشر: بمجرد نشر هذا الباك إند على السيرفر العام سيعلن فريق الباك إند بذلك — صفحة الربط نفسها لا تتغير، فقط انقل رابط البيئة.

16) مراجع ذات صلة
[دليل البث الحي لموقع السائق](driver-live-location-streaming-api.md) — بث الموقع كل 3–5 ثوانٍ (خطوة 2 من تسلسل الشاشة).
[بيانات عنوان العميل في تطبيق السائق](driver-manifest-zone-vs-full-address.md) — اسم المنطقة مقابل العنوان الكامل، وسبب فراغ customerPhone.
