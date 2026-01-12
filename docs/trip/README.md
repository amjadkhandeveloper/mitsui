# Trip Feature

## Overview
The Trip feature allows drivers and expats to view and manage trips. Drivers can start and end trips, record odometer readings, and view trip details.

## Features

### Trip List Screen
- **List View**: Displays all trips (for expats) or driver-specific trips
- **Trip Cards**: Each card shows:
  - Vehicle name and ID
  - Customer name
  - Location
  - Schedule start date and time
  - Status badge (Scheduled/Started/Completed/Cancelled)
- **Pull to Refresh**: Swipe down to reload trips
- **Navigation**: Tap on a trip card to view trip details

### Trip Detail Screen
- **Trip Details Section**:
  - Vehicle ID
  - Route
  - Customer
  - Location
  - Pickup/Drop type
  - Schedule Start time
  - Actual Start time
- **Odometer Readings**:
  - Trip Start Odometer input (enabled when trip is scheduled)
  - Trip End Odometer input (enabled when trip is started)
- **Action Buttons**:
  - **Start Trip**: Green button (enabled when trip is scheduled and start odometer is entered)
  - **End Trip**: Grey button (enabled when trip is started and end odometer is entered)

## Trip Status Flow
1. **Scheduled**: Trip is created and waiting to start
2. **Started**: Driver has started the trip with start odometer reading
3. **Completed**: Driver has ended the trip with end odometer reading
4. **Cancelled**: Trip has been cancelled

## Navigation
- **From Dashboard**: "Trips" feature card → Trip List Screen
- **From Trip List**: Tap on trip card → Trip Detail Screen

## API Endpoints

### Get Trips
- **Endpoint**: `GET /trips`
- **Query Parameters**:
  - `driver_id` (optional): Filter trips by driver
  - `status` (optional): Filter trips by status
- **Response**: List of trip details

### Get Trip Detail
- **Endpoint**: `GET /trips/:tripId`
- **Response**: Single trip detail

### Start Trip
- **Endpoint**: `POST /trips/:tripId/start`
- **Body**: `{ "trip_start_odometer": <number> }`
- **Response**: Updated trip detail

### End Trip
- **Endpoint**: `POST /trips/:tripId/end`
- **Body**: `{ "trip_end_odometer": <number> }`
- **Response**: Updated trip detail

## Data Models

### TripDetail Entity
- `id`: Unique trip identifier
- `vehicleId`: Vehicle ID
- `vehicleName`: Vehicle name
- `route`: Route information (optional)
- `customer`: Customer name (optional)
- `location`: Location address (optional)
- `pickupDrop`: "PICK UP" or "DROP" (optional)
- `scheduleStart`: Scheduled start date/time
- `actualStart`: Actual start date/time (optional)
- `actualEnd`: Actual end date/time (optional)
- `status`: Trip status (scheduled/started/completed/cancelled)
- `tripStartOdometer`: Odometer reading at trip start (optional)
- `tripEndOdometer`: Odometer reading at trip end (optional)
- `driverId`: Driver ID (optional)
- `driverName`: Driver name (optional)
- `createdAt`: Creation timestamp
- `updatedAt`: Last update timestamp (optional)

## User Roles

### Driver
- Views only their own trips
- Can start and end trips
- Must enter odometer readings

### Expat
- Views all trips
- Can view trip details
- Cannot start or end trips (read-only)

