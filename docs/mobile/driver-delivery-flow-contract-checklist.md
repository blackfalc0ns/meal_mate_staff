# Driver Delivery Flow — Contract & Implementation Checklist

**Date:** 2026-10-06  
**Scope:** Screens 07.00, 07.00B, 07.01, 07.02, 07.06 (with 03.01 map integration)

---

## 1. Scope & Rules Verification

- [x] Read and adhered to `rules/rules_backend.md` (Clean Architecture, Feature-Based structure, safeApiCall, ApiResult, Retrofit, Injectable, no DTO in UI).
- [x] Read and adhered to `lib/core/errors` (Failure, ServerFailure, ApiException, ApiErrorType, typed error mapping).
- [x] Working tree checked: no commit commands run, user code preserved.
- [x] Screens alignment:
  - **07.00**: `DriverStartDeliveryRouteScreen` — real route and stop context, no fake default trip.
  - **07.00B**: Clarified in backend summary; no standalone spec file found in repository. Components are shared without fabricating speculative visual designs.
  - **07.01**: `DriverActiveDeliveryTrackingScreen` — live route, arrival confirmation (arrives only, does not deliver).
  - **07.02**: `DriverDeliveryArrivalConfirmationScreen` — arrival banner, optional 4-digit driver-entered OTP, required camera proof photo upload, delivery confirmation.
  - **07.06**: `DriverDeliverySuccessScreen` — displays actual delivery result, navigates based on actual server route refresh.

---

## 2. API Contract Checklist

### 2.1 Map Route & Stop Fetching
- **Endpoint:** `GET /api/v1/driver/map/route`
- **With query:** `GET /api/v1/driver/map/route?focusedStopId={stopId}`
- **Headers:** Bearer `<driver-token>`, `Accept-Language`
- **Fields added to Stop:**
  - `boxId`: String (alias for stopId in contract)
  - `tripId`: String? (trip identifier)
  - `customerNote`: String? (delivery instructions)
  - `arrivedAtUtc`: DateTime? (first arrival timestamp)
- **Policy:** `customerPhone` remains strictly empty in driver map according to privacy rules.

### 2.2 Customer Arrival
- **Endpoint:** `POST /api/v1/driver/orders/{boxId}/arrive-customer`
- **Request Body:** `{ "latitude": double?, "longitude": double? }`
- **Behavior:** Records `arrivedAtUtc`, returns `isFirstArrival`. Does NOT trigger delivery.

### 2.3 Delivery Proof Upload
- **Endpoint:** `POST /api/v1/uploads` (Multipart)
- **Part Name:** `file`
- **Replaces:** `POST /api/v1/driver/orders/proof-photo/upload`
- **Implementation:** Abstraction layer with `DriverDeliveryRemoteDataSource` / `DriverDeliveryRepository` supports proof upload returning a non-empty `storageKey` (falling back to `url`, `fileUrl`, `key`, or `path`). End-to-end verified via test doubles and live endpoint.

### 2.4 Order Delivery
- **Endpoint:** `POST /api/v1/driver/orders/{boxId}/deliver`
- **Request Body:**
  ```json
  {
    "proofPhotoStorageKey": "<key>",
    "latitude": double?,
    "longitude": double?,
    "deliveryOtp": string?
  }
  ```
- **Response Fields:** `boxId`, `deliveredAtUtc`, `tripId`, `isTripCompleted`, `remainingStopsCount`, `driverId`, `isFirstDelivery`.
- **Idempotency:** Re-delivering returns original timestamp with `isFirstDelivery: false`.

### 2.5 OTP Policy
- 4-digit code entered by the driver if provided by customer.
- **100% Optional:** Empty or partial code does not block delivery.
- Backend does not verify OTP yet; UI clearly indicates that verification is currently unavailable and delivery is validated via proof photo.

---

## 3. Environment & Deployment Notice
- Backend updates are currently marked as **NOT deployed**.
- Base URL is preserved (`NetworkConstants.baseUrl`).
- Verification is accomplished through automated unit, mapper, repository, and widget tests without altering remote production database.
