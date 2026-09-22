# Dispatcher Support Issues Backend Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace fake data in dispatcher support screen 04.11 with the paginated backend API, server-side search/filtering, robust loading/error states, and optimized lazy rendering.

**Architecture:** Preserve the UI and add the established Feature-Based Clean Architecture layers. Nullable Retrofit DTOs are normalized into canonical domain entities; `DispatcherSupportViewModel` owns filters, debounced search, stale-request rejection, and append pagination. No polling or SignalR.

**Tech Stack:** Flutter, Dart 3, Dio, Retrofit, json_serializable, flutter_bloc/Cubit, GetIt, core `ApiResult`/errors, flutter_test.

**Spec:** `docs/superpowers/specs/2026-09-22-dispatcher-support-issues-design.md`

## Global Constraints

- Screen 04.11 only; do not implement the 04.12 details API.
- Role is `DeliveryManager`; authorization comes from the existing token interceptor.
- Endpoint: `/api/v1/dispatcher/support/issues`.
- Exact query names: `area`, `status`, `search`, `datePreset`, `fromDateUtc`, `toDateUtc`, `pageNumber`, `pageSize`.
- Defaults: `Open`, `Last7Days`, page 1, size 20; never request size above 50.
- No polling, timer, SignalR, second Dio, client-side filtering, or fake runtime fallback.
- Every response DTO field is nullable. DTOs never enter domain/presentation.
- Preserve the existing UI and reuse `lib/core/errors` plus `ShimmerWidget`.
- Never hand-edit generated `*.g.dart` or localization output.

## Locked file map

Create:

```text
lib/features/dispatcher/dispatcher_support/
  data/data_source/dispatcher_support_remote_data_source.dart
  data/data_source/dispatcher_support_remote_data_source_impl.dart
  data/mapper/dispatcher_support_mapper.dart
  data/models/response/dispatcher_support_response_dto.dart
  data/repo/dispatcher_support_repository_impl.dart
  domain/entities/dispatcher_support_date_preset.dart
  domain/entities/dispatcher_support_query_entity.dart
  domain/entities/dispatcher_support_response_entity.dart
  domain/repo/dispatcher_support_repository.dart
  domain/usecase/get_dispatcher_support_issues_usecase.dart
  presentation/manager/dispatcher_support_event.dart
  presentation/manager/dispatcher_support_state.dart
  presentation/manager/dispatcher_support_view_model.dart
  presentation/widgets/dispatcher_support_shimmer.dart
  presentation/widgets/dispatcher_support_empty_state.dart
  presentation/widgets/dispatcher_support_pagination_footer.dart
  presentation/widgets/dispatcher_support_date_filter_sheet.dart
```

Modify only the related core endpoint/DI, current support entities/widgets/screen, routing seam, localization, and tests. Do not move or refactor details/reassignment features.

---

### Task 1: Canonical domain contracts

**Files:**
- Create: `domain/entities/dispatcher_support_date_preset.dart`
- Create: `domain/entities/dispatcher_support_query_entity.dart`
- Create: `domain/entities/dispatcher_support_response_entity.dart`
- Modify: `domain/entities/dispatcher_support_issue_entity.dart`
- Modify: `domain/entities/dispatcher_support_kpi_entity.dart`
- Modify: `domain/entities/dispatcher_support_issue_type.dart`
- Test: `test/features/dispatcher/dispatcher_support/domain/dispatcher_support_entities_test.dart`

**Produces:** `DispatcherSupportQueryEntity`, `DispatcherSupportDatePreset`, counters/area/pagination/page entities, and a render-ready `DispatcherSupportIssueEntity`.

- [ ] **Step 1: Write failing domain tests**

Assert these defaults and conversions:

```dart
const query = DispatcherSupportQueryEntity();
expect(query.status, DispatcherSupportStatus.open);
expect(query.datePreset, DispatcherSupportDatePreset.last7Days);
expect(query.pageNumber, 1);
expect(query.pageSize, 20);
expect(query.apiStatus, 'Open');
expect(DispatcherSupportDatePreset.last30Days.apiValue, 'Last30Days');
expect(query.copyWith(pageNumber: 3).resetToFirstPage().pageNumber, 1);
```

Also test pagination booleans and construction of unknown/fallback issue values without API imports.

- [ ] **Step 2: Run and observe missing-type failures**

```bash
flutter test test/features/dispatcher/dispatcher_support/domain/dispatcher_support_entities_test.dart
```

- [ ] **Step 3: Implement immutable entities**

Required query constructor:

```dart
const DispatcherSupportQueryEntity({
  this.area,
  this.status = DispatcherSupportStatus.open,
  this.search = '',
  this.datePreset = DispatcherSupportDatePreset.last7Days,
  this.fromDateUtc,
  this.toDateUtc,
  this.pageNumber = 1,
  this.pageSize = 20,
});
```

