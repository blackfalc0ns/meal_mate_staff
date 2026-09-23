# Dispatcher Assign Box Backend Integration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the fake `AssignBoxScreen` with backend-driven box details, best suggestion, candidate selection, lazy View Box summary, and conflict-safe assignment while preserving the supplied Screen 04.04/10.02 design.

**Architecture:** `dispatcher_assign_box` owns the assignment-details and box-summary read flows through UI → Event → ViewModel → UseCase → Repository → RemoteDataSource → shared `ApiServices`. The screen reuses the single `AssignDriverToBoxUseCase` and assignment result contract already defined by the Driver Roster integration plan, avoiding a duplicate POST pipeline. One immutable ViewModel state owns initial details, single selection, lazy summary state, and submission state; full-screen and modal loading are represented with shape-matched shimmer.

**Tech Stack:** Flutter, Dart, `flutter_bloc`, Dio, Retrofit, `json_serializable`, GetIt/Injectable, existing `ApiResult`/`safeApiCall`, `lib/core/errors`, `AppCachedNetworkImage`, `CustomBottomSheet`, and `ShimmerWidget`.

**Spec:** `D:/yahya/meal meat/dis_new/screen-04.04-box-details-assignment (1).md`

**Dependency:** Reuse `AssignDriverRequestEntity`, `DriverAssignmentResultEntity`, and `AssignDriverToBoxUseCase` from `dispatcher_drivers` as defined by `docs/superpowers/plans/2026-09-23-dispatcher-driver-roster-assignment-backend-integration.md`. Do not declare the POST endpoint, request DTO, response DTO, repository method, or UseCase a second time.

## Global Constraints

- Follow `rules/rules_backend.md` exactly; preserve the mandatory Clean Architecture flow and do not bypass layers.
- Scope is Screen 04.04/10.02 (`dispatcher_assign_box`) plus the minimum Orders Queue/routing handoff required for a real `boxId` and refresh result. Do not redesign the screen or alter unrelated Driver Roster/Operations work.
- Reuse shared `ApiServices`, injected Dio, token/language interceptors, `ApiResult`, `safeApiCall`, `Failure`, GetIt/Injectable, and `lib/core/errors` widgets.
- Response DTO fields, nested objects, and lists are nullable and defensive. Never force-unwrap backend values.
- DTOs remain in Data; presentation consumes domain entities, ViewModel state, and events only.
- Initial load must render `AssignBoxShimmer`, matching the box card, best-suggestion card, candidate rows, and bottom actions. Never use `CircularProgressIndicator` for initial page loading.
- Opening View Box before its summary is cached must immediately open the modal and render `AssignBoxSummaryShimmer` inside it until the request succeeds or fails.
- Submitting assignment uses the existing button's loading facility or an inline compact progress indicator inside the confirm button only; it must not replace the loaded page with full-screen shimmer.
- Initial details failure uses `ApiErrorWidget.fromTypedFailure`; summary failure uses `InlineApiErrorWidget` inside the open modal; submission failure keeps screen data/selection and uses the existing Snackbar/error presentation.
- Successful empty/null details are treated as a valid empty/unavailable state only when the API contract permits it; never substitute `AssignBoxFakeData` after a real request.
- Use `AppCachedNetworkImage` for driver avatars. Do not send HTTP URLs to `AssetImage`.
- Every driver returned in `bestSuggestion` or `candidates` is selectable. `driverStatus` controls visual presentation only; the assignment POST performs the authoritative availability check.
- The app sends the raw GUID `boxId`; it never derives it from `boxCode`.
- Do not manually add Authorization or Accept-Language headers and do not add a second HTTP client.
- Do not manually edit generated `api_services.g.dart`, response `*.g.dart`, localization output, or `di.config.dart`; regenerate them.
- Preserve all unrelated dirty-worktree changes. The Driver Roster plan is currently being implemented and its files must not be overwritten.

## Locked Behavior

