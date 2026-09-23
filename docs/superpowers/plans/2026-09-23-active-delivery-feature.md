# Active Delivery Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the complete Driver Active Delivery flow with 6 screens, clean architecture, fake data simulation, isolated map updates, localization, and widget tests.

**Architecture:** Clean Architecture (`domain/`, `data/`, `presentation/`). State management via `flutter_bloc` (`Cubit`). Strict rebuild isolation for Google Maps stream via custom `DriverTrackingMapView`. Zero new external packages. Inherited RTL/LTR support.

**Tech Stack:** Flutter, Dart, google_maps_flutter, flutter_bloc, get_it.

**Spec:** `docs/superpowers/specs/2026-09-23-active-delivery-flow-design.md`

## Global Constraints
- Strictly follow `rules/ui_rules.md`.
- No new packages in `pubspec.yaml`.
- No hardcoded strings, colors, spacing, or dimensions. Use `context.colorScheme`, `styles_manager.dart`, `Spacing.*`, and `context.localization`.
- Every custom widget in its own file under `widgets/`.
- Directionality inherited (never check `languageCode == 'ar'`).
- The OTP confirmation screen is forbidden (no `driver_delivery_confirmation_screen.dart`).
- Location stream isolated to the map widget only.

---

### Task 1: Domain Entities & Fake Data
**Files:**
- Create: `lib/core/constants/assets_fake.dart`
- Create: `lib/features/driver/active_delivery/domain/entities/active_delivery_order_entity.dart`
- Create: `lib/features/driver/active_delivery/domain/entities/active_delivery_location_entity.dart`
- Create: `lib/features/driver/active_delivery/domain/entities/active_delivery_trip_entity.dart`
- Create: `lib/features/driver/active_delivery/domain/entities/delivery_failure_reason_entity.dart`
- Create: `lib/features/driver/active_delivery/domain/entities/return_box_entity.dart`
- Create: `lib/features/driver/active_delivery/domain/fake_data/driver_active_delivery_fake_data.dart`
- Create: `lib/features/driver/active_delivery/domain/repositories/active_delivery_repository.dart`
- Test: `test/features/driver/active_delivery/domain/active_delivery_entities_test.dart`

**Interfaces:**
- Produces: `ActiveDeliveryTripEntity`, `ActiveDeliveryOrderEntity`, `ActiveDeliveryLocationEntity`, `DeliveryFailureReasonEntity`, `ReturnBoxEntity`, `ActiveDeliveryRepository`, `DriverActiveDeliveryFakeData`.

- [ ] **Step 1: Write test for entities and fake data integrity**
- [ ] **Step 2: Run test to verify it fails**
- [ ] **Step 3: Implement domain entities, AssetsFake, and fake data with Kuwait coordinates & route**
- [ ] **Step 4: Run test to verify it passes**
- [ ] **Step 5: Verify analyzer and formatting**

---

### Task 2: Data Layer (Fake Repository & Simulated Location Stream)
**Files:**
- Create: `lib/features/driver/active_delivery/data/repositories/active_delivery_fake_repository_impl.dart`
- Test: `test/features/driver/active_delivery/data/active_delivery_fake_repository_test.dart`

**Interfaces:**
- Consumes: `ActiveDeliveryRepository`, `DriverActiveDeliveryFakeData`.
- Produces: `ActiveDeliveryFakeRepositoryImpl` implementing `watchDriverLocation()`, `getActiveTrip()`, state updates.

- [ ] **Step 1: Write failing test for repository and simulated location stream**
- [ ] **Step 2: Run test to verify failure**
- [ ] **Step 3: Implement `ActiveDeliveryFakeRepositoryImpl` with controlled Stream controller and timer**
- [ ] **Step 4: Run test to verify it passes**
- [ ] **Step 5: Verify clean cancellation and dispose**

---

### Task 3: Localization Setup
**Files:**
- Modify: `lib/core/l10n/app_en.arb`
- Modify: `lib/core/l10n/app_ar.arb`

- [ ] **Step 1: Add localization keys for all 6 screens in `app_en.arb`**
- [ ] **Step 2: Add Arabic translations for all keys in `app_ar.arb`**
- [ ] **Step 3: Run `flutter gen-l10n` to update `app_localizations.dart`**
- [ ] **Step 4: Verify generated files compile cleanly**

---

### Task 4: Screen 1 - Start Delivery Route
**Files:**
- Create: `lib/features/driver/active_delivery/presentation/manager/active_delivery_view_model.dart`
- Create: `lib/features/driver/active_delivery/presentation/manager/active_delivery_state.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/start_route_header.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/start_route_subtitle_banner.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/start_route_map_preview.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/start_route_customer_card.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/start_route_action_button.dart`
- Create: `lib/features/driver/active_delivery/presentation/screens/driver_start_delivery_route_screen.dart`
- Modify: `lib/config/routing/app_routes.dart`
- Modify: `lib/config/routing/routing_generator.dart`
- Test: `test/features/driver/active_delivery/presentation/screens/driver_start_delivery_route_screen_test.dart`

- [ ] **Step 1: Write widget test for `DriverStartDeliveryRouteScreen`**
- [ ] **Step 2: Implement `ActiveDeliveryViewModel`, state, and Screen 1 custom widgets matching Figma node `3038:10963`**
- [ ] **Step 3: Register route `AppRoutes.driverStartDeliveryRoute`**
- [ ] **Step 4: Run widget tests and verify they pass**
- [ ] **Step 5: Inspect visually and check RTL/LTR**

---

