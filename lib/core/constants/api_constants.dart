/// Central API host, paths, timeouts, and release metadata for Mitsui Fleet.
///
/// Before each store release, update:
/// - [appName], [appVersion], [releaseDate]
/// - [localAppVersion] (integer compared with ForceUpdateClient)
/// - [useStagingApi] (must stay `false` for production builds)
class ApiConstants {
  /// Switch API host: `true` = staging (POC), `false` = production.
  /// Keep `false` for Play Store / App Store builds.
  static const bool useStagingApi = true;

  /// Production mobile API (path-style HTTPS, no custom port).
  static const String _prodBaseUrl =
      'https://mitsuiv16mobapi.infotracktelematics.com/';

  /// Staging / POC mobile API used for QA.
  static const String _stagingBaseUrl =
      'https://mitsuiv16pocmobapi.infotracktelematics.com/';

  /// Resolved base URL used by [DioClient]. Trailing slash is required
  /// so relative paths like `/api/Auth/UserLogin` concatenate correctly.
  static const String baseUrl =
      useStagingApi ? _stagingBaseUrl : _prodBaseUrl;

  // ── About App (update these before each release) ──
  static const String appName = 'Mitsui FleetPlus Prod';
  static const String appVersion = '1.0.6';
  static const String releaseDate = '25-August-2026 11:50:00';

  // ── Auth ──
  static const String login = '/api/Auth/UserLogin';
  /// Reserved; not wired in the current login flow.
  static const String register = '/api/Auth/Register';
  static const String resetPassword = '/api/Auth/ResetPassword';
  /// Returns the minimum supported [localAppVersion] and force-logout flag.
  static const String forceUpdateClient = '/api/Auth/ForceUpdateClient';

  // ── Trip / Track ──
  /// All trips for the signed-in user or driver.
  static const String tripDetails = '/api/Track/TripDetails';
  /// Pending trip requests (expat approval list).
  static const String tripListRequest = '/api/Track/TripListRequest';
  static const String updateVehicleApproveStatus =
      '/api/Track/UpdateVehicleApproveStatus';
  static const String cancelTrip = '/api/Track/UpdateTripCancel';

  /// Host for trip document (PDF) preview.
  /// Full URL = [tripDocumentBaseUrl] + `FilePath` from the API.
  /// Warning: this still points at the POC host even when [useStagingApi] is false.
  static const String tripDocumentBaseUrl =
      'https://mitsuipocapi.infotracktelematics.com:5001';

  // ── Leave ──
  /// Apply or update a leave request.
  static const String leaveRequests = '/api/Leave/LeaveRequest';
  static const String leaveTypes = '/api/Leave/LeaveType';
  static const String leaveList = '/api/Leave/LeaveList';
  static const String leaveStatusUpdate = '/api/Leave/LeaveStatusUpdate';

  // ── Attendance ──
  // These routes omit the `/api/...` prefix used by Auth/Track/Leave.
  // Confirm with backend if a prefix is added later.
  static const String driverAttendanceLog = '/DriverAttendance';
  static const String driverAttendanceApproveStatus =
      '/DriverAttendanceApproveStatus';
  static const String driverDashboard = '/DriverDashboard';
  static const String driverDailySummary = '/DriverDailySummary';

  // ── Receipts / Expense ──
  static const String receiptList = '/ListExpenseDetails';
  static const String receiptStatusUpdate = '/ExpenseApproveStatus';
  static const String expenseDetails = '/ExpenseDetails';

  // ── FCM ──
  static const String registerFcmToken = '/api/FcmToken/RegisterToken';
  static const String logoutFcmToken = '/api/FcmToken/Logout';

  // ── Timeouts (milliseconds) ──
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  /// Integer build version used for force-update checks.
  /// Must be incremented before each release and compared with ForceUpdateClient.
  static const int localAppVersion = 13;

  /// Fallback client id when none is stored after login.
  static const int defaultClientId = 1;

  /// When true, driver check-in / check-out requires an odometer reading.
  static const bool enableAttendanceOdometer = true;

  /// Logs URL, method, request body, and response for every Dio API call.
  /// Keep `false` in production; request bodies can include login passwords.
  static const bool enableApiTrace = true;

  /// DriverAttendance `status` values (mode stays 1=In / 2=Out).
  static const int attendanceStatusCheckIn = 1;
  static const int attendanceStatusCheckOut = 2;
  static const int attendanceStatusStandbyIn = 7;
  static const int attendanceStatusStandbyOut = 8;

  static const String androidPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=com.infotrack.mitsuifleet';
  static const String iosAppStoreUrl =
      'https://apps.apple.com/us/app/mitsui-fleet-app/id6760277339';
}