- The route argument for this screen is a non-empty GUID `boxId`, not a prebuilt fake `AssignBoxOrderEntity`.
- The first successful details response selects `bestSuggestion.driverId` by default when it exists; otherwise it selects the first candidate when available; otherwise selection stays null and Confirm is disabled.
- Selection is local and single-choice. Selecting a candidate deselects the best suggestion, and selecting the best suggestion again deselects the candidate.
- Candidate status values `Available`, `Busy`, `InDelivery`, and `Returning` remain selectable because the backend intentionally returned those drivers as assignment candidates.
- Selection changes do not refetch details and do not show shimmer.
- Pull-to-refresh/refetch preserves the selected driver only if that driver is still returned; otherwise selection falls back using the default rule.
- View Box summary is loaded lazily on first tap and cached for the lifetime of the screen. A second tap reopens cached data without another request; retry after failure performs a new request.
- Confirm is disabled when no driver is selected or while submission is active. Repeated taps produce exactly one POST.
- Assignment notes are generated in the domain/presentation coordinator as `إسناد سريع للبوكس {boxCode}` or its localized equivalent; the UI does not instantiate a DTO.
- On assignment success, show the backend `message`, then `Navigator.pop(context, true)` exactly once. Orders Queue receives `true` and dispatches `RefreshDispatcherOrdersEvent`.
- On `409 Conflict`, keep the screen open, show the typed backend message, and refetch assignment details because driver availability or box assignment state may have changed.
- The server, not the mobile client, is responsible for notifying the driver and publishing SignalR events. The mobile client only handles the POST result and refreshes Orders Queue.
- Notification bell state remains outside these three endpoints and must not be hardcoded as unread as part of this integration.

## Backend Sign-off Items

The visual payload is complete. These behavioral points require confirmation for production hardening, but the client has safe behavior defined above:

1. Confirm whether `bestSuggestion` can be null and whether `candidates` may be empty.
2. Confirm the assignment conflict/error codes for already-assigned box, changed driver availability, capacity exceeded, and cross-restaurant IDs; use `409` for state conflicts and `403` for ownership violations.
3. Confirm `notes` optionality and maximum length.
4. Confirm the standard localized error envelope `{code, message, errors}` for `400`, `401`, `403`, `404`, `409`, `422`, and `500`.
5. Confirm POST idempotency or idempotency-key support. Client-side tap blocking cannot prevent another device assigning the same box.
6. Confirm `summary` masking rules for customer data and that only authorized `DeliveryManager` users can read it.
7. Confirm the server emits its assignment SignalR event after the transaction commits; the mobile screen must not fabricate or publish this event.

---

### Task 1: Define Assignment Details and Box Summary Domain Models

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_order_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_candidate_driver_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_driver_status_type.dart`
- Create: `lib/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_priority.dart`
- Create: `lib/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_status.dart`
- Create: `lib/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_details_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_summary_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_meal_entity.dart`
- Create: `lib/config/routing/arguments/assign_box_route_arguments.dart`
- Test: `test/features/dispatcher/dispatcher_assign_box/domain/assign_box_entities_test.dart`

**Interfaces:**
- Produces: route args containing only real `boxId`, typed box/status/priority/driver entities, aggregate details, and summary/meal entities.
- Reuses: assignment request/result entities from the Driver Roster plan.

- [ ] **Step 1: Write failing entity tests**

Cover route validation, API enum values and unknown fallbacks, all four driver statuses, separate ID/display fields, immutable lists, and default selection rules.

```dart
expect(
  const AssignBoxRouteArgs(boxId: '').isValid,
  isFalse,
);
expect(
  AssignBoxDriverStatusTypeX.fromApi('Returning'),
  AssignBoxDriverStatusType.returning,
);
expect(
  AssignBoxPriorityX.fromApi('HighPriority'),
  AssignBoxPriority.high,
);
```

- [ ] **Step 2: Run the focused test and verify failure**

Run: `flutter test test/features/dispatcher/dispatcher_assign_box/domain/assign_box_entities_test.dart`

Expected: FAIL because the backend domain contract is incomplete.

- [ ] **Step 3: Refine box and driver entities**

`AssignBoxOrderEntity` becomes the backend box summary used by the top card and contains `boxId`, `boxCode`, `zoneName`, `deliveryTimeWindow`, numeric/label meal count, numeric/text distance, typed priority plus badge text, and typed status plus badge text.

`AssignBoxCandidateDriverEntity` contains:

```dart
final String driverId;
final String fullName;
final String? avatarUrl;
final String? plateNumber;
final String? phone;
final double? distanceKm;
final String distanceText;
final int activeOrdersCount;
final int currentLoadBoxes;
final String currentLoadLabel;
final double? rating;
final AssignBoxDriverStatusType status;
final String driverStatusText;
final String statusTag;
final String estimatedFinishTimeText;
final int rank;
final bool isRecommended;
final String? recommendationReason;
```

Add compatibility getters only where necessary for staged widget migration; remove them before Definition of Done if no caller remains.

- [ ] **Step 4: Define aggregate and summary entities**

```dart
class AssignBoxDetailsEntity {
  const AssignBoxDetailsEntity({
    required this.box,
    required this.bestSuggestion,
    required this.candidates,
  });
  final AssignBoxOrderEntity box;
  final AssignBoxCandidateDriverEntity? bestSuggestion;
  final List<AssignBoxCandidateDriverEntity> candidates;
}

