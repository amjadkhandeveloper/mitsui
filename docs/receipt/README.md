# Receipt Feature

## Overview
The Receipt feature allows drivers to submit expense receipts (fuel, parking, toll, etc.) for approval. Expats can view all receipts and their approval status.

## Features

### Receipt History Screen
- **Summary Cards**: Three cards showing:
  - Total receipts count
  - Approved receipts count
  - Pending receipts count
- **Filter**: Filter receipts by status (All, Approved, Pending, Rejected)
- **Receipt List**: Displays all receipts with:
  - Receipt type badge (Fuel, Parking, Toll, Other)
  - Status badge (Approved, Pending, Rejected)
  - Date
  - Amount
  - Description
  - Approval/rejection details
- **Add Button**: Floating action button to add new receipt
- **Pull to Refresh**: Swipe down to reload receipts

### Add Receipt Screen
- **Receipt Date**: Date picker for receipt date
- **Receipt Type**: Dropdown selection (Fuel, Parking, Toll, Other)
- **Amount**: Amount input field with ₹ symbol
- **Fueled Liters**: (Only for Fuel type) Fuel quantity input
- **Odometer Reading**: (Only for Fuel type) Odometer reading in km
- **Description**: Multi-line description field
- **Receipt Image**: Image picker to upload receipt photo
- **Submit Button**: Submit receipt for approval

## Receipt Types
- **Fuel**: Requires fueled liters and odometer reading
- **Parking**: Standard receipt
- **Toll**: Standard receipt
- **Other**: Standard receipt

## Receipt Status Flow
1. **Pending**: Receipt submitted, awaiting approval
2. **Approved**: Receipt approved by manager/expat
3. **Rejected**: Receipt rejected with reason

## Navigation
- **From Dashboard**: "Receipt" feature card → Receipt History Screen
- **From Receipt History**: Floating action button → Add Receipt Screen

## API Endpoints

### Get Receipts
- **Endpoint**: `GET /receipts`
- **Query Parameters**:
  - `driver_id` (optional): Filter receipts by driver
  - `status` (optional): Filter receipts by status (pending/approved/rejected)
- **Response**: List of receipts

### Create Receipt
- **Endpoint**: `POST /receipts`
- **Content-Type**: `multipart/form-data`
- **Body Fields**:
  - `type`: Receipt type (fuel/parking/toll/other)
  - `amount`: Amount in rupees
  - `description`: Description text
  - `receipt_date`: ISO 8601 date string
  - `receipt_image`: Image file (optional)
  - `fueled_liters`: Fuel quantity (optional, for fuel type)
  - `odometer_reading`: Odometer reading (optional, for fuel type)
- **Response**: Created receipt object

## Data Models

### Receipt Entity
- `id`: Unique receipt identifier
- `type`: Receipt type (fuel/parking/toll/other)
- `amount`: Amount in rupees
- `description`: Description text
- `receiptDate`: Date of receipt
- `status`: Receipt status (pending/approved/rejected)
- `receiptImageUrl`: URL of uploaded receipt image (optional)
- `approvedBy`: Name of approver (optional)
- `approvedAt`: Approval timestamp (optional)
- `rejectedAt`: Rejection timestamp (optional)
- `rejectionReason`: Reason for rejection (optional)
- `submittedAt`: Submission timestamp
- `driverId`: Driver ID (optional)
- `driverName`: Driver name (optional)
- `fueledLiters`: Fuel quantity in liters (optional, for fuel type)
- `odometerReading`: Odometer reading in km (optional, for fuel type)
- `createdAt`: Creation timestamp
- `updatedAt`: Last update timestamp (optional)

## User Roles

### Driver
- Can submit receipts
- Views only their own receipts
- Can upload receipt images

### Expat
- Views all receipts
- Can approve/reject receipts (via API)
- Read-only access to receipt list

