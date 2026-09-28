# Driver Support Tickets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Driver Support Tickets screen (Figma Node `3687:1683`, `09.07 - Support Tickets`) in the driver bottom-tab navigation replacing `const Text("Support")` in `AppShellScreen` with fake data, adhering strictly to `rules/ui_rules.md`.

**Architecture:** A modular feature under `lib/features/driver/driver_support_tickets/` containing domain entities, a fake data source (6 tickets matching Figma counts), separated presentation widgets (1 class per file per `ui_rules.md`), local reactive filtering by status and query, and wired into `AppShellScreen` tab index 3.

**Tech Stack:** Flutter, Dart, Flutter Localizations (`l10n`), Material 3 (`ColorScheme`, `ThemeData`).

**Spec:** `docs/superpowers/specs/2026-09-29-driver-support-tickets-design.md`

## Global Constraints
- Follow `rules/ui_rules.md` strictly.
- Declare `final color = context.colorScheme;` and `final locale = context.localization;` at top of `build` methods where used.
- Obtain all UI colors from `color`. Never use `Colors.*`, `Color(...)`, or `AppColors` directly in widgets.
- Obtain all strings from `locale`. No hardcoded text.
- Obtain text styles from `lib/config/theme/styles_manager.dart`.
- Obtain spacing from `lib/config/theme/spacing.dart`.
- Every custom widget class must be placed in its own separate file (1 widget class per file).
- Use directional layouts (`EdgeInsetsDirectional`, `AlignmentDirectional`, `start`/`end`).
- Use `const` constructors wherever possible.

---

### Task 1: Add Support Tickets Localization Keys

**Files:**
- Modify: `lib/core/l10n/app_ar.arb`
- Modify: `lib/core/l10n/app_en.arb`

**Interfaces:**
- Produces:
  - `locale.driverSupportTicketsTitle`
  - `locale.driverSupportTicketsSubtitle`
  - `locale.driverSupportTicketsSearchHint`
  - `locale.driverSupportTicketsFilterAll`
  - `locale.driverSupportTicketsStatusUnderReview`
  - `locale.driverSupportTicketsStatusAwaitingResponse`
  - `locale.driverSupportTicketsStatusResolved`
  - `locale.driverSupportTicketsViewDetails`
  - `locale.driverSupportTicketsReportNewIssue`
  - `locale.driverSupportTicketsNoResults`

- [ ] **Step 1: Add Arabic localization keys to `lib/core/l10n/app_ar.arb`**

Add before closing brace:
```json
  "driverSupportTicketsTitle": "الدعم",
  "driverSupportTicketsSubtitle": "تابع البلاغات المفتوحة بسرعة",
  "driverSupportTicketsSearchHint": "ابحث برقم الطلب أو المشكلة",
  "driverSupportTicketsFilterAll": "الكل",
  "driverSupportTicketsStatusUnderReview": "قيد المراجعة",
  "driverSupportTicketsStatusAwaitingResponse": "بانتظار الرد",
  "driverSupportTicketsStatusResolved": "تم الحل",
  "driverSupportTicketsViewDetails": "عرض التفاصيل",
  "driverSupportTicketsReportNewIssue": "إبلاغ عن مشكلة جديدة",
  "driverSupportTicketsNoResults": "لا توجد بلاغات تطابق البحث"
```

- [ ] **Step 2: Add English localization keys to `lib/core/l10n/app_en.arb`**

Add before closing brace:
```json
  "driverSupportTicketsTitle": "Support",
  "driverSupportTicketsSubtitle": "Track open reports quickly",
  "driverSupportTicketsSearchHint": "Search by order number or issue",
  "driverSupportTicketsFilterAll": "All",
  "driverSupportTicketsStatusUnderReview": "Under Review",
  "driverSupportTicketsStatusAwaitingResponse": "Awaiting Response",
  "driverSupportTicketsStatusResolved": "Resolved",
  "driverSupportTicketsViewDetails": "View Details",
  "driverSupportTicketsReportNewIssue": "Report New Issue",
  "driverSupportTicketsNoResults": "No tickets match your search"
```

- [ ] **Step 3: Generate localizations**

Run: `flutter gen-l10n`
Expected: Successfully generated `app_localizations.dart` and language files.

- [ ] **Step 4: Commit**

```bash
git add lib/core/l10n/
git commit -m "feat(l10n): add driver support tickets localization strings"
```

---

### Task 2: Create Domain Entities

**Files:**
- Create: `lib/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_status.dart`
- Create: `lib/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_entity.dart`
- Test: `test/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_entity_test.dart`

