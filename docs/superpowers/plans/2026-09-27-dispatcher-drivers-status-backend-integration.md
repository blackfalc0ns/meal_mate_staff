# Dispatcher Drivers Status Backend Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the dispatcher drivers status feature's fake data with the Screen 04.05 REST and SignalR contracts while preserving the existing UI, navigation, localization, and clean-architecture flow.

**Architecture:** Keep the existing feature-based layers and route all work through `UI -> Event -> ViewModel -> UseCase -> Repository -> RemoteDataSource -> ApiServices`. REST DTOs stay nullable and map into domain-safe entities; list controls are server-driven, availability changes are optimistic and reversible, and a feature-specific SignalR client applies authoritative updates. Existing Core error widgets handle failures, while the existing feature shimmer handles first load.

**Tech Stack:** Flutter, Dart 3.12, flutter_bloc, Dio, Retrofit, json_serializable, GetIt constructor injection, signalr_netcore, url_launcher, flutter_test.

**Spec:** `D:/yahya/meal meat/dis_new/screen-04.05-dispatcher-drivers-list____.md`

## Global Constraints

- Treat the Screen 04.05 Markdown contract as authoritative: `GET /api/v1/dispatcher/drivers`, `PATCH /api/v1/dispatcher/drivers/{driverId}/availability`, hub `/hubs/dispatcher-hub`, event `driver-availability-updated`.
- Follow `rules/rules_backend.md`; do not bypass DTO, mapper, repository, use-case, event, or ViewModel layers.
- Preserve the current visual design, route names, RTL/LTR behavior, and dispatcher driver-details navigation.
- Use the existing `ApiServices`, injected `Dio`, token/language interceptors, `ApiResult`, `safeApiCall`, and GetIt container.
- Response DTO fields are nullable and defensive; request fields follow the backend contract; never force-unwrap API values.
- Use `ApiErrorWidget` for a failed first load with no usable data, `InlineApiErrorWidget` for a failed action/refresh while content remains, and Core `EmptyStateWidget` after a successful empty response.
- Use `DispatcherDriversStatusShimmer` for initial loading; do not introduce a progress-only blank screen.
- Preserve existing content during refresh, pagination, toggle, and realtime reconnect work.
- Do not edit `api_services.g.dart` or JSON `*.g.dart` files manually; regenerate them with build_runner.
- The project currently uses manual GetIt registrations in `lib/core/di/di.dart` and has no `di.config.dart`; update the existing registration block without migrating the whole application to generated Injectable DI.
- Do not add packages. `signalr_netcore` and `url_launcher` already exist.
- Do not delete the fake implementation until REST replacement tests pass.
- Do not alter the separate `dispatcher_drivers` roster/assignment feature or its `/roster` endpoint.

## Planned File Structure

### Create

- `lib/features/dispatcher/dispatcher_drivers_status/data/models/request/update_driver_availability_request_dto.dart` — PATCH body serialization.
- `lib/features/dispatcher/dispatcher_drivers_status/data/models/response/update_driver_availability_response_dto.dart` — PATCH response parsing.
- `lib/features/dispatcher/dispatcher_drivers_status/data/models/realtime/driver_availability_updated_event_dto.dart` — SignalR payload parsing.
- `lib/features/dispatcher/dispatcher_drivers_status/data/realtime/dispatcher_drivers_status_realtime_client.dart` — realtime abstraction.
- `lib/features/dispatcher/dispatcher_drivers_status/data/realtime/dispatcher_drivers_status_signalr_client.dart` — authenticated SignalR connection and event stream.
- `lib/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_query_entity.dart` — immutable server query.
- `lib/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_sort.dart` — `Name`, `RatingDesc`, `Newest`, `Status` mapping.
- `lib/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_pagination_entity.dart` — page metadata.
- `lib/features/dispatcher/dispatcher_drivers_status/domain/entities/update_driver_availability_request_entity.dart` — toggle command.
- `lib/features/dispatcher/dispatcher_drivers_status/domain/entities/update_driver_availability_result_entity.dart` — authoritative toggle/realtime result.
- `lib/features/dispatcher/dispatcher_drivers_status/domain/usecase/observe_driver_availability_updates_usecase.dart` — realtime stream access.
- `lib/features/dispatcher/dispatcher_drivers_status/domain/usecase/start_dispatcher_drivers_status_updates_usecase.dart` — screen ownership acquisition.
- `lib/features/dispatcher/dispatcher_drivers_status/domain/usecase/stop_dispatcher_drivers_status_updates_usecase.dart` — screen ownership release.
- `lib/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_pagination.dart` — previous/next controls.
- `lib/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_sort_button.dart` — current sort control.
- Focused unit tests under `test/features/dispatcher/dispatcher_drivers_status/` as listed per task.

