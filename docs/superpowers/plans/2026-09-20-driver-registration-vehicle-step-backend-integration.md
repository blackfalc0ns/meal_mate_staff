# Driver Registration Vehicle Step Backend Integration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make registration step 2 load backend vehicle catalogs and submit validated user-entered vehicle, license, and expiry data in the exact backend contract.

**Architecture:** Extend the existing Feature-Based Clean Architecture flow (`ApiServices -> RemoteDataSource -> Repository -> UseCase -> ViewModel -> UI`). Catalog responses stay nullable DTOs, map into domain entities, and the UI stores backend codes/HEX values while displaying localized labels.

**Tech Stack:** Flutter, flutter_bloc, Dio, Retrofit, json_serializable, Injectable/GetIt, flutter_test.

**Spec:** `C:/Users/orignal store/.codex/attachments/880cbc5c-c5a1-4a83-b97f-50ad075b6b9b/pasted-text.txt`

## Global Constraints

- Follow `rules/rules_backend.md` and preserve the existing UI structure.
- Use the existing `ApiServices`, `safeApiCall`, `ApiResult`, Injectable, repository, and ViewModel flow.
- Do not manually edit generated `*.g.dart` or `di.config.dart`; regenerate with build_runner.
- Send vehicle type codes (`Car`, `Motorcycle`, `Van`, `Bicycle`) and color as uppercase `#RRGGBB`.
- Required dates must be strictly later than today; contract expiry remains optional.
- Each task follows red-green-refactor and preserves unrelated worktree changes.

---

### Task 1: Vehicle catalog contracts and serialization

**Files:**
- Modify: `lib/core/network/network_constants.dart`
- Modify: `lib/core/network/api_services.dart`
- Create: `lib/features/register/data/models/response/driver_vehicle_type_response_dto.dart`
- Create: `lib/features/register/data/models/response/driver_vehicle_color_response_dto.dart`
- Create: `lib/features/register/data/models/response/driver_vehicle_model_response_dto.dart`
- Create: `lib/features/register/domain/entities/driver_vehicle_type_entity.dart`
- Create: `lib/features/register/domain/entities/driver_vehicle_color_entity.dart`
- Create: `lib/features/register/domain/entities/driver_vehicle_model_entity.dart`
- Modify: `lib/features/register/data/mapper/driver_registration_mapper.dart`
- Test: `test/features/register/data/driver_vehicle_catalog_dto_and_mapper_test.dart`

**Interfaces:**
- Produces: `getDriverVehicleTypes()`, `getDriverVehicleColors()`, and `searchDriverVehicleModels({String? search, String? vehicleType, int limit = 40})` on `ApiServices`.
- Produces: nullable response DTOs and non-null domain entities with `code/value`, localized names, and HEX values.

