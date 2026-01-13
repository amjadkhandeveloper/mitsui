# Vehicle Schedule - API Specifications

## Endpoints

### 1. Get Trips by Date
**Endpoint**: `GET /vehicle-schedule/trips`

**Description**: Fetches trips scheduled for a specific date

**Query Parameters**:
- `date` (required, ISO 8601 string): Date to fetch trips for (format: YYYY-MM-DD or ISO 8601)

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Example**:
```http
GET /vehicle-schedule/trips?date=2025-08-15
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response Success (200)**:
```json
{
  "data": [
    {
      "id": "trip_001",
      "vehicle_id": "veh_001",
      "vehicle_name": "Toyota Camry",
      "date": "2025-08-15T00:00:00Z",
      "start_time": "2025-08-15T09:00:00Z",
      "end_time": "2025-08-15T17:00:00Z",
      "status": "pending",
      "driver_id": "123",
      "driver_name": "John Doe",
      "destination": "Airport",
      "purpose": "Customer pickup",
      "created_at": "2025-08-10T10:00:00Z",
      "updated_at": null
    },
    {
      "id": "trip_002",
      "vehicle_id": "veh_002",
      "vehicle_name": "Honda Accord",
      "date": "2025-08-15T00:00:00Z",
      "start_time": "2025-08-15T10:00:00Z",
      "end_time": "2025-08-15T14:00:00Z",
      "status": "accepted",
      "driver_id": "124",
      "driver_name": "Jane Smith",
      "destination": "Downtown",
      "purpose": "Business meeting",
      "created_at": "2025-08-11T09:00:00Z",
      "updated_at": "2025-08-12T11:00:00Z"
    }
  ]
}
```

**Response Error (400/401/500)**:
```json
{
  "message": "Failed to fetch trips",
  "error": "Error details"
}
```

---

### 2. Update Trip Status
**Endpoint**: `PATCH /vehicle-schedule/trips/{trip_id}/status`

**Description**: Update trip status (accept/reject) - Note: This endpoint may not be used if status updates are handled elsewhere

**Path Parameters**:
- `trip_id` (string): Trip ID

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body**:
```json
{
  "status": "accepted"
}
```

**Request Example**:
```http
PATCH /vehicle-schedule/trips/trip_001/status
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "status": "rejected"
}
```

**Response Success (200)**:
```json
{
  "data": {
    "id": "trip_001",
    "vehicle_id": "veh_001",
    "vehicle_name": "Toyota Camry",
    "date": "2025-08-15T00:00:00Z",
    "start_time": "2025-08-15T09:00:00Z",
    "end_time": "2025-08-15T17:00:00Z",
    "status": "rejected",
    "driver_id": "123",
    "driver_name": "John Doe",
    "destination": "Airport",
    "purpose": "Customer pickup",
    "created_at": "2025-08-10T10:00:00Z",
    "updated_at": "2025-08-14T15:00:00Z"
  }
}
```

**Response Error (400/401/403/500)**:
```json
{
  "message": "Failed to update trip status",
  "error": "Error details"
}
```

---

### 3. Create Free Slot
**Endpoint**: `POST /vehicle-schedule/free-slots`

**Description**: Create a new free slot for vehicle availability

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body**:
```json
{
  "vehicle_id": "veh_001",
  "vehicle_name": "Toyota Camry",
  "date": "2025-08-20T00:00:00Z",
  "start_time": "2025-08-20T09:00:00Z",
  "end_time": "2025-08-20T17:00:00Z",
  "notes": "Available for booking"
}
```

**Request Example**:
```http
POST /vehicle-schedule/free-slots
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "vehicle_id": "veh_001",
  "vehicle_name": "Toyota Camry",
  "date": "2025-08-20T00:00:00Z",
  "start_time": "2025-08-20T09:00:00Z",
  "end_time": "2025-08-20T17:00:00Z",
  "notes": "Available for booking"
}
```

**Response Success (200/201)**:
```json
{
  "data": {
    "id": "slot_001",
    "vehicle_id": "veh_001",
    "vehicle_name": "Toyota Camry",
    "date": "2025-08-20T00:00:00Z",
    "start_time": "2025-08-20T09:00:00Z",
    "end_time": "2025-08-20T17:00:00Z",
    "notes": "Available for booking",
    "created_at": "2025-08-14T10:00:00Z"
  }
}
```

**Response Error (400/401/500)**:
```json
{
  "message": "Failed to create free slot",
  "error": "Error details"
}
```

---

## Data Models

### Trip (Vehicle Schedule)
```json
{
  "id": "string",                    // Unique trip ID
  "vehicle_id": "string",            // Vehicle ID
  "vehicle_name": "string",         // Vehicle name/identifier
  "date": "ISO8601 string",         // Date of trip (date only, time set to 00:00:00)
  "start_time": "ISO8601 string",   // Start time of trip
  "end_time": "ISO8601 string",     // End time of trip
  "status": "pending" | "accepted" | "rejected",
  "driver_id": "string | null",     // Assigned driver ID (optional)
  "driver_name": "string | null",   // Assigned driver name (optional)
  "destination": "string | null",   // Trip destination (optional)
  "purpose": "string | null",       // Trip purpose (optional)
  "created_at": "ISO8601 string",   // Creation timestamp
  "updated_at": "ISO8601 string | null"  // Last update timestamp
}
```

### FreeSlot
```json
{
  "id": "string",                    // Unique free slot ID
  "vehicle_id": "string",          // Vehicle ID
  "vehicle_name": "string",        // Vehicle name/identifier
  "date": "ISO8601 string",        // Date of free slot (date only)
  "start_time": "ISO8601 string",  // Start time of free slot
  "end_time": "ISO8601 string",    // End time of free slot
  "notes": "string | null",        // Optional notes
  "created_at": "ISO8601 string"   // Creation timestamp
}
```

## Status Values
- **"pending"**: Trip assigned but not yet accepted/rejected (shown as "Assigned" in UI)
- **"accepted"**: Trip accepted by driver
- **"rejected"**: Trip rejected by driver

## Error Handling

### Network Errors
- **Connection Timeout**: Shows toast message "Connection timeout. Please check your internet."
- **No Internet**: Shows toast message "No internet connection"
- **Server Error**: Shows toast message with server error message

### Validation Errors
- **400 Bad Request**: Shows toast message with validation error details
- **401 Unauthorized**: Should redirect to login screen
- **403 Forbidden**: Shows toast message "Access denied"

## Usage Flow

1. **Screen Loads**: 
   - Calendar displays current month
   - Default selected date is today (or earliest available future date)
   - Calls `GET /vehicle-schedule/trips?date={selected_date}`

2. **Date Selection**:
   - User selects a date on calendar (only today and future dates allowed)
   - Calls `GET /vehicle-schedule/trips?date={selected_date}` with new date
   - Displays trips for selected date

3. **View Trips**:
   - Trips displayed as cards with status badges
   - Status badges show: "Assigned" (pending), "Accepted", "Rejected"
   - No action buttons (status is read-only)

4. **Add Free Slot**:
   - User taps "Add Free Slot" button
   - Fills form with vehicle, date, start time, end time, notes
   - Submits → Calls `POST /vehicle-schedule/free-slots`
   - Returns to schedule screen

## Date/Time Format
- **API**: ISO 8601 format (e.g., "2025-08-15T09:00:00Z")
- **Display**: 
  - Date: DD-MMM-YYYY format (e.g., "15-Aug-2025")
  - Time: hh:mm AM/PM format (e.g., "09:00 AM")

## Calendar Constraints
- **Minimum Date**: Today (past dates cannot be selected)
- **Maximum Date**: Configurable (e.g., 1 year from today)
- **Disabled Dates**: All dates before today

## Notes
- The calendar should mark dates that have trips scheduled
- Trips are displayed in chronological order (earliest start time first)
- Free slots are separate from trips and may be displayed differently