class AssignBoxSummaryEntity {
  const AssignBoxSummaryEntity({
    required this.boxId,
    required this.boxCode,
    required this.customerMaskedId,
    required this.customerNameMasked,
    required this.customerPhoneMasked,
    required this.zoneName,
    required this.address,
    required this.deliveryTimeWindow,
    required this.boxCount,
    required this.barcode,
    required this.deliveryNotes,
    required this.allergies,
    required this.meals,
  });
}
```

Summary strings that may be legitimately absent remain nullable. `allergies` and `meals` are immutable empty lists when absent.

- [ ] **Step 5: Run domain tests**

Run: `flutter test test/features/dispatcher/dispatcher_assign_box/domain/assign_box_entities_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit domain contracts**

```bash
git add lib/features/dispatcher/dispatcher_assign_box/domain/entities lib/config/routing/arguments/assign_box_route_arguments.dart test/features/dispatcher/dispatcher_assign_box/domain/assign_box_entities_test.dart
git commit -m "feat: define assign box domain contracts"
```

### Task 2: Create Defensive Assignment Details and Summary DTO Mapping

**Files:**
- Create: `lib/features/dispatcher/dispatcher_assign_box/data/models/response/assign_box_details_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_assign_box/data/models/response/assign_box_summary_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_assign_box/data/mapper/assign_box_mapper.dart`
- Generated: corresponding `*.g.dart` files
- Test: `test/features/dispatcher/dispatcher_assign_box/data/assign_box_dto_mapper_test.dart`

**Interfaces:**
- Consumes: Task 1 entities.
- Produces: `AssignBoxDetailsResponseDto.toEntity()` and `AssignBoxSummaryResponseDto.toEntity()`.

- [ ] **Step 1: Write failing JSON and mapper tests**

Test the full documented details/summary payloads plus null best suggestion, null/empty candidates, missing box, unknown enum values, null avatar/contact/rating/distance, malformed numeric values, null allergies/meals, null meal notes, and repeated meal categories.

```dart
final entity = AssignBoxDetailsResponseDto.fromJson(payload).toEntity();
expect(entity.box.boxId, 'a1111111-1111-1111-1111-111111111111');
expect(entity.bestSuggestion?.driverId,
    '33333333-3333-3333-3333-333333333333');
expect(entity.candidates.length, 4);

final summary = AssignBoxSummaryResponseDto.fromJson(summaryJson).toEntity();
expect(summary.meals.first.quantity, 2);
expect(summary.allergies, contains('مكسرات'));
```

- [ ] **Step 2: Run mapper tests and verify failure**

Run: `flutter test test/features/dispatcher/dispatcher_assign_box/data/assign_box_dto_mapper_test.dart`

Expected: FAIL because response DTOs/mappers are absent.

- [ ] **Step 3: Implement nullable DTO trees**

Use `@JsonSerializable(createToJson: false)`. Keep the details root, box DTO, and driver DTO together in `assign_box_details_response_dto.dart`. Keep summary root and meal DTO together in `assign_box_summary_response_dto.dart`. Every response field is nullable.

- [ ] **Step 4: Implement defensive mapping**

Map null candidates/meals/allergies to immutable empty lists; missing best suggestion to null; unknown statuses/priorities to typed unknown values; invalid numbers to safe display defaults; missing `isRecommended` to false; and invalid/missing IDs to empty strings that route/UseCase validation can reject. Never manufacture a fake driver or meal.

- [ ] **Step 5: Generate and run mapper tests**

Run: `dart run build_runner build --delete-conflicting-outputs`

Then: `flutter test test/features/dispatcher/dispatcher_assign_box/data/assign_box_dto_mapper_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit DTO mapping**

```bash
git add lib/features/dispatcher/dispatcher_assign_box/data/models lib/features/dispatcher/dispatcher_assign_box/data/mapper test/features/dispatcher/dispatcher_assign_box/data/assign_box_dto_mapper_test.dart
git commit -m "feat: map assign box API responses"
```

### Task 3: Wire Assignment Details and Summary Read APIs

**Files:**
- Modify: `lib/core/network/network_constants.dart`
- Modify: `lib/core/network/api_services.dart`
- Generated: `lib/core/network/api_services.g.dart`
- Create: `lib/features/dispatcher/dispatcher_assign_box/data/data_source/assign_box_remote_data_source.dart`
- Create: `lib/features/dispatcher/dispatcher_assign_box/data/data_source/assign_box_remote_data_source_impl.dart`
- Create: `lib/features/dispatcher/dispatcher_assign_box/domain/repo/assign_box_repository.dart`
- Create: `lib/features/dispatcher/dispatcher_assign_box/data/repo/assign_box_repository_impl.dart`
- Create: `lib/features/dispatcher/dispatcher_assign_box/domain/usecase/get_assign_box_details_usecase.dart`
- Create: `lib/features/dispatcher/dispatcher_assign_box/domain/usecase/get_assign_box_summary_usecase.dart`
- Modify test: `test/core/network/api_services_test.dart`
- Test: `test/features/dispatcher/dispatcher_assign_box/data/assign_box_repository_test.dart`
- Test: `test/features/dispatcher/dispatcher_assign_box/domain/assign_box_usecases_test.dart`

**Interfaces:**
- Produces: two Retrofit GET methods and two validated read UseCases.
- Reuses: existing Driver Roster assignment POST UseCase; Task 3 must not duplicate it.

- [ ] **Step 1: Write failing Retrofit contract tests**

```dart
expect(detailsRequest.method, 'GET');
expect(detailsRequest.path,
    '/api/v1/dispatcher/orders/$boxId/assignment-details');
