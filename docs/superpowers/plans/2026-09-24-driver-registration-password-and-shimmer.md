# Driver Registration Password and Shimmer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make new-driver registration send the backend-required `password` field and use registration-specific shimmer placeholders for asynchronous loading states.

**Architecture:** Keep the existing feature-based Clean Architecture path: the personal-data form creates a `RegisterPersonalData`, the view model copies it into `DriverRegistrationDraftEntity`, the mapper creates `DriverRegistrationRequestDto`, and the existing repository/data-source/API stack submits it. Add loading booleans to registration state for concurrently loaded catalogs, and render focused shimmer widgets built from the shared `ShimmerWidget`; preserve the existing `Failure` and `InlineApiErrorWidget` error path.

**Tech Stack:** Flutter, Dart 3, flutter_bloc, Retrofit, json_serializable/build_runner, flutter_test.

**Spec:** Approved bounded design from the 2026-09-24 conversation; no separate design document was required.

## Global Constraints

- Follow `rules/rules_backend.md` and preserve the existing UI, naming, navigation, dependency injection, Retrofit client, repository, use-case, and view-model architecture.
- Use the existing `lib/core/errors`/`Failure`/`ApiResult` handling. Do not catch Dio exceptions in widgets or replace failures with ad-hoc strings.
- `password` is required only for a new registration request. Do not add it to `DriverResubmitEntity` or `DriverResubmitRequestDto` unless the backend contract changes separately.
- Never log, persist, display in review data, or include `password` in equality/debug output. Keep it only in memory until submission.
- Use the existing `Validations.validatePassword` rules: non-empty and matching `AppRegExp.isPasswordValid` (8+ characters, number, uppercase letter, and symbol according to the current localized message).
- Reuse `lib/core/widget/shimmer_widget.dart`; do not add a shimmer dependency.
- Do not edit generated `.g.dart` or localization Dart files manually. Run Flutter localization generation/build_runner.
- Preserve unrelated working-tree changes, especially the current active-delivery and localization edits.
- Follow TDD for every behavioral change: add one focused failing test, run it and confirm the expected failure, add minimal production code, then rerun.

## File Map

**Create**

- `lib/features/register/presentation/widgets/register_personal_data_shimmer.dart` — skeleton matching the personal-data step while restaurants/nationalities load.
- `lib/features/register/presentation/widgets/register_vehicle_catalog_shimmer.dart` — compact placeholders for vehicle type/color catalog loading and model search.
- `lib/features/register/presentation/widgets/register_submission_shimmer.dart` — non-dismissible submission overlay content built with `ShimmerWidget`.
- `test/features/register/presentation/register_personal_data_screen_test.dart` — password field, visibility, and validation widget coverage.
- `test/features/register/presentation/register_screen_loading_test.dart` — registration shimmer routing and absence of progress indicators.

**Modify**

- `lib/features/register/domain/register_personal_data.dart` — carry the in-memory password from the form.
- `lib/features/register/domain/entities/driver_registration_draft_entity.dart` — make password part of new-registration readiness and mapping input.
- `lib/features/register/data/models/request/driver_registration_request_dto.dart` — required backend `password` property.
- `lib/features/register/data/models/request/driver_registration_request_dto.g.dart` — generated only by build_runner.
- `lib/features/register/data/mapper/driver_registration_mapper.dart` — map draft password into the request DTO.
- `lib/features/register/presentation/controllers/register_personal_data_form_controller.dart` — own/dispose password controller and emit it.
- `lib/features/auth/presentation/widgets/registration_input_field.dart` — support `obscureText` without changing existing call sites.
- `lib/features/register/presentation/widgets/register_personal_info_section.dart` — password input, visibility toggle, and localized validation.
- `lib/features/register/presentation/screens/register_personal_data_screen.dart` — accept catalog loading and render the personal-data shimmer.
- `lib/features/register/presentation/screens/register_vehicle_data_screen.dart` — replace top linear progress with catalog shimmer.
- `lib/features/register/presentation/widgets/register_vehicle_specs_section.dart` — replace model-search linear progress with shimmer.
- `lib/features/register/presentation/screens/register_screen.dart` — forward loading flags and replace submit spinner with shimmer overlay.
- `lib/features/register/presentation/manager/driver_registration_state.dart` — independent restaurant/nationality loading flags.
- `lib/features/register/presentation/manager/driver_registration_view_model.dart` — preserve password and manage independent loading flags.
- `test/features/register/data/driver_registration_dto_and_mapper_test.dart` — request JSON and mapper assertions.
- `test/features/register/presentation/driver_registration_view_model_test.dart` — password propagation/readiness and concurrent loading assertions.
- `test/features/register/presentation/register_vehicle_data_screen_test.dart` — vehicle shimmer assertions.

