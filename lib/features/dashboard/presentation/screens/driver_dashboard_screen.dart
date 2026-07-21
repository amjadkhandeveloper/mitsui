import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/user_profile_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/feature_card.dart';
import '../widgets/dashboard_drawer.dart';
import '../../domain/entities/dashboard_feature.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../login/domain/repositories/auth_repository.dart';
import '../../../login/domain/entities/user.dart';
import '../../../splash/data/datasources/local_storage_data_source.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/utils/location_permission_flow.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/dashboard_bootstrap_service.dart';
import 'package:dio/dio.dart';
import '../../../../core/widgets/logout_helper.dart';
import '../../../../core/widgets/dashboard_bootstrap_host.dart';
import '../widgets/attendance_odometer_dialog.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  User? currentUser;
  int? _checkStatus;
  int _standbyStatus = 0;
  double _odometerIn = 0;
  double _odometerOut = 0;
  bool _isAttendanceSubmitting = false;
  bool _isRefreshing = false;
  DashboardBootstrapController? _bootstrap;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bootstrap = DashboardBootstrapScope.maybeOf(context);
    if (bootstrap != null && bootstrap != _bootstrap) {
      _bootstrap?.removeListener(_onBootstrapUpdated);
      _bootstrap = bootstrap;
      _bootstrap!.addListener(_onBootstrapUpdated);
      _applyBootstrapSummary();
    }
  }

  @override
  void dispose() {
    _bootstrap?.removeListener(_onBootstrapUpdated);
    super.dispose();
  }

  void _onBootstrapUpdated() {
    _applyBootstrapSummary();
  }

  void _applyBootstrapSummary() {
    final summary = _bootstrap?.summary;
    if (summary == null) return;
    setState(() {
      _checkStatus = summary.checkStatus;
      _standbyStatus = summary.standbyStatus;
      _odometerIn = summary.odometerIn;
      _odometerOut = summary.odometerOut;
    });
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
      final bootstrap = DashboardBootstrapScope.maybeOf(context);
      if (bootstrap != null) {
        await bootstrap.refreshDashboard();
        return;
      }

      final summary =
          await di.sl<DashboardBootstrapService>().fetchDashboardSummary();
      if (!mounted || summary == null) return;
      setState(() {
        _checkStatus = summary.checkStatus;
        _standbyStatus = summary.standbyStatus;
        _odometerIn = summary.odometerIn;
        _odometerOut = summary.odometerOut;
      });
    } catch (_) {
      // Silently ignore dashboard status errors; quick action falls back to Check In
    }
  }

  /// Regular session active: CheckStatus = 1, StandByStatus = 0.
  bool get _isRegularSessionActive =>
      _checkStatus == 1 && _standbyStatus == 0;

  /// Standby session active: CheckStatus = 7, StandByStatus = 1.
  bool get _isStandbySessionActive =>
      _checkStatus == 7 && _standbyStatus == 1;

  /// Check-in approved by user: CheckStatus = 3.
  /// Driver can Check Out or Standby Out.
  bool get _isCheckInApproved => _checkStatus == 3;

  /// Check-out approved by user: CheckStatus = 4.
  /// Driver is free again → Check In + Standby In.
  bool get _isCheckOutApproved => _checkStatus == 4;

  /// Idle/free: Check Out approved, or neither regular/standby/check-in-approved.
  bool get _showIdlePairButtons =>
      _isCheckOutApproved ||
      (!_isRegularSessionActive &&
          !_isStandbySessionActive &&
          !_isCheckInApproved);
  bool get _showOutPairButtons => _isCheckInApproved;
  bool get _showCheckOutOnly => _isRegularSessionActive;
  bool get _showStandbyOutOnly => _isStandbySessionActive;

  double get _referenceOdometer =>
      _odometerOut <= 0 ? _odometerIn : _odometerOut;

  double _minimumOdometer(bool isCheckIn) => isCheckIn
      ? (_odometerOut > 0 ? _odometerOut : 0)
      : (_odometerIn > 0 ? _odometerIn : 0);

  Future<void> _submitAttendance({
    required int attendanceStatus,
  }) async {
    if (_isAttendanceSubmitting) return;

    final isCheckIn = attendanceStatus == ApiConstants.attendanceStatusCheckIn ||
        attendanceStatus == ApiConstants.attendanceStatusStandbyIn;
    final isStandby =
        attendanceStatus == ApiConstants.attendanceStatusStandbyIn ||
            attendanceStatus == ApiConstants.attendanceStatusStandbyOut;
    final standbyStatus = isStandby ? 1 : 0;

    double? odometer;
    if (ApiConstants.enableAttendanceOdometer) {
      odometer = await AttendanceOdometerDialog.show(
        context,
        isCheckIn: isCheckIn,
        initialValue: _referenceOdometer,
        minimumValue: isStandby ? 0 : _minimumOdometer(isCheckIn),
        readOnly: isStandby,
        title: isStandby
            ? (isCheckIn ? 'Standby In' : 'Standby Out')
            : null,
        confirmLabel: isStandby
            ? (isCheckIn ? 'Standby In' : 'Standby Out')
            : null,
      );
      if (odometer == null) return;
    } else if (isStandby) {
      odometer = _referenceOdometer;
    }

    setState(() => _isAttendanceSubmitting = true);
    await _logAttendance(
      context: context,
      attendanceStatus: attendanceStatus,
      standbyStatus: standbyStatus,
      odometer: odometer ?? 0,
    );
    await _loadDriverStatus();
    if (mounted) {
      setState(() => _isAttendanceSubmitting = false);
    }
  }

  Widget _buildAttendanceQuickActions() {
    final children = <Widget>[];

    if (_showIdlePairButtons) {
      children.addAll([
        Expanded(
          child: QuickActionButton(
            type: QuickActionType.checkIn,
            checkInLabel: 'Check In',
            attendanceStyle: AttendanceActionStyle.checkIn,
            animationDelayMs: 300,
            onTap: () => _submitAttendance(
              attendanceStatus: ApiConstants.attendanceStatusCheckIn,
            ),
          ),
        ),
        Expanded(
          child: QuickActionButton(
            type: QuickActionType.checkIn,
            checkInLabel: 'Standby In',
            attendanceStyle: AttendanceActionStyle.standbyIn,
            animationDelayMs: 350,
            onTap: () => _submitAttendance(
              attendanceStatus: ApiConstants.attendanceStatusStandbyIn,
            ),
          ),
        ),
      ]);
    } else if (_showOutPairButtons) {
      // CheckStatus = 3 (check-in approved): Check Out + Standby Out
      children.addAll([
        Expanded(
          child: QuickActionButton(
            type: QuickActionType.checkIn,
            checkInLabel: 'Check Out',
            attendanceStyle: AttendanceActionStyle.checkOut,
            animationDelayMs: 300,
            onTap: () => _submitAttendance(
              attendanceStatus: ApiConstants.attendanceStatusCheckOut,
            ),
          ),
        ),
        Expanded(
          child: QuickActionButton(
            type: QuickActionType.checkIn,
            checkInLabel: 'Standby Out',
            attendanceStyle: AttendanceActionStyle.standbyOut,
            animationDelayMs: 350,
            onTap: () => _submitAttendance(
              attendanceStatus: ApiConstants.attendanceStatusStandbyOut,
            ),
          ),
        ),
      ]);
    } else if (_showCheckOutOnly) {
      children.add(
        Expanded(
          child: QuickActionButton(
            type: QuickActionType.checkIn,
            checkInLabel: 'Check Out',
            attendanceStyle: AttendanceActionStyle.checkOut,
            animationDelayMs: 300,
            onTap: () => _submitAttendance(
              attendanceStatus: ApiConstants.attendanceStatusCheckOut,
            ),
          ),
        ),
      );
    } else if (_showStandbyOutOnly) {
      children.add(
        Expanded(
          child: QuickActionButton(
            type: QuickActionType.checkIn,
            checkInLabel: 'Standby Out',
            attendanceStyle: AttendanceActionStyle.standbyOut,
            animationDelayMs: 300,
            onTap: () => _submitAttendance(
              attendanceStatus: ApiConstants.attendanceStatusStandbyOut,
            ),
          ),
        ),
      );
    }

    return Opacity(
      opacity: _isAttendanceSubmitting ? 0.6 : 1.0,
      child: IgnorePointer(
        ignoring: _isAttendanceSubmitting,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(children: children),
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
    );
  }

  Future<void> _refreshDashboard() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    // Capture controller synchronously before any async gap.
    final bootstrap = _bootstrap ?? DashboardBootstrapScope.maybeOf(context);
    try {
      // Reload current user (in case role/name changed).
      await _loadCurrentUser();

      // Re-run the same fresh-load sequence used when opening the dashboard.
      if (bootstrap != null) {
        await bootstrap.refresh();
      } else {
        await _loadDriverStatus();
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
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
          _isRefreshing
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Refresh',
                  onPressed: _refreshDashboard,
                ),
        ],
      ),
      drawer: DashboardDrawer(
        userName: currentUser?.username ?? currentUser?.name ?? 'Driver',
        onLogout: () => LogoutHelper.showConfirmationAndLogout(context),
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
            padding: Responsive.pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Card
                UserProfileCard(
                  userName: currentUser?.username ?? currentUser?.name ?? 'Driver',
                  userRole: currentUser?.role ?? UserRole.driver,
                ),
                const SizedBox(height: 8),
                // Quick Actions Section
                Padding(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildAttendanceQuickActions(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Features Section
                Padding(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Features',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Feature Grid (responsive for phone / iPad)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount =
                              Responsive.featureGridColumns(context);
                          return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 1.0,
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
    required int attendanceStatus,
    required int standbyStatus,
    required double odometer,
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
        final ok =
            await LocationPermissionFlow.ensureForAttendanceFeature(context);
        if (!ok) return;
        final position = await LocationPermissionFlow.getCurrentPositionSafe();
        if (position == null) {
          if (mounted) {
            Toast.showError(context, 'Could not get location. Please try again.');
          }
          return;
        }
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
      final isCheckIn =
          attendanceStatus == ApiConstants.attendanceStatusCheckIn ||
              attendanceStatus == ApiConstants.attendanceStatusStandbyIn;
      final isStandby = standbyStatus == 1;
      final defaultRemark = isCheckIn
          ? (isStandby ? 'Standby-in done' : 'Check-in done')
          : (isStandby ? 'Standby-out done' : 'Check-out done');
      final defaultSuccess = isCheckIn
          ? (isStandby
              ? 'Standby-in logged successfully'
              : 'Check-in logged successfully')
          : (isStandby
              ? 'Standby-out logged successfully'
              : 'Check-out logged successfully');

      final body = <String, dynamic>{
        'mode': isCheckIn ? 1 : 2, // 1 = in, 2 = out
        'clientId': clientId,
        'zoneId': zoneId,
        'driverId': driverId,
        'attendanceDate': now,
        'lat': lat,
        'lon': lon,
        'odometer': odometer,
        'deviceId': 'device-id',
        'appVersion': ApiConstants.appVersion,
        'remarks': defaultRemark,
        'userId': 0,
        // 1=CheckIn, 2=CheckOut, 7=StandbyIn, 8=StandbyOut
        'status': attendanceStatus,
        'standByStatus': standbyStatus, // 0 = regular, 1 = standby
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
            (message != null && message.isNotEmpty) ? message : defaultSuccess,
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
}

