# Design Spec: Dispatcher Operations Log Screen (10.10 - Operations Log)

## Overview
Implement the Dispatcher Operations Log Screen (Figma Node `1825:9909`, `10.10 - Operations Log`) for the MealMate Delivery mobile app under `lib/features/dispatcher/operations_log/`. This screen serves as an audit and operations history center for dispatchers (`UserRole.operations`), allowing them to track past box deliveries, search by box number, driver, or customer, filter by date range, switch between status categories (All, Completed, Cancelled, Failed, Reassigned), and browse through paginated records.

An entry point is integrated directly into the Dispatcher Profile screen (`DispatcherProfileScreen`) via a dedicated menu item card (`DispatcherProfileOperationsLogCard`).

The implementation strictly complies with [`rules/ui_rules.md`](file:///d:/projects/meal_mate_delivery/rules/ui_rules.md) and repository standards:
- One widget per file (all public classes, no private `_Widget` classes).
- Strict context extension usage (`color = context.colorScheme;`, `locale = context.localization;`).
- Zero hardcoded colors, strings, or spacing values.
- Directional layout support (inherited RTL/LTR without locale checks).
- Full localization keys in `app_ar.arb` and `app_en.arb`.

---

## Visual & Functional Breakdown (Figma Node `1825:9909`)

### 1. Header (`OperationsLogAppBar`)
- **Back Navigation**: Back arrow icon button to pop navigation.
- **Title**: `سجل العمليات` (`operationsLogTitle`) — Centered Bold, `color.onSurface`.
- **Action**: Filter button (`تصفية` / `operationsLogFilter`) with filter icon.
  - Tapping opens the existing `DriverFilterBottomSheet` (`lib/features/dispatcher/driver_filter/`).
- Wraps or conforms to `CustomAppBar` from `lib/core/widget/custom_app_bar.dart`.

### 2. Search & Date Filter Bar (`OperationsLogSearchFilterBar`)
Row consisting of:
- **Search Field**:
  - Placeholder: `ابحث برقم البوكس، السائق، أو العميل...` (`operationsLogSearchPlaceholder`).
  - Icon: Search magnifying glass.
  - Expands to take the primary width.
- **Date Filter Dropdown**:
  - Pill dropdown container with calendar icon (`Icons.calendar_today_outlined`).
  - Label: `آخر 7 أيام` (`operationsLogLast7Days`).
  - Chevron down indicator.

### 3. Status Tabs Bar (`OperationsLogStatusTabs`)
Horizontal scrollable bar of status filter chips, each containing a label and counter badge:
1. `الكل` (128) — `operationsLogTabAll`
2. `مكتملة` (96) — `operationsLogTabCompleted`
3. `ملغاة` (3) — `operationsLogTabCancelled`
4. `فشل التسليم` (7) — `operationsLogTabFailed`
5. `معاد إسنادها` (17) — `operationsLogTabReassigned`

Active tab styling: Primary colored pill with white/light text.
Inactive tab styling: Subtle border, neutral background, muted count badge.

### 4. Operations Log Cards (`OperationsLogCard`)
List of transaction cards (height ~68-76dp), supporting 4 transaction states:
1. **Completed / Standard Operation** (e.g. `#BX-10256`):
   - Right (RTL Start): Driver avatar with online status dot + Driver name (`أحمد السعيد`) + Box ID (`#BX-10256`).
   - Vertical subtle divider.
   - Center: Customer name (`عميل: أحمد العتيبي`) + Area (`حي الياسمين، الرياض`) with location pin icon.
   - Vertical subtle divider.
   - Left (RTL End): Status pill badge (`مكتملة` with checkmark icon) + Timestamp (`اليوم • 10:45 ص`).
   - Navigation chevron arrow.
2. **Reassigned Operation** (e.g. `#BX-10255`):
   - Right (RTL Start): Dual driver representation (`فهد المطيري` -> Arrow -> `يوسف خالد`).
   - Center: Customer + Area.
   - Left (RTL End): Status pill badge (`معاد إسنادها` with refresh icon) + Timestamp (`اليوم • 10:28 ص`).
3. **Failed Delivery** (e.g. `#BX-10248`):
   - Right: Driver name (`محمد العنزي`) + Box ID (`#BX-10256`).
   - Center: Customer + Area.
   - Left: Status pill badge (`فشل التسليم` with alert/error icon in red tone) + Timestamp (`اليوم • 09:50 ص`).
4. **Cancelled Operation** (e.g. `#BX-10241`):
   - Right: Store icon container + Store cancellation reason (`تم الإلغاء من قبل المطعم`).
   - Center: Customer + Area.
   - Left: Status pill badge (`ملغاة` with muted/cancel icon) + Timestamp (`أمس • 06:40 م`).

### 5. Pagination Bar (`OperationsLogPaginationBar`)
Bottom navigation bar for records pagination:
- **Previous Button**: `السابق` (`operationsLogPrevPage`) with back chevron.
- **Page Indicator**: `1 من 13` (`operationsLogPageIndicator`).
- **Next Button**: `التالي` (`operationsLogNextPage`) with next chevron.

### 6. Profile Entry Point (`DispatcherProfileOperationsLogCard`)
- In `lib/features/dispatcher/profile/presentation/widgets/dispatcher_profile_operations_log_card.dart`.
- Styled as a clean profile action tile matching other cards in `DispatcherProfileScreen`:
  - Receipt / operations history icon.
  - Title: `سجل العمليات` (`locale.operationsLogTitle`).
  - Subtitle: `عرض ومتابعة سجل طلبات وعمليات التوصيل السابقة` (`locale.profileOperationsLogSubtitle`).
  - Trailing chevron.
  - `onTap: () => context.pushNamed(AppRoutes.dispatcherOperationsLog)`.

---

## File Structure & Modularity (1 Widget Per File)

```text
lib/features/dispatcher/operations_log/
├── domain/
│   ├── entities/
│   │   ├── operation_log_status.dart
│   │   ├── operation_log_item_entity.dart
│   │   └── operations_log_filter_entity.dart
│   └── fake_data/
│       └── operations_log_fake_data.dart
└── presentation/
    ├── screens/
    │   └── dispatcher_operations_log_screen.dart
    └── widgets/
        ├── operations_log_app_bar.dart
        ├── operations_log_search_filter_bar.dart
        ├── operations_log_status_tabs.dart
        ├── operations_log_status_tab_item.dart
        ├── operations_log_card.dart
        ├── operations_log_driver_info.dart
        ├── operations_log_reassigned_info.dart
        ├── operations_log_cancelled_info.dart
        ├── operations_log_customer_info.dart
        ├── operations_log_status_badge.dart
        └── operations_log_pagination_bar.dart

lib/features/dispatcher/profile/presentation/widgets/
└── dispatcher_profile_operations_log_card.dart
```

---

## Routing & Navigation Integration
1. `AppRoutes.dart`:
   - Add `static const String dispatcherOperationsLog = '/dispatcher-operations-log';`
2. `routing_generator.dart`:
   - Case `AppRoutes.dispatcherOperationsLog` returning `DispatcherOperationsLogScreen`.
3. `dispatcher_profile_screen.dart`:
   - Insert `DispatcherProfileOperationsLogCard` in the body scrollable list.

---

## Verification Plan
1. `flutter analyze`: Verify 0 errors, 0 warnings.
2. Localization generation: Run `flutter gen-l10n` to compile new keys in AR and EN.
3. Unit / Widget test: Create `test/features/dispatcher/operations_log/dispatcher_operations_log_test.dart` to verify rendering, status tab switching, and card display.
