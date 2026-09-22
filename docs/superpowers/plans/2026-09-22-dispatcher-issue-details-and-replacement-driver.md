# Dispatcher Issue Details and Replacement Driver Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the fake-data flows for dispatcher issue details (04.12) and replacement-driver assignment (04.13) with tested backend integration while preserving the existing UI identity and returning successful mutations to the support list without polling.

**Architecture:** Extend the existing `dispatcher_support` feature through the project's required UI → Event → ViewModel → UseCase → Repository → RemoteDataSource → `ApiServices` pipeline. Keep the list ViewModel independent; add one ViewModel/state/event family for issue details and another for replacement assignment so their loading, pagination, and mutation failures cannot overwrite each other. Routes carry only `issueId`; domain result objects are returned through `Navigator.pop` after resolve/reassign.

**Tech Stack:** Flutter, Dart, `flutter_bloc`, Dio, Retrofit, `json_serializable`, GetIt, existing `ApiResult`/`safeApiCall`, existing `lib/core/errors`, existing `ShimmerWidget`.

**Spec:** `D:/yahya/meal meat/dis_new/screen-04.12-problem-details (1).md` and `D:/yahya/meal meat/dis_new/screen-04.13-assign-replacement-driver (2).md`

## Global Constraints

- Follow `rules/rules_backend.md`; do not bypass any Clean Architecture layer.
- Preserve the current screen layout, theme, localization, naming conventions, and shared widgets; do not redesign either screen.
- Response DTO fields and nested response fields are nullable and defensive; request DTO fields follow backend required/optional rules.
- The UI consumes domain entities only and never imports DTOs.
- Use the injected `ApiServices`; do not create another Dio or Retrofit client and do not manually add auth/language headers.
- Use `safeApiCall`, `Failure`, `ApiErrorWidget`, `InlineApiErrorWidget`, and `EmptyStateWidget` from core.
- Use `lib/core/widget/shimmer_widget.dart` for both initial-loading skeletons; never use a centered spinner for initial loading.
- Keep loaded content visible during resolve/reassign failures; mutation failures are inline and must not replace the full screen.
- Preserve server ordering and `recommendationRank`; do not calculate distance/ETA or re-sort candidates on mobile.
- 04.13 sends optional `notes` as `null`/omitted because the approved UI has no notes field. Do not invent a notes input.
- Do not manually edit generated `*.g.dart`; regenerate with build_runner.
- Existing uncommitted dispatcher-support work belongs to the user; inspect the diff before every task and do not overwrite unrelated changes.

## Locked Backend Contract and Required Clarifications

Implementation may proceed against the documented keys. Before production sign-off, backend must confirm these details; do not guess them in UI code:

1. `GET /issues/{issueId}` returns `409 ISSUE_ALREADY_RESOLVED_OR_REASSIGNED` or a normal resolved payload when the issue changed before screen load; document which behavior is canonical.
2. All stable enum values for issue `status`, `category`, `priority`, driver `status`, and `unavailabilityReason` must be documented. Unknown values map to safe `unknown`, never throw.
3. Candidate `recommendationRank` is global across pages, not restarted at one per page.
4. Backend defines the GPS freshness threshold and excludes candidates whose locations are stale; mobile only displays returned candidates.
5. Backend confirms `currentDriver` nullability. DTO supports null; the domain/UI renders a safe unavailable-information state.
6. Backend confirms invalid pagination behavior and that an out-of-range page returns `200` with an empty `candidates` array.
7. Backend must make reassignment idempotent using `Idempotency-Key` or an equivalent request ID. Until supported, the app disables double submission but cannot protect transport-level retries.
8. SignalR event names/payloads remain outside this HTTP integration. The support list is refreshed from the returned navigation result; no polling is added.

---

### Task 1: Lock Domain Contracts and Route Arguments

**Files:**
- Modify: `lib/config/routing/arguments/dispatcher_support_route_arguments.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_detail_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_attachment_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_candidate_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_status.dart`
- Create: `lib/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_resolution_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_driver_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_trip_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_candidates_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_request_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_support/domain/entities/reassignment_result_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_support/domain/entities/resolve_issue_result_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_workflow_result_entity.dart`
- Test: `test/features/dispatcher/dispatcher_support/domain/dispatcher_issue_flow_entities_test.dart`

