/// App Configuration
/// Set USE_MOCK_DATA to true to use dummy data instead of API calls
/// Set to false to use real API endpoints
class AppConfig {
  /// App version shown in dashboard drawer (match pubspec.yaml version)
  static const String APP_VERSION = '1.0.0';

  // Global mock data flag (for backward compatibility)
  // Set this to true to use mock data for all features, false to use real API
  static const bool USE_MOCK_DATA = false;

  // Feature-specific mock data flags
  // Only Receipt uses mock data, rest are live
  static const bool USE_MOCK_DATA_ATTENDANCE = false;
  static const bool USE_MOCK_DATA_RECEIPT = true;

  // API Base URL (only used when USE_MOCK_DATA is false)
  static const String BASE_URL = 'https://api.example.com';
}

