# Design Specification: Driver Performance Screen

- **Date:** 2026-09-29
- **Feature:** Driver Performance Screen (`09.01 - Performance`)
- **Figma Source of Truth:** Frame `09.01 - Performance` (Node ID: `1460-4307`)
- **UI Guidelines:** `rules/ui_rules.md`
- **Location:** `lib/features/driver/driver_profile/`

---

## 1. Overview & Goal

The user requested the implementation of the Driver Performance screen from Figma frame `09.01 - Performance` (Node ID: `1460-4307`), part of the section `09 — Performance, Profile & Notifications`.

The screen provides drivers with daily and weekly metrics and performance insights:
1. **Header**: Centered MealMate logo, bold title "الأداء", calendar icon with formatted date ("السبت ، 24 مايو 2025"), and online status pill ("أنت متصل" with green dot).
2. **Period Toggle**: A segmented toggle switching between "اليوم" (Today) and "هذا الأسبوع" (This Week).
3. **Hero Dark Summary Card**: A dark navy surface containing 4 key metrics separated by subtle vertical dividers:
   - Total Orders ("إجمالي الطلبات"): `8` orders ("طلبات") with shopping bag icon.
   - On-Time Delivery Rate ("معدل الالتزام بالوقت"): `92%` on-time ("في الوقت") with clock icon.
   - Deliveries ("التسليمات / استلام يد بيد"): `8` deliveries ("تسليمات") with handshake icon.
   - Total Distance ("المسافة الكلية"): `32.4` km ("كم") with location pin icon.
4. **Section Title**: "نظرة عامة على الأداء" (Performance Overview).
5. **2x2 Performance Grid Cards**:
   - **On-Time Rate Card**: `92%`, trend `↑ 8% من أمس` (green), smooth area curve chart with gradient fill (0%–100%, 00:00–24:00).
   - **Deliveries Card**: `8`, trend `↑ 2 من أمس` (green), bar chart showing delivery distribution throughout the day (0–10, 00:00–24:00).
   - **Distance Card**: `32.4كم`, trend `↑ 0.9 كم من أمس` (green), smooth area curve chart with warm orange/amber gradient fill (0–40, 00:00–24:00).
   - **Working Hours Card**: `5:45`, trend `↑ 0:45 من أمس` (green), bar chart showing working hours distribution (0–6س, 00:00–24:00).
6. **Excellence / Motivation Banner**: Deep purple gradient banner with an award ribbon/badge icon, text ("أداء رائع اليوم! استمر بنفس التميز" / "أنت من أفضل السائقين هذا الأسبوع"), and white pill button ("عرض التفاصيل") with insights/chart icon.

---

## 2. Architecture & File Structure

Adhering strictly to `rules/ui_rules.md` (one widget class per file, clean separation, reuse existing widgets and tokens):

```text
lib/features/driver/driver_profile/
├── domain/
│   ├── entities/
│   │   ├── driver_performance_entity.dart
│   │   ├── driver_performance_metric_card_entity.dart
│   │   └── driver_performance_chart_point_entity.dart
│   └── fake_data/
│       └── driver_performance_fake_data.dart
└── presentation/
    ├── screens/
    │   └── driver_performance_screen.dart
    └── widgets/
        ├── driver_performance_header.dart
        ├── driver_performance_period_toggle.dart
        ├── driver_performance_summary_card.dart
        ├── driver_performance_summary_column.dart
        ├── driver_performance_section_title.dart
        ├── driver_performance_on_time_card.dart
        ├── driver_performance_deliveries_card.dart
        ├── driver_performance_distance_card.dart
        ├── driver_performance_working_hours_card.dart
        ├── driver_performance_line_chart.dart
        ├── driver_performance_bar_chart.dart
        └── driver_performance_excellence_banner.dart
```

---

## 3. Navigation & Routing

1. **Route Constant**:
   - `static const String driverPerformance = '/driver-performance';` in `lib/config/routing/app_routes.dart`.
2. **Routing Generator (`lib/config/routing/routing_generator.dart`)**:
   - `case AppRoutes.driverPerformance:` renders `DriverPerformanceScreen(performance: performance)`.
3. **Integration Point**:
   - Navigable from Driver Profile, Driver Settings, or App Shell as needed.

---

## 4. UI Components Detail & Design Tokens

