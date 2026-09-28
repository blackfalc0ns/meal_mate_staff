# Design Specification: Driver Support Tickets Screen (Tab 3)

## 1. Overview
This specification defines the architecture, design, and implementation plan for the **Driver Support Tickets Screen** (Figma Frame `09.07 - Support Tickets`, Node `3687:1683`). This screen replaces the placeholder `const Text("Support")` in `AppShellScreen` (tab index 3) of the MealMate Driver application.

The screen allows the delivery driver to:
- View summary metrics (KPIs) of support tickets: All, Under Review, Awaiting Response, Resolved.
- Filter tickets by status using interactive KPI cards.
- Search tickets by order/box number (e.g. `#BX-1256`) or issue title.
- View ticket details in a clean card list with box ID, status pill, issue title, location, and updated time.
- Tap a primary action button ("+ إبلاغ عن مشكلة جديدة") to report a new issue.

All code strictly conforms to `rules/ui_rules.md`.

---

## 2. Directory Structure & Files

```text
lib/
├── core/
│   └── l10n/
│       ├── app_ar.arb (updated with support tickets strings)
│       └── app_en.arb (updated with support tickets strings)
├── core/app_shell/screens/
│   └── app_shell_screen.dart (wire DriverSupportTicketsScreen at tab index 3)
└── features/driver/
    └── driver_support_tickets/
        ├── domain/
        │   ├── entities/
        │   │   ├── driver_support_ticket_entity.dart
        │   │   └── driver_support_ticket_status.dart
        │   └── fake_data/
        │       └── driver_support_tickets_fake_data.dart
        └── presentation/
            ├── screens/
            │   └── driver_support_tickets_screen.dart
            └── widgets/
                ├── driver_support_tickets_header.dart
                ├── driver_support_tickets_search_field.dart
                ├── driver_support_tickets_kpi_card.dart
                ├── driver_support_tickets_kpi_row.dart
                ├── driver_support_ticket_status_badge.dart
                ├── driver_support_ticket_card.dart
                ├── driver_support_tickets_list.dart
                ├── driver_support_tickets_empty_state.dart
                └── driver_support_tickets_report_button.dart
```

---

## 3. Domain & Fake Data

### 3.1 Entities
- **`DriverSupportTicketStatus`**:
  - `underReview` (قيد المراجعة)
  - `awaitingResponse` (بانتظار الرد)
  - `resolved` (تم الحل)
- **`DriverSupportTicketFilter`**:
  - `all` (الكل)
  - `underReview` (قيد المراجعة)
  - `awaitingResponse` (بانتظار الرد)
  - `resolved` (تم الحل)
- **`DriverSupportTicketEntity`**:
  - `id`: `String`
  - `boxNumber`: `String` (e.g., `#BX-1256`)
  - `title`: `String` (e.g., `العميل غير متواجد`)
  - `location`: `String` (e.g., `منطقة السالمية`)
  - `updatedAt`: `String` (e.g., `آخر تحديث منذ 20 دقيقة`)
  - `status`: `DriverSupportTicketStatus`

### 3.2 Fake Data (`DriverSupportTicketsFakeData`)
Contains 6 fake tickets matching Figma counts:
1. `#BX-1256` - "العميل غير متواجد", "منطقة السالمية", "آخر تحديث منذ 20 دقيقة", Status: `underReview`
2. `#BX-1257` - "العنوان غير واضح", "منطقة حولي", "آخر تحديث منذ 45 دقيقة", Status: `awaitingResponse`
3. `#BX-1258` - "تأخير في الوصول", "منطقة الفحيحيل", "آخر تحديث منذ ساعة", Status: `resolved`
4. `#BX-1259` - "إعادة جدولة موعد التسليم", "منطقة الشويخ", "آخر تحديث منذ ساعتين", Status: `resolved`
5. `#BX-1260` - "تلف في محتويات الطلب", "منطقة اليرموك", "آخر تحديث منذ 15 دقيقة", Status: `underReview`
6. `#BX-1261` - "تم استلام الطلب مسبقاً", "منطقة العديلية", "آخر تحديث منذ 3 ساعات", Status: `resolved`

Metrics derived:
- All: 6
- Under Review: 2
- Awaiting Response: 1
- Resolved: 3

---

## 4. UI Architecture & Widgets (1 Class Per File)

### 4.1 `driver_support_tickets_header.dart`
- Title: `locale.driverSupportTicketsTitle` ("الدعم"), style: `getBoldStyle(fontSize: FontSize.size20, color: color.onSurface)`.
- Subtitle: `locale.driverSupportTicketsSubtitle` ("تابع البلاغات المفتوحة بسرعة"), style: `getRegularStyle(fontSize: FontSize.size12, color: color.onSurfaceVariant)`.
- Center aligned.

### 4.2 `driver_support_tickets_search_field.dart`
- Height: `Spacing.inputHeight` (52).
- Rounded border with `Spacing.inputRadius` (14), border color: `color.outline`.
- Background: `color.surface`.
- Prefix icon: `Icons.search_rounded` in `color.onSurfaceVariant`.
- Hint text: `locale.driverSupportTicketsSearchHint`.
- Triggers `onChanged(String query)` to filter list.

