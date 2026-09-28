# Design Spec: Driver Home Screens (05.01 - Start Work & 05.02 - Driver Home / Current Delivery)

## Overview
Implement the two driver home screens from Figma section `05 — Driver Home & Work Session`:
1. `05.01 - Start Work` (Figma Node `1364:3328`): Offline / shift initiation screen where the driver is "غير متاح للعمل" with zero metrics, checklist of requirements, and the primary "بدء العمل" action button.
2. `05.02 - Driver Home / Current Delivery` (Figma Node `2279:15086`): Active shift / delivery screen displaying live delivery status, daily goal achievement, mini map route preview, current active order (`BX-458722`), support/issues help banner, daily summary metrics, and daily performance metrics.

The implementation strictly adheres to [`rules/ui_rules.md`](file:///d:/projects/meal_mate_delivery/rules/ui_rules.md):
- Every custom widget in its own file (all public classes, no private `_Widget` classes).
- Strict context extensions: `final color = context.colorScheme;` and `final locale = context.localization;` only when used.
- Colors obtained only from `color` (no hardcoded colors, no `Colors.*`).
- Texts obtained only from `locale` (no hardcoded strings).
- Spacing values obtained strictly from `Spacing.*`.
- Full directional layout support (inherited RTL/LTR without locale checks).
- Clean Architecture (`data`, `domain`, `presentation`).

---

## 1. Architecture & Directory Structure

```text
lib/features/driver/home/
├── data/
│   ├── datasources/
│   │   ├── driver_home_datasource.dart
│   │   └── driver_home_fake_datasource.dart
│   ├── models/
│   │   ├── driver_start_work_model.dart
│   │   └── driver_active_home_model.dart
│   └── repositories/
│       └── driver_home_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── driver_start_work_entity.dart
│   │   ├── driver_active_home_entity.dart
│   │   ├── driver_current_order_entity.dart
│   │   ├── driver_daily_goal_entity.dart
│   │   ├── driver_daily_summary_entity.dart
│   │   └── driver_daily_performance_entity.dart
│   ├── repositories/
│   │   └── driver_home_repository.dart
│   └── usecases/
│       ├── get_driver_start_work_usecase.dart
│       ├── get_driver_active_home_usecase.dart
│       └── start_driver_shift_usecase.dart
└── presentation/
    ├── manager/
    │   ├── driver_start_work_view_model.dart
    │   ├── driver_start_work_state.dart
    │   ├── driver_active_home_view_model.dart
    │   └── driver_active_home_state.dart
    ├── screens/
    │   ├── driver_start_work_screen.dart (05.01)
    │   └── driver_active_home_screen.dart (05.02)
    └── widgets/
        ├── start_work/
        │   ├── driver_start_work_header_logo.dart
        │   ├── driver_start_work_title_section.dart
        │   ├── driver_start_work_illustration_card.dart
        │   ├── driver_start_work_status_card.dart
        │   ├── driver_start_work_metrics_row.dart
        │   ├── driver_start_work_metric_card.dart
        │   ├── driver_start_work_requirement_tile.dart
        │   ├── driver_start_work_requirements_list.dart
        │   └── driver_start_work_action_button.dart
        └── active_home/
            ├── driver_active_home_header.dart
            ├── driver_active_status_location_row.dart
            ├── driver_active_status_chip.dart
            ├── driver_active_location_chip.dart
            ├── driver_daily_goal_card.dart
            ├── driver_home_map_card.dart
            ├── driver_current_order_card.dart
            ├── driver_current_order_details_button.dart
            ├── driver_issues_help_banner.dart
            ├── driver_daily_summary_section.dart
            ├── driver_daily_summary_card.dart
            ├── driver_daily_performance_section.dart
            └── driver_daily_performance_card.dart
```

---

## 2. Screen 05.01 - Start Work Breakdown (`DriverStartWorkScreen`)

- **Route:** `AppRoutes.driverStartWork` (default initial index 0 in `AppShellScreen` when shift is not started).
- **Widgets:**
  1. `DriverStartWorkHeaderLogo`: MealMate centered logo.
  2. `DriverStartWorkTitleSection`: `غير متاح للعمل` + `أكمل المتطلبات لبدء استلام الطلبات`.
  3. `DriverStartWorkIllustrationCard`: Delivery driver character illustration with background.
  4. `DriverStartWorkStatusCard`: Container with `حالتك الآن` and red dot indicator + `غير متاح` + `أنت غير متاح لاستلام الطلبات`.
  5. `DriverStartWorkMetricsRow`: 3 cards showing 0.0 د.ك profits, 0 km distance, 0 completed orders.
  6. `DriverStartWorkRequirementsList`: List composed of 3 `DriverStartWorkRequirementTile` items:
     - Check requirements (`تحقق من متطلبات بدء العمل` - `راجع المتطلبات المطلوبة`).
     - Go to pickup point (`توجه إلى نقطة الاستلام` - `استلم الصناديق وابدأ التسليم`).
     - Ready to start (`جاهز لبدء العمل؟` - `تأكد من جاهزيتك وبدء استقبال الطلبات`).
  7. `DriverStartWorkActionButton`: Primary CTA button `بدء العمل`. Tapping executes `StartDriverShiftUseCase` and navigates to `AppRoutes.driverHome` (`DriverActiveHomeScreen`).

---

## 3. Screen 05.02 - Driver Home / Current Delivery Breakdown (`DriverActiveHomeScreen`)

- **Route:** `AppRoutes.driverHome` (the active home tab inside `AppShellScreen`).
- **Widgets:**
  1. `DriverActiveHomeHeader`: Top bar with notification bell icon + dot, MealMate logo, and menu icon.
  2. `DriverActiveStatusLocationRow`: Row containing `DriverActiveStatusChip` (`حالتك الحالية: توصيل الطلب`) and `DriverActiveLocationChip` (`الموقع الحالي: شارع الخليج العربي ، السالمية`).
  3. `DriverDailyGoalCard`: Target circular badge, count `8/5 طلبات`, text `أتممت 5 طلبات من الهدف اليومي`, progress segments indicator, remaining text `تبقى 3 طلبات للوصول للهدف`, and performance chip `★ مستوى الأداء : جيد`.
  4. `DriverHomeMapCard`: Mini route map preview with route polyline and overlay target button.
  5. `DriverCurrentOrderCard`: Active order container with 3D box graphic (`driverBox3d`), order code `BX-458722`, label `الطلب الحالي`, customer name `محمد علي`, address `شارع الخليج العربي ، قطعة 12 ، منزل 45 ، السالمية`, meals count `3 وجبات`, delivery time `09:20 ص`, and `DriverCurrentOrderDetailsButton` (`عرض التفاصيل >`) with local callback.
  6. `DriverIssuesHelpBanner`: Amber card with warning icon, title `في حال وجود مشكلة في التوصيل`, and description `أخبر لتتمكن من مساعدتك`.
  7. `DriverDailySummarySection`: Section titled `ملخص اليوم` with 4 colored status cards (`DriverDailySummaryCard`):
     - `1` `غير مكتملة` (soft red/pink tint).
     - `2` `قيد التوصيل` (soft amber tint).
     - `5` `تم التسليم` (soft green tint).
     - `8` `إجمالي الطلبات` (soft purple tint).
  8. `DriverDailyPerformanceSection`: Section titled `أداء اليوم` with 3 metric cards (`DriverDailyPerformanceCard`):
     - `18 دقيقة` `متوسط مدة التوصيل`.
     - `32.4 كم` `المسافة المقطوعة`.
     - `92%` `في الموعد`.

---

## 4. Localization & Theme

- Add required keys to `lib/config/localization/arb/app_ar.arb` and `app_en.arb`.
- Ensure all semantic colors exist in `ColorScheme` / `theme_color.dart` (or add missing ones cleanly).
- Ensure spacing constants in `Spacing` are used for all paddings, margins, gaps, and dimensions.
