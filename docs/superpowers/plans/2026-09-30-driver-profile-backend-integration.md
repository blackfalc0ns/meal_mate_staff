# Driver Profile Backend Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Connect Screen 09.02 to `GET /api/v1/driver/profile`, render only backend-owned profile, statistics, vehicle, document, assignment, and support-ticket data, and keep loading, refresh, rebuild, and request costs bounded.

**Architecture:** Preserve the existing feature-based Clean Architecture and UI identity. Add nullable response DTOs, a mapper, repository, use case, and `DriverProfileViewModel`; make the screen stateful only for lifecycle/locale coordination and render immutable domain entities through small widgets. A single-flight request policy, locale/request generation guard, 15-minute freshness window, and content-preserving refresh prevent duplicate requests and stale responses.

**Tech Stack:** Flutter, Dart, Retrofit/Dio, json_serializable, flutter_bloc, GetIt/Injectable, existing `ApiResult`/`safeApiCall`, existing `lib/core/errors`, existing `ShimmerWidget`, flutter_test.

**Spec:** `D:/yahya/meal meat/driver/screen-09.02-driver-profile-vehicle.md` plus `C:/Users/orignal store/.codex/attachments/79ef3068-e3bc-4245-b252-9d28bd76f995/Pasted text.txt`

## Global Constraints

- Follow `rules/rules_backend.md`; the data flow must remain UI → Event/ViewModel → UseCase → Repository → RemoteDataSource → `ApiServices`.
- Use the existing injected `Dio`, token interceptor, and `LanguageInterceptor`; do not manually send a token, `Language`, `X-Language`, or `X-Bilingual`.
- The endpoint response is the profile object itself, with no `data` or `result` envelope and no `driverId` parameter.
- Response DTO fields and nested DTO fields are nullable; domain nullability preserves meaningful absence instead of inventing values.
- Never show `DriverProfileFakeData` after backend integration. Zero reviews/orders remains valid; nullable rating, acceptance rate, rank, plate governorate, assignment, and ticket remain absent.
- Do not implement document upload, vehicle replacement, or profile editing because their endpoints are not available in the current contract.
- Initial load uses the existing `ShimmerWidget`; pull-to-refresh and stale refresh preserve current content and never replace it with a full-screen shimmer.
- At most one equivalent profile request may run at once. Older-language responses must never overwrite the newest-language state.
- Do not manually edit generated `*.g.dart` or `lib/core/di/di.config.dart`; regenerate them with build_runner.

## File Structure

### Create

- `lib/features/driver/driver_profile/data/models/response/driver_profile_response_dto.dart` — defensive JSON DTO graph.
- `lib/features/driver/driver_profile/data/mapper/driver_profile_mapper.dart` — DTO-to-domain conversion and safe date/number mapping.
- `lib/features/driver/driver_profile/data/data_source/driver_profile_remote_data_source.dart` — remote contract.
- `lib/features/driver/driver_profile/data/data_source/driver_profile_remote_data_source_impl.dart` — `ApiServices` adapter.
- `lib/features/driver/driver_profile/data/repo/driver_profile_repository_impl.dart` — `safeApiCall` boundary.
- `lib/features/driver/driver_profile/domain/entities/driver_profile_vehicle_entity.dart` — nullable vehicle fields.
- `lib/features/driver/driver_profile/domain/entities/driver_profile_document_entity.dart` — document data and status code.
- `lib/features/driver/driver_profile/domain/entities/driver_profile_assignment_entity.dart` — nullable restaurant/branch assignment.
- `lib/features/driver/driver_profile/domain/entities/driver_profile_ticket_entity.dart` — latest ticket data.
- `lib/features/driver/driver_profile/domain/repo/driver_profile_repository.dart` — domain repository contract.
- `lib/features/driver/driver_profile/domain/usecase/get_driver_profile_usecase.dart` — one read operation.
- `lib/features/driver/driver_profile/presentation/manager/driver_profile_event.dart` — load/refresh/locale/visibility/image events.
- `lib/features/driver/driver_profile/presentation/manager/driver_profile_state.dart` — immutable content/loading/error state.
- `lib/features/driver/driver_profile/presentation/manager/driver_profile_view_model.dart` — single-flight and stale-response coordination.
- `lib/features/driver/driver_profile/presentation/widgets/driver_profile_shimmer.dart` — screen-shaped loading skeleton.
- `lib/features/driver/driver_profile/presentation/widgets/driver_profile_documents_card.dart` — backend document list and empty state.
- `lib/features/driver/driver_profile/presentation/widgets/driver_profile_assignment_card.dart` — optional assignment section.
- Focused tests under `test/features/driver/driver_profile/` matching each layer.

### Modify