The issue entity must expose canonical ID, box code, title, category/label/color, UTC date/time label, driver ID/code/name/avatar, area, vehicle, priority/label/color, and status/label. Update fake/test call sites in this task so the project compiles; do not leave parallel fake-only fields in presentation.

- [ ] **Step 4: Verify and commit**

```bash
flutter test test/features/dispatcher/dispatcher_support/domain/dispatcher_support_entities_test.dart
flutter analyze lib/features/dispatcher/dispatcher_support/domain
git add lib/features/dispatcher/dispatcher_support/domain test/features/dispatcher/dispatcher_support/domain
git commit -m "feat: define dispatcher support domain contracts"
```

### Task 2: Defensive DTOs and alias mapper

**Files:**
- Create: `data/models/response/dispatcher_support_response_dto.dart`
- Generate: corresponding `.g.dart`
- Create: `data/mapper/dispatcher_support_mapper.dart`
- Test: `test/features/dispatcher/dispatcher_support/data/dispatcher_support_dto_mapper_test.dart`

**Produces:** `DispatcherSupportResponseDto.fromJson` and `toEntity()`.

- [ ] **Step 1: Write failing tests with three fixtures**

Use the complete supplied response; an alias-only issue; and a malformed/null fixture. Assert canonical ID/box/vehicle, counters, area key, pagination, null-list fallback, invalid color/date fallback, and no thrown exception.

- [ ] **Step 2: Run failing test**

```bash
flutter test test/features/dispatcher/dispatcher_support/data/dispatcher_support_dto_mapper_test.dart
```

- [ ] **Step 3: Implement nullable nested DTOs**

Use `@JsonSerializable()` for response, counters, area chip, issue, and pagination. Include all supplied duplicate fields exactly: `id/issueId`, `boxCode/issueCode`, `issueCategory/badgeText`, `timeAgo/reportedTimeText`, `vehicleInfo/vehicleText`, and color alternatives.

- [ ] **Step 4: Implement exact precedence**

```text
id = id ?? issueId ?? ''
boxCode = boxCode ?? issueCode ?? ''
issueCategory = issueCategory ?? badgeText ?? ''
timeAgo = timeAgo ?? reportedTimeText ?? ''
vehicleInfo = vehicleInfo ?? vehicleText ?? ''
categoryColor = valid issueCategoryColor -> named badgeColor -> safe fallback
```

Map unknown status/category/priority safely; never use force unwrap. Preserve `areaKey` independently from display area.

- [ ] **Step 5: Generate, test, commit**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/dispatcher/dispatcher_support/data/dispatcher_support_dto_mapper_test.dart
git add lib/features/dispatcher/dispatcher_support/data test/features/dispatcher/dispatcher_support/data
git commit -m "feat: map dispatcher support API response"
```

### Task 3: Endpoint through use case

**Files:**
- Modify: `lib/core/network/network_constants.dart`
- Modify: `lib/core/network/api_services.dart`
- Generate: `lib/core/network/api_services.g.dart`
- Create: both remote-data-source files
- Create: repository contract/implementation
- Create: `domain/usecase/get_dispatcher_support_issues_usecase.dart`
- Test: `test/features/dispatcher/dispatcher_support/data/dispatcher_support_repository_impl_test.dart`

**Interfaces:**

```dart
Future<DispatcherSupportResponseDto> getDispatcherSupportIssues({...});
Future<ApiResult<DispatcherSupportResponseEntity>> getIssues(
  DispatcherSupportQueryEntity query,
);
```

- [ ] **Step 1: Write repository tests**

A fake source records all eight query values. Test successful mapping and exception conversion to `ApiErrorResult` through `safeApiCall`.

- [ ] **Step 2: Verify failure**

```bash
flutter test test/features/dispatcher/dispatcher_support/data/dispatcher_support_repository_impl_test.dart
```

- [ ] **Step 3: Add endpoint and Retrofit queries**

```dart
static const dispatcherSupportIssues =
    '/api/v1/dispatcher/support/issues';
```

Pass optional area/search/custom dates and required status/date/page values using exact backend names. Convert custom dates using `toUtc().toIso8601String()`. Never add auth headers here.

- [ ] **Step 4: Implement layers**

Data source calls `ApiServices` only. Repository calls `safeApiCall(() async => (await source.getIssues(query)).toEntity())`. Use case delegates without UI logic.

- [ ] **Step 5: Generate and verify**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/dispatcher/dispatcher_support/data/dispatcher_support_repository_impl_test.dart
flutter test test/core/network/api_services_test.dart
git add lib/core/network lib/features/dispatcher/dispatcher_support/data lib/features/dispatcher/dispatcher_support/domain
git commit -m "feat: connect dispatcher support issues endpoint"
```

### Task 4: ViewModel, debounce, stale protection, pagination