### Modify

- `lib/core/network/network_constants.dart`
- `lib/core/network/api_services.dart`
- Generated Retrofit/JSON files through build_runner only.
- Existing `dispatcher_drivers_status` DTO, mapper, entities, repository, use cases, events, state, ViewModel, screen, card, filters, KPIs, empty state, and shimmer.
- `lib/core/di/di.dart`
- `lib/core/l10n/app_ar.arb` and `lib/core/l10n/app_en.arb`, then generated localization files via `flutter gen-l10n`.
- `test/dispatcher_drivers_status_screen_test.dart` or migrate its coverage into the focused test directory without duplicating test names.

---

### Task 1: Lock the REST Contract with Defensive DTO Tests

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/data/models/response/dispatcher_drivers_status_response_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers_status/data/models/request/update_driver_availability_request_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers_status/data/models/response/update_driver_availability_response_dto.dart`
- Test: `test/features/dispatcher/dispatcher_drivers_status/data/models/dispatcher_drivers_status_dto_test.dart`

**Interfaces:**
- Consumes: exact JSON keys from Screen 04.05.
- Produces: `DispatcherDriversStatusResponseDto`, `DispatcherDriversStatusCountsDto`, `DispatcherDriverStatusItemDto`, `DispatcherDriversPaginationDto`, `UpdateDriverAvailabilityRequestDto`, and `UpdateDriverAvailabilityResponseDto`.

- [ ] **Step 1: Write failing response parsing tests**

Cover a full response and a defensive sparse response. Assert camelCase JSON keys map exactly, `rating` and `phoneNumber` remain nullable, `items` defaults only in the mapper rather than parser, and pagination flags parse correctly.

```dart
final dto = DispatcherDriversStatusResponseDto.fromJson({
  'counts': {
    'total': 24,
    'available': 12,
    'inDelivery': 8,
    'unavailable': 4,
  },
  'items': [
    {
      'driverId': 'driver-1',
      'driverCode': 'DR-1025',
      'fullName': 'أحمد السعيد',
      'phoneNumber': '+96550123456',
      'avatarStorageKey': 'uploads/drivers/profiles/photo1.jpg',
      'isAvailable': true,
      'operationalStatus': 'Available',
      'rating': 4.8,
      'ratingsCount': 34,
      'vehicleType': 'Car',
      'vehicleModel': 'Toyota Corolla',
      'vehiclePlate': '12-3456',
    },
  ],
  'pagination': {
    'pageNumber': 1,
    'pageSize': 15,
    'totalItems': 24,
    'totalPages': 2,
    'hasPreviousPage': false,
    'hasNextPage': true,
  },
});

expect(dto.items?.single.driverId, 'driver-1');
expect(dto.items?.single.rating, 4.8);
expect(dto.pagination?.hasNextPage, isTrue);
```

- [ ] **Step 2: Write failing PATCH serialization tests**

Assert required `isAvailable` is emitted, non-empty optional `reason` is emitted, and a null reason is omitted with `@JsonSerializable(includeIfNull: false)`.

```dart
expect(
  const UpdateDriverAvailabilityRequestDto(
    isAvailable: false,
    reason: 'استراحة غداء مجدولة',
  ).toJson(),
  {'isAvailable': false, 'reason': 'استراحة غداء مجدولة'},
);
```

- [ ] **Step 3: Run the model test and verify it fails**

Run:

```powershell
flutter test test/features/dispatcher/dispatcher_drivers_status/data/models/dispatcher_drivers_status_dto_test.dart
```

Expected: compilation failures for the new DTO shape/classes.

- [ ] **Step 4: Implement nullable JSON-serializable DTOs**

Use `@JsonSerializable(createToJson: false)` for responses and `@JsonSerializable(includeIfNull: false)` for the request. Keep every response field nullable. Use the contract's camelCase keys without inventing wrappers such as `data`.

```dart
@JsonSerializable(createToJson: false)
class DispatcherDriverStatusItemDto {
  const DispatcherDriverStatusItemDto({
    this.driverId,
    this.driverCode,
    this.fullName,
    this.phoneNumber,
    this.avatarStorageKey,
    this.isAvailable,
    this.operationalStatus,
    this.rating,
    this.ratingsCount,
    this.vehicleType,
    this.vehicleModel,
    this.vehiclePlate,
  });