- `lib/core/network/network_constants.dart` — add `driverProfile` endpoint constant.
- `lib/core/network/api_services.dart` — add the Retrofit method and DTO import.
- `lib/features/driver/driver_profile/domain/entities/driver_profile_entity.dart` — replace flat fake-only shape with the backend domain aggregate.
- `lib/features/driver/driver_profile/presentation/screens/driver_profile_screen.dart` — provide the ViewModel, coordinate locale/activation, and select state branches.
- `lib/features/driver/driver_profile/presentation/widgets/driver_profile_hero_card.dart` — nullable statistics, network avatar, and status text.
- `lib/features/driver/driver_profile/presentation/widgets/driver_profile_vehicle_card.dart` — nullable vehicle content and backend verification status.
- `lib/features/driver/driver_profile/presentation/widgets/driver_profile_ticket_card.dart` — real optional latest ticket.
- `lib/core/app_shell/screens/app_shell_screen.dart` — pass profile-tab active state without rebuilding unrelated pages.
- ARB/localization sources and generated localization files — add generic profile empty/error/unavailable/document labels using the project generation workflow.
- `test/driver_profile_screen_test.dart` — migrate current widget expectations to injected ViewModel behavior.

---

### Task 1: Lock the backend contract in defensive DTO tests

**Files:**
- Create: `lib/features/driver/driver_profile/data/models/response/driver_profile_response_dto.dart`
- Test: `test/features/driver/driver_profile/data/models/driver_profile_response_dto_test.dart`

**Interfaces:**
- Produces: `DriverProfileResponseDto.fromJson(Map<String, dynamic>)` and nested `DriverProfileVehicleResponseDto`, `DriverProfileDocumentResponseDto`, `DriverProfileAssignmentResponseDto`, `DriverProfileTicketResponseDto`.

- [ ] **Step 1: Write parsing tests before the DTOs exist**

```dart
test('parses full direct response and accepts integer numeric doubles', () {
  final dto = DriverProfileResponseDto.fromJson({
    'driverProfileId': 'profile-1',
    'fullName': 'أحمد إبراهيم',
    'driverDescription': 'كابتن توصيل معتمد',
    'driverCode': 'profile1',
    'isOnline': true,
    'status': 'Online',
    'statusText': 'متصل',
    'averageRating': 5,
    'reviewsCount': 0,
    'totalOrders': 0,
    'acceptanceRatePercent': null,
    'joinedAtUtc': '2026-01-10T08:30:00Z',
    'vehicle': {'vehicleYear': 2024, 'vehicleModel': null},
    'documents': <Map<String, dynamic>>[],
    'assignment': null,
    'latestSupportTicket': null,
  });
  expect(dto.averageRating, 5);
  expect(dto.reviewsCount, 0);
  expect(dto.documents, isEmpty);
  expect(dto.assignment, isNull);
});

test('does not throw when optional and nested fields are absent', () {
  expect(() => DriverProfileResponseDto.fromJson(const {}), returnsNormally);
});
```

- [ ] **Step 2: Run the focused test and confirm it fails because the DTO is absent**

Run: `flutter test test/features/driver/driver_profile/data/models/driver_profile_response_dto_test.dart`

Expected: FAIL with missing import/type errors.

- [ ] **Step 3: Add nullable json_serializable DTOs**

```dart
@JsonSerializable(createToJson: false)
class DriverProfileResponseDto {
  const DriverProfileResponseDto({
    this.driverProfileId,
    this.fullName,
    this.driverDescription,
    this.driverRank,
    this.driverCode,
    this.phoneNumber,
    this.profileImageStorageKey,
    this.profileImageUrl,
    this.isOnline,
    this.status,
    this.statusText,
    this.averageRating,
    this.reviewsCount,
    this.totalOrders,
    this.acceptanceRatePercent,
    this.joinedAtUtc,
    this.vehicle,
    this.documents,
    this.assignment,
    this.latestSupportTicket,
  });

  factory DriverProfileResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverProfileResponseDtoFromJson(json);

  final String? driverProfileId;
  final String? fullName;
  final String? driverDescription;
  final String? driverRank;
  final String? driverCode;
  final String? phoneNumber;
  final String? profileImageStorageKey;
  final String? profileImageUrl;
  final bool? isOnline;
  final String? status;
  final String? statusText;
  final num? averageRating;
  final int? reviewsCount;
  final int? totalOrders;
  final num? acceptanceRatePercent;
  final String? joinedAtUtc;
  final DriverProfileVehicleResponseDto? vehicle;
  final List<DriverProfileDocumentResponseDto>? documents;
  final DriverProfileAssignmentResponseDto? assignment;
  final DriverProfileTicketResponseDto? latestSupportTicket;
}
```

Define every nested contract field exactly as the supplied specification, using nullable DTO fields and `createToJson: false`.

- [ ] **Step 4: Generate serializers and rerun the tests**

Run: `dart run build_runner build --delete-conflicting-outputs`

Run: `flutter test test/features/driver/driver_profile/data/models/driver_profile_response_dto_test.dart`

Expected: PASS, including empty/partial JSON.

