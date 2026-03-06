import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/user_profile_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/feature_card.dart';
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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  User? currentUser;
  double? _currentLat;
  double? _currentLon;
  bool _locationLoading = true;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _locationLoading = true;
      _locationError = null;
      _currentLat = null;
      _currentLon = null;
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
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      if (mounted) {
        setState(() {
          _currentLat = position.latitude;
          _currentLon = position.longitude;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.mitsuiDarkBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutConfirmation(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Card
                UserProfileCard(
                  userName: currentUser?.username ?? currentUser?.name ?? state.userName ?? 'User',
                  userRole: currentUser?.role,
                ),
                const SizedBox(height: 8),
                // Current Location Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: _locationError != null
                                ? Colors.grey
                                : AppTheme.mitsuiDarkBlue,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _locationLoading
                                ? const Text('Getting location...')
                                : _locationError != null
                                    ? Text(
                                        _locationError!,
                                        style: TextStyle(color: Colors.grey.shade700),
                                      )
                                    : Text(
                                        'Lat: ${_currentLat!.toStringAsFixed(5)}, Lon: ${_currentLon!.toStringAsFixed(5)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                          ),
                          if (!_locationLoading && _locationError != null)
                            TextButton(
                              onPressed: _loadLocation,
                              child: const Text('Retry'),
                            )
                          else if (!_locationLoading && _currentLat != null)
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _loadLocation,
                              tooltip: 'Refresh location',
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                            child: QuickActionButton(
                              type: QuickActionType.checkIn,
                              onTap: () async {
                                // Directly show check-in confirmation
                                final confirmed = await _showConfirmDialog(
                                  context,
                                  title: 'Check In',
                                  message:
                                      'Are you sure you want to check in?',
                                );
                                if (confirmed == true) {
                                  await _logAttendance(
                                    context: context,
                                    isCheckIn: true,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Additional Features Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Features',
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
                        itemCount: state.features.length,
                        itemBuilder: (context, index) {
                          final feature = state.features[index];
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
                              } else if (feature.route ==
                                  AppRoutes.vehicleSchedule) {
                                Navigator.pushNamed(context, feature.route);
                              } else if (feature.route ==
                                  AppRoutes.attendanceReport) {
                                Navigator.pushNamed(context, feature.route);
                              } else if (feature.route == AppRoutes.tripList) {
                                Navigator.pushNamed(context, feature.route);
                              } else if (feature.route == AppRoutes.receipts) {
                                Navigator.pushNamed(context, feature.route);
                              } else {
                                // Handle other feature taps
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
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
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
        final status = (data is Map<String, dynamic>) ? data['status'] : null;
        if (status == 200 || status == 1 || status == 'success') {
          Toast.showSuccess(
            context,
            isCheckIn ? 'Check-in logged successfully' : 'Check-out logged successfully',
          );
        } else {
          final message =
              (data is Map<String, dynamic>) ? (data['message'] ?? 'Failed to log attendance') : 'Failed to log attendance';
          Toast.showError(context, message.toString());
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
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
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