---

### Task 1: Add Password to the Domain-to-DTO Request Pipeline

**Files:**

- Modify: `lib/features/register/domain/register_personal_data.dart`
- Modify: `lib/features/register/domain/entities/driver_registration_draft_entity.dart`
- Modify: `lib/features/register/data/models/request/driver_registration_request_dto.dart`
- Modify: `lib/features/register/data/mapper/driver_registration_mapper.dart`
- Generate: `lib/features/register/data/models/request/driver_registration_request_dto.g.dart`
- Test: `test/features/register/data/driver_registration_dto_and_mapper_test.dart`

**Interfaces:**

- Produces: `RegisterPersonalData.password`, `DriverRegistrationDraftEntity.password`, and `DriverRegistrationRequestDto.password`, all non-nullable `String` values defaulting to `''` only in editable domain state.
- Produces: JSON key/value `'password': instance.password` for new registration.
- Consumes: existing `DriverRegistrationDraftEntityMapper.toDto()`.

- [ ] **Step 1: Write a failing DTO serialization test**

Add `password: 'Password123!'` to the existing complete `DriverRegistrationRequestDto` fixture and assert:

```dart
final json = dto.toJson();

expect(json['password'], 'Password123!');
expect(json.keys.where((key) => key == 'password'), hasLength(1));
```

Also add a mapper assertion using a draft with `password: 'Password123!'`:

```dart
final dto = draft.toDto();

expect(dto.password, 'Password123!');
expect(dto.toJson()['password'], 'Password123!');
```

- [ ] **Step 2: Run the focused test and confirm RED**

Run:

```bash
flutter test test/features/register/data/driver_registration_dto_and_mapper_test.dart
```

Expected: compile failure because the DTO/draft constructors do not accept `password`, or assertion failure because JSON lacks `password`.

- [ ] **Step 3: Add password to the domain objects**

In `RegisterPersonalData`, add:

```dart
this.password = '',
// ...
final String password;
```

Carry it through `empty` implicitly, add `String? password` to `copyWith`, and assign `password: password ?? this.password`.

In `DriverRegistrationDraftEntity`, add:

```dart
this.password = '',
// ...
final String password;
```

Require it in readiness:

```dart
bool get hasRequiredPersonalData =>
    restaurantId.trim().isNotEmpty &&
    fullNameAr.trim().isNotEmpty &&
    fullNameEn.trim().isNotEmpty &&
    phone.trim().isNotEmpty &&
    password.trim().isNotEmpty &&
    nationalId.trim().isNotEmpty &&
    nationalIdExpiry.trim().isNotEmpty &&
    nationality.trim().isNotEmpty;
```

Carry it from `toPersonalData()` and through `copyWith`. Do **not** add password to `toResubmitEntity()`.

- [ ] **Step 4: Add the required DTO property and mapper assignment**

Add immediately after phone in `DriverRegistrationRequestDto`:

```dart
required this.password,
// ...
final String password;
```

Map it in `DriverRegistrationDraftEntityMapper.toDto()`:

```dart
phone: phone,
password: password,
email: (email != null && email!.trim().isNotEmpty) ? email!.trim() : null,
```

- [ ] **Step 5: Generate serialization code**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Inspect the generated DTO code and confirm both directions contain exactly one password mapping:

```dart
password: json['password'] as String,
// ...
'password': instance.password,
```

