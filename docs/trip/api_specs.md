# Trip Management - API Specifications

## Endpoints

### 1. Get Trips by Driver
**Endpoint**: `GET /trips`

**Description**: Fetches trips for the current driver or all trips (for admin/expat)

**Query Parameters**:
- `driver_id` (optional, string): Filter by specific driver ID. If not provided and user is admin/expat, returns all trips.

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Example**:
```http
GET /trips?driver_id=123
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
      "route": "Route A",
      "customer": "ABC Company",
      "location": "Downtown Office",
      "pickup_drop": "PICK UP",
      "schedule_start": "2025-08-15T09:00:00Z",
      "actual_start": null,
      "actual_end": null,
      "status": "scheduled",
      "trip_start_odometer": null,
      "trip_end_odometer": null,
      "driver_id": "123",
      "driver_name": "John Doe",
      "created_at": "2025-08-10T10:00:00Z",
      "updated_at": null
    },
    {
      "id": "trip_002",
      "vehicle_id": "veh_002",
      "vehicle_name": "Honda Accord",
      "route": "Route B",
      "customer": "XYZ Corp",
      "location": "Airport",
      "pickup_drop": "DROP",
      "schedule_start": "2025-08-16T14:00:00Z",
      "actual_start": "2025-08-16T14:05:00Z",
      "actual_end": null,
      "status": "started",
      "trip_start_odometer": 50000,
      "trip_end_odometer": null,
      "driver_id": "123",
      "driver_name": "John Doe",
      "created_at": "2025-08-11T09:00:00Z",
      "updated_at": "2025-08-16T14:05:00Z"
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

### 2. Get Trip Detail
**Endpoint**: `GET /trips/{trip_id}`

**Description**: Fetches detailed information about a specific trip

**Path Parameters**:
- `trip_id` (string): Trip ID

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Example**:
```http
GET /trips/trip_001
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response Success (200)**:
```json
{
  "data": {
    "id": "trip_001",
    "vehicle_id": "veh_001",
    "vehicle_name": "Toyota Camry",
    "route": "Route A",
    "customer": "ABC Company",
    "location": "Downtown Office",
    "pickup_drop": "PICK UP",
    "schedule_start": "2025-08-15T09:00:00Z",
    "actual_start": null,
    "actual_end": null,
    "status": "scheduled",
    "trip_start_odometer": null,
    "trip_end_odometer": null,
    "driver_id": "123",
    "driver_name": "John Doe",
    "created_at": "2025-08-10T10:00:00Z",
    "updated_at": null
  }
}
```

**Response Error (400/401/404/500)**:
```json
{
  "message": "Trip not found",
  "error": "Error details"
}
```

---

### 3. Start Trip
**Endpoint**: `POST /trips/{trip_id}/start`

**Description**: Start a trip (mark trip as started and record start odometer reading)

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
  "trip_start_odometer": 50000
}
```

**Request Example**:
```http
POST /trips/trip_001/start
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "trip_start_odometer": 50000
}
```

**Response Success (200)**:
```json
{
  "data": {
    "id": "trip_001",
    "vehicle_id": "veh_001",
    "vehicle_name": "Toyota Camry",
    "route": "Route A",
    "customer": "ABC Company",
    "location": "Downtown Office",
    "pickup_drop": "PICK UP",
    "schedule_start": "2025-08-15T09:00:00Z",
    "actual_start": "2025-08-15T09:05:00Z",
    "actual_end": null,
    "status": "started",
    "trip_start_odometer": 50000,
    "trip_end_odometer": null,
    "driver_id": "123",
    "driver_name": "John Doe",
    "created_at": "2025-08-10T10:00:00Z",
    "updated_at": "2025-08-15T09:05:00Z"
  }
}
```

**Response Error (400/401/403/500)**:
```json
{
  "message": "Failed to start trip",
  "error": "Error details"
}
```

---

### 4. End Trip
**Endpoint**: `POST /trips/{trip_id}/end`

**Description**: End a trip (mark trip as completed and record end odometer reading)

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
  "trip_end_odometer": 50150
}
```

**Request Example**:
```http
POST /trips/trip_001/end
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "trip_end_odometer": 50150
}
```

