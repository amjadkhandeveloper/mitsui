# Attendance Screen - API Specifications

## Endpoints

### 1. Get Attendance Records
**Endpoint**: `GET /attendance`

**Description**: Fetches attendance records with optional filtering

**Query Parameters**:
- `driver_id` (optional, string): Filter by specific driver ID
- `start_date` (optional, ISO 8601 string): Start date for date range filter
- `end_date` (optional, ISO 8601 string): End date for date range filter

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Example**:
```http
GET /attendance?driver_id=123&start_date=2025-08-01T00:00:00Z&end_date=2025-08-31T23:59:59Z
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response Success (200)**:
```json
{
  "data": [
    {
      "id": "att_001",
      "driver_id": "123",
      "driver_name": "Rahul",
      "date": "2025-08-01T00:00:00Z",
      "status": "present",
      "check_in_time": "2025-08-01T09:00:00Z",
      "check_out_time": "2025-08-01T18:00:00Z",
      "location": "Office"
    },
    {
      "id": "att_002",
      "driver_id": "123",
      "driver_name": "Rahul",
      "date": "2025-08-02T00:00:00Z",
      "status": "absent",
      "check_in_time": null,
      "check_out_time": null,
      "location": null
    }
  ]
}
```

**Response Error (400/401/500)**:
```json
{
  "message": "Failed to fetch attendance records",
  "error": "Error details"
}
```

---

### 2. Get Drivers List
**Endpoint**: `GET /drivers`

**Description**: Fetches list of all drivers (for expat users)

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Example**:
```http
GET /drivers
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response Success (200)**:
```json
{
  "data": [
    {
      "id": "123",
      "name": "Rahul",
      "email": "rahul@example.com",
      "phone": "+1234567890"
    },
    {
      "id": "124",
      "name": "Amit",
      "email": "amit@example.com",
      "phone": "+1234567891"
    }
  ]
}
```

**Response Error (400/401/500)**:
```json
{
  "message": "Failed to fetch drivers",
  "error": "Error details"
}
```

---

## Data Models

### AttendanceRecord
```dart
{
  "id": string,              // Unique attendance record ID
  "driver_id": string,       // Driver ID
  "driver_name": string,     // Driver name
  "date": ISO8601 string,    // Date of attendance
  "status": "present" | "absent",
  "check_in_time": ISO8601 string | null,
  "check_out_time": ISO8601 string | null,
  "location": string | null
}
```

### Driver
```dart
{
  "id": string,              // Unique driver ID
  "name": string,            // Driver name
  "email": string | null,    // Driver email
  "phone": string | null     // Driver phone number
}
```

## Error Handling

### Network Errors
- **Connection Timeout**: Shows toast message "Connection timeout. Please check your internet."
- **No Internet**: Shows toast message "No internet connection"
- **Server Error**: Shows toast message with server error message

### Authentication Errors
- **401 Unauthorized**: Should redirect to login screen
- **403 Forbidden**: Shows toast message "Access denied"

## Usage Flow

### For Expat Users:
1. Screen loads → Calls `GET /drivers` to populate dropdown
2. User selects driver → Calls `GET /attendance?driver_id={id}`
3. User selects "All Drivers" → Calls `GET /attendance` (no driver_id)

### For Driver Users:
1. Screen loads → Calls `GET /attendance?driver_id={current_user_id}`
2. Displays only their own attendance records

## Date Format
- **API**: ISO 8601 format (e.g., "2025-08-01T00:00:00Z")
- **Display**: DD-MMM-YYYY format (e.g., "01-Aug-2025")

## Status Values
- **"present"**: Driver was present on that date
- **"absent"**: Driver was absent on that date

