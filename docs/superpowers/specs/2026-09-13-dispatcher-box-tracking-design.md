# Design Spec: Dispatcher Box Tracking Screen (10.08 - Box Tracking)

## Overview
Implement the Dispatcher Box Tracking Screen (Figma Node `1825:9412`, `10.08 - Box Tracking`) for the MealMate Delivery mobile app under `lib/features/dispatcher/box_tracking/`. This screen allows dispatchers (`UserRole.operations`) to track the real-time status of an assigned box/order, view delivery milestone progress, interact with the assigned driver (live tracking, call, message), review order metadata, and report issues.

The implementation strictly adheres to [`rules/ui_rules.md`](file:///d:/projects/meal_mate_delivery/rules/ui_rules.md) and repository standards (One widget per file, buildContext rules, color scheme usage, full RTL/LTR localization, `Spacing.*` tokens, and `styles_manager.dart`).

---

## Visual & Functional Breakdown (from Figma Node `1825:9412`)

### 1. Header (`BoxTrackingAppBar`)
- **Back Navigation**: Left chevron button (`Icons.arrow_back_ios_new_rounded`).
- **Title**: `متابعة البوكس` (`boxTrackingTitle`) — Centered Bold, `color.onSurface`.
- **Action**: Right options button (`Icons.more_vert_rounded`).
- Wraps `CustomAppBar` from `lib/core/widget/custom_app_bar.dart`.

### 2. Box Header Card (`BoxTrackingHeaderCard`)
Surface card displaying the primary identification of the box:
- **Box ID**: `#BX-10256` in Bold primary color.
- **Status Badge**: `في الطريق` (`boxTrackingStatusOnTheWay`) — Soft primary pill badge with status dot indicator.
- **Customer**: `عميل: أحمد العتيبي` (`boxTrackingCustomerLabel`).
- **Address & Time Row**:
  - Location pin icon + `السليمانية، الرياض` (truncated with ellipsis if needed).
  - Clock icon + `12:30 م`.
- **Visual Asset**: 3D box graphic (`AppAssets.driverBox3d`).

### 3. Timeline / Stepper Card (`BoxTrackingTimelineCard`)
A structured timeline card showing the delivery lifecycle:
- **Header**: `حالة البوكس` (`boxTrackingTimelineTitle`).
- **Steps** rendered via `BoxTrackingTimelineStepItem`:
  1. `جاهز في المطعم` — Completed (Green checkmark badge, timestamp `اليوم 10:15 ص`).
  2. `استلمه السائق` — Completed (Green checkmark badge, timestamp `اليوم 10:28 ص`).
  3. `في الطريق للتوصيل` — Active (Solid primary circle with pulsating/outer border, timestamp `اليوم 10:45 ص`, highlighted step container).
  4. `تم التسليم` — Pending (Muted grey circle with no timestamp).
- Connecting vertical dashed/solid lines respecting RTL/LTR directionality.

### 4. Assigned Driver Card (`BoxTrackingDriverCard`)
Card dedicated to the courier handling this box:
- **Driver Info**:
  - Avatar placeholder with online status indicator dot.
  - Name: `أحمد السعيد` (`driver.name`).
  - ID badge: `DR-1025` (`driver.id`).
- **Actions Row**:
  - `تتبع مباشر` (`boxTrackingLiveTrack`): `AppButton` (variant: `filled`, primary color, icon: `Icons.navigation_rounded` / location pin).
  - `رسالة` (`boxTrackingSendMessage`): `AppButton` (variant: `outlined`, icon: `AppAssets.driverActionMsg`).
  - `اتصال` (`boxTrackingCall`): `AppButton` (variant: `outlined`, icon: `AppAssets.driverActionCall`).

### 5. Box Details Card (`BoxTrackingDetailsCard`)
Card showing detailed order specifications in structured rows:
- `نوع البرنامج` (`boxTrackingPlanType`): `دايت متوازن`.
- `تاريخ الطلب` (`boxTrackingOrderDate`): `اليوم 09:50 ص`.
- `عدد الوجبات` (`boxTrackingMealCount`): `3 وجبات (يوم كامل)`.
- `ملاحظات العميل` (`boxTrackingCustomerNotes`): `يرجى الاتصال قبل الوصول`.

### 6. Bottom Action Button (`BoxTrackingReportIssueButton`)
- Outlined button with warning/error styling:
  - Text: `الإبلاغ عن مشكلة في البوكس` (`boxTrackingReportIssue`).
  - Icon: `Icons.warning_amber_rounded` or alert icon.
  - Color: `color.error`.

---

## File Structure & One-Widget-Per-File Rule

```text
lib/features/dispatcher/box_tracking/
├── domain/
│   ├── entities/
│   │   ├── box_tracking_entity.dart
│   │   ├── box_tracking_driver_entity.dart
│   │   └── box_tracking_step_entity.dart
│   └── fake_data/
│       └── box_tracking_fake_data.dart
└── presentation/
    ├── screens/
    │   └── dispatcher_box_tracking_screen.dart
    └── widgets/
        ├── box_tracking_app_bar.dart
        ├── box_tracking_header_card.dart
        ├── box_tracking_timeline_card.dart
        ├── box_tracking_timeline_step_item.dart
        ├── box_tracking_driver_card.dart
        ├── box_tracking_details_card.dart
        ├── box_tracking_details_row.dart
        └── box_tracking_report_issue_button.dart
```

---

## Repository Standards & UI Rules Compliance

1. **One Widget Per File**:
   Every widget (including row items and step items) is in its own public file. No private helper classes (`_Card`, `_Item`, etc.).
2. **Context Extension Rule**:
   - `final color = context.colorScheme;`
   - `final locale = context.localization;`
   - Only declared when actually used in `build`.
3. **No Hardcoded Values**:
   - Strings: Localized via `app_ar.arb` & `app_en.arb`.
   - Colors: Exclusively through `color.*` (`context.colorScheme`).
   - Spacing: Exclusively through `Spacing.*` constants.
   - Text styles: Through `styles_manager.dart` functions (`getBoldStyle`, `getRegularStyle`, `getSemiBoldStyle`).
4. **Directionality & Responsiveness**:
   - Directional padding: `EdgeInsetsDirectional.only()`, `EdgeInsets.symmetric()`.
   - Natural layout flow via `Row`, `Column`, `Expanded`, `Flexible`.
   - Overflow prevention on compact screens.
5. **Reusability**:
   - Reuses `CustomAppBar`, `AppButton`, `AppAssets`.
6. **Routing**:
   - Add `AppRoutes.boxTracking = '/box-tracking'` to `app_routes.dart` and `routing_generator.dart`.
7. **Automated Verification**:
   - Widget test: `test/features/dispatcher/box_tracking/dispatcher_box_tracking_screen_test.dart` verifying all components, callbacks, RTL Arabic, English, and narrow viewports.
