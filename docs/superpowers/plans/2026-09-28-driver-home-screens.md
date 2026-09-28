# Driver Home Screens Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the two Driver Home screens from Figma (`05.01 - Start Work` and `05.02 - Driver Home / Current Delivery`) with full clean architecture, modular single-widget-per-file UI adhering strictly to `rules/ui_rules.md`, and integration into `AppShellScreen`.

**Architecture:** Clean Architecture (`domain`, `data`, `presentation`) with state management via Cubit/ViewModel. Every custom widget resides in its own file under `presentation/widgets/`. All colors, strings, and spacings are retrieved from `context.colorScheme`, `context.localization`, and `Spacing`.

**Tech Stack:** Flutter, Dart, Bloc/Cubit, GetIt, Flutter Localizations (ARB).

**Spec:** [`docs/superpowers/specs/2026-09-28-driver-home-screens-design.md`](file:///d:/projects/meal_mate_delivery/docs/superpowers/specs/2026-09-28-driver-home-screens-design.md)

## Global Constraints
- Follow [`rules/ui_rules.md`](file:///d:/projects/meal_mate_delivery/rules/ui_rules.md) strictly.
- Exactly one public widget class per file in `presentation/widgets/`. No private widget classes.
- Obtain colors via `final color = context.colorScheme;` (no `Colors.*` or hex literals).
- Obtain strings via `final locale = context.localization;` (no hardcoded strings).
- Spacing via `Spacing.*` (no raw numeric padding/margin/gap).
- Support inherited RTL/LTR directionality seamlessly.

---

### Task 1: Theme, Spacing, and Localization Setup

**Files:**
- Modify: `lib/config/localization/arb/app_ar.arb`
- Modify: `lib/config/localization/arb/app_en.arb`
- Modify: `lib/config/theme/spacing.dart`
- Modify: `lib/core/constants/assets.dart`

- [ ] **Step 1: Add ARB keys for Start Work & Active Home screens**
Add keys in `app_ar.arb` and `app_en.arb`:
- `driverStartWorkTitle`: "غير متاح للعمل" / "Not Available for Work"
- `driverStartWorkSubtitle`: "أكمل المتطلبات لبدء استلام الطلبات" / "Complete requirements to start receiving orders"
- `driverStatusNow`: "حالتك الآن" / "Your Current Status"
- `driverStatusOffline`: "غير متاح" / "Offline"
- `driverNotAvailableDescription`: "أنت غير متاح لاستلام الطلبات" / "You are not available to receive orders"
- `driverProfits`: "الأرباح" / "Profits"
- `driverDistanceApprox`: "كم تقريباً" / "KM approx"
- `driverCompletedOrders`: "طلبات مكتملة" / "Completed orders"
- `driverReqCheckRequirements`: "تحقق من متطلبات بدء العمل" / "Check start work requirements"
- `driverReqCheckRequirementsSubtitle`: "راجع المتطلبات المطلوبة" / "Review required checklist"
- `driverReqGoToPickup`: "توجه إلى نقطة الاستلام" / "Go to pickup point"
- `driverReqGoToPickupSubtitle`: "استلم الصناديق وابدأ التسليم" / "Receive boxes and start delivery"
- `driverReqReadyToWork`: "جاهز لبدء العمل؟" / "Ready to start work?"
- `driverReqReadyToWorkSubtitle`: "تأكد من جاهزيتك وبدء استقبال الطلبات" / "Ensure readiness and begin accepting orders"
- `driverStartWorkAction`: "بدء العمل" / "Start Work"
- `driverCurrentStatusLabel`: "حالتك الحالية :" / "Current status :"
- `driverStatusInDelivery`: "توصيل الطلب" / "Delivering Order"
- `driverCurrentLocationLabel`: "الموقع الحالي :" / "Current Location :"
- `driverDailyGoalTitle`: "مؤشر الإنجاز اليومي" / "Daily Achievement Indicator"
- `driverDailyGoalCompleted`: "أتممت {count} طلبات من الهدف اليومي" / "Completed {count} orders of daily goal"
- `driverDailyGoalRemaining`: "تبقى {count} طلبات للوصول للهدف" / "{count} orders remaining to reach goal"
- `driverPerformanceGood`: "مستوى الأداء : جيد" / "Performance Level: Good"
- `driverCurrentOrderLabel`: "الطلب الحالي" / "Current Order"
- `driverClientLabel`: "عميل :" / "Client :"
- `driverAddressLabel`: "العنوان :" / "Address :"
- `driverMealsCountLabel`: "عدد الوجبات :" / "Meals count :"
- `driverDeliveryTimeLabel`: "وقت التسليم :" / "Delivery time :"
- `driverViewDetailsAction`: "عرض التفاصيل" / "View Details"
- `driverIssuesWarningTitle`: "في حال وجود مشكلة في التوصيل" / "If you encounter a delivery issue"
- `driverIssuesWarningSubtitle`: "أخبر لتتمكن من مساعدتك" / "Report so we can assist you"
- `driverDailySummaryTitle`: "ملخص اليوم" / "Today's Summary"
- `driverSummaryIncomplete`: "غير مكتملة" / "Incomplete"
- `driverSummaryInDelivery`: "قيد التوصيل" / "In Delivery"
- `driverSummaryDelivered`: "تم التسليم" / "Delivered"
- `driverSummaryTotalOrders`: "إجمالي الطلبات" / "Total Orders"
- `driverDailyPerformanceTitle`: "أداء اليوم" / "Today's Performance"
- `driverAvgDeliveryTime`: "متوسط مدة التوصيل" / "Avg Delivery Time"
- `driverDistanceCovered`: "المسافة المقطوعة" / "Distance Covered"
- `driverOnTimeRate`: "في الموعد" / "On Time"

- [ ] **Step 2: Generate localizations and verify**
Run `flutter gen-l10n`.

- [ ] **Step 3: Commit**
```bash
git add lib/config/localization/ lib/config/theme/ lib/core/constants/
git commit -m "feat(driver_home): add localizations and tokens for driver home screens"
```

---

### Task 2: Domain Layer (Entities & UseCases)

**Files:**
- Create: `lib/features/driver/home/domain/entities/driver_start_work_entity.dart`
- Create: `lib/features/driver/home/domain/entities/driver_start_work_metric_entity.dart`
- Create: `lib/features/driver/home/domain/entities/driver_start_work_requirement_entity.dart`
- Create: `lib/features/driver/home/domain/entities/driver_active_home_entity.dart`
- Create: `lib/features/driver/home/domain/entities/driver_current_order_entity.dart`
- Create: `lib/features/driver/home/domain/entities/driver_daily_goal_entity.dart`
- Create: `lib/features/driver/home/domain/entities/driver_daily_summary_entity.dart`
- Create: `lib/features/driver/home/domain/entities/driver_daily_performance_entity.dart`
- Create: `lib/features/driver/home/domain/repositories/driver_home_repository.dart`
- Create: `lib/features/driver/home/domain/usecases/get_driver_start_work_usecase.dart`
- Create: `lib/features/driver/home/domain/usecases/get_driver_active_home_usecase.dart`
- Create: `lib/features/driver/home/domain/usecases/start_driver_shift_usecase.dart`
- Test: `test/features/driver/home/domain/driver_home_domain_test.dart`

- [ ] **Step 1: Write Domain unit test**
Test that `GetDriverStartWorkUseCase` and `GetDriverActiveHomeUseCase` return expected entities.
- [ ] **Step 2: Implement Entities and UseCases**
- [ ] **Step 3: Run test to verify it passes**
- [ ] **Step 4: Commit**
```bash
git add lib/features/driver/home/domain/ test/features/driver/home/
git commit -m "feat(driver_home): implement domain entities and use cases"
```

---

### Task 3: Data Layer (Models, Fake DataSource, Repository Impl)

**Files:**
- Create: `lib/features/driver/home/data/datasources/driver_home_datasource.dart`
- Create: `lib/features/driver/home/data/datasources/driver_home_fake_datasource.dart`
- Create: `lib/features/driver/home/data/models/driver_start_work_model.dart`
- Create: `lib/features/driver/home/data/models/driver_active_home_model.dart`
- Create: `lib/features/driver/home/data/repositories/driver_home_repository_impl.dart`
- Test: `test/features/driver/home/data/driver_home_repository_test.dart`

- [ ] **Step 1: Write Data repository unit test**
- [ ] **Step 2: Implement Models, Fake DataSource, and Repository**
- [ ] **Step 3: Run test to verify it passes**
- [ ] **Step 4: Commit**
```bash
git add lib/features/driver/home/data/ test/features/driver/home/data/
git commit -m "feat(driver_home): implement data layer and fake data source"
```

---

### Task 4: Screen 05.01 - Start Work Presentation (Widgets & Screen)

**Files:**
- Create: `lib/features/driver/home/presentation/manager/driver_start_work_state.dart`
- Create: `lib/features/driver/home/presentation/manager/driver_start_work_view_model.dart`
- Create: `lib/features/driver/home/presentation/widgets/start_work/driver_start_work_header_logo.dart`
- Create: `lib/features/driver/home/presentation/widgets/start_work/driver_start_work_title_section.dart`
- Create: `lib/features/driver/home/presentation/widgets/start_work/driver_start_work_illustration_card.dart`
- Create: `lib/features/driver/home/presentation/widgets/start_work/driver_start_work_status_card.dart`
- Create: `lib/features/driver/home/presentation/widgets/start_work/driver_start_work_metric_card.dart`
- Create: `lib/features/driver/home/presentation/widgets/start_work/driver_start_work_metrics_row.dart`
- Create: `lib/features/driver/home/presentation/widgets/start_work/driver_start_work_requirement_tile.dart`
- Create: `lib/features/driver/home/presentation/widgets/start_work/driver_start_work_requirements_list.dart`
- Create: `lib/features/driver/home/presentation/widgets/start_work/driver_start_work_action_button.dart`
- Create: `lib/features/driver/home/presentation/screens/driver_start_work_screen.dart`
- Test: `test/features/driver/home/presentation/driver_start_work_screen_test.dart`

- [ ] **Step 1: Write Widget test for `DriverStartWorkScreen`**
- [ ] **Step 2: Implement View Model, State, all widgets, and the screen**
- [ ] **Step 3: Run widget test to verify it passes**
- [ ] **Step 4: Commit**
```bash
git add lib/features/driver/home/presentation/ test/features/driver/home/presentation/
git commit -m "feat(driver_home): implement driver start work screen (05.01)"
```

---

### Task 5: Screen 05.02 - Driver Home / Current Delivery Presentation (Widgets & Screen)

**Files:**
- Create: `lib/features/driver/home/presentation/manager/driver_active_home_state.dart`
- Create: `lib/features/driver/home/presentation/manager/driver_active_home_view_model.dart`
- Create: `lib/features/driver/home/presentation/widgets/active_home/driver_active_home_header.dart`
- Create: `lib/features/driver/home/presentation/widgets/active_home/driver_active_status_chip.dart`
- Create: `lib/features/driver/home/presentation/widgets/active_home/driver_active_location_chip.dart`
- Create: `lib/features/driver/home/presentation/widgets/active_home/driver_active_status_location_row.dart`
- Create: `lib/features/driver/home/presentation/widgets/active_home/driver_daily_goal_card.dart`
- Create: `lib/features/driver/home/presentation/widgets/active_home/driver_home_map_card.dart`
- Create: `lib/features/driver/home/presentation/widgets/active_home/driver_current_order_details_button.dart`
- Create: `lib/features/driver/home/presentation/widgets/active_home/driver_current_order_card.dart`
- Create: `lib/features/driver/home/presentation/widgets/active_home/driver_issues_help_banner.dart`
- Create: `lib/features/driver/home/presentation/widgets/active_home/driver_daily_summary_card.dart`
- Create: `lib/features/driver/home/presentation/widgets/active_home/driver_daily_summary_section.dart`
- Create: `lib/features/driver/home/presentation/widgets/active_home/driver_daily_performance_card.dart`
- Create: `lib/features/driver/home/presentation/widgets/active_home/driver_daily_performance_section.dart`
- Create: `lib/features/driver/home/presentation/screens/driver_active_home_screen.dart`
- Test: `test/features/driver/home/presentation/driver_active_home_screen_test.dart`

- [ ] **Step 1: Write Widget test for `DriverActiveHomeScreen`**
- [ ] **Step 2: Implement View Model, State, all widgets, and the screen**
- [ ] **Step 3: Run widget test to verify it passes**
- [ ] **Step 4: Commit**
```bash
git add lib/features/driver/home/presentation/ test/features/driver/home/presentation/
git commit -m "feat(driver_home): implement driver active home screen (05.02)"
```

---

### Task 6: Routing, AppShell Integration, and DI Registration

**Files:**
- Modify: `lib/config/routing/app_routes.dart`
- Modify: `lib/config/routing/routing_generator.dart`
- Modify: `lib/core/app_shell/screens/app_shell_screen.dart`
- Modify: `lib/core/di/di.dart`

- [ ] **Step 1: Add `AppRoutes.driverStartWork` and `AppRoutes.driverHome` in `app_routes.dart`**
- [ ] **Step 2: Handle routes in `routing_generator.dart`**
- [ ] **Step 3: Replace `const Text("Home")` in `AppShellScreen` with `DriverStartWorkScreen` or `DriverActiveHomeScreen`**
- [ ] **Step 4: Register DI for driver home data source, repository, usecases, and view models in `di.dart`**
- [ ] **Step 5: Commit**
```bash
git add lib/config/routing/ lib/core/app_shell/ lib/core/di/
git commit -m "feat(driver_home): integrate driver home screens with AppShell and DI"
```

---

### Task 7: Verification and Quality Assurance

- [ ] **Step 1: Run analyzer to verify 0 errors and warnings**
Run `flutter analyze`.
- [ ] **Step 2: Run all home tests**
Run `flutter test test/features/driver/home/`.
- [ ] **Step 3: Final commit and summary**
