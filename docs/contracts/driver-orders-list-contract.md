# Driver Orders List Backend & Realtime Contract (Screen 05.05)

## 1. REST Endpoints

### 1.1 Driver Orders Manifest
- **Route:** `GET /api/v1/driver/orders`
- **Query Parameters:**
  - `statusFilter`: `All` | `InProgress` | `Delivered` | `Failed` (default: `All`)
  - `search`: optional trimmed query string
- **Authorization:** Bearer token (Driver role)
- **Response Format:** `200 OK`
```json
{
  "tripId": "7ea85f64-5717-4562-b3fc-2c963f66af10",
  "tripCode": "TRP-48-8752",
  "tripStatus": "InProgress",
  "tripStatusText": "خارج للتوصيل",
  "serverTimeUtc": "2026-09-27T08:10:00Z",
  "counts": {
    "total": 8,
    "inProgress": 2,
    "delivered": 5,
    "failed": 1
  },
  "stops": [
    {
      "tripStopId": "stop-guid",
      "boxId": "box-guid",
      "boxCode": "BX-458622",
      "sequenceNumber": 2,
      "customerName": "محمد علي",
      "deliveryZone": "السالمية",
      "formattedAddress": "السالمية - ق 12، شارع الخليج، م 45",
      "latitude": 29.3375,
      "longitude": 48.0758,
      "mealsCount": 4,
      "mealsSummary": "4 وجبات (غداء عائلي)",
      "deliveryTimeSlot": "09:30 ص",
      "status": "InProgress",
      "statusText": "قيد التوصيل الآن",
      "deliveredAtUtc": null,
      "failureReasonCategory": null,
      "failureReasonText": null,
      "isCurrentStop": true,
      "canCompleteDelivery": true,
      "canNavigate": true,
      "canCallCustomer": true,
      "maskedPhoneNumber": null
    }
  ]
}
```
- **Empty State (No Active Trip):**
  - Status 200 OK with:
  ```json
  {
    "tripId": null,
    "tripCode": null,
    "tripStatus": null,
    "tripStatusText": null,
    "serverTimeUtc": "2026-09-27T08:10:00Z",
    "counts": {
      "total": 0,
      "inProgress": 0,
      "delivered": 0,
      "failed": 0
    },
    "stops": []
  }
  ```

### 1.2 Call Proxy
- **Route:** `GET /api/v1/driver/orders/{boxId}/call-proxy`
- **Path Parameters:** `boxId` (UUID)
- **Response Format:** `200 OK`
```json
{
  "boxId": "box-guid",
  "callableUri": "tel:+96512345678",
  "phoneNumber": "+96512345678",
  "expiresAtUtc": "2026-09-27T08:25:00Z"
}
```

## 2. SignalR Hub & Events

- **Hub URL:** `/hubs/driver`
- **Authentication:** Bearer token passed via `access_token` query parameter or `accessTokenFactory`
- **Events:**
  - `box-delivered`
  - `delivery-failed`
  - `driver-arrived-at-customer`
  - `driver-requested-reassignment`
  - `trip-in-transit`

### Event Payload Structure
All events include deduplication metadata:
```json
{
  "eventId": "event-guid",
  "tripId": "trip-guid",
  "boxId": "box-guid",
  "tripStopId": "stop-guid",
  "status": "Delivered",
  "statusText": "تم التسليم",
  "occurredAtUtc": "2026-09-27T08:15:00Z",
  "failureReasonCategory": null,
  "failureReasonText": null
}
```
