class ApiConstants {
  // Base URL - Mitsui Fleet Management API
  static const String baseUrl =
      "https://mitsuiv16pocmobapi.infotracktelematics.com:8443/";
  //  'https://mitsuiv16mobapi.infotracktelematics.com/';

  // API Endpoints
  static const String login = '/api/Auth/UserLogin';
  static const String register = '/api/Auth/Register'; // reserved

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

  // Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
