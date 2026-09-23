# Dispatcher Box Tracking Backend Integration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `DispatcherBoxTrackingScreen` fake data with the documented tracking and issue-reporting APIs while preserving the existing Screen 04.08/10.08 UI, adding shape-matched shimmer, typed error handling, retry/refresh, and success/error feedback through the shared custom Snackbar.

**Architecture:** Keep the existing feature-based Clean Architecture and implement `UI -> Event -> ViewModel -> UseCase -> Repository -> RemoteDataSource -> ApiServices`. The route supplies a raw GUID `boxId`; the ViewModel performs one REST snapshot load and owns independent page-loading and report-submission states. This screen does not create polling, SignalR, SSE, or WebSocket behavior because none is present in the supplied backend contract.

**Tech Stack:** Flutter, Dart, `flutter_bloc`, Dio, Retrofit, `json_serializable`, GetIt/Injectable, existing `ApiResult`/`safeApiCall`, `lib/core/errors`, `CustomBottomSheet`, `CustomSnackbar`, `AppCachedNetworkImage`, and `ShimmerWidget`.

**Spec:** `D:/yahya/meal meat/dis_new/screen-04.08-box-tracking.md`

## Global Constraints

- Follow `rules/rules_backend.md` exactly. Do not bypass a layer, create another Dio/Retrofit client, or manually attach auth/language headers already handled by interceptors.
- Preserve the current Screen 04.08/10.08 layout and widgets. This task is backend integration, not a redesign.
- Use `lib/core/errors` for typed failures. Initial failure renders `ApiErrorWidget.fromTypedFailure`; non-fatal/report failure uses `CustomSnackbar.showError` from `lib/core/widget/custom_snak_bar.dart`.
- **Initial loading must use a dedicated, shape-matched `BoxTrackingShimmer`. Do not use `CircularProgressIndicator`, plain text, fake data, or an empty white screen for initial loading.**
- Shimmer covers the header card, four timeline rows, driver card, details grid, and report button placeholder. Keep the real app bar visible.
- Reporting an issue uses a compact loading state inside the submit action; it must not replace already-loaded tracking content with the full-page shimmer.
- Response DTO fields and nested fields are nullable by default. Never force unwrap backend values.
- UI receives domain entities and ViewModel state only; DTOs must not leak into presentation.
- Remove runtime dependence on `BoxTrackingFakeData`. Never fall back to fake content after a real API error or missing route argument.
- The screen takes a raw GUID `boxId`, never `boxCode` and never a prebuilt `BoxTrackingEntity`.
- Treat `GET /tracking` as a one-shot REST snapshot. Do not implement periodic polling, SignalR, SSE, WebSocket, timers, or a Dart `Stream`.
- Pull-to-refresh and explicit retry are the only tracking reload mechanisms in this scope.
- Keep the existing callbacks/navigation hooks for Call, Message, Live Tracking, Back, and More where callers need them. Do not fabricate a `chatId`, conversation endpoint, driver coordinates, or live-location payload.
- `phoneNumber` is sufficient for the Call action, but adding a phone-launch dependency is outside this backend plan unless the dependency already exists when implementation begins.
- Message and Live Tracking must not claim to work solely from `driverId`; their missing backend/navigation contracts are sign-off items below.
- Do not manually edit `api_services.g.dart`, response `*.g.dart`, generated localization files, or `di.config.dart`. Run build generation.
- Preserve unrelated dirty-worktree changes, including the existing deletion under `dispatcher_assign_box`.

## Locked Backend Contract

### Tracking

```http
GET /api/v1/dispatcher/orders/{boxId}/tracking
```

The response maps `box`, `timeline`, `driver`, and `details` into one `BoxTrackingEntity`. The root `boxId` is the authoritative navigation ID; `box.boxCode` is display-only.

### Report issue

```http
POST /api/v1/dispatcher/orders/{boxId}/issues
Content-Type: application/json

{
  "issueType": "DelayedDelivery",
  "description": "...",
  "severity": "Medium"
}
```