### Task 5: Screen 2 - Active Delivery Tracking (Strict Stream Isolation)
**Files:**
- Create: `lib/features/driver/active_delivery/presentation/widgets/driver_tracking_map_view.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/driver_tracking_app_bar.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/driver_tracking_stepper.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/driver_tracking_customer_card.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/driver_tracking_bottom_actions.dart`
- Create: `lib/features/driver/active_delivery/presentation/screens/driver_active_delivery_tracking_screen.dart`
- Modify: `lib/config/routing/app_routes.dart`
- Modify: `lib/config/routing/routing_generator.dart`
- Test: `test/features/driver/active_delivery/presentation/screens/driver_active_delivery_tracking_screen_test.dart`

- [ ] **Step 1: Write widget test for `DriverActiveDeliveryTrackingScreen`**
- [ ] **Step 2: Implement `DriverTrackingMapView` subscribing to location stream without rebuilding parent**
- [ ] **Step 3: Implement stepper, customer card, and bottom actions matching Figma node `2739:1613`**
- [ ] **Step 4: Register route `AppRoutes.driverActiveDeliveryTracking`**
- [ ] **Step 5: Run widget tests and verify pass**

---

### Task 6: Screen 3 - Delivery Delay
**Files:**
- Create: `lib/features/driver/active_delivery/presentation/widgets/delivery_delay_header.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/delivery_delay_hero_banner.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/delivery_delay_info_card.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/delivery_delay_actions.dart`
- Create: `lib/features/driver/active_delivery/presentation/screens/driver_delivery_delay_screen.dart`
- Modify: `lib/config/routing/app_routes.dart`
- Modify: `lib/config/routing/routing_generator.dart`
- Test: `test/features/driver/active_delivery/presentation/screens/driver_delivery_delay_screen_test.dart`

- [ ] **Step 1: Write widget test for `DriverDeliveryDelayScreen`**
- [ ] **Step 2: Implement Screen 3 custom widgets matching Figma node `1977:4969`**
- [ ] **Step 3: Register route `AppRoutes.driverDeliveryDelay`**
- [ ] **Step 4: Run widget tests and verify pass**

---

### Task 7: Screen 4 - Failed Delivery
**Files:**
- Create: `lib/features/driver/active_delivery/presentation/widgets/failed_delivery_header.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/failed_delivery_hero_card.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/failed_delivery_reason_selector.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/failed_delivery_actions.dart`
- Create: `lib/features/driver/active_delivery/presentation/screens/driver_failed_delivery_screen.dart`
- Modify: `lib/config/routing/app_routes.dart`
- Modify: `lib/config/routing/routing_generator.dart`
- Test: `test/features/driver/active_delivery/presentation/screens/driver_failed_delivery_screen_test.dart`

- [ ] **Step 1: Write widget test for `DriverFailedDeliveryScreen`**
- [ ] **Step 2: Implement Screen 4 custom widgets matching Figma node `1977:4999`**
- [ ] **Step 3: Register route `AppRoutes.driverFailedDelivery`**
- [ ] **Step 4: Run widget tests and verify pass**

---

### Task 8: Screen 5 - Return Box to Restaurant
**Files:**
- Create: `lib/features/driver/active_delivery/presentation/widgets/return_box_header.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/return_box_map_view.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/return_box_status_card.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/return_box_form.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/return_box_actions.dart`
- Create: `lib/features/driver/active_delivery/presentation/screens/driver_return_box_to_restaurant_screen.dart`
- Modify: `lib/config/routing/app_routes.dart`
- Modify: `lib/config/routing/routing_generator.dart`
- Test: `test/features/driver/active_delivery/presentation/screens/driver_return_box_to_restaurant_screen_test.dart`

- [ ] **Step 1: Write widget test for `DriverReturnBoxToRestaurantScreen`**
- [ ] **Step 2: Implement Screen 5 custom widgets matching Figma node `2090:4793`**
- [ ] **Step 3: Register route `AppRoutes.driverReturnBoxToRestaurant`**
- [ ] **Step 4: Run widget tests and verify pass**

---

### Task 9: Screen 6 - Delivery Success
**Files:**
- Create: `lib/features/driver/active_delivery/presentation/widgets/delivery_success_header.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/delivery_success_hero_banner.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/delivery_success_summary_card.dart`
- Create: `lib/features/driver/active_delivery/presentation/widgets/delivery_success_action_button.dart`
- Create: `lib/features/driver/active_delivery/presentation/screens/driver_delivery_success_screen.dart`
- Modify: `lib/config/routing/app_routes.dart`
- Modify: `lib/config/routing/routing_generator.dart`
- Test: `test/features/driver/active_delivery/presentation/screens/driver_delivery_success_screen_test.dart`

- [ ] **Step 1: Write widget test for `DriverDeliverySuccessScreen`**
- [ ] **Step 2: Implement Screen 6 custom widgets matching Figma node `2293:15561`**
- [ ] **Step 3: Register route `AppRoutes.driverDeliverySuccess`**
- [ ] **Step 4: Run widget tests and verify pass**

---

### Task 10: Routing Integration, Di & Final Verification
**Files:**
- Modify: `lib/features/driver/confirm_receipt/presentation/screens/driver_boxes_received_screen.dart` (wire Start Delivery button)
- Modify: `lib/core/di/di.dart` (register ActiveDeliveryRepository and ViewModel)

- [ ] **Step 1: Connect `DriverBoxesReceivedScreen` to `AppRoutes.driverStartDeliveryRoute`**
- [ ] **Step 2: Run all active delivery unit & widget tests**
- [ ] **Step 3: Run `dart format` and `flutter analyze`**
- [ ] **Step 4: Final verification walkthrough**