- [ ] **Step 6: Run the focused tests and confirm GREEN**

Run:

```bash
flutter test test/features/register/data/driver_registration_dto_and_mapper_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit the request-contract change**

```bash
git add lib/features/register/domain/register_personal_data.dart lib/features/register/domain/entities/driver_registration_draft_entity.dart lib/features/register/data/models/request/driver_registration_request_dto.dart lib/features/register/data/models/request/driver_registration_request_dto.g.dart lib/features/register/data/mapper/driver_registration_mapper.dart test/features/register/data/driver_registration_dto_and_mapper_test.dart
git commit -m "feat: include password in driver registration request"
```

---

### Task 2: Collect and Validate the Password in the Personal-Data Form

**Files:**

- Modify: `lib/features/auth/presentation/widgets/registration_input_field.dart`
- Modify: `lib/core/l10n/app_ar.arb`
- Modify: `lib/core/l10n/app_en.arb`
- Generate: `lib/core/l10n/translations/app_localizations.dart`
- Generate: `lib/core/l10n/translations/app_localizations_ar.dart`
- Generate: `lib/core/l10n/translations/app_localizations_en.dart`
- Modify: `lib/features/register/presentation/controllers/register_personal_data_form_controller.dart`
- Modify: `lib/features/register/presentation/widgets/register_personal_info_section.dart`
- Create: `test/features/register/presentation/register_personal_data_screen_test.dart`

**Interfaces:**

- Consumes: `RegisterPersonalData.password` from Task 1.
- Produces: `RegistrationInputField.obscureText` with default `false` and optional `fieldKey` forwarded to its `TextFormField`.
- Produces: a password field using existing localized `passwordLabel`, `passwordHint`, and `context.validatePassword`.

- [ ] **Step 1: Write a failing widget test for the password field**

Build `RegisterPersonalDataScreen` inside the repository's localized test wrapper with non-empty restaurant/nationality fixtures. Assert:

```dart
expect(find.text('Password'), findsOneWidget);

