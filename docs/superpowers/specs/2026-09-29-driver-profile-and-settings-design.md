# Design Specification: Driver Profile & Settings Refactoring

- **Date:** 2026-09-29
- **Feature:** Driver Profile & Settings Separation
- **Figma Source of Truth:** Frame `09.02 الملف الشخصي` (Node ID: `1275-4107`)
- **UI Guidelines:** `rules/ui_rules.md`

## 1. Overview & Goal

Currently, `DriverProfileScreen` implements the driver's settings functionality (personal information, vehicle info, documents, language, notifications, sound, support links, and logout).
According to Figma node `1275-4107`, the true Driver Profile screen is "الملف الشخصي والدعم" (Profile & Support). It contains:
1. Header with MealMate logo, centered title and subtitle, and notification button.
2. Hero Profile Card with dark navy surface, avatar with online indicator, driver ID badge, rating, and 4 driver metrics (member since, rating, acceptance rate, total orders).
3. Vehicle Information Card with vehicle type, model, plate number, and active status chip.
4. Support & Assistance Section with "تواصل مع الدعم" card and "حالة طلب الدعم الأخير" card.
5. Quick Actions Row with 3 cards: Language ("اللغة"), Settings ("الإعدادات"), and Logout ("تسجيل الخروج").
6. Delivery Policy Banner ("سياسة التسليم").

### Scope & Constraints
- Keep all files inside `lib/features/driver/driver_profile/` without introducing external feature directories.
- Rename the existing screen to `DriverSettingsScreen` (`driver_settings_screen.dart`).
- Implement the new `DriverProfileScreen` (`driver_profile_screen.dart`) adhering strictly to `rules/ui_rules.md`.
- Each custom widget in its own file (single widget class per file).
- No hardcoded text, colors, dimensions, or asset paths.
- Full RTL and LTR support via directional APIs.

---

## 2. Architecture & File Structure

All files reside in `lib/features/driver/driver_profile/`:

```
lib/features/driver/driver_profile/
├── domain/
│   ├── entities/
│   │   └── driver_profile_entity.dart        (Existing - already matches Figma data)
│   └── fake_data/
│       └── driver_profile_fake_data.dart     (Existing - already matches Figma default values)
└── presentation/
    ├── screens/
    │   ├── driver_settings_screen.dart       (Renamed from driver_profile_screen.dart)
    │   └── driver_profile_screen.dart        (New screen matching Figma node 1275-4107)
    └── widgets/
        ├── driver_settings_header.dart       (Existing settings widget)
        ├── driver_settings_logout_button.dart(Existing settings widget)
        ├── driver_settings_menu_tile.dart    (Existing settings widget)
        ├── driver_settings_profile_card.dart (Existing settings widget)
        ├── driver_settings_section_card.dart (Existing settings widget)
        ├── driver_profile_header.dart        (New: CustomAppBar.logo with title/subtitle & notification button)
        ├── driver_profile_hero_card.dart     (New: Dark navy card with avatar, rating, and 4 metrics)
        ├── driver_profile_vehicle_card.dart  (New: Vehicle info card with active status badge)
        ├── driver_profile_contact_card.dart  (New: Contact support card with headset icon)
        ├── driver_profile_ticket_card.dart   (New: Recent ticket status card with 'View all' action)
        ├── driver_profile_quick_actions_row.dart (New: Row containing the 3 quick action items)
        ├── driver_profile_quick_action_item.dart (New: Single quick action card with icon, title, subtitle)
        └── driver_profile_policy_banner.dart (New: Delivery policy soft purple banner with orange check)
```

---

## 3. Navigation & Routing

1. **New Route**:
   - `AppRoutes.driverSettings = '/driver-settings'` added in `lib/config/routing/app_routes.dart`.
   - `AppRoutes.driverProfile` remains `'/driver-profile'`.
2. **Routing Generator (`routing_generator.dart`)**:
   - `case AppRoutes.driverSettings:` renders `DriverSettingsScreen`.
   - `case AppRoutes.driverProfile:` renders `DriverProfileScreen`.
3. **App Shell (`app_shell_screen.dart`)**:
   - Tab 4 (the 5th tab) displays `const DriverProfileScreen()`.
4. **Profile Interactions**:
   - Tapping the "الإعدادات" (Settings) card calls `context.pushNamed(AppRoutes.driverSettings)`.
   - Tapping the "تسجيل الخروج" (Logout) card triggers the confirmation dialog.
   - Tapping the "تواصل مع الدعم" card or "عرض الكل" on recent ticket calls `context.pushNamed(AppRoutes.driverSupport)` or `context.pushNamed(AppRoutes.driverSupportTickets)`.
   - Tapping notification bell calls `context.pushNamed(AppRoutes.driverNotifications)`.

---

## 4. UI Components Detail & Design Tokens

### 4.1 Header (`driver_profile_header.dart`)
- Uses `CustomAppBar.logo`:
  - `logo`: MealMate logo (`AppAssets.authHeaderLogo`, height 29).
  - `title`: `locale.driverProfileTitle` ("الملف الشخصي والدعم").
  - `subtitle`: `locale.driverProfileSubtitle` ("إدارة معلوماتك والحصول على المساعدة").
  - `showBackButton`: `false`.
  - `actions`: `[NotificationButton(onPressed: onNotificationTap), const SizedBox(width: Spacing.xs)]`.