- [ ] Write DTO/mapper tests using literal backend fixtures and assert defensive null mapping.
- [ ] Run `flutter test test/features/register/data/driver_vehicle_catalog_dto_and_mapper_test.dart` and verify missing classes/methods fail compilation.
- [ ] Add constants for `/vehicle-types`, `/vehicle-colors`, and `/vehicle-models`; add Retrofit GET methods with `@Query` parameters.
- [ ] Add `@JsonSerializable()` DTOs and mapper extensions; keep all backend response fields nullable.
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`.
- [ ] Re-run the DTO/mapper test and require a pass.

### Task 2: Catalog data flow through Clean Architecture

**Files:**
- Modify: `lib/features/register/data/data_source/driver_registration_remote_data_source.dart`
- Modify: `lib/features/register/data/data_source/driver_registration_remote_data_source_impl.dart`
- Modify: `lib/features/register/domain/repo/driver_registration_repository.dart`
- Modify: `lib/features/register/data/repo/driver_registration_repository_impl.dart`
- Create: `lib/features/register/domain/usecase/get_driver_vehicle_types_usecase.dart`
- Create: `lib/features/register/domain/usecase/get_driver_vehicle_colors_usecase.dart`
- Create: `lib/features/register/domain/usecase/search_driver_vehicle_models_usecase.dart`
- Test: `test/features/register/domain/driver_vehicle_catalog_usecases_test.dart`
- Test: `test/features/register/data/driver_registration_repository_impl_test.dart`

**Interfaces:**
- Consumes: Task 1 DTOs, entities, mappers, and Retrofit methods.
- Produces: repository methods returning `ApiResult<List<DriverVehicleTypeEntity>>`, `ApiResult<List<DriverVehicleColorEntity>>`, and `ApiResult<List<DriverVehicleModelEntity>>`.

- [ ] Write failing use-case and repository tests that assert parameters, mapping, and typed failures.
- [ ] Run both test files and verify failures are caused by missing catalog methods.
- [ ] Add data-source contracts/implementations delegating only to `ApiServices`.
- [ ] Add repository contracts/implementations using `safeApiCall` and mapper extensions.
- [ ] Add three injectable use cases with constructor-injected repository dependencies.
- [ ] Run the two test files and require all tests to pass.

### Task 3: ViewModel catalog state and model search

**Files:**
- Modify: `lib/features/register/presentation/manager/driver_registration_event.dart`
- Modify: `lib/features/register/presentation/manager/driver_registration_state.dart`
- Modify: `lib/features/register/presentation/manager/driver_registration_view_model.dart`
- Modify: `lib/features/register/presentation/screens/register_screen.dart`
- Test: `test/features/register/presentation/driver_registration_view_model_test.dart`

**Interfaces:**
- Consumes: Task 2 use cases.
- Produces: load-catalog events, a model-search event carrying `search` and `vehicleType`, and state lists for types/colors/models plus catalog loading/failure state.

- [ ] Add failing ViewModel tests for initial catalog loading, model search parameter forwarding, success data, and preserved form data on failure.
- [ ] Run the focused ViewModel tests and verify expected failures.
- [ ] Inject the three catalog use cases, handle events, and expose entity lists in immutable state.
- [ ] Dispatch type/color loads from `RegisterScreen`; keep errors inline without duplicate toast behavior.
- [ ] Regenerate Injectable output with build_runner.
- [ ] Re-run focused ViewModel tests and require a pass.

### Task 4: Exact vehicle values, dates, and validation

**Files:**
- Modify: `lib/features/register/domain/register_vehicle_data.dart`
- Modify: `lib/features/register/presentation/screens/register_vehicle_data_screen.dart`
- Modify: `lib/features/register/presentation/widgets/register_vehicle_color_picker.dart`
- Modify: `lib/features/register/presentation/manager/driver_registration_view_model.dart`
- Modify: `lib/core/helpers/validators.dart`
- Modify: `lib/core/l10n/app_ar.arb`
- Modify: `lib/core/l10n/app_en.arb`
- Test: `test/features/register/presentation/register_vehicle_data_screen_test.dart`
- Test: `test/features/register/presentation/driver_registration_view_model_test.dart`

**Interfaces:**
- Consumes: catalog entities/state from Task 3.
- Produces: `RegisterVehicleData` containing backend vehicle type code, selected model value, uppercase `#RRGGBB`, required ISO expiry dates, and optional contract expiry.

- [ ] Add failing widget tests proving selected labels submit backend codes/values, model search waits 300 ms, `#RRGGBB` excludes alpha, entered plate/license are preserved, and blank/past required dates block continuation.
- [ ] Add failing validator tests for year range `1990..currentYear + 1` and strictly future ISO dates.
- [ ] Run focused tests and verify failures match missing behaviors.
- [ ] Replace fake vehicle types with state-provided localized catalog choices while storing `code`.
- [ ] Implement model typeahead with a cancellable 300 ms `Timer`; store response `value` in `vehicleModel`.
- [ ] Render backend default colors first, provide an “Other” dialog with an accessible HEX input and preview, normalize through `#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}`.
- [ ] Add Date Picker fields/controllers for `licenseExpiry`, `vehicleLicenseExpiry`, and optional `contractExpiry`; serialize dates as ISO 8601 and validate future dates.
- [ ] Remove generated default expiry dates from both screen and ViewModel; never invent missing required backend data.
- [ ] Add explicit manufacturing-year validation and keep plate/license required.
- [ ] Regenerate localization output, then run focused tests until green.

### Task 5: Full regression and generated-code verification

**Files:**
- Verify all modified registration and generated files.

**Interfaces:**
- Consumes: Tasks 1-4.
- Produces: verified end-to-end step 2 payload matching the backend example.

- [ ] Add/extend a serialization regression asserting `vehicleType: Car`, `vehicleModel: Toyota Camry`, `vehicleColor: #5E35B1`, user-entered license/plate, ISO expiries, and null contract expiry.
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`.
- [ ] Run `flutter test test/features/register test/register_screen_test.dart test/register_plate_number_field_test.dart`.
- [ ] Run `flutter analyze` and require zero issues.
- [ ] Run `git diff --check` and review the diff to confirm no generated file was manually edited and no unrelated changes were overwritten.