**Files:**
- Create: three files under `presentation/manager/`
- Test: `test/features/dispatcher/dispatcher_support/presentation/manager/dispatcher_support_view_model_test.dart`

**Events:** initial load, retry, status change, area change, date preset/custom range change, search change, search clear, load next page.

**State:** response, query, `isInitialLoading`, `isFilterLoading`, `isNextPageLoading`, `initialFailure`, `nonFatalFailure`, `pageFailure`, and increasing `noticeId`.

- [ ] **Step 1: Write failing tests**

Cover default query; initial success/failure; every filter resetting page 1; configurable search debounce that trims and sends only the latest input; immediate clear; stale response rejection; page guard; append de-duplication; page failure retaining items; filter failure retaining data/incrementing notice; timer cancellation on close.

Use completers and inject a short/zero debounce duration—never sleep 400 ms in unit tests.

- [ ] **Step 2: Verify failure**

```bash
flutter test test/features/dispatcher/dispatcher_support/presentation/manager/dispatcher_support_view_model_test.dart
```

- [ ] **Step 3: Implement state machine**

Follow existing `doIntent(event)`. Use sentinel-based `copyWith`. Use `_requestGeneration` for replacement loads, a next-page guard, and `Timer? _searchDebounce`. Check `isClosed` and generation relevance after awaits. Merge pages in server order and de-duplicate non-empty IDs.

- [ ] **Step 4: Verify and commit**

```bash
flutter test test/features/dispatcher/dispatcher_support/presentation/manager/dispatcher_support_view_model_test.dart
git add lib/features/dispatcher/dispatcher_support/presentation/manager test/features/dispatcher/dispatcher_support/presentation/manager
git commit -m "feat: manage dispatcher support filters and pagination"
```

### Task 5: Dependency injection

**Files:**
- Modify: `lib/core/di/di.dart`
- Modify: `test/core/di/di_test.dart`

- [ ] **Step 1: Add failing registration assertions**

Assert source, repository, use case, and ViewModel resolve; ViewModel is a factory.

- [ ] **Step 2: Register in existing manual style**

Remote source/repository are lazy singletons; use case/ViewModel are factories. Do not introduce Injectable generation for only this feature.

- [ ] **Step 3: Test and commit**

```bash
flutter test test/core/di/di_test.dart
git add lib/core/di/di.dart test/core/di/di_test.dart
git commit -m "chore: register dispatcher support dependencies"
```

### Task 6: Shimmer, empty, date, and pagination widgets

**Files:**
- Create: four planned state/widget files
- Modify: `dispatcher_support_filter_chips.dart`
- Modify: `lib/core/l10n/app_ar.arb`
- Modify: `lib/core/l10n/app_en.arb`
- Generate localization output
- Test: `test/features/dispatcher/dispatcher_support/presentation/widgets/dispatcher_support_state_widgets_test.dart`

- [ ] **Step 1: Write failing widget tests**

Assert: structural skeleton uses `ShimmerWidget`; localized empty state; backend area names/counts; selected area value; five date presets; Custom range result; pagination loading/retry behavior.

- [ ] **Step 2: Implement widgets**

Compose the existing `ShimmerWidget`; do not add a shimmer package. Use existing theme/spacing/error widgets/date-picker dependency. Convert chosen custom start/end boundaries to UTC before dispatch.

- [ ] **Step 3: Generate, test, commit**

```bash
flutter gen-l10n
flutter test test/features/dispatcher/dispatcher_support/presentation/widgets/dispatcher_support_state_widgets_test.dart
git add lib/features/dispatcher/dispatcher_support/presentation/widgets lib/core/l10n test/features/dispatcher/dispatcher_support/presentation/widgets
git commit -m "feat: add dispatcher support state widgets"
```

### Task 7: Adapt cards and counters to API entities

**Files:**
- Modify: `dispatcher_support_issue_card.dart`
- Modify: `dispatcher_support_kpi_bar.dart`
- Modify: `dispatcher_support_status_tabs.dart`
- Test: `test/features/dispatcher/dispatcher_support/presentation/widgets/dispatcher_support_issue_card_test.dart`

- [ ] **Step 1: Write failing card tests**

Verify category/title/time, driver code, vehicle, priority, dynamic colors, network-avatar fallback, long Arabic/English layout at 360px, and callbacks.

- [ ] **Step 2: Adapt minimally**

Use canonical entity values. Render avatars via existing `AppCachedNetworkImage` and current asset fallback. Remove fake enum label switches, `minutesAgo` computation, and vehicle splitting from UI. Do not parse backend values in `build`.

- [ ] **Step 3: Verify and commit**

```bash
flutter test test/features/dispatcher/dispatcher_support/presentation/widgets/dispatcher_support_issue_card_test.dart
git add lib/features/dispatcher/dispatcher_support/presentation/widgets test/features/dispatcher/dispatcher_support/presentation/widgets
git commit -m "feat: render dispatcher support API issues"
```