### 4.3 `driver_support_tickets_kpi_card.dart`
- Single card in the KPI filter row.
- Displays:
  - Top: Icon (`Icons.receipt_long_rounded` for All, `Icons.hourglass_empty_rounded` for Under Review, `Icons.access_time_rounded` for Awaiting Response, `Icons.check_circle_outline_rounded` for Resolved).
  - Middle: Status label.
  - Bottom: Number count in bold.
- Background & borders:
  - Selected state: highlighted with `color.primaryContainer` and border `color.primary`.
  - Normal state: soft tinted surface according to status (`color.surface` / `color.surfaceContainerHighest`), border `color.outlineVariant`.
- Tap handler to activate filter.

### 4.4 `driver_support_tickets_kpi_row.dart`
- Composes 4 `DriverSupportTicketsKpiCard` widgets in a `Row` with `Spacing.sm` spacing.
- Each item is wrapped in `Expanded` for consistent grid distribution.

### 4.5 `driver_support_ticket_status_badge.dart`
- Rounded pill badge (`Spacing.radiusPill`).
- Contains a colored dot (`Container` with circle shape) + status text.
- Under Review: red dot, red text, `color.errorContainer` surface.
- Awaiting Response: secondary amber/purple dot, secondary text, `color.secondaryContainer` surface.
- Resolved: tertiary green dot, tertiary text, `color.tertiaryContainer` surface.

### 4.6 `driver_support_ticket_card.dart`
- Container card with `Spacing.cardRadius` (14), `color.surface`, border `color.outline`.
- Padding: `Spacing.cardPadding` (16).
- Row 1 (Header):
  - Box icon (`Icons.inventory_2_rounded` in `color.primary`) + `ticket.boxNumber` in `getBoldStyle(fontSize: FontSize.size14, color: color.primary)`.
  - `DriverSupportTicketStatusBadge(status: ticket.status)`.
- Row 2 (Content):
  - Issue title (`ticket.title`) in `getSemiBoldStyle(fontSize: FontSize.size14, color: color.onSurface)`.
  - Location row: `Icons.location_on_rounded` (14dp) + `ticket.location` in `getRegularStyle(fontSize: FontSize.size12, color: color.onSurfaceVariant)`.
- Divider: `Divider(color: color.outlineVariant, height: 1, thickness: 1)`.
- Row 3 (Footer):
  - Clock icon (`Icons.access_time_rounded`) + `ticket.updatedAt` in `getRegularStyle(fontSize: FontSize.size11, color: color.onSurfaceVariant)`.
  - InkWell: "عرض التفاصيل" in `color.primary` with `Icons.arrow_back_ios_rounded` / `Icons.chevron_left_rounded`.

### 4.7 `driver_support_tickets_list.dart`
- `ListView.separated` rendering `DriverSupportTicketCard` items.
- Separator: `SizedBox(height: Spacing.md)`.
- If list is empty, renders `DriverSupportTicketsEmptyState`.

### 4.8 `driver_support_tickets_empty_state.dart`
- Shows search / empty icon and `locale.driverSupportTicketsNoResults`.

### 4.9 `driver_support_tickets_report_button.dart`
- Prominent button with height `Spacing.buttonHeight` (52), radius `Spacing.buttonRadius` (14).
- Background: `color.primary`, text & icon: `color.onPrimary`.
- Icon: `Icons.add_rounded`, label: `locale.driverSupportTicketsReportNewIssue`.

### 4.10 `driver_support_tickets_screen.dart`
- Full screen hosting the stateful view:
  - Manages `_selectedFilter` (`DriverSupportTicketFilter.all` by default) and `_searchQuery`.
  - Filters `DriverSupportTicketsFakeData.tickets` efficiently without rebuilding unaffected UI.
  - SafeArea padding: horizontal `Spacing.screenH` (20), vertical `Spacing.screenV` (16).
  - Pinned or scroll-integrated bottom report button.

---

## 5. Localization Additions
Added to `app_ar.arb` and `app_en.arb`:
- `driverSupportTicketsTitle`
- `driverSupportTicketsSubtitle`
- `driverSupportTicketsSearchHint`
- `driverSupportTicketsFilterAll`
- `driverSupportTicketsStatusUnderReview`
- `driverSupportTicketsStatusAwaitingResponse`
- `driverSupportTicketsStatusResolved`
- `driverSupportTicketsViewDetails`
- `driverSupportTicketsReportNewIssue`
- `driverSupportTicketsNoResults`

---

## 6. Integration in `AppShellScreen`
In `lib/core/app_shell/screens/app_shell_screen.dart`:
```dart
  List<Widget> _defaultPages(BuildContext context, int activeIndex) {
    if (widget.role == UserRole.driver) {
      return [
        const DriverStartWorkScreen(),
        const DriverAssignedBoxesScreen(),
        const DriverMapScreen(),
        const DriverSupportTicketsScreen(),
        const DriverProfileScreen(),
      ];
    }
```

---

## 7. Verification & Compliance
- [x] All colors accessed via `context.colorScheme`. No `Colors.*` or hardcoded hex colors.
- [x] All user-facing strings accessed via `context.localization`.
- [x] All text styles from `styles_manager.dart`.
- [x] All spacing from `spacing.dart`.
- [x] Exactly one widget class per file.
- [x] Directional RTL/LTR compliance using `EdgeInsetsDirectional` and directional alignments.
- [x] Run `flutter gen-l10n` and `flutter analyze` to ensure zero errors or warnings.
