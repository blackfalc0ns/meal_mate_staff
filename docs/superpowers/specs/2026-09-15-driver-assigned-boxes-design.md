# Design Spec: Driver Assigned Boxes Screen (06.02 - Assigned Boxes)

## Overview
Implement the Driver Assigned Boxes Screen (Figma Node `2397:6942`, `06.02 - Assigned Boxes`) for the MealMate Delivery mobile app under `lib/features/driver/orders/`. This screen serves as the central orders/loading queue for the Driver role (`UserRole.driver`), allowing drivers to inspect boxes assigned to them for the current shift, track loaded vs unloaded boxes, review destination areas and meal quantities, and proceed to pickup/QR scanning (`استكمال الإجراء`).

The implementation strictly complies with [`rules/ui_rules.md`](file:///d:/projects/meal_mate_delivery/rules/ui_rules.md) and repository standards:
- One widget per file (all public classes, no private `_Widget` classes).
- Strict context extension usage (`final color = context.colorScheme;`, `final locale = context.localization;`).
- Zero hardcoded colors, strings, or spacing values.
- Directional layout support (inherited RTL/LTR without locale checks).
- Full localization keys in `app_ar.arb` and `app_en.arb`.
- Fake data source with clean entities.

---

## Visual & Functional Breakdown (Figma Node `2397:6942`)

### 1. Header (`DriverBoxesHeaderLogo`)
- Centered MealMate Logo (`AppAssets.logo` / `AppAssets.mealMateLogo`) at top SafeArea.
- Consistent with top brand positioning across the driver onboarding and session screens.

### 2. Title & Status Bar (`DriverBoxesTitleBar`)
Row consisting of:
- **Title Column** (RTL Start / Logical Start):
  - Primary title: `قائمة الصناديق` (`driverBoxesTitle`) — 17px SemiBold (Alexandria), `color.onSurface`.
  - Subtitle: `الصناديق المخصصة قبل التوصيل` (`driverBoxesSubtitle`) — 10px Regular, `color.onSurfaceVariant`.
- **Delivery Mode Pill** (`DriverBoxesDeliveryModeChip`):
  - Pill container (`Radius.circular(99)`), subtle light green background (`color.tertiaryContainer` / `#E7F6EC`).
  - Active green indicator dot (`color.tertiary` / `#29BE63`).
  - Text: `أنت في وضع التوصيل` (`driverInDeliveryMode`) — 8px Regular, `color.tertiary`.

### 3. Shift Stats Banner (`DriverBoxesStatsBanner`)
Prominent rounded card (Radius 14dp, background `#25174C` / dark surface):
- **Right / Logical Start Column**:
  - Total Meals: Count `32` (25px Bold, White) + Label `إجمالي الوجبات` (`driverTotalMeals`) + Unit `وجبة` (`driverMealsUnit`).
- **Vertical Subtle Divider**: Divider line with muted opacity.
- **Center Column**:
  - Total Boxes: Count `8` (25px Bold, White) + Label `إجمالي الصناديق المخصصة اليوم` (`driverTotalBoxesToday`) + Unit `صناديق` (`driverBoxesUnit`).
- **Left / Logical End**:
  - Illustration graphic (`AppAssets.driverAssignedBoxesBanner`, 90x76dp) representing delivery meals/boxes.

### 4. Filter Tabs & Filter Action Bar (`DriverBoxesFilterBar`)
Row containing:
- **Filter Tabs Container**:
  - Background surface with rounded border.
  - Three filter options:
    1. `الكل` (`driverBoxesFilterAll`)
    2. `لم يتم التحميل` (`driverBoxesFilterNotLoaded`)
    3. `تم التحميل` (`driverBoxesFilterLoaded`)
  - Active pill style: Primary purple background (`color.primary`), white text (`color.onPrimary`).
  - Inactive pill style: Transparent background, muted text (`color.onSurfaceVariant`).
- **Filter Action Button** (`DriverBoxesFilterActionButton`):
  - Square container (38x38dp), rounded corners, surface background with subtle border.
  - Filter icon (`AppAssets.driverFilterIcon`).

### 5. Assigned Box Card (`DriverAssignedBoxCard`)
Card container (height ~82dp, rounded 12dp, surface background, subtle border, shadow):
- **Left Column / Logical End**:
  - Box Icon Container (46x48dp, rounded 10dp):
    - Light purple background (`#F1EEF7`) with box icon (`AppAssets.driverBoxLinear`).
    - If loaded (`isLoaded == true`): Light green background (`#EAF6EC`) with checkmark overlay (`AppAssets.driverCheckFill`).
- **Box Identifiers Column**:
  - Box ID: `#BOX-1256` (11px SemiBold, `color.onSurface`).
  - Order Code: `#MM-1256` (8px Regular, `color.onSurfaceVariant`) + Copy icon (`Icons.copy_rounded` / `solar:copy-outline`).
- **Vertical Divider**: Subtle hairline divider.
- **Meals & Destination Column**:
  - Meals count: `3 وجبات` (10px SemiBold) above label `عدد الوجبات` (`driverMealCountLabel`).
  - Destination Area: Area name (e.g. `حي النرجس`, 8px SemiBold) with location pin icon above/beside label `المنطقة` (`driverAreaLabel`).
- **Vertical Divider**: Subtle hairline divider.
- **Action & Status Column / Logical Start**:
  - Top Badge (`DriverBoxStatusPill`):
    - If unloaded: `لم يتم التحميل` (`driverStatusNotLoaded`, purple badge).
    - If loaded: `تم التحميل` (`driverStatusLoaded`, green badge).
  - Bottom Action:
    - If unloaded: Interactive button `استكمال الاجراء` (`driverCompleteAction`) with tap icon (`AppAssets.driverGestureTap`). Tapping triggers navigation to QR scan / pickup flow.
    - If loaded: Completed pill indicator `تم التحميل` with green checkmark icon.

---

## File Structure & Modularity (1 Widget Per File)

```text
lib/features/driver/orders/
├── domain/
│   ├── entities/
│   │   ├── driver_assigned_box_entity.dart
│   │   └── driver_boxes_filter_type.dart
│   └── fake_data/
│       └── driver_assigned_boxes_fake_data.dart
└── presentation/
    ├── screens/
    │   └── driver_assigned_boxes_screen.dart
    └── widgets/
        ├── driver_boxes_header_logo.dart
        ├── driver_boxes_title_bar.dart
        ├── driver_boxes_delivery_mode_chip.dart
        ├── driver_boxes_stats_banner.dart
        ├── driver_boxes_filter_bar.dart
        ├── driver_boxes_filter_tab_item.dart
        ├── driver_boxes_filter_action_button.dart
        ├── driver_assigned_box_card.dart
        ├── driver_box_icon_badge.dart
        ├── driver_box_ids_section.dart
        ├── driver_box_meals_and_area_section.dart
        ├── driver_box_action_section.dart
        └── driver_box_status_pill.dart
```

---

## State Management & Rebuild Control
- Local filter state managed cleanly within `DriverAssignedBoxesScreen` via `ValueNotifier<DriverBoxesFilterType>` so only the filter tabs and list view rebuild when toggling filters.
- List items constructed with `ListView.separated` and `const` constructors wherever possible.
- All callbacks (`onCompleteAction`, `onCopyBoxId`, `onFilterTap`) exposed cleanly as parameters.
