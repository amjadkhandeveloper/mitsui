# API Specifications Index

This document provides an index to all API specifications for the Mitsui Fleet Management System. Each feature has its own detailed API specification document.

## Overview

All API endpoints require authentication via Bearer token in the Authorization header:
```
Authorization: Bearer {token}
```

Base URL: `https://api.example.com` (configurable via `AppConfig.BASE_URL`)

## API Specification Documents

### 1. Authentication & User Management
- **Document**: [`login_screen/api_specs.md`](./login_screen/api_specs.md)
- **Endpoints**:
  - `POST /auth/login` - User login
- **Key Models**: User (with role and name)

### 2. Attendance Management
- **Document**: [`attendance_screen/api_specs.md`](./attendance_screen/api_specs.md)
- **Endpoints**:
  - `GET /attendance` - Get attendance records
  - `GET /drivers` - Get drivers list
- **Key Models**: AttendanceRecord, Driver

### 3. Leave Management
- **Document**: [`leave_screen/api_specs.md`](./leave_screen/api_specs.md)
- **Endpoints**:
  - `GET /leave-requests` - Get leave requests
  - `POST /leave-requests` - Apply for leave
  - `PATCH /leave-requests/{leave_id}/status` - Update leave status (Admin/Expat)
- **Key Models**: LeaveRequest

### 4. Vehicle Schedule
- **Document**: [`vehicle_schedule/api_specs.md`](./vehicle_schedule/api_specs.md)
- **Endpoints**:
  - `GET /vehicle-schedule/trips` - Get trips by date
  - `PATCH /vehicle-schedule/trips/{trip_id}/status` - Update trip status
  - `POST /vehicle-schedule/free-slots` - Create free slot
- **Key Models**: Trip (Vehicle Schedule), FreeSlot

### 5. Trip Management
- **Document**: [`trip/api_specs.md`](./trip/api_specs.md)
- **Endpoints**:
  - `GET /trips` - Get trips by driver
  - `GET /trips/{trip_id}` - Get trip detail
  - `POST /trips/{trip_id}/start` - Start trip
  - `POST /trips/{trip_id}/end` - End trip
- **Key Models**: TripDetail

### 6. Receipt Management
- **Document**: [`receipt/api_specs.md`](./receipt/api_specs.md)
- **Endpoints**:
  - `GET /receipts` - Get receipts
  - `POST /receipts` - Create receipt (with image upload)
  - `PATCH /receipts/{receipt_id}/status` - Update receipt status (Admin/Expat)
- **Key Models**: Receipt

### 7. Attendance Report
- **Document**: [`attendance_report/api_specs.md`](./attendance_report/api_specs.md)
- **Endpoints**:
  - `GET /attendance-report` - Get monthly attendance report
- **Key Models**: AttendanceReport, DailyAttendanceRecord

## Common Response Formats

### Success Response
```json
{
  "data": { ... }  // Single object or array
}
```

### Error Response
```json
{
  "message": "Error message",
  "error": "Detailed error information"
}
```

## Common HTTP Status Codes

- **200 OK**: Request successful
- **201 Created**: Resource created successfully
- **400 Bad Request**: Validation error or invalid request
- **401 Unauthorized**: Authentication required or token invalid
- **403 Forbidden**: Access denied (insufficient permissions)
- **404 Not Found**: Resource not found
- **500 Internal Server Error**: Server error

## Date/Time Format

All dates and times in API requests and responses use **ISO 8601** format:
- Example: `"2025-08-15T09:00:00Z"`
- Date only: `"2025-08-15T00:00:00Z"`

## Duration Format

Durations are represented as **integers in seconds**:
- Example: `28800` seconds = 8 hours (8 * 60 * 60)

## Pagination (Future Enhancement)

For endpoints that return lists, pagination may be added:
```
GET /endpoint?page=1&limit=20
```

Response:
```json
{
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

## Filtering & Sorting (Future Enhancement)

Many endpoints support filtering and sorting:
```
GET /endpoint?status=pending&sort=created_at&order=desc
```

## Image Upload

For endpoints that accept image uploads (e.g., Receipt):
- **Content-Type**: `multart/form-data`
- **Supported Formats**: JPG, JPEG, PNG
- **Max File Size**: 5MB (recommended)

## Role-Based Access Control

### Driver Role
- Can view own data only
- Can create leave requests, receipts, trips
- Cannot approve/reject requests

### Expat/Admin Role
- Can view all data
- Can filter by driver
- Can approve/reject leave requests and receipts
- Can create resources on behalf of drivers

## Error Handling

All endpoints should return consistent error responses:
- **Network Errors**: Connection timeout, no internet
- **Validation Errors**: 400 Bad Request with error details
- **Authentication Errors**: 401 Unauthorized
- **Authorization Errors**: 403 Forbidden
- **Server Errors**: 500 Internal Server Error

## Rate Limiting (Future Enhancement)

API rate limiting may be implemented:
- **Limit**: 100 requests per minute per user
- **Headers**: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

## Versioning (Future Enhancement)

API versioning may be added:
```
GET /v1/attendance
```

## Testing

### Mock Data
The application includes a mock data system for UI testing. See [`MOCK_DATA.md`](./MOCK_DATA.md) for details.

### Test Credentials
For development/testing:
- **Driver**: username: `driver1`, password: `password123`
- **Expat**: username: `expat1`, password: `password123`

## Updates & Changes

When API specifications change:
1. Update the relevant feature's `api_specs.md` file
2. Update this index if endpoints are added/removed
3. Document breaking changes with version notes
4. Notify frontend team of changes

## Support

For API-related questions or issues:
1. Check the specific feature's API specification document
2. Review the data models section
3. Check error handling examples
4. Contact the backend team for clarification