Supported issue types in the supplied contract are exactly `DamagedBox`, `DelayedDelivery`, `WrongAddress`, `CustomerUnreachable`, and `Other`. `Medium` is the only documented severity value, so the first integration sends `Medium` without inventing a severity selector.

## Locked UI Behavior

- On entry, create/inject one `BoxTrackingViewModel`, dispatch `LoadBoxTrackingEvent`, and show `BoxTrackingShimmer` until the request resolves.
- On initial success, render only backend-derived data.
- On initial error, render the matching `ApiErrorWidget` with Retry and Back actions.
- Pull-to-refresh keeps current content visible while reloading. Refresh success replaces it; refresh failure preserves it and shows `CustomSnackbar.showError` once.
- Repeated load/refresh taps must not cause an older request to overwrite a newer result.
- Timeline order is determined by numeric `step` ascending, not response array order.
- Timeline state mapping is `Completed -> completed`, `Active -> active`, `Pending -> pending`; unknown values degrade to pending.
- Timeline icon mapping is `Restaurant`, `Driver`, `Truck`, and `Receipt`; unknown values use a neutral fallback icon.
- `statusText`, timestamps, and other server-formatted display strings are displayed as returned. The app uses typed enum values for visual logic and safe fallback styling.
- Tapping Report Issue opens `CustomBottomSheet`. It contains issue type selection, a required multiline description, Cancel, and Submit.
- Description is trimmed, must not be empty, and should use the backend-confirmed maximum length once supplied. Until then, do not invent client truncation.
- Submit is disabled while invalid or submitting. Repeated taps produce one POST.
- On report success, close the bottom sheet once and call `CustomSnackbar.showSuccess(context: context, message: backendMessage)`.
- On report failure, keep the form and user input open, stop the button loading state, and call `CustomSnackbar.showError` with the typed backend failure message.
- Reporting an issue does not automatically reload tracking because the documented response contains no updated tracking snapshot.

## Backend Sign-off Items

These are not blockers for rendering the page, but must not be silently guessed:

1. Confirm all permitted `severity` values and whether it is required. Until confirmed, send the only documented value: `Medium`.
2. Confirm description minimum/maximum length and whitespace rules.
3. Confirm whether duplicate reports require an idempotency key and which HTTP status indicates a duplicate/conflict.
4. Confirm the standard localized error envelope for `400`, `401`, `403`, `404`, `409`, `422`, and `500`.
5. Confirm whether `box`, `driver`, `details`, or any timeline fields can be null for valid records.
6. Provide a chat/conversation contract before wiring Message (`chatId` or create/open-conversation endpoint is missing).
7. Provide a live-location/navigation contract before wiring Live Tracking (driver coordinates or a documented map-focus lookup is missing).
8. Provide an explicit SignalR/SSE/WebSocket event contract if automatic live updates are required. The current file documents REST only.
9. Define the More menu actions; the design shows the button but does not define its commands.

---

