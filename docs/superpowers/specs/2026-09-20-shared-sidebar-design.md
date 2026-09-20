# Design Spec: Shared App Sidebar in Core (`AppSidebar`)

## Overview
Implement the shared navigation sidebar (Drawer) component in `lib/core/app_shell/` based on Figma Node `3038:11112` (`05.02A - Driver Home · Sidebar Open`). This sidebar is designed as a core reusable component used by both the **Driver** (`UserRole.driver`) and **Dispatcher** (`UserRole.operations`) roles.

The implementation strictly complies with [`rules/ui_rules.md`](file:///d:/projects/meal_mate_delivery/rules/ui_rules.md) and repository standards:
- One widget per file (all public classes, no private `_Widget` classes).
- Strict context extension usage (`final color = context.colorScheme;`, `final locale = context.localization;`).
- Zero hardcoded colors, strings, or spacing values.
- Directional layout support (inherited RTL/LTR without manual locale checks).
- Full localization keys in `app_ar.arb` and `app_en.arb`.
- Fake data source with clean entities.
- Selective rebuilds and `const` constructors.

---

## Visual & Functional Breakdown (Figma Node `3038:11112`)

### 1. Sidebar Container (`AppSidebar`)
- **Dimensions & Layout:**
  - Drawer width: 280dp (Figma proportion ~226dp on 390dp base screen).
  - Background: `color.surface` (`#FFFFFF`).
  - SafeArea enabled for top and bottom.
  - Scrollable content using `SingleChildScrollView` to prevent overflows on smaller devices.
- **Directionality:**
  - Placed in `Scaffold.drawer`. Under RTL (Arabic), Flutter natively slides the drawer in from the right edge. Under LTR (English), it slides from the left edge.

### 2. User Profile Header (`SidebarUserHeader`)
- **Avatar:**
  - Round avatar container (76x76dp), circular clip.
  - Default image: `assets/images/driver/driver_avatar.png` (matching Figma node `3038:11317`).
- **User Name:**
  - Label: `محمد علي` (or role-specific user name).
  - Style: `getBoldStyle(fontSize: FontSize.size14, color: color.onSurface)`.
- **Online Status Chip:**
  - Capsule pill container (Radius 99, background `#E3F5EC` / light green container).
  - Indicator dot: 8x8dp circle, color `#29BE63` (green / tertiary).
  - Status text: `متصل` (`sidebarStatusOnline`), style: `getRegularStyle(fontSize: FontSize.size10, color: Color(0xFF29BE63))`.

### 3. Navigation Items List (`SidebarNavList` & `SidebarNavItemTile`)
Each item consists of:
- **Active State (e.g. `الرئيسية` / Home):**
  - Container background: `color.primary.withValues(alpha: 0.08)` / `#F5F2FC`.
  - Start accent line: 4–6dp width bar at logical start edge, colored `color.primary` (`#603BC1`).
  - Leading icon: Primary color (`#603BC1`), 20x20dp.
  - Title text: Primary color (`#603BC1`), `getBoldStyle(fontSize: FontSize.size12)`.
- **Inactive State:**
  - Container background: transparent.
  - Leading icon: `color.onSurface` (`#000000`), 20x20dp.
  - Title text: `color.onSurface`, `getRegularStyle(fontSize: FontSize.size12)`.
  - Trailing chevron arrow: `Icons.chevron_left_rounded` (in RTL) / directional chevron icon (`color.onSurfaceVariant`).
  - Optional badge: Red circular indicator (16x16dp, color `color.error` / `#DD0C14`) with white bold text (e.g., `3`).
- **Item Separator:**
  - Hairline divider (`color.outlineVariant.withValues(alpha: 0.4)`).
- **Default Driver Navigation Items:**
  1. `الرئيسية` (`sidebarHome`)
  2. `الطلبات` (`sidebarOrders`)
  3. `الخريطة` (`sidebarMap`)
  4. `الإحصائيات` (`sidebarAnalytics`)
  5. `سجل العمليات` (`sidebarOperationsLog`)
  6. `الإشعارات` (`sidebarNotifications`, badge: 3)
  7. `المساعدة والدعم` (`sidebarHelpSupport`)
  8. `الإعدادات` (`sidebarSettings`)
  9. `السلامة والأمان` (`sidebarSafetySecurity`)
- **Default Dispatcher Navigation Items:**
  1. `الرئيسية` (`sidebarHome`)
  2. `الطلبات` (`sidebarOrders`)
  3. `الخريطة` (`sidebarMap`)
  4. `سجل العمليات` (`sidebarOperationsLog`)
  5. `الإشعارات` (`sidebarNotifications`)
  6. `المساعدة والدعم` (`sidebarHelpSupport`)
  7. `الإعدادات` (`sidebarSettings`)

### 4. Role Status Banner Card (`SidebarDriverStatusCard`)
- **Container:**
  - Rounded card (radius 14dp, background `#F8F7FD`, subtle border).
  - Padding: `EdgeInsets.all(Spacing.md)`.
- **Contents:**
  - Row / Column containing:
    - Status Title: `حالة السائق` (`sidebarDriverStatusTitle`), 10px Regular (`color.onSurfaceVariant`).
    - Active Status indicator row: Green dot (8x8dp) + `خارج التوصيل` (`sidebarDriverOffDuty`) or `في وضع التوصيل` (`sidebarDriverOnDuty`), 11px Bold (`color.primary`).
    - Subtitle: `متاح لتوصيل الطلبات` (`sidebarDriverStatusSubtitle`), 9px Regular (`color.onSurface`).
  - Illustration:
    - 3D delivery car asset: `assets/images/driver/driver_sidebar_car.png` (80x80dp), matching Figma node `3038:11389`.

### 5. Logout Button (`SidebarLogoutButton`)
- **Style:**
  - Outlined button container (height 42dp, border width 1.2dp, border color `color.primary`, radius 10dp, background white).
  - Icon: Logout icon (`Icons.logout_rounded` / `solar:logout-2-outline`), color `color.primary`.
  - Label: `تسجيل الخروج` (`sidebarLogout`), `getBoldStyle(fontSize: FontSize.size12, color: color.primary)`.
  - Action: Triggers `onLogout` callback or default auth logout navigation.

### 6. Version Footer (`SidebarVersionFooter`)
- **Text:**
  - `الإصدار 2.4.1` (`sidebarAppVersion`).
  - Style: `getRegularStyle(fontSize: FontSize.size10, color: color.onSurfaceVariant)`.
  - Centered alignment.

---

## File Structure & Modularity (1 Widget Per File)

```text
lib/core/app_shell/
├── domain/
│   ├── entities/
│   │   ├── sidebar_item_entity.dart
│   │   └── sidebar_user_entity.dart
│   └── fake_data/
│       └── sidebar_fake_data.dart
└── widgets/
    └── sidebar/
        ├── app_sidebar.dart
        ├── sidebar_user_header.dart
        ├── sidebar_user_status_chip.dart
        ├── sidebar_nav_list.dart
        ├── sidebar_nav_item_tile.dart
        ├── sidebar_notification_badge.dart
        ├── sidebar_driver_status_card.dart
        ├── sidebar_logout_button.dart
        └── sidebar_version_footer.dart
```

---

## Localization Keys Required

### Arabic (`app_ar.arb`):
- `"sidebarStatusOnline": "متصل"`
- `"sidebarHome": "الرئيسية"`
- `"sidebarOrders": "الطلبات"`
- `"sidebarMap": "الخريطة"`
- `"sidebarAnalytics": "الإحصائيات"`
- `"sidebarOperationsLog": "سجل العمليات"`
- `"sidebarNotifications": "الإشعارات"`
- `"sidebarHelpSupport": "المساعدة والدعم"`
- `"sidebarSettings": "الإعدادات"`
- `"sidebarSafetySecurity": "السلامة والأمان"`
- `"sidebarDriverStatusTitle": "حالة السائق"`
- `"sidebarDriverOffDuty": "خارج التوصيل"`
- `"sidebarDriverOnDuty": "في وضع التوصيل"`
- `"sidebarDriverStatusSubtitle": "متاح لتوصيل الطلبات"`
- `"sidebarLogout": "تسجيل الخروج"`
- `"sidebarAppVersion": "الإصدار {version}"`

### English (`app_en.arb`):
- `"sidebarStatusOnline": "Online"`
- `"sidebarHome": "Home"`
- `"sidebarOrders": "Orders"`
- `"sidebarMap": "Map"`
- `"sidebarAnalytics": "Analytics"`
- `"sidebarOperationsLog": "Operations Log"`
- `"sidebarNotifications": "Notifications"`
- `"sidebarHelpSupport": "Help & Support"`
- `"sidebarSettings": "Settings"`
- `"sidebarSafetySecurity": "Safety & Security"`
- `"sidebarDriverStatusTitle": "Driver Status"`
- `"sidebarDriverOffDuty": "Off Duty"`
- `"sidebarDriverOnDuty": "On Duty"`
- `"sidebarDriverStatusSubtitle": "Available for order delivery"`
- `"sidebarLogout": "Logout"`
- `"sidebarAppVersion": "Version {version}"`

---

## State Management & Rebuild Control
- `AppSidebar` is a lightweight `StatelessWidget` (or stateful if managing local selected item index internally without shell binding).
- Each list item is isolated in `SidebarNavItemTile`, taking primitive/immutable values and a click callback.
- `const` constructors used throughout.
- Clean callback propagation for item selection and logout.
