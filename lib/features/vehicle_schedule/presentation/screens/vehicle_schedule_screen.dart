import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../splash/data/datasources/local_storage_data_source.dart';
import '../../../login/domain/repositories/auth_repository.dart';
import '../../../login/domain/entities/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cubit/vehicle_schedule_cubit.dart';
import '../widgets/trip_card.dart';
import '../../domain/entities/trip.dart' as vehicle_trip;
import '../../../trip/presentation/cubit/trip_cubit.dart';

class VehicleScheduleScreen extends StatefulWidget {
  const VehicleScheduleScreen({super.key});

  @override
  State<VehicleScheduleScreen> createState() => _VehicleScheduleScreenState();
}

class _VehicleScheduleScreenState extends State<VehicleScheduleScreen> {
  bool _isExpatUser = false;

  @override
  void initState() {
    super.initState();
    // Load all trips
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Vehicle Schedule'),
        backgroundColor: AppTheme.mitsuiDarkBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadTrips(),
            tooltip: 'Refresh schedule',
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<VehicleScheduleCubit, VehicleScheduleState>(
            listener: (context, state) {
              if (state is VehicleScheduleError) {
                Toast.showError(context, state.message);
              }
            },
          ),
          BlocListener<TripCubit, TripState>(
            listener: (context, state) {
              if (state is TripActionSuccess) {
                Toast.showSuccess(context, state.message);
                // Reload trips after approve/reject
                _loadTrips();
              } else if (state is TripError) {
                Toast.showError(context, state.message);
              }
            },
          ),
        ],
        child: BlocBuilder<VehicleScheduleCubit, VehicleScheduleState>(
          builder: (context, state) {
          if (state is VehicleScheduleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VehicleScheduleLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                await _loadTrips();
              },
              child: state.trips.isEmpty
                  ? const Center(child: Text('No trips available'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: state.trips.length,
                      itemBuilder: (context, index) {
                        final trip = state.trips[index];
                        return TripCard(
                          trip: trip,
                          index: index,
                          isExpatUser: _isExpatUser,
                          onApprove: _isExpatUser && trip.status == vehicle_trip.TripStatus.pending
                              ? () => _handleApproveTrip(context, trip.id)
                              : null,
                          onReject: _isExpatUser && trip.status == vehicle_trip.TripStatus.pending
                              ? () => _handleRejectTrip(context, trip.id)
                              : null,
                        );
                      },
                    ),
            );
          }

          return const Center(child: Text('No data available'));
        },
        ),
      ),
    );
  }

  Future<void> _loadTrips() async {
    try {
      // Get IDs from local storage
      final localStorage = di.sl<LocalStorageDataSource>();
      String? backendUserId = await localStorage.getUserId(); // userid
      String? backendDriverId = await localStorage.getDriverId(); // driverid
      bool isExpat = false;

      // Determine role from stored values (expat vs driver)
      try {
        final sharedPrefs = di.sl<SharedPreferences>();
        final roleIdString = sharedPrefs.getString('roleid');
        if (roleIdString == '4') {
          isExpat = true;
        } else if (roleIdString == '7') {
          isExpat = false;
        } else {
          final storedRole = sharedPrefs.getString('role');
          if (storedRole == 'expat') {
            isExpat = true;
          }
        }
        // Store isExpat in state
        if (mounted) {
          setState(() {
            _isExpatUser = isExpat;
          });
        }
      } catch (_) {
        // Default handled below (driver)
        if (mounted) {
          setState(() {
            _isExpatUser = false;
          });
        }
      }

      // Fallback: if both ids missing, try to recover from AuthRepository.getCurrentUser
      if ((backendUserId == null || backendUserId.isEmpty) &&
          (backendDriverId == null || backendDriverId.isEmpty)) {
        try {
          final authRepo = di.sl<AuthRepository>();
          final result = await authRepo.getCurrentUser();
          result.fold(
            (_) {},
            (user) {
              if (user != null) {
                if (user.role == UserRole.expat) {
                  backendUserId = user.id;
                  isExpat = true;
                } else {
                  backendDriverId = user.driverId ?? user.id;
                  isExpat = false;
                }
                // Update isExpatUser state
                if (mounted) {
                  setState(() {
                    _isExpatUser = isExpat;
                  });
                }
              }
            },
          );
        } catch (_) {
          // ignore, will handle below if still null/empty
        }
      }

      if (!mounted) return;
      final cubit = context.read<VehicleScheduleCubit>();

      if ((isExpat && backendUserId != null && backendUserId!.isNotEmpty) ||
          (!isExpat && backendDriverId != null && backendDriverId!.isNotEmpty)) {
        // Pass current date to cubit (it's used for state but trips are not filtered by date)
        final currentDate = DateTime.now();
        if (isExpat) {
          await cubit.loadTripsForDate(
            currentDate,
            userId: backendUserId,
            driverId: null,
          );
        } else {
          await cubit.loadTripsForDate(
            currentDate,
            userId: null,
            driverId: backendDriverId,
          );
        }
      } else {
        if (mounted) {
          Toast.showError(context, 'User / Driver ID not found. Please login again.');
        }
      }
    } catch (e) {
      if (mounted) {
        Toast.showError(context, 'Failed to load vehicle schedule: $e');
      }
    }
  }

  Future<void> _handleApproveTrip(BuildContext context, String tripId) async {
    try {
      // Get user ID from local storage
      final localStorage = di.sl<LocalStorageDataSource>();
      String? userId = await localStorage.getUserId();

      // Fallback: if userid is missing, try to recover from AuthRepository.getCurrentUser
      if (userId == null || userId.isEmpty) {
        try {
          final authRepo = di.sl<AuthRepository>();
          final result = await authRepo.getCurrentUser();
          result.fold(
            (_) {},
            (user) {
              if (user != null) {
                userId = user.id;
              }
            },
          );
        } catch (_) {
          // ignore
        }
      }

      if (userId == null || userId!.isEmpty) {
        if (mounted) {
          Toast.showError(context, 'User ID not found. Please login again.');
        }
        return;
      }

      // Store context and userId before async operation
      final currentContext = context;
      final currentUserId = userId!;

      // Show confirmation dialog
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: currentContext,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Approve Trip',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to approve this trip?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Approve'),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        // Call approve trip action with user ID using TripCubit
        if (mounted) {
          context.read<TripCubit>().approveTrip(tripId, currentUserId);
        }
      }
    } catch (e) {
      if (mounted) {
        Toast.showError(context, 'Failed to approve trip: $e');
      }
    }
  }

  Future<void> _handleRejectTrip(BuildContext context, String tripId) async {
    try {
      // Get user ID from local storage
      final localStorage = di.sl<LocalStorageDataSource>();
      String? userId = await localStorage.getUserId();

      // Fallback: if userid is missing, try to recover from AuthRepository.getCurrentUser
      if (userId == null || userId.isEmpty) {
        try {
          final authRepo = di.sl<AuthRepository>();
          final result = await authRepo.getCurrentUser();
          result.fold(
            (_) {},
            (user) {
              if (user != null) {
                userId = user.id;
              }
            },
          );
        } catch (_) {
          // ignore
        }
      }

      if (userId == null || userId!.isEmpty) {
        if (mounted) {
          Toast.showError(context, 'User ID not found. Please login again.');
        }
        return;
      }

      // Store context and userId before async operation
      final currentContext = context;
      final currentUserId = userId!;

      // Show confirmation dialog
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: currentContext,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Reject Trip',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to reject this trip?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        // Call reject trip action with user ID using TripCubit
        if (mounted) {
          context.read<TripCubit>().rejectTrip(tripId, currentUserId);
        }
      }
    } catch (e) {
      if (mounted) {
        Toast.showError(context, 'Failed to reject trip: $e');
      }
    }
  }
}