### Task 1: Align the Box Tracking Domain Contract

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_driver_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_step_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_status.dart`
- Create: `lib/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_step_state.dart`
- Create: `lib/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_step_icon_kind.dart`
- Create: `lib/features/dispatcher/dispatcher_box_tracking/domain/entities/report_box_issue_request_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_box_tracking/domain/entities/report_box_issue_result_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_box_tracking/domain/entities/box_issue_type.dart`
- Create: `lib/config/routing/arguments/box_tracking_route_arguments.dart`
- Test: `test/features/dispatcher/dispatcher_box_tracking/domain/box_tracking_entities_test.dart`

**Interfaces:**
- Produces: API-safe tracking aggregate, typed status/timeline/issue enums, request/result entities, and `BoxTrackingRouteArguments(boxId: ...)`.
- Consumers: mapping, UseCases, ViewModel, route generator, and existing tracking widgets.

- [ ] **Step 1: Write failing domain tests**

Cover GUID route validation, all documented status/state/icon/issue values, unknown fallbacks, `driverCode`, `phoneNumber`, nullable avatar, box code distinct from ID, immutable timeline, and report request fields.

```dart
expect(
  const BoxTrackingRouteArguments(boxId: '').isValid,
  isFalse,
);
expect(BoxTrackingStepStateX.fromApi('Active'), BoxTrackingStepState.active);
expect(BoxIssueTypeX.fromApi('WrongAddress'), BoxIssueType.wrongAddress);
expect(BoxTrackingStepIconKindX.fromApi('unexpected'), BoxTrackingStepIconKind.unknown);
```

- [ ] **Step 2: Run the focused test and confirm failure**

Run: `flutter test test/features/dispatcher/dispatcher_box_tracking/domain/box_tracking_entities_test.dart`

Expected: FAIL because the current entities omit backend fields and use Flutter `IconData` inside Domain.

- [ ] **Step 3: Refactor the entities to represent the backend contract**

`BoxTrackingEntity` must contain:

```dart
final String boxId;
final String boxCode;
final BoxTrackingStatus status;
final String statusText;
final String statusColor;
final String customerName;
final String scheduledTimeText;
final String deliveryAddress;
final BoxTrackingDriverEntity? driver;
final String programType;
final String orderDateText;
final String customerNotes;
final String mealsSummary;
final List<BoxTrackingStepEntity> steps;
```

`BoxTrackingDriverEntity` contains `driverId`, `driverCode`, `fullName`, `phoneNumber`, and nullable `avatarUrl`. Remove the unbacked `isOnline` field.

`BoxTrackingStepEntity` contains numeric `step`, title, nullable description/timestamp, typed state, and typed icon kind. Remove Flutter `IconData` from Domain; presentation maps `iconKind` to icons.

- [ ] **Step 4: Add report entities and exact API serialization values**

```dart
class ReportBoxIssueRequestEntity {
  const ReportBoxIssueRequestEntity({
    required this.issueType,
    required this.description,
    this.severity = 'Medium',
  });
  final BoxIssueType issueType;
  final String description;
  final String severity;
}

class ReportBoxIssueResultEntity {
  const ReportBoxIssueResultEntity({
    required this.issueId,
    required this.boxId,
    required this.reportedAtUtc,
    required this.message,
  });
  final String issueId;
  final String boxId;
  final DateTime? reportedAtUtc;
  final String message;
}
```

- [ ] **Step 5: Run domain tests**

Run: `flutter test test/features/dispatcher/dispatcher_box_tracking/domain/box_tracking_entities_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit the domain contract**

```bash
git add lib/features/dispatcher/dispatcher_box_tracking/domain/entities lib/config/routing/arguments/box_tracking_route_arguments.dart test/features/dispatcher/dispatcher_box_tracking/domain/box_tracking_entities_test.dart
git commit -m "feat: define box tracking domain contracts"
```

### Task 2: Create Defensive DTOs and Mappers

**Files:**
- Create: `lib/features/dispatcher/dispatcher_box_tracking/data/models/response/box_tracking_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_box_tracking/data/models/request/report_box_issue_request_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_box_tracking/data/models/response/report_box_issue_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_box_tracking/data/mapper/box_tracking_mapper.dart`
- Generated: corresponding `*.g.dart` files
- Test: `test/features/dispatcher/dispatcher_box_tracking/data/box_tracking_dto_mapper_test.dart`

**Interfaces:**
- Consumes: Task 1 entities.
- Produces: `BoxTrackingResponseDto.toEntity()`, `ReportBoxIssueRequestEntity.toDto()`, and `ReportBoxIssueResponseDto.toEntity()`.

- [ ] **Step 1: Write failing JSON/mapping tests**

Use the complete supplied JSON examples. Also test null root children, null list, null timeline entries, missing driver, unknown enum strings, null text/color/icon fields, malformed timestamp, and missing report response message.

```dart
final entity = BoxTrackingResponseDto.fromJson(payload).toEntity();
expect(entity.boxId, '4f8a3c21-9b12-42e7-90c1-872f2316e110');
expect(entity.boxCode, '#BX-10256');
expect(entity.steps.map((e) => e.step), orderedEquals([1, 2, 3, 4]));
expect(entity.driver?.driverCode, 'DR-1025');

final dto = const ReportBoxIssueRequestEntity(
  issueType: BoxIssueType.delayedDelivery,
  description: 'Traffic delay',
).toDto();
expect(dto.toJson()['issueType'], 'DelayedDelivery');
expect(dto.toJson()['severity'], 'Medium');
```

