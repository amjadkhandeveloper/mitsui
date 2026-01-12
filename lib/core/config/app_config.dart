/// App Configuration
/// Set USE_MOCK_DATA to true to use dummy data instead of API calls
/// Set to false to use real API endpoints
class AppConfig {
  // Set this to true to use mock data, false to use real API
  static const bool USE_MOCK_DATA = true;

  // API Base URL (only used when USE_MOCK_DATA is false)
  static const String BASE_URL = 'https://api.example.com';
}

