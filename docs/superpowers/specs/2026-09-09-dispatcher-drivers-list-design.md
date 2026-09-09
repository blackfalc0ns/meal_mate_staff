# Design Spec: Dispatcher Drivers List Screen (10.04 - Driver List – By Area)

## Overview
Implement the Dispatcher Drivers List Screen (Figma Node `2259-7279`, `10.04 - Driver List — By Area`) for the MealMate Delivery mobile app. This screen allows dispatchers (`UserRole.operations`) to browse, filter by area/governorate, view driver workloads, and select drivers for order assignment, adhering strictly to `rules/ui_rules.md` and repository standards.

---

## Visual & Functional Breakdown (from Figma Node `2259:7279`)

### 1. Header Section (`DispatcherDriversHeader`)
- **Back Navigation**: Left button in rounded border/surface container (`Icons.arrow_back_ios_new_rounded` or chevron).
- **Titles**:
  - Main Title: `قائمة السائقين` (`driversTitle`) — 18-20px Bold, `color.onSurface`.
  - Subtitle: `اختر السائق المناسب لتوزيع الطلبات` (`driversSubtitle`) — 12-13px Regular, `color.onSurfaceVariant`.
- **Filter Action**: Right button in rounded container with filter icon (`Icons.tune_rounded`).

### 2. View Switcher (`DispatcherDriversViewSwitcher`)
A segmented pill toggle allowing the dispatcher to switch modes:
- **By Area (`حسب المحافظة`)**: Building/city icon (`Icons.apartment_rounded`), active state with filled primary purple pill and white text.
- **All Drivers (`كل السائقين`)**: People icon (`Icons.people_alt_rounded`), inactive state with subtle text.

### 3. Area Filter Chips (`DispatcherDriversAreaChips`)
Horizontally scrollable chips shown when "حسب المحافظة" is active:
- Chips: `السالمية`, `حولي`, `حطين`, `الفروانية`, `العاصمة`.
- Active chip: Purple filled background (`color.primary`), pin icon (`Icons.location_on_rounded`), white text.
- Inactive chips: Outlined surface background, pin icon, dark text.

### 4. KPI Summary Card (`DispatcherDriversKpiCard`)
Surface card divided into 3 equal stat segments:
1. **Total Drivers (`إجمالي السائقين`)**:
   - Value: `13`
   - Icon: `Icons.people_alt_rounded` in a soft primary circle.
2. **Available Drivers (`السائقين المتاحين`)**:
   - Value: `8`
   - Icon: `Icons.person_rounded` in a soft success (green) circle.
3. **Busy Now (`مشغول الآن`)**:
   - Value: `5`
   - Icon: `Icons.person_rounded` in a soft warning (amber/orange) circle.

### 5. Section Header (`DispatcherDriversSectionHeader`)
- Dynamic title: `السائقين في {area} ({count})` (e.g., `السائقين في السالمية (8)`).
- Sort button: `ترتيب` (`driversSort`) with `Icons.swap_vert_rounded` in a small pill container.

### 6. Driver Cards (`DispatcherDriversCard`)
Card showing driver status and performance metrics:
- **Profile Column**:
  - Circular avatar (`42x42`) with online status badge indicator dot at the bottom corner:
    - Green for `available` (`متاح`)
    - Orange for `onTheWay` (`في طريقه`)
    - Grey for `onBreak` (`في استراحة`)
- **Driver Info**:
  - Name (e.g., `أحمد محمد`) — 14px SemiBold.
  - Rating (e.g., `⭐ 4.9`).
  - ID badge (e.g., `ID:D-1025`) — Muted 12px.
- **Status Pill**:
  - `متاح`: Light green background, green text.
  - `في طريقه`: Light orange background, orange text.
  - `في استراحة`: Light grey background, muted text.
- **Action Button**:
  - If available: `+ اختيار` — Filled primary button (`Icons.add_rounded`).
  - If busy/on break: `⊘ غير متاح` — Disabled outlined button (`Icons.block_rounded`).
- **Metrics Row**:
  - Current Orders (`الطلبات الحالية`): e.g., `1` with box icon.
  - Completed Today (`طلبات مكتملة اليوم`): e.g., `12` with box check icon.
  - Distance (`المسافة منك`): e.g., `9 Km` with car/navigation icon.

### 7. Bottom Action Button (`DispatcherDriversMapButton`)
- Outlined rounded pill button with map icon (`Icons.map_outlined`):
  - Text: `عرض السائقين على الخريطة` (`driversViewOnMap`).

### 8. Navigation & App Shell Integration
- Embedded inside `AppShellScreen` as Tab 2 (`navDelivery` / Delivery Tab).
- `showBottomNavBar: false` when mounted in `AppShellScreen` to avoid nested navigation bars.
- Can also be launched standalone via route `/dispatcher-drivers`.

---

## Repository Standards & UI Rules Compliance

1. **One Widget Per File**:
   - `lib/features/dispatcher/drivers/presentation/widgets/dispatcher_drivers_header.dart`
   - `lib/features/dispatcher/drivers/presentation/widgets/dispatcher_drivers_view_switcher.dart`
   - `lib/features/dispatcher/drivers/presentation/widgets/dispatcher_drivers_area_chips.dart`
   - `lib/features/dispatcher/drivers/presentation/widgets/dispatcher_drivers_kpi_card.dart`
   - `lib/features/dispatcher/drivers/presentation/widgets/dispatcher_drivers_section_header.dart`
   - `lib/features/dispatcher/drivers/presentation/widgets/dispatcher_drivers_card.dart`
   - `lib/features/dispatcher/drivers/presentation/widgets/dispatcher_drivers_map_button.dart`
2. **Context Extension Rule**:
   - `final color = context.colorScheme;`
   - `final locale = context.localization;`
3. **No Hardcoded Strings / Colors**:
   - Localized via `app_ar.arb` & `app_en.arb`.
   - Colors from `AppColors` / `context.colorScheme`.
   - Spacing tokens from `Spacing.*`.
   - Typography from `styles_manager.dart`.
4. **Directionality & Responsiveness**:
   - Pure `EdgeInsetsDirectional` / `AlignmentDirectional`.
   - Overflow prevention: `Expanded`, `Flexible`, `FittedBox` for compact metric chips.