- [ ] **Step 5: Commit the DTO contract**

```bash
git add lib/features/driver/driver_profile/data/models test/features/driver/driver_profile/data/models
git commit -m "feat(driver-profile): model profile API response"
```

### Task 2: Build domain entities and explicit mapping semantics

**Files:**
- Modify: `lib/features/driver/driver_profile/domain/entities/driver_profile_entity.dart`
- Create: `lib/features/driver/driver_profile/domain/entities/driver_profile_vehicle_entity.dart`
- Create: `lib/features/driver/driver_profile/domain/entities/driver_profile_document_entity.dart`
- Create: `lib/features/driver/driver_profile/domain/entities/driver_profile_assignment_entity.dart`
- Create: `lib/features/driver/driver_profile/domain/entities/driver_profile_ticket_entity.dart`
- Create: `lib/features/driver/driver_profile/data/mapper/driver_profile_mapper.dart`
- Test: `test/features/driver/driver_profile/data/mapper/driver_profile_mapper_test.dart`

**Interfaces:**
- Consumes: `DriverProfileResponseDto` graph from Task 1.
- Produces: `DriverProfileResponseDtoMapper.toEntity()` returning `DriverProfileEntity`.

- [ ] **Step 1: Write mapper tests for meaningful nulls, zeros, dates, and statuses**

```dart
test('preserves meaningful absence and valid zero counts', () {
  final entity = const DriverProfileResponseDto(
    fullName: 'Ahmed',
    reviewsCount: 0,
    totalOrders: 0,
    averageRating: null,
    acceptanceRatePercent: null,
    documents: [],
  ).toEntity();
  expect(entity.reviewsCount, 0);
  expect(entity.totalOrders, 0);
  expect(entity.averageRating, isNull);
  expect(entity.acceptanceRatePercent, isNull);
  expect(entity.documents, isEmpty);
});

test('parses UTC instants but preserves expiryDate as a date string', () {
  final entity = DriverProfileResponseDto.fromJson({
    'joinedAtUtc': '2026-01-10T08:30:00Z',
    'documents': [{'expiryDate': '2027-11-15'}],
  }).toEntity();
  expect(entity.joinedAtUtc?.isUtc, isTrue);
  expect(entity.documents.single.expiryDate, '2027-11-15');
});
```

- [ ] **Step 2: Run the mapper test and confirm the old flat entity cannot satisfy it**

Run: `flutter test test/features/driver/driver_profile/data/mapper/driver_profile_mapper_test.dart`

Expected: FAIL on missing nested entities and mapper.

- [ ] **Step 3: Implement immutable domain entities with equality**

`DriverProfileEntity` must expose:

```dart
final String driverProfileId;
final String fullName;
final String driverDescription;
final String? driverRank;
final String driverCode;
final String? phoneNumber;
final String? profileImageUrl;
final bool isOnline;
final String status;
final String statusText;
final double? averageRating;
final int reviewsCount;
final int totalOrders;
final double? acceptanceRatePercent;
final DateTime? joinedAtUtc;
final DriverProfileVehicleEntity? vehicle;
final List<DriverProfileDocumentEntity> documents;
final DriverProfileAssignmentEntity? assignment;
final DriverProfileTicketEntity? latestSupportTicket;
```

Use empty strings only for required display identifiers/text when absent; retain `null` where the specification distinguishes “unavailable.” Wrap mapped document lists with `List.unmodifiable` so state equality and selectors are stable.

- [ ] **Step 4: Implement mapper conversion without assertions**

```dart
extension DriverProfileResponseDtoMapper on DriverProfileResponseDto {
  DriverProfileEntity toEntity() => DriverProfileEntity(
    driverProfileId: driverProfileId ?? '',
    fullName: fullName ?? '',
    driverDescription: driverDescription ?? '',
    driverRank: driverRank,
    driverCode: driverCode ?? '',
    phoneNumber: phoneNumber,
    profileImageUrl: profileImageUrl,
    isOnline: isOnline ?? false,
    status: status ?? '',
    statusText: statusText ?? '',
    averageRating: averageRating?.toDouble(),
    reviewsCount: reviewsCount ?? 0,
    totalOrders: totalOrders ?? 0,
    acceptanceRatePercent: acceptanceRatePercent?.toDouble(),
    joinedAtUtc: DateTime.tryParse(joinedAtUtc ?? '')?.toUtc(),
    vehicle: vehicle?.toEntity(),
    documents: List.unmodifiable(
      (documents ?? const []).map((item) => item.toEntity()),
    ),
    assignment: assignment?.toEntity(),
    latestSupportTicket: latestSupportTicket?.toEntity(),
  );
}
```

- [ ] **Step 5: Run mapper tests**