**Interfaces:**
- Produces: `DispatcherSupportIssueDetailsRouteArgs(issueId: String)` and `DispatcherReassignDriverRouteArgs(issueId: String)`.
- Produces: `DispatcherIssueDetailEntity` containing raw dates plus backend display text, typed status, metadata, nullable driver, evidence, trip, and nullable resolution.
- Produces: `ReassignDriverCandidatesEntity(summary, currentDriver, candidates, pagination)`, `ReassignmentResultEntity`, and `DispatcherIssueWorkflowResultEntity(changed, requiresRefresh)` for returning from 04.12 to 04.11.

- [ ] **Step 1: Write failing domain and route-argument tests**

Test typed status parsing/fallback, resolved-state derivation, optional current driver/resolution, immutable candidate-page append with ID de-duplication, and that both route argument classes require only `issueId`.

```dart
expect(DispatcherIssueStatusX.fromApi('Resolved'), DispatcherIssueStatus.resolved);
expect(DispatcherIssueStatusX.fromApi('future-value'), DispatcherIssueStatus.unknown);
expect(openIssue.isResolved, isFalse);
expect(resolvedIssue.isResolved, isTrue);
expect(const DispatcherReassignDriverRouteArgs(issueId: 'issue-1').issueId, 'issue-1');
```

- [ ] **Step 2: Run the focused test and confirm it fails**

Run: `flutter test test/features/dispatcher/dispatcher_support/domain/dispatcher_issue_flow_entities_test.dart`

Expected: FAIL because the new typed contracts do not exist yet.

- [ ] **Step 3: Implement focused domain types**

Use API-independent names and types. Keep localized server text as display fields, but preserve stable keys for logic. Required aggregate shape:

```dart
class DispatcherIssueDetailEntity {
  final String issueId;
  final String title;
  final String category;
  final String categoryLabel;
  final String categoryColorHex;
  final DateTime? createdAtUtc;
  final String reportedTimeText;
  final DispatcherIssueStatus status;
  final String statusLabel;
  final String boxCode;
  final String area;
  final int affectedBoxesCount;
  final String affectedBoxesText;
  final String priority;
  final String priorityText;
  final String priorityColorHex;
  final DispatcherIssueDriverEntity? driver;
  final String description;
  final List<DispatcherIssueAttachmentEntity> evidencePhotos;
  final DispatcherIssueTripEntity tripInfo;
  final DispatcherIssueResolutionEntity? resolution;
}
```

`DispatcherIssueAttachmentEntity` must expose `url`, `thumbnailUrl`, and `uploadedAtUtc`; remove asset-only assumptions from production types. `ReassignDriverCandidateEntity` must expose every candidate key: status text/color, area, same-area flag, distance/ETA raw and text values, vehicle info, last-location time, and rank.

- [ ] **Step 4: Run domain tests**

