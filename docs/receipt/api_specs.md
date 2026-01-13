# Receipt Management - API Specifications

## Endpoints

### 1. Get Receipts
**Endpoint**: `GET /receipts`

**Description**: Fetches receipts with optional filtering

**Query Parameters**:
- `driver_id` (optional, string): Filter by specific driver ID. If not provided and user is admin/expat, returns all receipts.
- `status` (optional, string): Filter by status ("pending", "approved", "rejected")
- `type` (optional, string): Filter by receipt type ("fuel", "parking", "toll", "other")
- `start_date` (optional, ISO 8601 string): Start date for date range filter
- `end_date` (optional, ISO 8601 string): End date for date range filter

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Example**:
```http
GET /receipts?driver_id=123&status=pending
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response Success (200)**:
```json
{
  "data": [
    {
      "id": "receipt_001",
      "type": "fuel",
      "amount": 1500.50,
      "description": "Fuel purchase at Shell Station",
      "receipt_date": "2025-08-15T00:00:00Z",
      "status": "pending",
      "receipt_image_url": "https://example.com/receipts/receipt_001.jpg",
      "approved_by": null,
      "approved_at": null,
      "rejected_at": null,
      "rejection_reason": null,
      "submitted_at": "2025-08-15T10:30:00Z",
      "driver_id": "123",
      "driver_name": "John Doe",
      "fueled_liters": 45.5,
      "odometer_reading": 50000,
      "created_at": "2025-08-15T10:30:00Z",
      "updated_at": null
    },
    {
      "id": "receipt_002",
      "type": "parking",
      "amount": 250.00,
      "description": "Parking fee at Airport",
      "receipt_date": "2025-08-14T00:00:00Z",
      "status": "approved",
      "receipt_image_url": "https://example.com/receipts/receipt_002.jpg",
      "approved_by": "admin_001",
      "approved_at": "2025-08-14T15:00:00Z",
      "rejected_at": null,
      "rejection_reason": null,
      "submitted_at": "2025-08-14T12:00:00Z",
      "driver_id": "123",
      "driver_name": "John Doe",
      "fueled_liters": null,
      "odometer_reading": null,
      "created_at": "2025-08-14T12:00:00Z",
      "updated_at": "2025-08-14T15:00:00Z"
    }
  ],
  "summary": {
    "total_receipts": 10,
    "pending": 3,
    "approved": 6,
    "rejected": 1,
    "total_amount": 12500.50,
    "pending_amount": 2000.00,
    "approved_amount": 10000.50,
    "rejected_amount": 500.00
  }
}
```

**Response Error (400/401/500)**:
```json
{
  "message": "Failed to fetch receipts",
  "error": "Error details"
}
```

---

### 2. Create Receipt
**Endpoint**: `POST /receipts`

**Description**: Submit a new receipt with image upload

**Headers**:
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Request Body** (multipart/form-data):
```
type: "fuel" | "parking" | "toll" | "other"
amount: number (decimal)
description: string
receipt_date: ISO8601 string
receipt_image: File (image file - jpg, png, etc.)
driver_id: string (optional, auto-filled from token if driver user)
driver_name: string (optional, auto-filled from token if driver user)
fueled_liters: number (optional, required for fuel type)
odometer_reading: integer (optional, required for fuel type)
```

**Request Example** (using curl):
```bash
curl -X POST https://api.example.com/receipts \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -F "type=fuel" \
  -F "amount=1500.50" \
  -F "description=Fuel purchase at Shell Station" \
  -F "receipt_date=2025-08-15T00:00:00Z" \
  -F "receipt_image=@/path/to/receipt.jpg" \
  -F "fueled_liters=45.5" \
  -F "odometer_reading=50000"
