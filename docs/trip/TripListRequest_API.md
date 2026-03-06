# TripListRequest API Documentation

## Endpoint
**URL**: `https://mitsuiv16pocmobapi.infotracktelematics.com:8443/api/Track/TripListRequest`  
**Method**: `POST`

## Request

### Headers
```
Content-Type: application/json
Authorization: Bearer {token}  // If authentication is required
```

### Request Body
```json
{
  "user_id": "string",    // User ID (for expat users) or "0" (for driver users)
  "driver_id": "string"   // Driver ID (for driver users) or "0" (for expat users)
}
```

### Request Body Rules
- **For Expat Users**: 
  - `user_id` = actual user ID
  - `driver_id` = `"0"`
  
- **For Driver Users**:
  - `user_id` = `"0"`
  - `driver_id` = actual driver ID

### Example Request
```json
// Expat user request
{
  "user_id": "123",
  "driver_id": "0"
}

// Driver user request
{
  "user_id": "0",
  "driver_id": "456"
}
```

---

## Response

### Success Response

**HTTP Status Code**: `200 OK`

**Response Body Format**:
```json
{
  "status": 200,           // API status code (200 = success)
  "message": "Success",    // Success message
  "data": [                // Array of trip requests
    {
      "TripRequestId": "string",      // Trip request ID
      "TripName": "string",           // Trip name
      "TripStartDate": "string",      // Start date (ISO 8601 format)
      "TripEndDate": "string",        // End date (ISO 8601 format)
      "Trip Status": "string"         // Trip status (or "TripStatus")
    }
  ]
}
```

**Success Criteria**:
1. ✅ HTTP status code = `200`
2. ✅ Response body `status` field = `200`
3. ✅ Response body `data` field is not `null` (can be empty array `[]`)

### Failed Response

**HTTP Status Codes**:
- `400` - Bad Request (invalid parameters)
- `401` - Unauthorized (authentication required)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `500` - Internal Server Error
- Other non-200 status codes

**Response Body Format (Error)**:
```json
{
  "status": 400,                    // API status code (non-200 = error)
  "message": "Error message here",  // Error description
  "data": null                      // null on error
}
```

**Failure Criteria**:
1. ❌ HTTP status code ≠ `200` OR
2. ❌ Response body `status` field ≠ `200` OR
3. ❌ Response body `data` field is `null`

---

## Status Codes Summary

### HTTP Status Codes (Response Status Code)
| Code | Meaning | Description |
|------|---------|-------------|
| `200` | OK | Request was successful |
| `400` | Bad Request | Invalid request parameters |
| `401` | Unauthorized | Authentication required or token invalid |
| `403` | Forbidden | Access denied (insufficient permissions) |
| `404` | Not Found | Endpoint or resource not found |
| `500` | Internal Server Error | Server error occurred |
| Other | Error | Various other error conditions |

### API Status Codes (Response Body `status` field)
| Code | Meaning | Description |
|------|---------|-------------|
| `200` | Success | API call successful, data returned |
| `400` | Bad Request | Invalid parameters or request format |
| `401` | Unauthorized | Authentication failed |
| `403` | Forbidden | Access denied |
| `500` | Server Error | Server-side error occurred |
| Other | Error | Various error conditions |

---

## Implementation Example

Based on the current codebase implementation:

```dart
// Success check
if (response.statusCode == 200) {
  final responseData = response.data;
  final apiStatus = responseData['status'] as int?;
  final apiMessage = responseData['message'] as String?;

  if (apiStatus == 200 && responseData['data'] != null) {
    // ✅ SUCCESS - Process the data
    final List<dynamic> data = responseData['data'] as List<dynamic>;
    // Process trip requests...
  } else {
    // ❌ FAILED - API returned error status
    throw ServerException(apiMessage ?? 'Failed to fetch trips');
  }
} else {
  // ❌ FAILED - HTTP error status
  throw ServerException('Failed to fetch trips');
}
```

---

## Error Handling

### Network Errors
- **Connection Timeout**: `Connection timeout. Please check your internet.`
- **No Internet**: `No internet connection`
- **Server Error**: Shows message from `response.data['message']`

### Validation Errors
- **400 Bad Request**: Invalid `user_id` or `driver_id` format
- **401 Unauthorized**: Should redirect to login screen
- **403 Forbidden**: Access denied message
- **500 Internal Server Error**: Server error message

---

## Notes

1. **Both status codes must be checked**: 
   - HTTP status code (`response.statusCode`)
   - API status code (`response.data['status']`)

2. **Success requires both**:
   - HTTP status = `200`
   - API status = `200`
   - `data` field is not `null`

3. **Empty data is still success**: 
   - If `data` is an empty array `[]`, it's still considered success
   - Only `null` data indicates failure

4. **Request parameters**:
   - Always send both `user_id` and `driver_id`
   - One must be `"0"` and the other must be the actual ID
   - Never send both as actual IDs or both as `"0"`

