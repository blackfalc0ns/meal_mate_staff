backend_integration_clean_architecture_rules_updated.md


# Backend Integration & Clean Architecture Rules

These rules are mandatory when integrating any backend API into this Flutter project.

They extend the existing UI/Figma rules in `AGENTS.md`.

The existing project architecture, UI implementation, naming conventions, theme, localization, widgets, navigation, and shared code must be preserved.

---

# 1. Main Goal

When integrating backend APIs:

* Do not redesign the UI.
* Do not change existing screens unless required for backend integration.
* Do not change unrelated features.
* Do not replace the project architecture.
* Do not introduce a new architecture.
* Follow Feature-Based Clean Architecture.
* Use the existing Core networking and dependency injection setup.
* Reuse the existing `Dio`, `Retrofit`, `ApiResult`, `safeApiCall`, error handling, interceptors, GetIt, and Injectable setup.
* Never bypass an architecture layer just to make the API work faster.

The expected flow is:

```text
UI
↓
Event
↓
ViewModel / Cubit
↓
UseCase
↓
Repository Contract
↓
Repository Implementation
↓
Remote Data Source
↓
ApiServices
↓
Backend API
```

The response returns through:

```text
Backend Response
↓
Response DTO
↓
Mapper
↓
Domain Entity
↓
ApiResult<Entity>
↓
UseCase
↓
ViewModel
↓
State
↓
UI
```

---

# 2. Feature Folder Structure

Backend-enabled features must follow this structure.

Example feature:

```text
lib/features/profile/
│
├── data/
│   │
│   ├── data_source/
│   │   ├── profile_remote_data_source.dart
│   │   └── profile_remote_data_source_impl.dart
│   │
│   ├── mapper/
│   │   └── profile_mapper.dart
│   │
│   ├── models/
│   │   ├── request/
│   │   │   └── update_profile_request_dto.dart
│   │   │
│   │   └── response/
│   │       └── profile_response_dto.dart
│   │
│   └── repo/
│       └── profile_repository_impl.dart
│
├── domain/
│   │
│   ├── entities/
│   │   ├── profile_entity.dart
│   │   └── update_profile_request_entity.dart
│   │
│   ├── repo/
│   │   └── profile_repository.dart
│   │
│   └── usecase/
│       ├── get_profile_usecase.dart
│       └── update_profile_usecase.dart
│
└── presentation/
    │
    ├── manager/
    │   ├── profile_view_model.dart
    │   ├── profile_event.dart
    │   └── profile_state.dart
    │
    ├── screens/
    │   └── ...
    │
    └── widgets/
        └── ...
```

Do not create all folders blindly.

Only create folders/files required by the feature.

For example, if the feature has no request body, do not create an empty `request/` folder.

However, when a complete backend feature requires these layers, do not skip them.

---

# 3. Existing Features

Some existing features currently contain only:

```text
presentation/
```

or:

```text
data/
domain/
presentation/
```

with fake data.

When connecting an existing feature to the backend:

* Keep its current UI.
* Keep its current widgets.
* Keep existing domain entities when they correctly represent the business model.
* Add the missing Clean Architecture layers.
* Replace fake data usage with real backend data only where required.
* Do not rewrite the entire feature.
* Do not move unrelated files.
* Do not rename existing UI widgets unnecessarily.

Example:

Before:

```text
home/
├── data/
│   └── home_fake_data_source.dart
├── domain/
│   └── entities/
└── presentation/
```

After backend integration it may become:

```text
home/
├── data/
│   ├── data_source/
│   ├── mapper/
│   ├── models/
│   └── repo/
├── domain/
│   ├── entities/
│   ├── repo/
│   └── usecase/
└── presentation/
    ├── manager/
    ├── screens/
    └── widgets/
```

Do not delete fake data until the real backend implementation has replaced every required usage.

---

# 4. Naming Conventions

All files must use `snake_case`.

All Dart classes must use `PascalCase`.

Use feature-specific names.

## Response DTO

```text
profile_response_dto.dart
meal_details_response_dto.dart
offers_response_dto.dart
subscription_packages_response_dto.dart
```

Classes:

```dart
ProfileResponseDto
MealDetailsResponseDto
OffersResponseDto
SubscriptionPackagesResponseDto
```

## Request DTO

```text
login_request_dto.dart
register_request_dto.dart
update_profile_request_dto.dart
create_subscription_request_dto.dart
```

Classes:

```dart
LoginRequestDto
RegisterRequestDto
UpdateProfileRequestDto
CreateSubscriptionRequestDto
```

## Entities

```text
profile_entity.dart
login_request_entity.dart
meal_entity.dart
offer_entity.dart
```

Classes:

```dart
ProfileEntity
LoginRequestEntity
MealEntity
OfferEntity
```

## Mapper

```text
profile_mapper.dart
login_mapper.dart
meal_mapper.dart
```

## Repository Contract

```text
profile_repository.dart
login_repository.dart
offers_repository.dart
```

## Repository Implementation

Always suffix implementations with `Impl`.

```text
profile_repository_impl.dart
login_repository_impl.dart
offers_repository_impl.dart
```

Classes:

```dart
ProfileRepositoryImpl
LoginRepositoryImpl
OffersRepositoryImpl
```

## Data Source

```text
profile_remote_data_source.dart
profile_remote_data_source_impl.dart
```

Classes:

```dart
ProfileRemoteDataSource
ProfileRemoteDataSourceImpl
```

## UseCases

File:

```text
get_profile_usecase.dart
login_usecase.dart
update_profile_usecase.dart
get_offers_usecase.dart
```

Class:

```dart
GetProfileUseCase
LoginUseCase
UpdateProfileUseCase
GetOffersUseCase
```