expect(summaryRequest.method, 'GET');
expect(summaryRequest.path,
    '/api/v1/dispatcher/orders/$boxId/summary');
```

Assert path substitution and absence of manually supplied auth/language headers at the feature call site.

- [ ] **Step 2: Add endpoint constants and Retrofit declarations**

```dart
static const String dispatcherAssignmentDetails =
    '/api/v1/dispatcher/orders/{boxId}/assignment-details';
static const String dispatcherOrderSummary =
    '/api/v1/dispatcher/orders/{boxId}/summary';
```

```dart
@GET(EndPoints.dispatcherAssignmentDetails)
Future<AssignBoxDetailsResponseDto> getAssignBoxDetails(
  @Path('boxId') String boxId,
);

@GET(EndPoints.dispatcherOrderSummary)
Future<AssignBoxSummaryResponseDto> getAssignBoxSummary(
  @Path('boxId') String boxId,
);
```

- [ ] **Step 3: Write failing repository and UseCase tests**

Cover success mapping, Dio errors through `safeApiCall`, malformed response safety, and local rejection of empty/non-GUID box IDs without calling the repository.

- [ ] **Step 4: Implement DataSource, Repository, and read UseCases**

```dart
abstract interface class AssignBoxRemoteDataSource {
  Future<AssignBoxDetailsResponseDto> getDetails(String boxId);
  Future<AssignBoxSummaryResponseDto> getSummary(String boxId);
}

abstract interface class AssignBoxRepository {
  Future<ApiResult<AssignBoxDetailsEntity>> getDetails(String boxId);
  Future<ApiResult<AssignBoxSummaryEntity>> getSummary(String boxId);
}
```

Use Injectable constructor bindings. Repository wraps remote calls/mapping in `safeApiCall`. UseCases validate the ID and return `ApiErrorResult` with `ApiErrorType.validationError` for invalid input.

- [ ] **Step 5: Generate and run focused tests**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/core/network/api_services_test.dart
flutter test test/features/dispatcher/dispatcher_assign_box/data/assign_box_repository_test.dart
flutter test test/features/dispatcher/dispatcher_assign_box/domain/assign_box_usecases_test.dart
```

Expected: all PASS.

- [ ] **Step 6: Commit read pipeline**

```bash
git add lib/core/network lib/features/dispatcher/dispatcher_assign_box/data lib/features/dispatcher/dispatcher_assign_box/domain/repo lib/features/dispatcher/dispatcher_assign_box/domain/usecase test/core/network/api_services_test.dart test/features/dispatcher/dispatcher_assign_box
git commit -m "feat: connect assign box detail APIs"
```

### Task 4: Implement the Assign Box ViewModel State Machine

**Files:**
- Create: `lib/features/dispatcher/dispatcher_assign_box/presentation/manager/assign_box_event.dart`
- Create: `lib/features/dispatcher/dispatcher_assign_box/presentation/manager/assign_box_state.dart`
- Create: `lib/features/dispatcher/dispatcher_assign_box/presentation/manager/assign_box_view_model.dart`
- Test: `test/features/dispatcher/dispatcher_assign_box/presentation/manager/assign_box_view_model_test.dart`

**Interfaces:**
- Consumes: `GetAssignBoxDetailsUseCase`, `GetAssignBoxSummaryUseCase`, and reused `AssignDriverToBoxUseCase`.
- Produces: injectable ViewModel with deterministic details, selection, summary, and submit states.

- [ ] **Step 1: Write failing state-machine tests**

Cover initial load/shimmer, default best-suggestion selection, fallback candidate selection, no-candidate disabled state, single selection, refresh preservation/fallback, lazy summary caching/retry, duplicate-summary guard, submit request content, duplicate-submit guard, success event, ordinary submit failure, and 409 details refetch.