Run: `flutter test test/features/dispatcher/dispatcher_support/domain/dispatcher_issue_flow_entities_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit the domain boundary**

```bash
git add lib/config/routing/arguments/dispatcher_support_route_arguments.dart lib/features/dispatcher/dispatcher_support/domain/entities test/features/dispatcher/dispatcher_support/domain/dispatcher_issue_flow_entities_test.dart
git commit -m "feat: define dispatcher issue workflow domain contracts"
```

### Task 2: Add Defensive DTOs and Mappers

**Files:**
- Create: `lib/features/dispatcher/dispatcher_support/data/models/response/dispatcher_issue_details_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_support/data/models/response/reassign_driver_candidates_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_support/data/models/response/reassignment_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_support/data/models/response/resolve_issue_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_support/data/models/request/reassign_driver_request_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_support/data/models/request/resolve_issue_request_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_support/data/mapper/dispatcher_issue_details_mapper.dart`
- Create: `lib/features/dispatcher/dispatcher_support/data/mapper/dispatcher_reassignment_mapper.dart`
- Test: `test/features/dispatcher/dispatcher_support/data/dispatcher_issue_flow_dto_mapper_test.dart`

**Interfaces:**
- Consumes: Task 1 domain entities.
- Produces: nullable `@JsonSerializable()` response trees and `toEntity()` mappers with no force unwraps.
- Produces: `ReassignDriverRequestDto(replacementDriverId, notes)` and `ResolveIssueRequestDto(resolutionNotes)`.

- [ ] **Step 1: Write failing JSON and mapper tests**

Cover the full open issue JSON, resolved JSON, candidates JSON, empty candidate list, success responses, missing nested objects, null image/location fields, numeric coercion accepted by generated serializers, unknown enum values, and request JSON.

```dart
expect(dto.driver, isNotNull);
expect(dto.toEntity().evidencePhotos.first.thumbnailUrl, contains('thumb_01'));
expect(emptyCandidates.toEntity().candidates, isEmpty);
expect(ReassignDriverRequestDto(
  replacementDriverId: 'driver-2',
  notes: null,
).toJson(), {'replacementDriverId': 'driver-2'});
```

Use `@JsonSerializable(includeIfNull: false)` on request DTOs so absent optional notes are omitted.

- [ ] **Step 2: Run the focused test and confirm it fails**

Run: `flutter test test/features/dispatcher/dispatcher_support/data/dispatcher_issue_flow_dto_mapper_test.dart`

Expected: FAIL because DTOs/mappers are missing.

- [ ] **Step 3: Implement DTOs and mappings**

Every response field is nullable. Mappers use semantic defaults: empty collections for absent photos/candidates, `unknown` for unknown statuses, nullable dates for malformed timestamps, and `0` only for absent counts where zero is a valid display fallback. Do not parse backend color strings into Material colors in data/domain.

- [ ] **Step 4: Generate serializers**

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: generated `*.g.dart` files compile with no conflicting outputs.

- [ ] **Step 5: Run mapper tests and analyzer**

Run: `flutter test test/features/dispatcher/dispatcher_support/data/dispatcher_issue_flow_dto_mapper_test.dart`

Run: `flutter analyze lib/features/dispatcher/dispatcher_support/data lib/features/dispatcher/dispatcher_support/domain`

Expected: PASS and no analyzer errors.

- [ ] **Step 6: Commit DTOs and mappers**

```bash
git add lib/features/dispatcher/dispatcher_support/data/models lib/features/dispatcher/dispatcher_support/data/mapper test/features/dispatcher/dispatcher_support/data/dispatcher_issue_flow_dto_mapper_test.dart
git commit -m "feat: map dispatcher issue workflow responses"
```

### Task 3: Add API, Data Source, Repository, and Use Cases

**Files:**
- Modify: `lib/core/network/network_constants.dart`
- Modify: `lib/core/network/api_services.dart`
- Generated: `lib/core/network/api_services.g.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/data/data_source/dispatcher_support_remote_data_source.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/data/data_source/dispatcher_support_remote_data_source_impl.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/domain/repo/dispatcher_support_repository.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/data/repo/dispatcher_support_repository_impl.dart`
- Create: `lib/features/dispatcher/dispatcher_support/domain/usecase/get_dispatcher_issue_details_usecase.dart`
- Create: `lib/features/dispatcher/dispatcher_support/domain/usecase/resolve_dispatcher_issue_usecase.dart`
- Create: `lib/features/dispatcher/dispatcher_support/domain/usecase/get_replacement_driver_candidates_usecase.dart`
- Create: `lib/features/dispatcher/dispatcher_support/domain/usecase/reassign_dispatcher_issue_usecase.dart`
- Test: `test/core/network/api_services_test.dart`
- Test: `test/features/dispatcher/dispatcher_support/data/dispatcher_issue_flow_repository_test.dart`
- Test: `test/features/dispatcher/dispatcher_support/domain/dispatcher_issue_flow_usecases_test.dart`

**Interfaces:**
- Produces: `Future<ApiResult<DispatcherIssueDetailEntity>> getIssueDetails(String issueId)`.
- Produces: `Future<ApiResult<ResolveIssueResultEntity>> resolveIssue(String issueId, String resolutionNotes)`.
- Produces: `Future<ApiResult<ReassignDriverCandidatesEntity>> getReplacementCandidates(String issueId, {int pageNumber = 1, int pageSize = 20})`.
- Produces: `Future<ApiResult<ReassignmentResultEntity>> reassignIssue(String issueId, ReassignDriverRequestEntity request)`.

- [ ] **Step 1: Write failing endpoint and repository tests**

Assert exact methods, paths, path substitution, query names, and request bodies:

```dart
@GET('${EndPoints.dispatcherSupportIssues}/{issueId}')
Future<DispatcherIssueDetailsResponseDto> getDispatcherIssueDetails(
  @Path('issueId') String issueId,
);

@POST('${EndPoints.dispatcherSupportIssues}/{issueId}/resolve')
Future<ResolveIssueResponseDto> resolveDispatcherIssue(
  @Path('issueId') String issueId,
  @Body() ResolveIssueRequestDto request,
);

@GET('${EndPoints.dispatcherSupportIssues}/{issueId}/candidates')
Future<ReassignDriverCandidatesResponseDto> getReplacementDriverCandidates(
  @Path('issueId') String issueId,
  @Query('pageNumber') int pageNumber,
  @Query('pageSize') int pageSize,
);