  final String? driverId;
  final String? driverCode;
  final String? fullName;
  final String? phoneNumber;
  final String? avatarStorageKey;
  final bool? isAvailable;
  final String? operationalStatus;
  final double? rating;
  final int? ratingsCount;
  final String? vehicleType;
  final String? vehicleModel;
  final String? vehiclePlate;
}
```

- [ ] **Step 5: Generate serializers and rerun the focused test**

Run:

```powershell
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/dispatcher/dispatcher_drivers_status/data/models/dispatcher_drivers_status_dto_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit the contract boundary**

```powershell
git add lib/features/dispatcher/dispatcher_drivers_status/data/models test/features/dispatcher/dispatcher_drivers_status/data/models
git commit -m "test: lock dispatcher drivers API contract"
```

---

### Task 2: Build Domain Models and Mapping Rules

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_status_type.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_status_item_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_kpis_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_summary_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_query_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_sort.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_pagination_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers_status/domain/entities/update_driver_availability_request_entity.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers_status/domain/entities/update_driver_availability_result_entity.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/data/mapper/dispatcher_drivers_status_mapper.dart`
- Test: `test/features/dispatcher/dispatcher_drivers_status/data/mapper/dispatcher_drivers_status_mapper_test.dart`

**Interfaces:**
- Consumes: DTOs from Task 1.
- Produces: domain status enum `available`, `inDelivery`, `unavailable`, `unknown`; query defaults `all/name/page 1/page size 15`; nullable rating and phone; summary counts/items/pagination.

- [ ] **Step 1: Write failing mapper tests for all operational states and null semantics**

Assert case-insensitive mapping of `Available`, `InDelivery`, and `Unavailable`; unknown input maps to `unknown`, never `available`. Assert `rating: null` remains null so UI can show “New”, missing phone remains null, counts are clamped to non-negative values, and missing lists map to `const []`.

```dart
expect(
  DispatcherDriverStatusTypeX.fromApi('InDelivery'),
  DispatcherDriverStatusType.inDelivery,
);
expect(entity.rating, isNull);
expect(entity.phoneNumber, isNull);
```

- [ ] **Step 2: Write failing tests for request and sort mappings**

Assert:

```dart
expect(DispatcherDriversStatusSort.ratingDesc.apiValue, 'RatingDesc');
expect(DispatcherDriverStatusType.unavailable.apiValue, 'Unavailable');
expect(const DispatcherDriversStatusQueryEntity().pageNumber, 1);
expect(const DispatcherDriversStatusQueryEntity().pageSize, 15);
```

- [ ] **Step 3: Run mapper tests and verify they fail**

```powershell
flutter test test/features/dispatcher/dispatcher_drivers_status/data/mapper/dispatcher_drivers_status_mapper_test.dart
```

Expected: compilation/assertion failures caused by legacy `offline/connected` and missing fields.

- [ ] **Step 4: Implement domain entities and mapping extensions**

Use stable property names:

```dart
enum DispatcherDriverStatusType { available, inDelivery, unavailable, unknown }