- [ ] **Step 2: Run the mapper test and confirm failure**

Run: `flutter test test/features/dispatcher/dispatcher_box_tracking/data/box_tracking_dto_mapper_test.dart`

Expected: FAIL because DTOs and mapper do not exist.

- [ ] **Step 3: Implement nullable response DTO trees**

Use `@JsonSerializable(createToJson: false)` for response DTOs and standard `@JsonSerializable()` for the request. Every response property must be nullable, including nested DTOs and list entries. The request fields are required because the documented POST requires all three.

- [ ] **Step 4: Implement defensive mapping**

Sort timeline by `step`; map a null timeline to an immutable empty list; map unknown status/state/icon to typed unknown/pending fallback; preserve absent optional driver as null; parse `reportedAtUtc` with `DateTime.tryParse`; never create a fake driver, timeline row, customer, or details payload.

- [ ] **Step 5: Generate files and run the test**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/dispatcher/dispatcher_box_tracking/data/box_tracking_dto_mapper_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit DTO mapping**

```bash
git add lib/features/dispatcher/dispatcher_box_tracking/data test/features/dispatcher/dispatcher_box_tracking/data
git commit -m "feat: map box tracking API payloads"
```

### Task 3: Wire Tracking and Report-Issue APIs Through Clean Architecture

**Files:**
- Modify: `lib/core/network/network_constants.dart`
- Modify: `lib/core/network/api_services.dart`
- Generated: `lib/core/network/api_services.g.dart`
- Create: `lib/features/dispatcher/dispatcher_box_tracking/data/data_source/box_tracking_remote_data_source.dart`
- Create: `lib/features/dispatcher/dispatcher_box_tracking/data/data_source/box_tracking_remote_data_source_impl.dart`
- Create: `lib/features/dispatcher/dispatcher_box_tracking/domain/repo/box_tracking_repository.dart`
- Create: `lib/features/dispatcher/dispatcher_box_tracking/data/repo/box_tracking_repository_impl.dart`
- Create: `lib/features/dispatcher/dispatcher_box_tracking/domain/usecase/get_box_tracking_usecase.dart`
- Create: `lib/features/dispatcher/dispatcher_box_tracking/domain/usecase/report_box_issue_usecase.dart`
- Modify test: `test/core/network/api_services_test.dart`
- Test: `test/features/dispatcher/dispatcher_box_tracking/data/box_tracking_repository_test.dart`
- Test: `test/features/dispatcher/dispatcher_box_tracking/domain/box_tracking_usecases_test.dart`

**Interfaces:**
- Produces: `GetBoxTrackingUseCase.call(String boxId)` and `ReportBoxIssueUseCase.call(String boxId, ReportBoxIssueRequestEntity request)` returning existing `ApiResult` types.
- Consumes: Task 2 DTOs/mappers and shared `ApiServices`/`safeApiCall`.

- [ ] **Step 1: Write failing Retrofit contract tests**

Assert exact methods, paths, path replacement, and request JSON:

```dart
expect(trackingRequest.method, 'GET');
expect(trackingRequest.path, '/api/v1/dispatcher/orders/$boxId/tracking');
expect(issueRequest.method, 'POST');
expect(issueRequest.path, '/api/v1/dispatcher/orders/$boxId/issues');
expect(issueRequest.data['severity'], 'Medium');
```

- [ ] **Step 2: Add endpoint constants and Retrofit methods**

```dart
static const String dispatcherOrderTracking =
    '/api/v1/dispatcher/orders/{boxId}/tracking';
static const String dispatcherOrderIssues =
    '/api/v1/dispatcher/orders/{boxId}/issues';
```

```dart
@GET(EndPoints.dispatcherOrderTracking)
Future<BoxTrackingResponseDto> getBoxTracking(@Path('boxId') String boxId);

@POST(EndPoints.dispatcherOrderIssues)
Future<ReportBoxIssueResponseDto> reportBoxIssue(
  @Path('boxId') String boxId,
  @Body() ReportBoxIssueRequestDto request,
);
```