```dart
await vm.doIntent(const LoadAssignBoxEvent());
expect(vm.state.isInitialLoading, isTrue);

detailsCompleter.complete(successDetails);
await loadFuture;
expect(vm.state.selectedDriverId,
    successDetails.bestSuggestion!.driverId);

await vm.doIntent(const SelectAssignBoxDriverEvent(candidateId));
expect(vm.state.selectedDriverId, candidateId);
```

- [ ] **Step 2: Define events and immutable state**

Events:

```dart
LoadAssignBoxEvent
RetryAssignBoxDetailsEvent
RefreshAssignBoxDetailsEvent
SelectAssignBoxDriverEvent
LoadAssignBoxSummaryEvent
RetryAssignBoxSummaryEvent
SubmitAssignBoxEvent({required String localizedNotes})
ClearAssignBoxNoticeEvent
```

State fields:

```dart
String boxId;
AssignBoxDetailsEntity? details;
String? selectedDriverId;
AssignBoxSummaryEntity? summary;
bool isInitialLoading;
bool isRefreshLoading;
bool isSummaryLoading;
bool isSubmitting;
Failure? initialFailure;
Failure? refreshFailure;
Failure? summaryFailure;
Failure? submitFailure;
DriverAssignmentResultEntity? assignmentResult;
int noticeId;
int successId;
```

Use sentinel-based `copyWith` for nullable data/failures. Add derived getters `canSubmit`, `selectedDriver`, and `hasCandidates`.

- [ ] **Step 3: Implement details and selection logic**

Initial load sets `isInitialLoading=true` before awaiting. Refresh keeps current content and uses `isRefreshLoading`; on success preserve selection only if its ID remains in best/candidates. Use a request-generation counter to ignore stale refresh/load responses.

- [ ] **Step 4: Implement lazy summary loading and cache**

If `summary != null`, `LoadAssignBoxSummaryEvent` returns without API call. If already loading, ignore duplicate tap. Failure remains scoped to summary state and does not alter details or selection. Retry clears only `summaryFailure` and calls summary again.

- [ ] **Step 5: Implement duplicate-safe submission**

Ignore submit if `!canSubmit` or already submitting. Build:

```dart
AssignDriverRequestEntity(
  boxId: state.details!.box.boxId,
  driverId: state.selectedDriverId!,
  notes: localizedNotes,
)
```

The screen creates the localized string from `boxCode` and dispatches `SubmitAssignBoxEvent(localizedNotes: notes)`, so Domain remains localization-free and the ViewModel has an explicitly defined `localizedNotes` input. Success increments `successId`. Error increments `noticeId`; typed conflict triggers a details refresh after emitting the failure notice.

- [ ] **Step 6: Run ViewModel tests**

Run: `flutter test test/features/dispatcher/dispatcher_assign_box/presentation/manager/assign_box_view_model_test.dart`

Expected: PASS; every awaited loading state is observable and duplicate calls remain one.

- [ ] **Step 7: Commit ViewModel**

```bash
git add lib/features/dispatcher/dispatcher_assign_box/presentation/manager test/features/dispatcher/dispatcher_assign_box/presentation/manager/assign_box_view_model_test.dart
git commit -m "feat: manage assign box workflow state"
```

### Task 5: Build Mandatory Page and Modal Shimmer States

**Files:**
- Create: `lib/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_shimmer.dart`
- Create: `lib/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_summary_shimmer.dart`
- Test: `test/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_shimmer_test.dart`

**Interfaces:**
- Produces: exact structural loading views for page details and View Box modal.

- [ ] **Step 1: Write failing shimmer tests first**

```dart
expect(find.byType(AssignBoxShimmer), findsOneWidget);
expect(find.byType(ShimmerWidget), findsWidgets);
expect(find.byType(CircularProgressIndicator), findsNothing);
```

Test structural sections rather than pixel snapshots: one box-card block, one recommendation-card block, four candidate-row blocks, and bottom-action placeholders. Test `AssignBoxSummaryShimmer` contains identity/barcode blocks, customer/address blocks, and at least three meal-row blocks.

- [ ] **Step 2: Run tests and verify failure**

Run: `flutter test test/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_shimmer_test.dart`

Expected: FAIL because shimmer widgets are missing.

- [ ] **Step 3: Implement `AssignBoxShimmer`**

Use only `ShimmerWidget`, `Spacing`, and theme structure. Mirror the current screen vertically:

- title-safe header spacing;
- summary card height/columns;
- highlighted recommendation card;
- candidates header and four rows;
- fixed bottom-action row.

The shimmer must fit narrow viewports without overflow and use `NeverScrollableScrollPhysics` only where appropriate. Do not show fake text/data while loading.

- [ ] **Step 4: Implement `AssignBoxSummaryShimmer`**