@POST('${EndPoints.dispatcherSupportIssues}/{issueId}/reassign')
Future<ReassignmentResponseDto> reassignDispatcherIssue(
  @Path('issueId') String issueId,
  @Body() ReassignDriverRequestDto request,
);
```

Repository tests must assert `safeApiCall` maps Dio 409 errors through `Failure.exception.backendErrorCode` without converting them to generic strings.

- [ ] **Step 2: Run focused tests and confirm failure**

Run: `flutter test test/core/network/api_services_test.dart test/features/dispatcher/dispatcher_support/data/dispatcher_issue_flow_repository_test.dart test/features/dispatcher/dispatcher_support/domain/dispatcher_issue_flow_usecases_test.dart`

Expected: FAIL for missing contracts.

- [ ] **Step 3: Implement the four endpoint pipelines**

Keep request entity → DTO mapping in the repository/data layer. Trim resolution notes before creating `ResolveIssueRequestDto`. Pass optional reassignment notes as `null`; do not manufacture text. Validate `pageNumber >= 1`, `pageSize` between 1 and 50 in the use case so invalid local calls fail before network access.

- [ ] **Step 4: Regenerate Retrofit and run tests**

Run: `dart run build_runner build --delete-conflicting-outputs`

Run: `flutter test test/core/network/api_services_test.dart test/features/dispatcher/dispatcher_support/data/dispatcher_issue_flow_repository_test.dart test/features/dispatcher/dispatcher_support/domain/dispatcher_issue_flow_usecases_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit the data pipeline**

```bash
git add lib/core/network lib/features/dispatcher/dispatcher_support/data lib/features/dispatcher/dispatcher_support/domain/repo lib/features/dispatcher/dispatcher_support/domain/usecase test/core/network/api_services_test.dart test/features/dispatcher/dispatcher_support/data/dispatcher_issue_flow_repository_test.dart test/features/dispatcher/dispatcher_support/domain/dispatcher_issue_flow_usecases_test.dart
git commit -m "feat: integrate dispatcher issue workflow endpoints"
```

### Task 4: Implement Issue Details State and Resolution Flow

**Files:**
- Create: `lib/features/dispatcher/dispatcher_support/presentation/manager/issue_details/dispatcher_issue_details_event.dart`
- Create: `lib/features/dispatcher/dispatcher_support/presentation/manager/issue_details/dispatcher_issue_details_state.dart`
- Create: `lib/features/dispatcher/dispatcher_support/presentation/manager/issue_details/dispatcher_issue_details_view_model.dart`
- Test: `test/features/dispatcher/dispatcher_support/presentation/manager/dispatcher_issue_details_view_model_test.dart`

**Interfaces:**
- Consumes: `GetDispatcherIssueDetailsUseCase`, `ResolveDispatcherIssueUseCase`, and an immutable `issueId`.
- Produces: initial load/retry, resolve submission, inline mutation failure, and updated resolved content.

- [ ] **Step 1: Write failing ViewModel tests**

Cover:

- initial load success/failure;
- retry after initial failure;
- rejecting notes shorter than 3 or longer than 500 without calling the repository;
- resolve loading while keeping detail visible;
- resolve success updating status/resolution locally from the returned result;
- `409 ISSUE_ALREADY_RESOLVED` triggering one details refresh, then displaying the server's resolution card;
- non-conflict resolve failure preserved as `resolveFailure`;
- stale request generation ignored after retry.

```dart
expect(viewModel.state.detail, same(loadedDetail));
expect(viewModel.state.isResolving, isTrue);
expect(viewModel.state.resolveFailure, isNotNull);
```

- [ ] **Step 2: Run test and confirm failure**

Run: `flutter test test/features/dispatcher/dispatcher_support/presentation/manager/dispatcher_issue_details_view_model_test.dart`

Expected: FAIL because manager files are missing.

- [ ] **Step 3: Implement events and state**

Use events `LoadIssueDetails`, `RetryIssueDetails`, `SubmitIssueResolution(notes)`, and `ClearIssueResolutionFailure`. State must include `detail`, `isInitialLoading`, `isResolving`, `initialFailure`, `resolveFailure`, `resolutionNotesError`, `resolveSuccessId`, and a derived `canMutate` that is false when resolved/closed or submitting.

- [ ] **Step 4: Run tests**