```

**Response Success (200/201)**:
```json
{
  "data": {
    "id": "receipt_003",
    "type": "fuel",
    "amount": 1500.50,
    "description": "Fuel purchase at Shell Station",
    "receipt_date": "2025-08-15T00:00:00Z",
    "status": "pending",
    "receipt_image_url": "https://example.com/receipts/receipt_003.jpg",
    "approved_by": null,
    "approved_at": null,
    "rejected_at": null,
    "rejection_reason": null,
    "submitted_at": "2025-08-15T11:00:00Z",
    "driver_id": "123",
    "driver_name": "John Doe",
    "fueled_liters": 45.5,
    "odometer_reading": 50000,
    "created_at": "2025-08-15T11:00:00Z",
    "updated_at": null
  }
}
```

**Response Error (400/401/500)**:
```json
{
  "message": "Failed to create receipt",
  "error": "Error details"
}
```

---

### 3. Update Receipt Status (Admin/Expat Only)
**Endpoint**: `PATCH /receipts/{receipt_id}/status`

**Description**: Approve or reject a receipt - Admin/Expat only

**Path Parameters**:
- `receipt_id` (string): Receipt ID

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body**:
```json
{
  "status": "approved"
}
```

**For Rejection**:
```json
{
  "status": "rejected",
  "rejection_reason": "Receipt image is unclear"
}
```

**Request Example**:
```http
PATCH /receipts/receipt_001/status
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "status": "approved"
}
```

**Response Success (200)**:
```json
{
  "data": {
    "id": "receipt_001",
    "type": "fuel",
    "amount": 1500.50,
    "description": "Fuel purchase at Shell Station",
    "receipt_date": "2025-08-15T00:00:00Z",
    "status": "approved",
    "receipt_image_url": "https://example.com/receipts/receipt_001.jpg",
    "approved_by": "admin_001",
    "approved_at": "2025-08-15T12:00:00Z",
    "rejected_at": null,
    "rejection_reason": null,
    "submitted_at": "2025-08-15T10:30:00Z",
    "driver_id": "123",
    "driver_name": "John Doe",
    "fueled_liters": 45.5,
    "odometer_reading": 50000,
    "created_at": "2025-08-15T10:30:00Z",
    "updated_at": "2025-08-15T12:00:00Z"
  }
}
```

**Response Error (400/401/403/500)**:
```json
{
  "message": "Failed to update receipt status",
  "error": "Error details"
}
```

---

## Data Models

### Receipt
```json
{
  "id": "string",                          // Unique receipt ID
  "type": "fuel" | "parking" | "toll" | "other",
  "amount": "number",                      // Amount in currency (decimal)
  "description": "string",                 // Description of receipt
  "receipt_date": "ISO8601 string",       // Date of receipt (date only)
  "status": "pending" | "approved" | "rejected",
  "receipt_image_url": "string | null",   // URL to uploaded receipt image
  "approved_by": "string | null",         // Admin/expat user ID who approved
  "approved_at": "ISO8601 string | null", // Approval timestamp
  "rejected_at": "ISO8601 string | null", // Rejection timestamp
  "rejection_reason": "string | null",    // Reason for rejection (if rejected)
  "submitted_at": "ISO8601 string",       // Submission timestamp
  "driver_id": "string | null",           // Driver ID who submitted
  "driver_name": "string | null",         // Driver name who submitted
  "fueled_liters": "number | null",        // Fuel amount in liters (for fuel type)
  "odometer_reading": "integer | null",   // Odometer reading (for fuel type)
  "created_at": "ISO8601 string",        // Creation timestamp
  "updated_at": "ISO8601 string | null"  // Last update timestamp
}
```

### Receipt Summary (Optional)
```json
{
  "total_receipts": "integer",
  "pending": "integer",
  "approved": "integer",
  "rejected": "integer",
  "total_amount": "number",
  "pending_amount": "number",
  "approved_amount": "number",
  "rejected_amount": "number"
}
```

## Status Values
- **"pending"**: Receipt submitted, awaiting approval
- **"approved"**: Receipt approved by admin/expat
- **"rejected"**: Receipt rejected by admin/expat

## Receipt Types
- **"fuel"**: Fuel purchase receipt (requires `fueled_liters` and `odometer_reading`)
- **"parking"**: Parking fee receipt
- **"toll"**: Toll fee receipt
- **"other"**: Other expense receipt

## Error Handling

### Network Errors
- **Connection Timeout**: Shows toast message "Connection timeout. Please check your internet."
- **No Internet**: Shows toast message "No internet connection"
- **Server Error**: Shows toast message with server error message

### Validation Errors
- **400 Bad Request**: Shows toast message with validation error details
  - Missing required fields
  - Invalid amount (must be positive)
  - Invalid image format
  - Missing `fueled_liters` or `odometer_reading` for fuel type
- **401 Unauthorized**: Should redirect to login screen
- **403 Forbidden**: Shows toast message "Access denied" (for non-admin users trying to update status)
- **413 Payload Too Large**: Shows toast message "Image file is too large"

## Usage Flow

### Receipt History Screen:
1. **Screen Loads**: 
   - Calls `GET /receipts` (with driver_id if driver user)
   - Displays summary cards and list of receipts

2. **Filter Receipts** (optional):
   - User can filter by status, type, date range
   - Updates query parameters and calls `GET /receipts` with filters

### Add Receipt Screen:
1. **Screen Loads**: 
   - Form with fields: type, amount, description, receipt date, image picker
   - Additional fields for fuel type: fueled liters, odometer reading

2. **Select Image**:
   - User taps image picker
   - Selects image from gallery or camera
   - Image preview displayed

3. **Submit Receipt**:
   - User fills all required fields
   - Taps "Submit" button
   - Calls `POST /receipts` with multipart/form-data
   - Returns to Receipt History Screen

### Admin/Expat Actions:
1. **Approve Receipt**:
   - Admin/expat taps approve button on receipt
   - Calls `PATCH /receipts/{receipt_id}/status` with status "approved"
   - Receipt status updates

2. **Reject Receipt**:
   - Admin/expat taps reject button on receipt
   - Optionally enters rejection reason
   - Calls `PATCH /receipts/{receipt_id}/status` with status "rejected"
   - Receipt status updates

## Date Format
- **API**: ISO 8601 format (e.g., "2025-08-15T00:00:00Z")
- **Display**: DD-MMM-YYYY format (e.g., "15-Aug-2025")

## Image Upload
- **Supported Formats**: JPG, JPEG, PNG
- **Max File Size**: Recommended 5MB
- **Image Processing**: Server should resize/optimize images if needed
- **Storage**: Receipt images should be stored securely and accessible via URL

## Notes
- Receipt images are required for all receipt types
- For fuel receipts, `fueled_liters` and `odometer_reading` are required
- Amount must be a positive number
- Receipt date cannot be in the future
- Summary statistics can be calculated on the client side or provided by the API