This widget renders inside `CustomBottomSheet`, not as a page. Mirror the eventual summary sections and constrain height for small screens. It appears immediately when View Box is tapped and remains until summary success/failure.

- [ ] **Step 5: Run shimmer tests**

Run: `flutter test test/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_shimmer_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit shimmer states**

```bash
git add lib/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_shimmer.dart lib/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_summary_shimmer.dart test/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_shimmer_test.dart
git commit -m "feat: add assign box shimmer states"
```

### Task 6: Adapt Existing Cards and Build View Box Modal

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_summary_card.dart`
- Modify: `lib/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_recommended_card.dart`
- Modify: `lib/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_driver_card.dart`
- Modify: `lib/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_driver_avatar.dart`
- Modify: `lib/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_driver_status_badge.dart`
- Modify: `lib/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_bottom_actions.dart`
- Create: `lib/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_summary_bottom_sheet.dart`
- Create: `lib/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_summary_content.dart`
- Create: `lib/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_summary_meal_row.dart`
- Test: `test/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_backend_widgets_test.dart`

**Interfaces:**
- Consumes: Task 1 domain entities and ViewModel-supplied state/callbacks.
- Produces: backend-driven existing design, network images, loading-aware actions, and summary modal.

- [ ] **Step 1: Write failing widget tests**

Cover all box fields, best suggestion, four status styles, rank/tag/rating, network avatar and fallback, single radio selection, Confirm disabled/loading states, complete summary/modal content, null optional fields, no allergies, and empty meals.

```dart
expect(find.text('#BX-1256'), findsWidgets);
expect(find.text('سالم الحربي'), findsOneWidget);
expect(find.text('4 بوكسات'), findsOneWidget);
expect(find.byType(AppCachedNetworkImage), findsWidgets);
expect(find.text('MM-BX-1256-KWT'), findsOneWidget);
expect(find.text('سالمون مشوي مع الكينوا والخضار السوتيه'), findsOneWidget);
```

- [ ] **Step 2: Bind box and driver widgets to backend entities**

Remove display fallbacks such as hardcoded `0 بوكسات` and `10:20 ص`; show mapped values or an em dash for missing optional display data. Status colors come from typed `AssignBoxDriverStatusType`, not string comparisons. Both best suggestion and every candidate remain tappable/selectable.

- [ ] **Step 3: Replace avatar asset assumptions**

Use `AppCachedNetworkImage(shape: BoxShape.circle)` with the current person icon fallback for null/failed URLs. Preserve semantics and existing dimensions.

- [ ] **Step 4: Make bottom actions state-aware**

Add `isConfirmEnabled`, `isSubmitting`, and `isViewBoxLoading`/callback protection as appropriate. Only the Confirm button may show a compact inline progress indicator during POST. The initial page and summary modal continue to use shimmer.

- [ ] **Step 5: Implement View Box modal content**

Use `CustomBottomSheet.show` with scroll control and safe area. Display masked customer identity/phone, zone/address/time, box count, barcode as selectable text, delivery notes, allergy chips, and meal rows with quantity/category/optional notes. Empty allergies and meals render localized empty labels, not errors.

- [ ] **Step 6: Run widget tests**

Run: `flutter test test/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_backend_widgets_test.dart`

Expected: PASS in Arabic, English, and a 360px viewport without overflow.

- [ ] **Step 7: Commit backend widgets and modal**

```bash
git add lib/features/dispatcher/dispatcher_assign_box/presentation/widgets test/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_backend_widgets_test.dart
git commit -m "feat: render assign box API data"
```

### Task 7: Connect Screen, Routing, View All, and Orders Refresh

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_assign_box/presentation/screens/assign_box_screen.dart`
- Modify: `lib/config/routing/routing_generator.dart`
- Modify: `lib/features/dispatcher/dispatcher_orders/presentation/screens/dispatcher_orders_screen.dart`
- Modify: `lib/features/dispatcher/dispatcher_orders/presentation/widgets/dispatcher_orders_list.dart`
- Modify: `lib/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_drivers_header.dart`
- Modify localization: `lib/core/l10n/app_ar.arb`
- Modify localization: `lib/core/l10n/app_en.arb`
- Generated localization files via project command
- Test: `test/features/dispatcher/dispatcher_assign_box/presentation/assign_box_backend_test.dart`
- Modify test: `test/assign_box_screen_test.dart`
- Modify test: `test/dispatcher_orders_screen_test.dart`

**Interfaces:**
- Consumes: `AssignBoxRouteArgs`, `AssignBoxViewModel`, summary sheet, and Driver Roster route args.
- Produces: fully backend-connected screen and `true` result refresh to Orders Queue.

- [ ] **Step 1: Write failing screen-flow tests**

Cover:

- first frame starts details request and renders `AssignBoxShimmer`;
- initial typed failure renders `ApiErrorWidget.fromTypedFailure` and retry;
- success renders API data/default selection;
- selection is single-choice without a request;
- View Box immediately opens `AssignBoxSummaryShimmer`, then content or inline typed error/retry;
- summary second open uses cache;
- Confirm disabled without selection;
- POST shows button-only loading and prevents duplicate tap;
- POST success Snackbar and one `pop(true)`;
- POST failure retains data/selection;
- 409 displays failure then shimmers/refetches details as a refresh;
- View All passes current `boxId` to `DispatcherDriversRouteArgs.assignment`.

```dart
await tester.tap(find.text('عرض البوكس'));
await tester.pump();
expect(find.byType(AssignBoxSummaryShimmer), findsOneWidget);

