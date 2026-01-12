# Leave Application - API Specifications

## Endpoints

### 1. Get Leave Requests
**Endpoint**: `GET /leave-requests`

**Description**: Fetches leave requests with optional user filtering

**Query Parameters**:
- `user_id` (optional, string): Filter by specific user ID. If not provided (admin/expat), returns all requests.

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Example**:
```http
GET /leave-requests?user_id=123
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response Success (200)**:
```json
{
  "data": [
    {
      "id": "leave_001",
      "user_id": "123",
      "user_name": "Rahul",
      "start_date": "2025-08-15T00:00:00Z",
      "end_date": "2025-08-17T00:00:00Z",
      "start_time": "2025-08-15T09:00:00Z",
      "end_time": "2025-08-17T18:00:00Z",
      "status": "pending",
      "reason": "Personal work",
      "admin_note": null,
      "created_at": "2025-08-10T10:00:00Z",
      "updated_at": null
    },
    {
      "id": "leave_002",
      "user_id": "123",
      "user_name": "Rahul",
      "start_date": "2025-08-20T00:00:00Z",
      "end_date": "2025-08-20T00:00:00Z",
      "start_time": "2025-08-20T10:00:00Z",
      "end_time": "2025-08-20T14:00:00Z",
      "status": "approved",
      "reason": "Medical appointment",
      "admin_note": "Approved",
      "created_at": "2025-08-12T09:00:00Z",
      "updated_at": "2025-08-12T14:30:00Z"
    }
  ]
}
```

**Response Error (400/401/500)**:
```json
{
  "message": "Failed to fetch leave requests",
  "error": "Error details"
}
```

---

### 2. Apply Leave
**Endpoint**: `POST /leave-requests`

**Description**: Submit a new leave request

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body**:
```json
{
  "user_id": "123",
  "user_name": "Rahul",
  "start_date": "2025-08-15T00:00:00Z",
  "end_date": "2025-08-17T00:00:00Z",
  "start_time": "2025-08-15T09:00:00Z",
  "end_time": "2025-08-17T18:00:00Z",
  "reason": "Personal work"
}
```

**Request Example**:
```http
POST /leave-requests
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "user_id": "123",
  "user_name": "Rahul",
  "start_date": "2025-08-15T00:00:00Z",
  "end_date": "2025-08-17T00:00:00Z",
  "start_time": "2025-08-15T09:00:00Z",
  "end_time": "2025-08-17T18:00:00Z"
}
```

**Response Success (200/201)**:
```json
{
  "data": {
    "id": "leave_003",
    "user_id": "123",
    "user_name": "Rahul",
    "start_date": "2025-08-15T00:00:00Z",
    "end_date": "2025-08-17T00:00:00Z",
    "start_time": "2025-08-15T09:00:00Z",
    "end_time": "2025-08-17T18:00:00Z",
    "status": "pending",
    "reason": null,
    "admin_note": null,
    "created_at": "2025-08-14T10:00:00Z",
    "updated_at": null
  }
}
```

**Response Error (400/401/500)**:
```json
{
  "message": "Failed to apply leave",
  "error": "Error details"
}
```

---

### 3. Update Leave Status
**Endpoint**: `PATCH /leave-requests/{leave_id}/status`

**Description**: Update leave request status (approve/reject) - Admin/Expat only

**Path Parameters**:
- `leave_id` (string): Leave request ID

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body**:
```json
{
  "status": "approved",
  "admin_note": "Approved - No conflicts"
}
```

**Request Example**:
```http
PATCH /leave-requests/leave_001/status
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "status": "rejected",
  "admin_note": "Not enough drivers available"
}
```

**Response Success (200)**:
```json
{
  "data": {
    "id": "leave_001",
    "user_id": "123",
    "user_name": "Rahul",
    "start_date": "2025-08-15T00:00:00Z",
    "end_date": "2025-08-17T00:00:00Z",
    "start_time": "2025-08-15T09:00:00Z",
    "end_time": "2025-08-17T18:00:00Z",
    "status": "rejected",
    "reason": "Personal work",
    "admin_note": "Not enough drivers available",
    "created_at": "2025-08-10T10:00:00Z",
    "updated_at": "2025-08-14T15:00:00Z"
  }
}
```

**Response Error (400/401/403/500)**:
```json
{
  "message": "Failed to update leave status",
  "error": "Error details"
}
```

---

## Data Models

### LeaveRequest
```dart
{
  "id": string,                    // Unique leave request ID
  "user_id": string,              // User ID who requested leave
  "user_name": string,            // User name
  "start_date": ISO8601 string,   // Start date of leave
  "end_date": ISO8601 string,     // End date of leave
  "start_time": ISO8601 string,    // Start time of leave
  "end_time": ISO8601 string,     // End time of leave
  "status": "pending" | "approved" | "rejected",
  "reason": string | null,         // Optional reason for leave
  "admin_note": string | null,    // Admin note (for approved/rejected)
  "created_at": ISO8601 string,   // Creation timestamp
  "updated_at": ISO8601 string | null  // Last update timestamp
}
```

## Status Values
- **"pending"**: Leave request submitted, awaiting approval
- **"approved"**: Leave request approved by admin/expat
- **"rejected"**: Leave request rejected by admin/expat

## Error Handling

### Network Errors
- **Connection Timeout**: Shows toast message "Connection timeout. Please check your internet."
- **No Internet**: Shows toast message "No internet connection"
- **Server Error**: Shows toast message with server error message

### Validation Errors
- **400 Bad Request**: Shows toast message with validation error details
- **401 Unauthorized**: Should redirect to login screen
- **403 Forbidden**: Shows toast message "Access denied" (for non-admin users trying to update status)

## Usage Flow

### For Driver Users:
1. Navigate to Leave List Screen → Shows only their own leave requests
2. Tap "+" button → Opens Apply Leave Screen
3. Fill form → Submit → Returns to Leave List Screen
4. View status updates from admin

### For Expat/Admin Users:
1. Navigate to Leave List Screen → Shows all leave requests
2. Tap "+" button → Opens Apply Leave Screen (can apply on behalf of others)
3. View pending requests → Tap Approve/Reject → Confirm → Status updated
4. Can add notes when rejecting

## Date/Time Format
- **API**: ISO 8601 format (e.g., "2025-08-15T09:00:00Z")
- **Display**: 
  - Date: DD-MMM-YYYY format (e.g., "15-Aug-2025")
  - Time: hh:mm AM/PM format (e.g., "09:00 AM")

