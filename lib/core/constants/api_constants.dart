class ApiConstants {
  // Base URL - Mitsui Fleet Management API
  static const String baseUrl =
        "https://mitsuiv16pocmobapi.infotracktelematics.com/"; //:8443
    //   'https://mitsuiv16mobapi.infotracktelematics.com/';

  // API Endpoints
  static const String login = '/api/Auth/UserLogin';
  static const String register = '/api/Auth/Register'; // reserved
  static const String resetPassword = '/api/Auth/ResetPassword';
  static const String forceUpdateClient = '/api/Auth/ForceUpdateClient';

  // Trip APIs
  static const String tripDetails = '/api/Track/TripDetails'; // All trips
  static const String tripListRequest =
      '/api/Track/TripListRequest'; // Trip requests
  static const String updateVehicleApproveStatus =
      '/api/Track/UpdateVehicleApproveStatus';
  static const String cancelTrip = '/api/Track/UpdateTripCancel';

  /// Base URL for trip document (PDF) preview; full URL = tripDocumentBaseUrl + FilePath from API
  static const String tripDocumentBaseUrl =
      'https://mitsuipocapi.infotracktelematics.com:5001';

  // Leave
  static const String leaveRequests =
      '/api/Leave/LeaveRequest'; // apply / update
  static const String leaveTypes = '/api/Leave/LeaveType';
  static const String leaveList = '/api/Leave/LeaveList';
  static const String leaveStatusUpdate = '/api/Leave/LeaveStatusUpdate';

  // Attendance logging (driver check-in / check-out from dashboard)
  // NOTE: Adjust this path if backend uses a different route name
  static const String driverAttendanceLog = '/DriverAttendance';

  // Attendance approval (expat/user approves driver check-in / check-out)
  static const String driverAttendanceApproveStatus =
      '/DriverAttendanceApproveStatus';

  // Driver dashboard summary (driver status, latest attendance info)
  static const String driverDashboard = '/DriverDashboard';

  // Driver daily attendance summary (attendance report)
  static const String driverDailySummary = '/DriverDailySummary';

  // Receipts (Expense module)
  // NOTE: Update these endpoints to match backend routes.
  static const String receiptList = '/ListExpenseDetails';
  static const String receiptStatusUpdate = '/ExpenseApproveStatus';
  static const String expenseDetails = '/ExpenseDetails';

  // FCM Token
  static const String registerFcmToken = '/api/FcmToken/RegisterToken';
  static const String logoutFcmToken = '/api/FcmToken/Logout';

  // Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // ── About App (update these before each release) ──
  static const String appName = 'Mitsui FleetPlus';
  static const String appVersion = '1.0.3';
  static const String releaseDate = '08-July-2026';

  /// Integer build version used for force-update checks.
  /// Update this before each release and compare with ForceUpdateClient API.
  static const int localAppVersion = 15;

  /// Fallback client id when none is stored after login.
  static const int defaultClientId = 1;

  /// Set to true when odometer input is required for driver check-in/out.
  static const bool enableAttendanceOdometer = true;

  static const String androidPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=com.infotrack.mitsuifleet';
  static const String iosAppStoreUrl =
      'https://apps.apple.com/us/app/mitsui-fleet-app/id6760277339';
}