class DispatcherDriversStatusSummaryEntity {
  final DispatcherDriversStatusKpisEntity counts;
  final List<DispatcherDriverStatusItemEntity> items;
  final DispatcherDriversPaginationEntity pagination;
}
```

The item entity contains `driverId`, `driverCode`, `fullName`, nullable `phoneNumber`, nullable resolved `avatarUrl`, `isAvailable`, `operationalStatus`, nullable `rating`, `ratingsCount`, `vehicleType`, `vehicleModel`, and `vehiclePlate`. Retain convenience getters (`id`, `name`, `code`, `plateNumber`, `status`) only where they reduce UI churn and keep them read-only.

- [ ] **Step 5: Resolve avatar storage keys consistently**

Reuse an existing project URL/storage resolver if one exists. If none exists, map absolute `http/https` values unchanged and resolve relative keys with `Uri.parse(NetworkConstants.baseUrl).resolve('/$normalizedKey')`; keep null/blank as null. Test all three cases. Do not hardcode the base URL in the feature.

- [ ] **Step 6: Map toggle request/result**

Add `UpdateDriverAvailabilityRequestEntity.toDto()` and `UpdateDriverAvailabilityResponseDto.toEntity()`. Parse `updatedAtUtc` with `DateTime.tryParse(value)?.toUtc()` and keep it nullable on malformed/missing input.

- [ ] **Step 7: Run mapper tests**

```powershell
flutter test test/features/dispatcher/dispatcher_drivers_status/data/mapper/dispatcher_drivers_status_mapper_test.dart
```

Expected: PASS.

- [ ] **Step 8: Commit domain and mapping work**

```powershell
git add lib/features/dispatcher/dispatcher_drivers_status/domain/entities lib/features/dispatcher/dispatcher_drivers_status/data/mapper test/features/dispatcher/dispatcher_drivers_status/data/mapper
git commit -m "feat: model dispatcher fleet status domain"
```

---

### Task 3: Connect Retrofit, Remote Data Source, Repository, and Use Cases

**Files:**
- Modify: `lib/core/network/network_constants.dart`
- Modify: `lib/core/network/api_services.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/data/data_source/dispatcher_drivers_status_remote_data_source.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/data/data_source/dispatcher_drivers_status_remote_data_source_impl.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/domain/repo/dispatcher_drivers_status_repository.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/data/repo/dispatcher_drivers_status_repository_impl.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/domain/usecase/get_drivers_status_usecase.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/domain/usecase/toggle_driver_availability_usecase.dart`
- Modify: `lib/core/di/di.dart`
- Generated: `lib/core/network/api_services.g.dart` and DTO `*.g.dart` via build_runner.
- Test: `test/features/dispatcher/dispatcher_drivers_status/data/repo/dispatcher_drivers_status_repository_impl_test.dart`

**Interfaces:**
- Consumes: `DispatcherDriversStatusQueryEntity` and `UpdateDriverAvailabilityRequestEntity`.
- Produces: `Future<ApiResult<DispatcherDriversStatusSummaryEntity>> getDriversStatus(query)` and `Future<ApiResult<UpdateDriverAvailabilityResultEntity>> toggleDriverAvailability(request)`.

- [ ] **Step 1: Write failing repository tests**

Use a fake `DispatcherDriversStatusRemoteDataSource`. Verify query values are forwarded, response DTOs map into entities, request entities map into DTO bodies, and thrown `DioException` becomes `ApiErrorResult` through `safeApiCall`.

- [ ] **Step 2: Run repository tests and verify they fail**

```powershell
flutter test test/features/dispatcher/dispatcher_drivers_status/data/repo/dispatcher_drivers_status_repository_impl_test.dart
```

- [ ] **Step 3: Add endpoint constants and Retrofit methods**

```dart
static const String dispatcherDriversStatus = '/api/v1/dispatcher/drivers';
static const String dispatcherDriverAvailability =
    '/api/v1/dispatcher/drivers/{driverId}/availability';
static const String dispatcherDriversStatusHub = '/hubs/dispatcher-hub';
```

```dart
@GET(EndPoints.dispatcherDriversStatus)
Future<DispatcherDriversStatusResponseDto> getDispatcherDriversStatus({
  @Query('search') String? search,
  @Query('status') String status = 'All',
  @Query('sortBy') String sortBy = 'Name',
  @Query('pageNumber') int pageNumber = 1,
  @Query('pageSize') int pageSize = 15,
});

@PATCH(EndPoints.dispatcherDriverAvailability)
Future<UpdateDriverAvailabilityResponseDto> updateDispatcherDriverAvailability(
  @Path('driverId') String driverId,
  @Body() UpdateDriverAvailabilityRequestDto request,
);
```

Do not manually add Authorization or Accept-Language headers; existing interceptors own them.

- [ ] **Step 4: Replace the fake remote implementation**

Inject `ApiServices`; delete all delayed/static driver construction; delegate both calls directly to Retrofit. Keep no state, UI logic, error conversion, or navigation in this layer.

```dart
class DispatcherDriversStatusRemoteDataSourceImpl
    implements DispatcherDriversStatusRemoteDataSource {
  const DispatcherDriversStatusRemoteDataSourceImpl(this._apiServices);
  final ApiServices _apiServices;
}
```

- [ ] **Step 5: Update repository contracts and use cases**

Pass domain entities through use cases and keep DTO mapping exclusively in `DispatcherDriversStatusRepositoryImpl`. Wrap both remote calls in `safeApiCall`.

- [ ] **Step 6: Update the existing manual DI block**

Construct the remote data source with `getIt<ApiServices>()`. Do not add a second Dio/Retrofit client and do not edit unrelated registrations.

- [ ] **Step 7: Regenerate code and run tests**

```powershell
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/dispatcher/dispatcher_drivers_status/data/repo/dispatcher_drivers_status_repository_impl_test.dart
```

Expected: PASS and generated Retrofit code contains both endpoints.

- [ ] **Step 8: Commit REST integration**

```powershell
git add lib/core/network lib/core/di/di.dart lib/features/dispatcher/dispatcher_drivers_status/data lib/features/dispatcher/dispatcher_drivers_status/domain test/features/dispatcher/dispatcher_drivers_status/data/repo
git commit -m "feat: connect dispatcher drivers REST API"
```

---

### Task 4: Implement Server-Driven List State and Availability Semantics

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_event.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_state.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_view_model.dart`
- Test: `test/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_view_model_test.dart`

