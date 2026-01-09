class ApiConstants {
  // Base URL - Update this with your actual API base URL
  static const String baseUrl = 'https://api.example.com';

  // API Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
