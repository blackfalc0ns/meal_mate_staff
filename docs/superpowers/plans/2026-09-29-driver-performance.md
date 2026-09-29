# Driver Performance Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Driver Performance screen from Figma frame `09.01 - Performance` (Node ID: `1460-4307`) with complete domain models, custom widgets, responsive charts, and localization.

**Architecture:** All new widgets and domain entities are located in `lib/features/driver/driver_profile/` under domain and presentation folders. Each custom UI component is isolated into its own file with exactly one class per file per `rules/ui_rules.md`. Charts are built with custom painters for zero-dependency high-performance rendering. The screen is registered in `AppRoutes` and `routing_generator.dart`.

**Tech Stack:** Flutter, Dart, Material 3, AppTheme, CustomPainter, Localization (ARB).

**Spec:** `docs/superpowers/specs/2026-09-29-driver-performance-design.md`

## Global Constraints
- Follow `rules/ui_rules.md` strictly:
  - `final color = context.colorScheme;` and `final locale = context.localization;` declared at start of `build()` only if used.
  - Never use hardcoded colors (`Colors.*` or `Color(...)`), always use `color.*` and semantic extensions.
  - Never use hardcoded text, always use `locale.*`.
  - Never guess spacing, use `Spacing.*` from `lib/config/theme/spacing.dart`.
  - Never create private widget classes (`_Card`, `_Tile`, etc.). Keep exactly one widget class per file.
  - Support both RTL and LTR using directional APIs (`EdgeInsetsDirectional`, `AlignmentDirectional`).
  - No new feature folders outside `lib/features/driver/driver_profile/`.

---

### Task 1: Add Localization Keys to ARB Files
**Files:**
- Modify: `lib/core/l10n/app_ar.arb`
- Modify: `lib/core/l10n/app_en.arb`

- [ ] Add the following keys to `app_ar.arb`:
  - `driverPerformanceTitle`: "الأداء"
  - `driverPerformanceToday`: "اليوم"
  - `driverPerformanceThisWeek`: "هذا الأسبوع"
  - `driverPerformanceOnlineStatus`: "أنت متصل"
  - `driverPerformanceTotalOrders`: "إجمالي الطلبات"
  - `driverPerformanceOrdersUnit`: "طلبات"
  - `driverPerformanceOnTimeRate`: "معدل الالتزام بالوقت"
  - `driverPerformanceOnTimeLabel`: "في الوقت"
  - `driverPerformanceDeliveries`: "التسليمات"
  - `driverPerformanceHandover`: "استلام يد بيد"
  - `driverPerformanceDeliveriesUnit`: "تسليمات"
  - `driverPerformanceTotalDistance`: "المسافة الكلية"
  - `driverPerformanceDistanceKmUnit`: "كم"
  - `driverPerformanceWorkingHours`: "ساعات العمل"
  - `driverPerformanceOverview`: "نظرة عامة على الأداء"
  - `driverPerformanceTrendUpFromYesterday`: "↑ {value} من أمس"
  - `driverPerformanceExcellenceTitle`: "أداء رائع اليوم! استمر بنفس التميز"
  - `driverPerformanceExcellenceSubtitle`: "أنت من أفضل السائقين هذا الأسبوع"
  - `driverPerformanceViewDetails`: "عرض التفاصيل"
- [ ] Add equivalent English translations to `app_en.arb`.
- [ ] Run `flutter gen-l10n` to update generated localizations.

---

### Task 2: Domain Entities & Fake Data Source
**Files:**
- Create: `lib/features/driver/driver_profile/domain/entities/driver_performance_chart_point_entity.dart`
- Create: `lib/features/driver/driver_profile/domain/entities/driver_performance_metric_card_entity.dart`
- Create: `lib/features/driver/driver_profile/domain/entities/driver_performance_entity.dart`
- Create: `lib/features/driver/driver_profile/domain/fake_data/driver_performance_fake_data.dart`

- [ ] `DriverPerformanceChartPointEntity`: immutable data class representing a point (time label, value).
- [ ] `DriverPerformanceMetricCardEntity`: immutable data class for individual metric cards (value, trend, unit, chart points, isAreaChart, isAmber).
- [ ] `DriverPerformanceEntity`: container entity with date, online status, summary metrics (total orders, on-time rate, deliveries count, total distance), and the 4 detailed metric card objects.
- [ ] `DriverPerformanceFakeData`: provides `todayPerformance` and `thisWeekPerformance` with the exact values matching Figma node 1460-4307.

---