Use `UseCase`, not `Service`, for domain actions.

## Cubit / ViewModel

This project must use the naming:

```text
profile_view_model.dart
login_view_model.dart
home_view_model.dart
```

Classes:

```dart
ProfileViewModel
LoginViewModel
HomeViewModel
```

Do not randomly mix:

```text
ProfileCubit
ProfileBloc
ProfileController
ProfileProvider
```

when the feature architecture uses `ViewModel`.

---

# 5. Data Layer Models

The Data Layer represents raw backend data.

Backend DTOs must NEVER be used directly by the UI.

Backend DTOs must NEVER leak into the Domain Layer.

---

# 6. Response DTO Nullability — CRITICAL

Response DTO models in the Data Layer must be defensive.

Backend response values must be nullable by default.

Example backend response:

```json
{
  "id": 1,
  "name": "Ahmed",
  "image": "https://..."
}
```

DTO:

```dart
class UserResponseDto {
  final int? id;
  final String? name;
  final String? image;

  const UserResponseDto({
    this.id,
    this.name,
    this.image,
  });
}
```

Do NOT write:

```dart
final int id;
final String name;
final String image;
```

just because Swagger/Postman currently shows those values.

Backend APIs may return:

```json
null
```

or omit a field.

Therefore response DTOs must protect the application from parsing crashes.

This rule also applies to nested response DTOs.

Example:

```dart
class MealResponseDto {
  final int? id;
  final String? name;
  final String? image;
  final double? price;
  final NutritionResponseDto? nutrition;
  final List<IngredientResponseDto>? ingredients;
}
```

Nested DTO fields must also be nullable.

---

# 7. Request DTO Nullability

Request DTOs follow the API contract.

Required backend parameters should normally be required in the Request DTO.

Example:

```dart
class LoginRequestDto {
  final String identifier;
  final String password;

  const LoginRequestDto({
    required this.identifier,
    required this.password,
  });
}
```

Optional request fields may be nullable:

```dart
class UpdateProfileRequestDto {
  final String name;
  final String? image;

  const UpdateProfileRequestDto({
    required this.name,
    this.image,
  });
}
```

Do NOT make required request fields nullable without a reason.

So:

```text
Response DTO → defensive / nullable
Request DTO → follows backend requirements
```

---

# 8. JSON Serialization

Use the project's existing JSON serialization approach.

Prefer:

```dart
@JsonSerializable()
class ProfileResponseDto {
  ...
}
```

with:

```dart
factory ProfileResponseDto.fromJson(Map<String, dynamic> json) =>
    _$ProfileResponseDtoFromJson(json);

Map<String, dynamic> toJson() =>
    _$ProfileResponseDtoToJson(this);
```

Do not manually parse large backend responses when `json_serializable` is already installed.

Do not manually modify generated:

```text
*.g.dart
```

files.

Generated files must always be generated by `build_runner`.

---

# 9. Domain Entities

Entities belong to the Domain Layer.

Entities must not know anything about:

* Retrofit
* Dio
* JSON
* `JsonKey`
* API response structures
* HTTP status codes

Do not add:

```dart
@JsonSerializable()
```

to Domain Entities unless the existing project explicitly requires it for another reason.

Prefer clean entities:

```dart
class ProfileEntity {
  final int id;
  final String name;
  final String image;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.image,
  });
}
```

DTO nullability does NOT automatically mean the entire Domain Layer must be nullable.

The Mapper decides how raw API data becomes domain-safe data.

---

# 10. Never Use DTOs In UI

Forbidden:

```dart
BlocBuilder<ProfileViewModel, ProfileState>(
  builder: (_, state) {
    final ProfileResponseDto user = state.profile;
  },
);
```

Correct:

```dart
final ProfileEntity user = state.profile;
```

UI works with:

```text
Entity
State
Event
```

not raw DTOs.

---

# 11. Mapper Layer

Every backend DTO that crosses into the Domain Layer must be mapped.

Create mappers inside:

```text
data/mapper/
```

Example:

```dart
extension ProfileResponseDtoMapper on ProfileResponseDto {
  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id ?? 0,
      name: name ?? '',
      image: image ?? '',
    );
  }
}
```

However:

Do not blindly convert everything to empty strings or zero.

Choose a fallback only when it is valid for the business meaning.

If absence of a value matters to the business logic, the corresponding Entity field may remain nullable.

Never use:

```dart
name!
image!
id!
```

to bypass DTO nullability.

Avoid force unwrap `!` for API values.

---

# 12. Request Entity → Request DTO Mapping

The Presentation Layer should preferably create/use a Request Entity.

Example:

```dart
LoginRequestEntity
```

Then map it before reaching the API request.

Example:

```dart
extension LoginRequestEntityMapper on LoginRequestEntity {
  LoginRequestDto toDto() {
    return LoginRequestDto(
      identifier: identifier,
      password: password,
    );
  }
}
```

Expected flow:

```text
UI
↓
LoginRequestEntity
↓
ViewModel
↓
UseCase
↓
Repository
↓
Mapper
↓
LoginRequestDto
↓
API
```

Do not create DTOs directly inside UI widgets.

---

# 13. ApiServices Rules

All Retrofit endpoints belong in:

```text
lib/core/network/api_services.dart
```

Use the existing `ApiServices`.

Do not create a second Dio instance.

Do not create a second Retrofit client.

Do not create:

```text
ProfileApiService
HomeApiService
AnotherDioClient
HttpManager
```

unless explicitly requested.

Example:

```dart
@RestApi()
@injectable
abstract class ApiServices {
  @factoryMethod
  factory ApiServices(Dio dio) = _ApiServices;

  @GET('/profile')
  Future<ProfileResponseDto> getProfile();

  @POST('/auth/login')
  Future<LoginResponseDto> login(
    @Body() LoginRequestDto request,
  );
}
```