Run: `flutter test test/features/dispatcher/dispatcher_support/presentation/manager/dispatcher_issue_details_view_model_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit details state management**

```bash
git add lib/features/dispatcher/dispatcher_support/presentation/manager/issue_details test/features/dispatcher/dispatcher_support/presentation/manager/dispatcher_issue_details_view_model_test.dart
git commit -m "feat: manage dispatcher issue details and resolution"
```

### Task 5: Implement Replacement Candidates and Atomic Reassignment State

**Files:**
- Create: `lib/features/dispatcher/dispatcher_support/presentation/manager/reassignment/dispatcher_reassignment_event.dart`
- Create: `lib/features/dispatcher/dispatcher_support/presentation/manager/reassignment/dispatcher_reassignment_state.dart`
- Create: `lib/features/dispatcher/dispatcher_support/presentation/manager/reassignment/dispatcher_reassignment_view_model.dart`
- Test: `test/features/dispatcher/dispatcher_support/presentation/manager/dispatcher_reassignment_view_model_test.dart`

**Interfaces:**
- Consumes: candidates/reassign use cases and immutable `issueId`.
- Produces: candidate page data, selected driver ID, append pagination, inline 409 state, and `ReassignmentResultEntity? successResult`.

- [ ] **Step 1: Write failing ViewModel tests**

Cover initial loading, first-ranked auto-selection, empty list, retry, refresh retaining prior content until success, next-page append with ID de-duplication, page failure without losing page one, selection, double-submit prevention, and both conflict codes.

Expected conflict behavior:

- `REPLACEMENT_DRIVER_NO_LONGER_AVAILABLE`: keep content, clear only the unavailable selected ID, show inline failure, refresh candidates, then auto-select the new first candidate.
- `ISSUE_ALREADY_RESOLVED_OR_REASSIGNED`: keep content, expose terminal conflict so the UI can return to details/list after acknowledgement.
- Other errors: keep selected candidate and show `InlineApiErrorWidget` with retry.

- [ ] **Step 2: Run test and confirm failure**

Run: `flutter test test/features/dispatcher/dispatcher_support/presentation/manager/dispatcher_reassignment_view_model_test.dart`

Expected: FAIL because manager files are missing.

- [ ] **Step 3: Implement events/state/ViewModel**

Use events `LoadReplacementCandidates`, `RetryReplacementCandidates`, `RefreshReplacementCandidates`, `LoadNextReplacementCandidatesPage`, `SelectReplacementDriver(driverId)`, `SubmitReplacementDriver`, and `ClearReassignmentFailure`.

State must separately model:

```dart
final ReassignDriverCandidatesEntity? data;
final String? selectedDriverId;
final bool isInitialLoading;
final bool isRefreshing;
final bool isNextPageLoading;
final bool isSubmitting;
final Failure? initialFailure;
final Failure? pageFailure;
final Failure? submitFailure;
final bool terminalIssueConflict;
final ReassignmentResultEntity? successResult;
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/features/dispatcher/dispatcher_support/presentation/manager/dispatcher_reassignment_view_model_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit reassignment state management**

```bash
git add lib/features/dispatcher/dispatcher_support/presentation/manager/reassignment test/features/dispatcher/dispatcher_support/presentation/manager/dispatcher_reassignment_view_model_test.dart
git commit -m "feat: manage replacement driver candidates and reassignment"
```