### Task 3: AppRoutes and Routing Generator Integration
**Files:**
- Modify: `lib/config/routing/app_routes.dart`
- Modify: `lib/config/routing/routing_generator.dart`

- [ ] Add `static const String driverPerformance = '/driver-performance';` to `AppRoutes`.
- [ ] In `routing_generator.dart`, import `DriverPerformanceScreen` and add `case AppRoutes.driverPerformance:` returning `DriverPerformanceScreen(performance: performance)`.

---

### Task 4: Reusable Chart Custom Painters (One Class Per File)
**Files:**
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_performance_line_chart.dart`
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_performance_bar_chart.dart`

- [ ] Create `DriverPerformanceLineChart`:
  - CustomPainter widget drawing smooth cubic bezier curves with gradient fill beneath the line.
  - Draws y-axis scale labels (0%, 50%, 100% or 0, 20, 40) and x-axis time labels (00:00, 12:00, 24:00).
  - Supports color configuration (purple gradient for on-time rate, amber/orange gradient for distance).
- [ ] Create `DriverPerformanceBarChart`:
  - CustomPainter widget drawing rounded vertical bars for hourly activity.
  - Draws y-axis scale labels and x-axis time labels.
  - Supports bar color configuration (purple bars for deliveries, amber/orange bars for working hours).

---

### Task 5: Upper Section Widgets (One Class Per File)
**Files:**
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_performance_header.dart`
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_performance_period_toggle.dart`
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_performance_summary_column.dart`
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_performance_summary_card.dart`
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_performance_section_title.dart`

- [ ] `DriverPerformanceHeader`: centered logo, bold title "الأداء", calendar icon with date, online status capsule.
- [ ] `DriverPerformancePeriodToggle`: segmented pill control between "اليوم" and "هذا الأسبوع" with active state styling.
- [ ] `DriverPerformanceSummaryColumn`: single metric column with label, icon, bold value, and unit.
- [ ] `DriverPerformanceSummaryCard`: dark navy card composing 4 `DriverPerformanceSummaryColumn` with vertical dividers.
- [ ] `DriverPerformanceSectionTitle`: section title "نظرة عامة على الأداء" with directional padding.

---

### Task 6: 2x2 Performance Grid Cards (One Class Per File)
**Files:**
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_performance_on_time_card.dart`
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_performance_deliveries_card.dart`
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_performance_distance_card.dart`
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_performance_working_hours_card.dart`

- [ ] `DriverPerformanceOnTimeCard`: title, clock icon in circle, 92%, ↑ 8% from yesterday badge, and `DriverPerformanceLineChart`.
- [ ] `DriverPerformanceDeliveriesCard`: title, handshake icon, 8, ↑ 2 from yesterday badge, and `DriverPerformanceBarChart`.
- [ ] `DriverPerformanceDistanceCard`: title, location pin icon, 32.4كم, ↑ 0.9 كم from yesterday badge, and `DriverPerformanceLineChart` with amber gradient.
- [ ] `DriverPerformanceWorkingHoursCard`: title, clock icon, 5:45, ↑ 0:45 from yesterday badge, and `DriverPerformanceBarChart` with amber bars.

---

### Task 7: Excellence Banner & Main Screen
**Files:**
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_performance_excellence_banner.dart`
- Create: `lib/features/driver/driver_profile/presentation/screens/driver_performance_screen.dart`

- [ ] `DriverPerformanceExcellenceBanner`: purple gradient card, rosette badge icon, motivational title & subtitle, white "عرض التفاصيل" button with insights icon.
- [ ] `DriverPerformanceScreen`:
  - Accepts optional `DriverPerformanceEntity? performance` (defaults to `DriverPerformanceFakeData.todayPerformance`).
  - Uses `ValueNotifier<bool>` for toggle between Today and This Week so only the data widgets react without unnecessary screen rebuilds.
  - Composes `DriverPerformanceHeader`, `DriverPerformancePeriodToggle`, `DriverPerformanceSummaryCard`, `DriverPerformanceSectionTitle`, 2x2 grid cards, and `DriverPerformanceExcellenceBanner` inside a `SafeArea` and `SingleChildScrollView`.

---

### Task 8: Automated Tests & Verification
**Files:**
- Create: `test/driver_performance_screen_test.dart`

- [ ] Write widget tests for:
  - Header rendering with logo and status badge.
  - Period toggle selection changes.
  - Summary card metrics rendering.
  - 2x2 grid cards rendering with charts.
  - Excellence banner rendering.
  - RTL directionality verification.
- [ ] Run `flutter test test/driver_performance_screen_test.dart`.
- [ ] Run `flutter analyze` to ensure 0 lint errors.
