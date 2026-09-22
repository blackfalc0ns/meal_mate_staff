# Dispatcher Support Issues Backend Integration Design

## Scope

Integrate only dispatcher support screen 04.11 with `GET /api/v1/dispatcher/support/issues`. Keep the existing visual identity and screen 04.12 implementation out of scope. Tapping an issue only forwards its identifier to the existing details route. Do not add polling or SignalR.

## Confirmed contract

- Authorization role: `DeliveryManager` through the existing bearer-token interceptor.
- Query: `area`, `status`, `search`, `datePreset`, `fromDateUtc`, `toDateUtc`, `pageNumber`, `pageSize`.
- Defaults: `Open`, `Last7Days`, page 1, size 20; maximum page size 50.
- Search is server-side over box code, driver name/code, category, and title.
- Response: `counters`, `areaChips`, `issues`, and `pagination`.
- Compatibility aliases in the supplied JSON are accepted in DTOs and collapsed to canonical domain properties by the mapper.

## Architecture

```text
Screen -> ViewModel event -> UseCase -> Repository -> RemoteDataSource
       -> ApiServices -> API -> nullable DTO -> Mapper -> Entity -> State -> Screen
```

Reuse the existing Dio, interceptors, `safeApiCall`, `ApiResult`, `Failure`, GetIt, error widgets, localization, and visual widgets. No DTO reaches presentation.

Mapper precedence is deterministic:

```text
id <- id, then issueId
boxCode <- boxCode, then issueCode
issueCategory <- issueCategory, then badgeText
timeAgo <- timeAgo, then reportedTimeText
vehicleInfo <- vehicleInfo, then vehicleText
issueCategoryColor <- valid issueCategoryColor, then named badgeColor fallback
```

All response DTO fields are nullable. Unknown enums, malformed colors/dates, missing optional values, and null lists must not crash.

## State and interaction

The ViewModel owns filters, pagination, concurrency, and failures:

- Initial load uses a structural shimmer.
- Filter/search changes reset to page 1 and replace results.
- Search is trimmed and debounced by 400 ms; clearing reloads immediately.
- Infinite scroll loads only when `hasNextPage` and no append is running.
- Appended issues are de-duplicated by ID.
- A generation counter discards stale replacement responses.
- Existing data stays visible during filter/append requests.
- No polling, timer, or realtime subscription.

## UI and errors

Preserve the existing screen layout. Use API counters, area chips, issue properties, network avatar with asset fallback, and safe dynamic colors. A date sheet supports all presets and a custom UTC range. Use one lazy list/sliver tree rather than spreading every issue widget.

- Initial failure: existing full-page core error widget with retry.
- Empty success: existing empty-state treatment with localized support copy.
- Filter/search failure with data: retain data and show one SnackBar.
- Pagination failure: retain data and show an inline retry footer.

## Performance and verification

No client-side filtering. Debounce search, prevent duplicate page requests, discard stale responses, normalize dates/colors outside `build`, use lazy construction and narrow Bloc rebuilds. Tests cover DTO aliases/nullability, mapping, query forwarding, repository failures, ViewModel concurrency/debounce/pagination, and all UI states. Run build_runner, localization generation, formatter, analyzer, targeted tests, and the full suite.

