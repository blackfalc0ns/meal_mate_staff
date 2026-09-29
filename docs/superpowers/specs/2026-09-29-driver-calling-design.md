# Design Specification: Driver Active Call Screen

- **Date:** 2026-09-29
- **Feature:** Driver Active In-App Call (`08.09 - Active In-App Call`)
- **Figma Source of Truth:** Frame `08.09 - Active In-App Call` (Node ID: `2090-5549`)
- **UI Guidelines:** `rules/ui_rules.md`
- **Location:** `lib/features/driver/calling/`

---

## 1. Overview & Goal

The user requested the creation of a new driver feature named `calling`, starting with the Active In-App Call screen from Figma node `2090-5549` (`08.09 - Active In-App Call`).

This screen represents an ongoing in-app call between the driver and the customer during delivery:
1. **Top Bar**: Minimal dismiss/minimize control (`Icons.keyboard_arrow_down_rounded`) allowing the driver to return or minimize the call overlay.
2. **Call Status & Customer Header**:
   - Connection indicator: Green circular dot with text "اتصال جاري..." (Call in progress...).
   - Customer Name: Large bold headline "محمد علي" (Mohammad Ali).
   - Live Call Duration: Incrementing timer string formatted as "MM:SS" (e.g., "00:24").
3. **Pulsing Avatar Section**:
   - 3 concentric circular waves/rings with progressive opacity representing call activity.
   - Dark purple circular avatar container with user silhouette icon.
   - White circular badge with phone receiver icon at the bottom edge.
4. **Customer Address Card**:
   - Translucent rounded surface on dark background.
   - Location pin icon in rounded badge.
   - Header label "العنوان" (Address).
   - Address details: "شارع الخليج العربي ، قطعة 12 ، منزل 45" and area "السلمانية".
5. **Call Control Actions**:
   - Speaker toggle button ("سماعة"): Toggles speaker state with active/inactive visual cues.
   - Microphone mute button ("كتم الميكروفون"): Toggles mute state with active/inactive visual cues.
   - End Call button ("إنهاء المكالمة"): Prominent circular red button with hangup icon that terminates the call and navigates back.

---

## 2. Architecture & File Structure

Adhering strictly to `rules/ui_rules.md` (one widget class per file, fake data isolated from network, no business logic coupling, responsive RTL/LTR):

```text
lib/features/driver/calling/
├── domain/
│   ├── entities/
│   │   └── driver_active_call_entity.dart
│   └── fake_data/
│       └── driver_calling_fake_data.dart
└── presentation/
    ├── screens/
    │   └── driver_active_call_screen.dart
    └── widgets/
        ├── driver_call_top_bar.dart
        ├── driver_call_header.dart
        ├── driver_call_avatar.dart
        ├── driver_call_address_card.dart
        ├── driver_call_action_button.dart
        ├── driver_call_end_button.dart
        └── driver_call_controls_row.dart
```

---

## 3. UI Components Breakdown

### 3.1 `DriverActiveCallScreen`
- **File:** `lib/features/driver/calling/presentation/screens/driver_active_call_screen.dart`
- **Role:** Main scaffold hosting the call experience on a full-height dark container.
- **State:** Manages call duration timer (incrementing every second), speaker toggle (`ValueNotifier<bool>`), and mic mute toggle (`ValueNotifier<bool>`).
- **Layout:** `Scaffold` with dark midnight background (`const Color(0xFF131127)` or theme dark surface), `SafeArea`, and a flex layout placing the top bar and header at top, avatar in the center, address card above bottom controls, and controls pinned to bottom.

### 3.2 `DriverCallTopBar`
- **File:** `lib/features/driver/calling/presentation/widgets/driver_call_top_bar.dart`
- **Role:** Displays back/collapse chevron (`Icons.keyboard_arrow_down_rounded`).
- **Interaction:** Invokes `onDismiss` callback (defaults to `Navigator.of(context).maybePop()`).

### 3.3 `DriverCallHeader`
- **File:** `lib/features/driver/calling/presentation/widgets/driver_call_header.dart`
- **Role:** Displays connection status indicator (green dot + localized "اتصال جاري..."), customer name in bold white, and formatted duration timer.
- **Rebuild Boundary:** Reads duration from `ValueListenable<String>` or formatted string so only the timer updates every second.

### 3.4 `DriverCallAvatar`
- **File:** `lib/features/driver/calling/presentation/widgets/driver_call_avatar.dart`
- **Role:** 3 concentric circular rings (e.g. 180dp, 140dp, 100dp) with primary color tints (`alpha: 0.15`, `0.25`, `0.40`). Center circle holds the avatar silhouette icon, with a floating white circular badge at the bottom containing `Icons.phone_rounded`.

### 3.5 `DriverCallAddressCard`
- **File:** `lib/features/driver/calling/presentation/widgets/driver_call_address_card.dart`
- **Role:** Semi-transparent card with subtle border showing location icon and customer delivery address details.

### 3.6 `DriverCallActionButton`
- **File:** `lib/features/driver/calling/presentation/widgets/driver_call_action_button.dart`
- **Role:** Circular button with dark container, icon (speaker or mic), and text label below. Highlights when active.

### 3.7 `DriverCallEndButton`
- **File:** `lib/features/driver/calling/presentation/widgets/driver_call_end_button.dart`
- **Role:** Circular red end-call button (`color.error` / `0xFFE53935`) with phone hangup icon and localized label "إنهاء المكالمة".

### 3.8 `DriverCallControlsRow`
- **File:** `lib/features/driver/calling/presentation/widgets/driver_call_controls_row.dart`
- **Role:** Layout row grouping `DriverCallActionButton` (speaker), `DriverCallActionButton` (mute), and `DriverCallEndButton` (end call).

---

## 4. Domain & Fake Data

### 4.1 `DriverActiveCallEntity`
- **File:** `lib/features/driver/calling/domain/entities/driver_active_call_entity.dart`
- **Fields:**
  - `customerName`: String
  - `addressLine`: String
  - `area`: String
  - `initialDurationSeconds`: int (default `24`)

### 4.2 `DriverCallingFakeData`
- **File:** `lib/features/driver/calling/domain/fake_data/driver_calling_fake_data.dart`
- **Default Data:**
  - `customerName`: "محمد علي"
  - `addressLine`: "شارع الخليج العربي ، قطعة 12 ، منزل 45"
  - `area`: "السلمانية"
  - `initialDurationSeconds`: 24

---

## 5. Localization

Keys to be added to `ar.json` and `en.json`:
- `driverCallInProgress`: "اتصال جاري..." / "Call in progress..."
- `driverCallAddressTitle`: "العنوان" / "Address"
- `driverCallSpeaker`: "سماعة" / "Speaker"
- `driverCallMute`: "كتم الميكروفون" / "Mute"
- `driverCallEnd`: "إنهاء المكالمة" / "End Call"

---

## 6. Routing Integration

- **Route Constant:** `AppRoutes.driverActiveCall = '/driver-active-call'` in `lib/config/routing/app_routes.dart`.
- **Route Generator:** Added to `lib/config/routing/routing_generator.dart` returning `DriverActiveCallScreen`.

---

## 7. Testing & Verification

- **Widget Tests:** Automated test file `test/features/driver/calling/driver_active_call_screen_test.dart`:
  - Renders all UI components in Arabic RTL and English LTR.
  - Toggles speaker and mute buttons.
  - Tapping end call triggers callback / navigation.
- **Static Analysis:** `flutter analyze` passes with zero issues.