### 4.1 Header (`driver_performance_header.dart`)
- **Logo**: MealMate logo centered (`AppAssets.authHeaderLogo`, height: 28).
- **Date & Title**:
  - Title: `locale.driverPerformanceTitle` ("الأداء") styled with `getBoldStyle(fontSize: FontSize.size20, color: color.onSurface)`.
  - Date row: Calendar icon (`Icons.calendar_today_outlined`, size: 14, color: `color.onSurfaceVariant`) + date string formatted via `locale` or entity with `getRegularStyle(fontSize: FontSize.size11, color: color.onSurfaceVariant)`.
- **Status Pill**:
  - Capsule container with `color.tertiaryContainer` background, rounded radius `Spacing.radiusXl`.
  - Inner green dot: 8x8 circle with `color.tertiary`.
  - Text: `locale.driverPerformanceOnlineStatus` ("أنت متصل") styled with `getMediumStyle(fontSize: FontSize.size11, color: color.tertiary)`.

### 4.2 Period Toggle (`driver_performance_period_toggle.dart`)
- Container with border `Border.all(color: color.outline.withValues(alpha: 0.5))` and rounded border radius `Spacing.radiusMd`.
- Two segmented tabs:
  - `locale.driverPerformanceToday` ("اليوم")
  - `locale.driverPerformanceThisWeek` ("هذا الأسبوع")
- Active tab: background `color.primary`, text `color.onPrimary`, `getMediumStyle(fontSize: FontSize.size13)`.
- Inactive tab: transparent background, text `color.primary`, `getMediumStyle(fontSize: FontSize.size13)`.
- State managed selectively (e.g. `ValueNotifier<bool>` or callback) to avoid full screen rebuilds.

### 4.3 Hero Dark Summary Card (`driver_performance_summary_card.dart`)
- **Background**: `color.inverseSurface` (Dark navy `#1B1540`).
- **Border radius**: `Spacing.cardRadius` (16px).
- **Padding**: `EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.md)`.
- **Content**: `Row` of 4 `Expanded` children with subtle vertical dividers between them (`Container(width: 1, height: 48, color: color.onInverseSurface.withValues(alpha: 0.15))`).

### 4.4 Summary Column (`driver_performance_summary_column.dart`)
- Label: `getRegularStyle(fontSize: FontSize.size10, color: color.onInverseSurface.withValues(alpha: 0.8))`
- Icon: centered with size 22, color `color.onInverseSurface`
- Value: `getBoldStyle(fontSize: FontSize.size18, color: color.onInverseSurface)`
- Unit: `getRegularStyle(fontSize: FontSize.size10, color: color.onInverseSurface.withValues(alpha: 0.8))`

### 4.5 Section Title (`driver_performance_section_title.dart`)
- Text: `locale.driverPerformanceOverview` ("نظرة عامة على الأداء")
- Style: `getBoldStyle(fontSize: FontSize.size15, color: color.onSurface)`
- Padding: `EdgeInsetsDirectional.only(start: Spacing.xs, bottom: Spacing.sm)`.

### 4.6 Performance 2x2 Grid Cards
Each card is built in its own file:
1. `DriverPerformanceOnTimeCard`:
   - Top: Header text `locale.driverPerformanceOnTimeRate` + Clock icon in circular badge.
   - Value: `92%` + Trend badge `↑ 8% من أمس` (green `color.tertiary`).
   - Chart: `DriverPerformanceLineChart` with purple gradient fill.
2. `DriverPerformanceDeliveriesCard`:
   - Top: Header text `locale.driverPerformanceDeliveries` + Handshake icon in circular badge.
   - Value: `8` + Trend badge `↑ 2 من أمس` (green `color.tertiary`).
   - Chart: `DriverPerformanceBarChart` with purple bars.
3. `DriverPerformanceDistanceCard`:
   - Top: Header text `locale.driverPerformanceTotalDistance` + Location pin icon in circular badge.
   - Value: `32.4كم` + Trend badge `↑ 0.9 كم من أمس` (green `color.tertiary`).
   - Chart: `DriverPerformanceLineChart` with orange/amber gradient fill.
4. `DriverPerformanceWorkingHoursCard`:
   - Top: Header text `locale.driverPerformanceWorkingHours` + Clock icon in circular badge.
   - Value: `5:45` + Trend badge `↑ 0:45 من أمس` (green `color.tertiary`).
   - Chart: `DriverPerformanceBarChart` with orange/amber bars.

