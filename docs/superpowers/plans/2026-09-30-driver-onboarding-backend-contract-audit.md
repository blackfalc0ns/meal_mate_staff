# Driver Onboarding and Approval Backend Integration Contract Audit

**Date:** 2026-09-30  
**Status:** Completed Audit  
**References:** Spec sections 1–13, 15–16; `rules/rules_backend.md`.

## 1. Endpoint Contract Matrix

| Endpoint | HTTP | Auth | Status | Notes & Action Required |
|---|---|---|---|---|
| `/api/v1/auth/staff/driver-registration/restaurants` | GET | No | `already correct` | Used for restaurant catalog in linked registration. |
| `/api/v1/auth/staff/driver-registration/nationalities` | GET | No | `already correct` | Catalog for nationalities. |
| `/api/v1/auth/staff/driver-registration/vehicle-types` | GET | No | `already correct` | Catalog for vehicle types. |
| `/api/v1/auth/staff/driver-registration/vehicle-colors` | GET | No | `already correct` | Catalog for vehicle colors. |
| `/api/v1/auth/staff/driver-registration/vehicle-models` | GET | No | `already correct` | Search vehicle models query with search, vehicleType, limit. |
| `/api/v1/auth/staff/driver-registration/upload` | POST | No | `already correct` | Multipart form `file`. Client guard: file size < 15 MiB to leave multipart overhead, reject empty files, keep storageKey unset until upload succeeds. |
| `/api/v1/auth/staff/driver-registration` | POST | No | `mobile change` | Make `restaurantId` nullable (`null` for independent registration). Remove ViewModel fallback auto-selecting first restaurant. Do not sync FCM token pre-login. Handle submit timeout without duplicate submissions. |
| `/api/v1/auth/staff/driver-registration/status` | GET | Yes | `mobile change` | Add `fullNameAr`, `fullNameEn`, `requestedByRole` to DTO. Map status strings defensively. Enforce `showResubmit = canResubmit && status != Approved && status != Rejected`. Replace initial loader with ShimmerWidget, and use `CustomProgressIndicator` during request loading overlays. |
| `/api/v1/auth/staff/driver-registration/{registrationId}/resubmit` | POST | Yes | `mobile change` | Send only changed fields. Omit `phone`. Serialize `isVehicleOwned: false` when false. Omit unchanged document keys. Disallow submit with empty changes. Handle 409 conflict states. |
| `/api/v1/auth/drivers/lookup-phone` | POST | No | `mobile change` | Add missing driver route. Body `{ phone }`. Response `{ exists, isFirstTimeSetup, phone, fullName, restaurantName, status }`. 404 is typed failure. |
| `/api/v1/auth/drivers/first-time-setup` | POST | No | `mobile change` | Add route. Body `{ phone, otpCode, password }`. Returns top-level session response. Store tokens securely, then fetch status. |
| `/api/v1/auth/drivers/login` | POST | No | `mobile change` | Add route. Body `{ phone, password, email? }`. Distinguish pre-approval session from operational approval. |
| `/api/v1/auth/drivers/resend-otp` | POST | No | `mobile change` | Add route. Body `{ destination, channel, purpose }`. Do not auto-resend on lookup. |
| `/api/v1/auth/drivers/verify-otp` | POST | No | `mobile change` | Add route. Body `{ destination, purpose, code }`. |
| `/api/v1/auth/drivers/forgot-password` | POST | No | `mobile change` | Add route. Body `{ phone }`. |
| `/api/v1/auth/drivers/reset-password` | POST | No | `mobile change` | Add route. Body `{ phone, otpCode, newPassword }`. |
| `/api/v1/drivers/registrations/{id}` | GET | Yes | `mobile change` | Add route for full registration details. |
| `/api/v1/driver/device-token` | POST | Yes | `mobile change` | In ApiServices already, but must only be invoked after authenticated session exists. |
| `/api/v1/driver/device-token?token=...` / `/deactivate` | DELETE/POST | Yes | `mobile change` | Deactivate token before clearing session on logout. |
| `/api/v1/driver/notifications` | GET | Yes | `mobile change` | Add route. Returns direct JSON array of latest 50 notifications. |
| `/api/v1/driver/notifications/{id}/read` | PUT | Yes | `mobile change` | Add route. 204 NoContent, void response. |
| `/api/v1/driver/profile` | GET | Yes (Driver) | `already correct` | Operational profile (Screen 09.02). Does not contain `accountStatus`. |

## 2. Notification Events Audit

- `driver.registration.submitted`: Handled (needs status refresh prompt).
- `driver.registration.independent_submitted`: Missing in parser, add handler.
- `driver.registration.resubmitted`: Missing in parser, add handler.
- `driver.registration.restaurant_approved`: Handled (refresh status, remains under review).
- `driver.registration.restaurant_changes_requested`: Handled (refresh status, open correction).
- `driver.registration.restaurant_rejected`: Missing in parser, add handler.
- `driver.registration.admin_approved`: Existing parser checked `admin_confirmed`; add alias for `admin_approved`.
- `driver.registration.admin_changes_requested`: Missing in parser, add handler.
- `driver.registration.admin_rejected`: Handled.
- Deep link: `/driver/status?registrationId=...` parsed as internal route argument, not opened as external URL.

## 3. UI Loading & Error Handling Directives

- **User Directive:** Whenever an API request is loading, use `CustomProgressIndicator` (`lib/core/widget/custom_progress_indecator.dart`) in the center of the screen (or centered in a modal/scrim overlay).
- **Initial screen loading:** Screen-shaped `ShimmerWidget` for account status and notifications placeholder.
- **Errors:** `ApiErrorWidget` for full-screen failures, `InlineApiErrorWidget` for inline/retry errors.

## 4. Backend Evidence & Unresolved Gaps

- **Upload ownership:** Server checks file existence and non-empty size, but lacks user ownership verification. Client must never claim ownership is verified.
- **canResubmit on Rejected:** Backend mapper currently returns `canResubmit: true` for rejected registrations, but resubmit returns 409 `ALREADY_REJECTED`. Mobile client strictly guards `showResubmit = canResubmit && status != Approved && status != Rejected`.
- **Notification delivery:** Push is best-effort. Events trigger API status refresh; events are never the authority for state.