**Response Success (200)**:
```json
{
  "data": {
    "id": "trip_001",
    "vehicle_id": "veh_001",
    "vehicle_name": "Toyota Camry",
    "route": "Route A",
    "customer": "ABC Company",
    "location": "Downtown Office",
    "pickup_drop": "PICK UP",
    "schedule_start": "2025-08-15T09:00:00Z",
    "actual_start": "2025-08-15T09:05:00Z",
    "actual_end": "2025-08-15T17:30:00Z",
    "status": "completed",
    "trip_start_odometer": 50000,
    "trip_end_odometer": 50150,
    "driver_id": "123",
    "driver_name": "John Doe",
    "created_at": "2025-08-10T10:00:00Z",
    "updated_at": "2025-08-15T17:30:00Z"
  }
}
```

**Response Error (400/401/403/500)**:
```json
{
  "message": "Failed to end trip",
  "error": "Error details"
}
```

---

## Data Models

### TripDetail
```json
{
  "id": "string",                          // Unique trip ID
  "vehicle_id": "string",                  // Vehicle ID
  "vehicle_name": "string",                // Vehicle name/identifier
  "route": "string | null",               // Route name/identifier (optional)
  "customer": "string | null",             // Customer name (optional)
  "location": "string | null",              // Location/address (optional)
  "pickup_drop": "PICK UP" | "DROP" | null,  // Trip type (optional)
  "schedule_start": "ISO8601 string",      // Scheduled start time
  "actual_start": "ISO8601 string | null", // Actual start time (set when trip starts)
  "actual_end": "ISO8601 string | null",   // Actual end time (set when trip ends)
  "status": "scheduled" | "started" | "completed" | "cancelled",
  "trip_start_odometer": "integer | null", // Odometer reading at trip start
  "trip_end_odometer": "integer | null",   // Odometer reading at trip end
  "driver_id": "string | null",            // Driver ID (optional)
  "driver_name": "string | null",          // Driver name (optional)
  "created_at": "ISO8601 string",          // Creation timestamp
  "updated_at": "ISO8601 string | null"    // Last update timestamp
}
```

## Status Values
- **"scheduled"**: Trip is scheduled but not yet started
- **"started"**: Trip has been started (actual_start and trip_start_odometer are set)
- **"completed"**: Trip has been completed (actual_end and trip_end_odometer are set)
- **"cancelled"**: Trip was cancelled

## Error Handling

### Network Errors
- **Connection Timeout**: Shows toast message "Connection timeout. Please check your internet."
- **No Internet**: Shows toast message "No internet connection"
- **Server Error**: Shows toast message with server error message

### Validation Errors
- **400 Bad Request**: Shows toast message with validation error details
  - Invalid odometer reading (must be positive integer)
  - Trip already started/completed
- **401 Unauthorized**: Should redirect to login screen
- **403 Forbidden**: Shows toast message "Access denied"
- **404 Not Found**: Shows toast message "Trip not found"

## Usage Flow

### Trip List Screen:
1. **Screen Loads**: 
   - Calls `GET /trips` (with driver_id if driver user)
   - Displays list of trips

2. **Trip Selection**:
   - User taps on a trip card
   - Navigates to Trip Detail Screen with trip_id

### Trip Detail Screen:
1. **Screen Loads**: 
   - Calls `GET /trips/{trip_id}`
   - Displays trip information

2. **Start Trip** (if status is "scheduled"):
   - User enters trip start odometer reading
   - Taps "Start Trip" button
   - Calls `POST /trips/{trip_id}/start` with odometer reading
   - Status updates to "started"
   - Actual start time is set automatically by server

3. **End Trip** (if status is "started"):
   - User enters trip end odometer reading
   - Taps "End Trip" button
   - Calls `POST /trips/{trip_id}/end` with odometer reading
   - Status updates to "completed"
   - Actual end time is set automatically by server

## Date/Time Format
- **API**: ISO 8601 format (e.g., "2025-08-15T09:00:00Z")
- **Display**: 
  - Date: DD-MMM-YYYY format (e.g., "15-Aug-2025")
  - Time: hh:mm AM/PM format (e.g., "09:00 AM")

## Odometer Reading
- **Format**: Integer (kilometers or miles)
- **Validation**: Must be positive integer
- **Start Odometer**: Required when starting trip
- **End Odometer**: Required when ending trip
- **End Odometer**: Should be greater than or equal to start odometer

## Notes
- Only trips with status "scheduled" can be started
- Only trips with status "started" can be ended
- Odometer readings are required for both start and end actions
- Actual start/end times are set automatically by the server when trip is started/ended
- Trip distance can be calculated as: `trip_end_odometer - trip_start_odometer`