**Interfaces:**
- Consumes: REST use cases from Task 3.
- Produces: immutable state with query, summary, loading modes, per-driver toggle IDs, and non-destructive failures.

- [ ] **Step 1: Write failing load/query tests**

Test initial load defaults, 350 ms search debounce, clearing search, filter changes, sort changes, previous/next page, refresh retaining content, and stale-response rejection when two queries overlap. Assert every query-changing action resets `pageNumber` to 1 except explicit page navigation.

Events:

```dart
SearchDriversStatusEvent(String query)
FilterDriversStatusEvent(DispatcherDriverStatusType? status)
SortDriversStatusEvent(DispatcherDriversStatusSort sort)
ChangeDriversStatusPageEvent(int pageNumber)
RefreshDispatcherDriversStatusEvent()
```

- [ ] **Step 2: Write failing toggle behavior tests**

Cover:

- Available -> toggle false: optimistic `isAvailable=false`, optimistic status `unavailable`, counters adjusted, then server response replaces optimistic values.
- InDelivery -> toggle false: `isAvailable=false` but status remains `inDelivery`; active delivery is never cancelled or hidden locally.
- PATCH failure: exact previous item and counts are restored, content remains visible, and an action failure is exposed.
- Repeated tap while the driver ID is in `togglingDriverIds`: no second request.
- `reason` is forwarded when supplied.

- [ ] **Step 3: Run ViewModel tests and verify they fail**

```powershell
flutter test test/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_view_model_test.dart
```

- [ ] **Step 4: Replace local filtering with a query-driven state**

Remove `filteredDrivers`; the backend `summary.items` is the rendered page. Store:

```dart
final DispatcherDriversStatusQueryEntity query;
final Failure? initialFailure;
final Failure? actionFailure;
final bool isInitialLoading;
final bool isRefreshing;
final bool isPageLoading;
final Set<String> togglingDriverIds;
```

Provide explicit `clearInitialFailure` and `clearActionFailure` flags in `copyWith`; do not rely on nullable arguments ambiguously clearing failures.

- [ ] **Step 5: Implement request sequencing and debounce**

Maintain a `Timer? _searchDebounce` and monotonically increasing `_requestGeneration`. Only the newest generation may update the summary. Cancel the timer and subscriptions in `close()`.

- [ ] **Step 6: Implement optimistic toggle snapshots**

Capture the exact pre-toggle driver and counts. Apply a helper that respects priority:

```dart
final optimisticStatus = previous.operationalStatus ==
        DispatcherDriverStatusType.inDelivery
    ? DispatcherDriverStatusType.inDelivery
    : requestedAvailability
        ? DispatcherDriverStatusType.available
        : DispatcherDriverStatusType.unavailable;
```

On success, merge the authoritative response into that item. On failure, restore the snapshot and set `actionFailure`; never set `initialFailure` for an action failure.

- [ ] **Step 7: Run ViewModel tests**

```powershell
flutter test test/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_view_model_test.dart
```

Expected: PASS.

- [ ] **Step 8: Commit state management**

```powershell
git add lib/features/dispatcher/dispatcher_drivers_status/presentation/manager test/features/dispatcher/dispatcher_drivers_status/presentation/manager
git commit -m "feat: manage dispatcher fleet queries and availability"
```

---

### Task 5: Add Feature-Specific SignalR Updates

