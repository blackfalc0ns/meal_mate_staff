# Driver Reassignment Submission — Gemini Implementation Plan

> **For agentic workers:** Use `using-superpowers` and `executing-plans` if available. Execute the checkboxes task by task; read current code before editing. This is a plan-only handoff, not evidence of implementation.

**Goal:** Connect screen 08.02 to the real request-reassignment endpoint and show screen 08.03 only after a verified successful response, preserving the existing design and the driver's active trip.

**Architecture:** Feature-Based Clean Architecture inside `lib/features/driver/delivery_issues`. Existing UI → Event → ViewModel → UseCase → Repository → RemoteDataSource → shared ApiServices. DTO → Mapper → Entity on the return path. Reuse Core errors, ApiResult, safeApiCall, Dio, Retrofit, Injectable/GetIt and flutter_bloc.

**Tech Stack:** Existing Flutter/Dart packages only; existing localization and code generation; Flutter tests with fake repositories/mock transport.

**Spec:** The user approved submission-only integration. This document is the self-contained specification, incorporating the supplied updated Mobile Integration Guide for Screens 08.01/08.02. Older screen markdown is design context, not the authority for changed API fields.

## Scope and constraints

- Read any applicable `AGENTS.md`, all `rules/rules_backend.md`, all `rules/ui_rules.md`, and relevant files in `lib/core/errors` before implementation.
- Preserve the current design, illustration assets, colors, spacing, typography, dropdown, notes, buttons and navigation styling. Do not redesign or claim Figma measurements without inspecting an actual supplied node.
- User explicitly requests the existing Shimmer loading pattern. No new package, Dio instance, generic error system or state-management library.
- Do not implement report-issue submission, uploads, ticket list/details, support acceptance/rejection, driver notifications, SignalR, polling or cancellation APIs.
- Only adjust report-issue screen/navigation enough to carry the real delivery context into reassignment. Do not change its independent submit behavior in this task.
- Sending a request does not locally end, transfer, reset or mark the trip Reassigned. Support/operations handles processing outside this scope. Keep active-delivery state intact.
- Do not execute the unrelated profile-support-information plan or any other plan.
- Preserve existing modifications and untracked illustration assets. No reset, stash, commit, push or live POST during automated verification.
- Capture fresh status and diff before starting; the request screen, active tracking screen, widgets, ARBs, generated localization, tests and assets already contain user changes.
- API contract says deployment is pending. Implement and verify with test doubles regardless; do not claim live integration verified until the matching server release and an authorized test are available.

## Verified current evidence

- `DriverReassignmentRequestScreen._handleSubmit()` currently navigates directly to confirmation by default, without HTTP.
- `ReassignmentRequestEntity` contains only reason/notes; no target `boxId` or coordinates.
- `ReassignmentReason` currently has four options (`vehicleFailure`, `accident`, `emergency`, `healthIssue`), whereas the API has five canonical reasons. Correct this narrow mismatch while preserving dropdown design.
- Active tracking passes a `DeliveryIssueEntity` with display `boxCode` to report-issue, losing the real target ID. `DriverMapStopEntity.boxId` exists and must be traced to the actual route DTO mapping.
- Report-issue passes a `DeliveryIssueEntity` to the reassignment route, but the generator accepts only `ReassignmentRequestEntity`: the current argument is discarded.
- Confirmation currently takes a request draft, not a persisted result.
- `lib/core/widget/shimmer_widget.dart` exists but is a static skeleton. Reuse the established project pattern; do not promise animation that this widget does not implement.
- `Failure.code`, `Failure.exception.backendErrorCode`, and `Failure.exception.statusCode` are available. `safeApiCall` already maps errors through Core.

## Authoritative API contract

```http
POST /api/v1/driver/orders/{boxId}/request-reassignment
Authorization: Bearer <existing driver token interceptor>
Accept-Language: <existing language interceptor>
Content-Type: application/json
```

`boxId` is `TripStop.Id`/the backend route `BoxId` UUID, never `BoxCode`, order display number or `DailyOrderId`.

```json
{
  "reason": "VehicleBreakdown",
  "notes": "Optional explanation, at most 250 characters",
  "latitude": 29.3,
  "longitude": 47.93
}
```

| UI option | Wire value |
| --- | --- |
| Vehicle breakdown | `VehicleBreakdown` |
| Traffic accident | `TrafficAccident` |
| Medical or personal emergency | `MedicalOrPersonalEmergency` |
| Device failure | `DeviceFailure` |
| Other operational reason | `OtherOperationalReason` |