Run: `flutter test test/features/driver/driver_profile/data/mapper/driver_profile_mapper_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit domain and mapper**

```bash
git add lib/features/driver/driver_profile/domain/entities lib/features/driver/driver_profile/data/mapper test/features/driver/driver_profile/data/mapper
git commit -m "feat(driver-profile): map profile response to domain"
```

### Task 3: Add the endpoint through every Clean Architecture layer

**Files:**
- Modify: `lib/core/network/network_constants.dart`
- Modify: `lib/core/network/api_services.dart`
- Create: `lib/features/driver/driver_profile/data/data_source/driver_profile_remote_data_source.dart`
- Create: `lib/features/driver/driver_profile/data/data_source/driver_profile_remote_data_source_impl.dart`
- Create: `lib/features/driver/driver_profile/domain/repo/driver_profile_repository.dart`
- Create: `lib/features/driver/driver_profile/data/repo/driver_profile_repository_impl.dart`
- Create: `lib/features/driver/driver_profile/domain/usecase/get_driver_profile_usecase.dart`
- Test: `test/features/driver/driver_profile/data/repo/driver_profile_repository_impl_test.dart`

**Interfaces:**
- Produces: `Future<ApiResult<DriverProfileEntity>> DriverProfileRepository.getProfile()` and `GetDriverProfileUseCase.call()`.

- [ ] **Step 1: Write repository success and failure tests**

```dart
test('maps the direct DTO response to a domain entity', () async {
  when(() => remote.getProfile()).thenAnswer(
    (_) async => const DriverProfileResponseDto(fullName: 'Ahmed'),
  );
  final result = await repository.getProfile();
  expect(result, isA<ApiSuccessResult<DriverProfileEntity>>());
});

test('returns typed failure when the remote source throws DioException', () async {
  when(() => remote.getProfile()).thenThrow(
    DioException(requestOptions: RequestOptions(path: '/api/v1/driver/profile')),
  );
  final result = await repository.getProfile();
  expect(result, isA<ApiErrorResult<DriverProfileEntity>>());
});
```

- [ ] **Step 2: Run the repository test and verify it fails**

Run: `flutter test test/features/driver/driver_profile/data/repo/driver_profile_repository_impl_test.dart`

Expected: FAIL on missing repository/data-source types.

- [ ] **Step 3: Add endpoint and layer contracts**

```dart
// network_constants.dart
static const String driverProfile = '/api/v1/driver/profile';

// api_services.dart
@GET(EndPoints.driverProfile)
Future<DriverProfileResponseDto> getDriverProfile();

abstract interface class DriverProfileRemoteDataSource {
  Future<DriverProfileResponseDto> getProfile();
}

abstract interface class DriverProfileRepository {
  Future<ApiResult<DriverProfileEntity>> getProfile();
}
```

The Retrofit method has no query/body/header arguments: token and `Accept-Language` already come from interceptors.

- [ ] **Step 4: Implement adapters and use `safeApiCall`**

```dart
@LazySingleton(as: DriverProfileRemoteDataSource)
class DriverProfileRemoteDataSourceImpl
    implements DriverProfileRemoteDataSource {
  const DriverProfileRemoteDataSourceImpl(this._apiServices);
  final ApiServices _apiServices;

  @override
  Future<DriverProfileResponseDto> getProfile() =>
      _apiServices.getDriverProfile();
}

@LazySingleton(as: DriverProfileRepository)
class DriverProfileRepositoryImpl implements DriverProfileRepository {
  const DriverProfileRepositoryImpl(this._remote);
  final DriverProfileRemoteDataSource _remote;

  @override
  Future<ApiResult<DriverProfileEntity>> getProfile() =>
      safeApiCall(() async => (await _remote.getProfile()).toEntity());
}

@injectable
class GetDriverProfileUseCase {
  const GetDriverProfileUseCase(this._repository);
  final DriverProfileRepository _repository;
  Future<ApiResult<DriverProfileEntity>> call() => _repository.getProfile();
}
```

- [ ] **Step 5: Generate Retrofit and DI code, then run tests**

Run: `dart run build_runner build --delete-conflicting-outputs`

Run: `flutter test test/features/driver/driver_profile/data/repo/driver_profile_repository_impl_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit the API pipeline**

```bash
git add lib/core/network lib/core/di/di.config.dart lib/features/driver/driver_profile/data lib/features/driver/driver_profile/domain/repo lib/features/driver/driver_profile/domain/usecase test/features/driver/driver_profile/data/repo
git commit -m "feat(driver-profile): connect profile endpoint"
```

### Task 4: Implement request de-duplication and stale-response protection

**Files:**
- Create: `lib/features/driver/driver_profile/presentation/manager/driver_profile_event.dart`
- Create: `lib/features/driver/driver_profile/presentation/manager/driver_profile_state.dart`
- Create: `lib/features/driver/driver_profile/presentation/manager/driver_profile_view_model.dart`
- Test: `test/features/driver/driver_profile/presentation/manager/driver_profile_view_model_test.dart`