final passwordField = tester.widget<TextFormField>(
  find.byKey(const Key('driver_registration_password_field')),
);
expect(passwordField.obscureText, isTrue);
```

Use a stable `fieldKey` on `RegistrationInputField` rather than selecting the field by index.

- [ ] **Step 2: Write failing validation and visibility tests**

Add one test that taps Continue with an empty password and expects the localized `validationPasswordRequired` text. Add another that enters `Password123!`, taps the eye suffix, and verifies the keyed `TextFormField.obscureText` changes from `true` to `false` without losing the value.

- [ ] **Step 3: Run the widget tests and confirm RED**

Run:

```bash
flutter test test/features/register/presentation/register_personal_data_screen_test.dart
```

Expected: failure because no password field/obscuring support exists.

- [ ] **Step 4: Add generic obscuring support to RegistrationInputField**

Add a backwards-compatible constructor property:

```dart
this.obscureText = false,
this.fieldKey,
// ...
final bool obscureText;
final Key? fieldKey;
```

Pass it to `TextFormField`:

```dart
key: fieldKey,
obscureText: obscureText,
```

Do not change existing callers.

- [ ] **Step 5: Own the password controller in the form controller**

Initialize, declare, dispose, and emit the controller:

```dart
password = TextEditingController(text: initialData?.password ?? '');
late final TextEditingController password;
// dispose(): password.dispose();
// toPersonalData(): password: password.text,
```

Do not trim or normalize the password; spaces may be meaningful and validation already controls acceptance.

- [ ] **Step 6: Render the secure field and visibility toggle**

Convert `RegisterPersonalInfoSection` to a `StatefulWidget` with `_obscurePassword = true`. Insert the password field after phone and before optional email:

```dart
RegistrationInputField(
  fieldKey: const Key('driver_registration_password_field'),
  label: locale.passwordLabel,
  hint: locale.passwordHint,
  controller: widget.formController.password,
  obscureText: _obscurePassword,
  suffixIcon: _obscurePassword
      ? Icons.visibility_off_outlined
      : Icons.visibility_outlined,
  suffixTooltip: _obscurePassword
      ? locale.showPassword
      : locale.hidePassword,
  onSuffixTap: () {
    setState(() => _obscurePassword = !_obscurePassword);
  },
  validator: context.validatePassword,
),
```

Add these exact ARB entries because the project does not currently provide password-visibility tooltips:

```json
// app_en.arb
"showPassword": "Show password",
"hidePassword": "Hide password"
```

```json
// app_ar.arb
"showPassword": "إظهار كلمة المرور",
"hidePassword": "إخفاء كلمة المرور"
```

Run `flutter gen-l10n` and do not edit the generated localization Dart files manually. Because the localization files already have unrelated working-tree changes, inspect the diff and stage only these two ARB key additions plus the generated hunks attributable to them.

- [ ] **Step 7: Run the widget tests and confirm GREEN**

Run:

```bash
flutter test test/features/register/presentation/register_personal_data_screen_test.dart
```

Expected: PASS with required, complexity, obscuring, and toggle behavior covered.

- [ ] **Step 8: Commit the form change**

```bash
git add lib/features/auth/presentation/widgets/registration_input_field.dart lib/features/register/presentation/controllers/register_personal_data_form_controller.dart lib/features/register/presentation/widgets/register_personal_info_section.dart test/features/register/presentation/register_personal_data_screen_test.dart lib/core/l10n/app_ar.arb lib/core/l10n/app_en.arb lib/core/l10n/translations
git commit -m "feat: collect driver password during registration"
```

Only stage localization files if this task actually changed them; never stage unrelated pre-existing localization edits.

---

### Task 3: Preserve Password Through View-Model Updates and Submission

**Files:**

- Modify: `lib/features/register/presentation/manager/driver_registration_view_model.dart`
- Modify: `test/features/register/presentation/driver_registration_view_model_test.dart`

**Interfaces:**

- Consumes: `RegisterPersonalData.password` and `DriverRegistrationDraftEntity.password`.
- Produces: `_handlePersonalDataUpdated` copies password into the draft; submit passes a ready draft through the existing use case unchanged.

- [ ] **Step 1: Write a failing personal-data propagation test**

Extend the existing `DriverRegistrationPersonalDataUpdatedEvent` test fixture:

```dart
const personalData = RegisterPersonalData(
  // existing required values...
  password: 'Password123!',
);

viewModel.doIntent(
  const DriverRegistrationPersonalDataUpdatedEvent(personalData),
);

