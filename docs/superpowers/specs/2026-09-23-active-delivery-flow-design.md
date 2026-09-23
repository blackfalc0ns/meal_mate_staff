# Active Delivery Flow Design Specification

**Feature:** `lib/features/driver/active_delivery/`  
**Status:** Approved  
**Author:** Pair Programming Agent & User  
**Date:** 2026-09-23  

---

## 1. Executive Summary & Goals

The Active Delivery feature provides a complete mobile flow for drivers on active meal-mate delivery runs:
1. Review initial route & start the run.
2. Track live delivery route with an interactive Google Map, customer details, and trip stages.
3. Manage delivery delay notification when running late.
4. Report failed deliveries with reasons.
5. Guide the driver to return the box to the restaurant after a failed delivery.
6. Confirm delivery success with order summary and navigate to next order or finish.

> [!IMPORTANT]
> **Strict Scope Rule:** The OTP screen (`07.02 - Delivery Confirmation (OTP)`, Figma node 2607:7203) is **explicitly cancelled**. No OTP screen or OTP verification logic shall be built. Confirming arrival directly moves to Delivery Success.

---

## 2. Dependencies & Map Streaming Strategy

### 2.1 Dependencies Inspection
- `google_maps_flutter: ^2.18.1` is **present** in `pubspec.yaml` and will be used for interactive map rendering.
- No GPS/Location packages (e.g. `geolocator`, `location`) are present.
- **Decision:** As required by `rules/ui_rules.md`, no new packages will be added without explicit consent. The driver's location stream is simulated in `ActiveDeliveryFakeRepositoryImpl` using a predefined sequence of coordinates along the route with periodic ticks.

### 2.2 Strict Rebuild & Map Isolation Architecture
To satisfy the strict rebuild rules:
- The screen Scaffold, AppBar, Customer Card, Order Details, Stepper, and Action Buttons are built as standard widgets.
- **Only** the custom map widget (`DriverTrackingMapView`) subscribes to the driver location Stream or coordinates.
- Moving the driver marker or camera updates is handled strictly inside `DriverTrackingMapView` (via `GoogleMapController`), preventing the rest of the screen from rebuilding during location stream updates.
- Timers/streams are properly paused/cancelled in `dispose()`.

---

## 3. Screen Breakdown & Figma Node Mappings

### 3.1 Screen 1: Start Delivery Route
- **File:** `lib/features/driver/active_delivery/presentation/screens/driver_start_delivery_route_screen.dart`
- **Figma Node:** `3038:10963`
- **Key Elements:**
  - Standard AppBar with title: `بدء مسار التوصيل` / Start Delivery Route.
  - Subtitle banner: `راجع بيانات الطلب وابدأ المسار`.
  - Initial Route Map view (showing driver pin, customer pin, polyline).
  - Customer & Order Details Card:
    - Customer Name (e.g. `عبدالله العتيبي`) and Avatar.
    - Box Code (e.g. `#BX-1256`).
    - Destination Address (e.g. `قطعة 6 ، شارع الخليج العربي ، برج الرؤية`).
    - ETA and Distance (e.g. `15 دقيقة • 4.2 كم`).
    - Meal count (e.g. `3 وجبات`).
    - Special Customer Note (e.g. `يرجى الاتصال قبل الوصول`).
  - Primary Action Button: `بدء مسار التوصيل` (Purple filled button) -> Navigates to `DriverActiveDeliveryTrackingScreen`.

### 3.2 Screen 2: Active Delivery Tracking
- **File:** `lib/features/driver/active_delivery/presentation/screens/driver_active_delivery_tracking_screen.dart`
- **Figma Node:** `2739:1613`
- **Key Elements:**
  - Interactive Google Map with live driver marker, route polyline, customer pin.
  - Quick action floating buttons on map: Center on Driver, Call Customer, Chat/Message Customer.
  - Trip Progress Stepper: `بدء المسار` (Done) -> `في الطريق` (Active) -> `تم الوصول`.
  - Customer Card with expandable order details & notes.
  - Action Triggers:
    - `تأكيد الوصول والتسليم` -> Navigates to `DriverDeliverySuccessScreen`.
    - `إبلاغ عن تأخير` (Delay button) -> Navigates to `DriverDeliveryDelayScreen`.
    - `تعذر التسليم` (Failed button) -> Navigates to `DriverFailedDeliveryScreen`.

### 3.3 Screen 3: Delivery Delay
- **File:** `lib/features/driver/active_delivery/presentation/screens/driver_delivery_delay_screen.dart`
- **Figma Node:** `1977:4969`
- **Key Elements:**
  - Header: `تأخير في التوصيل` / Delivery Delay.
  - 3D Clock illustration / visual banner.
  - Delay notification card with expected time vs current delay.
  - Actions:
    - `متابعة التوصيل` (Continue Delivery) -> Pops back to Active Tracking.
    - `الاتصال بالدعم` (Contact Support) -> Navigates to Driver Support.