**Interfaces:**
- Consumes: `GetDriverProfileUseCase.call()`.
- Produces: `Future<void> doIntent(DriverProfileEvent event)` and `DriverProfileState`.

- [ ] **Step 1: Write concurrency, refresh, and locale race tests**

```dart
test('coalesces two non-forced loads while one request is active', () async {
  final pending = Completer<ApiResult<DriverProfileEntity>>();
  when(() => useCase()).thenAnswer((_) => pending.future);
  final first = viewModel.doIntent(const DriverProfileStarted(locale: 'ar'));
  final second = viewModel.doIntent(const DriverProfileStarted(locale: 'ar'));
  verify(() => useCase()).called(1);
  pending.complete(ApiSuccessResult(data: profile));
  await Future.wait([first, second]);
});

test('keeps content visible during pull refresh', () async {
  await loadSuccessfully(viewModel, profile);
  final pending = Completer<ApiResult<DriverProfileEntity>>();
  when(() => useCase()).thenAnswer((_) => pending.future);
  unawaited(viewModel.doIntent(const DriverProfileRefreshed(locale: 'ar')));
  expect(viewModel.state.profile, same(profile));
  expect(viewModel.state.isRefreshing, isTrue);
});

test('ignores an older response after locale changes', () async {
  final ar = Completer<ApiResult<DriverProfileEntity>>();
  final en = Completer<ApiResult<DriverProfileEntity>>();
  when(() => useCase()).thenAnswer((_) => ar.future).thenAnswer((_) => en.future);
  unawaited(viewModel.doIntent(const DriverProfileStarted(locale: 'ar')));
  unawaited(viewModel.doIntent(const DriverProfileLocaleChanged(locale: 'en')));
  en.complete(ApiSuccessResult(data: englishProfile));
  ar.complete(ApiSuccessResult(data: arabicProfile));
  await Future<void>.delayed(Duration.zero);
  expect(viewModel.state.profile, englishProfile);
});
```

- [ ] **Step 2: Run the ViewModel test and verify failure**

Run: `flutter test test/features/driver/driver_profile/presentation/manager/driver_profile_view_model_test.dart`

Expected: FAIL because ViewModel/state/events are absent.

- [ ] **Step 3: Define state with separate initial and refresh flags**

```dart
class DriverProfileState {
  const DriverProfileState({
    this.profile,
    this.failure,
    this.inlineFailure,
    this.isInitialLoading = true,
    this.isRefreshing = false,
    this.localeCode,
    this.lastSuccessfulLoadAt,
  });
  final DriverProfileEntity? profile;
  final Failure? failure;
  final Failure? inlineFailure;
  final bool isInitialLoading;
  final bool isRefreshing;
  final String? localeCode;
  final DateTime? lastSuccessfulLoadAt;
  bool get hasContent => profile != null;
}
```

Implement value equality so `BlocBuilder.buildWhen` and `BlocSelector` can avoid equivalent rebuilds.

- [ ] **Step 4: Implement single-flight loading with generation tokens**

```dart
Future<void>? _inFlight;
int _generation = 0;

Future<void> _load({required String locale, required bool force}) {
  if (!force && _inFlight != null && state.localeCode == locale) {
    return _inFlight!;
  }
  final generation = ++_generation;
  final future = _performLoad(locale: locale, generation: generation);
  _inFlight = future;
  return future.whenComplete(() {
    if (identical(_inFlight, future)) _inFlight = null;
  });
}
```

`DriverProfileLocaleChanged` always advances `_generation`; only a response whose generation and locale still match may emit success/error. `DriverProfileActivated` refreshes only when `lastSuccessfulLoadAt` is absent or older than 15 minutes. Explicit pull-to-refresh is forced but still serialized; repeated gestures while refreshing return the active future.

- [ ] **Step 5: Map typed failures without local try/catch**

On initial failure store `failure`; on refresh failure preserve `profile` and store `inlineFailure`. The UI will use `ApiErrorWidget.fromTypedFailure`, satisfying 401/403/404/network/5xx rendering through `lib/core/errors`.

- [ ] **Step 6: Run the ViewModel tests**

Run: `flutter test test/features/driver/driver_profile/presentation/manager/driver_profile_view_model_test.dart`

Expected: PASS with one call for duplicate loads and newest locale winning.

- [ ] **Step 7: Commit state management**

```bash
git add lib/features/driver/driver_profile/presentation/manager test/features/driver/driver_profile/presentation/manager
git commit -m "feat(driver-profile): add efficient profile state management"
```

### Task 5: Add screen-shaped shimmer and reusable document/assignment widgets

**Files:**
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_profile_shimmer.dart`
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_profile_documents_card.dart`
- Create: `lib/features/driver/driver_profile/presentation/widgets/driver_profile_assignment_card.dart`
- Test: `test/features/driver/driver_profile/presentation/widgets/driver_profile_state_widgets_test.dart`

**Interfaces:**
- Consumes: `DriverProfileDocumentEntity` and `DriverProfileAssignmentEntity`.
- Produces: const-friendly presentational widgets with no network calls.

