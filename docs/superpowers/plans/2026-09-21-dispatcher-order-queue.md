# Dispatcher Orders Queue Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Connect the existing dispatcher orders screen to the queue endpoint, including backend counters, status filters, order cards, screen-shaped shimmer, Core error handling, and empty state.

**Architecture:** Preserve the current `dispatcher_orders` UI and replace its fake-data source with ApiServices -> RemoteDataSource -> Repository -> UseCase -> ViewModel -> State -> UI. This phase does not implement details, candidates, assignment submission, or SignalR.

**Tech Stack:** Flutter/Dart, flutter_bloc, Dio/Retrofit, json_serializable, get_it, `ApiResult`/`safeApiCall`, Core error widgets, and `ShimmerWidget`.

**Spec:** `D:/yahya/meal meat/dis/screen-04.03-dispatcher-order-queue.md` — queue-screen portion only.

## Scope

Included: restaurant identity, four counters, filter chips, box cards, suggestion text, initial shimmer, full-page typed error, successful-empty state, pull-to-refresh, and the existing `إسناد` navigation hook.

Excluded: details screen/API, candidate endpoint, driver-selection bottom sheet, assignment POST, SignalR, and changes to `AssignBoxScreen`.

The `التفاصيل` button is hidden/disabled in this phase. The `إسناد` button keeps navigation to `AppRoutes.assignBox`; it does not call candidate or assignment endpoints.

## Confirmed backend contract for this screen

- Endpoint: `GET /api/v1/dispatcher/orders/queue?filter={value}`.
- Filter wire values are exactly `All`, `Pending`, `Assigned`, `InDelivery`, and `Issues`. The server accepts them case-insensitively and also accepts Arabic aliases; the client always sends the canonical English values.
- `All` may be omitted, but the client sends `All` consistently to keep requests explicit and testable.
- Filtering is server-side. Every filter selection issues a new queue request.
- There is no pagination: `boxes` contains the complete current-shift result for the selected filter.
- Counts describe the entire current shift on every response, not only the filtered list.
- Counter mapping is exact: All -> `totalCount`, Pending -> `pendingCount`, Assigned -> `assignedCount`, In Delivery -> `inDeliveryCount`, Issues -> `issuesCount`.
- `totalCount` is the sum of `pendingCount + assignedCount + inDeliveryCount + issuesCount`; therefore the All chip uses `120` in the documented example, not `23`.
- Status wire values: `Pending`, `Assigned`, `InDelivery`, `Issue`.
- Priority wire values: `New`, `Urgent`, `HighPriority`, `Normal`.
- Suggestion type wire values: `Nearest`, `LeastLoaded`.
- `suggestion` is nullable and is absent when no active driver is eligible or the box is already assigned.
- The backend localizes display strings using `Accept-Language: ar|en`, including `priorityBadgeText`, `suggestion.label`, `mealCountLabel`, and restaurant display text.
- Note the intentional singular/plural difference: the filter value is `Issues`, while an individual box status is `Issue`.

## Global constraints

- Follow `rules/rules_backend.md` exactly.
- UI calls only `viewModel.doIntent(Event)`.
- Response DTO fields are nullable; UI/domain never import DTOs.
- Use one immutable State with `copyWith`, sealed Events, `safeApiCall`, typed `Failure`, and constructor injection.
- Initial load without data uses a screen-shaped shimmer; refresh/filter loading keeps old content.
- Failure without data uses `ApiErrorWidget`; successful empty data uses `EmptyStateWidget`.
- Do not add packages, new error widgets, or another state-management abstraction.
- Continue using the existing `LanguageInterceptor`; do not manually append `Accept-Language` inside this feature.

## File map

Create under `lib/features/dispatcher/dispatcher_orders/`:

- `data/models/response/dispatcher_order_queue_response_dto.dart`
- `data/mapper/dispatcher_orders_mapper.dart`
- `data/data_source/dispatcher_orders_remote_data_source.dart`
- `data/data_source/dispatcher_orders_remote_data_source_impl.dart`
- `data/repo/dispatcher_orders_repository_impl.dart`
- `domain/entities/dispatcher_order_queue_entity.dart`
- `domain/entities/dispatcher_driver_suggestion_entity.dart`
- `domain/entities/dispatcher_order_status.dart`
- `domain/repo/dispatcher_orders_repository.dart`
- `domain/usecase/get_dispatcher_order_queue_usecase.dart`
- `presentation/manager/dispatcher_orders_event.dart`
- `presentation/manager/dispatcher_orders_state.dart`
- `presentation/manager/dispatcher_orders_view_model.dart`
- `presentation/widgets/dispatcher_orders_shimmer.dart`

Modify `network_constants.dart`, `api_services.dart`, `di.dart`, existing order entities/widgets/screen, ARB localization files if necessary, and related tests.

## Task 1: Model and map the queue response