- [ ] **Step 3: Write failing repository and UseCase tests**

Cover mapping success, `safeApiCall` error conversion, no direct Dio exceptions escaping, invalid/blank/non-GUID box IDs rejected before repository calls, trimmed descriptions, empty description validation, and exact request mapping.

- [ ] **Step 4: Implement DataSource and Repository contracts**

```dart
abstract interface class BoxTrackingRemoteDataSource {
  Future<BoxTrackingResponseDto> getTracking(String boxId);
  Future<ReportBoxIssueResponseDto> reportIssue(
    String boxId,
    ReportBoxIssueRequestDto request,
  );
}

abstract interface class BoxTrackingRepository {
  Future<ApiResult<BoxTrackingEntity>> getTracking(String boxId);
  Future<ApiResult<ReportBoxIssueResultEntity>> reportIssue(
    String boxId,
    ReportBoxIssueRequestEntity request,
  );
}
```

Use `@LazySingleton(as: ...)` or the established neighboring annotation style. Repository implementations wrap remote calls and mapping with `safeApiCall`.

- [ ] **Step 5: Implement validated UseCases**

Use the existing GUID validation/error style from `GetAssignBoxDetailsUseCase`. `ReportBoxIssueUseCase` rejects an empty trimmed description with `ApiErrorType.validationError`; it must not create DTOs in the UI.

- [ ] **Step 6: Generate and run focused tests**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/core/network/api_services_test.dart
flutter test test/features/dispatcher/dispatcher_box_tracking/data/box_tracking_repository_test.dart
flutter test test/features/dispatcher/dispatcher_box_tracking/domain/box_tracking_usecases_test.dart
```

Expected: all PASS.

- [ ] **Step 7: Commit the API pipeline**

```bash
git add lib/core/network lib/features/dispatcher/dispatcher_box_tracking/data lib/features/dispatcher/dispatcher_box_tracking/domain/repo lib/features/dispatcher/dispatcher_box_tracking/domain/usecase test/core/network/api_services_test.dart test/features/dispatcher/dispatcher_box_tracking
git commit -m "feat: connect box tracking APIs"
```

### Task 4: Implement the ViewModel State Machine

**Files:**
- Create: `lib/features/dispatcher/dispatcher_box_tracking/presentation/manager/box_tracking_event.dart`
- Create: `lib/features/dispatcher/dispatcher_box_tracking/presentation/manager/box_tracking_state.dart`
- Create: `lib/features/dispatcher/dispatcher_box_tracking/presentation/manager/box_tracking_view_model.dart`
- Test: `test/features/dispatcher/dispatcher_box_tracking/presentation/manager/box_tracking_view_model_test.dart`

**Interfaces:**
- Consumes: Task 3 UseCases plus constructor `boxId`.
- Produces: injectable/factory-param ViewModel state for initial load, refresh, initial/non-fatal errors, report form selection/input, submission, and one-shot success/error notices.

- [ ] **Step 1: Write failing ViewModel tests**

Cover initial loading, success, initial failure, retry, refresh preserving data, refresh failure preserving data, stale request suppression, report field updates, empty submission guard, duplicate-submit guard, successful report message, failure preserving form state, and state reset after success.

```dart
final future = viewModel.doIntent(const LoadBoxTrackingEvent());
expect(viewModel.state.isInitialLoading, isTrue);
trackingCompleter.complete(ApiSuccessResult(data: tracking));
await future;
expect(viewModel.state.tracking, tracking);