**Files:**
- Create: `lib/features/dispatcher/dispatcher_drivers_status/data/models/realtime/driver_availability_updated_event_dto.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers_status/data/realtime/dispatcher_drivers_status_realtime_client.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers_status/data/realtime/dispatcher_drivers_status_signalr_client.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/domain/repo/dispatcher_drivers_status_repository.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/data/repo/dispatcher_drivers_status_repository_impl.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers_status/domain/usecase/observe_driver_availability_updates_usecase.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers_status/domain/usecase/start_dispatcher_drivers_status_updates_usecase.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers_status/domain/usecase/stop_dispatcher_drivers_status_updates_usecase.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_event.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_view_model.dart`
- Modify: `lib/core/di/di.dart`
- Test: `test/features/dispatcher/dispatcher_drivers_status/data/realtime/dispatcher_drivers_status_signalr_client_test.dart`
- Test: `test/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_realtime_test.dart`

**Interfaces:**
- Consumes: JWT from existing `TokenService`; event `driver-availability-updated`.
- Produces: broadcast `Stream<UpdateDriverAvailabilityResultEntity>` and lifecycle `acquire(ownerId)/release(ownerId)`.

- [ ] **Step 1: Write failing SignalR URL and payload tests**

Assert base URL normalization produces exactly `/hubs/dispatcher-hub`, payload parsing handles camelCase fields, malformed timestamps remain null, and missing `driverId` events are ignored.

- [ ] **Step 2: Write failing ViewModel realtime tests**

Assert an event updates a visible item, its switch, operational status, and counts without another GET. Assert events for drivers outside the current page trigger a debounced refresh because global counts may have changed. Assert an incoming authoritative event wins over a pending optimistic value.

- [ ] **Step 3: Run realtime tests and verify they fail**

```powershell
flutter test test/features/dispatcher/dispatcher_drivers_status/data/realtime/dispatcher_drivers_status_signalr_client_test.dart
flutter test test/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_realtime_test.dart
```

- [ ] **Step 4: Implement the authenticated realtime client**

Follow the proven lifecycle shape in `dispatcher_map_signalr_client.dart`: existing token service, access-token factory, automatic reconnect delays, broadcast stream, handler registration/removal, owner tracking, and idempotent disposal. Register only `driver-availability-updated` for this client. Do not duplicate token storage or create Dio.

- [ ] **Step 5: Expose realtime through repository and use cases**

The ViewModel receives use cases, not the concrete client. Use a stable owner ID such as `dispatcher-drivers-status-screen`, acquire on initial load, subscribe once, release and cancel in `close()`.

- [ ] **Step 6: Apply events with the same authoritative merge helper as PATCH success**

Avoid two implementations of count/status logic. If the updated driver no longer matches the active server filter, refresh page 1 rather than locally inventing server pagination membership.

- [ ] **Step 7: Update manual DI and run realtime tests**

```powershell
flutter test test/features/dispatcher/dispatcher_drivers_status/data/realtime/dispatcher_drivers_status_signalr_client_test.dart test/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_realtime_test.dart
```

Expected: PASS.

- [ ] **Step 8: Commit realtime integration**

```powershell
git add lib/features/dispatcher/dispatcher_drivers_status lib/core/di/di.dart test/features/dispatcher/dispatcher_drivers_status
git commit -m "feat: stream dispatcher driver availability updates"
```

---

### Task 6: Connect the Existing UI, Core Errors, Shimmer, Calling, Sorting, and Pagination