expect(viewModel.state.draft.password, 'Password123!');
```

- [ ] **Step 2: Write a failing readiness/submission test**

Create an otherwise complete draft with `password: ''` and assert `isReadyForSubmission` is false. Then use `password: 'Password123!'`, submit through the existing fake repository/use-case fixture, and assert the captured `DriverRegistrationDraftEntity.password` is exactly `Password123!`.

- [ ] **Step 3: Run the focused view-model tests and confirm RED**

Run:

```bash
flutter test test/features/register/presentation/driver_registration_view_model_test.dart
```

Expected: the update test fails because `_handlePersonalDataUpdated` currently drops password.

- [ ] **Step 4: Copy the password in the existing handler**

Add to `_handlePersonalDataUpdated`:

```dart
password: personalData.password,
```

Keep the handler typed as `RegisterPersonalData` if practical; replacing the current `dynamic` parameter with `RegisterPersonalData` is allowed because the event already provides that exact type and improves type safety without changing behavior.

- [ ] **Step 5: Verify success and failure behavior**

Run:

```bash
flutter test test/features/register/presentation/driver_registration_view_model_test.dart test/features/register/domain/driver_registration_usecases_test.dart
```

Expected: PASS. Existing `ApiErrorResult(:final failure)` branches must remain unchanged and continue emitting `Failure` to the UI.

- [ ] **Step 6: Commit view-model propagation**

```bash
git add lib/features/register/presentation/manager/driver_registration_view_model.dart test/features/register/presentation/driver_registration_view_model_test.dart
git commit -m "test: verify driver password submission flow"
```

---

### Task 4: Replace Registration Loading Indicators with Shimmer

**Files:**

- Create: `lib/features/register/presentation/widgets/register_personal_data_shimmer.dart`
- Create: `lib/features/register/presentation/widgets/register_vehicle_catalog_shimmer.dart`
- Create: `lib/features/register/presentation/widgets/register_submission_shimmer.dart`
- Modify: `lib/features/register/presentation/manager/driver_registration_state.dart`
- Modify: `lib/features/register/presentation/manager/driver_registration_view_model.dart`
- Modify: `lib/features/register/presentation/screens/register_personal_data_screen.dart`
- Modify: `lib/features/register/presentation/screens/register_vehicle_data_screen.dart`
- Modify: `lib/features/register/presentation/widgets/register_vehicle_specs_section.dart`
- Modify: `lib/features/register/presentation/screens/register_screen.dart`
- Test: `test/features/register/presentation/driver_registration_view_model_test.dart`
- Test: `test/features/register/presentation/register_vehicle_data_screen_test.dart`
- Create: `test/features/register/presentation/register_screen_loading_test.dart`

**Interfaces:**

- Produces: `DriverRegistrationState.isLoadingRestaurants` and `.isLoadingNationalities` booleans, matching the existing vehicle loading flags.
- Produces: `RegisterPersonalDataShimmer`, `RegisterVehicleCatalogShimmer`, and `RegisterSubmissionShimmer`, each composed only from `ShimmerWidget` and layout primitives.
- Preserves: `Failure` rendering through `InlineApiErrorWidget`; shimmer disappears before an error is rendered.

- [ ] **Step 1: Write failing state concurrency tests**

Use completers in the existing view-model test fakes. Dispatch restaurant and nationality loads concurrently and assert both flags can be true independently. Complete only restaurants and assert:

```dart
expect(viewModel.state.isLoadingRestaurants, isFalse);
expect(viewModel.state.isLoadingNationalities, isTrue);
```

Complete nationalities and assert both are false. Add error cases proving each flag returns to false when its use case returns `ApiErrorResult` and `state.failure` remains the original `Failure` object.

- [ ] **Step 2: Run the state tests and confirm RED**

Run:

```bash
flutter test test/features/register/presentation/driver_registration_view_model_test.dart
```

Expected: failure because restaurant/nationality loading is currently represented by one shared status.

- [ ] **Step 3: Add independent personal-catalog loading flags**

In `DriverRegistrationState`, add constructor fields, properties, and `copyWith` parameters:

```dart
this.isLoadingRestaurants = false,
this.isLoadingNationalities = false,
// ...
final bool isLoadingRestaurants;
final bool isLoadingNationalities;
```

Remove the existing computed `isLoadingRestaurants` getter. In `_handleLoadRestaurants` and `_handleLoadNationalities`, set the matching flag true before awaiting and false in both success and error cases. Status values may remain for compatibility, but UI loading decisions must use the booleans so concurrent requests cannot overwrite one another.

- [ ] **Step 4: Run the state tests and confirm GREEN**

Run:

```bash
flutter test test/features/register/presentation/driver_registration_view_model_test.dart
```

Expected: PASS, including concurrent completion order and error-reset cases.

- [ ] **Step 5: Write failing shimmer widget tests**

For personal loading, pump the registration screen with pending restaurant/nationality use cases and assert:

```dart
expect(find.byType(RegisterPersonalDataShimmer), findsOneWidget);
expect(find.byType(ShimmerWidget), findsWidgets);
expect(find.byType(CircularProgressIndicator), findsNothing);
expect(find.byType(LinearProgressIndicator), findsNothing);
```

For vehicle loading, extend `register_vehicle_data_screen_test.dart` to assert `RegisterVehicleCatalogShimmer` appears when type/color loading is true. For model search, assert a compact `ShimmerWidget` appears below the model field. For submit, assert `RegisterSubmissionShimmer` and the non-dismissible `ModalBarrier` appear and `CustomProgressIndicator` does not.

- [ ] **Step 6: Run the UI loading tests and confirm RED**

Run:

```bash
flutter test test/features/register/presentation/register_screen_loading_test.dart test/features/register/presentation/register_vehicle_data_screen_test.dart
```

Expected: failure because the existing UI renders linear/custom progress indicators.

- [ ] **Step 7: Implement focused shimmer widgets**

Build all placeholders using the shared widget, for example:

```dart
const ShimmerWidget(height: Spacing.registrationFieldInputHeight),
```

`RegisterPersonalDataShimmer` should preserve the registration scaffold/header and approximate the workplace, personal, and identity cards with label bars and field-height bars. `RegisterVehicleCatalogShimmer` should be compact enough to sit above the vehicle form without hiding already entered values. `RegisterSubmissionShimmer` should be a centered surface card containing two or three shimmer bars; it must not expose or mimic the password value.

- [ ] **Step 8: Route loading states to shimmer**

Pass personal flags from `RegisterScreen`:

```dart
isLoadingCatalogs:
    state.isLoadingRestaurants || state.isLoadingNationalities,