Use the correct Retrofit annotation according to the backend:

```text
@GET
@POST
@PUT
@PATCH
@DELETE
@Body
@Path
@Query
@Queries
@Header
@Part
@MultiPart
```

Do not guess endpoints.

Use the provided Swagger/Postman/backend documentation.

---

# 14. Network Constants

Use the existing:

```text
lib/core/network/network_constants.dart
```

for network-level constants where appropriate.

Do not hardcode the base URL in feature files.

Never create another `Dio` with a different hardcoded base URL.

The existing Dio already contains the application's interceptors and configuration.

---

# 15. Existing Dio Configuration

Always use the existing injected `Dio`.

The existing project already handles concerns such as:

```text
TokenInterceptor
LanguageInterceptor
PrettyDioLogger
```

Do not manually add authorization headers inside every repository or API request if the existing interceptor already handles them.

Do not manually add language headers in each feature if `LanguageInterceptor` handles them.

Reuse Core infrastructure.

---

# 16. Remote Data Source

Create a contract:

```dart
abstract interface class ProfileRemoteDataSource {
  Future<ProfileResponseDto> getProfile();
}
```

Implementation:

```dart
@Injectable(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl
    implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<ProfileResponseDto> getProfile() {
    return _apiServices.getProfile();
  }
}
```

Important:

The Remote Data Source:

* Calls `ApiServices`.
* Deals with DTOs.
* Does not emit Cubit states.
* Does not know about widgets.
* Does not navigate.
* Does not show Toast/Snackbar.
* Does not contain UI logic.

---

# 17. Repository Contract

Repository contracts belong inside:

```text
domain/repo/
```

Example:

```dart
abstract interface class ProfileRepository {
  Future<ApiResult<ProfileEntity>> getProfile();
}
```

Repository contracts should return Domain Entities, not DTOs.

Wrong:

```dart
Future<ApiResult<ProfileResponseDto>> getProfile();
```

Correct:

```dart
Future<ApiResult<ProfileEntity>> getProfile();
```

---

# 18. Repository Implementation

Repository implementation belongs inside:

```text
data/repo/
```

Use Injectable binding:

```dart
@Injectable(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<ProfileEntity>> getProfile() {
    return safeApiCall(() async {
      final response = await _remoteDataSource.getProfile();

      return response.toEntity();
    });
  }
}
```

Repository implementation is responsible for connecting:

```text
Data Source
+
Mapper
+
safeApiCall
```

Do not write `try/catch` manually in every repository when `safeApiCall` already exists.

Use:

```dart
safeApiCall(...)
```

for remote calls.

---

# 19. ApiResult Rules

Use the existing Core result types:

```dart
ApiResult<T>
ApiSuccessResult<T>
ApiErrorResult<T>
```

Never introduce another result wrapper such as:

```text
Result
Either
NetworkResult
Resource
DataState
BaseResponseState
```

unless explicitly requested.

Use the existing architecture.

Handle result using pattern matching:

```dart
switch (result) {
  case ApiSuccessResult():
    ...
  case ApiErrorResult():
    ...
}
```

---

# 20. UseCase Rules

Each business operation should have its own UseCase when appropriate.

Example:

```dart
@injectable
class GetProfileUseCase {
  GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ApiResult<ProfileEntity>> call() {
    return _repository.getProfile();
  }
}
```

For parameters:

```dart
@injectable
class LoginUseCase {
  LoginUseCase(this._repository);

  final LoginRepository _repository;

  Future<ApiResult<LoginEntity>> call(
    LoginRequestEntity requestEntity,
  ) {
    return _repository.login(requestEntity);
  }
}
```

Do not inject RemoteDataSource directly into the UseCase.

Wrong:

```text
ViewModel → DataSource
```

Wrong:

```text
UseCase → ApiServices
```

Correct:

```text
ViewModel
↓
UseCase
↓
Repository
```

---

# 21. Dependency Injection — CRITICAL

This project uses:

```text
injectable
get_it
```

Use constructor injection everywhere.

Do not manually instantiate dependencies.

Wrong:

```dart
final dio = Dio();
final repo = ProfileRepositoryImpl(...);
```

Wrong inside ViewModel:

```dart
final useCase = getIt<GetProfileUseCase>();
```

Correct:

```dart
@injectable
class ProfileViewModel extends Cubit<ProfileState> {
  ProfileViewModel(
    this._getProfileUseCase,
  ) : super(const ProfileState());

  final GetProfileUseCase _getProfileUseCase;
}
```

---

# 22. Injectable Annotations

Remote Data Source:

```dart
@Injectable(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl
    implements ProfileRemoteDataSource {
  ...
}
```

Repository:

```dart
@Injectable(as: ProfileRepository)
class ProfileRepositoryImpl
    implements ProfileRepository {
  ...
}
```

UseCase:

```dart
@injectable
class GetProfileUseCase {
  ...
}
```

ViewModel:

```dart
@injectable
class ProfileViewModel extends Cubit<ProfileState> {
  ...
}
```

Do not manually register these dependencies inside GetIt if Injectable can generate them.

---

# 23. Do Not Edit Generated DI Files

Never manually edit:

```text
lib/core/di/di.config.dart
```

This file is generated.

Update annotations and regenerate it.

Also never manually edit:

```text
api_services.g.dart
*.g.dart
```

---

# 24. Build Runner

After adding/changing any:

* `@injectable`
* `@Injectable`
* Retrofit endpoint
* JSON Serializable DTO
* generated dependency

run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Never manually implement missing generated code as a workaround.

---