await viewModel.doIntent(const SubmitBoxIssueEvent());
verifyNever(() => reportIssueUseCase(any(), any()));
```

- [ ] **Step 2: Run the focused test and confirm failure**

Run: `flutter test test/features/dispatcher/dispatcher_box_tracking/presentation/manager/box_tracking_view_model_test.dart`

Expected: FAIL because the state machine does not exist.

- [ ] **Step 3: Define events and immutable state**

Events:

```dart
LoadBoxTrackingEvent
RetryBoxTrackingEvent
RefreshBoxTrackingEvent
ChangeBoxIssueTypeEvent(BoxIssueType issueType)
ChangeBoxIssueDescriptionEvent(String description)
SubmitBoxIssueEvent
ResetBoxIssueFormEvent
```

State contains `tracking`, `isInitialLoading`, `isRefreshing`, `initialFailure`, `nonFatalFailure`, `selectedIssueType`, `issueDescription`, `isSubmittingIssue`, `reportFailure`, `reportSuccessMessage`, and monotonic `noticeId`/`reportNoticeId` values so `BlocListener` handles each notice exactly once.

- [ ] **Step 4: Implement deterministic intents**

Use a request generation counter for load/refresh. Initial errors populate `initialFailure`; refresh errors keep `tracking` and populate `nonFatalFailure`. Guard report submission when description is empty or a request is active. Submit `severity: 'Medium'` through the domain request entity.

- [ ] **Step 5: Run ViewModel tests**

Run: `flutter test test/features/dispatcher/dispatcher_box_tracking/presentation/manager/box_tracking_view_model_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit the state machine**

```bash
git add lib/features/dispatcher/dispatcher_box_tracking/presentation/manager test/features/dispatcher/dispatcher_box_tracking/presentation/manager
git commit -m "feat: manage box tracking state"
```

### Task 5: Add Mandatory Shape-Matched Shimmer and Error/Empty Presentation

**Files:**
- Create: `lib/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_shimmer.dart`
- Modify: `lib/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_timeline_step_item.dart`
- Modify: `lib/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_driver_card.dart`
- Test: `test/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_shimmer_test.dart`
- Test: `test/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_widgets_test.dart`

**Interfaces:**
- Consumes: shared `ShimmerWidget` and refactored domain entities.
- Produces: the required full-body loading skeleton and safe rendering for nullable driver/unknown backend values.

- [ ] **Step 1: Write failing widget tests**

Assert that the shimmer contains placeholders corresponding to the header, exactly four timeline rows, driver area, four detail values, and issue button. Also test missing driver, empty timeline, unknown status/icon, null timestamps, and long Arabic/English strings without overflow at 320px width.

- [ ] **Step 2: Run the tests and confirm failure**

```bash
flutter test test/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_shimmer_test.dart
flutter test test/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_widgets_test.dart
```

Expected: FAIL because no screen-specific shimmer exists and widgets still expect the old fake entity shape.

- [ ] **Step 3: Build `BoxTrackingShimmer` using `ShimmerWidget`**

Match the real vertical rhythm and card radii. The skeleton must be scroll-safe on small screens and use shared theme spacing/colors. Do not hardcode business text inside the shimmer and do not substitute fake entities.

- [ ] **Step 4: Adapt presentation mapping**

Map `BoxTrackingStepIconKind` to Flutter icons in presentation. Render absent driver as a localized unavailable state and disable its action buttons. Render an empty timeline/details value safely without crashing or inventing data.

- [ ] **Step 5: Run focused widget tests**

Run the two commands from Step 2.

Expected: PASS with no overflow or exception.

- [ ] **Step 6: Commit loading and resilient widgets**

```bash
git add lib/features/dispatcher/dispatcher_box_tracking/presentation/widgets test/features/dispatcher/dispatcher_box_tracking/presentation/widgets
git commit -m "feat: add box tracking shimmer states"
```

### Task 6: Build the Report-Issue Bottom Sheet

**Files:**
- Create: `lib/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_report_issue_sheet.dart`
- Modify: `lib/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_report_issue_button.dart`
- Modify: `lib/core/l10n/app_ar.arb`
- Modify: `lib/core/l10n/app_en.arb`
- Generated: localization output files
- Test: `test/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_report_issue_sheet_test.dart`

**Interfaces:**
- Consumes: ViewModel issue type/description/submission state.
- Produces: `CustomBottomSheet` form that dispatches typed events and preserves input on API failure.

- [ ] **Step 1: Write failing form tests**

Test all five documented issue types, initial default `Other`, multiline description editing, trimmed-empty validation, submit disabled while invalid/loading, a visible compact loading indicator during POST, cancellation without POST, and retained input after failure.

- [ ] **Step 2: Run the test and confirm failure**

Run: `flutter test test/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_report_issue_sheet_test.dart`