- Reason required; do not send Arabic/English labels, enum `.name`, or free text.
- Notes optional, trimmed and limited to 250 characters. Omit empty notes consistently with existing serialization.
- Coordinates optional: send both or neither. Latitude finite and within [-90,90]; longitude finite and within [-180,180].
- Do not reuse customer destination coordinates as the driver's current location. Reuse a verified existing current-location snapshot if available; otherwise omit both. No new permission flow or location dependency is needed for an optional field.
- Stop must be `PickedUp` and assigned to the driver's active delivery. Inspect the existing status mapper; do not guess which domain enum represents that wire value.

```json
{
  "requestId": "f4444444-4444-4444-4444-444444444444",
  "boxId": "c2222222-2222-2222-2222-222222222222",
  "boxCode": "#BX-1256",
  "status": "ReassignmentRequested",
  "message": "Backend message",
  "requestedAtUtc": "2026-10-07T08:45:00Z"
}
```

Success is HTTP 200 with an object, unlike report-issue's bare JSON string. `requestId` is the persisted ComplaintId. Never fabricate it.

| HTTP | ProblemDetails `code` | Action |
| --- | --- | --- |
| 400 | `driver.reassignment.reason_invalid` | Preserve draft, show Core inline failure, allow correction |
| 400 | `driver.reassignment.notes_too_long` | Preserve draft, show failure; local 250-character guard |
| 400 | `Orders.CoordinatesPairRequired` | Preserve draft, fix/drop optional location pair before resubmitting |
| 400 | `Orders.CoordinatesOutOfRange` | Preserve draft, fix/drop optional location pair |
| 403 | `driver.reassignment.stop_forbidden` | Preserve draft, block repeated submission for this context |
| 404 | `order.not_found` | Preserve draft, block submission for invalid/stale target |
| 409 | `driver.reassignment.request_already_active` | Show localized existing-request feedback, lock submission in this route; never open success |
| 409 | `driver.reassignment.stop_state_not_allowed` | Show feedback and lock submission for this context |
| 401/network/timeout/5xx | Core classification | Existing auth handling/inline failure; no success or automatic POST retry |

Timeout may mean the server saved the request: explain that outcome is uncertain with localized copy. A deliberate retry may receive 409; do not present that as a new successful submission. Active-request lookup is deferred and no new endpoint should be invented.

## File map

Existing files to inspect/modify only as necessary:

- `lib/core/network/api_services.dart`, `network_constants.dart`, generated `api_services.g.dart`.
- `lib/core/network/api_results.dart`, `failures.dart` and `lib/core/errors/*`: reuse; change only if a verified parsing gap requires a narrow regression-tested correction.
- `lib/core/di/di.dart` and the actual generated DI registration file: follow existing workflow.
- `lib/config/routing/routing_generator.dart`; retain existing AppRoutes names.
- `lib/features/driver/active_delivery/presentation/screens/driver_active_delivery_tracking_screen.dart`.
- `lib/features/driver/delivery_issues/domain/entities/{delivery_issue_entity,reassignment_reason,reassignment_request_entity}.dart`.
- `lib/features/driver/delivery_issues/presentation/screens/{driver_report_issue_screen,driver_reassignment_request_screen,driver_reassignment_submitted_screen}.dart`.
- `lib/features/driver/delivery_issues/presentation/widgets/{reassignment_reason_dropdown,reassignment_notes_field,reassignment_submit_button,reassignment_submitted_card}.dart`.
- `lib/core/l10n/app_ar.arb`, `app_en.arb`, configured generated localization.

New files (each class/widget in its own file), relative to `lib/features/driver/delivery_issues/`:

```text
domain/entities/reassignment_delivery_context_entity.dart
domain/entities/reassignment_result_entity.dart
domain/repo/driver_reassignment_repository.dart
domain/usecase/submit_driver_reassignment_usecase.dart
data/models/request/driver_reassignment_request_dto.dart
data/models/response/driver_reassignment_response_dto.dart
data/mapper/driver_reassignment_mapper.dart
data/data_source/driver_reassignment_remote_data_source.dart
data/data_source/driver_reassignment_remote_data_source_impl.dart
data/repo/driver_reassignment_repository_impl.dart
presentation/manager/driver_reassignment_event.dart
presentation/manager/driver_reassignment_state.dart
presentation/manager/driver_reassignment_view_model.dart
presentation/widgets/reassignment_submission_shimmer.dart
```

`lib/config/routing/arguments/driver_reassignment_route_arguments.dart` owns typed navigation arguments. Do not put routing dependencies in domain entities.