# 25. ViewModel / Cubit Architecture

Use `flutter_bloc`.

Each backend-connected screen/feature should use:

```text
ViewModel
Event
State
```

Example:

```text
presentation/
└── manager/
    ├── login_view_model.dart
    ├── login_event.dart
    └── login_state.dart
```

The UI must communicate with the ViewModel through:

```dart
doIntent(...)
```

Do not expose random public methods to the UI when they represent user intents.

---

# 26. Event Pattern — CRITICAL

Events must use a sealed base class.

Example:

```dart
sealed class LoginEvent {}

class LoginSubmitEvent extends LoginEvent {
  LoginSubmitEvent(this.requestEntity);

  final LoginRequestEntity requestEntity;
}
```

Multiple actions:

```dart
sealed class ProfileEvent {}

class GetProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  UpdateProfileEvent(this.requestEntity);

  final UpdateProfileRequestEntity requestEntity;
}

class LogoutEvent extends ProfileEvent {}
```

---

# 27. doIntent Is The UI Entry Point

The main public entry point for ViewModel user actions must be:

```dart
void doIntent(ProfileEvent event) {
  switch (event) {
    case GetProfileEvent():
      _getProfile();

    case UpdateProfileEvent():
      _updateProfile(event.requestEntity);

    case LogoutEvent():
      _logout();
  }
}
```

UI:

```dart
viewModel.doIntent(
  GetProfileEvent(),
);
```

or:

```dart
viewModel.doIntent(
  UpdateProfileEvent(requestEntity),
);
```

Do not do:

```dart
viewModel.getProfile();
```

when `getProfile` represents an event/user intent.

Do not make API handlers public.

Use private handlers:

```dart
_getProfile()
_updateProfile()
_loginUser()
_registerUser()
_getMeals()
_getOffers()
```

---

# 28. ViewModel Example

Follow this style:

```dart
@injectable
class LoginViewModel extends Cubit<LoginState> {
  LoginViewModel(this._loginUseCase)
      : super(const LoginState());

  final LoginUseCase _loginUseCase;

  void doIntent(LoginEvent event) {
    switch (event) {
      case LoginSubmitEvent():
        _loginUser(event.requestEntity);
    }
  }

  Future<void> _loginUser(
    LoginRequestEntity requestEntity,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
      ),
    );

    final result = await _loginUseCase(requestEntity);

    switch (result) {
      case ApiSuccessResult():
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: true,
            loginResponse: result.data,
          ),
        );

      case ApiErrorResult():
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: false,
            errorMessage: result.failure.errorMessage,
            failure: result.failure,
          ),
        );
    }
  }
}
```

---

# 29. State Architecture

Prefer one immutable State class per ViewModel.

Example:

```dart
class ProfileState {
  final bool isLoading;
  final bool isSuccess;
  final ProfileEntity? profile;
  final String? errorMessage;
  final Failure? failure;

  const ProfileState({
    this.isLoading = false,
    this.isSuccess = false,
    this.profile,
    this.errorMessage,
    this.failure,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isSuccess,
    ProfileEntity? profile,
    String? errorMessage,
    Failure? failure,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
      failure: failure ?? this.failure,
    );
  }
}
```

Follow the project's existing state style.

Do not automatically create:

```text
ProfileInitial
ProfileLoading
ProfileSuccess
ProfileError
```

as four separate classes if the feature architecture uses a single state object with `copyWith`.

---

# 30. State Flags

Typical state fields:

```dart
isLoading
isSuccess
errorMessage
failure
data/entity
```

Only add fields actually needed by the feature.

Do not create meaningless flags.

For multiple independent API operations, use descriptive loading flags when needed:

```dart
isProfileLoading
isUpdateProfileLoading
isDeleteAccountLoading
```

instead of one ambiguous flag if operations can occur independently.

---

# 31. Resetting Feedback

If success/error flags are temporary UI feedback, expose an appropriate Event when possible.

Example:

```dart
class ClearProfileFeedbackEvent extends ProfileEvent {}
```

Then:

```dart
void doIntent(ProfileEvent event) {
  switch (event) {
    ...
    case ClearProfileFeedbackEvent():
      _clearFeedback();
  }
}
```

Prefer keeping user-driven state changes inside the Event → `doIntent` flow.

---

# 32. Business-Specific Error Handling

Generic network errors belong in Core.

Feature-specific error interpretation may remain inside the feature ViewModel or another appropriate feature layer.

Example:

```dart
final isNotVerified =
    result.failure.exception.errorType ==
        ApiErrorType.unauthorized &&
    _isEmailNotVerifiedError(
      result.failure.exception.message,
    );
```

Do not put login-specific behavior into global Core error handling.

Core handles generic network failures.

Feature handles feature-specific meaning.

---

# 33. UI Must Not Call UseCase Directly

Wrong:

```dart
onPressed: () async {
  final result = await getIt<LoginUseCase>()(...);
}
```

Correct:

```dart
onPressed: () {
  viewModel.doIntent(
    LoginSubmitEvent(requestEntity),
  );
}
```

UI observes State.

ViewModel controls the operation.

---

# 34. UI Must Not Call Repository Directly

Never:

```dart
repository.login(...)
```

inside:

```text
Screen
Widget
ViewModel UI helper
```

Correct:

```text
UI
↓
ViewModel
↓
UseCase
↓
Repository
```

---

# 35. UI Must Not Call ApiServices

Absolutely forbidden:

```dart
getIt<ApiServices>().getProfile();
```

inside UI.

Also forbidden inside ViewModel.

`ApiServices` belongs at the Data Layer boundary.

---

# 36. Loading Handling

Before an API call:

```dart
emit(
  state.copyWith(
    isLoading: true,
    isSuccess: false,
  ),
);
```

On success:

```dart
emit(
  state.copyWith(
    isLoading: false,
    isSuccess: true,
    data: result.data,
  ),
);
```

On failure:

```dart
emit(
  state.copyWith(
    isLoading: false,
    isSuccess: false,
    errorMessage: result.failure.errorMessage,
    failure: result.failure,
  ),
);
```

Never leave loading `true` after success/error.

---

# 37. Error Messages

Use the project's existing failure/error system.

Do not create custom error strings for network failures when `Failure` already provides:

```dart
failure.errorMessage
```

Do not show raw Dio exceptions to users.

Do not expose backend stack traces.

---

# 38. Logging

Logging may be used for useful development information.

Prefer:

```dart
import 'dart:developer' as developer;

developer.log(
  'Loading profile',
  name: 'ProfileViewModel',
);
```

Do not use excessive `print()` statements.

Never log:

* Passwords
* Access tokens
* Refresh tokens
* Credit card data
* OTP values
* Sensitive personal data

Example of what NOT to do:

```dart
developer.log('password = ${request.password}');
```

---

# 39. Authentication / Token Handling

Use the existing token infrastructure.

Do not manually add:

```dart
'Authorization': 'Bearer $token'
```

to every endpoint if `TokenInterceptor` already handles authentication.

Do not store access tokens inside ViewModels.

Do not store tokens inside widgets.

Use the existing secure storage/service infrastructure.

---

# 40. Language Header

Use the existing `LanguageInterceptor`.

Do not manually send Arabic/English language headers from every feature unless the API specifically requires a different behavior.

---

# 41. Pagination

If an endpoint supports pagination, represent pagination explicitly.

Example request/query:

```text
page
limit
pageSize
cursor
```

depending on backend contract.

Pagination state may contain:

```dart
currentPage
hasMore
isLoadingMore
```

Do not reload the entire first page when only loading the next page.

Do not invent pagination if the backend endpoint does not support it.

---

# 42. Lists

Response DTO:

```dart
final List<MealResponseDto>? meals;
```

Domain Entity may become:

```dart
final List<MealEntity> meals;
```

Mapper:

```dart
meals:
    dto.meals
        ?.map((item) => item.toEntity())
        .toList() ??
    const [],
```

Never allow a malformed nullable backend list to crash the UI.

---

# 43. Nested Responses

Do not put an entire complex API response in one massive Dart file if it contains meaningful nested structures.

Example:

```text
models/response/
├── home_response_dto.dart
├── meal_response_dto.dart
├── category_response_dto.dart
└── offer_response_dto.dart
```

Keep models readable.

At the same time, do not split tiny anonymous structures unnecessarily.

Follow the backend domain.

---

# 44. Endpoint Integration Checklist

Before implementing an endpoint, inspect:

1. HTTP method.
2. Endpoint path.
3. Authentication requirement.
4. Headers.
5. Query parameters.
6. Path parameters.
7. Request body.
8. Response body.
9. Nullable values.
10. Pagination.
11. Possible error responses.
12. File upload requirements.
13. Whether the feature already has matching Entity/UI.
14. Whether a reusable mapper/model already exists.

Never guess any of these when API documentation exists.

---

# 45. Backend Contract Is Source of Truth For Data

For backend integration:

* Swagger/Postman/backend documentation is the source of truth for API shape.
* Existing Figma is the source of truth for UI.
* Existing project code is the source of truth for architecture/conventions.

Do not use UI text to guess API fields.

Do not use API response structure to redesign UI.

Keep these responsibilities separate.

---

# 46. Do Not Change UI During Backend Integration

When asked only to connect an endpoint:

Do not change:

* colors
* padding
* typography
* layout
* icons
* screen structure
* animations
* navigation design
* visual hierarchy

unless backend data makes a small functional adjustment necessary.

Connect the existing UI to the new State/Entity.

---

# 47. Replace Fake Data Correctly

If a screen currently uses:

```dart
HomeFakeDataSource
```

and real Home API is being connected:

Do not start by deleting the fake data source.

First implement:

```text
DTO
Mapper
DataSource
Repository
UseCase
ViewModel
State
Event
```

Then connect the existing UI to the ViewModel.

After confirming the real data completely replaces the fake dependency, remove obsolete fake-data usage/files only if safe and requested/appropriate.

Do not leave two competing sources controlling the same screen.

---

# 48. Existing Entity Reuse

Before creating:

```dart
MealEntity
OfferEntity
HomeMealEntity
SubscriptionEntity
```

search the project first.

If an Entity already exists and correctly represents the backend/domain concept, reuse or carefully extend it.

Do not create:

```text
MealEntity
MealDataEntity
MealItemEntity
MealModelEntity
```

for the same concept without a real reason.

---

# 49. Existing Core Reuse

Before creating anything network-related, inspect:

```text
lib/core/network/
lib/core/errors/
lib/core/services/
lib/core/di/
```

Reuse existing implementations.

Especially reuse:

```text
ApiServices
ApiResult
safeApiCall
Failure
Dio
TokenInterceptor
LanguageInterceptor
GetIt / Injectable
```

Do not duplicate Core infrastructure inside features.

---

# 50. Import Rules

Prefer package imports for cross-feature/Core dependencies according to existing project conventions.

Relative imports may be used for closely related files inside the same feature if that matches the surrounding code.

Do not create inconsistent import styles in one file.

Remove unused imports after implementation.

---

# 51. File Responsibility

Each file should have a clear responsibility.

Examples:

```text
profile_response_dto.dart
→ API response representation

profile_mapper.dart
→ DTO ↔ Entity conversion

profile_remote_data_source_impl.dart
→ ApiServices call

profile_repository_impl.dart
→ safeApiCall + mapping

get_profile_usecase.dart
→ one domain operation

profile_view_model.dart
→ presentation state orchestration

profile_event.dart
→ user/system intents

profile_state.dart
→ UI state
```

Do not combine all architecture layers into one file.

---

# 52. ViewModel Must Not Parse JSON

Never:

```dart
final data = jsonDecode(response);
```

inside ViewModel.

Parsing belongs to Data Layer / generated DTO serialization.

---

# 53. ViewModel Must Not Map DTOs

Never:

```dart
final entity = ProfileEntity(
  id: response.id ?? 0,
);
```

inside ViewModel.

Mapping belongs in:

```text
data/mapper/
```

---

# 54. Repository Must Not Emit States

Never:

```dart
emit(ProfileState(...));
```

inside Repository.

Repository does not know Cubit exists.

---

# 55. Data Source Must Not Handle UI Error Messages

Never:

```dart
showToast(...)
ScaffoldMessenger...
context.localization...
```

inside Data Source.

Data Layer has no Flutter UI responsibility.

---

# 56. Domain Must Stay Framework-Light

Domain should not depend on:

```text
Flutter widgets
BuildContext
Dio Response
Retrofit annotations
Cubit
Bloc
Toast
Navigator
```

Domain represents application business concepts.

---

# 57. API Response Wrapper

If backend responses use a standard wrapper such as:

```json
{
  "success": true,
  "message": "Success",
  "data": {}
}
```

follow the actual backend contract.

Do not strip useful wrapper fields blindly.

Create an appropriate DTO representation when needed and map the actual business `data` into the Domain Entity.

Do not expose generic response wrappers directly to UI unless the existing architecture explicitly needs them.

---

# 58. Empty / Nullable Backend Data

Never assume:

```dart
response.data!
response.image!
response.items!
```

is safe.

Handle null at the Mapper/Data boundary.

Avoid API-derived `!` unless there is an extremely clear, validated invariant.

---

# 59. Multipart / Images

If backend integration requires an image/file upload:

* Reuse existing Dio/Retrofit.
* Use `@MultiPart`.
* Use appropriate `MultipartFile`.
* Keep file conversion/preparation outside widgets when possible.
* Do not manually build low-level HTTP requests if Retrofit already supports the endpoint.

Do not add another networking package.

---

# 60. Dependency Rule

Dependencies must point inward:

```text
Presentation
↓
Domain
↑
Data implements Domain contracts
```

Conceptually:

```text
Presentation knows Domain.
Domain does not know Data.
Data knows Domain contracts/entities.
```

Never import Data DTOs into Domain entities.

Never import Data DTOs into Presentation UI.

---

# 61. Complete Example Structure

For a new `favorites` feature:

```text
lib/features/favorites/
│
├── data/
│   ├── data_source/
│   │   ├── favorites_remote_data_source.dart
│   │   └── favorites_remote_data_source_impl.dart
│   │
│   ├── mapper/
│   │   └── favorites_mapper.dart
│   │
│   ├── models/
│   │   ├── request/
│   │   │   └── toggle_favorite_request_dto.dart
│   │   └── response/
│   │       └── favorite_response_dto.dart
│   │
│   └── repo/
│       └── favorites_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── favorite_entity.dart
│   │   └── toggle_favorite_request_entity.dart
│   │
│   ├── repo/
│   │   └── favorites_repository.dart
│   │
│   └── usecase/
│       ├── get_favorites_usecase.dart
│       └── toggle_favorite_usecase.dart
│
└── presentation/
    ├── manager/
    │   ├── favorites_view_model.dart
    │   ├── favorites_event.dart
    │   └── favorites_state.dart
    │
    ├── screens/
    └── widgets/
```

---

# 62. Complete Event Example

```dart
sealed class FavoritesEvent {}

class GetFavoritesEvent extends FavoritesEvent {}

class ToggleFavoriteEvent extends FavoritesEvent {
  ToggleFavoriteEvent(this.requestEntity);

  final ToggleFavoriteRequestEntity requestEntity;
}

class LoadMoreFavoritesEvent extends FavoritesEvent {}
```

---

# 63. Complete ViewModel Flow

```dart
@injectable
class FavoritesViewModel extends Cubit<FavoritesState> {
  FavoritesViewModel(
    this._getFavoritesUseCase,
    this._toggleFavoriteUseCase,
  ) : super(const FavoritesState());

  final GetFavoritesUseCase _getFavoritesUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;

  void doIntent(FavoritesEvent event) {
    switch (event) {
      case GetFavoritesEvent():
        _getFavorites();

      case ToggleFavoriteEvent():
        _toggleFavorite(event.requestEntity);

      case LoadMoreFavoritesEvent():
        _loadMoreFavorites();
    }
  }

  Future<void> _getFavorites() async {
    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
      ),
    );

    final result = await _getFavoritesUseCase();

    switch (result) {
      case ApiSuccessResult():
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: true,
            favorites: result.data,
          ),
        );

      case ApiErrorResult():
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: false,
            errorMessage: result.failure.errorMessage,
            failure: result.failure,
          ),
        );
    }
  }
}
```

---

# 64. Before Writing Code

Before modifying a feature, inspect the entire relevant feature folder.

Also inspect relevant shared/Core files.

At minimum check:

```text
lib/features/<feature>/
lib/core/network/
lib/core/errors/
lib/core/di/
lib/core/services/
lib/shared/
```

when relevant.

Do not immediately generate a new architecture without checking what already exists.

---

# 65. Before Creating A New Entity

Search for equivalent entities across the project.

Before creating a new model, search existing models.

Before creating a new widget, follow the existing UI rules and search reusable widgets.