### 4.2 Hero Profile Card (`driver_profile_hero_card.dart`)
- **Background**: `color.inverseSurface` (Dark navy `#1B1540`).
- **Border radius**: `Spacing.cardRadius` (14).
- **Top section**:
  - Avatar image (from `profile.avatarAsset`) with green online dot indicator (`•` / `color.tertiary` / `AppColors.success`).
  - Name: `profile.name` (`getBoldStyle(fontSize: FontSize.size16, color: color.onInverseSurface)`).
  - Driver ID pill: `profile.driverId` + `locale.driverIdLabel` in a translucent surface container.
  - Rating: Star icon (`Icons.star_rounded`, gold/orange) + `profile.rating` + `(${profile.reviewsCount} ${locale.driverRatingReviews})`.
- **Divider**: Opacity-reduced divider line (`color.outline.withValues(alpha: 0.2)`).
- **4 Metrics columns**:
  1. `locale.driverMemberSince` / `profile.memberSince`
  2. `locale.driverRating` / `"${profile.rating} ★"`
  3. `locale.driverAcceptanceRate` / `"${profile.acceptanceRate}%"`
  4. `locale.driverTotalOrders` / `"${profile.totalOrders} ${locale.driverOrdersCountLabel}"`

### 4.3 Vehicle Info Card (`driver_profile_vehicle_card.dart`)
- Container with `color.surface` and border `color.outlineVariant`.
- Header: Car icon (`Icons.directions_car_outlined`, `color.primary`) + `locale.driverVehicleInfo` on start, status badge `locale.driverVehicleActive` (green chip with `•`) on end.
- 3 columns / row items:
  1. `locale.driverVehicleType`: `profile.vehicleType`
  2. `locale.driverVehicleModel`: `profile.vehicleModel`
  3. `locale.driverPlateNumber`: `profile.plateNumber`

### 4.4 Contact Support Card (`driver_profile_contact_card.dart`)
- Section Header: Headset icon (`color.primary`) + `locale.driverSupportSectionTitle` ("الدعم والمساعدة").
- Card with rounded corner:
  - Trailing: Directional chevron (`Icons.chevron_left_rounded` or `Icons.chevron_right_rounded`).
  - Content: `locale.driverContactSupportTitle` (bold) + `locale.driverContactSupportDesc` (muted).
  - Icon: Rounded square in `color.primary` with white headset icon.

### 4.5 Recent Ticket Card (`driver_profile_ticket_card.dart`)
- Header row: Title `locale.driverRecentTicketTitle` + "عرض الكل" button (`locale.driverViewAll`).
- Card content:
  - Trailing chevron.
  - Date: `profile.recentTicketDate` + `locale.driverTicketDateLabel`.
  - Status chip: `• ${locale.driverTicketStatusResolved}` (green) + `locale.driverTicketResolvedSubtitle`.
  - Ticket ID & Subject: `profile.recentTicketId` + `profile.recentTicketSubject`.
  - Icon: Purple rounded box with ticket icon (`Icons.confirmation_number_outlined`).

### 4.6 Quick Actions Row & Item (`driver_profile_quick_actions_row.dart`, `driver_profile_quick_action_item.dart`)
- Row of 3 equal `Expanded` cards:
  - **Item 1: Language**: Globe icon (`Icons.language_rounded`), title `locale.driverQuickActionLanguage`, subtitle `locale.driverQuickActionLanguageValue`.
  - **Item 2: Settings**: Gear icon (`Icons.settings_outlined`), title `locale.driverQuickActionSettings`, subtitle `locale.driverQuickActionSettingsDesc`. On tap -> `onSettingsTap`.
  - **Item 3: Logout**: Logout icon (`Icons.logout_rounded`), title `locale.driverQuickActionLogout`, subtitle `locale.driverQuickActionLogoutDesc`. On tap -> `onLogoutTap`.

### 4.7 Delivery Policy Banner (`driver_profile_policy_banner.dart`)
- Background: Soft purple/lavender container (`color.primaryContainer`).
- End/trailing icon: Orange circle with checkmark (`Icons.check_rounded`, `AppColors.warning`).
- Title: `locale.driverDeliveryPolicyTitle` ("سياسة التسليم").
- Body: RichText with "يدوياً" highlighted in orange (`AppColors.warning`) and remaining text in muted primary.

---

## 5. Testing & Verification

1. **Settings Screen Test (`test/driver_settings_screen_test.dart`)**:
   - Verifies all existing settings cards, header, and logout button render properly.
2. **Profile Screen Test (`test/driver_profile_screen_test.dart`)**:
   - Verifies the new `DriverProfileScreen` renders all cards: header, hero card with 4 stats, vehicle card, support card, ticket card, 3 quick action items, and delivery policy banner.
   - Verifies navigation callbacks when tapping Settings, Logout, and Support.
   - Verifies both RTL and LTR rendering without layout errors or overflow.
3. **Flutter Analyzer**:
   - Run `flutter analyze` to ensure zero errors and zero warnings.