### 3.4 Screen 4: Failed Delivery
- **File:** `lib/features/driver/active_delivery/presentation/screens/driver_failed_delivery_screen.dart`
- **Figma Node:** `1977:4999`
- **Key Elements:**
  - Header: `تعذر تسليم الطلب` / Failed Delivery.
  - Hero illustration with alert / failed pin.
  - Radio list or dropdown of failure reasons:
    - `العميل لا يجيب على الهاتف` (Customer not answering)
    - `العنوان غير صحيح أو غير واضح` (Incorrect address)
    - `العميل رفض استلام الطلب` (Customer rejected delivery)
    - `مشكلة في الصندوق أو الوجبة` (Box/Meal damaged)
    - `أخرى (مع كتابة ملاحظة)` (Other with note input)
  - Action Button: `إرسال البلاغ وإرجاع الصندوق` -> Navigates to `DriverReturnBoxToRestaurantScreen`.
  - Secondary Action: `إعادة المحاولة` (Retry) / `التواصل مع الدعم`.

### 3.5 Screen 5: Return Box to Restaurant
- **File:** `lib/features/driver/active_delivery/presentation/screens/driver_return_box_to_restaurant_screen.dart`
- **Figma Node:** `2090:4793`
- **Key Elements:**
  - Header: `إعادة الصندوق للمطعم` / Return Box to Restaurant.
  - Map view with route directed back to restaurant.
  - Box info card with status `لم يتم التسليم - جاري الإرجاع`.
  - Form summary: Selected failure reason, notes, optional attachment upload.
  - Primary Action Button: `تأكيد استلام المطعم للصندوق` (Confirm Restaurant Return) -> Completes return flow.

### 3.6 Screen 6: Delivery Success
- **File:** `lib/features/driver/active_delivery/presentation/screens/driver_delivery_success_screen.dart`
- **Figma Node:** `2293:15561`
- **Key Elements:**
  - Header: `تم تسليم الطلب بنجاح` / Delivery Success.
  - Hero celebration illustration / check badge.
  - Order delivery summary card:
    - Order/Box Number: `#MM-45829`
    - Customer Name: `عبدالله العتيبي`
    - Delivery Time: `02:30 م`
    - Payment Method: `مدفوع مسبقاً (KNET)`
  - Primary Action Button: `تم تأكيد الاستلام` (Receipt Confirmed) / `العودة للطلبات` -> Navigates to next order or `AppRoutes.driverAssignedBoxes`.

---

## 4. Architecture & Data Contracts

### 4.1 Domain Layer
- **Entities:**
  - `ActiveDeliveryTripEntity`: Full state of an active delivery (order, customer, location, status, timestamps).
  - `ActiveDeliveryOrderEntity`: Order details, customer name, phone, address, meals count, instructions.
  - `ActiveDeliveryLocationEntity`: Lat, Lng, bearing, simulated route points.
  - `DeliveryFailureReasonEntity`: Predefined failure reasons (id, title, description).
  - `ReturnBoxEntity`: Box code, restaurant name, restaurant location, failure report.
- **Repository Interface:**
  - `ActiveDeliveryRepository`:
    - `Future<ActiveDeliveryTripEntity> getActiveTrip();`
    - `Stream<LatLng> watchDriverLocation();`
    - `Future<void> startDeliveryRoute(String tripId);`
    - `Future<void> markArrivedAtCustomer(String tripId);`
    - `Future<void> reportDeliveryDelay(String tripId, String reason);`
    - `Future<void> reportDeliveryFailed(String tripId, String reasonId, String? note);`
    - `Future<void> confirmBoxReturnedToRestaurant(String tripId);`

### 4.2 Data Layer
- `ActiveDeliveryFakeData`: Structured static data, coordinates for Kuwait City routes, sample customer data.
- `AssetsFake`: Reference fake image paths cleanly per `rules/ui_rules.md`.
- `ActiveDeliveryFakeRepositoryImpl`: In-memory implementation of `ActiveDeliveryRepository`.

### 4.3 Presentation Layer
- `ActiveDeliveryViewModel`: Cubit managing `ActiveDeliveryState` (trip status transitions, actions).
- Isolated widgets: Each widget in its own file under `presentation/widgets/`.

---

## 5. UI Rules Compliance Checklist
- [x] Colors obtained only via `context.colorScheme` and semantic tokens. No `Colors.*` or hex codes in UI.
- [x] Text styles obtained only via `styles_manager.dart`. No new `TextStyle()` in widgets.
- [x] Spacing obtained only via `Spacing.*` constants.
- [x] User-facing strings localized in `app_en.arb` and `app_ar.arb`.
- [x] Layout direction follows inherited `Directionality` (no `languageCode == 'ar'` checks).
- [x] Every custom widget placed in its own separate file under `presentation/widgets/`.
- [x] Strict rebuild control: only map widget listens to location stream.