Before creating a helper/service, search Core and Shared.

Reuse before creating.

---

# 66. When Backend Documentation Is Provided

When Swagger, Postman, sample JSON, API docs, or backend response examples are provided:

Read them before writing models.

Match exact:

```text
JSON keys
HTTP method
endpoint
request body
query parameters
response nesting
types
```

Use `@JsonKey(name: '...')` when Dart naming differs from backend JSON naming.

Example:

```dart
@JsonKey(name: 'image_url')
final String? imageUrl;
```

Do not rename backend JSON keys based on assumptions.

---

# 67. Do Not Invent Backend Fields

If the backend response is unknown, do not invent:

```text
id
name
message
status
data
image
```

Ask for or inspect actual backend documentation when necessary.

If Swagger/Postman is available, use it as the API contract.

---

# 68. Do Not Over-Engineer

Do not create:

* BaseRepository unless already used.
* BaseUseCase unless already used.
* Generic Cubit abstractions.
* Generic DataSource abstractions.
* New Result/Either types.
* New API client.
* New state management system.
* Unnecessary interfaces.
* Extra wrapper classes.

Use the existing project architecture.

---

# 69. Never Add Packages Automatically

The project already contains the necessary backend packages including:

```text
dio
retrofit
injectable
get_it
flutter_bloc
json_serializable
build_runner
retrofit_generator
injectable_generator
flutter_secure_storage
pretty_dio_logger
```

Do not add another backend/state-management package without explicit permission.

---

# 70. Code Quality After Integration

After completing backend integration:

* Remove unused imports.
* Remove obsolete temporary code.
* Remove debug `print()` calls.
* Keep useful developer logs only.
* Format changed Dart files.
* Run analyzer.
* Generate required code.
* Ensure no generated file was manually modified.
* Ensure UI still follows existing AGENTS.md rules.

Recommended commands:

```bash
dart run build_runner build --delete-conflicting-outputs
dart format lib
flutter analyze
```

Do not claim the task is complete while generated code is stale or analyzer errors caused by the implementation remain.

---

# 71. Do Not Break Existing Behavior

Backend integration must not break:

* localization
* RTL/LTR
* navigation
* theme
* authentication persistence
* token handling
* existing UI
* existing shared widgets
* existing routes

Modify only what the requested endpoint/feature requires.

---

# 72. Required Architecture Summary

For every normal backend feature, think in this exact order:

```text
1. Inspect existing feature.
2. Inspect API contract.
3. Reuse/create Domain Entities.
4. Create Request Entity if needed.
5. Create nullable Response DTO.
6. Create Request DTO if needed.
7. Create Mapper.
8. Add Retrofit endpoint to ApiServices.
9. Create RemoteDataSource contract.
10. Create RemoteDataSourceImpl with @Injectable(as: ...).
11. Create Repository contract in Domain.
12. Create RepositoryImpl in Data with @Injectable(as: ...).
13. Use safeApiCall.
14. Map DTO → Entity.
15. Create UseCase with @injectable.
16. Create/update Event.
17. Create/update State.
18. Create/update ViewModel with @injectable.
19. Route UI actions through doIntent.
20. Connect existing UI to State.
21. Run build_runner.
22. Format and analyze.
```

---

# 73. Final Mandatory Rules

Always:

```text
UI → doIntent(Event)
Event → private ViewModel method
ViewModel → UseCase
UseCase → Repository
RepositoryImpl → RemoteDataSource
RemoteDataSourceImpl → ApiServices
ApiServices → Backend
Response DTO → Mapper → Entity
Entity → State → UI
```

Never:

```text
UI → ApiServices
UI → Repository
UI → UseCase
ViewModel → ApiServices
ViewModel → RemoteDataSource
Domain → DTO
UI → DTO
```

Always use:

```text
injectable
constructor injection
ApiResult
safeApiCall
Retrofit
DTO → Mapper → Entity
existing Core ApiErrorWidget / InlineApiErrorWidget
single immutable State + copyWith
sealed Event
doIntent
private API handlers in ViewModel
```

Response DTO fields must be nullable/defensive.

Request DTO fields follow the backend contract.

Do not use force unwrap `!` to hide backend nullability problems.

Do not modify generated files manually.

Do not duplicate existing Core functionality.

Do not redesign the UI while connecting the backend.

The existing project architecture is always preferred over inventing a new abstraction.

---

# 74. Error Widget Usage — CRITICAL

The project already contains reusable Core error widgets.

Do not create a new error screen/widget inside every feature.

Before implementing UI error handling, inspect and reuse:

lib/core/errors/
The default rules are:

Whole screen/feature failed with no usable data
→ ApiErrorWidget

One section/part of a screen failed
→ InlineApiErrorWidget

Request succeeded but returned no data
→ EmptyStateWidget

Loading
→ Existing feature loader/shimmer

Content exists
→ Keep the content visible
Screen-Level API Errors
For a normal backend-connected screen, when the request fails and there is no usable data to display, use the existing:

ApiErrorWidget.fromTypedFailure(
  state.failure!,
  onRetry: () {
    viewModel.doIntent(
      LoadFeatureEvent(),
    );
  },
)
Do not create custom conditions for:

no internet
timeout
server error
unauthorized
forbidden
not found
inside every feature UI when ApiErrorWidget already knows how to present the existing typed Failure.

Do not duplicate error-type switching in feature screens.

Wrong:

if (failure.exception.errorType == ApiErrorType.noInternetConnection) {
  return NoInternetErrorWidget(...);
}

if (failure.exception.errorType == ApiErrorType.timeout) {
  return TimeoutErrorWidget(...);
}

