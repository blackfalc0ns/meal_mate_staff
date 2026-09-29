# Driver Active Call Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Driver Active In-App Call screen (`08.09 - Active In-App Call`, Figma Node `2090-5549`) under `lib/features/driver/calling/` using pure UI with fake data, adhering strictly to `rules/ui_rules.md`.

**Architecture:** A standalone calling feature with domain entities and fake data, composed of modular widgets (one widget class per file) rendered on a dark fullscreen canvas with live call timer and toggleable controls for speaker and mic mute.

**Tech Stack:** Flutter, Dart, Flutter Test.

**Spec:** `docs/superpowers/specs/2026-09-29-driver-calling-design.md`

## Global Constraints

- Figma is the single source of truth (Frame `08.09 - Active In-App Call`, Node ID `2090-5549`).
- Every custom widget must be placed in its own separate file; exactly one widget class per file (`rules/ui_rules.md`).
- At the beginning of every `build` method, declare `final color = context.colorScheme;` and `final locale = context.localization;` (when used).
- Obtain text from `locale` and colors from `color` (no hardcoded colors, no `Colors.*`).
- Use spacing from `Spacing.*` and styles from `styles_manager.dart`.
- Fake data only, no external backend or network dependencies.

## Review Focus

- Call timer tick: format string `MM:SS` (e.g. `00:24`) must correctly pad minutes and seconds.
- Speaker toggle state: visual highlight updates correctly without rebuilding the whole screen.
- Mic mute toggle state: visual highlight updates correctly without rebuilding the whole screen.
- Dismiss / End call action: triggers `onEndCall` or pops navigation cleanly.
- Dark theme contrast: all text and icons clearly readable against the dark midnight canvas.

---

### Task 1: Domain Entity & Fake Data

**Files:**
- Create: `lib/features/driver/calling/domain/entities/driver_active_call_entity.dart`
- Create: `lib/features/driver/calling/domain/fake_data/driver_calling_fake_data.dart`
- Test: `test/features/driver/calling/domain/driver_calling_entity_test.dart`

**Interfaces:**
- Produces: `DriverActiveCallEntity` (fields: `customerName`, `addressLine`, `area`, `initialDurationSeconds`) and `DriverCallingFakeData.activeCall`.

- [ ] **Step 1: Write the unit test for `DriverActiveCallEntity` and `DriverCallingFakeData`**
- [ ] **Step 2: Run test to verify it fails**
  Run: `flutter test test/features/driver/calling/domain/driver_calling_entity_test.dart`
- [ ] **Step 3: Implement `DriverActiveCallEntity` and `DriverCallingFakeData`**
- [ ] **Step 4: Run test to verify it passes**
  Run: `flutter test test/features/driver/calling/domain/driver_calling_entity_test.dart`
- [ ] **Step 5: Commit**
  `git add lib/features/driver/calling/domain/ test/features/driver/calling/domain/; git commit -m "feat(driver_calling): add active call entity and fake data"`

---

### Task 2: Localization Strings

**Files:**
- Modify: `assets/translations/ar.json`
- Modify: `assets/translations/en.json`

**Interfaces:**
- Produces: Localization keys `driverCallInProgress`, `driverCallAddressTitle`, `driverCallSpeaker`, `driverCallMute`, `driverCallEnd`.

- [ ] **Step 1: Add Arabic and English translations**
  In `ar.json`:
  - `"driverCallInProgress": "اتصال جاري..."`
  - `"driverCallAddressTitle": "العنوان"`
  - `"driverCallSpeaker": "سماعة"`
  - `"driverCallMute": "كتم الميكروفون"`
  - `"driverCallEnd": "إنهاء المكالمة"`
  In `en.json`:
  - `"driverCallInProgress": "Call in progress..."`
  - `"driverCallAddressTitle": "Address"`
  - `"driverCallSpeaker": "Speaker"`
  - `"driverCallMute": "Mute Microphone"`
  - `"driverCallEnd": "End Call"`
- [ ] **Step 2: Run build_runner / localization generation if needed or verify JSON validity**
- [ ] **Step 3: Commit**
  `git add assets/translations/; git commit -m "feat(driver_calling): add call screen localization keys"`

---

### Task 3: Call Top Bar & Call Header Widgets

**Files:**
- Create: `lib/features/driver/calling/presentation/widgets/driver_call_top_bar.dart`
- Create: `lib/features/driver/calling/presentation/widgets/driver_call_header.dart`
- Test: `test/features/driver/calling/presentation/widgets/driver_call_header_test.dart`

**Interfaces:**
- `DriverCallTopBar(onDismiss: VoidCallback?)`
- `DriverCallHeader(customerName: String, durationText: String)`

- [ ] **Step 1: Write test for `DriverCallTopBar` and `DriverCallHeader`**
- [ ] **Step 2: Run test to verify it fails**
- [ ] **Step 3: Implement `DriverCallTopBar` with down chevron icon and `DriverCallHeader` with green dot, "اتصال جاري...", customer name, and duration timer**
- [ ] **Step 4: Run test to verify it passes**
- [ ] **Step 5: Commit**
  `git add lib/features/driver/calling/presentation/widgets/test/features/driver/calling/presentation/widgets/; git commit -m "feat(driver_calling): add call top bar and header widgets"`

---