- [ ] **Step 1: Write widget tests for skeleton structure and document states**

```dart
testWidgets('initial skeleton uses ShimmerWidget and no spinner', (tester) async {
  await tester.pumpWidget(testApp(const DriverProfileShimmer()));
  expect(find.byType(ShimmerWidget), findsWidgets);
  expect(find.byType(CircularProgressIndicator), findsNothing);
});

testWidgets('empty documents render an explicit empty state', (tester) async {
  await tester.pumpWidget(testApp(
    const DriverProfileDocumentsCard(documents: []),
  ));
  expect(find.byKey(const Key('driver_profile_documents_empty')), findsOneWidget);
});

testWidgets('document color is selected by status code, not statusText', (tester) async {
  await tester.pumpWidget(testApp(DriverProfileDocumentsCard(documents: [
    expiredDocument.copyWith(status: 'Expired', statusText: 'Custom text'),
  ])));
  expect(find.byKey(const Key('driver_document_status_expired')), findsOneWidget);
});
```

- [ ] **Step 2: Run the widget test and verify missing widgets**

Run: `flutter test test/features/driver/driver_profile/presentation/widgets/driver_profile_state_widgets_test.dart`

Expected: FAIL on missing widget imports.

- [ ] **Step 3: Implement a static, low-cost shimmer**

Build the skeleton from the existing `ShimmerWidget` using `const` boxes that match hero, statistics, vehicle, documents, assignment, and ticket geometry. Do not introduce a package animation or timer; this avoids continuous repaint cost while preserving the project’s established loading style.

- [ ] **Step 4: Implement document status presentation**

Use a pure status resolver:

```dart
DriverDocumentTone documentTone(String status) => switch (status) {
  'Expired' => DriverDocumentTone.danger,
  'ExpiringSoon' => DriverDocumentTone.warning,
  'Approved' => DriverDocumentTone.success,
  'Submitted' || 'UnderReview' => DriverDocumentTone.pending,
  'Rejected' || 'NeedsChanges' || 'ResubmissionRequired' =>
    DriverDocumentTone.actionRequired,
  _ => DriverDocumentTone.neutral,
};
```

Render `documentTitle`, `statusText`, optional date-only `expiryDate`, and optional backend-calculated `daysUntilExpiry`. Do not add upload buttons.

- [ ] **Step 5: Implement assignment visibility**

Hide `DriverProfileAssignmentCard` when both restaurant and branch names are blank/null. If only one exists, render only that value without fabricated separators.

- [ ] **Step 6: Run widget tests**

Run: `flutter test test/features/driver/driver_profile/presentation/widgets/driver_profile_state_widgets_test.dart`

Expected: PASS.

- [ ] **Step 7: Commit loading and new sections**

```bash
git add lib/features/driver/driver_profile/presentation/widgets test/features/driver/driver_profile/presentation/widgets
git commit -m "feat(driver-profile): add profile loading and document views"
```

### Task 6: Bind existing cards to backend entities without broad rebuilds

**Files:**
- Modify: `lib/features/driver/driver_profile/presentation/widgets/driver_profile_hero_card.dart`
- Modify: `lib/features/driver/driver_profile/presentation/widgets/driver_profile_vehicle_card.dart`
- Modify: `lib/features/driver/driver_profile/presentation/widgets/driver_profile_ticket_card.dart`
- Modify: localization ARB/source files used by the project
- Test: `test/features/driver/driver_profile/presentation/widgets/driver_profile_content_widgets_test.dart`

**Interfaces:**
- Consumes: domain entities only; no DTOs or ViewModel access.
- Produces: pure widgets whose rebuild boundary is their input entity.

- [ ] **Step 1: Write tests for null-versus-zero and missing optional content**

```dart
testWidgets('zero reviews and orders display, null rating does not become 0.0', (tester) async {
  await tester.pumpWidget(testApp(DriverProfileHeroCard(profile: profile.copyWith(
    averageRating: null,
    reviewsCount: 0,
    totalOrders: 0,
    acceptanceRatePercent: null,
  ))));
  expect(find.text('0'), findsWidgets);
  expect(find.text('0.0'), findsNothing);
  expect(find.text('0%'), findsNothing);
});

testWidgets('missing latest ticket does not render fake ticket content', (tester) async {
  await tester.pumpWidget(testApp(const DriverProfileTicketCard(ticket: null)));
  expect(find.byKey(const Key('driver_profile_ticket_empty')), findsOneWidget);
  expect(find.text('#SUP-4587'), findsNothing);
});
```

- [ ] **Step 2: Run tests and confirm the old fake-oriented API fails**

Run: `flutter test test/features/driver/driver_profile/presentation/widgets/driver_profile_content_widgets_test.dart`

Expected: FAIL on obsolete entity fields and widget constructors.

- [ ] **Step 3: Update hero card**