## Task 1 — Baseline and source tracing

- [ ] Run `git status --short` and inspect existing scoped diff. Record baseline `flutter analyze` and relevant delivery-issues tests, distinguishing existing failures.
- [ ] Read all mandatory rules and Core error/DI/network implementations. Inspect neighbouring active-delivery repository/ViewModel as the architecture reference.
- [ ] Trace `selectedStop.boxId` to backend DTO `BoxId`; trace status to backend `PickedUp`. Check all entrances with `rg -n 'driverReassignmentRequest|driverReportIssue' lib test`.
- [ ] Inspect localization generation (`l10n.yaml`, pubspec/tool scripts), build_runner setup, and current error-widget constructor signatures.
- [ ] Record the current-screen screenshots if a runnable preview/device exists. Use current UI as preservation evidence; no design cleanup.

Deliverable: exact target-ID/status source, code-generation commands, existing loading/error reuse choices and baseline.

## Task 2 — Typed context and real route propagation

Interfaces:

```dart
// ReassignmentDeliveryContextEntity: immutable domain context
// required String boxId; optional String? boxCode, tripId;
// required bool isPickedUp; derived from verified backend status mapping.
// Optional double? driverLatitude, driverLongitude: current-driver snapshot only.

// DriverReassignmentRouteArguments: immutable routing object
// required ReassignmentDeliveryContextEntity delivery;
// optional ReassignmentRequestEntity? initialRequest.
```

- [ ] Write route tests proving the same real UUID survives tracking → report-issue → reassignment. Include different boxCode and DailyOrderId values so accidental substitution fails.
- [ ] Add optional delivery context to `DeliveryIssueEntity` (and preserve in copyWith), or use a typed report-route wrapper if this better matches current route patterns; choose one, do not duplicate ownership. Update the generator and all production callers consistently.
- [ ] Keep `boxId` separate from form draft. Request draft retains reason/notes and optional coordinate pair; route context identifies the target.
- [ ] Enter from active tracking using the current selected stop, not stale `_trip` display information. Report-issue forwards exactly that context.
- [ ] Disable only the reassignment action when `PickedUp`/real context is absent. Do not disable report-issue for this condition.
- [ ] Missing/incorrect route args must render localized unavailable-context feedback and never silently fall back to fake data or another order. Generic ticket entry with no selected real box cannot submit reassignment.
- [ ] Confirmation route accepts `ReassignmentResultEntity` exclusively in production. Missing result cannot render a successful submission.
- [ ] Run route tests and existing affected screen tests; preserve constructor test seams where compatible, but a production callback must not bypass the HTTP success gate.

## Task 3 — Request/response, repository and DI

Stable interface shared by repository/usecase:

```dart
Future<ApiResult<ReassignmentResultEntity>> call({
  required String boxId,
  required ReassignmentRequestEntity request,
});
// Repository method name: submit (same named parameters).
// Remote method name: submit -> Future<DriverReassignmentResponseDto>.
```

- [ ] First write DTO/mapper/transport tests for all five reason values, optional fields, exact path/body and nullable response.
- [ ] Replace the four legacy reason choices with the five approved choices, update fake/test fixtures and localized labels only where this enum is consumed. Map reasons explicitly in data mapper.
- [ ] Request DTO uses required String reason and optional notes/latitude/longitude with existing JsonSerializable conventions. Domain types have no JSON/Retrofit annotations.
- [ ] Response DTO fields nullable: requestId, boxId, boxCode, status, message, requestedAtUtc. Mapper produces a domain-safe result. Empty/malformed requestId or missing/unexpected status is an invalid response, never fabricated success. If returned boxId is present and differs from submitted boxId, reject the result. Missing boxId may use the known submitted target; optional date/message/code remain optional.
- [ ] Define `ReassignmentResultEntity` with required requestId, boxId, status and optional boxCode, message, DateTime? requestedAtUtc. No fixed timestamps or ticket IDs.
- [ ] Add `EndPoints.driverRequestReassignment = '/api/v1/driver/orders/{boxId}/request-reassignment'` and the shared Retrofit POST:

```dart
@POST(EndPoints.driverRequestReassignment)
Future<DriverReassignmentResponseDto> requestDriverReassignment(
  @Path('boxId') String boxId,
  @Body() DriverReassignmentRequestDto request,
);
```