### Task 6: Wire Issue Details UI, Shimmer, Errors, Resolution, and Evidence

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_support/presentation/screens/dispatcher_issue_details_screen.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_issue_details_header_card.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_issue_details_driver_card.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_issue_details_attachments_card.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_issue_details_trip_card.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_issue_details_action_buttons.dart`
- Create: `lib/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_issue_details_shimmer.dart`
- Create: `lib/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_issue_resolution_card.dart`
- Create: `lib/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_resolve_issue_dialog.dart`
- Create: `lib/features/dispatcher/dispatcher_support/presentation/widgets/issue_details/dispatcher_evidence_photo_viewer.dart`
- Modify: `lib/core/l10n/app_ar.arb`
- Modify: `lib/core/l10n/app_en.arb`
- Generated: `lib/core/l10n/translations/*`
- Test: `test/features/dispatcher/dispatcher_support/presentation/dispatcher_issue_details_backend_test.dart`

**Interfaces:**
- Consumes: `issueId`, optional injected `DispatcherIssueDetailsViewModel` for tests, and returns `DispatcherIssueWorkflowResultEntity?` when the screen closes after a successful resolve/reassignment or a terminal conflict that requires list refresh.
- Produces: route to 04.13 using only `DispatcherReassignDriverRouteArgs(issueId)` and awaits `ReassignmentResultEntity?`.

- [ ] **Step 1: Write failing widget tests**

Assert full shimmer during initial load, `ApiErrorWidget` + retry on initial failure, mapped live content, cached thumbnails, full-screen `InteractiveViewer` using original URL, graceful empty evidence, resolve dialog validation, inline resolve error, disabled actions while submitting, resolved card replacing action buttons, and details updating immediately after reassignment result without GET/polling.

- [ ] **Step 2: Run test and confirm failure**

Run: `flutter test test/features/dispatcher/dispatcher_support/presentation/dispatcher_issue_details_backend_test.dart`

Expected: FAIL against fake-data screen.

- [ ] **Step 3: Build the loading/error/content shell**

Convert the screen to stateful only for ViewModel ownership and route-result awaiting. Resolve the ViewModel from GetIt unless injected, dispatch load once in `initState`, close only owned instances, and render:

```text
detail == null + loading  -> DispatcherIssueDetailsShimmer
detail == null + failure  -> ApiErrorWidget(onRetry)
detail != null            -> existing content widgets
```

Build shimmer blocks with `ShimmerWidget.rectangular`/`circular` matching header, driver, description, evidence, trip, and actions.

- [ ] **Step 4: Adapt content widgets without redesign**

Use `AppCachedNetworkImage` for driver/avatar thumbnails with placeholders. Hide attachment section for an empty list. Open `DispatcherEvidencePhotoViewer` with `InteractiveViewer` and the original `url`. Render server display text but use stable keys for state decisions. For direct phone calling, keep the widget callback injectable; if product requires launching `tel:`, add `url_launcher` in a separate reviewed dependency change rather than embedding platform code here.

- [ ] **Step 5: Implement resolution dialog and navigation results**

The dialog owns a `TextEditingController`, displays 3–500 validation, and embeds `InlineApiErrorWidget` for `resolveFailure`. On success update the details state to resolved, close the dialog, and show the resolution card. Await 04.13 result:

```dart
final result = await Navigator.pushNamed<ReassignmentResultEntity>(...);
if (result != null) viewModel.applyReassignmentResult(result);
```

Update the displayed driver and status from `result` only; do not refetch details.

- [ ] **Step 6: Generate localization and run tests**

Run the project's localization generation command (or `flutter gen-l10n` if that is the configured command).

Run: `flutter test test/features/dispatcher/dispatcher_support/presentation/dispatcher_issue_details_backend_test.dart`

Expected: PASS with no overflows in Arabic RTL and English LTR.

- [ ] **Step 7: Commit details UI integration**

```bash
git add lib/features/dispatcher/dispatcher_support/presentation/screens/dispatcher_issue_details_screen.dart lib/features/dispatcher/dispatcher_support/presentation/widgets/issue_details lib/core/l10n test/features/dispatcher/dispatcher_support/presentation/dispatcher_issue_details_backend_test.dart
git commit -m "feat: connect dispatcher issue details screen"
```

### Task 7: Wire Replacement Driver UI, Pagination, Shimmer, Empty, and Conflict States

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_support/presentation/screens/dispatcher_reassign_driver_screen.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_issue_summary_card.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_current_driver_section.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_card.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_card_avatar.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_card_stats.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_card_distance.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_bottom_button.dart`
- Create: `lib/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_shimmer.dart`
- Create: `lib/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_empty_state.dart`
- Create: `lib/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_pagination_footer.dart`
- Modify: `lib/core/l10n/app_ar.arb`
- Modify: `lib/core/l10n/app_en.arb`
- Generated: `lib/core/l10n/translations/*`
- Test: `test/features/dispatcher/dispatcher_support/presentation/dispatcher_reassign_driver_backend_test.dart`

**Interfaces:**
- Consumes: `issueId`, optional injected `DispatcherReassignmentViewModel`, and pops `ReassignmentResultEntity` on success.
- Produces: no local filtering/sorting; filter bottom sheet is removed from this screen because the server contract already filters and ranks candidates and exposes no filter query parameters.

- [ ] **Step 1: Write failing widget tests**

Cover shimmer, full-page API error/retry, summary/current driver content, first-candidate selection, radio selection, no-candidate `EmptyStateWidget` with refresh, next-page footer/loading/error/retry, disabled confirmation with no selection/submitting, inline 409 immediately above confirm button, content preservation on submit failure, success pop result, and no duplicate candidates after pagination.

- [ ] **Step 2: Run test and confirm failure**

Run: `flutter test test/features/dispatcher/dispatcher_support/presentation/dispatcher_reassign_driver_backend_test.dart`

Expected: FAIL against fake-data screen.

- [ ] **Step 3: Build the backend state shell and shimmer**

Resolve/inject the ViewModel exactly as Task 6, load candidates in `initState`, and use a `RefreshIndicator`. `ReassignDriverShimmer` must mimic the issue summary, current-driver card, header, three candidate cards, and fixed bottom action.

- [ ] **Step 4: Adapt candidate widgets to complete server data**

Display `recommendationRank`, `statusText`, `rating`, `activeOrdersCount`, area/same-area label, `distanceText`, `estimatedArrivalText`, `vehicleInfo`, and network avatar. Preserve server order. Do not show the existing unrelated driver-filter sheet because the endpoint has no corresponding filters.

- [ ] **Step 5: Implement pagination and failures**

Load next page through an explicit footer or near-end scroll trigger, never both. Keep existing candidates visible during append. Render page failure in `ReassignDriverPaginationFooter`. Render submit failure with `InlineApiErrorWidget` directly above `ReassignDriverBottomButton`; retry re-submits only when the selected candidate remains valid.

- [ ] **Step 6: Implement success/terminal conflict navigation**

Use `BlocListener` to pop exactly once with `ReassignmentResultEntity` on success. For `ISSUE_ALREADY_RESOLVED_OR_REASSIGNED`, show the localized backend message and pop a typed terminal-conflict result after acknowledgement; 04.12 then returns `DispatcherIssueWorkflowResultEntity(changed: false, requiresRefresh: true)` so 04.11 refreshes. Guard with state notice IDs to prevent duplicate dialogs/snackbars on rebuild.

- [ ] **Step 7: Generate localization and run tests**

Run localization generation.

Run: `flutter test test/features/dispatcher/dispatcher_support/presentation/dispatcher_reassign_driver_backend_test.dart`

Expected: PASS in Arabic RTL and English LTR with no overflow.

- [ ] **Step 8: Commit reassignment UI integration**

```bash
git add lib/features/dispatcher/dispatcher_support/presentation/screens/dispatcher_reassign_driver_screen.dart lib/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver lib/core/l10n test/features/dispatcher/dispatcher_support/presentation/dispatcher_reassign_driver_backend_test.dart
git commit -m "feat: connect replacement driver assignment screen"
```

### Task 8: Fix Routing, Dependency Injection, and Support-List Refresh Propagation

**Files:**
- Modify: `lib/config/routing/routing_generator.dart`
- Modify: `lib/config/routing/arguments/dispatcher_support_route_arguments.dart`
- Modify: `lib/core/di/di.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/presentation/widgets/support/dispatcher_support_issues_section.dart`
- Modify: `lib/features/dispatcher/dispatcher_support/presentation/screens/dispatcher_support_screen.dart`
- Test: `test/features/dispatcher/dispatcher_support/presentation/dispatcher_support_navigation_flow_test.dart`
- Test: `test/core/di/di_test.dart`

**Interfaces:**
- Consumes: route args and four new use cases/ViewModels.
- Produces: list → details(issueId) → replacement(issueId) → details(result) → list(`DispatcherIssueWorkflowResultEntity`) flow.

- [ ] **Step 1: Write failing route/DI/navigation tests**

Assert invalid/missing route arguments render the existing unknown-route/error behavior rather than fake content. Assert GetIt registrations resolve both new ViewModels and all use cases. Assert a successful resolve/reassign returned from details triggers exactly one `LoadDispatcherSupportEvent` or equivalent refresh on the existing list ViewModel.

- [ ] **Step 2: Run tests and confirm failure**

Run: `flutter test test/features/dispatcher/dispatcher_support/presentation/dispatcher_support_navigation_flow_test.dart test/core/di/di_test.dart`

Expected: FAIL because routes still expect entities and new dependencies are absent.

- [ ] **Step 3: Update routing**

`dispatcherSupportIssueDetails` accepts only `DispatcherSupportIssueDetailsRouteArgs`. `dispatcherReassignDriver` accepts only `DispatcherReassignDriverRouteArgs`. Remove fallback fake entities. Preserve route names for backward compatibility.

- [ ] **Step 4: Register dependencies**

Reuse the existing singleton support remote data source/repository. Register four new use cases as factories and both ViewModels as factories with their use cases. Do not create another repository instance.

- [ ] **Step 5: Propagate mutation result to list**

Make the list await details navigation. Details returns `DispatcherIssueWorkflowResultEntity`; when `changed || requiresRefresh`, refresh page one and counters using the existing list ViewModel while retaining current filters/search. Do not poll and do not depend on SignalR for the immediate local update.

- [ ] **Step 6: Run tests**

Run: `flutter test test/features/dispatcher/dispatcher_support/presentation/dispatcher_support_navigation_flow_test.dart test/core/di/di_test.dart`

Expected: PASS.

- [ ] **Step 7: Commit composition changes**

```bash
git add lib/config/routing lib/core/di/di.dart lib/features/dispatcher/dispatcher_support/presentation/screens/dispatcher_support_screen.dart lib/features/dispatcher/dispatcher_support/presentation/widgets/support/dispatcher_support_issues_section.dart test/features/dispatcher/dispatcher_support/presentation/dispatcher_support_navigation_flow_test.dart test/core/di/di_test.dart
git commit -m "feat: complete dispatcher issue workflow navigation"
```

### Task 9: Remove Runtime Fake Dependencies and Complete Regression Verification

**Files:**
- Modify or delete after zero-reference check: `lib/features/dispatcher/dispatcher_support/domain/fake_data/dispatcher_issue_detail_fake_data.dart`
- Modify or delete after zero-reference check: `lib/features/dispatcher/dispatcher_support/domain/fake_data/dispatcher_reassign_driver_fake_data.dart`
- Modify: `test/features/dispatcher/dispatcher_support/dispatcher_issue_details_screen_test.dart`
- Modify: `test/features/dispatcher/dispatcher_support/dispatcher_reassign_driver_screen_test.dart`
- Verify: all files modified by Tasks 1–8

**Interfaces:**
- Produces: no production import of either fake-data file and a fully passing dispatcher-support suite.

- [ ] **Step 1: Search for remaining fake-data imports**

Run: `rg -n "DispatcherIssueDetailFakeData|DispatcherReassignDriverFakeData" lib test`

Expected: no matches under `lib/features/dispatcher/dispatcher_support/presentation`; test fixtures may remain only if explicitly isolated to tests.

- [ ] **Step 2: Update or remove obsolete UI-only tests**

Replace tests that instantiate parameterless fake-backed screens with injected fake ViewModels/use cases and explicit route args. Keep layout assertions that still protect the approved design; remove assertions tied only to hard-coded fake values.

- [ ] **Step 3: Format and analyze**

Run: `dart format lib/features/dispatcher/dispatcher_support lib/config/routing lib/core/network lib/core/di test/features/dispatcher/dispatcher_support test/core/network/api_services_test.dart test/core/di/di_test.dart`

Run: `flutter analyze`

Expected: no errors or warnings introduced by this feature.

- [ ] **Step 4: Run focused and full regression suites**

Run: `flutter test test/features/dispatcher/dispatcher_support`

Run: `flutter test test/core/network/api_services_test.dart test/core/errors test/core/di/di_test.dart`

Run: `flutter test`

Expected: all tests PASS. If an unrelated pre-existing test fails, capture its exact name/output and prove it also fails without this feature change; do not weaken the test.

- [ ] **Step 5: Manually verify high-risk states**

Verify on a phone-sized Arabic RTL viewport and an English LTR viewport:

1. Details shimmer → content.
2. Details initial error → retry.
3. Empty and populated evidence.
4. Resolve validation, loading, success, and 409.
5. Candidates shimmer, empty, populated, pagination, and refresh.
6. Candidate becomes unavailable during submit; content remains and selection recovers.
7. Reassignment success updates 04.12 immediately.
8. Returning to 04.11 refreshes list/counters once.
9. Back navigation during in-flight calls causes no post-dispose emissions.

- [ ] **Step 6: Commit verification cleanup**

```bash
git add lib test
git commit -m "test: verify dispatcher issue and reassignment workflow"
```

## Definition of Done

- Both screens receive only `issueId` and no production code falls back to fake entities.
- All four endpoints run through the mandated Clean Architecture path and existing Dio/interceptors.
- Initial loading uses shape-matched shimmer; initial failures use `ApiErrorWidget`; mutation failures use `InlineApiErrorWidget` without dropping loaded data.
- Resolved issues display resolution data instead of action buttons.
- Candidate ordering, distance, ETA, eligibility, and pagination come from the server.
- First candidate is selected automatically; empty candidates show a refreshable empty state.
- POST buttons are guarded against double tap; 409 codes receive code-specific behavior.
- Reassignment returns a typed result to 04.12 and updates its driver/status without refetching.
- 04.12 returns a typed changed result so 04.11 refreshes list/counters once, without polling.
- DTO, mapper, repository, use-case, ViewModel, widget, navigation, DI, error, RTL/LTR, and regression tests pass.
