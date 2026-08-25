/// Feature flags and leftover scaffold config.
///
/// Live HTTP host is [ApiConstants.baseUrl], not [BASE_URL] below.
/// Keep mock flags `false` for store builds.
class AppConfig {
  /// Drawer version string. Prefer [ApiConstants.appVersion] as the source of truth;
  /// this value is currently `1.0.0` while About App shows `1.0.5`.
  static const String APP_VERSION = '1.0.0';

  /// When true, trip / leave / attendance / receipt data sources return dummy data.
  static const bool USE_MOCK_DATA = false;

  static const bool USE_MOCK_DATA_ATTENDANCE = false;
  static const bool USE_MOCK_DATA_RECEIPT = false;

  /// Unused placeholder from the original template. Dio uses ApiConstants.baseUrl.
  static const String BASE_URL = 'https://api.example.com';
}