Use `AppCachedNetworkImage` for `profileImageUrl`, with a user icon and `ShimmerWidget` placeholder. Display backend `fullName`, `driverDescription`, optional `driverRank`, `driverCode`, `statusText`, optional phone, nullable rating, real counts, optional acceptance rate, and locally formatted `joinedAtUtc`. Do not derive a CDN URL from `profileImageStorageKey`.

- [ ] **Step 4: Update vehicle card**

Accept `DriverProfileVehicleEntity?`; show an empty state when absent. Build model/year text from available values, render optional color and plate governorate, and style `verificationStatusText` using `verificationStatus`. Remove the implication that document verification is independent fleet approval, and remove the unsupported tap/change action.

- [ ] **Step 5: Update latest ticket card**

Accept `DriverProfileTicketEntity?`; render ticket ID, subject, body, status, priority, and formatted `createdAtUtc` when present. Translate known status/priority codes locally and show unknown codes unchanged. Keep “view all tickets” navigation, but do not invent a detail/edit endpoint.

- [ ] **Step 6: Generate localization outputs and run tests**

Run the repository’s localization generation command, then:

Run: `flutter test test/features/driver/driver_profile/presentation/widgets/driver_profile_content_widgets_test.dart`

Expected: PASS in Arabic and English test locales.

- [ ] **Step 7: Commit backend-driven cards**

```bash
git add lib/features/driver/driver_profile/presentation/widgets lib/core/l10n test/features/driver/driver_profile/presentation/widgets
git commit -m "feat(driver-profile): render backend profile content"
```

### Task 7: Integrate the ViewModel with lifecycle, locale, errors, and pull-to-refresh

**Files:**
- Modify: `lib/features/driver/driver_profile/presentation/screens/driver_profile_screen.dart`
- Modify: `lib/core/app_shell/screens/app_shell_screen.dart`
- Modify: `test/driver_profile_screen_test.dart`
- Test: `test/features/driver/driver_profile/presentation/driver_profile_backend_test.dart`

**Interfaces:**
- Consumes: `DriverProfileViewModel`, content widgets, `ApiErrorWidget`, shimmer.
- Produces: `DriverProfileScreen({DriverProfileViewModel? viewModel, bool isActive = true, ...callbacks})`.

- [ ] **Step 1: Write screen state tests**

```dart
testWidgets('loads once, shows shimmer, then content', (tester) async {
  final pending = Completer<ApiResult<DriverProfileEntity>>();
  when(() => useCase()).thenAnswer((_) => pending.future);
  await tester.pumpWidget(buildScreen(viewModel));
  expect(find.byType(DriverProfileShimmer), findsOneWidget);
  verify(() => useCase()).called(1);
  pending.complete(ApiSuccessResult(data: profile));
  await tester.pump();
  expect(find.byType(DriverProfileHeroCard), findsOneWidget);
});

testWidgets('pull refresh retains content and does not show full shimmer', (tester) async {
  await pumpLoadedProfile(tester, viewModel, profile);
  await tester.drag(find.byType(RefreshIndicator), const Offset(0, 500));
  await tester.pump();
  expect(find.byType(DriverProfileHeroCard), findsOneWidget);
  expect(find.byType(DriverProfileShimmer), findsNothing);
});

testWidgets('typed initial failure uses ApiErrorWidget and retries', (tester) async {
  emitFailure(viewModel, ApiErrorType.notFound);
  await tester.pumpWidget(buildScreen(viewModel));
  expect(find.byType(ApiErrorWidget), findsOneWidget);
});
```

- [ ] **Step 2: Run the screen test and verify failure**

Run: `flutter test test/features/driver/driver_profile/presentation/driver_profile_backend_test.dart`

Expected: FAIL because the screen still reads fake data.

- [ ] **Step 3: Convert the screen to coordinated stateful ownership**

Create/inject one ViewModel in `initState`, call `DriverProfileStarted(locale: ...)` once after dependencies are available, close only an internally-created ViewModel, and detect locale changes in `didChangeDependencies`. Store the last locale locally so unrelated inherited-widget changes do not trigger requests.

- [ ] **Step 4: Use narrow state rebuilds**

Wrap the state-dependent body in `BlocBuilder` with:

```dart
buildWhen: (previous, current) =>
    previous.profile != current.profile ||
    previous.failure != current.failure ||
    previous.isInitialLoading != current.isInitialLoading,
```

Use a separate `BlocListener` for `inlineFailure` so a refresh error shows a snackbar without rebuilding the whole content. Keep static header, quick actions, and policy widgets outside the state-dependent subtree where possible, and keep constructors `const` where inputs are static.

- [ ] **Step 5: Wire loading, content, error, and refresh**

Initial state → `DriverProfileShimmer`; initial typed failure → `ApiErrorWidget.fromTypedFailure(onRetry: ...)`; loaded state → `RefreshIndicator` around content. Preserve data during refresh and use the platform refresh indicator only for the user gesture.

