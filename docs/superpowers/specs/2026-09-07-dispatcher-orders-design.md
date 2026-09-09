# Design Spec: Dispatcher Orders Screen (10.01 - Dispatcher Dashboard)

## Overview
Implement the Dispatcher Orders Screen (Figma Node `1631-2980`) for the MealMate Delivery mobile app. This screen represents the box queue awaiting assignment for the Dispatcher role (`UserRole.operations`), adhering strictly to `rules/ui_rules.md`.

## Visual & Functional Breakdown

### 1. Header Section
- **Restaurant Identifier**: Store icon with title `مطعم MealMate الكويت` (`dispatcherRestaurantName`).
- **Role Chip**: `Dispatcher` badge with person icon, light primary background (`primaryContainer`), primary text (`primary`).
- **Screen Titles**:
  - Main Title: `الطلبات` (`dispatcherOrdersTitle`) - 22px Bold.
  - Subtitle: `طابور البوكسات في انتظار الإسناد` (`dispatcherOrdersSubtitle`) - 13px Regular, onSurfaceVariant.

### 2. Metrics Section (KPIs)
Four metrics cards showing real-time dispatch queue counts:
1. **Pending Assignment (`بانتظار الإسناد`)**:
   - Count: `23`
   - Accent: `warning` (Orange)
   - Icon: Clock
2. **Assigned (`تم الإسناد`)**:
   - Count: `37`
   - Accent: `tertiary` / `success` (Green)
   - Icon: Check circle
3. **In Delivery (`قيد التوصيل`)**:
   - Count: `58`
   - Accent: `info` (Blue - added to semantic colors)
   - Icon: Delivery bike
4. **Issues / Problems (`مشاكل`)**:
   - Count: `2`
   - Accent: `error` (Red)
   - Icon: Alert / Timer

### 3. Filter Bar
Horizontally scrollable filter pills allowing status filtering:
- `الكل 23` (All) - Active by default
- `بانتظار الإسناد 23` (Dot indicator: Warning)
- `تم الإسناد 37` (Dot indicator: Success)
- `قيد التوصيل 58` (Dot indicator: Info)
- `مشاكل 2` (Dot indicator: Error)

### 4. Order Box Card (`DispatcherOrderCard`)
Each card contains:
- **Card Header**:
  - Box ID (e.g., `#BX-1256`) with box icon.
  - Priority Badge:
    - `جديد` (New) - Green tint
    - `عاجل` (Urgent) - Red tint with siren icon
    - `أولوية عالية` (High Priority) - Amber tint with star icon
    - `عادي` (Normal) - Muted grey tint
- **Card Body**:
  - **Info Column**:
    - Area (e.g., `منطقة السالمية`)
    - Time window (e.g., `09:30-10:30 ص`) with clock icon
    - Meals count (e.g., `8 وجبات` under `وجبات اليوم`) with cutlery icon
    - Distance (e.g., `6.2 كم` under `المسافة`) with pin icon
    - Driver Suggestion: e.g., `اقتراح : أحمد الأقرب` or `الأقل ضغطاً : محمد` with avatar
  - **Action Buttons Column**:
    - Primary Button: `إسناد` (Assign) with user-plus icon
    - Outlined Button: `التفاصيل` (Details)

### 5. Bottom Navigation Bar
Persistent navigation with 5 items:
1. `الرئيسية` (Home)
2. `الطلبات` (Orders) -> **Active State** with purple background pill indicator
3. `التوصيل` (Delivery)
4. `الدعم` (Support)
5. `الحساب` (Account)

## Architecture & Code Rules Compliance

1. **One Widget Per File Rule**:
   Every widget is strictly in its own file in `lib/features/dispatcher/presentation/widgets/`.
2. **Context Extension Rule**:
   Every `build` method starts with:
   ```dart
   final color = context.colorScheme;
   final locale = context.localization;
   ```
3. **No Hardcoded Values**:
   - All colors come from `context.colorScheme`.
   - All text comes from `context.localization` (`app_ar.arb` / `app_en.arb`).
   - All spacing comes from `Spacing`.
   - All text styles come from `styles_manager.dart`.
4. **Directionality (RTL / LTR)**:
   - Uses `EdgeInsetsDirectional` and `AlignmentDirectional`.
   - Zero language checks or manual list reversing.
5. **Data Layer**:
   - `DispatcherOrderEntity`, `DispatcherMetricEntity`, `DispatcherFilterEntity`.
   - `DispatcherFakeData` provides mock data for UI rendering.