### 4.7 Reusable Charts (`driver_performance_line_chart.dart` & `driver_performance_bar_chart.dart`)
- Pure Flutter `CustomPainter` widgets to ensure zero external dependency bloat, high 60fps rendering, and exact pixel replication of Figma curved area and bar designs.
- Labels for y-axis (min, mid, max) and x-axis (start time, end time) styled via `styles_manager.dart` with `color.onSurfaceVariant`.

### 4.8 Excellence / Motivation Banner (`driver_performance_excellence_banner.dart`)
- **Background**: `BoxDecoration` with `LinearGradient` of rich purple tones.
- **Border radius**: `Spacing.cardRadius` (16px).
- **Leading**: Medal / Ribbon Rosette icon badge (`Icons.workspace_premium_rounded` or `Icons.military_tech_rounded`, size 36, color `color.secondary` / amber/gold).
- **Center**:
  - Title: `locale.driverPerformanceExcellenceTitle` ("أداء رائع اليوم! استمر بنفس التميز") styled with `getBoldStyle(fontSize: FontSize.size13, color: color.onPrimary)`.
  - Subtitle: `locale.driverPerformanceExcellenceSubtitle` ("أنت من أفضل السائقين هذا الأسبوع") styled with `getRegularStyle(fontSize: FontSize.size11, color: color.onPrimary.withValues(alpha: 0.8))`.
- **Action**: White pill button with `locale.driverPerformanceViewDetails` ("عرض التفاصيل") and insights icon.

---

## 5. Localization Keys (ARB Files)

Keys to add in `app_ar.arb` and `app_en.arb`:
- `driverPerformanceTitle`: "الأداء" / "Performance"
- `driverPerformanceToday`: "اليوم" / "Today"
- `driverPerformanceThisWeek`: "هذا الأسبوع" / "This Week"
- `driverPerformanceOnlineStatus`: "أنت متصل" / "You are online"
- `driverPerformanceTotalOrders`: "إجمالي الطلبات" / "Total Orders"
- `driverPerformanceOrdersUnit`: "طلبات" / "orders"
- `driverPerformanceOnTimeRate`: "معدل الالتزام بالوقت" / "On-Time Rate"
- `driverPerformanceOnTimeLabel`: "في الوقت" / "on time"
- `driverPerformanceDeliveries`: "التسليمات" / "Deliveries"
- `driverPerformanceHandover`: "استلام يد بيد" / "Hand-to-hand"
- `driverPerformanceDeliveriesUnit`: "تسليمات" / "deliveries"
- `driverPerformanceTotalDistance`: "المسافة الكلية" / "Total Distance"
- `driverPerformanceDistanceKmUnit`: "كم" / "km"
- `driverPerformanceWorkingHours`: "ساعات العمل" / "Working Hours"
- `driverPerformanceOverview`: "نظرة عامة على الأداء" / "Performance Overview"
- `driverPerformanceTrendUpFromYesterday`: "↑ {value} من أمس" / "↑ {value} from yesterday"
- `driverPerformanceExcellenceTitle`: "أداء رائع اليوم! استمر بنفس التميز" / "Great performance today! Keep up the excellence"
- `driverPerformanceExcellenceSubtitle`: "أنت من أفضل السائقين هذا الأسبوع" / "You are one of the top drivers this week"
- `driverPerformanceViewDetails`: "عرض التفاصيل" / "View Details"

---

## 6. Adherence to `rules/ui_rules.md`

- **Build Context:** `final color = context.colorScheme;` and `final locale = context.localization;` declared at the beginning of `build()` and only when used.
- **Colors:** Colors strictly obtained via `color.*`. No `AppColors.*` or hardcoded hex literals in widget files.
- **Styles & Spacing:** Strictly derived from `styles_manager.dart` and `spacing.dart`.
- **Single Widget Per File:** Every custom component has its own dedicated file (no private `_Card` or helper classes).
- **RTL/LTR Support:** Inherited text direction with directional padding (`EdgeInsetsDirectional`) and alignments.
- **Performance & Rebuilds:** `const` constructors everywhere; local `ValueNotifier` for period toggle so toggling does not cause unnecessary full-screen rebuilds.

---

## 7. Testing & Quality Verification

- Unit & Widget test file: `test/driver_performance_screen_test.dart`
  - Tests rendering of header, period toggle, dark summary card, 2x2 grid cards, and excellence banner.
  - Tests switching period between "اليوم" and "هذا الأسبوع".
  - Verifies RTL directionality and localization.
- Validation commands:
  - `flutter analyze`
  - `flutter test test/driver_performance_screen_test.dart`