```

In `RegisterPersonalDataScreen`, render `RegisterPersonalDataShimmer` while `isLoadingCatalogs` is true. In `RegisterVehicleDataScreen`, replace the top `LinearProgressIndicator` with `RegisterVehicleCatalogShimmer`. In `RegisterVehicleSpecsSection`, replace the model-search `LinearProgressIndicator` with a small `ShimmerWidget` of the same available width. In `RegisterScreen`, keep the `ModalBarrier` but replace `CustomProgressIndicator` with `RegisterSubmissionShimmer` and remove the obsolete import.

- [ ] **Step 9: Keep errors visible and retryable**

Confirm all load handlers clear only their own loading flag on error and still emit the backend `Failure`. Do not replace `InlineApiErrorWidget` in personal/vehicle/documents screens. A failed request must show the existing error widget after shimmer disappears; retry callbacks must continue to dispatch the existing retry/load events.

- [ ] **Step 10: Run shimmer tests and confirm GREEN**

Run:

```bash
flutter test test/features/register/presentation/register_screen_loading_test.dart test/features/register/presentation/register_vehicle_data_screen_test.dart test/features/register/presentation/driver_registration_view_model_test.dart
```

Expected: PASS and no `CircularProgressIndicator`, `LinearProgressIndicator`, or `CustomProgressIndicator` remains in the tested registration loading paths.

- [ ] **Step 11: Commit loading-state changes**

```bash
git add lib/features/register/presentation/manager/driver_registration_state.dart lib/features/register/presentation/manager/driver_registration_view_model.dart lib/features/register/presentation/screens/register_personal_data_screen.dart lib/features/register/presentation/screens/register_vehicle_data_screen.dart lib/features/register/presentation/widgets/register_vehicle_specs_section.dart lib/features/register/presentation/screens/register_screen.dart lib/features/register/presentation/widgets/register_personal_data_shimmer.dart lib/features/register/presentation/widgets/register_vehicle_catalog_shimmer.dart lib/features/register/presentation/widgets/register_submission_shimmer.dart test/features/register/presentation/driver_registration_view_model_test.dart test/features/register/presentation/register_vehicle_data_screen_test.dart test/features/register/presentation/register_screen_loading_test.dart
git commit -m "feat: use shimmer for driver registration loading"
```

---

### Task 5: Final Contract, Error, and Regression Verification

**Files:**

- Verify: `lib/core/network/api_services.dart`
- Verify: `lib/features/register/data/data_source/driver_registration_remote_data_source_impl.dart`
- Verify: `lib/features/register/data/repo/driver_registration_repository_impl.dart`
- Verify: `lib/features/register/domain/usecase/submit_driver_registration_usecase.dart`
- Verify: all files changed in Tasks 1–4.

**Interfaces:**

- Verifies: final backend body contains required `password` once and otherwise matches the supplied contract.
- Verifies: API errors still flow as `ApiResult`/`Failure` into `InlineApiErrorWidget`.
- Verifies: resubmission payload remains unchanged and contains no password.

- [ ] **Step 1: Add or update the endpoint request-body assertion**

In the most focused existing API/data-source test (`test/core/network/api_services_test.dart` or the registration repository test), capture the serialized request and assert the required subset:

```dart
expect(body, containsPair('restaurantId', '898259c1-4064-434e-ad20-be885987d8cb'));
expect(body, containsPair('phone', '+96551234001'));
expect(body, containsPair('password', 'Password123!'));
expect(body, containsPair('vehicleType', 'Car'));
```

Also assert nullable `email` and `contractExpiry` remain JSON null when absent, and storage keys are serialized without altering slashes/underscores.

- [ ] **Step 2: Verify the endpoint test fails before updating any stale fixture**

Run the exact focused test selected in Step 1. Expected initial result: FAIL if its request fixture has not yet supplied password. Update only the fixture/expected body needed for the new required contract, then rerun to PASS.

- [ ] **Step 3: Verify resubmission does not leak password**

Run:

```bash
flutter test test/features/register/resubmit_driver_registration_test.dart
```

Expected: PASS. Where the test inspects JSON, add:

```dart
expect(body.containsKey('password'), isFalse);
```

- [ ] **Step 4: Format and analyze only after tests are green**

Run:

```bash
dart format lib/features/register lib/features/auth/presentation/widgets/registration_input_field.dart test/features/register
flutter analyze
```

Expected: formatting completes and analyzer reports no new issues. Do not fix unrelated pre-existing warnings without explicit scope approval.

- [ ] **Step 5: Run the complete relevant regression suite**

Run:

```bash
flutter test test/features/register test/core/helpers/validators_test.dart test/core/network/api_services_test.dart
```

Expected: all tests PASS.

- [ ] **Step 6: Inspect the generated request contract**

Run:

```bash
rg -n "password|DriverRegistrationRequestDto" lib/features/register/data/models/request/driver_registration_request_dto.dart lib/features/register/data/models/request/driver_registration_request_dto.g.dart lib/features/register/data/mapper/driver_registration_mapper.dart
rg -n "CircularProgressIndicator|LinearProgressIndicator|CustomProgressIndicator" lib/features/register
```

Expected:

- `password` appears in the request DTO constructor/property, generated `fromJson`/`toJson`, and draft mapper.
- No password appears in driver resubmit DTO/entity files.
- No old progress indicator remains in registration loading code; document upload progress UI may remain only if it is determinate task progress rather than a loading placeholder.

- [ ] **Step 7: Review the diff for secrets and unrelated files**

Run:

```bash
git diff --check
git status --short
git diff -- lib/features/register lib/features/auth/presentation/widgets/registration_input_field.dart test/features/register test/core/network/api_services_test.dart
```

Confirm no real password, token, driver identity document, or local storage key was committed; test values such as `Password123!` are synthetic fixtures only. Confirm unrelated active-delivery and pre-existing localization changes were not staged.

- [ ] **Step 8: Commit final verification updates**

```bash
git add test/core/network/api_services_test.dart test/features/register/resubmit_driver_registration_test.dart
git commit -m "test: cover driver registration backend contract"
```

Skip this commit if Step 1 required no test-file change.

## Acceptance Checklist

- [ ] A valid password is required before leaving the personal-data step.
- [ ] The password field is obscured by default and can be shown/hidden accessibly.
- [ ] The password survives form → event → draft → mapper → DTO and is serialized exactly once as `password`.
- [ ] The password is never included in review UI, logs, persisted storage, resubmission payloads, or error messages.
- [ ] The exact sample body shape is supported, including nullable email/contract expiry and all provided storage-key fields.
- [ ] Concurrent restaurant, nationality, vehicle type, and vehicle color loads have independent flags.
- [ ] Registration loading uses `ShimmerWidget`; errors use the existing `Failure` and `InlineApiErrorWidget` flow.
- [ ] Generated files were produced by build_runner/localization tools, not hand-edited.
- [ ] Focused tests, registration regression tests, `flutter analyze`, and `git diff --check` pass.