- [ ] Write fixture tests for the documented response plus missing fields, null suggestion, and unknown enums.
- [ ] Test exact enum mappings: statuses `Pending/Assigned/InDelivery/Issue`, priorities `New/Urgent/HighPriority/Normal`, and suggestions `Nearest/LeastLoaded`.
- [ ] Change the existing entity so distance remains numeric, status is explicit, suggestion is nullable, and raw/display values remain separate.
- [ ] Add nullable `@JsonSerializable(createToJson: false)` DTOs matching backend keys exactly.
- [ ] Implement pure DTO-to-entity mappers with `unknown` fallbacks and no force unwraps.
- [ ] Run `dart run build_runner build --delete-conflicting-outputs` and mapper tests.
- [ ] Commit as `feat(dispatcher-orders): model order queue response`.

## Task 2: Integrate the queue endpoint

**Interface:** `DispatcherOrdersRepository.getQueue(DispatcherFilterType filter)` and `GetDispatcherOrderQueueUseCase.call(filter)` return `Future<ApiResult<DispatcherOrderQueueEntity>>`.

- [ ] Write repository tests for success mapping and Dio failure via `safeApiCall`.
- [ ] Add `/api/v1/dispatcher/orders/queue` to `EndPoints`.
- [ ] Add Retrofit GET with `@Query('filter')`; map filters exactly to `All/Pending/Assigned/InDelivery/Issues`.
- [ ] Add a unit test for every filter mapping, including the intentional `Issues` filter versus `Issue` box status difference.
- [ ] Add RemoteDataSource contract/implementation.
- [ ] Add Repository contract/implementation; mapping and `safeApiCall` live here.
- [ ] Add the injectable use case, generate code, and run tests.
- [ ] Commit as `feat(dispatcher-orders): integrate queue endpoint`.

## Task 3: Add filter-safe state management

**Events:** `LoadDispatcherOrdersEvent`, `RefreshDispatcherOrdersEvent`, `SelectDispatcherFilterEvent`, `RetryDispatcherOrdersEvent`.

**State:** queue, selected filter, initial/refresh/filter loading flags, failure, and `hasLoadedOnce`.

- [ ] Test initial success/failure, retry, refresh retaining data, filter success/failure, and out-of-order filter responses.
- [ ] Implement sentinel-based `copyWith` so nullable values can be cleared.
- [ ] Implement `doIntent` and private handlers.
- [ ] Add a request-generation counter so stale responses cannot overwrite the active filter.
- [ ] Preserve current data on refresh/filter failure.
- [ ] Run ViewModel tests and commit as `feat(dispatcher-orders): manage queue and filters`.

## Task 4: Register dependencies

- [ ] Extend `test/core/di/di_test.dart` to resolve data source, repository, use case, and ViewModel.
- [ ] Register them in the same manual get_it style as `dispatcher_home`.
- [ ] Run the DI test and commit as `chore(di): register dispatcher orders flow`.

## Task 5: Bind the existing UI and add shimmer/errors

- [ ] Update widget tests to inject a fake ViewModel.
- [ ] Test shimmer, full-page typed error/retry, empty success, populated content, backend restaurant/counters, filter intent, retained content during reload, and RTL/LTR.
- [ ] Build `DispatcherOrdersShimmer` from `ShimmerWidget` blocks matching header, counters, chips, and three cards.
- [ ] Replace local filter state and every `DispatcherFakeData` read with Bloc state.
- [ ] Load from `initState`; close only an internally created ViewModel.
- [ ] Add `RefreshIndicator` and await the refresh-specific cycle.
- [ ] Use `ApiErrorWidget` only when no queue exists; use localized `EmptyStateWidget` after successful empty data.
- [ ] Pass response counts to metrics/chips; map All to `totalCount` and remove hard-coded `23/37/58/2`.
- [ ] Verify the documented counts render as `120/23/37/58/2` for All/Pending/Assigned/InDelivery/Issues.
- [ ] Add `ValueKey(boxId)` to cards and safely render nullable suggestion.
- [ ] Hide/disable `التفاصيل`.
- [ ] Keep `إسناد` navigation only; do not fabricate missing candidate/driver data.
- [ ] Generate localization files, run widget tests, and commit as `feat(dispatcher-orders): connect queue screen state`.

## Task 6: Verify and clean up

- [ ] Remove production use of `DispatcherFakeData` from the orders screen.
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`.
- [ ] Run `flutter gen-l10n` and `dart format lib test`.
- [ ] Run `flutter test test/features/dispatcher/dispatcher_orders test/dispatcher_orders_screen_test.dart test/core/di/di_test.dart`.
- [ ] Run `flutter test` and `flutter analyze`.
- [ ] Manually verify Arabic/English loading, error/retry, empty, populated, filters, refresh, narrow width, and long text.
- [ ] Commit as `test(dispatcher-orders): verify queue screen integration`.

## Acceptance criteria

- Restaurant, counters, and boxes come only from the queue endpoint.
- Filter changes use exactly `All/Pending/Assigned/InDelivery/Issues`, and stale responses are ignored.
- Loading uses `ShimmerWidget`; failures use Core `ApiErrorWidget`; empty success uses Core `EmptyStateWidget`.
- Existing data stays visible during refresh/filter loading or failure.
- Counts are never hard-coded, All uses `totalCount`, and null/unknown backend values do not crash.
- The complete filtered shift list renders without pagination or load-more behavior.
- No details, candidates, assignment POST, bottom sheet, or SignalR code is added.
- Generated code, tests, and analyzer pass.