### Task 8: Screen integration, lazy list, errors, navigation

**Files:**
- Modify: `presentation/screens/dispatcher_support_screen.dart`
- Modify: `lib/config/routing/routing_generator.dart`
- Create/modify: `lib/config/routing/arguments/dispatcher_support_route_arguments.dart`
- Modify: `test/dispatcher_support_screen_test.dart`
- Create: `test/features/dispatcher/dispatcher_support/presentation/dispatcher_support_screen_backend_test.dart`

**Screen seam:** optional injected `DispatcherSupportViewModel? viewModel` for tests; otherwise resolve GetIt. Details navigation forwards only the exact issue ID.

- [ ] **Step 1: Write failing state/interaction tests**

Test shimmer; data; empty; full-page error/retry; retained-data SnackBar once per `noticeId`; status/area/search/date events; scroll threshold dispatching one next page; append footer retry; exact issue-ID navigation; ownership-aware ViewModel close; narrow Arabic/English layout.

- [ ] **Step 2: Run and confirm fake screen fails**

```bash
flutter test test/dispatcher_support_screen_test.dart test/features/dispatcher/dispatcher_support/presentation/dispatcher_support_screen_backend_test.dart
```

- [ ] **Step 3: Wire lifecycle and Bloc**

Resolve/create in `initState`, load once, own/dispose a `ScrollController`, use `BlocProvider.value`, one-shot `BlocListener`, and narrow builders. Remove `DispatcherSupportFakeData` usage.

- [ ] **Step 4: Use one lazy scroll tree**

Use slivers or indexed `ListView.builder`; never `...issues.map`, nested shrink-wrapped lists, or eager page rendering. Trigger next page near 300 logical pixels from the end; ViewModel remains the final duplicate-call guard.

- [ ] **Step 5: Apply core errors and typed navigation**

Full-page core error on initial failure; SnackBar/inline footer for nonfatal failures. Route argument contains `issueId`; do not fabricate a details entity or fetch details.

- [ ] **Step 6: Verify and commit**

```bash
flutter test test/dispatcher_support_screen_test.dart test/features/dispatcher/dispatcher_support
git add lib/features/dispatcher/dispatcher_support/presentation lib/config/routing test/dispatcher_support_screen_test.dart test/features/dispatcher/dispatcher_support
git commit -m "feat: integrate dispatcher support screen backend"
```

### Task 9: Remove runtime fake usage and verify everything

**Files:**
- Delete only if unreferenced: `domain/fake_data/dispatcher_support_fake_data.dart`
- Do not delete details/reassignment fake data.

- [ ] **Step 1: Prove list fake data is unused**

```bash
rg "DispatcherSupportFakeData" lib
```

Expected: no runtime reference. Delete its file only if nothing still consumes it.

- [ ] **Step 2: Format and regenerate**

```bash
dart format lib/features/dispatcher/dispatcher_support lib/core/network lib/core/di/di.dart lib/config/routing test/features/dispatcher/dispatcher_support test/dispatcher_support_screen_test.dart
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

- [ ] **Step 3: Targeted verification**

```bash
flutter test test/features/dispatcher/dispatcher_support test/dispatcher_support_screen_test.dart test/core/network/api_services_test.dart test/core/di/di_test.dart
```

- [ ] **Step 4: Project verification**

```bash
flutter analyze
flutter test
```

Expected: zero analyzer errors and all tests pass. Record exact unrelated pre-existing failures without modifying unrelated features.

- [ ] **Step 5: Manual acceptance**

With a `DeliveryManager` token verify all statuses, areas, date presets/custom UTC range, Arabic/English search and clear, multiple pages, empty result, offline initial/page failures, avatar fallback, exact ID navigation, and that no request occurs unless initial load, user filter/search action, retry, or next-page scroll triggers it.

- [ ] **Step 6: Final commit**

```bash
git add docs/superpowers/specs/2026-09-22-dispatcher-support-issues-design.md docs/superpowers/plans/2026-09-22-dispatcher-support-issues.md lib test
git commit -m "test: verify dispatcher support backend integration"
```

## Executor guardrails for Gemini

1. Read this plan, its spec, and `rules/rules_backend.md` fully before Task 1.
2. Execute tasks in order and run each red/green test cycle.
3. Treat the supplied backend JSON as authoritative; accept aliases in DTOs rather than redesigning the contract.
4. Keep aliases only in DTO/mapper code; presentation sees canonical entities.
5. Never add local filtering, fake runtime fallback, polling, or SignalR.
6. Do not redesign the support UI or refactor unrelated details/reassignment screens.
7. Never hand-edit generated code.
8. Do not claim completion without Task 9 command output.

