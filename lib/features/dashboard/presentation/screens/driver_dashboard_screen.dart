import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/user_profile_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/feature_card.dart';
import '../widgets/dashboard_drawer.dart';
import '../../domain/entities/dashboard_feature.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../login/domain/repositories/auth_repository.dart';
import '../../../login/domain/entities/user.dart';
import '../../../splash/data/datasources/local_storage_data_source.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/di/injection_container.dart' as di;
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  User? currentUser;
  String? _driverStatus;
  DateTime? _checkInTime;
  DateTime? _checkOutTime;
  // Office / reference location from dashboard API (Lat, Lon)
  double? _officeLat;
  double? _officeLon;
  double? _currentLat;
  bool _locationLoading = true;
  String? _locationError;
  bool _isAttendanceSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadDriverStatus();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _locationLoading = true;
      _locationError = null;
      _currentLat = null;
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _locationLoading = false;
            _locationError = 'Location is off';
          });
          await Geolocator.openLocationSettings();
        }
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _locationLoading = false;
            _locationError = 'Permission denied';
          });
          await Geolocator.openAppSettings();
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (mounted) {
        setState(() {
          _currentLat = position.latitude;
          _locationLoading = false;
          _locationError = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _locationLoading = false;
          _locationError = 'Unable to get location';
        });
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    final authRepository = di.sl<AuthRepository>();
    final result = await authRepository.getCurrentUser();
    result.fold(
      (failure) => null,
      (user) {
        if (mounted) {
          setState(() {
            currentUser = user;
          });
        }
      },
    );
  }

  Future<void> _loadDriverStatus() async {
    try {
      final localStorage = di.sl<LocalStorageDataSource>();
      final driverIdString = await localStorage.getDriverId();
      final userIdString = await localStorage.getUserId();

      final driverId = int.tryParse(driverIdString ?? '') ?? 0;
      final userId = int.tryParse(userIdString ?? '') ?? 0;

      if (driverId == 0 && userId == 0) {
        return;
      }

      final dio = di.sl<Dio>();
      final response = await dio.post(
        ApiConstants.driverDashboard,
        data: {
          'driverId': driverId,
          'userId': userId,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = response.data;
        String? status;
        DateTime? checkInTime;
        DateTime? checkOutTime;
        if (data is Map<String, dynamic>) {
          final list = data['data'];
          if (list is List && list.isNotEmpty) {
            final first = list.first;
            if (first is Map<String, dynamic>) {
              status = (first['Driver Status'] ?? first['driverStatus'])?.toString();

              // Parse CheckInTime (can be string or empty object {})
              final checkInValue = first['CheckInTime'];
              if (checkInValue != null &&
                  !(checkInValue is Map && checkInValue.isEmpty)) {
                if (checkInValue is String && checkInValue.isNotEmpty) {
                  try {
                    checkInTime = DateTime.parse(checkInValue);
                  } catch (_) {
                    checkInTime = null;
                  }
                }
              }

              // Parse CheckOutTime (can be string or empty object {})
              final checkOutValue = first['CheckOutTime'];
              if (checkOutValue != null &&
                  !(checkOutValue is Map && checkOutValue.isEmpty)) {
                if (checkOutValue is String && checkOutValue.isNotEmpty) {
                  try {
                    checkOutTime = DateTime.parse(checkOutValue);
                  } catch (_) {
                    checkOutTime = null;
                  }
                }
              }

              // Parse office/reference Lat/Lon for geofence (can be number or string)
              final latValue = first['Lat'] ?? first['lat'];
              final lonValue = first['Lon'] ?? first['lon'] ?? first['Lng'] ?? first['lng'];
              double? officeLat;
              double? officeLon;
              if (latValue is num) {
                officeLat = latValue.toDouble();
              } else if (latValue is String && latValue.isNotEmpty) {
                officeLat = double.tryParse(latValue);
              }
              if (lonValue is num) {
                officeLon = lonValue.toDouble();
              } else if (lonValue is String && lonValue.isNotEmpty) {
                officeLon = double.tryParse(lonValue);
              }

              if (officeLat != null && officeLon != null) {
                _officeLat = officeLat;
                _officeLon = officeLon;
              }
            }
          }
        }
        setState(() {
          _driverStatus = status;
          _checkInTime = checkInTime;
          _checkOutTime = checkOutTime;
        });
      }
    } catch (_) {
      // Silently ignore dashboard status errors; quick action falls back to Check In
    }
  }

  String get _normalizedDriverStatus =>
      (_driverStatus ?? '').trim().toLowerCase();

  bool get _hasCheckIn => _checkInTime != null;
  bool get _hasCheckOut => _checkOutTime != null;

  /// Dashboard attendance action based on latest driver status and times.
  ///
  /// Server status mapping (normalized to lowercase):
  /// - 'driver checkin'        -> waiting for approval, disable both actions
  /// - 'driver checkout'       -> waiting for approval, disable both actions
  /// - 'checkin approved' or
  ///   'checkin approval'      -> enable Check Out (when no checkout time)
  /// - 'checkout approved' or
  ///   'checkout approval'     -> enable Check In
  /// - 'approved by user'      -> if no checkout time: enable Check Out,
  ///                              otherwise enable Check In
  /// - 'not approve'           -> enable Check In
  bool get _showAttendanceButton {
    // No check-in recorded yet: always allow initial Check In
    if (!_hasCheckIn) {
      return true;
    }

    final status = _normalizedDriverStatus;

    // Waiting states – disable both actions
    if (status == 'driver checkin' || status == 'driver checkout') {
      return false;
    }

    // Check-in approved -> allow Check Out (while no checkout time)
    if ((status == 'checkin approved' || status == 'checkin approval') &&
        !_hasCheckOut) {
      return true;
    }

    // Checkout approved -> allow next Check In
    if (status == 'checkout approved' || status == 'checkout approval') {
      return true;
    }

    // Approved by User ->
    //   if no checkout time => show Check Out
    //   else                => show Check In
    if (status == 'approved by user') {
      return true;
    }

    // Not Approve -> enable Check In
    if (status == 'not approve') {
      return true;
    }

    // Any other unknown state: hide button to be safe
    return false;
  }

  String get _attendanceButtonLabel {
    final status = _normalizedDriverStatus;

    // No check-in yet or explicit "Not Approve" -> Check In
    if (!_hasCheckIn || status == 'not approve') {
      return 'Check In';
    }

    // Check-in approved/approval and no checkout yet -> Check Out
    if ((status == 'checkin approved' || status == 'checkin approval') &&
        !_hasCheckOut) {
      return 'Check Out';
    }

    // Checkout approved/approval -> Check In
    if (status == 'checkout approved' || status == 'checkout approval') {
      return 'Check In';
    }

    // Approved by User -> depends on checkout time
    if (status == 'approved by user') {
      return !_hasCheckOut ? 'Check Out' : 'Check In';
    }

    // Fallback for any other visible state
    return 'Check In';
  }

  bool get _isAttendanceActionCheckIn {
    final status = _normalizedDriverStatus;

    // No check-in yet or explicit "Not Approve" -> action is Check In
    if (!_hasCheckIn || status == 'not approve') {
      return true;
    }

    // Check-in approved/approval and no checkout yet -> action is Check Out
    if ((status == 'checkin approved' || status == 'checkin approval') &&
        !_hasCheckOut) {
      return false;
    }

    // Checkout approved/approval -> next action is Check In
    if (status == 'checkout approved' || status == 'checkout approval') {
      return true;
    }

    // Approved by User -> mirrors label logic
    if (status == 'approved by user') {
      return _hasCheckOut; // if checkout exists -> Check In, else Check Out
    }

    // For any other visible state, default to Check In
    return true;
  }

  Future<void> _refreshDashboard() async {
    // Reload current user (in case role/name changed) and latest driver status
    await _loadCurrentUser();
    await _loadDriverStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Driver Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.mitsuiDarkBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _refreshDashboard,
          ),
        ],
      ),
      drawer: DashboardDrawer(
        userName: currentUser?.username ?? currentUser?.name ?? 'Driver',
        onLogout: () => _showLogoutConfirmation(context),
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Driver-specific features - rearranged: My Leave above My Trips.
          // Hide Receipts card for release.
          final driverFeatures = [
            const DashboardFeature(
              id: 'leave',
              title: 'My Leave',
              subtitle: 'View my leave',
              icon: Icons.event_note,
              route: '/leave-list',
            ),
            const DashboardFeature(
              id: 'attendance',
              title: 'Attendance',
              subtitle: 'Check in/out',
              icon: Icons.access_time,
              route: '/attendance',
            ),
            const DashboardFeature(
              id: 'receipts',
              title: 'Receipts',
              subtitle: 'View receipts',
              icon: Icons.receipt_long,
              route: '/receipts',
            ),
            const DashboardFeature(
              id: 'trips',
              title: 'My Trips',
              subtitle: 'View my trips',
              icon: Icons.directions_car,
              route: '/trips',
            ),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Card
                UserProfileCard(
                  userName: currentUser?.username ?? currentUser?.name ?? 'Driver',
                  userRole: currentUser?.role ?? UserRole.driver,
                ),
                const SizedBox(height: 8),
                // Current Location Card
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16),
                //   child: Card(
                //     margin: EdgeInsets.zero,
                //     child: Padding(
                //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                //       child: Row(
                //         children: [
                //           Icon(
                //             Icons.location_on,
                //             color: _locationError != null
                //                 ? Colors.grey
                //                 : AppTheme.mitsuiDarkBlue,
                //             size: 28,
                //           ),
                //           const SizedBox(width: 12),
                //           Expanded(
                //             child: _locationLoading
                //                 ? const Text('Getting location...')
                //                 : _locationError != null
                //                     ? Text(
                //                         _locationError!,
                //                         style: TextStyle(color: Colors.grey.shade700),
                //                       )
                //                     : const Text(
                //                         'Location is ready for check-in / check-out',
                //                         style: TextStyle(
                //                           fontSize: 13,
                //                           color: Colors.black87,
                //                         ),
                //                       ),
                //           ),
                //           if (!_locationLoading && _locationError != null)
                //             TextButton(
                //               onPressed: _loadLocation,
                //               child: const Text('Retry'),
                //             )
                //           else if (!_locationLoading && _currentLat != null)
                //             IconButton(
                //               icon: const Icon(Icons.refresh),
                //               onPressed: _loadLocation,
                //               tooltip: 'Refresh location',
                //             ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 8),
                // Quick Actions Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Opacity(
                                  opacity: _isAttendanceSubmitting ? 0.6 : 1.0,
                                  child: IgnorePointer(
                                    ignoring: _isAttendanceSubmitting,
                                    child: QuickActionButton(
                                      type: QuickActionType.checkIn,
                                      checkInLabel: _attendanceButtonLabel,
                                      enabled: _showAttendanceButton,
                                      onTap: () async {
                                        if (!_showAttendanceButton ||
                                            _isAttendanceSubmitting) return;
                                        // Directly show check-in/check-out confirmation
                                        final confirmed = await _showConfirmDialog(
                                          context,
                                          title: _isAttendanceActionCheckIn
                                              ? 'Check In'
                                              : 'Check Out',
                                          message: _isAttendanceActionCheckIn
                                              ? 'Are you sure you want to check in?'
                                              : 'Are you sure you want to check out?',
                                        );
                                        if (confirmed == true) {
                                          setState(() {
                                            _isAttendanceSubmitting = true;
                                          });
                                          await _logAttendance(
                                            context: context,
                                            isCheckIn: _isAttendanceActionCheckIn,
                                          );
                                          await _loadDriverStatus();
                                          if (mounted) {
                                            setState(() {
                                              _isAttendanceSubmitting = false;
                                            });
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                if (_isAttendanceSubmitting)
                                  const SizedBox(
                                    height: 28,
                                    width: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Features Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Features',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Feature Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.92,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: driverFeatures.length,
                        itemBuilder: (context, index) {
                          final feature = driverFeatures[index];
                          return FeatureCard(
                            feature: feature,
                            index: index,
                            onTap: () {
                              if (feature.route == AppRoutes.attendance) {
                                Navigator.pushNamed(
                                  context,
                                  feature.route,
                                  arguments: currentUser,
                                );
                              } else if (feature.route == AppRoutes.tripList) {
                                Navigator.pushNamed(context, feature.route);
                              } else if (feature.route == AppRoutes.receipts) {
                                Navigator.pushNamed(context, feature.route);
                              } else if (feature.route == AppRoutes.leaveList) {
                                Navigator.pushNamed(
                                  context,
                                  feature.route,
                                  arguments: currentUser,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${feature.title} tapped'),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _logAttendance({
    required BuildContext context,
    required bool isCheckIn,
  }) async {
    try {
      final localStorage = di.sl<LocalStorageDataSource>();
      final clientId = await localStorage.getClientId() ?? 0;
      final zoneId = await localStorage.getZoneId() ?? 0;
      final driverIdString = await localStorage.getDriverId();

      if (driverIdString == null || driverIdString.isEmpty) {
        Toast.showError(context, 'Driver ID not found. Please login again.');
        return;
      }

      final driverId = int.tryParse(driverIdString) ?? 0;

      double lat = 0;
      double lon = 0;
      try {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (mounted) {
            Toast.showError(context, 'Opening location settings. Enable location and try again.');
            await Geolocator.openLocationSettings();
          }
          return;
        }
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
            if (mounted) {
              Toast.showError(context, 'Opening app settings. Grant location permission and try again.');
              await Geolocator.openAppSettings();
            }
            return;
          }
        }
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
        lat = position.latitude;
        lon = position.longitude;
      } catch (e) {
        if (mounted) {
          Toast.showError(context, 'Could not get location. Please try again.');
        }
        return;
      }

      final dio = di.sl<Dio>();
      final now = DateTime.now().toIso8601String();

      final body = {
        'mode': isCheckIn ? 1 : 2, // 1 = check-in, 2 = check-out
        'clientId': clientId,
        'zoneId': zoneId,
        'driverId': driverId,
        'attendanceDate': now,
        'lat': lat,
        'lon': lon,
        'odometer': 0,
        'deviceId': 'device-id',
        'appVersion': '1.0.0',
        'remarks': isCheckIn ? 'Check-in done' : 'Check-out done',
        'userId': 0,
        'status': isCheckIn ? 1 : 2, // 1 = check-in, 2 = check-out
      };

      final response = await dio.post(
        ApiConstants.driverAttendanceLog,
        data: body,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        dynamic status;
        String? message;

        if (data is Map<String, dynamic>) {
          status = data['status'];
          message = data['message']?.toString();
        } else {
          message = data?.toString();
        }

        final isSuccess =
            status == 200 || status == 1 || status == 'success';

        if (isSuccess) {
          Toast.showSuccess(
            context,
            (message != null && message.isNotEmpty)
                ? message
                : (isCheckIn
                    ? 'Check-in logged successfully'
                    : 'Check-out logged successfully'),
          );
        } else {
          Toast.showError(
            context,
            (message != null && message.isNotEmpty)
                ? message
                : 'Failed to log attendance',
          );
        }
      } else {
        Toast.showForStatusCode(
          context,
          statusCode: response.statusCode,
          message: 'Failed to log attendance. (${response.statusCode})',
        );
      }
    } catch (e) {
      Toast.showError(context, 'Failed to log attendance: $e');
    }
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final authRepository = di.sl<AuthRepository>();
              await authRepository.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