if (failure.exception.errorType == ApiErrorType.serverError) {
  return ServerErrorWidget(...);
}
Correct:

return ApiErrorWidget.fromTypedFailure(
  state.failure!,
  onRetry: () {
    viewModel.doIntent(
      LoadFeatureEvent(),
    );
  },
);
ApiErrorWidget is the default reusable full-feature error UI.

Keep The Existing State Architecture
Do not convert a feature from the project's single immutable State + copyWith architecture into:

FeatureInitial
FeatureLoading
FeatureLoaded
FeatureError
only to make error rendering easier.

Use the existing State fields.

Example:

BlocBuilder<ProfileViewModel, ProfileState>(
  builder: (context, state) {
    if (state.isLoading && state.profile == null) {
      return const ProfileShimmer();
    }

    if (state.failure != null && state.profile == null) {
      return ApiErrorWidget.fromTypedFailure(
        state.failure!,
        onRetry: () {
          context.read<ProfileViewModel>().doIntent(
                GetProfileEvent(),
              );
        },
      );
    }

    if (state.isSuccess && state.profile == null) {
      return const EmptyStateWidget();
    }

    return ProfileContent(
      profile: state.profile,
    );
  },
);
The exact hasData condition depends on the feature.

Examples:

state.profile != null
state.orders.isNotEmpty
state.meals.isNotEmpty
state.favorites.isNotEmpty
Do not add a generic hasData abstraction unless the feature actually benefits from it.

Typed State Features That Already Exist
If an existing feature already uses typed/sealed states such as:

ExamsLoading
ExamsError
ExamsLoaded
do not rewrite it only to match another feature.

Use the reusable error widget directly:

if (state is ExamsLoading) {
  return const Center(
    child: LogoShimmerLoader(size: 120),
  );
}

if (state is ExamsError) {
  return ApiErrorWidget.fromTypedFailure(
    state.failure,
    onRetry: () => _load(context, page: _page),
  );
}

if (state is ExamsLoaded) {
  return _buildContent(
    context,
    state.data,
  );
}
Preserve the feature's existing State style.

The general rule is to reuse the same Core error widgets, not to force every feature to use the same State class shape.

Partial / Section Errors
If a screen already has usable data and only one independent section fails, do not replace the entire screen with ApiErrorWidget.

Use:

InlineApiErrorWidget(
  failure: state.sectionFailure!,
  onRetry: () {
    viewModel.doIntent(
      ReloadSectionEvent(),
    );
  },
)
Example:

Home
├── Categories      ✅
├── Popular Meals   ✅
├── Offers           ❌
└── Recommended     ✅
Correct behavior:

Keep Home visible
+
show InlineApiErrorWidget only for Offers
Do not show a full-screen error while useful screen data is already available.

Refresh Errors With Existing Data
If refresh/reload fails but existing data is still available:

Keep existing data visible.
Do not replace it with a full-screen error.

A full-screen ApiErrorWidget is appropriate when:

loading finished
+
the required request failed
+
there is no usable data to render
Example condition for a multi-section feature:

final showGlobalError =
    !state.isLoading &&
    state.hasStartedLoadingContent &&
    !state.hasAnyData &&
    state.firstFailure != null;
Then:

if (showGlobalError)
  SliverFillRemaining(
    hasScrollBody: false,
    child: ApiErrorWidget.fromTypedFailure(
      state.firstFailure!,
      onRetry: () {
        _reloadAllSections(context);
      },
    ),
  ),
The SliverFillRemaining wrapper is only for screens already built with Slivers.

Do not force Slivers into normal screens just for error handling.

For a normal widget tree, return ApiErrorWidget directly.

Empty State Is Not An Error
A successful request with empty data is not a network failure.

Example:

200 OK
[]
Use the project's existing empty-state UI/widget.

Do not create a fake Failure.

Do not show ApiErrorWidget for successful empty data.

Action / Form Errors
For operations where the current UI should remain visible, such as:

login
register
update profile
add/remove favorite
delete item
submit form
do not remove the form/content and replace the whole screen with a full-screen error.

When an existing reusable inline error presentation fits the design, prefer:

InlineApiErrorWidget(
  failure: state.failure!,
  onRetry: retryAction,
)
Otherwise preserve the feature's existing feedback pattern.

Do not introduce BlocListener, Snackbar, Toast, or a new feedback mechanism solely for API errors unless the existing feature/UI already requires that pattern.

Retry Must Repeat The Correct Intent
onRetry must retry only the operation that failed.

Correct:

onRetry: () {
  viewModel.doIntent(
    GetOrdersEvent(),
  );
}
For a failed Home section:

onRetry: () {
  viewModel.doIntent(
    GetOffersEvent(),
  );
}
Do not reload unrelated features or reset unrelated state.

Error Widget Decision Summary
Use this decision:

Is loading?
→ Existing loader/shimmer

Else, failure + no usable data?
→ ApiErrorWidget

Else, partial failure + other usable data?
→ InlineApiErrorWidget

Else, success + empty data?
→ EmptyStateWidget

Else
→ Content
Do not create another generic feature-state/error wrapper unless explicitly requested.

Reuse the existing Core widgets directly in BlocBuilder / the existing UI state rendering.

# CRITICAL BACKEND RULE

When asked to integrate an API, do not implement only the Retrofit method and call it from the screen.

The endpoint is not considered properly integrated until the required architecture flow is connected:

```text
ApiServices
→ RemoteDataSource
→ Repository
→ UseCase
→ ViewModel
→ Event/State
→ Existing UI
```

while preserving:

```text
DTO
→ Mapper
→ Entity
```

and using the project's existing:

```text
ApiResult
safeApiCall
Injectable
GetIt
Dio
Retrofit
flutter_bloc
```