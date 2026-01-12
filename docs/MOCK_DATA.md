# Mock Data Configuration

## Overview
This project includes a mock data system that allows you to test the UI without a working backend API. The mock data can be easily enabled or disabled.

## How to Use Mock Data

### Enable Mock Data
1. Open `lib/core/config/app_config.dart`
2. Set `USE_MOCK_DATA = true`

```dart
class AppConfig {
  static const bool USE_MOCK_DATA = true; // Set to true for mock data
}
```

### Disable Mock Data (Use Real API)
1. Open `lib/core/config/app_config.dart`
2. Set `USE_MOCK_DATA = false`

```dart
class AppConfig {
  static const bool USE_MOCK_DATA = false; // Set to false for real API
}
```

## Mock Data Features

### What's Included
- **Attendance Records**: 7 days of mock attendance data
- **Drivers**: 3 mock drivers (John Doe, Jane Smith, Mike Johnson)
- **Attendance Report**: Monthly report with 10 days of data
- **Leave Requests**: 3 mock leave requests (pending, approved, rejected)
- **Vehicle Schedule Trips**: 2 mock trips for selected date
- **Trip Details**: 2 mock trip details
- **Receipts**: 5 mock receipts (fuel, parking, toll, other)

### Mock Data Location
All mock data is defined in `lib/core/mock/mock_data_service.dart`

## Removing Mock Data

To completely remove mock data support:

1. **Delete the mock data service:**
   ```bash
   rm lib/core/mock/mock_data_service.dart
   ```

2. **Delete the config file (optional):**
   ```bash
   rm lib/core/config/app_config.dart
   ```

3. **Remove mock data checks from data sources:**
   - Remove `AppConfig.USE_MOCK_DATA` checks from all data source files
   - Remove imports of `app_config.dart` and `mock_data_service.dart`

4. **Files to update:**
   - `lib/features/attendance/data/datasources/attendance_remote_data_source.dart`
   - `lib/features/attendance_report/data/datasources/attendance_report_remote_data_source.dart`
   - `lib/features/leave/data/datasources/leave_remote_data_source.dart`
   - `lib/features/vehicle_schedule/data/datasources/vehicle_schedule_remote_data_source.dart`
   - `lib/features/trip/data/datasources/trip_remote_data_source.dart`
   - `lib/features/receipt/data/datasources/receipt_remote_data_source.dart`

## Notes

- Mock data includes a simulated network delay (500ms) to mimic real API behavior
- Mock data respects filters (driverId, status, date) where applicable
- When mock data is enabled, all API calls return mock responses
- Mock data is perfect for UI testing and development