Expected: FAIL because the sheet does not exist.

- [ ] **Step 3: Add localized form copy**

Add Arabic/English labels for the sheet title, description, cancel/submit, the five issue types, required validation, and reporting state. Generate localization files rather than editing generated Dart by hand.

- [ ] **Step 4: Implement the bottom sheet**

Use `CustomBottomSheet.show`, shared controls/theme, and ViewModel events. Do not add a severity picker. Use the documented constant `Medium` in the request entity, not a UI DTO.

- [ ] **Step 5: Run localization generation and form tests**

```bash
flutter gen-l10n
flutter test test/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_report_issue_sheet_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit the report form**

```bash
git add lib/features/dispatcher/dispatcher_box_tracking/presentation/widgets lib/core/l10n test/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_report_issue_sheet_test.dart
git commit -m "feat: add box issue reporting form"
```

### Task 7: Connect the Screen, Snackbar Feedback, and Routing

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_box_tracking/presentation/screens/dispatcher_box_tracking_screen.dart`
- Modify: `lib/config/routing/routing_generator.dart`
- Modify: `lib/features/dispatcher/dispatcher_driver_details/presentation/screens/dispatcher_driver_details_screen.dart`
- Modify: operations/order/map navigation call sites returned by `rg -n "AppRoutes.boxTracking" lib`
- Modify: `test/features/dispatcher/dispatcher_box_tracking/dispatcher_box_tracking_screen_test.dart`
- Modify or create: `test/config/routing/box_tracking_route_test.dart`

**Interfaces:**
- Consumes: `BoxTrackingRouteArguments`, injected `BoxTrackingViewModel`, Tasks 5-6 widgets, `ApiErrorWidget`, and `CustomSnackbar`.
- Produces: backend-driven route and full screen behavior.

- [ ] **Step 1: Rewrite screen tests to fail against the fake implementation**

Provide a mocked ViewModel/UseCases rather than `BoxTrackingFakeData`. Assert:

- initial state displays `BoxTrackingShimmer`, not real cards;
- success displays all mapped backend fields;
- initial failure displays `ApiErrorWidget` and Retry calls the ViewModel;
- refresh retains loaded content;
- refresh failure calls `CustomSnackbar.showError` once;
- report success closes the sheet and calls `CustomSnackbar.showSuccess` with the backend message;
- report error leaves the sheet open and calls `CustomSnackbar.showError`;
- a 320x640 viewport has no overflow.

- [ ] **Step 2: Add route tests**

Assert the route accepts `BoxTrackingRouteArguments(boxId: guid)`, passes only the GUID to the screen/ViewModel, and rejects missing/invalid arguments with the existing typed route/error behavior. Assert there is no `BoxTrackingFakeData.defaultBox` fallback.

- [ ] **Step 3: Convert the screen to ViewModel-driven rendering**

The public constructor takes `boxId` plus optional UI callbacks. Use `BlocProvider` with injected dependencies and dispatch initial load once. Use `BlocConsumer`/`BlocListener` for one-shot Snackbar effects:

```dart
CustomSnackbar.showSuccess(context: context, message: message);
CustomSnackbar.showError(
  context: context,
  message: failure.errorMessage,
);
```

Render in this priority: initial shimmer -> initial typed error -> loaded content. Wrap loaded content in `RefreshIndicator` without turning refresh into full-page shimmer.

- [ ] **Step 4: Wire report-sheet lifecycle**

The screen opens the sheet on the existing report button. A success notice pops only the sheet, clears the form, and shows success. An error notice leaves the sheet mounted and shows the error through `CustomSnackbar.showError`.

- [ ] **Step 5: Migrate every caller to ID-based routing**

Replace prebuilt `BoxTrackingEntity` arguments with:

```dart
BoxTrackingRouteArguments(boxId: boxId)
```

Do not construct timeline/driver/details data in Driver Details, Operations Log, Orders Queue, or Map before navigation. The tracking endpoint is the sole page-data source.

- [ ] **Step 6: Run screen and routing tests**