- [ ] Remote source delegates to ApiServices only. Repository maps request/response inside `safeApiCall`; UseCase forwards to repository. Validate domain input before transport, using existing typed-error patterns for invalid local requests.
- [ ] Register remote/repository/usecase with Injectable and route-owned ViewModel as a factory. No shared draft singleton.
- [ ] Generate DTO/Retrofit/DI through the verified existing command (normally `dart run build_runner build --delete-conflicting-outputs`). Never edit generated code manually; inspect generated diff for unrelated churn.
- [ ] Run data tests; assert no authorization/language override, no second Dio, no HTTP from widgets.

## Task 4 — Submission state and Core errors

State owns idle/submitting/succeeded/failed/blocked status, typed `Failure?`, and `ReassignmentResultEntity?`. Controllers and draft fields stay owned by form State. Event submits a validated snapshot with delivery context; reset/consume event clears one-time effects without resetting the form.

- [ ] Write ViewModel tests with a Completer-backed fake usecase: two taps while pending produce one call; after success no second call; close during pending emits nothing afterward.
- [ ] Implement existing project's `doIntent`/event pattern. Set busy synchronously before awaiting. Guard missing context, wrong known status, invalid reason/notes/location and terminal blocked/success state.
- [ ] Validate input in the ViewModel/usecase boundary too; keyboard/callback entry cannot bypass form validation. Required reason and target; notes ≤250; finite valid coordinates or omit both.
- [ ] Preserve `Failure`/`ApiException` from Core. Branch on stable code, not translated `detail`; confirm the ProblemDetails mapper extracts `code` and `detail`. Add a Core regression test if a narrow fix is needed.
- [ ] Apply the error-action table above. Unknown 409 remains an ordinary failure; do not treat every 409 as an active request.
- [ ] Keep form visible for action failures using existing `InlineApiErrorWidget` from `lib/core/errors/error_widgets`. Show localized actionable conflict/invalid-context explanation adjacent to it where needed; no competing generic error system.
- [ ] No automatic replay on timeout/connectivity recovery. Explicit retry repeats only this submission using preserved draft. Existing active-request conflict locks submission for the current route, with no disk persistence or polling claim.
- [ ] Run ViewModel tests for all error codes, late results, malformed response, no fabricated success and no trip mutations.

## Task 5 — Preserve UI, Shimmer and verified confirmation

- [ ] Keep controllers/focus nodes outside build; dispose them. Retain reason/notes on all failures and loading transitions.
- [ ] Use narrow BlocSelectors for busy/button and inline failure. Static header/illustration stays outside reactive builders. Use a success-only listener for navigation; consume the effect once and check mounted/lifetime.
- [ ] Submission loading uses `ReassignmentSubmissionShimmer` built from existing `ShimmerWidget`, confined to the existing action/button footprint using verified dimensions/tokens. Keep the form mounted and visible; temporarily disable fields/action to preserve the submitted snapshot. Do not replace the whole page or overlay an invented modal.
- [ ] Add localized semantics/live-region loading announcement. Honor reduced motion if an existing animated loader is reused. Shared skeleton is currently static: report that accurately; do not add a package or broadly rewrite it.
- [ ] Notes retain the existing design and display the 250-character constraint. Selection uses the five localized labels. No raw server enums in UI.
- [ ] After ApiSuccessResult with valid persisted result, navigate once to existing `driverReassignmentSubmitted`, passing that result. Never navigate immediately on tap or on 409.
- [ ] Keep confirmation layout/illustrations and return-home button. Replace any promise of acceptance/notification with localized copy: Arabic `تم إرسال طلب إعادة الإسناد للدعم للمراجعة.`; English `Your reassignment request has been submitted to support for review.` Do not blindly render backend message containing deferred promises.
- [ ] Return-home navigation preserves existing trip ownership/state. Do not invoke trip completion/reassignment, clear active-delivery storage or update stop status optimistically.
- [ ] Add copy to every configured locale, regenerate localization using project workflow. Inherited RTL/LTR, theme/styles/Spacing and existing assets only.
- [ ] Verify screen at narrow phone width, keyboard open and large text, with Arabic and English. Do not redesign other screens to achieve this.

## Task 6 — Focused verification and handoff

Create/update suites under `test/features/driver/delivery_issues/`:

| Test file | Required assertions |
| --- | --- |
| `data/driver_reassignment_mapper_test.dart` | Five canonical reasons; optional serialization; nullable/malformed response; valid UTC parsing; mismatched target rejected |
| `data/driver_reassignment_repository_impl_test.dart` | Exact UUID/path/body; safeApiCall preserves ProblemDetails codes; transport once; no trip side effects |
| `presentation/manager/driver_reassignment_view_model_test.dart` | Required input; 250/251 boundary; coordinate validation; duplicate guard; close; success/blocked guards; uncertainty/error handling |
| `presentation/screens/driver_reassignment_request_screen_test.dart` | Shimmer while pending; retained fields; no navigation before response; one navigation after success; 409 stays on form; retry; RTL/LTR and keyboard |
| `presentation/screens/driver_reassignment_route_test.dart` | Real context survives all entrances; missing args cannot submit/show success; wrong status disables reassignment only |
| `presentation/screens/driver_reassignment_submitted_screen_test.dart` | Result required; review wording; no acceptance/push promise; return-home works |

Concrete async test pattern (adapt constructor names only to existing test harness):

```dart
final completion = Completer<ApiResult<ReassignmentResultEntity>>();
// Fake usecase returns completion.future and counts calls.
// Dispatch submit twice before resolving: expect(callCount, 1).
// Assert state is busy and navigator has not opened confirmation.
// Resolve ApiErrorResult with code request_already_active:
// expect state blocked; expect original draft; expect no confirmation.
// Separate test resolves a valid ApiSuccessResult: one confirmation.
```

- [ ] Each task's tests are written/run failing first, then rerun passing after implementation. Do not claim a pre-existing test passed without running it.
- [ ] Format only changed Dart files. Run generated-code/localization steps before final analysis.
- [ ] Run `flutter test test/features/driver/delivery_issues`, then affected active-delivery/navigation tests identified in Task 1.
- [ ] Run `flutter analyze`, `git diff --check`, `git status --short`. Compare failures with recorded baseline. Inspect scoped diff and generated output; preserve unrelated edits.
- [ ] Capture Arabic/English idle, Shimmer, ordinary error with retained notes, active-request conflict and success-review screens when runtime tooling is available. Report screenshot/device limitations honestly.
- [ ] No live POST without explicit authorized testing. Report server deployment as unverified if not checked; do not substitute fake success into production wiring.

## Acceptance checklist

- [ ] Real BoxId UUID from the active stop reaches the request route and HTTP path.
- [ ] Five canonical reasons, optional trimmed notes ≤250, optional valid driver coordinate pair.
- [ ] Full existing architecture chain and DI connected; production uses real repository.
- [ ] Core typed errors/inline presentation reused; explicit handling of the two different 409 codes.
- [ ] Same design; existing Shimmer pattern; form stays mounted; no duplicate or late-lifetime submission effects.
- [ ] Confirmation only after validated persisted response; no fake ID, immediate navigation or deferred notification promise.
- [ ] Trip stays active locally; acceptance/rejection/notifications/tickets/report upload remain outside scope.
- [ ] Tests/analyzer/diff checks reported with baseline distinction; no unrelated changes/commits/live mutation.

## Required Gemini delivery report

Report files changed; real target-ID/status origin and full route chain; repository/usecase/ViewModel/DI wiring; explicit reason mapping; reused Core errors and loading components; error behavior including timeout and 409; tests and analysis output; screenshots or tooling limitations; server deployment/live verification status. State clearly that support processing, notification, active-request recovery after restart and report-issue submission are not implemented by this task.

## Ready-to-send Gemini prompt

> اقرأ `docs/superpowers/plans/2026-10-07-driver-reassignment-submit-gemini.md` كاملة، وأي `AGENTS.md`، و`rules/rules_backend.md` و`rules/ui_rules.md`. استخدم using-superpowers وexecuting-plans لو متاحين. نفذ ربط إرسال طلب إعادة الإسناد فقط بنفس التصميم الحالي، ومرر BoxId الحقيقي من الرحلة النشطة عبر شاشة البلاغ للطلب. التزم بطبقات المشروع وDI وApiResult وsafeApiCall واستخدم `lib/core/errors`، والأسباب الخمسة القياسية والملاحظات 250 حرف والإحداثيات الاختيارية الصحيحة. استخدم Shimmer المشروع للتحميل مع الحفاظ على الفورم والمدخلات ومنع التكرار، ولا تفتح التأكيد إلا بعد نجاح الباك بنتيجة محفوظة صحيحة. عالج 409 حسب الكود ولا تعتبره نجاح، ولا تنقل أو تنهي الرحلة محليًا. نص التأكيد إن الطلب اتبعت للدعم للمراجعة بدون وعد إشعار. القبول والرفض والإشعارات وبلاغاتي وربط إرسال البلاغ خارج النطاق. حافظ على كل التعديلات والأصول الحالية، اختبر وسلّم النتائج والحدود، ولا تعمل commit أو push أو POST حي أو تنفذ خطة البروفايل.