**Files:**
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/presentation/screens/dispatcher_drivers_status_screen.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_card.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_badge.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_kpi_section.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_filter_sheet.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_count_header.dart`
- Remove after replacing all usages: `lib/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_empty_state.dart`
- Modify: `lib/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_shimmer.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_pagination.dart`
- Create: `lib/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_sort_button.dart`
- Modify: `lib/core/l10n/app_ar.arb`
- Modify: `lib/core/l10n/app_en.arb`
- Generated: localization Dart files via `flutter gen-l10n`.
- Test: `test/dispatcher_drivers_status_screen_test.dart`

**Interfaces:**
- Consumes: Task 4/5 ViewModel state and events.
- Produces: unchanged screen identity with all Screen 04.05 behaviors visible and accessible.

- [ ] **Step 1: Rewrite failing widget tests around the backend domain shape**

Cover:

- Initial `DispatcherDriversStatusShimmer` before the first response.
- Exactly four KPI values: total, available, in delivery, unavailable.
- `ApiErrorWidget` plus retry for first-load failure.
- Successful empty list uses Core `EmptyStateWidget` with localized fleet copy, not an error widget or a duplicate feature widget.
- Search event dispatch, filter selection, sort selection, and previous/next page events.
- Nullable rating renders localized “New” instead of `0.0`.
- Null phone disables call action and shows localized “phone not registered”.
- Valid phone launches `tel:<number>` through an injectable/testable launcher boundary already used by driver details, or a small feature-local abstraction if the existing launcher cannot represent nullable phone.
- Toggle shows an inline loader/disabled control only for the affected driver.
- Tapping the card still navigates to `AppRoutes.dispatcherDriverDetails` with `driverId`.
- `InDelivery` badge remains blue when availability is false.

- [ ] **Step 2: Run widget tests and verify they fail**

```powershell
flutter test test/dispatcher_drivers_status_screen_test.dart
```

- [ ] **Step 3: Wire screen-level loading/error/empty/content states**

Use this decision order:

```dart
if (state.isInitialLoading && state.summary == null) {
  return const DispatcherDriversStatusShimmer();
}
if (state.initialFailure != null && state.summary == null) {
  return ApiErrorWidget.fromTypedFailure(
    failure: state.initialFailure!,
    onRetry: () => viewModel.doIntent(
      const LoadDispatcherDriversStatusEvent(),
    ),
  );
}
```

Keep content visible for refresh/action errors. Place `InlineApiErrorWidget` above the list when `actionFailure != null`, with retry bound to the exact failed query/action where safe; otherwise provide dismissal through a clear-error event without replaying a non-idempotent toggle automatically.

For `summary.items.isEmpty`, render `EmptyStateWidget` from `lib/core/errors/error_widgets/empty_state_widget.dart` with localized title/description. Delete `DispatcherDriversStatusEmptyState` only after its usages and tests have moved to Core.

- [ ] **Step 4: Connect server-driven controls**

Search dispatches on text change and lets the ViewModel debounce. KPI/filter controls use `All/Available/InDelivery/Unavailable`. Sort control exposes `Name/RatingDesc/Newest/Status`. Count header uses `pagination.totalItems`, not current page length. Pagination disables buttons using `hasPreviousPage/hasNextPage` and displays localized `pageNumber/totalPages`.

- [ ] **Step 5: Upgrade the card without redesigning it**

Render full name/code, nullable rating plus ratings count, vehicle model/type/plate, phone, status badge, availability label/switch, call action, and details action within the current card styling. Stop the switch/call button tap from triggering card navigation. Disable the switch while that driver ID is toggling and show a compact progress indicator in the switch area.

- [ ] **Step 6: Update the shimmer to match final content**

Use the existing shimmer widget/style and create placeholders for four KPIs, search/sort row, and multiple full-height driver cards. Do not use static fake driver text during loading and do not show a lone `CircularProgressIndicator` for the initial screen.

- [ ] **Step 7: Add localized strings and regenerate localization**

Add Arabic/English strings for all statuses, sort choices, pagination, “New”, phone-unavailable, call, details, availability, toggle reason prompt if retained, and empty-filter results. Run:

```powershell
flutter gen-l10n
```

- [ ] **Step 8: Run widget tests**

```powershell
flutter test test/dispatcher_drivers_status_screen_test.dart
```

Expected: PASS in Arabic and at least one English smoke case.

- [ ] **Step 9: Commit UI integration**

```powershell
git add lib/features/dispatcher/dispatcher_drivers_status/presentation lib/core/l10n test/dispatcher_drivers_status_screen_test.dart
git commit -m "feat: present live dispatcher fleet controls"
```

---

### Task 7: Verify Authentication, Error Mapping, and Edge Cases

**Files:**
- Modify only if tests expose a feature-specific gap: `lib/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_view_model.dart`
- Test: `test/features/dispatcher/dispatcher_drivers_status/presentation/dispatcher_drivers_status_error_handling_test.dart`
- Test: `test/features/dispatcher/dispatcher_drivers_status/presentation/dispatcher_drivers_status_edge_cases_test.dart`

**Interfaces:**
- Consumes: existing Core `Failure`, `ApiExceptionMapper`, and error widgets.
- Produces: verified behavior for 401, 403, 404, empty/null fields, refresh failure, and action failure.

- [ ] **Step 1: Write error-path tests using typed Failures**

Assert 401/403/404 and connectivity/timeout failures reach `ApiErrorWidget.fromTypedFailure` on initial load. Do not add feature-level status-code switches already handled by Core.

- [ ] **Step 2: Write retained-content tests**

Assert a refresh failure retains the last summary and presents `InlineApiErrorWidget`; a PATCH 404 restores the driver snapshot and triggers a list refresh after the inline error is shown; a successful empty page does not construct a `Failure`.

- [ ] **Step 3: Write data edge-case tests**

Cover null phone, null rating, null avatar, unknown operational status, empty items, page number beyond new total pages after filtering, and a realtime update for a driver absent from the current page.

- [ ] **Step 4: Run edge/error tests and make only scoped corrections**

```powershell
flutter test test/features/dispatcher/dispatcher_drivers_status/presentation/dispatcher_drivers_status_error_handling_test.dart test/features/dispatcher/dispatcher_drivers_status/presentation/dispatcher_drivers_status_edge_cases_test.dart
```

Expected: PASS. Reuse Core widgets; do not create new feature error widgets.

- [ ] **Step 5: Commit resilience coverage**

```powershell
git add lib/features/dispatcher/dispatcher_drivers_status test/features/dispatcher/dispatcher_drivers_status
git commit -m "test: cover dispatcher fleet failures and edge cases"
```

---

### Task 8: Generated Code, Regression Tests, and Final Verification

**Files:**
- Generated: Retrofit, JSON serialization, and localization outputs.
- Review only: all files changed by Tasks 1–7.

**Interfaces:**
- Consumes: complete implementation.
- Produces: formatted, analyzed, tested integration with no stale generated artifacts.

- [ ] **Step 1: Regenerate all required output**

```powershell
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