```bash
flutter test test/features/dispatcher/dispatcher_box_tracking/dispatcher_box_tracking_screen_test.dart
flutter test test/config/routing/box_tracking_route_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit the connected screen**

```bash
git add lib/features/dispatcher/dispatcher_box_tracking/presentation/screens lib/config/routing lib/features/dispatcher test/features/dispatcher/dispatcher_box_tracking test/config/routing/box_tracking_route_test.dart
git commit -m "feat: load box tracking from backend"
```

### Task 8: Remove Fake Runtime Paths and Complete Regression Verification

**Files:**
- Delete when no production caller remains: `lib/features/dispatcher/dispatcher_box_tracking/domain/fake_data/box_tracking_fake_data.dart`
- Modify: tests still importing the fake fixture; replace with local test builders/fixtures
- Generated: `lib/core/network/api_services.g.dart`, DTO `*.g.dart`, localization files, `lib/core/di/di.config.dart`

**Interfaces:**
- Produces: zero fake runtime dependency and a verified generated build.

- [ ] **Step 1: Prove fake data is unused by production**

Run:

```bash
rg -n "BoxTrackingFakeData|defaultBox|defaultSteps" lib
```

Expected: no matches outside the fake file itself. If `dispatcher_driver_details` still uses `defaultSteps`, replace that unrelated fake coupling with its own domain/test fixture before deletion; do not move backend tracking data back into Driver Details.

- [ ] **Step 2: Remove the fake file and update test fixtures**

Delete only after Step 1 proves all production references are gone. Tests construct explicit domain fixtures under test helpers or inside their test files.

- [ ] **Step 3: Regenerate code**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
dart format lib/features/dispatcher/dispatcher_box_tracking test/features/dispatcher/dispatcher_box_tracking lib/config/routing/arguments/box_tracking_route_arguments.dart
```

- [ ] **Step 4: Run static analysis and the complete relevant test suite**

```bash
flutter analyze
flutter test test/features/dispatcher/dispatcher_box_tracking
flutter test test/core/network/api_services_test.dart
flutter test test/config/routing
```

Expected: no new analyzer errors and all tests PASS.

- [ ] **Step 5: Perform manual acceptance checks**

Verify Arabic RTL and English LTR, initial shimmer visibility on a throttled connection, typed retry for offline/timeout/server errors, pull-to-refresh, long strings, null avatar, missing driver, report success/error, duplicate-submit blocking, and 320px-wide layout. Confirm network logs show one GET on entry and no polling/SignalR connection from this feature.

- [ ] **Step 6: Final contract audit**

Run:

```bash
rg -n "BoxTrackingFakeData|CircularProgressIndicator|Timer.periodic|StreamBuilder|SignalR|HubConnection" lib/features/dispatcher/dispatcher_box_tracking
rg -n "CustomSnackbar.show(Success|Error)|BoxTrackingShimmer|ApiErrorWidget.fromTypedFailure" lib/features/dispatcher/dispatcher_box_tracking
```

Expected: no fake/runtime-stream matches; loading/error/Snackbar integrations are present. A compact progress indicator inside only the report submit button is allowed if it is the shared button loading implementation.

- [ ] **Step 7: Commit cleanup and verification artifacts**

```bash
git add lib test
git commit -m "test: verify box tracking integration"
```

## Definition of Done

- The route and screen require a real GUID `boxId`.
- No production code uses `BoxTrackingFakeData`.
- Initial load always shows the mandatory shape-matched `BoxTrackingShimmer`.
- Tracking data comes only from `GET /api/v1/dispatcher/orders/{boxId}/tracking`.
- Reporting uses only `POST /api/v1/dispatcher/orders/{boxId}/issues` with a domain request and documented values.
- Initial errors use `lib/core/errors`; refresh/report feedback uses `lib/core/widget/custom_snak_bar.dart`.
- Success and error notices are shown exactly once.
- Loaded data stays visible during refresh and report submission.
- No Stream, polling, SignalR, SSE, or WebSocket is introduced.
- Message/live-map gaps remain explicitly unwired until their backend contracts exist.
- Generated files are regenerated, not hand-edited.
- Focused tests, route tests, `flutter analyze`, and relevant regression tests pass.
