# Attendance Report - API Specifications

## Endpoints

### 1. Get Attendance Report
**Endpoint**: `GET /attendance-report`

**Description**: Fetches monthly attendance report with daily records

**Query Parameters**:
- `driver_id` (optional, string): Filter by specific driver ID. If not provided and user is admin/expat, returns report for all drivers or selected driver.
- `month` (optional, integer): Month (1-12). Defaults to current month.
- `year` (optional, integer): Year (e.g., 2025). Defaults to current year.

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Example**:
```http
GET /attendance-report?driver_id=123&month=8&year=2025
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response Success (200)**:
```json
{
  "data": {
    "total_days": 31,
    "present_days": 25,
    "absent_days": 3,
    "leave_days": 3,
    "attendance_rate": 80.65,
    "total_hours": 200,
    "daily_records": [
      {
        "date": "2025-08-01T00:00:00Z",
        "status": "present",
        "check_in_time": "2025-08-01T09:00:00Z",
        "check_out_time": "2025-08-01T18:00:00Z",
        "total_hours": 8,
        "overtime": 0
      },
      {
        "date": "2025-08-02T00:00:00Z",
        "status": "present",
        "check_in_time": "2025-08-02T09:00:00Z",
        "check_out_time": "2025-08-02T20:00:00Z",
        "total_hours": 11,
        "overtime": 3
      },
      {
        "date": "2025-08-03T00:00:00Z",
        "status": "absent",
        "check_in_time": null,
        "check_out_time": null,
        "total_hours": null,
        "overtime": null
      },
      {
        "date": "2025-08-04T00:00:00Z",
        "status": "present",
        "check_in_time": "2025-08-04T09:00:00Z",
        "check_out_time": "2025-08-04T18:00:00Z",
        "total_hours": 8,
        "overtime": 0
      },
      {
        "date": "2025-08-15T00:00:00Z",
        "status": "present",
        "check_in_time": "2025-08-15T09:00:00Z",
        "check_out_time": null,
        "total_hours": null,
        "overtime": null
      }
    ]
  }
}
```

**Response Error (400/401/500)**:
```json
{
  "message": "Failed to fetch attendance report",
  "error": "Error details"
}
```

---

## Data Models

### AttendanceReport
```json
{
  "total_days": "integer",              // Total days in the month
  "present_days": "integer",           // Number of days present
  "absent_days": "integer",            // Number of days absent
  "leave_days": "integer",             // Number of days on leave
  "attendance_rate": "number",         // Attendance rate percentage (0-100)
  "total_hours": "integer",            // Total working hours in seconds (Duration)
  "daily_records": "array"             // Array of DailyAttendanceRecord
}
```

### DailyAttendanceRecord
```json
{
  "date": "ISO8601 string",            // Date of record (date only)
  "status": "present" | "absent",      // Attendance status
  "check_in_time": "ISO8601 string | null",    // Check-in time
  "check_out_time": "ISO8601 string | null",   // Check-out time
  "total_hours": "integer | null",     // Total hours worked in seconds (Duration)
  "overtime": "integer | null"         // Overtime hours in seconds (Duration)
}
```

## Status Values
- **"present"**: Driver was present on that date
- **"absent"**: Driver was absent on that date

## Calculations

### Attendance Rate
```
attendance_rate = (present_days / total_days) * 100
```

### Total Hours
- Sum of all `total_hours` from daily records where status is "present"
- Expressed in seconds (Duration format)

### Overtime
- Hours worked beyond standard working hours (e.g., 8 hours)
- Expressed in seconds (Duration format)

## Error Handling

### Network Errors
- **Connection Timeout**: Shows toast message "Connection timeout. Please check your internet."
- **No Internet**: Shows toast message "No internet connection"
- **Server Error**: Shows toast message with server error message

### Validation Errors
- **400 Bad Request**: Shows toast message with validation error details
  - Invalid month (must be 1-12)
  - Invalid year
- **401 Unauthorized**: Should redirect to login screen
- **403 Forbidden**: Shows toast message "Access denied"

## Usage Flow

### Attendance Report Screen:
1. **Screen Loads**: 
   - Defaults to current month/year
   - Calls `GET /attendance-report?month={current_month}&year={current_year}`
   - If expat user, shows driver dropdown first

2. **Select Driver** (Expat users only):
   - User selects driver from dropdown
   - Calls `GET /attendance-report?driver_id={driver_id}&month={month}&year={year}`

3. **Change Month/Year**:
   - User selects different month/year from filters
   - Calls `GET /attendance-report?driver_id={driver_id}&month={month}&year={year}` with new values

4. **Display Report**:
   - Shows summary cards: Total Days, Present Days, Absent Days, Leave Days, Attendance Rate
   - Shows total hours worked
   - Shows daily records list with date, status, check-in/out times, hours worked

## Date Format
- **API**: ISO 8601 format (e.g., "2025-08-01T00:00:00Z")
- **Display**: 
  - Date: DD-MMM-YYYY format (e.g., "01-Aug-2025")
  - Time: hh:mm AM/PM format (e.g., "09:00 AM")
  - Duration: HH:mm format (e.g., "08:00" for 8 hours)

## Duration Format
- **API**: Duration is represented as integer (seconds)
  - Example: `"total_hours": 28800` represents 8 hours (8 * 60 * 60 = 28800 seconds)
- **Display**: Convert to hours:minutes format
  - Example: `28800` seconds = `8:00` hours

## Notes
- `total_days` includes all days in the selected month (including weekends)
- `present_days` + `absent_days` + `leave_days` should equal `total_days` (or less if month is not complete)
- `daily_records` should include all days in the month, even if there's no attendance record
- For days with no check-in/check-out, `check_in_time` and `check_out_time` are null
- `total_hours` and `overtime` are null for absent days
- `total_hours` may be null for present days if check-out hasn't happened yet
- Attendance rate is calculated as: `(present_days / total_days) * 100`
- For driver users, `driver_id` is automatically set from the authentication token