- [ ] **Step 6: Refresh only on meaningful activation**

In `AppShellScreen`, construct `DriverProfileScreen(isActive: activeIndex == 4)`. In `didUpdateWidget`, dispatch `DriverProfileActivated(locale: currentLocale)` only on `false → true`; the ViewModel freshness window decides whether a request is necessary. This prevents every shell rebuild or tab tap from issuing a request.

- [ ] **Step 7: Handle expired avatar URL once per loaded profile generation**

On `AppCachedNetworkImage.onImageResolved(false)`, ask the ViewModel for a forced refresh only once for the current `profileImageUrl`. Track the attempted URL in screen state and reset it only when a different URL arrives. This refreshes a 15-minute signed URL without creating an error/reload loop.

- [ ] **Step 8: Run screen tests**

Run: `flutter test test/features/driver/driver_profile/presentation/driver_profile_backend_test.dart test/driver_profile_screen_test.dart`

Expected: PASS with a single initial request, retained content on refresh, and typed error UI.

- [ ] **Step 9: Commit screen integration**

```bash
git add lib/features/driver/driver_profile/presentation/screens lib/core/app_shell/screens/app_shell_screen.dart test/driver_profile_screen_test.dart test/features/driver/driver_profile/presentation
git commit -m "feat(driver-profile): bind profile screen to backend state"
```

### Task 8: Verify performance invariants and full integration

**Files:**
- Test: `test/features/driver/driver_profile/presentation/driver_profile_performance_test.dart`
- Modify: any Task 1–7 file only if verification exposes a defect.

**Interfaces:**
- Verifies the complete feature; produces no new runtime API.

- [ ] **Step 1: Add regression tests for request counts**

```dart
testWidgets('unrelated parent rebuilds do not refetch profile', (tester) async {
  await tester.pumpWidget(rebuildableHost(DriverProfileScreen(viewModel: viewModel)));
  await completeInitialLoad(tester);
  await triggerUnrelatedParentRebuild(tester);
  verify(() => useCase()).called(1);
});

testWidgets('reactivation inside freshness window does not refetch', (tester) async {
  await pumpLoadedProfile(tester, viewModel, profile);
  await setProfileTabActive(tester, false);
  await setProfileTabActive(tester, true);
  verify(() => useCase()).called(1);
});

testWidgets('one locale change causes one new request', (tester) async {
  await pumpLoadedProfile(tester, viewModel, profile);
  await changeLocale(tester, const Locale('en'));
  verify(() => useCase()).called(2);
});
```

- [ ] **Step 2: Run all driver-profile tests**

Run: `flutter test test/features/driver/driver_profile test/driver_profile_screen_test.dart`

Expected: PASS.

- [ ] **Step 3: Run code generation consistency and static analysis**

Run: `dart run build_runner build --delete-conflicting-outputs`

Run: `flutter analyze`

Expected: no new analysis errors and no generated-file drift after a second build_runner run.

- [ ] **Step 4: Run the full test suite**

Run: `flutter test`

Expected: PASS; if pre-existing unrelated failures exist, record their exact test names and verify all driver-profile tests independently pass.

- [ ] **Step 5: Manually verify the acceptance matrix**

Check Arabic and English, direct object parsing, missing vehicle fields, empty documents, every known document status, unknown document status, null assignment, null ticket, zero counts, null rating/acceptance/rank/governorate, 401/403/404/network/5xx, pull refresh, tab reactivation before/after 15 minutes, and avatar failure. Confirm there are no upload/change/edit success paths.

- [ ] **Step 6: Commit verification coverage**

```bash
git add test/features/driver/driver_profile lib/features/driver/driver_profile lib/core/network lib/core/app_shell lib/core/l10n
git commit -m "test(driver-profile): cover profile integration and request efficiency"
```

## Performance Acceptance Criteria

- Exactly one API call on first profile-screen activation.
- No API call from ordinary widget rebuilds, scrolling, orientation/layout rebuilds, or navigation callbacks unrelated to profile data.
- Repeated load events while the same locale request is active share the same future.
- Pull-to-refresh triggers at most one concurrent request and retains the loaded widget tree.
- Locale change issues one request for the new locale; any older response is ignored.
- Returning to the profile tab refreshes only when cached state is at least 15 minutes old.
- Avatar failure can trigger only one refresh per failed URL.
- Initial loading uses static `ShimmerWidget` placeholders; no extra animation controller, timer, or shimmer dependency is added.
- `BlocBuilder.buildWhen`, immutable/equatable entities, `const` widgets, and small content widgets confine rebuilds to changed profile content.

## Out of Scope

- `POST /api/v1/driver/profile/documents` and any renewal upload UI.
- Vehicle change requests.
- Profile editing.
- Client-side authority to bypass backend shift-start validation.
- Guessing unsupported health-certificate rows or synthesizing absent backend values.