### Task 4: Concentric Waves Call Avatar Widget

**Files:**
- Create: `lib/features/driver/calling/presentation/widgets/driver_call_avatar.dart`
- Test: `test/features/driver/calling/presentation/widgets/driver_call_avatar_test.dart`

**Interfaces:**
- `DriverCallAvatar({super.key})`

- [ ] **Step 1: Write test for `DriverCallAvatar` rendering concentric rings, avatar icon, and call badge**
- [ ] **Step 2: Run test to verify it fails**
- [ ] **Step 3: Implement `DriverCallAvatar` with 3 translucent concentric circular rings, purple avatar background, silhouette icon, and white phone badge**
- [ ] **Step 4: Run test to verify it passes**
- [ ] **Step 5: Commit**
  `git add lib/features/driver/calling/presentation/widgets/driver_call_avatar.dart test/features/driver/calling/presentation/widgets/driver_call_avatar_test.dart; git commit -m "feat(driver_calling): add concentric waves avatar widget"`

---

### Task 5: Customer Address Card Widget

**Files:**
- Create: `lib/features/driver/calling/presentation/widgets/driver_call_address_card.dart`
- Test: `test/features/driver/calling/presentation/widgets/driver_call_address_card_test.dart`

**Interfaces:**
- `DriverCallAddressCard({super.key, required String addressLine, required String area})`

- [ ] **Step 1: Write test for `DriverCallAddressCard`**
- [ ] **Step 2: Run test to verify it fails**
- [ ] **Step 3: Implement `DriverCallAddressCard` with translucent dark surface, location pin badge, title "العنوان", address line, and area**
- [ ] **Step 4: Run test to verify it passes**
- [ ] **Step 5: Commit**
  `git add lib/features/driver/calling/presentation/widgets/driver_call_address_card.dart test/features/driver/calling/presentation/widgets/driver_call_address_card_test.dart; git commit -m "feat(driver_calling): add call address card widget"`

---

### Task 6: Call Control Action Buttons & Controls Row

**Files:**
- Create: `lib/features/driver/calling/presentation/widgets/driver_call_action_button.dart`
- Create: `lib/features/driver/calling/presentation/widgets/driver_call_end_button.dart`
- Create: `lib/features/driver/calling/presentation/widgets/driver_call_controls_row.dart`
- Test: `test/features/driver/calling/presentation/widgets/driver_call_controls_row_test.dart`

**Interfaces:**
- `DriverCallActionButton(icon: IconData, label: String, isActive: bool, onTap: VoidCallback)`
- `DriverCallEndButton(onEndCall: VoidCallback)`
- `DriverCallControlsRow(isSpeakerOn: bool, isMuted: bool, onToggleSpeaker: VoidCallback, onToggleMute: VoidCallback, onEndCall: VoidCallback)`

- [ ] **Step 1: Write tests for action button, end button, and controls row**
- [ ] **Step 2: Run test to verify it fails**
- [ ] **Step 3: Implement `DriverCallActionButton`, `DriverCallEndButton`, and `DriverCallControlsRow`**
- [ ] **Step 4: Run test to verify it passes**
- [ ] **Step 5: Commit**
  `git add lib/features/driver/calling/presentation/widgets/ test/features/driver/calling/presentation/widgets/; git commit -m "feat(driver_calling): add call control buttons and controls row"`

---

### Task 7: Main Screen `DriverActiveCallScreen`

**Files:**
- Create: `lib/features/driver/calling/presentation/screens/driver_active_call_screen.dart`
- Test: `test/features/driver/calling/presentation/screens/driver_active_call_screen_test.dart`

**Interfaces:**
- `DriverActiveCallScreen({super.key, DriverActiveCallEntity? callData, VoidCallback? onEndCall, VoidCallback? onDismiss})`

- [ ] **Step 1: Write comprehensive test for `DriverActiveCallScreen` in RTL Arabic and LTR English**
- [ ] **Step 2: Run test to verify it fails**
- [ ] **Step 3: Implement `DriverActiveCallScreen` integrating top bar, header, avatar, address card, and controls row on dark canvas with timer and toggles**
- [ ] **Step 4: Run test to verify it passes**
- [ ] **Step 5: Commit**
  `git add lib/features/driver/calling/presentation/screens/ test/features/driver/calling/presentation/screens/; git commit -m "feat(driver_calling): implement driver active call screen"`

---

### Task 8: Routing Integration & Full Verification

**Files:**
- Modify: `lib/config/routing/app_routes.dart`
- Modify: `lib/config/routing/routing_generator.dart`
- Test: `test/config/routing/driver_active_call_route_test.dart`

**Interfaces:**
- `AppRoutes.driverActiveCall = '/driver-active-call'`

- [ ] **Step 1: Add `driverActiveCall` to `AppRoutes` and `RouteGenerator`**
- [ ] **Step 2: Write route generator test for `AppRoutes.driverActiveCall`**
- [ ] **Step 3: Run all calling feature tests and analyzer**
  `flutter test test/features/driver/calling/`
  `flutter test test/config/routing/driver_active_call_route_test.dart`
  `flutter analyze lib/features/driver/calling/ lib/config/routing/`
- [ ] **Step 4: Commit**
  `git add lib/config/routing/ test/config/routing/; git commit -m "feat(driver_calling): add routing for active call screen"`