await tester.tap(find.text('تأكيد الإسناد'));
await tester.tap(find.text('تأكيد الإسناد'));
verify(() => assignUseCase(any())).called(1);
```

- [ ] **Step 2: Replace fake/local state with injected ViewModel**

```dart
class AssignBoxScreen extends StatefulWidget {
  const AssignBoxScreen({
    super.key,
    required this.args,
    this.viewModel,
    this.onAssignmentCompleted,
    this.onViewAllDrivers,
  });

  final AssignBoxRouteArgs args;
  final AssignBoxViewModel? viewModel;
  final ValueChanged<DriverAssignmentResultEntity>? onAssignmentCompleted;
  final ValueChanged<String>? onViewAllDrivers;
}
```

Resolve GetIt only when no ViewModel is supplied and close only internally owned instances. Remove `_order`, `_candidates`, local `_selectedDriverId`, and every runtime `AssignBoxFakeData` reference.

- [ ] **Step 3: Render the mandatory state hierarchy**

1. `details == null && isInitialLoading` → full `AssignBoxShimmer`.
2. `details == null && initialFailure != null` → `ApiErrorWidget.fromTypedFailure`.
3. `details != null` → loaded screen; refresh may overlay/replace content with shape-matched shimmer, never fake data.
4. Summary modal uses summary shimmer/error/content independently.
5. Submit loading affects Confirm button only.

- [ ] **Step 4: Wire core error presentation**

Use `ApiErrorWidget.fromTypedFailure` for initial failure, `InlineApiErrorWidget` for summary failure, and existing `CustomSnackbar.showError` with `failure.errorMessage` for refresh/submit failure. Do not parse Dio exceptions in the screen and do not add feature-specific error widgets.

- [ ] **Step 5: Wire View All and return behavior**

View All pushes `AppRoutes.dispatcherDrivers` with:

```dart
DispatcherDriversRouteArgs.assignment(
  boxId: state.details!.box.boxId,
  initialAreaName: state.details!.box.zoneName,
)
```

If roster completes assignment itself, it returns `DriverAssignmentResultEntity`/success to close this screen and refresh queue; it must not add a selected driver into the four-candidate list and wait for a second confirmation.

- [ ] **Step 6: Pass real IDs from Orders Queue and refresh on result**

Orders list invokes:

```dart
final assigned = await context.pushNamed<bool>(
  AppRoutes.assignBox,
  arguments: AssignBoxRouteArgs(boxId: order.boxId),
);
if (assigned == true && context.mounted) {
  await viewModel.doIntent(const RefreshDispatcherOrdersEvent());
}
```

Route generator rejects missing/invalid args through a safe typed error/fallback route; it never opens fake assignment data.

- [ ] **Step 7: Add only missing localization keys**

Add Arabic/English strings for summary title, customer/phone/address/barcode/notes/allergies/meals, empty allergies/meals, retry, assignment failure/success fallback, and unavailable details. Run the project's localization generation command; do not hand-edit generated localization Dart.

- [ ] **Step 8: Run screen and navigation tests**

```bash
flutter test test/features/dispatcher/dispatcher_assign_box/presentation/assign_box_backend_test.dart
flutter test test/assign_box_screen_test.dart
flutter test test/dispatcher_orders_screen_test.dart
```

Expected: PASS.

- [ ] **Step 9: Commit integrated flow**

```bash
git add lib/features/dispatcher/dispatcher_assign_box/presentation lib/features/dispatcher/dispatcher_orders/presentation lib/config/routing/routing_generator.dart lib/core/l10n/app_ar.arb lib/core/l10n/app_en.arb test/features/dispatcher/dispatcher_assign_box/presentation/assign_box_backend_test.dart test/assign_box_screen_test.dart test/dispatcher_orders_screen_test.dart
git commit -m "feat: connect assign box screen workflow"
```

### Task 8: Remove Fake Runtime Data, Regenerate, and Verify

**Files:**
- Delete when unused: `lib/features/dispatcher/dispatcher_assign_box/domain/fake_data/assign_box_fake_data.dart`
- Generated: Assign Box response `*.g.dart`, shared `api_services.g.dart`, localization outputs, and `di.config.dart`
- Tests from Tasks 1–7

**Interfaces:**
- Consumes: all earlier tasks.
- Produces: fake-free, generated, analyzed, and regression-tested Screen 04.04 integration.

- [ ] **Step 1: Search for stale fake/local assumptions**

```bash
rg -n "AssignBoxFakeData|sampleOrder|recommendedDriver\.id|candidate\.id|_selectedDriverId|_candidates|onViewBoxPressed: \(\) \{\}|context\.pop\(\)" lib/features/dispatcher/dispatcher_assign_box test/assign_box_screen_test.dart test/features/dispatcher/dispatcher_assign_box
```

Expected: no runtime fake or empty-action matches; migrate tests to explicit domain fixtures.

- [ ] **Step 2: Delete fake data after imports reach zero**

Remove `assign_box_fake_data.dart`. Do not delete it while any production or test import remains; replace tests with local fixture builders first.

- [ ] **Step 3: Regenerate generated code**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

Expected: Retrofit, JSON, Injectable, and localization generation succeeds. Inspect diffs so concurrent Driver Roster/Operations generated changes remain intact.

- [ ] **Step 4: Format only touched files**

Run `dart format` with the explicit Assign Box, minimum routing/orders, and test file list. Do not bulk-format unrelated dirty files.

- [ ] **Step 5: Run focused suites**

```bash
flutter test test/features/dispatcher/dispatcher_assign_box
flutter test test/assign_box_screen_test.dart
flutter test test/dispatcher_orders_screen_test.dart
flutter test test/core/network/api_services_test.dart
```

Expected: all PASS.

- [ ] **Step 6: Run analysis and connected regressions**

```bash
flutter analyze
flutter test test/features/dispatcher/dispatcher_drivers
flutter test test/dispatcher_drivers_screen_test.dart
flutter test test/features/dispatcher/dispatcher_map
```

Expected: no new errors/warnings and no regressions in shared assignment/route/API contracts. Document unrelated pre-existing failures without editing those features.

- [ ] **Step 7: Manual acceptance**

Using valid Arabic and English `DeliveryManager` sessions:

1. Opening from a queue row sends that row's GUID `boxId`.
2. Initial page always shows the structural shimmer until details finish.
3. Details map every box, suggestion, candidate, status, metric, and image field.
4. Best suggestion is initially selected; every returned candidate can be selected exclusively.
5. View Box always shows modal shimmer on its first load, then complete masked summary data.
6. Summary retry/error stays inside the modal; cached reopen makes no request.
7. Confirm makes one POST, shows button-only loading, and retains selection on failure.
8. Successful assignment shows server message, pops `true`, and refreshes Orders Queue.
9. Conflict refetches details and updates candidates/default selection safely.
10. No fake text/data appears in loading, failure, empty, or production navigation paths.

- [ ] **Step 8: Final diff audit and commit**

```bash
git status --short
git diff --check
git diff --stat
```

Confirm no unrelated Driver Roster/Operations dirty files were staged except shared generated output that was legitimately regenerated.

```bash
git add lib/core/network lib/core/di/di.config.dart lib/core/l10n lib/config/routing lib/features/dispatcher/dispatcher_assign_box lib/features/dispatcher/dispatcher_orders/presentation test/core/network/api_services_test.dart test/features/dispatcher/dispatcher_assign_box test/assign_box_screen_test.dart test/dispatcher_orders_screen_test.dart
git commit -m "test: verify assign box backend integration"
```

## Definition of Done

- `AssignBoxScreen` requires a real `boxId` and has no runtime `AssignBoxFakeData` fallback.
- Details, summary, and assignment use the documented backend contracts through Clean Architecture.
- The POST assignment pipeline exists exactly once and is shared with Driver Roster.
- Nullable DTOs map safely and never leak into UI.
- Initial page loading always uses `AssignBoxShimmer`; first summary load always uses `AssignBoxSummaryShimmer`.
- No full-page progress spinner replaces either required shimmer.
- Single selection, default recommendation, empty candidates, refresh, summary cache/retry, and duplicate-submit protection behave deterministically.
- `lib/core/errors` handles initial, modal, refresh, submit, authorization, timeout, offline, server, and conflict failures.
- Network avatars and null fallbacks render without asset/URL failures.
- Success pops `true` and Orders Queue refreshes automatically.
- Focused tests, shared API tests, analysis, and connected dispatcher regressions pass.