Expected: successful generation; no manual edits inside generated files.

- [ ] **Step 2: Format only relevant source and tests**

```powershell
dart format lib/core/network lib/core/di/di.dart lib/features/dispatcher/dispatcher_drivers_status test/dispatcher_drivers_status_screen_test.dart test/features/dispatcher/dispatcher_drivers_status
```

- [ ] **Step 3: Run focused feature tests**

```powershell
flutter test test/dispatcher_drivers_status_screen_test.dart test/features/dispatcher/dispatcher_drivers_status
```

Expected: all dispatcher drivers status tests PASS.

- [ ] **Step 4: Run nearby dispatcher regressions**

```powershell
flutter test test/dispatcher_profile_drivers_status_card_test.dart test/dispatcher_drivers_screen_test.dart
```

Expected: profile entry and separate roster/assignment screen remain passing.

- [ ] **Step 5: Run static analysis**

```powershell
flutter analyze
```

Expected: no new analyzer errors or warnings caused by this work.

- [ ] **Step 6: Run the complete test suite**

```powershell
flutter test
```

Expected: PASS. If unrelated pre-existing failures exist, record the exact failing tests and prove all focused/nearby tests pass.

- [ ] **Step 7: Perform a manual authenticated smoke test**

Verify with a Dispatcher account:

1. First load shows shimmer then four live counts and page 1.
2. Arabic/English search matches name, phone, code, and plate through the server.
3. Each status and sort option changes the server query and resets to page 1.
4. Pagination buttons and page label match backend metadata.
5. Valid phone opens the platform dialer; missing phone stays disabled.
6. Available toggle updates optimistically, blocks repeat taps, and reconciles with PATCH response.
7. Turning off an in-delivery driver leaves the blue InDelivery badge until completion.
8. Another session's availability change updates the card and counts via SignalR without manual refresh.
9. Pull-to-refresh retains content during loading and handles failure inline.
10. Card/details navigation still opens Screen 04.07 with the correct driver ID.

- [ ] **Step 8: Inspect the final diff for scope and secrets**

```powershell
git diff --check
git status --short
git diff --stat
```

Confirm there are no fake delays/data, debug token contents, hardcoded bearer tokens, second Dio clients, unrelated refactors, or manual generated-file edits.

- [ ] **Step 9: Commit final generated and verification adjustments**

```powershell
git add lib test
git commit -m "chore: verify dispatcher drivers status integration"
```

## Completion Criteria

- The feature contains no fake driver list or fake toggle result.
- Both documented REST endpoints are invoked through the existing Retrofit client.
- Search, filter, sort, and pagination values are sent to the backend exactly as documented.
- Domain/UI never imports REST DTOs.
- Initial loading uses the feature shimmer; existing content stays visible for refresh/action operations.
- Full-screen, inline, and empty states reuse `ApiErrorWidget`, `InlineApiErrorWidget`, and `EmptyStateWidget` from `lib/core/errors` as specified.
- Operational status priority and active-delivery behavior are preserved.
- SignalR updates visible cards and counts without a full reload and reconnects through the existing auth services.
- Null phone, rating, avatar, empty list, 401, 403, and 404 cases are verified.
- Generated code is current, focused tests pass, nearby regressions pass, and `flutter analyze` reports no new issues.