**Interfaces:**
- Produces:
  - `enum DriverSupportTicketStatus { underReview, awaitingResponse, resolved }`
  - `enum DriverSupportTicketFilter { all, underReview, awaitingResponse, resolved }`
  - `class DriverSupportTicketEntity` with fields: `id`, `boxNumber`, `title`, `location`, `updatedAt`, `status`.

- [ ] **Step 1: Write unit tests for domain entities**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_status.dart';

void main() {
  test('DriverSupportTicketEntity stores correct properties', () {
    const ticket = DriverSupportTicketEntity(
      id: '1',
      boxNumber: '#BX-1256',
      title: 'العميل غير متواجد',
      location: 'منطقة السالمية',
      updatedAt: 'آخر تحديث منذ 20 دقيقة',
      status: DriverSupportTicketStatus.underReview,
    );

    expect(ticket.id, '1');
    expect(ticket.boxNumber, '#BX-1256');
    expect(ticket.status, DriverSupportTicketStatus.underReview);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_entity_test.dart`
Expected: Compilation failure (entities do not exist yet).

- [ ] **Step 3: Implement `driver_support_ticket_status.dart` and `driver_support_ticket_entity.dart`**

In `lib/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_status.dart`:
```dart
enum DriverSupportTicketStatus {
  underReview,
  awaitingResponse,
  resolved,
}

enum DriverSupportTicketFilter {
  all,
  underReview,
  awaitingResponse,
  resolved,
}
```

In `lib/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_entity.dart`:
```dart
import 'driver_support_ticket_status.dart';

class DriverSupportTicketEntity {
  const DriverSupportTicketEntity({
    required this.id,
    required this.boxNumber,
    required this.title,
    required this.location,
    required this.updatedAt,
    required this.status,
  });

  final String id;
  final String boxNumber;
  final String title;
  final String location;
  final String updatedAt;
  final DriverSupportTicketStatus status;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_entity_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/driver/driver_support_tickets/domain/entities/ test/features/driver/driver_support_tickets/domain/entities/
git commit -m "feat(driver): add driver support ticket entities"
```

---

### Task 3: Create Fake Data Source

**Files:**
- Create: `lib/features/driver/driver_support_tickets/domain/fake_data/driver_support_tickets_fake_data.dart`
- Test: `test/features/driver/driver_support_tickets/domain/fake_data/driver_support_tickets_fake_data_test.dart`

**Interfaces:**
- Produces:
  - `DriverSupportTicketsFakeData.tickets`: List of 6 `DriverSupportTicketEntity` items.
  - `DriverSupportTicketsFakeData.totalCount`: 6
  - `DriverSupportTicketsFakeData.underReviewCount`: 2
  - `DriverSupportTicketsFakeData.awaitingResponseCount`: 1
  - `DriverSupportTicketsFakeData.resolvedCount`: 3

- [ ] **Step 1: Write unit test for fake data source**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_status.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/fake_data/driver_support_tickets_fake_data.dart';

void main() {
  test('DriverSupportTicketsFakeData contains exactly 6 tickets matching Figma counts', () {
    expect(DriverSupportTicketsFakeData.tickets.length, 6);
    expect(DriverSupportTicketsFakeData.totalCount, 6);
    expect(DriverSupportTicketsFakeData.underReviewCount, 2);
    expect(DriverSupportTicketsFakeData.awaitingResponseCount, 1);
    expect(DriverSupportTicketsFakeData.resolvedCount, 3);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/driver/driver_support_tickets/domain/fake_data/driver_support_tickets_fake_data_test.dart`
Expected: Compilation failure.

- [ ] **Step 3: Implement `driver_support_tickets_fake_data.dart`**

```dart
import '../entities/driver_support_ticket_entity.dart';
import '../entities/driver_support_ticket_status.dart';

class DriverSupportTicketsFakeData {
  const DriverSupportTicketsFakeData._();

  static const List<DriverSupportTicketEntity> tickets = [
    DriverSupportTicketEntity(
      id: '1',
      boxNumber: '#BX-1256',
      title: 'العميل غير متواجد',
      location: 'منطقة السالمية',
      updatedAt: 'آخر تحديث منذ 20 دقيقة',
      status: DriverSupportTicketStatus.underReview,
    ),
    DriverSupportTicketEntity(
      id: '2',
      boxNumber: '#BX-1257',
      title: 'العنوان غير واضح',
      location: 'منطقة حولي',
      updatedAt: 'آخر تحديث منذ 45 دقيقة',
      status: DriverSupportTicketStatus.awaitingResponse,
    ),
    DriverSupportTicketEntity(
      id: '3',
      boxNumber: '#BX-1258',
      title: 'تأخير في الوصول',
      location: 'منطقة الفحيحيل',
      updatedAt: 'آخر تحديث منذ ساعة',
      status: DriverSupportTicketStatus.resolved,
    ),
    DriverSupportTicketEntity(
      id: '4',
      boxNumber: '#BX-1259',
      title: 'إعادة جدولة موعد التسليم',
      location: 'منطقة الشويخ',
      updatedAt: 'آخر تحديث منذ ساعتين',
      status: DriverSupportTicketStatus.resolved,
    ),
    DriverSupportTicketEntity(
      id: '5',
      boxNumber: '#BX-1260',
      title: 'تلف في محتويات الطلب',
      location: 'منطقة اليرموك',
      updatedAt: 'آخر تحديث منذ 15 دقيقة',
      status: DriverSupportTicketStatus.underReview,
    ),
    DriverSupportTicketEntity(
      id: '6',
      boxNumber: '#BX-1261',
      title: 'تم استلام الطلب مسبقاً',
      location: 'منطقة العديلية',
      updatedAt: 'آخر تحديث منذ 3 ساعات',
      status: DriverSupportTicketStatus.resolved,
    ),
  ];

  static int get totalCount => tickets.length;
  static int get underReviewCount =>
      tickets.where((t) => t.status == DriverSupportTicketStatus.underReview).length;
  static int get awaitingResponseCount =>
      tickets.where((t) => t.status == DriverSupportTicketStatus.awaitingResponse).length;
  static int get resolvedCount =>
      tickets.where((t) => t.status == DriverSupportTicketStatus.resolved).length;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/driver/driver_support_tickets/domain/fake_data/driver_support_tickets_fake_data_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/driver/driver_support_tickets/domain/fake_data/ test/features/driver/driver_support_tickets/domain/fake_data/
git commit -m "feat(driver): add driver support tickets fake data"
```

---

### Task 4: Build KPI Filter Components

**Files:**
- Create: `lib/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_kpi_card.dart`
- Create: `lib/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_kpi_row.dart`
- Test: `test/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_kpi_row_test.dart`

**Interfaces:**
- Produces:
  - `DriverSupportTicketsKpiCard`: widget for individual status card.
  - `DriverSupportTicketsKpiRow`: row widget composing all 4 filter cards.

- [ ] **Step 1: Write widget test for KPI filter row**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_status.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_kpi_row.dart';

void main() {
  testWidgets('DriverSupportTicketsKpiRow renders 4 filter cards and responds to taps', (tester) async {
    DriverSupportTicketFilter selected = DriverSupportTicketFilter.all;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DriverSupportTicketsKpiRow(
            selectedFilter: selected,
            allCount: 6,
            underReviewCount: 2,
            awaitingResponseCount: 1,
            resolvedCount: 3,
            onFilterChanged: (filter) => selected = filter,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('6'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_kpi_row_test.dart`
Expected: Compilation failure.

- [ ] **Step 3: Implement `driver_support_tickets_kpi_card.dart` and `driver_support_tickets_kpi_row.dart`**

Implement strictly following `rules/ui_rules.md`:
- Obtain `color` from `context.colorScheme` and `locale` from `context.localization`.
- Obtain text styles from `styles_manager.dart`.
- Obtain spacing from `spacing.dart`.
- In `driver_support_tickets_kpi_card.dart`:
  - Show icon inside tinted container or directly with count and label.
  - Border: `color.primary` when `isSelected`, otherwise `color.outlineVariant`.
  - Background: `color.primaryContainer` when selected for all, status surface container for others.
- In `driver_support_tickets_kpi_row.dart`:
  - `Row` with 4 `Expanded` children for `all`, `underReview`, `awaitingResponse`, `resolved`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_kpi_row_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_kpi* test/features/driver/driver_support_tickets/presentation/widgets/
git commit -m "feat(driver): add driver support tickets KPI cards and row"
```

---

### Task 5: Build Header and Search Field Widgets

**Files:**
- Create: `lib/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_header.dart`
- Create: `lib/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_search_field.dart`
- Test: `test/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_header_test.dart`

**Interfaces:**
- Produces:
  - `DriverSupportTicketsHeader`: Centered title & subtitle.
  - `DriverSupportTicketsSearchField`: Rounded search input with search icon.

- [ ] **Step 1: Write widget test for header & search field**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_header.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_search_field.dart';

void main() {
  testWidgets('DriverSupportTicketsHeader and SearchField render with localization', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Column(
            children: [
              const DriverSupportTicketsHeader(),
              DriverSupportTicketsSearchField(
                controller: controller,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DriverSupportTicketsHeader), findsOneWidget);
    expect(find.byType(DriverSupportTicketsSearchField), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_header_test.dart`
Expected: Compilation failure.

- [ ] **Step 3: Implement `driver_support_tickets_header.dart` and `driver_support_tickets_search_field.dart`**

Implement strictly with:
- `styles_manager.dart` font styles (`getBoldStyle`, `getRegularStyle`).
- `spacing.dart` constants (`Spacing.inputHeight`, `Spacing.inputRadius`, `Spacing.sm`).
- `context.colorScheme` (`color.onSurface`, `color.onSurfaceVariant`, `color.surface`, `color.outline`).
- Directional paddings.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_header_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_header.dart lib/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_search_field.dart test/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_header_test.dart
git commit -m "feat(driver): add driver support tickets header and search field"
```

---

### Task 6: Build Ticket Card, Status Badge, and Empty State

**Files:**
- Create: `lib/features/driver/driver_support_tickets/presentation/widgets/driver_support_ticket_status_badge.dart`
- Create: `lib/features/driver/driver_support_tickets/presentation/widgets/driver_support_ticket_card.dart`
- Create: `lib/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_empty_state.dart`
- Test: `test/features/driver/driver_support_tickets/presentation/widgets/driver_support_ticket_card_test.dart`

**Interfaces:**
- Produces:
  - `DriverSupportTicketStatusBadge`: Pill with status dot and status label.
  - `DriverSupportTicketCard`: Ticket card matching Figma (box ID, status badge, title, location pin, divider, updated time, "عرض التفاصيل <").
  - `DriverSupportTicketsEmptyState`: Empty state widget.

- [ ] **Step 1: Write widget test for ticket card and status badge**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_status.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/widgets/driver_support_ticket_card.dart';

void main() {
  testWidgets('DriverSupportTicketCard renders ticket info and handles tap', (tester) async {
    const ticket = DriverSupportTicketEntity(
      id: '1',
      boxNumber: '#BX-1256',
      title: 'العميل غير متواجد',
      location: 'منطقة السالمية',
      updatedAt: 'آخر تحديث منذ 20 دقيقة',
      status: DriverSupportTicketStatus.underReview,
    );

    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DriverSupportTicketCard(
            ticket: ticket,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('#BX-1256'), findsOneWidget);
    expect(find.text('العميل غير متواجد'), findsOneWidget);
    expect(find.text('منطقة السالمية'), findsOneWidget);

    await tester.tap(find.byType(DriverSupportTicketCard));
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/driver/driver_support_tickets/presentation/widgets/driver_support_ticket_card_test.dart`
Expected: Compilation failure.

- [ ] **Step 3: Implement `driver_support_ticket_status_badge.dart`, `driver_support_ticket_card.dart`, and `driver_support_tickets_empty_state.dart`**

Implement strictly conforming to `rules/ui_rules.md`:
- Each widget in its own file.
- Badges use `color.errorContainer` / `color.error`, `color.secondaryContainer` / `color.secondary`, `color.tertiaryContainer` / `color.tertiary`.
- Card border: `Border.all(color: color.outline)`.
- Directional chevrons and spacing.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/driver/driver_support_tickets/presentation/widgets/driver_support_ticket_card_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/driver/driver_support_tickets/presentation/widgets/driver_support_ticket_* lib/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_empty_state.dart test/features/driver/driver_support_tickets/presentation/widgets/driver_support_ticket_card_test.dart
git commit -m "feat(driver): add driver support ticket card, status badge, and empty state"
```

---

### Task 7: Build Tickets List and Report Button

**Files:**
- Create: `lib/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_list.dart`
- Create: `lib/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_report_button.dart`
- Test: `test/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_list_test.dart`

**Interfaces:**
- Produces:
  - `DriverSupportTicketsList`: `ListView.separated` of ticket cards.
  - `DriverSupportTicketsReportButton`: Primary action button "+ إبلاغ عن مشكلة جديدة".

- [ ] **Step 1: Write widget test for ticket list and report button**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/fake_data/driver_support_tickets_fake_data.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_list.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_report_button.dart';

void main() {
  testWidgets('DriverSupportTicketsList renders all tickets and ReportButton responds to tap', (tester) async {
    var reported = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: DriverSupportTicketsList(
                  tickets: DriverSupportTicketsFakeData.tickets,
                ),
              ),
              DriverSupportTicketsReportButton(
                onPressed: () => reported = true,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('#BX-1256'), findsOneWidget);
    await tester.tap(find.byType(DriverSupportTicketsReportButton));
    expect(reported, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_list_test.dart`
Expected: Compilation failure.

- [ ] **Step 3: Implement `driver_support_tickets_list.dart` and `driver_support_tickets_report_button.dart`**

Implement strictly following `rules/ui_rules.md`:
- `DriverSupportTicketsList`: Uses `ListView.separated` with `SizedBox(height: Spacing.md)`. Empty state fallback if `tickets.isEmpty`.
- `DriverSupportTicketsReportButton`: Primary filled button, height `Spacing.buttonHeight` (52), radius `Spacing.buttonRadius` (14), background `color.primary`, text `color.onPrimary`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_list_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_list.dart lib/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_report_button.dart test/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_list_test.dart
git commit -m "feat(driver): add driver support tickets list and report button"
```

---

### Task 8: Assemble Driver Support Tickets Screen

**Files:**
- Create: `lib/features/driver/driver_support_tickets/presentation/screens/driver_support_tickets_screen.dart`
- Test: `test/features/driver/driver_support_tickets/presentation/screens/driver_support_tickets_screen_test.dart`

**Interfaces:**
- Produces:
  - `DriverSupportTicketsScreen`: Main tab screen composing header, search, KPI filter row, list, and bottom button.

- [ ] **Step 1: Write screen integration test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/screens/driver_support_tickets_screen.dart';

void main() {
  testWidgets('DriverSupportTicketsScreen filters tickets by KPI and search query', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DriverSupportTicketsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial state shows all tickets
    expect(find.text('#BX-1256'), findsOneWidget);
    expect(find.text('#BX-1257'), findsOneWidget);
    expect(find.text('#BX-1258'), findsOneWidget);

    // Search for 1257
    await tester.enterText(find.byType(TextField), '1257');
    await tester.pumpAndSettle();

    expect(find.text('#BX-1257'), findsOneWidget);
    expect(find.text('#BX-1256'), findsNothing);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/driver/driver_support_tickets/presentation/screens/driver_support_tickets_screen_test.dart`
Expected: Compilation failure.

- [ ] **Step 3: Implement `driver_support_tickets_screen.dart`**

Implement stateful widget managing:
- `TextEditingController` for search.
- `_selectedFilter` defaulting to `DriverSupportTicketFilter.all`.
- Efficient filtering logic:
  - Filter by status if not `all`.
  - Filter by search query on `boxNumber` or `title`.
- Layout:
  - `SafeArea`
  - `Column` / `Padding` with `Spacing.screenH` (20) and `Spacing.screenV` (16)
  - `DriverSupportTicketsHeader`
  - `SizedBox(height: Spacing.md)`
  - `DriverSupportTicketsSearchField`
  - `SizedBox(height: Spacing.md)`
  - `DriverSupportTicketsKpiRow`
  - `SizedBox(height: Spacing.md)`
  - `Expanded(child: DriverSupportTicketsList)`
  - `SizedBox(height: Spacing.sm)`
  - `DriverSupportTicketsReportButton`

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/driver/driver_support_tickets/presentation/screens/driver_support_tickets_screen_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/driver/driver_support_tickets/presentation/screens/ test/features/driver/driver_support_tickets/presentation/screens/
git commit -m "feat(driver): assemble driver support tickets screen"
```

---

### Task 9: Wire into AppShellScreen & Final Verification

**Files:**
- Modify: `lib/core/app_shell/screens/app_shell_screen.dart:83`
- Verify: Full analyzer and all tests pass

- [ ] **Step 1: Replace placeholder `const Text("Support")` with `const DriverSupportTicketsScreen()` in `AppShellScreen`**

In `lib/core/app_shell/screens/app_shell_screen.dart`:
```dart
import '../../../features/driver/driver_support_tickets/presentation/screens/driver_support_tickets_screen.dart';
...
      return [
        const DriverStartWorkScreen(),
        const DriverAssignedBoxesScreen(),
        const DriverMapScreen(),
        const DriverSupportTicketsScreen(),
        const DriverProfileScreen(),
      ];
```

- [ ] **Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: 0 issues found.

- [ ] **Step 3: Run all unit and widget tests**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
git add lib/core/app_shell/screens/app_shell_screen.dart
git commit -m "feat(driver): integrate DriverSupportTicketsScreen into driver tab navigation"
```
